module IDU #(WIDTH = 64)(
    input wire rst,
    input wire [WIDTH-1:0]    pc,
    input wire [31 : 0]       inst,
    input wire [WIDTH-1:0]    rs1_data,
    input wire [WIDTH-1:0]    rs2_data,
    
    output wire               br_taken,
    output wire [5 :0]        inst_type,
    output wire [5 :0]        ld_type,
    output wire [3 :0]        st_type,
    output wire               inst_32bit,

    output wire [4 : 0]       rs1,
    output wire [4 : 0]       rs2,
    output wire               rd_wen,
    output wire [4 : 0]       rd,
    
    output wire [16: 0]       alu_op,
    output wire [WIDTH-1:0]   op1,
    output wire [WIDTH-1:0]   op2
);

    wire[6:0] opcode;
    wire[6:0] func7;
    wire[2:0] func3;

    wire[WIDTH-1:0] imm;
    wire[WIDTH-1:0] op1_64;
    wire[WIDTH-1:0] op2_64;

    assign opcode = inst[6 :0 ];
    assign rd     = inst[11:7 ];
    assign func3  = inst[14:12];
    assign func7  = inst[31:25];
    assign rs1    = inst[19:15];
    assign rs2    = inst[24:20];

    //imm？？
    assign imm[0]     = inst_type[4]? inst[20] : inst_type[3]? inst[7] : 0;
    assign imm[4:1]   = (inst_type[4] | inst_type[0])? inst[24:21] : 
                        (inst_type[3] | inst_type[2])? inst[11:8] : 4'b0;               
    assign imm[10:5]  = inst_type[1] ? 6'b0 : inst[30:25];
    assign imm[11]    = (inst_type[4] | inst_type[3]) ? inst[31] : inst_type[2] ? inst[7] :
                        inst_type[0] ? inst[20] : 1'b0;
    assign imm[19:12] = (inst_type[1] | inst_type[0]) ? inst[19:12] : {8{inst[31]}};
    assign imm[30:20] = inst_type[1] ? inst[30:20] : {11{inst[31]}};

    assign imm[WIDTH-1:31] = {(WIDTH-31){inst[31]}};

    

    //J_type
    assign inst_type[0] = inst_jal;

    //U_type
    assign inst_type[1] = inst_lui | inst_auipc; 

    //B_type
    assign inst_type[2] = inst_beq | inst_bne | inst_blt | inst_bge | inst_bltu | inst_bgeu; 

    //S_type
    assign inst_type[3] = inst_sb | inst_sh | inst_sw | inst_sd; 

    //I_type
    assign inst_type[4] = inst_jalr 
                    | inst_lb | inst_lh | inst_lw | inst_ld | inst_lbu | inst_lhu
                    | inst_addi | inst_slti | | inst_sltiu | inst_xori | inst_ori | inst_andi
                    | inst_slli | inst_srli | inst_srai 
                    | inst_addiw | inst_slliw | inst_srliw | inst_sraiw; 

    //R_type
    assign inst_type[5] = inst_add | inst_sub | inst_sll | inst_slt | inst_sltu | 
                      inst_xor | inst_srl | inst_sra | inst_or  | inst_and  |
                      inst_addw | inst_subw | inst_sllw | inst_srlw | inst_sraw |
                      inst_mul | inst_div | inst_divu | inst_remu | inst_mulw | inst_divw | inst_remw;

    //指令集

    //J
    wire inst_jal   = (opcode == 7'b1101111);

    //U
    wire inst_lui   = (opcode == 7'b0110111);
    wire inst_auipc = (opcode == 7'b0010111);

    //I
    wire inst_jalr  = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire inst_addi  = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire inst_slti  = (opcode == 7'b0010011) & (func3 == 3'b010);
    wire inst_sltiu = (opcode == 7'b0010011) & (func3 == 3'b011);
    wire inst_xori  = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire inst_ori   = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire inst_andi  = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire inst_slli  = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire inst_srli  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire inst_srai  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);

    wire inst_lb    = (opcode == 7'b0000011) & (func3 == 3'b000);
    wire inst_lh    = (opcode == 7'b0000011) & (func3 == 3'b001);
    wire inst_lw    = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire inst_ld    = (opcode == 7'b0000011) & (func3 == 3'b011);
    wire inst_lbu   = (opcode == 7'b0000011) & (func3 == 3'b100);
    wire inst_lhu   = (opcode == 7'b0000011) & (func3 == 3'b101);

    wire inst_addiw = (opcode == 7'b0011011) & (func3 == 3'b000);
    wire inst_slliw = (opcode == 7'b0011011) & (func3 == 3'b001);
    wire inst_srliw = (opcode == 7'b0011011) & (func3 == 3'b101) & (func7 == 7'b0);
    wire inst_sraiw = (opcode == 7'b0011011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire inst_addw  = (opcode == 7'b0111011) & (func3 == 3'b000) & (func7 == 7'b0);
    wire inst_subw  = (opcode == 7'b0111011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire inst_sllw  = (opcode == 7'b0111011) & (func3 == 3'b001) & (func7 == 7'b0);
    wire inst_srlw  = (opcode == 7'b0111011) & (func3 == 3'b101) & (func7 == 7'b0);
    wire inst_sraw  = (opcode == 7'b0111011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    

    //R
    wire inst_add   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire inst_sub   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire inst_sll   = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire inst_slt   = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire inst_sltu  = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000000);
    wire inst_xor   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire inst_srl   = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire inst_sra   = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire inst_or    = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire inst_and   = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);

    wire inst_mul   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b1);
    wire inst_div   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b1);
    wire inst_divu  = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b1);
    wire inst_remu  = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b1);
    wire inst_mulw  = (opcode == 7'b0111011) & (func3 == 3'b000) & (func7 == 7'b1);
    wire inst_divw  = (opcode == 7'b0111011) & (func3 == 3'b100) & (func7 == 7'b1);
    wire inst_remw  = (opcode == 7'b0111011) & (func3 == 3'b110) & (func7 == 7'b1);

    //B
    wire inst_beq   = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire inst_bne   = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire inst_blt   = (opcode == 7'b1100011) & (func3 == 3'b100);
    wire inst_bge   = (opcode == 7'b1100011) & (func3 == 3'b101);
    wire inst_bltu  = (opcode == 7'b1100011) & (func3 == 3'b110);
    wire inst_bgeu  = (opcode == 7'b1100011) & (func3 == 3'b111);

    //S
    wire inst_sb    = (opcode == 7'b0100011) & (func3 == 3'b000);
    wire inst_sh    = (opcode == 7'b0100011) & (func3 == 3'b001);
    wire inst_sw    = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire inst_sd    = (opcode == 7'b0100011) & (func3 == 3'b011);
    



    assign alu_op[0] = inst_add | inst_addi | inst_auipc | inst_jal | inst_jalr 
                  | inst_lb | inst_lh | inst_lw | inst_ld | inst_lbu | inst_lhu 
                  | inst_type[3] | inst_type[2]
                  | inst_addw | inst_addiw;
    assign alu_op[1] = inst_sub | inst_subw;
    assign alu_op[2] = inst_slti | inst_slt;
    assign alu_op[3] = inst_sltiu | inst_sltu;
    assign alu_op[4] = inst_andi | inst_and;
    assign alu_op[5] = 0;
    assign alu_op[6] = inst_ori | inst_or;
    assign alu_op[7] = inst_xori | inst_xor;
    assign alu_op[8] = inst_slli | inst_sll | inst_sllw | inst_slliw;
    assign alu_op[9] = inst_srli | inst_srl | inst_srliw | inst_srlw;
    assign alu_op[10] = inst_srai | inst_sra | inst_sraiw | inst_sraw;
    assign alu_op[11] = inst_lui;
    assign alu_op[12] = inst_mulw | inst_mul;
    assign alu_op[13] = inst_divw | inst_div;
    assign alu_op[14] = inst_divu;
    assign alu_op[15] = inst_remw;
    assign alu_op[16] = inst_remu;



    assign op1_64 =  (inst_type[5] | inst_type[4] | inst_type[3])? rs1_data : pc;
    assign op2_64 =  inst_type[5]? rs2_data : imm;

    assign op1 = inst_32bit? {32'b0, op1_64[31:0]} : op1_64;
    assign op2 = inst_32bit? {32'b0, op2_64[31:0]} : op2_64;




    
endmodule
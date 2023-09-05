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

wire [6 :0]     opcode;
wire [2 :0]     func3;
wire [6 :0]     func7;
wire [WIDTH-1:0]imm;

wire [WIDTH-1:0]op1_64;
wire [WIDTH-1:0]op2_64;

assign opcode = inst[6 :0 ];
assign rd     = inst[11:7 ];
assign func3  = inst[14:12];
assign func7  = inst[31:25];
assign rs1    = inst[19:15];
assign rs2    = inst[24:20];
assign imm[0]     = inst_type[4]? inst[20] : 
                  inst_type[3]? inst[7] : 0;
assign imm[4:1]   = (inst_type[4] | inst_type[0])? inst[24:21] : 
                  (inst_type[3] | inst_type[2])? inst[11:8] : 4'b0;               
assign imm[10:5]  = inst_type[1] ? 6'b0 : inst[30:25];
assign imm[11]    = (inst_type[4] | inst_type[3]) ? inst[31] :
                  inst_type[2] ? inst[7] :
                  inst_type[0] ? inst[20] : 1'b0;
assign imm[19:12] = (inst_type[1] | inst_type[0]) ? inst[19:12] : {8{inst[31]}};
assign imm[30:20] = inst_type[1] ? inst[30:20] : {11{inst[31]}};
assign imm[WIDTH-1:31] = {(WIDTH-31){inst[31]}};
                    


wire inst_lui   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] &  opcode[2];
wire inst_auipc = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] &  opcode[2];
wire inst_jal   =  opcode[6] &  opcode[5] & !opcode[4] &  opcode[3] &  opcode[2];
wire inst_jalr  =  opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] &  opcode[2];

wire inst_beq   =  opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  & !func3[0];
wire inst_bne   =  opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  &  func3[0];
wire inst_blt   =  opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  & !func3[0];
wire inst_bge   =  opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  &  func3[0];
wire inst_bltu  =  opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  &  func3[1]  & !func3[0];
wire inst_bgeu  =  opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  &  func3[1]  &  func3[0];

wire inst_lb    = !opcode[6] & !opcode[5] & !opcode[4] & !opcode[3] & !opcode[2] & opcode[1] & opcode[0]
                & !func3[2]  & !func3[1]  & !func3[0];
wire inst_lh    = !opcode[6] & !opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  &  func3[0];
wire inst_lw    = !opcode[6] & !opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  & !func3[0];
wire inst_ld    = !opcode[6] & !opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  &  func3[0];
wire inst_lbu   = !opcode[6] & !opcode[5] & !opcode[4] & !opcode[3] & !opcode[2] & opcode[1] & opcode[0] 
                &  func3[2]  & !func3[1]  & !func3[0];
wire inst_lhu   = !opcode[6] & !opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  &  func3[0];
                
wire inst_sb    = !opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  & !func3[0];
wire inst_sh    = !opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  &  func3[0];
wire inst_sw    = !opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  & !func3[0];
wire inst_sd    = !opcode[6] &  opcode[5] & !opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  &  func3[0];
               

wire inst_addi  = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  & !func3[0];
wire inst_slti  = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  & !func3[0];
wire inst_sltiu = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  &  func3[0];
wire inst_xori  = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  & !func3[0];
wire inst_ori   = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  &  func3[1]  & !func3[0];
wire inst_andi  = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  &  func3[1]  &  func3[0];
wire inst_slli  = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  &  func3[0];
wire inst_srli  = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  &  func3[0]  & (func7[6:1] == 6'b0);
wire inst_srai  = !opcode[6] & !opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  &  func3[0]  & (func7[6:1] == 6'b010000);

wire inst_add   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  & !func3[0]  & (func7 == 7'b0);
wire inst_sub   = !opcode[2] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  & !func3[0]  & (func7 == 7'b0100000);
wire inst_sll   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  & !func3[1]  &  func3[0]  & (func7 == 7'b0);
wire inst_slt   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  & !func3[0]  & (func7 == 7'b0);
wire inst_sltu  = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                & !func3[2]  &  func3[1]  &  func3[0]  & (func7 == 7'b0);
wire inst_xor   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  & !func3[0]  & (func7 == 7'b0);
wire inst_srl   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  &  func3[0]  & (func7 == 7'b0);
wire inst_sra   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  & !func3[1]  &  func3[0]  & (func7 == 7'b0100000);
wire inst_or    = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  &  func3[1]  & !func3[0]  & (func7 == 7'b0);
wire inst_and   = !opcode[6] &  opcode[5] &  opcode[4] & !opcode[3] & !opcode[2]
                &  func3[2]  &  func3[1]  &  func3[0]  & (func7 == 7'b0);

wire inst_addiw = (opcode == 7'b0011011) & (func3 == 3'b000);
wire inst_slliw = (opcode == 7'b0011011) & (func3 == 3'b001);
wire inst_srliw = (opcode == 7'b0011011) & (func3 == 3'b101) & (func7 == 7'b0);
wire inst_sraiw = (opcode == 7'b0011011) & (func3 == 3'b101) & (func7 == 7'b0100000);
wire inst_addw  = (opcode == 7'b0111011) & (func3 == 3'b000) & (func7 == 7'b0);
wire inst_subw  = (opcode == 7'b0111011) & (func3 == 3'b000) & (func7 == 7'b0100000);
wire inst_sllw  = (opcode == 7'b0111011) & (func3 == 3'b001) & (func7 == 7'b0);
wire inst_srlw  = (opcode == 7'b0111011) & (func3 == 3'b101) & (func7 == 7'b0);
wire inst_sraw  = (opcode == 7'b0111011) & (func3 == 3'b101) & (func7 == 7'b0100000);

wire inst_mul   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b1);
wire inst_div   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b1);
wire inst_divu  = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b1);
wire inst_remu  = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b1);
wire inst_mulw  = (opcode == 7'b0111011) & (func3 == 3'b000) & (func7 == 7'b1);
wire inst_divw  = (opcode == 7'b0111011) & (func3 == 3'b100) & (func7 == 7'b1);
wire inst_remw  = (opcode == 7'b0111011) & (func3 == 3'b110) & (func7 == 7'b1);

//R-type
assign inst_type[5] = inst_add | inst_sub | inst_sll | inst_slt | inst_sltu | 
                      inst_xor | inst_srl | inst_sra | inst_or  | inst_and  |
                      inst_addw | inst_subw | inst_sllw | inst_srlw | inst_sraw |
                      inst_mul | inst_div | inst_divu | inst_remu | inst_mulw | inst_divw | inst_remw;
//I-type
assign inst_type[4] = inst_jalr 
                    | inst_lb | inst_lh | inst_lw | inst_ld | inst_lbu | inst_lhu
                    | inst_addi | inst_slti | | inst_sltiu | inst_xori | inst_ori | inst_andi
                    | inst_slli | inst_srli | inst_srai 
                    | inst_addiw | inst_slliw | inst_srliw | inst_sraiw; 
//S-type
assign inst_type[3] = inst_sb | inst_sh | inst_sw | inst_sd; 
//B-type
assign inst_type[2] = inst_beq | inst_bne | inst_blt | inst_bge | inst_bltu | inst_bgeu; 
//U-type
assign inst_type[1] = inst_lui | inst_auipc; 
//J-type
assign inst_type[0] = inst_jal; 

//ld/st
assign ld_type = {inst_lb, inst_lh, inst_lw, inst_ld, inst_lbu, inst_lhu};
assign st_type = {inst_sb, inst_sh, inst_sw, inst_sd};

//32bit inst
assign inst_32bit = | inst_addiw | inst_slliw | inst_srliw | inst_sraiw 
                    | inst_addw | inst_subw | inst_sllw | inst_srlw | inst_sraw 
                    | inst_mulw | inst_divw | inst_remw;

wire rj_eq_rd = (rs1_data == rs2_data);
wire rj_lt_rd = ($signed(rs1_data) < $signed(rs2_data));
wire rj_ltu_rd = (rs1_data < rs2_data);
assign br_taken  = inst_beq  &&  rj_eq_rd
                || inst_bne  && !rj_eq_rd
                || inst_blt  &&  rj_lt_rd
                || inst_bge  && !rj_lt_rd
                || inst_bltu &&  rj_ltu_rd
                || inst_bgeu && !rj_ltu_rd
                || inst_jal || inst_jalr;


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

assign rd_wen   = inst_type[5] | inst_type[4] | inst_type[1] | inst_type[0];

assign op1_64 =  (inst_type[5] | inst_type[4] | inst_type[3])? rs1_data : pc;
assign op2_64 =  inst_type[5]? rs2_data : imm;

assign op1 = inst_32bit? {32'b0, op1_64[31:0]} : op1_64;
assign op2 = inst_32bit? {32'b0, op2_64[31:0]} : op2_64;

endmodule
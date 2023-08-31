module alu #(WIDTH = 64)(
  input  wire        inst_32bit,
  input  wire [16:0] alu_op,
  input  wire [WIDTH-1:0] alu_src1,
  input  wire [WIDTH-1:0] alu_src2,
  output wire [WIDTH-1:0] alu_result
);

    wire op_add;   //add operation
    wire op_sub;   //sub operation
    wire op_slt;   //signed compared and set less than
    wire op_sltu;  //unsigned compared and set less than
    wire op_and;   //bitwise and
    wire op_nor;   //bitwise nor
    wire op_or;    //bitwise or
    wire op_xor;   //bitwise xor
    wire op_sll;   //logic left shift
    wire op_srl;   //logic right shift
    wire op_sra;   //arithmetic right shift
    wire op_lui;   //Load Upper Immediate
    wire op_mul;   
    wire op_div;   
    wire op_divu;   
    wire op_rem;   
    wire op_remu;   

    // control code decomposition
    assign op_add  = alu_op[ 0];
    assign op_sub  = alu_op[ 1];
    assign op_slt  = alu_op[ 2];
    assign op_sltu = alu_op[ 3];
    assign op_and  = alu_op[ 4];
    assign op_nor  = alu_op[ 5];
    assign op_or   = alu_op[ 6];
    assign op_xor  = alu_op[ 7];
    assign op_sll  = alu_op[ 8];
    assign op_srl  = alu_op[ 9];
    assign op_sra  = alu_op[10];
    assign op_lui  = alu_op[11];
    assign op_mul  = alu_op[12];
    assign op_div  = alu_op[13];
    assign op_divu = alu_op[14];
    assign op_rem  = alu_op[15];
    assign op_remu = alu_op[16];


    wire [WIDTH-1:0] add_sub_result;
    wire [WIDTH-1:0] slt_result;
    wire [WIDTH-1:0] sltu_result;
    wire [WIDTH-1:0] and_result;
    wire [WIDTH-1:0] nor_result;
    wire [WIDTH-1:0] or_result;
    wire [WIDTH-1:0] xor_result;
    wire [WIDTH-1:0] lui_result;
    wire [WIDTH-1:0] sll_result;
    wire [WIDTH*2-1:0] sr_extend;
    wire [WIDTH-1:0] sr_result;
    wire [WIDTH-1:0] mul_result;
    wire [WIDTH-1:0] div_result;
    wire [WIDTH-1:0] divu_result;
    wire [WIDTH-1:0] rem_result;
    wire [WIDTH-1:0] remu_result;


    //adder
    wire [WIDTH-1:0] adder_a;
    wire [WIDTH-1:0] adder_b;
    wire [WIDTH-1:0] adder_cin; // warning-WIDTH
    wire [WIDTH-1:0] adder_result;
    wire             adder_cout;

    assign adder_a   = alu_src1;
    assign adder_b   = (op_sub | op_slt | op_sltu) ? ~alu_src2 : alu_src2;  //src1 - src2 rj-rk
    assign adder_cin = (op_sub | op_slt | op_sltu) ? 1 : 0;
    assign {adder_cout, adder_result} = adder_a + adder_b + adder_cin;

    // ADD, SUB result
    assign add_sub_result = adder_result;

    // SLT result
    assign slt_result[WIDTH-1:1] = 0;   
    assign slt_result[0]    = (alu_src1[WIDTH-1] & !alu_src2[WIDTH-1])
                            | ((alu_src1[WIDTH-1] ~^ alu_src2[WIDTH-1]) & adder_result[WIDTH-1]);

    // SLTU result
    assign sltu_result[WIDTH-1:1] = 0;
    assign sltu_result[0]    = ~adder_cout;

    // bitwise operation
    assign and_result = alu_src1 & alu_src2;
    assign or_result  = alu_src1 | alu_src2;
    assign nor_result = ~or_result;
    assign xor_result = alu_src1 ^ alu_src2;
    assign lui_result = alu_src2;

    // SLL result
    assign sll_result = alu_src1 << alu_src2[$clog2(WIDTH)-1:0]; 

    // SRL, SRA result

    assign sr_extend  = inst_32bit? {{96{op_sra & alu_src1[31]}}, alu_src1[31:0]} >> alu_src2[4:0] :
                                    {{64{op_sra & alu_src1[63]}}, alu_src1[63:0]} >> alu_src2[5:0] ;

    assign sr_result  = sr_extend[WIDTH-1:0]; 

    //mul/div
    assign mul_result = alu_src1 * alu_src2;
    assign div_result = $signed(alu_src1 / alu_src2);
    assign divu_result = alu_src1 / alu_src2;
    assign rem_result = $signed(alu_src1 % alu_src2);
    assign remu_result = alu_src1 % alu_src2;

    // final result mux
    assign alu_result   = ({WIDTH{op_add|op_sub}} & add_sub_result)
                        | ({WIDTH{op_slt       }} & slt_result)
                        | ({WIDTH{op_sltu      }} & sltu_result)
                        | ({WIDTH{op_and       }} & and_result)
                        | ({WIDTH{op_nor       }} & nor_result)
                        | ({WIDTH{op_or        }} & or_result)
                        | ({WIDTH{op_xor       }} & xor_result)
                        | ({WIDTH{op_lui       }} & lui_result)
                        | ({WIDTH{op_sll       }} & sll_result)
                        | ({WIDTH{op_srl|op_sra}} & sr_result)
                        | ({WIDTH{op_mul       }} & mul_result)
                        | ({WIDTH{op_div       }} & div_result)
                        | ({WIDTH{op_divu      }} & divu_result)
                        | ({WIDTH{op_rem       }} & rem_result)
                        | ({WIDTH{op_remu      }} & remu_result);

endmodule

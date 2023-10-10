module alu #(WIDTH = 64)(
  input  wire clk,
  input  wire rst,
  input  wire inst_32bit,
  input  wire [16:0] alu_op,
  input  wire [WIDTH-1:0] alu_src1,
  input  wire [WIDTH-1:0] alu_src2,
  output wire [WIDTH-1:0] alu_result,
  input  wire alu_busy,
  output wire alu_out_valid,
  input  wire alu_flush
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
assign slt_result[WIDTH-1:1] = 0;   //rj < rk 1
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

//multiplier 
wire mulh = 0;
reg  mul_valid;
wire mul_ready;
wire mul_flush = alu_flush;
wire [1:0] mul_signed = 2'b0;
wire mul_out_valid;
wire [63:0] mul_result_hi;
wire [63:0] mul_result_lo;

assign mul_result = mulh? mul_result_hi : mul_result_lo;

always @(posedge clk) begin
  if(rst)
    mul_valid <= 0;
  else if(mul_valid == 1)
    mul_valid <= 0;
  else if(op_mul && alu_busy && mul_ready)
    mul_valid <= 1;
end

multiplier multiplier(
  .clk(clk),	
  .rst(rst),	

  .mul_valid(mul_valid),
  .flush(mul_flush),	
  .mulw(inst_32bit),	
  .mul_signed(mul_signed),	
  .multiplicand(alu_src1),	
  .multiplier(alu_src2),	   
  .mul_ready(mul_ready),
  .out_valid(mul_out_valid),
  .result_hi(mul_result_hi),
  .result_lo(mul_result_lo)
);

//divisioner
reg  div_valid;
wire div_ready;
wire div_flush = alu_flush;
wire div_signed = op_div || op_rem;
wire div_out_valid;
wire [63:0] quotient;
wire [63:0] remainder;

always @(posedge clk) begin
  if(rst)
    div_valid <= 0;
  else if(div_valid == 1)
    div_valid <= 0;
  else if((op_div || op_divu || op_rem || op_remu) && alu_busy && div_ready)
    div_valid <= 1;
end

divisioner divisioner(
  .clk(clk),	
  .rst(rst),	

  .div_valid(div_valid),
  .flush(div_flush),	
  .divw(inst_32bit),	
  .div_signed(div_signed),	
  .dividend(alu_src1),	
  .divisor(alu_src2),	   
  .div_ready(div_ready),
  .out_valid(div_out_valid),
  .quotient(quotient),
  .remainder(remainder)
);

assign alu_out_valid = div_out_valid || mul_out_valid;

// final result mux
assign alu_result = ({WIDTH{op_add|op_sub}} & add_sub_result)
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
                  | ({WIDTH{op_div|op_divu}} & quotient)
                  | ({WIDTH{op_rem|op_remu}} & remainder);

endmodule

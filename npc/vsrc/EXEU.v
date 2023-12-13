module EXEU #(WIDTH = 64)(
  input wire rst,
  input wire inst_32bit,
  input wire [16: 0]alu_op,
  input wire [WIDTH-1:0]op1,
  input wire [WIDTH-1:0]op2,
  
  output wire [WIDTH-1:0]exe_result
);
  alu #(WIDTH) alu(inst_32bit, alu_op, op1, op2, exe_result);

  
endmodule
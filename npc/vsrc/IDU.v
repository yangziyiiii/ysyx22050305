module IDU #(WIDTH=64) (
    input clk,
    input rst,

    input wire [63:0] if_pc_i,
    input wire [31:0] if_inst_i,
    input wire [63:0] rs1_data,
    input wire [63:0] rs2_data,

    output wire [16:0] alu_op,
    output wire [63:0] op1,
    output wire [63:0] op2,

    output wire          br_taken,
    output wire [63:0]   br_target,
    output wire [6 :0]   ld_type,
    output wire [3 :0]   st_type,
    output wire          inst_32bit,
    

);




endmodule
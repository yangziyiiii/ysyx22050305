`define PC_ENTRY  64'h80000000   

module IFU #(WIDTH = 64)(
    input wire clk,
    input wire rst,
    
    input wire  br_taken,
    input wire  [WIDTH-1:0] br_target,

    input wire  ex,
    input wire  [WIDTH-1:0] ex_entry,
    input wire  ex_ret,
    input wire  [WIDTH-1:0] epc,

    output wire [WIDTH-1:0] nextpc,
    output reg  [WIDTH-1:0] pc
);
    always @(posedge clk) begin
        if(rst)
            pc <= `PC_ENTRY;
        else
            pc <= nextpc;
    end
    //Reg #(WIDTH, `PC_ENTRY-4) pc_r (clk, rst, nextpc, pc, 1'b1);
    assign nextpc = ex? ex_entry :
                    ex_ret? epc :
                    br_taken? br_target : 
                    pc + 4;

endmodule
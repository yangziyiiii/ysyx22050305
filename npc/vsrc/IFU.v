`define PC_ENTRY  64'h80000000   

module IFU #(WIDTH = 64)(
    input wire clk,
    input wire rst,
    
    input wire         br_taken,
    input wire  [63:0] br_target,

    input wire         ex,   //exception
    input wire  [63:0] ex_entry,
    input wire         ex_ret,
    input wire  [63:0] epc,

    output wire [63:0] nextpc,
    output reg  [63:0] pc
);
    always @(posedge clk) begin
        if(rst)
            pc <= `PC_ENTRY;
        else
            pc <= nextpc;
    end

    //异常发生的时候pc跳转到异常处理的起始地址，当从异常返回 (ex_ret 为真) 时，
    //PC会设置为异常发生时的地址，从而恢复正常的程序执行流程
    assign nextpc = ex? ex_entry :
                    ex_ret? epc :
                    br_taken? br_target : 
                    pc + 4;

endmodule

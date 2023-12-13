`define PC_ENTRY 64'h80000000

module IFU(
    input wire clk,
    input wire rst,

    //分支跳转
    input wire br_taken,
    input wire [63:0] br_target,

    //异常处理
    input wire ex,  //exception
    input wire ex_ret,  //exception return
    input wire [63:0] epc,  //exception pc
    input wire [63:0] ex_entry, //exception entry

    output wire [63:0] next_pc,
    
    //if_id_reg
    output reg [63:0] pc
);

    always @(posedge clk) begin
        if (rst)
            pc <= `PC_ENTRY - 4;
        else
            pc <= next_pc;
    end

    assign nextpc = ex? ex_entry :
                    ex_ret? epc :
                    br_taken? br_target : 
                    pc + 4;


endmodule
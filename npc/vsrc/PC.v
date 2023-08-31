`define PC_ENTRY 64'h80000000

module PC(
    input clk,//CPU时钟
    input rstn,//reset信号              
    input [31:0] nextPc,//下一条指令的地址
    output reg [31:0] nowPc//目前指令的地址
);
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            nowPc <= PC_ENTRY;
        end
        else begin
            nowPc <= nextPc;
        end
    end
    
endmodule


import "DPI-C" function void set_gpr_ptr(input logic [63:0] a []);

module RegFile #(ADDR_WIDTH = 5, DATA_WIDTH = 64) (
  input  clk,
  input  wire [DATA_WIDTH-1:0] wdata,
  input  wire [ADDR_WIDTH-1:0] waddr,
  input  wire wen,
  input  wire [ADDR_WIDTH-1:0] raddr1,
  input  wire [ADDR_WIDTH-1:0] raddr2,
  output [DATA_WIDTH-1:0] rdata1,
  output [DATA_WIDTH-1:0] rdata2
);
  reg [DATA_WIDTH-1:0] rf [31:0];  // 通用寄存器文件，每个寄存器有 DATA_WIDTH 位
  initial set_gpr_ptr(rf);  // rf为通用寄存器的二维数组变量

  always @(posedge clk) begin
    if (wen && waddr != 0) rf[waddr] <= wdata;  // 如果写使能打开且写地址不为0,将写数据写入对应的寄存器位置
  end
  assign rdata1 = (raddr1 == 0)? 0 : rf[raddr1];
  assign rdata2 = (raddr2 == 0)? 0 : rf[raddr2];
endmodule

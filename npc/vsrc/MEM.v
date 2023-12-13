import "DPI-C" function void pmem_read(
    input longint raddr, output longint rdata,input byte ren);
import "DPI-C" function void pmem_write(
    input longint waddr, input longint wdata, input byte wmask);

/* verilator lint_off UNUSED */
/* verilator lint_off LATCH */
module MEM(
    input clk,

    input wire [63:0] raddr,
    output wire [63:0] rdata, 

    input wire [6:0] ld_type,
    input wire [3:0] st_type,
    input wire [63:0] waddr,
    input wire [63:0] wdata,
    input wire [7:0] wmask,
    input wire Write_en,
    input wire Read_en
);

    always@(*) begin
        if(Read_en) pmem_read(raddr,rdata);
        else rdata = 64'b0;
        if(Write_en) pmem_write(waddr,wdata,wmask);
        else pmem_write(waddr,wdata,0);
    end
endmodule
/* verilator lint_on LATCH */
/* verilator lint_on UNUSED */
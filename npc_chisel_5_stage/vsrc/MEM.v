import "DPI-C" function void pmem_read(
  input longint Raddr, output longint Rdata);
import "DPI-C" function void pmem_write(
  input longint Waddr, input longint Wdata, input byte Wmask);

/* verilator lint_off UNUSED */
/* verilator lint_off LATCH */
module MEM (
    input [63:0] Raddr,
    input [63:0] Waddr,
    input [63:0] Wdata,
    input [7:0] Wmask,
    input Write_en,
    input Read_en,
    output [63:0] Rdata
);
 
 always@(*) begin
    if(Read_en)begin
      pmem_read(Raddr, Rdata);
    end
    if(Write_en)begin
      pmem_write(Waddr, Wdata, Wmask);
    end
end
  
endmodule
/* verilator lint_on LATCH */
/* verilator lint_on UNUSED */


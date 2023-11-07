
module Memory(
    input wire  clk,
    input wire  [63:0] raddr,
    input wire  [ 6:0] ld_type,
    output wire [63:0] rdata,

    input wire [ 3:0] st_type,
    input wire [63:0] waddr,
    input wire [63:0] wdata
);
    import "DPI-C" function void pmem_read(
      input longint raddr, output longint rdata,input byte ren);
    import "DPI-C" function void pmem_write(
      input longint waddr, input longint wdata, input byte wmask);
    
    wire [ 7:0] ren = {8{ld_type != 0}} ;
    wire [63:0] pmem_rdata;
    wire [ 7:0] rmask;

    wire [ 2:0] offset;
    wire [ 7:0] wmask;

    assign offset = waddr[2:0];
    assign wmask =  {8{st_type[3]}} & (8'b1   << offset) |
                    {8{st_type[2]}} & (8'b11  << offset) |
                    {8{st_type[1]}} & (8'b1111<< offset) |
                    {8{st_type[0]}} & (8'b11111111) ;

    always @(*) begin
      pmem_read(raddr, pmem_rdata, ren);
      pmem_write(waddr, wdata, wmask);
    end

    decoder_3_8 dec1 (raddr[2:0], rmask);
    wire [7 :0] lb_data = {8{rmask[7]}} & pmem_rdata[63:56] |
                          {8{rmask[6]}} & pmem_rdata[55:48] |
                          {8{rmask[5]}} & pmem_rdata[47:40] |
                          {8{rmask[4]}} & pmem_rdata[39:32] |
                          {8{rmask[3]}} & pmem_rdata[31:24] |
                          {8{rmask[2]}} & pmem_rdata[23:16] |
                          {8{rmask[1]}} & pmem_rdata[15: 8] |
                          {8{rmask[0]}} & pmem_rdata[7 : 0] ;
    wire [15:0] lh_data = {16{rmask[6]}} & pmem_rdata[63:48] |
                          {16{rmask[4]}} & pmem_rdata[47:32] |
                          {16{rmask[2]}} & pmem_rdata[31:16] |
                          {16{rmask[0]}} & pmem_rdata[15: 0] ;
    wire [31:0] lw_data = {32{rmask[4]}} & pmem_rdata[63:32] |
                          {32{rmask[0]}} & pmem_rdata[31: 0] ;
    assign rdata =  {64{ld_type[6]}} & {{56{lb_data[ 7]}}, lb_data} |
                    {64{ld_type[5]}} & {{48{lh_data[15]}}, lh_data} |
                    {64{ld_type[4]}} & {{32{lw_data[31]}}, lw_data} |
                    {64{ld_type[3]}} & pmem_rdata                   |
                    {64{ld_type[2]}} & {56'b0, lb_data}             |
                    {64{ld_type[1]}} & {48'b0, lh_data}             |
                    {64{ld_type[0]}} & {32'b0, lw_data}             ;
                          
endmodule

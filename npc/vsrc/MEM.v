// import "DPI-C" function void pmem_read(
//     input longint raddr, output longint rdata,input byte ren);
// import "DPI-C" function void pmem_write(
//     input longint waddr, input longint wdata, input byte wmask);


module MEM(
    input  wire clk,
    input  wire rst,
    input  wire [63:0] addr,
    input  wire [ 6:0] ld_type,
    output wire [63:0] rdata,

    input  wire [ 3:0] st_type,
    input  wire [63:0] wdata,
    output wire mem_valid
);

    wire [7:0] rmask;
    wire [2:0] offset;
    wire [7:0] wmask;

    assign offset = addr[2:0];
    assign wmask =  {8{st_type[3]}} & (8'b1   << offset) |
                    {8{st_type[2]}} & (8'b11  << offset) |
                    {8{st_type[1]}} & (8'b1111<< offset) |
                    {8{st_type[0]}} & (8'b11111111) ;


    decoder_3_8 dec1 (offset, rmask);
    wire [7 :0] lb_data = {8{rmask[7]}} & d_rdata[63:56] |
                          {8{rmask[6]}} & d_rdata[55:48] |
                          {8{rmask[5]}} & d_rdata[47:40] |
                          {8{rmask[4]}} & d_rdata[39:32] |
                          {8{rmask[3]}} & d_rdata[31:24] |
                          {8{rmask[2]}} & d_rdata[23:16] |
                          {8{rmask[1]}} & d_rdata[15: 8] |
                          {8{rmask[0]}} & d_rdata[7 : 0] ;
    wire [15:0] lh_data = {16{rmask[6]}} & d_rdata[63:48] |
                          {16{rmask[4]}} & d_rdata[47:32] |
                          {16{rmask[2]}} & d_rdata[31:16] |
                          {16{rmask[0]}} & d_rdata[15: 0] ;
    wire [31:0] lw_data = {32{rmask[4]}} & d_rdata[63:32] |
                          {32{rmask[0]}} & d_rdata[31: 0] ;
    assign rdata =  {64{ld_type[6]}} & {{56{lb_data[ 7]}}, lb_data} |
                    {64{ld_type[5]}} & {{48{lh_data[15]}}, lh_data} |
                    {64{ld_type[4]}} & {{32{lw_data[31]}}, lw_data} |
                    {64{ld_type[3]}} & d_rdata                      |
                    {64{ld_type[2]}} & {56'b0, lb_data}             |
                    {64{ld_type[1]}} & {48'b0, lh_data}             |
                    {64{ld_type[0]}} & {32'b0, lw_data}             ;
    
    assign mem_valid = (ld_type == 0 && st_type == 0)? 1 : d_bvalid;

    //dcache
    wire [31:0] d_addr = addr[31:0];
    wire        d_avalid = (ld_type != 0) || (st_type != 0);
    wire        d_aready;
    wire [63:0] d_rdata;
    wire [63:0] d_wdata = wdata;
    wire [ 7:0] d_wstrb = wmask;
    wire        d_bvalid;
    wire        d_bready = 1;

    cache dcache(
        .clk(clk),
        .rst(rst), 
        .addr(d_addr),
        .avalid(d_avalid),
        .aready(d_aready),
        .rdata(d_rdata),
        .wdata(d_wdata),
        .wstrb(d_wstrb),
        .bvalid(d_bvalid),
        .bready(d_bready)
    );                      
endmodule
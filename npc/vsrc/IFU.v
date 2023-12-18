`define PC_ENTRY  64'h80000000   

module IFU #(WIDTH = 64)(
    input wire clk,
    input wire rst,
    
    //input wire  recv_inst,
    input wire  br_taken,
    input wire  [63:0] br_target,

    input wire  ex,
    input wire  [63:0] ex_entry,
    input wire  ex_ret,
    input wire  [63:0] epc,

    output wire [63:0] nextpc,
    output reg  [63:0] pc,
    output reg  [31:0] inst,
    output reg  if_valid,
    input  wire mem_valid,
    input  wire debug_valid
);
    always @(posedge clk) begin
        if(rst)
            pc <= `PC_ENTRY-4;
        else if(debug_valid)
            pc <= nextpc;
    end
    //Reg #(WIDTH, `PC_ENTRY-4) pc_r (clk, rst, nextpc, pc, 1'b1);
    assign nextpc = ex? ex_entry :
                    ex_ret? epc :
                    br_taken? br_target : 
                    pc + 4;
    
    always @(posedge clk) begin
        if(debug_valid)
            inst <= nextpc[2]? i_rdata[63:32] : i_rdata[31:0];
    end

    always @(posedge clk) begin
        if(rst)
            if_valid <= 0;
        else if(i_bvalid)
            if_valid <= 1;
        else if(debug_valid)
            if_valid <= 0;
    end

    //icache
    wire [31:0] i_addr = nextpc[31:0];
    wire        i_avalid = mem_valid;
    wire        i_aready;
    wire [63:0] i_rdata;
    wire [63:0] i_wdata = 64'b0;
    wire [ 7:0] i_wstrb = 8'b0;
    wire        i_bvalid;
    wire        i_bready = 1;

    cache icache(
        .clk(clk),
        .rst(rst), 

        .addr(i_addr),
        .avalid(i_avalid),
        .aready(i_aready),
        //read data
        .rdata(i_rdata),
        //write data
        .wdata(i_wdata),
        .wstrb(i_wstrb),
        //response
        .bvalid(i_bvalid),
        .bready(i_bready)
    );
endmodule
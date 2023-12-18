//state of cache
`define CACHE_INIT          9'b000000001
`define CACHE_RES_ADDR      9'b000000010
`define CACHE_READ_HIT      9'b000000100
`define CACHE_READ_MISS     9'b000001000
`define CACHE_WRITE_HIT     9'b000010000
`define CACHE_WRITE_MISS    9'b000100000
`define CACHE_WAIT          9'b001000000
`define CACHE_RELOAD        9'b010000000
`define CACHE_DEVICE        9'b100000000
module cache (
    input  wire        clk,
    input  wire        rst, 

    input  wire [31:0] addr,
    input  wire        avalid,
    output wire        aready,

    //read data
    output wire [63:0] rdata,

    //write data
    input  wire [63:0] wdata,
    input  wire [ 7:0] wstrb,

    //response
    output wire        bvalid ,
    input  wire        bready
);
    `define BLOCK_WIDTH     5'd7
    `define BLOCK_SIZE      8'd128
    `define OFFSET_WIDTH    5'd7
    `define INDEX_WIDTH     5'd4
    `define TAG_WIDTH       (32-`OFFSET_WIDTH-`INDEX_WIDTH)
    `define TAG_BMASK       31 : `OFFSET_WIDTH+`INDEX_WIDTH
    `define INDEX_BMASK     `OFFSET_WIDTH+`INDEX_WIDTH-1 : `OFFSET_WIDTH
    `define OFFSET_BMASK    `OFFSET_WIDTH-1 : 0

    reg [15:0] cache_valid_way0;
    reg [15:0] cache_valid_way1;
    reg [15:0] cache_valid_way2;
    reg [15:0] cache_valid_way3;
    reg [15:0] cache_dirty_way0;
    reg [15:0] cache_dirty_way1;
    reg [15:0] cache_dirty_way2;
    reg [15:0] cache_dirty_way3;
    reg [`TAG_WIDTH-1:0] cache_tag_way0  [15:0];
    reg [`TAG_WIDTH-1:0] cache_tag_way1  [15:0];
    reg [`TAG_WIDTH-1:0] cache_tag_way2  [15:0];
    reg [`TAG_WIDTH-1:0] cache_tag_way3  [15:0];
    

    wire [`OFFSET_WIDTH-1:0] offset = addr[`OFFSET_BMASK];
    wire [`INDEX_WIDTH-1 :0] index  = addr[`INDEX_BMASK];   
    wire [`TAG_WIDTH-1   :0] tag    = addr[`TAG_BMASK];
    wire [`OFFSET_WIDTH-5:0] block  = offset[`OFFSET_WIDTH-1:4];
    wire [`OFFSET_WIDTH-4:0] word   = offset[`OFFSET_WIDTH-1:3];

    wire wen = (wstrb != 0);

    wire way0_hit = cache_valid_way0[index] && (cache_tag_way0[index] == tag);
    wire way1_hit = cache_valid_way1[index] && (cache_tag_way1[index] == tag);
    wire way2_hit = cache_valid_way2[index] && (cache_tag_way2[index] == tag);
    wire way3_hit = cache_valid_way3[index] && (cache_tag_way3[index] == tag);
    wire cache_hit = way0_hit | way1_hit | way2_hit | way3_hit;

    //8 data_ram
    wire [127:0] rdata_block0;
    wire [127:0] rdata_block1;
    wire [127:0] rdata_block2;
    wire [127:0] rdata_block3;
    wire [127:0] rdata_block4;
    wire [127:0] rdata_block5;
    wire [127:0] rdata_block6;
    wire [127:0] rdata_block7;
    wire         cen;
    wire         wen_block0;
    wire         wen_block1;
    wire         wen_block2;
    wire         wen_block3;
    wire         wen_block4;
    wire         wen_block5;
    wire         wen_block6;
    wire         wen_block7;
    wire [127:0] bwen;
    wire [  5:0] addr_block;
    wire [127:0] wdata_block;

    wire reloadfinish;
    wire writebackfinish;
    wire is_dirty;
    wire is_reload;
    wire is_write;
    wire is_device_addr;

    reg  [1:0] FIFO [15:0];
    wire [1:0] replace_way;
    wire [1:0] cache_way;

    //state machine
    reg [8:0] cache_state;
    reg [8:0] cache_nstate;

    always @(posedge clk)begin
        if(rst) 
            cache_state <= `CACHE_INIT;
        else
            cache_state <= cache_nstate;
    end 
/* verilator lint_off COMBDLY */
    always @(*) begin
        case(cache_state)
        `CACHE_INIT:
            if(avalid)
                cache_nstate = `CACHE_RES_ADDR;
        `CACHE_RES_ADDR:
            if(is_device_addr)
                cache_nstate <= `CACHE_DEVICE;
            else if(!wen && cache_hit)
                cache_nstate = `CACHE_READ_HIT;
            else if(!wen && !cache_hit)
                cache_nstate = `CACHE_READ_MISS;
            else if(cache_hit)
                cache_nstate = `CACHE_WRITE_HIT;
            else if(!cache_hit)
                cache_nstate = `CACHE_WRITE_MISS;
        `CACHE_READ_HIT:
            cache_nstate = `CACHE_INIT;
        `CACHE_READ_MISS:
            if(is_dirty)
                cache_nstate = `CACHE_WAIT;
            else
                cache_nstate = `CACHE_RELOAD;
        `CACHE_WRITE_HIT:
            cache_nstate = `CACHE_INIT;
        `CACHE_WRITE_MISS:
            if(is_dirty)
                cache_nstate = `CACHE_WAIT;
            else
                cache_nstate = `CACHE_RELOAD;
        `CACHE_WAIT:
            if(writebackfinish)
                cache_nstate = `CACHE_RELOAD;
        `CACHE_RELOAD:
            if(reloadfinish)
                cache_nstate = `CACHE_RES_ADDR;
        `CACHE_DEVICE:
            if(((wen) && sram_bvalid) || ((!wen) && rvalid))
                cache_nstate = `CACHE_INIT;
        default: 
            cache_nstate = `CACHE_INIT;
        endcase
    end

    assign is_dirty  = (replace_way == 2'b00) & cache_dirty_way0[index] |
                       (replace_way == 2'b01) & cache_dirty_way1[index] |
                       (replace_way == 2'b10) & cache_dirty_way2[index] |
                       (replace_way == 2'b11) & cache_dirty_way3[index] ;

    assign is_reload = (cache_state == `CACHE_RELOAD);
    assign is_write  = (cache_state == `CACHE_WRITE_HIT);

    assign is_device_addr = (addr >= 32'ha0000000);

    //wire debug_addr = (addr == 32'h83061818);

    assign writebackfinish = wvalid && wlast;
    assign reloadfinish = rvalid && rlast;

    assign aready = (cache_state == `CACHE_INIT);
    assign bvalid = (cache_state ==`CACHE_READ_HIT) || (cache_state ==`CACHE_WRITE_HIT) 
                 || (cache_state ==`CACHE_DEVICE && cache_nstate == `CACHE_INIT);
    assign rdata  = (cache_state == `CACHE_DEVICE)? sram_rdata :
                    {64{block == 0}} & rdata_block0[64*word[0] +: 64] |
                    {64{block == 1}} & rdata_block1[64*word[0] +: 64] |
                    {64{block == 2}} & rdata_block2[64*word[0] +: 64] |
                    {64{block == 3}} & rdata_block3[64*word[0] +: 64] |
                    {64{block == 4}} & rdata_block4[64*word[0] +: 64] |
                    {64{block == 5}} & rdata_block5[64*word[0] +: 64] |
                    {64{block == 6}} & rdata_block6[64*word[0] +: 64] |
                    {64{block == 7}} & rdata_block7[64*word[0] +: 64] ;
    
    //FIFO replace
    assign replace_way = FIFO[index];
    always @(posedge clk) begin
        if(rst) begin
            FIFO[0] <= 2'b0;
            FIFO[1] <= 2'b0;
            FIFO[2] <= 2'b0;
            FIFO[3] <= 2'b0;
            FIFO[4] <= 2'b0;
            FIFO[5] <= 2'b0;
            FIFO[6] <= 2'b0;
            FIFO[7] <= 2'b0;
            FIFO[8] <= 2'b0;
            FIFO[9] <= 2'b0;
            FIFO[10] <= 2'b0;
            FIFO[11] <= 2'b0;
            FIFO[12] <= 2'b0;
            FIFO[13] <= 2'b0;
            FIFO[14] <= 2'b0;
            FIFO[15] <= 2'b0;
        end
        else if(cache_state == `CACHE_RES_ADDR && !cache_hit)
            FIFO[index] <= FIFO[index] + 1;
    end

    assign cache_way =  way0_hit ? 2'b0:
                        way1_hit ? 2'b1:
                        way2_hit ? 2'b10:
                        way3_hit ? 2'b11:
                        replace_way;

    
    always @(posedge clk)begin
        if(rst) begin
            cache_valid_way0 <= 16'b0;
            cache_valid_way1 <= 16'b0;
            cache_valid_way2 <= 16'b0;
            cache_valid_way3 <= 16'b0;
        end
        else if(is_reload && replace_way == 0) begin
            cache_valid_way0[index] <= 1'b1;
        end
        else if(is_reload && replace_way == 1) begin
            cache_valid_way1[index] <= 1'b1;
        end
        else if(is_reload && replace_way == 2) begin
            cache_valid_way2[index] <= 1'b1;
        end
        else if(is_reload && replace_way == 3) begin
            cache_valid_way3[index] <= 1'b1;
        end
    end 
    

    always @(posedge clk)begin
        if(rst) begin
            cache_dirty_way0 <= 16'b0;
        end
        else if(way0_hit && is_write) begin
            cache_dirty_way0[index] <= 1'b1;
        end
        else if(cache_state == `CACHE_WAIT && replace_way == 0) begin
            cache_dirty_way0[index] <= 1'b0;
        end
    end 
    always @(posedge clk)begin
        if(rst) begin
            cache_dirty_way1 <= 16'b0;
        end
        else if(way1_hit && is_write) begin
            cache_dirty_way1[index] <= 1'b1;
        end
        else if(cache_state == `CACHE_WAIT && replace_way == 1) begin
            cache_dirty_way1[index] <= 1'b0;
        end
    end 
    always @(posedge clk)begin
        if(rst) begin
            cache_dirty_way2 <= 16'b0;
        end
        else if(way2_hit && is_write) begin
            cache_dirty_way2[index] <= 1'b1;
        end
        else if(cache_state == `CACHE_WAIT && replace_way == 2) begin
            cache_dirty_way2[index] <= 1'b0;
        end
    end 
    always @(posedge clk)begin
        if(rst) begin
            cache_dirty_way3 <= 16'b0;
        end
        else if(way3_hit && is_write) begin
            cache_dirty_way3[index] <= 1'b1;
        end
        else if(cache_state == `CACHE_WAIT && replace_way == 3) begin
            cache_dirty_way3[index] <= 1'b0;
        end
    end 

    always @(posedge clk)begin
        if(is_reload && replace_way == 0)begin
            cache_tag_way0[index] <= tag;
        end
        else if(is_reload && replace_way == 1)begin
            cache_tag_way1[index] <= tag;
        end
        else if(is_reload && replace_way == 2)begin
            cache_tag_way2[index] <= tag;
        end
        else if(is_reload && replace_way == 3)begin
            cache_tag_way3[index] <= tag;
        end
    end 

    reg [3:0] rcnt;
    always @(posedge clk) begin
        if(rst)
            rcnt <= 0;
        else if(rcnt == 4'b1111 || cache_state == `CACHE_INIT)
            rcnt <= 0;
        else if(cache_state == `CACHE_RELOAD && rvalid)
            rcnt <= rcnt + 1;
    end

    reg [3:0] wcnt;
    always @(posedge clk) begin
        if(rst)
            wcnt <= 0;
        else if(wcnt == 4'b1111 || cache_state == `CACHE_INIT)
            wcnt <= 0;
        else if(cache_state == `CACHE_WAIT)
            wcnt <= wcnt + 1;
    end

    //8 ram cache_data
    wire  [63:0] wmask = {{8{wstrb[7]}}, {8{wstrb[6]}}, {8{wstrb[5]}}, {8{wstrb[4]}}, 
                          {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}}};
    assign cen = 1;
    assign wen_block0   = (is_reload && rcnt[3:1] == 0) || (is_write && block == 0);
    assign wen_block1   = (is_reload && rcnt[3:1] == 1) || (is_write && block == 1);
    assign wen_block2   = (is_reload && rcnt[3:1] == 2) || (is_write && block == 2);
    assign wen_block3   = (is_reload && rcnt[3:1] == 3) || (is_write && block == 3);
    assign wen_block4   = (is_reload && rcnt[3:1] == 4) || (is_write && block == 4);
    assign wen_block5   = (is_reload && rcnt[3:1] == 5) || (is_write && block == 5);
    assign wen_block6   = (is_reload && rcnt[3:1] == 6) || (is_write && block == 6);
    assign wen_block7   = (is_reload && rcnt[3:1] == 7) || (is_write && block == 7);
    assign bwen         = is_reload ? (128'hffffffffffffffffffffffffffffffff & {{64{rcnt[0]}}, {64{!rcnt[0]}}}) : 
                                      ({2{wmask}} & {{64{word[0]}}, {64{!word[0]}}});
    assign addr_block   = is_reload ? {replace_way, index} : {cache_way, index};
    assign wdata_block  = is_reload ? {2{sram_rdata}} : {2{wdata << {offset[2:0], 3'b0}}};

    S011HD1P_X32Y2D128_BW cache_data_block0(
        .Q(rdata_block0), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block0), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    S011HD1P_X32Y2D128_BW cache_data_block1(
        .Q(rdata_block1), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block1), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    S011HD1P_X32Y2D128_BW cache_data_block2(
        .Q(rdata_block2), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block2), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    S011HD1P_X32Y2D128_BW cache_data_block3(
        .Q(rdata_block3), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block3), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    S011HD1P_X32Y2D128_BW cache_data_block4(
        .Q(rdata_block4), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block4), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    S011HD1P_X32Y2D128_BW cache_data_block5(
        .Q(rdata_block5), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block5), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    S011HD1P_X32Y2D128_BW cache_data_block6(
        .Q(rdata_block6), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block6), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    S011HD1P_X32Y2D128_BW cache_data_block7(
        .Q(rdata_block7), 
        .CLK(clk), 
        .CEN(~cen), 
        .WEN(~wen_block7), 
        .BWEN(~bwen), 
        .A(addr_block), 
        .D(wdata_block)
    );
    

    //sram
    wire        is_loaddata = 1;
    wire        recv_data;
    wire        recv_inst;

    wire [31:0] araddr = is_device_addr? addr : {tag, index, 7'b0};
    wire        arvalid = (cache_state == `CACHE_RELOAD) || (cache_state == `CACHE_DEVICE && !wen);
    wire        arready;
    wire [ 7:0] arlen = is_device_addr? 8'b0 : 8'b1111;
    wire [ 2:0] arsize = 3'b11;
    wire [ 1:0] arburst = 2'b10;

    wire [63:0] sram_rdata;
    wire [ 1:0] rresp;
    wire        rlast;
    wire        rvalid;
    wire        rready = 1;

    wire [`TAG_WIDTH-1:0] replace_tag = {`TAG_WIDTH{replace_way == 0}} & cache_tag_way0[index] |
                                        {`TAG_WIDTH{replace_way == 1}} & cache_tag_way1[index] |
                                        {`TAG_WIDTH{replace_way == 2}} & cache_tag_way2[index] |
                                        {`TAG_WIDTH{replace_way == 3}} & cache_tag_way3[index] ;
    wire [31:0] awaddr = is_device_addr? addr : {replace_tag, index, 7'b0};
    wire        awvalid = (cache_state == `CACHE_WAIT) || (cache_state == `CACHE_DEVICE && wen);
    wire        awready;
    wire [ 7:0] awlen = is_device_addr? 8'b0 : 8'b1111;
    wire [ 2:0] awsize = 3'b11;
    wire [ 1:0] awburst = 2'b10;

    wire [63:0] sram_wdata = is_device_addr? wdata :
                            {64{wcnt[3:1] == 0}} & rdata_block0[64*wcnt[0] +: 64] |
                            {64{wcnt[3:1] == 1}} & rdata_block1[64*wcnt[0] +: 64] |
                            {64{wcnt[3:1] == 2}} & rdata_block2[64*wcnt[0] +: 64] |
                            {64{wcnt[3:1] == 3}} & rdata_block3[64*wcnt[0] +: 64] |
                            {64{wcnt[3:1] == 4}} & rdata_block4[64*wcnt[0] +: 64] |
                            {64{wcnt[3:1] == 5}} & rdata_block5[64*wcnt[0] +: 64] |
                            {64{wcnt[3:1] == 6}} & rdata_block6[64*wcnt[0] +: 64] |
                            {64{wcnt[3:1] == 7}} & rdata_block7[64*wcnt[0] +: 64] ;
    wire [ 7:0] sram_wstrb = is_device_addr? wstrb : 8'hff;
    reg         wlast;
    always @(posedge clk) begin
        if(rst)
            wlast <= 0;
        else if(wcnt == awlen[3:0])
            wlast <= 1;
        else 
            wlast <= 0;
    end
    wire        wvalid = (cache_state == `CACHE_WAIT) || (cache_state == `CACHE_DEVICE && wen);
    wire        wready;

    wire [ 1:0] bresp;
    wire        sram_bvalid;
    wire        sram_bready = 1;

    SDRAM sdram(
    .clk(clk),
    .rst(rst),

    /*.is_loaddata(is_loaddata),
    .recv_data(recv_data),
    .recv_inst(recv_inst),
    .pc({32'b0,araddr}),
    .inst(inst),*/

    .araddr(araddr),
    .arvalid(arvalid),
    .arready(arready),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),

    .rdata(sram_rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),

    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),

    .wdata(sram_wdata),
    .wstrb(sram_wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),

    .bresp(bresp),
    .bvalid(sram_bvalid),
    .bready(sram_bready)
    );


endmodule
module MEM(
    input  wire clk,
    input  wire rst,

    input  wire exe_to_mem_valid,
    output wire mem_allow_in,
    output wire mem_ready_go,
    output reg  mem_valid,
    output wire mem_to_wb_valid,
    input  wire wb_allow_in,

    input  wire [ 6:0] exe_ld_type,
    input  wire [ 3:0] exe_st_type,

    input  wire [63:0] exe_result,      //addr
    input  wire [63:0] mem_st_data,     //st_data
    output wire [63:0] mem_ld_data,     //ld_data
    output wire        mem_ld,
    output wire [63:0] mem_exe_result,  

    input  wire [63:0] exe_pc,
    input  wire [31:0] exe_inst,
    input  wire [ 4:0] exe_rd,
    input  wire        exe_rd_wen,

    input  wire        exe_ex,
    input  wire [62:0] exe_ecode,
    input  wire        exe_ex_ret,

    input  wire        exe_csr_re,
    input  wire        exe_csr_we,
    input  wire        exe_csr_set,
    input  wire [11:0] exe_csr_num,
    input  wire [63:0] exe_csr_wdata,

    output reg  [63:0] mem_pc,
    output reg  [31:0] mem_inst,
    output reg  [ 4:0] mem_rd,
    output reg         mem_rd_wen,

    output reg         mem_ex,
    output reg  [62:0] mem_ecode,
    output reg         mem_ex_ret,

    output reg         mem_csr_re,
    output reg         mem_csr_we,
    output reg         mem_csr_set,
    output reg  [11:0] mem_csr_num,
    output reg  [63:0] mem_csr_wdata,

    input  wire        clear_pipline,

    //pref
    output reg  [63:0] d_miss_cnt,
    output reg  [63:0] device_cnt
);
    // MEM REG
    always @(posedge clk) begin
        if (rst) begin
            mem_valid <= 1'b0;
        end
        else if (mem_allow_in) begin
            mem_valid <= exe_to_mem_valid;
        end
    end

    reg [63:0] mem_addr;
    reg [63:0] mem_wdata;
    reg [ 6:0] mem_ld_type;
    reg [ 3:0] mem_st_type;

    always @(posedge clk) begin
        if (exe_to_mem_valid && mem_allow_in) begin
            mem_pc <= exe_pc;         // 设置存储器PC值
            mem_inst <= exe_inst;     // 设置存储器指令

            mem_rd <= exe_rd;         // 设置存储器目标寄存器编号
            mem_rd_wen <= exe_rd_wen; // 设置存储器写使能信号

            mem_wdata <= mem_st_data;  // 设置存储器写入数据
            mem_addr <= exe_result;   // 设置存储器地址
            mem_ld_type <= exe_ld_type; // 设置存储器加载类型
            mem_st_type <= exe_st_type; // 设置存储器存储类型


            mem_ex  <= exe_ex;
            mem_ecode <= exe_ecode;
            mem_ex_ret <= exe_ex_ret;

            mem_csr_re <= exe_csr_re;
            mem_csr_we <= exe_csr_we;
            mem_csr_set <= exe_csr_set;
            mem_csr_num <= exe_csr_num;
            mem_csr_wdata <= exe_csr_wdata;
            
        end
    end

    // 根据加载类型和存储类型确定存储器是否准备好接收指令
    assign mem_ready_go = (mem_ld_type == 0 && mem_st_type == 0)? 1 : d_hit;
    assign mem_allow_in = ~mem_valid | mem_ready_go & wb_allow_in;
    assign mem_to_wb_valid = mem_valid & mem_ready_go & ~clear_pipline;

    wire [ 6:0] ld_type = mem_ld_type;
    wire [ 3:0] st_type = mem_st_type;
    wire [63:0] rdata;
    wire [ 7:0] rmask;
    wire [ 2:0] offset;
    wire [ 7:0] wmask;

    //ld_data is later than ld_addr one circle
    //存储器读取数据的掩码计算
    reg  [31:0] mem_addr_r;
    reg  [ 6:0] ld_type_r; 
    always @(posedge clk) begin
        mem_addr_r <= mem_addr[31:0];
        ld_type_r <= ld_type;
    end

    assign offset = mem_addr[2:0];
    assign wmask =  {8{st_type[3]}} & (8'b1   << offset) |
                    {8{st_type[2]}} & (8'b11  << offset) |
                    {8{st_type[1]}} & (8'b1111<< offset) |
                    {8{st_type[0]}} & (8'b11111111) ;


    decoder_3_8 dec1 (mem_addr_r[2:0], rmask);
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
    assign rdata =  {64{ld_type_r[6]}} & {{56{lb_data[ 7]}}, lb_data} |
                    {64{ld_type_r[5]}} & {{48{lh_data[15]}}, lh_data} |
                    {64{ld_type_r[4]}} & {{32{lw_data[31]}}, lw_data} |
                    {64{ld_type_r[3]}} & d_rdata                      |
                    {64{ld_type_r[2]}} & {56'b0, lb_data}             |
                    {64{ld_type_r[1]}} & {48'b0, lh_data}             |
                    {64{ld_type_r[0]}} & {32'b0, lw_data}             ;

    assign mem_ld = (ld_type != 0);
    assign mem_ld_data = is_device_addr? device_rdata : rdata;
    assign mem_exe_result = mem_addr;

    //device
    reg         is_device_addr;
    reg  [63:0] device_rdata;
    always @(posedge clk) begin
        if(rst) begin
            is_device_addr <= 0;
            device_rdata <= 0;
        end
        else if(mem_addr >= 64'ha0000000) begin
            is_device_addr <= 1; 
            device_rdata <= rdata;
        end
        else begin
            is_device_addr <= 0;
        end
    end
    
    //wire  debug_addr = (mem_addr == 64'h81bebc60);


    //dcache
    wire [31:0] d_addr = mem_addr[31:0];
    // dcache中的数据有效标志，当ld_type或st_type不为0且mem_valid为1且不处于清除流水线状态时，数据有效
    wire        d_avalid = ((ld_type != 0) || (st_type != 0)) && mem_valid && !clear_pipline;
    wire        d_aready;
    wire [63:0] d_rdata;
    wire [63:0] d_wdata = mem_wdata;
    wire [ 7:0] d_wstrb = wmask;
    wire        d_bvalid;
    wire        d_bready = 1;
    wire        d_hit;

    cache dcache(
        .clk(clk),
        .rst(rst), 

        .addr(d_addr),
        .avalid(d_avalid),
        .aready(d_aready),
        //read data
        .rdata(d_rdata),
        //write data
        .wdata(d_wdata),
        .wstrb(d_wstrb),
        //response
        .bvalid(d_bvalid),
        .bready(d_bready),
        .hit(d_hit)
    );     

    //pref
    always @(posedge clk) begin
        if(rst)
            d_miss_cnt <= 0;
        else if(d_avalid && d_aready && !d_hit && mem_addr < 64'ha0000000)
            d_miss_cnt <= d_miss_cnt + 1;
    end

    always @(posedge clk) begin
        if(rst)
            device_cnt <= 0;
        else if(d_avalid && d_aready && mem_addr >= 64'ha0000000)
            device_cnt <= device_cnt + 1;
    end                 
endmodule

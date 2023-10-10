`define PC_ENTRY  64'h80000000   

module IFU #(WIDTH = 64)(
    input wire clk,
    input wire rst,

    output wire if_to_id_valid,  // 传递到ID阶段的指令有效信号
    input wire id_allow_in,  // ID阶段允许指令输入信号
    input wire id_valid,  // ID阶段有效指令信号
    input wire wb_valid,  // 写回阶段有效信号

    input wire br_taken,  // 分支是否被接受信号
    input wire [63:0] br_target,  // 分支目标地址

    input wire ex,  // 执行阶段有效信号
    input wire [63:0] ex_entry,  // 执行阶段指令地址
    input wire ex_ret,  // 执行阶段是否是返回指令信号
    input wire [63:0] epc,  // 异常程序计数器

    output wire [63:0] if_pc,  // 输出指令地址
    output wire [31:0] if_inst,  // 输出指令
    output wire id_inst_cancel,  // ID阶段是否取消指令
    input wire clear_pipline,  // 清空流水线信号

    output reg  [63:0] i_miss_cnt  // I-cache缺失计数器
);
    // pre_if stage
    wire pre_if_valid = !rst;
    wire pre_if_ready_go = i_aready && i_avalid;
    wire to_if_valid = pre_if_valid && pre_if_ready_go;

    //IF_stage
    reg  if_valid;
    wire if_ready_go = i_bvalid || if_inst_reg_valid;
    wire if_allow_in = ~if_valid | if_ready_go & id_allow_in;
    assign if_to_id_valid = if_valid && if_ready_go & ~clear_pipline;

    always @(posedge clk) begin
        if (rst) begin
            if_valid <= 1'b0;
        end
        else if (if_allow_in) begin
            if_valid <= to_if_valid;
        end
    end

    reg [63:0] pc;
    always @(posedge clk) begin
        if (rst) begin
            pc <= `PC_ENTRY-4;
        end
        else if (to_if_valid && id_allow_in) begin
            pc <= {32'b0, i_addr};
        end
    end
    
    wire [63:0] nextpc;
    wire        jump_taken;
    wire [63:0] jump_target;
    //当I-cache缺失且nextpc为跳转地址时，由于id_valid只存在一个周期，
    //jump_taken和jump_target应该为寄存器类型。
    reg         jump_taken_r;
    reg  [63:0] jump_target_r;

    assign id_inst_cancel = jump_taken || jump_taken_r;

    always @(posedge clk) begin
        if(pre_if_ready_go)
            jump_taken_r <= 0;
        else if(jump_taken) begin
            jump_taken_r <= 1;
            jump_target_r <= jump_target;
        end
    end
    assign jump_taken = (ex && wb_valid) ||
                        (ex_ret && wb_valid) ||
                        (br_taken && id_valid);
    assign jump_target = (ex && wb_valid)? ex_entry :
                        (ex_ret && wb_valid)? epc :
                        (br_taken && id_valid)? br_target:
                        pc + 4;
    assign nextpc = jump_taken ? jump_target :
                    (jump_taken_r) ? jump_target_r :
                    pc + 4;

    assign if_pc = pc;

    wire [31:0] inst = pc[2]? i_rdata[63:32] : i_rdata[31:0];

    /*
    * 初始化: valid == 0;
    * 如果inst_sram_data_ok但ID存在冒险，并且inst_reg为空: valid == 1, 存储rdata;
    * 如果inst_sram_data_ok但ID存在冒险，并且inst_reg不为空: 什么也不做;
    * 如果ID存在冒险 -> ID允许进入: ID读取存储的rdata, valid == 0;
    */
    reg        if_inst_reg_valid;
    reg [31:0] if_inst_reg;
    always @(posedge clk) begin
        if (rst) begin
            if_inst_reg_valid <= 1'b0;
        end
        else if (if_ready_go & ~id_allow_in & ~if_inst_reg_valid) begin
            if_inst_reg_valid <= 1'b1;
        end
        else if (id_allow_in) begin
            if_inst_reg_valid <= 1'b0;
        end

        if (if_ready_go & ~id_allow_in & ~if_inst_reg_valid) begin
            if_inst_reg <= inst;
        end
    end

    assign if_inst = if_inst_reg_valid ? if_inst_reg : inst;

    //icache
    wire [31:0] i_addr = nextpc[31:0];  // I-cache地址
    wire i_avalid = if_allow_in;  // I-cache是否允许输入信号
    wire i_aready;  // I-cache是否就绪信号
    wire [63:0] i_rdata;  // I-cache读取数据
    wire [63:0] i_wdata = 64'b0;  // I-cache写入数据
    wire [7:0] i_wstrb = 8'b0;  // I-cache写使能信号
    wire i_bvalid;  // I-cache写响应有效信号
    wire i_bready = 1;  // I-cache写响应就绪信号
    wire i_hit;  // I-cache是否命中

    //预取阶段
    always @(posedge clk) begin
        if(rst)
            i_miss_cnt <= 0;
        else if(i_avalid && i_aready && !i_hit)
            i_miss_cnt <= i_miss_cnt + 1; 
    end

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
        .bready(i_bready),
        .hit(i_hit)
    );
endmodule
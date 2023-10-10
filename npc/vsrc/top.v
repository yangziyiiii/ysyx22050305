module top #(WIDTH = 64)(
  input wire          clk,
  input wire          rst,

  //debug
  output wire         debug_valid,
  output wire [31:0]  debug_inst,
  output wire [63:0]  debug_pc,

  //pref
  output reg  [63:0]  inst_cnt,    // 指令计数器
  output wire [63:0]  icache_miss, // 指令高速缓存未命中计数
  output reg  [63:0]  mem_cnt,     // 存储器计数器
  output wire [63:0]  dcache_miss, // 数据高速缓存未命中计数
  output wire [63:0]  device_cnt,  // 设备计数
  output reg  [63:0]  mul_cnt,     // 乘法计数
  output reg  [63:0]  div_cnt      // 除法计数
);

// if_stage
wire        if_to_id_valid;
wire [63:0] if_pc;
wire [31:0] if_inst;
wire        id_inst_cancel;

// id_stage
wire        id_allow_in;
wire        id_valid;
wire        id_to_exe_valid;

wire [63:0] id_pc;
wire [31:0] id_inst;
wire [4 :0] rs1;
wire [4 :0] rs2;
wire        id_rd_wen;
wire [4 :0] id_rd;

wire        br_taken;
wire [63:0] br_target;

wire        id_inst_32bit;
wire [6 :0] id_ld_type;
wire [3 :0] id_st_type;

wire [16:0] alu_op;
wire [63:0] op1;
wire [63:0] op2;

wire        id_csr_re;
wire        id_csr_we;
wire        id_csr_set;
wire [11:0] id_csr_num;
wire [63:0] id_csr_wdata;

wire        id_ex;
wire        id_ex_ret;
wire [62:0] id_ecode;


// exe_stage
wire exe_allow_in;
wire exe_ready_go;
wire exe_valid;
wire exe_to_mem_valid;

wire [63:0] exe_result;
wire [63:0] exe_rs2_data;

wire [63:0] exe_pc;
wire [31:0] exe_inst;
wire        exe_rd_wen;
wire [4 :0] exe_rd;

wire [6 :0] exe_ld_type;
wire [3 :0] exe_st_type;

wire        exe_csr_re;
wire        exe_csr_we;
wire        exe_csr_set;
wire [11:0] exe_csr_num;
wire [63:0] exe_csr_wdata;

wire        exe_ex;
wire        exe_ex_ret;
wire [62:0] exe_ecode;

// mem_stage
wire mem_allow_in;
wire mem_ready_go;
wire mem_valid;
wire mem_to_wb_valid;

wire [63:0] mem_exe_result;
wire        mem_ld;
wire [63:0] mem_ld_data;

wire [63:0] mem_pc;
wire [31:0] mem_inst;
wire        mem_rd_wen;
wire [4 :0] mem_rd;

wire        mem_csr_re;
wire        mem_csr_we;
wire        mem_csr_set;
wire [11:0] mem_csr_num;
wire [63:0] mem_csr_wdata;

wire        mem_ex;
wire        mem_ex_ret;
wire [62:0] mem_ecode;

// wb_stage
wire wb_allow_in;
wire wb_valid;

wire [63:0] wb_pc;
wire [31:0] wb_inst;

wire        wb_rd_wen;
wire [ 4:0] wb_rd;
wire [63:0] wb_wdata;

wire [63:0] r_data1;
wire [63:0] r_data2;

wire [63:0] csr_rvalue;
wire [63:0] ex_entry;
wire        wb_ex;
wire        wb_ex_ret;

wire        ex_clear_pipline;
wire        clear_pipline;

//hazard
wire hazard;
wire hazard_to_exe;
wire hazard_to_mem;
wire hazard_to_wb;
assign hazard_to_exe = exe_valid 
                    && exe_rd_wen 
                    && (exe_rd != 0) 
                    && (exe_rd == rs1 || exe_rd == rs2);
assign hazard_to_mem = mem_valid 
                    && mem_rd_wen 
                    && (mem_rd != 0) 
                    && (mem_rd == rs1 || mem_rd == rs2);
assign hazard_to_wb = wb_valid 
                    && wb_rd_wen
                    && (wb_rd != 0)
                    && (wb_rd == rs1 || wb_rd == rs2);
assign hazard = hazard_to_exe && (exe_ld_type !=0 || exe_csr_re || !exe_ready_go)
             || hazard_to_mem && (mem_csr_re || mem_ld);

//forward
wire [63:0] forward_rs1  = (hazard_to_exe && exe_rd == rs1) ? exe_result
                      : (hazard_to_mem && mem_rd == rs1) ? mem_exe_result
                      : (hazard_to_wb  && wb_rd == rs1) ? wb_wdata
                      : r_data1;
wire [63:0] forward_rs2  = (hazard_to_exe && exe_rd == rs2) ? exe_result
                      : (hazard_to_mem && mem_rd == rs2) ? mem_exe_result
                      : (hazard_to_wb  && wb_rd == rs2) ? wb_wdata
                      : r_data2;

//5 stage
IFU If_stage(
  .clk(clk),
  .rst(rst),

  .if_to_id_valid(if_to_id_valid),
  .id_allow_in(id_allow_in),
  .id_valid(id_valid),
  .wb_valid(wb_valid),

  .br_taken(br_taken),
  .br_target(br_target),

  .ex(wb_ex),
  .ex_entry(ex_entry),
  .ex_ret(wb_ex_ret),
  .epc(csr_rvalue),

  .if_pc(if_pc),
  .if_inst(if_inst),
  .id_inst_cancel(id_inst_cancel),
  .clear_pipline(clear_pipline),

  .i_miss_cnt(icache_miss)
);

IDU Id_stage(
  .clk(clk),
  .rst(rst),

  .if_to_id_valid(if_to_id_valid),
  .id_allow_in(id_allow_in),
  .id_valid(id_valid),
  .id_to_exe_valid(id_to_exe_valid),
  .exe_allow_in(exe_allow_in),

  .if_pc(if_pc),
  .if_inst(if_inst),

  .rs1_data(forward_rs1),
  .rs2_data(forward_rs2),
  
  .id_pc(id_pc),
  .id_inst(id_inst),
  .rs1(rs1),
  .rs2(rs2),
  .rd_wen(id_rd_wen),
  .rd(id_rd),
  .alu_op(alu_op),
  .op1(op1),
  .op2(op2),

  .br_taken(br_taken),
  .br_target(br_target),

  .ld_type(id_ld_type),
  .st_type(id_st_type),
  .inst_32bit(id_inst_32bit),

  .csr_re(id_csr_re),
  .csr_we(id_csr_we),
  .csr_set(id_csr_set),
  .csr_num(id_csr_num),
  .csr_wdata(id_csr_wdata),

  .id_ex(id_ex),
  .id_ex_ret(id_ex_ret),
  .id_ecode(id_ecode),

  .clear_pipline(clear_pipline),
  .hazard(hazard),
  .id_inst_cancel(id_inst_cancel)

);

EXEU Exe_stage(
  .clk(clk),
  .rst(rst),

  .id_to_exe_valid(id_to_exe_valid),
  .exe_allow_in(exe_allow_in),
  .exe_ready_go(exe_ready_go),
  .exe_valid(exe_valid),
  .exe_to_mem_valid(exe_to_mem_valid),
  .mem_allow_in(mem_allow_in),

  .id_pc(id_pc),
  .id_inst(id_inst),
  .id_rd_wen(id_rd_wen),
  .id_rd(id_rd),

  .br_taken(br_taken),
  .id_inst_32bit(id_inst_32bit),
  .id_ld_type(id_ld_type),
  .id_st_type(id_st_type),

  .alu_op(alu_op),
  .op1(op1),
  .op2(op2),
  .exe_result(exe_result),
  .rs2_data(forward_rs2),
  .exe_rs2_data(exe_rs2_data),

  .csr_re(id_csr_re),
  .csr_we(id_csr_we),
  .csr_set(id_csr_set),
  .csr_num(id_csr_num),
  .csr_wdata(id_csr_wdata),

  .id_ex(id_ex),
  .id_ex_ret(id_ex_ret),
  .id_ecode(id_ecode),

  .exe_pc(exe_pc),
  .exe_inst(exe_inst),
  .exe_rd_wen(exe_rd_wen),
  .exe_rd(exe_rd),
  .exe_ld_type(exe_ld_type),
  .exe_st_type(exe_st_type),

  .exe_csr_re(exe_csr_re),
  .exe_csr_we(exe_csr_we),
  .exe_csr_set(exe_csr_set),
  .exe_csr_num(exe_csr_num),
  .exe_csr_wdata(exe_csr_wdata),

  .exe_ex(exe_ex),
  .exe_ex_ret(exe_ex_ret),
  .exe_ecode(exe_ecode),

  .clear_pipline(clear_pipline)
);

MEM Mem_stage(
  .clk(clk),
  .rst(rst),

  .exe_to_mem_valid(exe_to_mem_valid),
  .mem_allow_in(mem_allow_in),
  .mem_ready_go(mem_ready_go),
  .mem_valid(mem_valid),
  .mem_to_wb_valid(mem_to_wb_valid),
  .wb_allow_in(wb_allow_in),

  .exe_ld_type(exe_ld_type),
  .exe_st_type(exe_st_type),
  .exe_result(exe_result),
  .mem_st_data(exe_rs2_data),
  .mem_ld_data(mem_ld_data),
  .mem_ld(mem_ld),
  .mem_exe_result(mem_exe_result),

  .exe_pc(exe_pc),
  .exe_inst(exe_inst),
  .exe_rd_wen(exe_rd_wen),
  .exe_rd(exe_rd),

  .exe_csr_re(exe_csr_re),
  .exe_csr_we(exe_csr_we),
  .exe_csr_set(exe_csr_set),
  .exe_csr_num(exe_csr_num),
  .exe_csr_wdata(exe_csr_wdata),

  .exe_ex(exe_ex),
  .exe_ex_ret(exe_ex_ret),
  .exe_ecode(exe_ecode),

  .mem_pc(mem_pc),
  .mem_inst(mem_inst),
  .mem_rd_wen(mem_rd_wen),
  .mem_rd(mem_rd),

  .mem_csr_re(mem_csr_re),
  .mem_csr_we(mem_csr_we),
  .mem_csr_set(mem_csr_set),
  .mem_csr_num(mem_csr_num),
  .mem_csr_wdata(mem_csr_wdata),

  .mem_ex(mem_ex),
  .mem_ex_ret(mem_ex_ret),
  .mem_ecode(mem_ecode),

  .clear_pipline(clear_pipline),

  .d_miss_cnt(dcache_miss),
  .device_cnt(device_cnt)
);

WBU Wb_stage(
  .clk(clk),
  .rst(rst),

  .mem_to_wb_valid(mem_to_wb_valid),
  .wb_allow_in(wb_allow_in),
  .wb_valid(wb_valid),

  .mem_pc(mem_pc),
  .mem_inst(mem_inst),
  .mem_ld(mem_ld),
  .mem_ld_data(mem_ld_data),
  .mem_exe_result(mem_exe_result),

  .mem_rd_wen(mem_rd_wen),
  .mem_rd(mem_rd),

  .mem_csr_re(mem_csr_re),
  .mem_csr_we(mem_csr_we),
  .mem_csr_set(mem_csr_set),
  .mem_csr_num(mem_csr_num),
  .mem_csr_wdata(mem_csr_wdata),

  .mem_ex(mem_ex),
  .mem_ex_ret(mem_ex_ret),
  .mem_ecode(mem_ecode),

  .wb_pc(wb_pc),
  .wb_inst(wb_inst),

  .wb_rd(wb_rd),
  .wb_rd_wen(wb_rd_wen),
  .wb_wdata(wb_wdata),

  .wb_ex(wb_ex),
  .wb_ex_ret(wb_ex_ret),
  .csr_rvalue(csr_rvalue),
  .ex_entry(ex_entry),

  .raddr1(rs1),
  .rdata1(r_data1),
  .raddr2(rs2),
  .rdata2(r_data2)
);

// 处理流水线清除的信号
assign ex_clear_pipline = (wb_ex || wb_ex_ret) & wb_valid;
assign clear_pipline = ex_clear_pipline;

//debug signal
  assign debug_valid = wb_valid;
  assign debug_inst = wb_inst;
  assign debug_pc = wb_pc;

//预取计数器
always @(posedge clk) begin
  if(rst) begin
    inst_cnt   <= 0;
    device_cnt <= 0;
    mul_cnt    <= 0;
    div_cnt    <= 0;
  end
  else if(debug_valid)
    inst_cnt <= inst_cnt + 1;
end

// 存储器计数器
always @(posedge clk) begin
  if(rst) begin
    mem_cnt <= 0;
  end
  else if(id_to_exe_valid && exe_allow_in && (id_ld_type != 0 || id_st_type != 0))
    mem_cnt <= mem_cnt + 1;
end


// 乘法计数器
always @(posedge clk) begin
  if(rst) begin
    mul_cnt <= 0;
  end
  else if(id_to_exe_valid && exe_allow_in && alu_op[12])
    mul_cnt <= mul_cnt + 1;
end

// 除法计数器
always @(posedge clk) begin
  if(rst) begin
    div_cnt <= 0;
  end
  else if(id_to_exe_valid && exe_allow_in && (alu_op[13] || alu_op[14] || alu_op[15] || alu_op[16]))
    div_cnt <= div_cnt + 1;
end
endmodule
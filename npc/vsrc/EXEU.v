module EXEU #(WIDTH = 64)(
  input  wire clk,
  input  wire rst,

  input  wire id_to_exe_valid,
  output wire exe_allow_in,
  output wire exe_ready_go,
  output reg  exe_valid,
  output wire exe_to_mem_valid,
  input  wire mem_allow_in,

  input  wire [63:0] id_pc,
  input  wire [31:0] id_inst,

  input  wire        id_rd_wen,
  input  wire [4 :0] id_rd,

  input  wire [16:0] alu_op,
  input  wire [63:0] op1,
  input  wire [63:0] op2,

  input  wire        br_taken,
  input  wire [63:0] rs2_data,
  output reg  [63:0] exe_rs2_data,
  output wire [63:0] exe_result,

  input  wire        id_inst_32bit,
  input  wire [6 :0] id_ld_type,
  input  wire [3 :0] id_st_type,

  input  wire        csr_re,
  input  wire        csr_we,
  input  wire        csr_set,
  input  wire [11:0] csr_num,
  input  wire [63:0] csr_wdata,

  input  wire        id_ex,
  input  wire [62:0] id_ecode,
  input  wire        id_ex_ret,

  output reg  [63:0] exe_pc,
  output reg  [31:0] exe_inst,
  output reg  [ 4:0] exe_rd,
  output reg         exe_rd_wen,

  output reg  [6 :0] exe_ld_type,
  output reg  [3 :0] exe_st_type,

  output reg         exe_ex,
  output reg  [62:0] exe_ecode,
  output reg         exe_ex_ret,

  output reg         exe_csr_re,
  output reg         exe_csr_we,
  output reg         exe_csr_set,
  output reg  [11:0] exe_csr_num,
  output reg  [63:0] exe_csr_wdata,

  input  wire        clear_pipline
);
  // 确定是否允许执行阶段接收指令，依赖于ALU是否繁忙和流水线是否清空
  assign exe_ready_go = !alu_busy | clear_pipline; 
  assign exe_allow_in = ~exe_valid | exe_ready_go & mem_allow_in;
  assign exe_to_mem_valid = exe_valid & exe_ready_go & ~clear_pipline;
  
  always @(posedge clk) begin
      if (rst) begin
          exe_valid <= 1'b0;
      end
      else if (exe_allow_in) begin
          exe_valid <= id_to_exe_valid;
      end
  end

  reg [63:0] exe_alu_src1;
  reg [63:0] exe_alu_src2;
  reg [16:0] exe_alu_op;
  reg        exe_inst_32bit;
  reg        exe_br_taken;

  always @(posedge clk) begin
      if (id_to_exe_valid && exe_allow_in) begin
          exe_pc      <= id_pc;
          exe_inst    <= id_inst;

          exe_rd_wen  <= id_rd_wen;
          exe_rd      <= id_rd;
          exe_rs2_data <= rs2_data;

          exe_alu_src1 <= op1;
          exe_alu_src2 <= op2;
          exe_alu_op <= alu_op;
          exe_br_taken <= br_taken;

          exe_inst_32bit <= id_inst_32bit;
          exe_ld_type <= id_ld_type;
          exe_st_type <= id_st_type;

          exe_ex <= id_ex;
          exe_ecode <= id_ecode;
          exe_ex_ret <= id_ex_ret;

          exe_csr_re <= csr_re;
          exe_csr_we <= csr_we;
          exe_csr_set <= csr_set;       
          exe_csr_num <= csr_num;       
          exe_csr_wdata <= csr_wdata;       
      end
  end


  //alu signal
  wire [63:0] alu_result;
  wire [63:0] alu_result_v;
  reg  [63:0] alu_result_r;
  reg  alu_busy;
  wire alu_out_valid;
  wire alu_muldiv = alu_op[16:12] != 0;  // 判断是否为乘除法指令
  wire exe_muldiv = exe_alu_op[16:12] != 0;

  always @(posedge clk) begin
      if (id_to_exe_valid && exe_allow_in && alu_muldiv)
        alu_busy <= 1;
      else if(alu_out_valid) begin
        alu_busy <= 0;
        alu_result_r <= alu_result;
      end
  end

  alu #(WIDTH) alu(
    .clk(clk),
    .rst(rst),
    .inst_32bit(exe_inst_32bit),
    .alu_op(exe_alu_op),
    .alu_src1(exe_alu_src1),
    .alu_src2(exe_alu_src2),
    .alu_result(alu_result),
    .alu_busy(alu_busy),
    .alu_out_valid(alu_out_valid),
    .alu_flush(clear_pipline)
  );

  assign alu_result_v = exe_muldiv? alu_result_r : alu_result;
  assign exe_result = exe_br_taken? (exe_pc + 64'h4) : 
                      exe_inst_32bit? {{32{alu_result_v[31]}}, alu_result_v[31:0]} : 
                      alu_result_v;
endmodule
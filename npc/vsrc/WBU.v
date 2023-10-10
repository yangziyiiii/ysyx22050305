module WBU(
  input  clk,
  input  rst,

  input  wire mem_to_wb_valid,   // 内存模块到写回模块数据是否有效
  output wire wb_allow_in,       // 写回模块是否允许接收数据
  output reg  wb_valid,          // 写回模块数据是否有效

  input  wire [63:0] mem_pc,     // 内存模块返回的程序计数器值
  input  wire [31:0] mem_inst,   // 内存模块返回的指令
  input  wire [63:0] mem_exe_result,  // 内存模块返回的执行结果
  input  wire [63:0] mem_ld_data,     // 内存模块返回的加载数据
  input  wire        mem_ld,     // 内存模块是否加载数据

  input  wire [ 4:0] mem_rd,     // 内存模块返回的目标寄存器地址（写回地址）
  input  wire        mem_rd_wen, // 内存模块返回的写回使能信号

  input  wire        mem_ex,     // 内存模块返回的异常信号
  input  wire [62:0] mem_ecode,  // 内存模块返回的异常码
  input  wire        mem_ex_ret, // 内存模块返回的异常返回信号

  input  wire        mem_csr_re,     // 内存模块返回的CSR读使能信号
  input  wire        mem_csr_we,     // 内存模块返回的CSR写使能信号
  input  wire        mem_csr_set,    // 内存模块返回的CSR写入标志
  input  wire [11:0] mem_csr_num,    // 内存模块返回的CSR寄存器号
  input  wire [63:0] mem_csr_wdata,  // 内存模块返回的CSR写入数据

  output reg  [63:0] wb_pc,         // 写回模块的程序计数器值
  output reg  [31:0] wb_inst,       // 写回模块的指令
  output reg  [ 4:0] wb_rd,         // 写回模块的目标寄存器地址（写回地址）
  output reg         wb_rd_wen,     // 写回模块的写回使能信号
  output wire [63:0] wb_wdata,      // 写回模块的写入数据

  output wire [63:0] ex_entry,      // 异常入口地址
  output reg         wb_ex,         // 写回模块的异常信号
  output reg         wb_ex_ret,     // 写回模块的异常返回信号
  output wire [63:0] csr_rvalue,    // CSR读取值

  input  wire [4 :0] raddr1,        // 寄存器文件读取地址1
  input  wire [4 :0] raddr2,        // 寄存器文件读取地址2
  output wire [63:0] rdata1,       // 寄存器文件读取数据1
  output wire [63:0] rdata2        // 寄存器文件读取数据2
);
  // 写回模块的数据寄存器
  reg        wb_ld;               // 是否需要加载数据到寄存器
  reg [63:0] wb_exe_result;      // 内存模块返回的执行结果
  reg [62:0] wb_ecode;           // 内存模块返回的异常码
  reg        csr_re;             // 是否进行CSR寄存器读取
  reg        csr_we;             // 是否进行CSR寄存器写入
  reg        csr_set;            // 是否进行CSR寄存器写入标志
  reg [11:0] csr_num;            // CSR寄存器号
  reg [63:0] csr_wdata;          // CSR寄存器写入数据

  always @(posedge clk) begin
      if (rst) begin
          wb_valid <= 1'b0;
      end
      else if (wb_allow_in) begin
          wb_valid <= mem_to_wb_valid;
      end
  end

  always @(posedge clk) begin
      if (mem_to_wb_valid && wb_allow_in) begin
          wb_pc <= mem_pc;
          wb_inst <= mem_inst;

          wb_rd <= mem_rd;
          wb_rd_wen <= mem_rd_wen;
          wb_ld <= mem_ld;
          wb_exe_result <= mem_exe_result;

          wb_ex <= mem_ex;
          wb_ecode <= mem_ecode;
          wb_ex_ret <= mem_ex_ret;

          csr_re <= mem_csr_re;
          csr_we <= mem_csr_we;
          csr_set <= mem_csr_set;
          csr_num <= mem_csr_num;
          csr_wdata <= mem_csr_wdata;
      end
  end
  wire   wb_ready_go = 1'b1;
  assign wb_allow_in = ~wb_valid | wb_ready_go;


//regfile
  assign wb_wdata = csr_re? csr_rvalue :
                    wb_ld? mem_ld_data : 
                    wb_exe_result;

  RegFile Regfile(
  .clk(clk),
  .wdata(wb_wdata),
  .waddr(wb_rd),
  .wen(wb_rd_wen & wb_valid),
  .raddr1(raddr1),
  .rdata1(rdata1),
  .raddr2(raddr2),
  .rdata2(rdata2)
);

//csr and ex
// CSR模块的掩码与写入值计算
wire [63:0] csr_wmask = csr_set? csr_wdata : 64'hffffffffffffffff;
wire [63:0] csr_wvalue = csr_set? 64'hffffffffffffffff : csr_wdata;
CSR csr(
  .clk(clk),
  .rst(rst), 
  .csr_re(csr_re & wb_valid),
  .csr_num(csr_num),
  .csr_rvalue(csr_rvalue),
  .csr_we(csr_we & wb_valid),
  .csr_wmask(csr_wmask),
  .csr_wvalue(csr_wvalue),

  .ex(wb_ex),
  .ex_ret(wb_ex_ret),
  .epc(wb_pc),
  .ecode(wb_ecode),
  .ex_entry(ex_entry)
);
endmodule
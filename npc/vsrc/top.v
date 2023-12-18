module top(
    input wire clk,
    input wire rst,

    output wire debug_valid,
    output wire [31:0] inst,
    output wire [63:0] pc,
    output wire [63:0] next_pc
);

//if_stage
wire if_valid;

//id_stage
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire rd_wen;

wire br_taken;
wire [5:0] inst_type;
wire inst_32bit;
wire [16:0] alu_op;
wire [63:0] op1;
wire [63:0] op2;
wire [63:0] rd_wdata;

//exe_stage
wire [63:0] exe_result;
wire [63:0] exe_result_32bit;

//mem_stage
wire [63:0] mem_rdata;
wire [6:0] ld_type;
wire [3:0] st_type;
wire mem_valid;

//csr
wire ex;
wire ex_ret;
wire [63:0] ex_entry;
wire [62:0] ecode;
wire csr_re;
wire csr_we;
wire csr_set;
wire [63:0] csr_rvalue;
wire [63:0] csr_wmask;
wire [63:0] csr_wvalue;

//regfile
wire [63:0] r_data1;
wire [63:0] r_data2;
/* verilator lint_off IMPLICIT */
IFU If_stage(
  .clk(clk),
  .rst(rst),
  .br_taken(br_taken),
  .br_target(exe_result),
  .ex(ex),
  .ex_entry(ex_entry),
  .ex_ret(ex_ret),
  .epc(csr_rvalue),
  /* verilator lint_off WIDTHEXPAND */
  .nextpc(nextpc),
  /* verilator lint_off WIDTHEXPAND */
  .pc(pc),
  .inst(inst),
  .if_valid(if_valid),
  .mem_valid(mem_valid),
  .debug_valid(debug_valid)
);

IDU Id_stage(
  .rst(rst),
  .pc(pc),
  .inst(inst),
  .rs1_data(r_data1),
  .rs2_data(r_data2),
  
  .br_taken(br_taken),
  .inst_type(inst_type),
  .ld_type(ld_type),
  .st_type(st_type),
  .inst_32bit(inst_32bit),

  .rs1(rs1),
  .rs2(rs2),
  .rd_wen(rd_wen),
  .rd(rd),
  .alu_op(alu_op),
  .op1(op1),
  .op2(op2),

  .csr_re(csr_re),
  .csr_we(csr_we),
  .csr_set(csr_set),
  .ex(ex),
  .ex_ret(ex_ret),
  .ecode(ecode)
);

EXEU Exe_stage(
  .rst(rst),
  .inst_32bit(inst_32bit),
  .alu_op(alu_op),
  .op1(op1),
  .op2(op2),
  
  .exe_result(exe_result)
);

MEM Mem_stage(
  .clk(clk),
  .rst(rst),
  .addr(exe_result),
  .rdata(mem_rdata),
  .ld_type(ld_type),
  .st_type(st_type),
  .wdata(r_data2),
  .mem_valid(mem_valid)
);

assign exe_result_32bit = {{32{exe_result[31]}}, exe_result[31:0]};

assign rd_wdata = br_taken? (pc + 64'h4) :  
                  (ld_type != 0)? mem_rdata : 
                  inst_32bit? exe_result_32bit :
                  csr_re? csr_rvalue :
                  exe_result;

RegFile Regfile(
  .clk(clk),
  .wdata(rd_wdata),
  .waddr(rd),
  .wen(rd_wen & debug_valid),
  
  .raddr1(rs1),
  .rdata1(r_data1),
  .raddr2(rs2),
  .rdata2(r_data2)
);

assign csr_wmask = csr_set? r_data1 : 64'hffffffffffffffff;
assign csr_wvalue = csr_set? 64'hffffffffffffffff : r_data1;
CSR csr(
  .clk(clk),
  .rst(rst), 
  .csr_re(csr_re & debug_valid),
  .csr_num(op2[11:0]),
  .csr_rvalue(csr_rvalue),
  .csr_we(csr_we & debug_valid),
  .csr_wmask(csr_wmask),
  .csr_wvalue(csr_wvalue),

  .ex(ex & debug_valid),
  .ex_ret(ex_ret),
  .epc(pc),
  .ecode(ecode),
  .ex_entry(ex_entry)
);

EBREAK ebreak(
  .inst(inst)
);

  assign debug_valid = mem_valid & if_valid;

endmodule 




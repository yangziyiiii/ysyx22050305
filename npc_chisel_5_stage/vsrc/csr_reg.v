module csr_reg(
  input         clock,
  input         io_wen1,
  input         io_wen2,
  input  [1:0]  io_waddr1,
  input  [63:0] io_wdata1,
  input  [1:0]  io_raddr,
  output [63:0] io_rdata
);
`ifdef RANDOMIZE_MEM_INIT
  reg [63:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
  reg [63:0] CSR_Reg [0:3]; // @[csr_reg.scala 19:22]
  wire  CSR_Reg_io_rdata_MPORT_en; // @[csr_reg.scala 19:22]
  wire [1:0] CSR_Reg_io_rdata_MPORT_addr; // @[csr_reg.scala 19:22]
  wire [63:0] CSR_Reg_io_rdata_MPORT_data; // @[csr_reg.scala 19:22]
  wire [63:0] CSR_Reg_MPORT_data; // @[csr_reg.scala 19:22]
  wire [1:0] CSR_Reg_MPORT_addr; // @[csr_reg.scala 19:22]
  wire  CSR_Reg_MPORT_mask; // @[csr_reg.scala 19:22]
  wire  CSR_Reg_MPORT_en; // @[csr_reg.scala 19:22]
  wire [63:0] CSR_Reg_MPORT_1_data; // @[csr_reg.scala 19:22]
  wire [1:0] CSR_Reg_MPORT_1_addr; // @[csr_reg.scala 19:22]
  wire  CSR_Reg_MPORT_1_mask; // @[csr_reg.scala 19:22]
  wire  CSR_Reg_MPORT_1_en; // @[csr_reg.scala 19:22]
  wire [63:0] CSR_Reg_MPORT_2_data; // @[csr_reg.scala 19:22]
  wire [1:0] CSR_Reg_MPORT_2_addr; // @[csr_reg.scala 19:22]
  wire  CSR_Reg_MPORT_2_mask; // @[csr_reg.scala 19:22]
  wire  CSR_Reg_MPORT_2_en; // @[csr_reg.scala 19:22]
  assign CSR_Reg_io_rdata_MPORT_en = 1'h1;
  assign CSR_Reg_io_rdata_MPORT_addr = io_raddr;
  assign CSR_Reg_io_rdata_MPORT_data = CSR_Reg[CSR_Reg_io_rdata_MPORT_addr]; // @[csr_reg.scala 19:22]
  assign CSR_Reg_MPORT_data = 64'ha00001800;
  assign CSR_Reg_MPORT_addr = 2'h2;
  assign CSR_Reg_MPORT_mask = 1'h1;
  assign CSR_Reg_MPORT_en = 1'h1;
  assign CSR_Reg_MPORT_1_data = io_wdata1;
  assign CSR_Reg_MPORT_1_addr = io_waddr1;
  assign CSR_Reg_MPORT_1_mask = 1'h1;
  assign CSR_Reg_MPORT_1_en = io_wen1;
  assign CSR_Reg_MPORT_2_data = 64'hb;
  assign CSR_Reg_MPORT_2_addr = 2'h3;
  assign CSR_Reg_MPORT_2_mask = 1'h1;
  assign CSR_Reg_MPORT_2_en = io_wen2;
  assign io_rdata = CSR_Reg_io_rdata_MPORT_data; // @[csr_reg.scala 27:14]
  always @(posedge clock) begin
    if (CSR_Reg_MPORT_en & CSR_Reg_MPORT_mask) begin
      CSR_Reg[CSR_Reg_MPORT_addr] <= CSR_Reg_MPORT_data; // @[csr_reg.scala 19:22]
    end
    if (CSR_Reg_MPORT_1_en & CSR_Reg_MPORT_1_mask) begin
      CSR_Reg[CSR_Reg_MPORT_1_addr] <= CSR_Reg_MPORT_1_data; // @[csr_reg.scala 19:22]
    end
    if (CSR_Reg_MPORT_2_en & CSR_Reg_MPORT_2_mask) begin
      CSR_Reg[CSR_Reg_MPORT_2_addr] <= CSR_Reg_MPORT_2_data; // @[csr_reg.scala 19:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {2{`RANDOM}};
  for (initvar = 0; initvar < 4; initvar = initvar+1)
    CSR_Reg[initvar] = _RAND_0[63:0];
`endif // RANDOMIZE_MEM_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule

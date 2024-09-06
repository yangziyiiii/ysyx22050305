module AXI_ARBITER(
  input         clock,
  input         reset,
  input  [31:0] io_ifu_axi_in_araddr,
  input  [7:0]  io_ifu_axi_in_arlen,
  input         io_ifu_axi_in_arvalid,
  input         io_ifu_axi_in_rready,
  output [63:0] io_ifu_axi_out_rdata,
  output        io_ifu_axi_out_rlast,
  output        io_ifu_axi_out_rvalid,
  input  [31:0] io_lsu_axi_in_araddr,
  input  [7:0]  io_lsu_axi_in_arlen,
  input         io_lsu_axi_in_arvalid,
  input  [31:0] io_lsu_axi_in_awaddr,
  input  [7:0]  io_lsu_axi_in_awlen,
  input         io_lsu_axi_in_awvalid,
  input  [63:0] io_lsu_axi_in_wdata,
  input  [7:0]  io_lsu_axi_in_wstrb,
  input         io_lsu_axi_in_wvalid,
  input         io_lsu_axi_in_bready,
  output [63:0] io_lsu_axi_out_rdata,
  output        io_lsu_axi_out_rlast,
  output        io_lsu_axi_out_rvalid,
  output        io_lsu_axi_out_wready,
  output        io_lsu_axi_out_bvalid,
  input  [63:0] io_axi_in_rdata,
  input         io_axi_in_rlast,
  input         io_axi_in_wready,
  input         io_axi_in_bvalid,
  output [31:0] io_axi_out_araddr,
  output [7:0]  io_axi_out_arlen,
  output        io_axi_out_arvalid,
  output        io_axi_out_rready,
  output [31:0] io_axi_out_awaddr,
  output [7:0]  io_axi_out_awlen,
  output        io_axi_out_awvalid,
  output [63:0] io_axi_out_wdata,
  output [7:0]  io_axi_out_wstrb,
  output        io_axi_out_wvalid,
  output        io_axi_out_bready
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] state; // @[axi_arbiter.scala 18:24]
  wire [1:0] _GEN_0 = io_ifu_axi_in_arvalid ? 2'h1 : state; // @[axi_arbiter.scala 61:46 62:23 18:24]
  wire [31:0] _GEN_1 = io_ifu_axi_in_arvalid ? io_ifu_axi_in_araddr : 32'h0; // @[axi_arbiter.scala 48:16 61:46 63:28]
  wire [7:0] _GEN_2 = io_ifu_axi_in_arvalid ? io_ifu_axi_in_arlen : 8'h0; // @[axi_arbiter.scala 48:16 61:46 63:28]
  wire  _GEN_6 = io_ifu_axi_in_arvalid & io_ifu_axi_in_rready; // @[axi_arbiter.scala 48:16 61:46 63:28]
  wire [63:0] _GEN_18 = io_ifu_axi_in_arvalid ? io_axi_in_rdata : 64'h0; // @[axi_arbiter.scala 50:20 61:46 64:32]
  wire  _GEN_19 = io_ifu_axi_in_arvalid & io_axi_in_rlast; // @[axi_arbiter.scala 50:20 61:46 64:32]
  wire [31:0] _GEN_25 = io_lsu_axi_in_arvalid ? io_lsu_axi_in_araddr : _GEN_1; // @[axi_arbiter.scala 57:46 59:28]
  wire [7:0] _GEN_26 = io_lsu_axi_in_arvalid ? io_lsu_axi_in_arlen : _GEN_2; // @[axi_arbiter.scala 57:46 59:28]
  wire  _GEN_29 = io_lsu_axi_in_arvalid ? io_lsu_axi_in_arvalid : io_ifu_axi_in_arvalid; // @[axi_arbiter.scala 57:46 59:28]
  wire  _GEN_30 = io_lsu_axi_in_arvalid | _GEN_6; // @[axi_arbiter.scala 57:46 59:28]
  wire [31:0] _GEN_31 = io_lsu_axi_in_arvalid ? io_lsu_axi_in_awaddr : 32'h0; // @[axi_arbiter.scala 57:46 59:28]
  wire [7:0] _GEN_32 = io_lsu_axi_in_arvalid ? io_lsu_axi_in_awlen : 8'h0; // @[axi_arbiter.scala 57:46 59:28]
  wire  _GEN_35 = io_lsu_axi_in_arvalid & io_lsu_axi_in_awvalid; // @[axi_arbiter.scala 57:46 59:28]
  wire [63:0] _GEN_36 = io_lsu_axi_in_arvalid ? io_lsu_axi_in_wdata : 64'h0; // @[axi_arbiter.scala 57:46 59:28]
  wire [7:0] _GEN_37 = io_lsu_axi_in_arvalid ? io_lsu_axi_in_wstrb : 8'h0; // @[axi_arbiter.scala 57:46 59:28]
  wire  _GEN_39 = io_lsu_axi_in_arvalid & io_lsu_axi_in_wvalid; // @[axi_arbiter.scala 57:46 59:28]
  wire  _GEN_40 = io_lsu_axi_in_arvalid & io_lsu_axi_in_bready; // @[axi_arbiter.scala 57:46 59:28]
  wire [63:0] _GEN_42 = io_lsu_axi_in_arvalid ? io_axi_in_rdata : 64'h0; // @[axi_arbiter.scala 49:20 57:46 60:32]
  wire  _GEN_43 = io_lsu_axi_in_arvalid & io_axi_in_rlast; // @[axi_arbiter.scala 49:20 57:46 60:32]
  wire  _GEN_46 = io_lsu_axi_in_arvalid & io_axi_in_wready; // @[axi_arbiter.scala 49:20 57:46 60:32]
  wire  _GEN_47 = io_lsu_axi_in_arvalid & io_axi_in_bvalid; // @[axi_arbiter.scala 49:20 57:46 60:32]
  wire [63:0] _GEN_49 = io_lsu_axi_in_arvalid ? 64'h0 : _GEN_18; // @[axi_arbiter.scala 50:20 57:46]
  wire  _GEN_50 = io_lsu_axi_in_arvalid ? 1'h0 : _GEN_19; // @[axi_arbiter.scala 50:20 57:46]
  wire  _GEN_51 = io_lsu_axi_in_arvalid ? 1'h0 : io_ifu_axi_in_arvalid; // @[axi_arbiter.scala 50:20 57:46]
  wire [31:0] _GEN_56 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_araddr : _GEN_25; // @[axi_arbiter.scala 53:40 55:28]
  wire [7:0] _GEN_57 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_arlen : _GEN_26; // @[axi_arbiter.scala 53:40 55:28]
  wire  _GEN_60 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_arvalid : _GEN_29; // @[axi_arbiter.scala 53:40 55:28]
  wire  _GEN_61 = io_lsu_axi_in_awvalid | _GEN_30; // @[axi_arbiter.scala 53:40 55:28]
  wire [31:0] _GEN_62 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_awaddr : _GEN_31; // @[axi_arbiter.scala 53:40 55:28]
  wire [7:0] _GEN_63 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_awlen : _GEN_32; // @[axi_arbiter.scala 53:40 55:28]
  wire  _GEN_66 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_awvalid : _GEN_35; // @[axi_arbiter.scala 53:40 55:28]
  wire [63:0] _GEN_67 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_wdata : _GEN_36; // @[axi_arbiter.scala 53:40 55:28]
  wire [7:0] _GEN_68 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_wstrb : _GEN_37; // @[axi_arbiter.scala 53:40 55:28]
  wire  _GEN_70 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_wvalid : _GEN_39; // @[axi_arbiter.scala 53:40 55:28]
  wire  _GEN_71 = io_lsu_axi_in_awvalid ? io_lsu_axi_in_bready : _GEN_40; // @[axi_arbiter.scala 53:40 55:28]
  wire [63:0] _GEN_73 = io_lsu_axi_in_awvalid ? io_axi_in_rdata : _GEN_42; // @[axi_arbiter.scala 53:40 56:32]
  wire  _GEN_74 = io_lsu_axi_in_awvalid ? io_axi_in_rlast : _GEN_43; // @[axi_arbiter.scala 53:40 56:32]
  wire  _GEN_75 = io_lsu_axi_in_awvalid | io_lsu_axi_in_arvalid; // @[axi_arbiter.scala 53:40 56:32]
  wire  _GEN_77 = io_lsu_axi_in_awvalid ? io_axi_in_wready : _GEN_46; // @[axi_arbiter.scala 53:40 56:32]
  wire  _GEN_78 = io_lsu_axi_in_awvalid ? io_axi_in_bvalid : _GEN_47; // @[axi_arbiter.scala 53:40 56:32]
  wire [63:0] _GEN_80 = io_lsu_axi_in_awvalid ? 64'h0 : _GEN_49; // @[axi_arbiter.scala 50:20 53:40]
  wire  _GEN_81 = io_lsu_axi_in_awvalid ? 1'h0 : _GEN_50; // @[axi_arbiter.scala 50:20 53:40]
  wire  _GEN_82 = io_lsu_axi_in_awvalid ? 1'h0 : _GEN_51; // @[axi_arbiter.scala 50:20 53:40]
  wire [1:0] _GEN_87 = io_lsu_axi_out_rvalid & io_lsu_axi_out_rlast ? 2'h0 : state; // @[axi_arbiter.scala 77:88 78:23 18:24]
  wire [1:0] _GEN_88 = io_lsu_axi_out_bvalid & io_lsu_axi_in_bready ? 2'h0 : state; // @[axi_arbiter.scala 84:64 85:23 18:24]
  wire [31:0] _GEN_89 = 2'h3 == state ? io_lsu_axi_in_araddr : 32'h0; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire [7:0] _GEN_90 = 2'h3 == state ? io_lsu_axi_in_arlen : 8'h0; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire  _GEN_93 = 2'h3 == state & io_lsu_axi_in_arvalid; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire [31:0] _GEN_95 = 2'h3 == state ? io_lsu_axi_in_awaddr : 32'h0; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire [7:0] _GEN_96 = 2'h3 == state ? io_lsu_axi_in_awlen : 8'h0; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire  _GEN_99 = 2'h3 == state & io_lsu_axi_in_awvalid; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire [63:0] _GEN_100 = 2'h3 == state ? io_lsu_axi_in_wdata : 64'h0; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire [7:0] _GEN_101 = 2'h3 == state ? io_lsu_axi_in_wstrb : 8'h0; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire  _GEN_103 = 2'h3 == state & io_lsu_axi_in_wvalid; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire  _GEN_104 = 2'h3 == state & io_lsu_axi_in_bready; // @[axi_arbiter.scala 48:16 51:18 82:24]
  wire [63:0] _GEN_106 = 2'h3 == state ? io_axi_in_rdata : 64'h0; // @[axi_arbiter.scala 51:18 49:20 83:28]
  wire  _GEN_107 = 2'h3 == state & io_axi_in_rlast; // @[axi_arbiter.scala 51:18 49:20 83:28]
  wire  _GEN_110 = 2'h3 == state & io_axi_in_wready; // @[axi_arbiter.scala 51:18 49:20 83:28]
  wire  _GEN_111 = 2'h3 == state & io_axi_in_bvalid; // @[axi_arbiter.scala 51:18 49:20 83:28]
  wire [1:0] _GEN_112 = 2'h3 == state ? _GEN_88 : state; // @[axi_arbiter.scala 51:18 18:24]
  wire [31:0] _GEN_113 = 2'h2 == state ? io_lsu_axi_in_araddr : _GEN_89; // @[axi_arbiter.scala 51:18 75:24]
  wire [7:0] _GEN_114 = 2'h2 == state ? io_lsu_axi_in_arlen : _GEN_90; // @[axi_arbiter.scala 51:18 75:24]
  wire  _GEN_117 = 2'h2 == state ? io_lsu_axi_in_arvalid : _GEN_93; // @[axi_arbiter.scala 51:18 75:24]
  wire  _GEN_118 = 2'h2 == state | 2'h3 == state; // @[axi_arbiter.scala 51:18 75:24]
  wire [31:0] _GEN_119 = 2'h2 == state ? io_lsu_axi_in_awaddr : _GEN_95; // @[axi_arbiter.scala 51:18 75:24]
  wire [7:0] _GEN_120 = 2'h2 == state ? io_lsu_axi_in_awlen : _GEN_96; // @[axi_arbiter.scala 51:18 75:24]
  wire  _GEN_123 = 2'h2 == state ? io_lsu_axi_in_awvalid : _GEN_99; // @[axi_arbiter.scala 51:18 75:24]
  wire [63:0] _GEN_124 = 2'h2 == state ? io_lsu_axi_in_wdata : _GEN_100; // @[axi_arbiter.scala 51:18 75:24]
  wire [7:0] _GEN_125 = 2'h2 == state ? io_lsu_axi_in_wstrb : _GEN_101; // @[axi_arbiter.scala 51:18 75:24]
  wire  _GEN_127 = 2'h2 == state ? io_lsu_axi_in_wvalid : _GEN_103; // @[axi_arbiter.scala 51:18 75:24]
  wire  _GEN_128 = 2'h2 == state ? io_lsu_axi_in_bready : _GEN_104; // @[axi_arbiter.scala 51:18 75:24]
  wire [63:0] _GEN_130 = 2'h2 == state ? io_axi_in_rdata : _GEN_106; // @[axi_arbiter.scala 51:18 76:28]
  wire  _GEN_131 = 2'h2 == state ? io_axi_in_rlast : _GEN_107; // @[axi_arbiter.scala 51:18 76:28]
  wire  _GEN_134 = 2'h2 == state ? io_axi_in_wready : _GEN_110; // @[axi_arbiter.scala 51:18 76:28]
  wire  _GEN_135 = 2'h2 == state ? io_axi_in_bvalid : _GEN_111; // @[axi_arbiter.scala 51:18 76:28]
  wire [31:0] _GEN_137 = 2'h1 == state ? io_ifu_axi_in_araddr : _GEN_113; // @[axi_arbiter.scala 51:18 68:24]
  wire [7:0] _GEN_138 = 2'h1 == state ? io_ifu_axi_in_arlen : _GEN_114; // @[axi_arbiter.scala 51:18 68:24]
  wire  _GEN_141 = 2'h1 == state ? io_ifu_axi_in_arvalid : _GEN_117; // @[axi_arbiter.scala 51:18 68:24]
  wire  _GEN_142 = 2'h1 == state ? io_ifu_axi_in_rready : _GEN_118; // @[axi_arbiter.scala 51:18 68:24]
  wire [31:0] _GEN_143 = 2'h1 == state ? 32'h0 : _GEN_119; // @[axi_arbiter.scala 51:18 68:24]
  wire [7:0] _GEN_144 = 2'h1 == state ? 8'h0 : _GEN_120; // @[axi_arbiter.scala 51:18 68:24]
  wire  _GEN_147 = 2'h1 == state ? 1'h0 : _GEN_123; // @[axi_arbiter.scala 51:18 68:24]
  wire [63:0] _GEN_148 = 2'h1 == state ? 64'h0 : _GEN_124; // @[axi_arbiter.scala 51:18 68:24]
  wire [7:0] _GEN_149 = 2'h1 == state ? 8'h0 : _GEN_125; // @[axi_arbiter.scala 51:18 68:24]
  wire  _GEN_151 = 2'h1 == state ? 1'h0 : _GEN_127; // @[axi_arbiter.scala 51:18 68:24]
  wire  _GEN_152 = 2'h1 == state ? 1'h0 : _GEN_128; // @[axi_arbiter.scala 51:18 68:24]
  wire [63:0] _GEN_154 = 2'h1 == state ? io_axi_in_rdata : 64'h0; // @[axi_arbiter.scala 51:18 50:20 69:28]
  wire  _GEN_155 = 2'h1 == state & io_axi_in_rlast; // @[axi_arbiter.scala 51:18 50:20 69:28]
  wire [63:0] _GEN_162 = 2'h1 == state ? 64'h0 : _GEN_130; // @[axi_arbiter.scala 51:18 49:20]
  wire  _GEN_163 = 2'h1 == state ? 1'h0 : _GEN_131; // @[axi_arbiter.scala 51:18 49:20]
  wire  _GEN_164 = 2'h1 == state ? 1'h0 : _GEN_118; // @[axi_arbiter.scala 51:18 49:20]
  wire  _GEN_166 = 2'h1 == state ? 1'h0 : _GEN_134; // @[axi_arbiter.scala 51:18 49:20]
  wire  _GEN_167 = 2'h1 == state ? 1'h0 : _GEN_135; // @[axi_arbiter.scala 51:18 49:20]
  assign io_ifu_axi_out_rdata = 2'h0 == state ? _GEN_80 : _GEN_154; // @[axi_arbiter.scala 51:18]
  assign io_ifu_axi_out_rlast = 2'h0 == state ? _GEN_81 : _GEN_155; // @[axi_arbiter.scala 51:18]
  assign io_ifu_axi_out_rvalid = 2'h0 == state ? _GEN_82 : 2'h1 == state; // @[axi_arbiter.scala 51:18]
  assign io_lsu_axi_out_rdata = 2'h0 == state ? _GEN_73 : _GEN_162; // @[axi_arbiter.scala 51:18]
  assign io_lsu_axi_out_rlast = 2'h0 == state ? _GEN_74 : _GEN_163; // @[axi_arbiter.scala 51:18]
  assign io_lsu_axi_out_rvalid = 2'h0 == state ? _GEN_75 : _GEN_164; // @[axi_arbiter.scala 51:18]
  assign io_lsu_axi_out_wready = 2'h0 == state ? _GEN_77 : _GEN_166; // @[axi_arbiter.scala 51:18]
  assign io_lsu_axi_out_bvalid = 2'h0 == state ? _GEN_78 : _GEN_167; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_araddr = 2'h0 == state ? _GEN_56 : _GEN_137; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_arlen = 2'h0 == state ? _GEN_57 : _GEN_138; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_arvalid = 2'h0 == state ? _GEN_60 : _GEN_141; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_rready = 2'h0 == state ? _GEN_61 : _GEN_142; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_awaddr = 2'h0 == state ? _GEN_62 : _GEN_143; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_awlen = 2'h0 == state ? _GEN_63 : _GEN_144; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_awvalid = 2'h0 == state ? _GEN_66 : _GEN_147; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_wdata = 2'h0 == state ? _GEN_67 : _GEN_148; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_wstrb = 2'h0 == state ? _GEN_68 : _GEN_149; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_wvalid = 2'h0 == state ? _GEN_70 : _GEN_151; // @[axi_arbiter.scala 51:18]
  assign io_axi_out_bready = 2'h0 == state ? _GEN_71 : _GEN_152; // @[axi_arbiter.scala 51:18]
  always @(posedge clock) begin
    if (reset) begin // @[axi_arbiter.scala 18:24]
      state <= 2'h0; // @[axi_arbiter.scala 18:24]
    end else if (2'h0 == state) begin // @[axi_arbiter.scala 51:18]
      if (io_lsu_axi_in_awvalid) begin // @[axi_arbiter.scala 53:40]
        state <= 2'h3; // @[axi_arbiter.scala 54:23]
      end else if (io_lsu_axi_in_arvalid) begin // @[axi_arbiter.scala 57:46]
        state <= 2'h2; // @[axi_arbiter.scala 58:23]
      end else begin
        state <= _GEN_0;
      end
    end else if (2'h1 == state) begin // @[axi_arbiter.scala 51:18]
      if (io_ifu_axi_out_rvalid & io_ifu_axi_in_rready & io_ifu_axi_out_rlast) begin // @[axi_arbiter.scala 70:88]
        state <= 2'h0; // @[axi_arbiter.scala 71:23]
      end
    end else if (2'h2 == state) begin // @[axi_arbiter.scala 51:18]
      state <= _GEN_87;
    end else begin
      state <= _GEN_112;
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
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule

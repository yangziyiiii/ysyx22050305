/* verilator lint_off UNOPTFLAT */
module AXI(
  input         clock,
  input         reset,
  input  [31:0] io_axi_in_araddr,
  input  [7:0]  io_axi_in_arlen,
  input         io_axi_in_arvalid,
  input         io_axi_in_rready,
  input  [31:0] io_axi_in_awaddr,
  input  [7:0]  io_axi_in_awlen,
  input         io_axi_in_awvalid,
  input  [63:0] io_axi_in_wdata,
  input  [7:0]  io_axi_in_wstrb,
  input         io_axi_in_wvalid,
  input         io_axi_in_bready,
  output [63:0] io_axi_out_rdata,
  output        io_axi_out_rlast,
  output        io_axi_out_wready,
  output        io_axi_out_bvalid
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  wire [63:0] Mem_modle_Raddr; // @[AXI.scala 30:27]
  wire [63:0] Mem_modle_Rdata; // @[AXI.scala 30:27]
  wire [63:0] Mem_modle_Waddr; // @[AXI.scala 30:27]
  wire [63:0] Mem_modle_Wdata; // @[AXI.scala 30:27]
  wire [7:0] Mem_modle_Wmask; // @[AXI.scala 30:27]
  wire  Mem_modle_Write_en; // @[AXI.scala 30:27]
  wire  Mem_modle_Read_en; // @[AXI.scala 30:27]
  reg  axi_wready; // @[AXI.scala 14:29]
  reg  axi_bvalid; // @[AXI.scala 17:29]
  reg [7:0] arlen; // @[AXI.scala 22:24]
  reg [7:0] awlen; // @[AXI.scala 23:24]
  reg [63:0] araddr; // @[AXI.scala 24:25]
  reg [63:0] awaddr; // @[AXI.scala 25:25]
  reg [2:0] state; // @[AXI.scala 28:24]
  wire  _Mem_modle_io_Raddr_T = state == 3'h0; // @[AXI.scala 31:36]
  wire [7:0] _awlen_T_1 = io_axi_in_awlen - 8'h1; // @[AXI.scala 54:46]
  wire [31:0] _awaddr_T_1 = io_axi_in_awaddr + 32'h8; // @[AXI.scala 55:48]
  wire  _GEN_2 = io_axi_in_awlen == 8'h0 ? 1'h0 : axi_wready; // @[AXI.scala 14:29 44:44 47:32]
  wire  _GEN_3 = io_axi_in_awlen == 8'h0 | axi_bvalid; // @[AXI.scala 17:29 44:44 48:32]
  wire  _T_3 = io_axi_in_arlen == 8'h0; // @[AXI.scala 64:37]
  wire [7:0] _arlen_T_1 = io_axi_in_arlen - 8'h1; // @[AXI.scala 68:46]
  wire [31:0] _araddr_T_1 = io_axi_in_araddr + 32'h8; // @[AXI.scala 69:48]
  wire [2:0] _GEN_6 = io_axi_in_arlen == 8'h0 ? 3'h0 : 3'h1; // @[AXI.scala 64:44 65:27 67:27]
  wire [7:0] _GEN_7 = io_axi_in_arlen == 8'h0 ? arlen : _arlen_T_1; // @[AXI.scala 22:24 64:44 68:27]
  wire [63:0] _GEN_8 = io_axi_in_arlen == 8'h0 ? araddr : {{32'd0}, _araddr_T_1}; // @[AXI.scala 24:25 64:44 69:28]
  wire  _GEN_16 = io_axi_in_awvalid & io_axi_in_wvalid ? _GEN_2 : axi_wready; // @[AXI.scala 14:29 43:56]
  wire [63:0] _awaddr_T_3 = awaddr + 64'h8; // @[AXI.scala 85:38]
  wire [7:0] _awlen_T_3 = awlen - 8'h1; // @[AXI.scala 86:36]
  wire [63:0] _GEN_23 = io_axi_in_wvalid & axi_wready ? _awaddr_T_3 : awaddr; // @[AXI.scala 25:25 84:60 85:28]
  wire [7:0] _GEN_24 = io_axi_in_wvalid & axi_wready ? _awlen_T_3 : awlen; // @[AXI.scala 23:24 84:60 86:27]
  wire  _GEN_25 = awlen == 8'h0 ? 1'h0 : axi_wready; // @[AXI.scala 77:30 78:28 14:29]
  wire  _GEN_27 = awlen == 8'h0 | axi_bvalid; // @[AXI.scala 77:30 81:28 17:29]
  wire  _T_9 = arlen == 8'h0; // @[AXI.scala 91:23]
  wire [2:0] _GEN_31 = io_axi_in_rready ? 3'h0 : state; // @[AXI.scala 28:24 92:39 93:27]
  wire [63:0] _araddr_T_3 = araddr + 64'h8; // @[AXI.scala 99:38]
  wire [7:0] _arlen_T_3 = arlen - 8'h1; // @[AXI.scala 100:36]
  wire [63:0] _GEN_33 = io_axi_in_rready ? _araddr_T_3 : araddr; // @[AXI.scala 24:25 98:39 99:28]
  wire [7:0] _GEN_34 = io_axi_in_rready ? _arlen_T_3 : arlen; // @[AXI.scala 100:27 22:24 98:39]
  wire [2:0] _GEN_35 = arlen == 8'h0 ? _GEN_31 : state; // @[AXI.scala 28:24 91:30]
  wire [63:0] _GEN_37 = arlen == 8'h0 ? araddr : _GEN_33; // @[AXI.scala 24:25 91:30]
  wire [7:0] _GEN_38 = arlen == 8'h0 ? arlen : _GEN_34; // @[AXI.scala 22:24 91:30]
  wire [2:0] _GEN_39 = io_axi_in_bready ? 3'h0 : state; // @[AXI.scala 105:35 106:23 28:24]
  wire  _GEN_40 = io_axi_in_bready ? 1'h0 : axi_bvalid; // @[AXI.scala 105:35 107:28 17:29]
  wire  _GEN_42 = io_axi_in_bready | axi_wready; // @[AXI.scala 105:35 109:28 14:29]
  wire [2:0] _GEN_43 = 3'h3 == state ? _GEN_39 : state; // @[AXI.scala 41:18 28:24]
  wire  _GEN_44 = 3'h3 == state ? _GEN_40 : axi_bvalid; // @[AXI.scala 41:18 17:29]
  wire  _GEN_46 = 3'h3 == state ? _GEN_42 : axi_wready; // @[AXI.scala 41:18 14:29]
  wire  _GEN_53 = 3'h1 == state ? axi_wready : _GEN_46; // @[AXI.scala 41:18 14:29]
  wire  _GEN_54 = 3'h2 == state ? _GEN_25 : _GEN_53; // @[AXI.scala 41:18]
  wire  _GEN_65 = 3'h0 == state ? _GEN_16 : _GEN_54; // @[AXI.scala 41:18]
  MEM Mem_modle ( // @[AXI.scala 30:27]
    .Raddr(Mem_modle_Raddr),
    .Rdata(Mem_modle_Rdata),
    .Waddr(Mem_modle_Waddr),
    .Wdata(Mem_modle_Wdata),
    .Wmask(Mem_modle_Wmask),
    .Write_en(Mem_modle_Write_en),
    .Read_en(Mem_modle_Read_en)
  );
  assign io_axi_out_rdata = Mem_modle_Rdata; // @[AXI.scala 121:22]
  assign io_axi_out_rlast = state == 3'h1 & _T_9 | _T_3; // @[AXI.scala 123:58]
  assign io_axi_out_wready = axi_wready; // @[AXI.scala 125:23]
  assign io_axi_out_bvalid = axi_bvalid; // @[AXI.scala 126:23]
  assign Mem_modle_Raddr = state == 3'h0 ? {{32'd0}, io_axi_in_araddr} : araddr; // @[AXI.scala 31:30]
  assign Mem_modle_Waddr = _Mem_modle_io_Raddr_T ? {{32'd0}, io_axi_in_awaddr} : awaddr; // @[AXI.scala 32:30]
  assign Mem_modle_Wdata = io_axi_in_wdata; // @[AXI.scala 33:24]
  assign Mem_modle_Wmask = io_axi_in_wstrb; // @[AXI.scala 34:24]
  assign Mem_modle_Write_en = axi_wready & io_axi_in_awvalid; // @[AXI.scala 35:48]
  assign Mem_modle_Read_en = io_axi_in_arvalid; // @[AXI.scala 36:47]
  always @(posedge clock) begin
    axi_wready <= reset | _GEN_65; // @[AXI.scala 14:{29,29}]
    if (reset) begin // @[AXI.scala 17:29]
      axi_bvalid <= 1'h0; // @[AXI.scala 17:29]
    end else if (3'h0 == state) begin // @[AXI.scala 41:18]
      if (io_axi_in_awvalid & io_axi_in_wvalid) begin // @[AXI.scala 43:56]
        axi_bvalid <= _GEN_3;
      end
    end else if (3'h2 == state) begin // @[AXI.scala 41:18]
      axi_bvalid <= _GEN_27;
    end else if (!(3'h1 == state)) begin // @[AXI.scala 41:18]
      axi_bvalid <= _GEN_44;
    end
    if (reset) begin // @[AXI.scala 22:24]
      arlen <= 8'h0; // @[AXI.scala 22:24]
    end else if (3'h0 == state) begin // @[AXI.scala 41:18]
      if (!(io_axi_in_awvalid & io_axi_in_wvalid)) begin // @[AXI.scala 43:56]
        if (io_axi_in_arvalid) begin // @[AXI.scala 63:42]
          arlen <= _GEN_7;
        end
      end
    end else if (!(3'h2 == state)) begin // @[AXI.scala 41:18]
      if (3'h1 == state) begin // @[AXI.scala 41:18]
        arlen <= _GEN_38;
      end
    end
    if (reset) begin // @[AXI.scala 23:24]
      awlen <= 8'h0; // @[AXI.scala 23:24]
    end else if (3'h0 == state) begin // @[AXI.scala 41:18]
      if (io_axi_in_awvalid & io_axi_in_wvalid) begin // @[AXI.scala 43:56]
        if (!(io_axi_in_awlen == 8'h0)) begin // @[AXI.scala 44:44]
          awlen <= _awlen_T_1; // @[AXI.scala 54:27]
        end
      end
    end else if (3'h2 == state) begin // @[AXI.scala 41:18]
      if (!(awlen == 8'h0)) begin // @[AXI.scala 77:30]
        awlen <= _GEN_24;
      end
    end
    if (reset) begin // @[AXI.scala 24:25]
      araddr <= 64'h0; // @[AXI.scala 24:25]
    end else if (3'h0 == state) begin // @[AXI.scala 41:18]
      if (!(io_axi_in_awvalid & io_axi_in_wvalid)) begin // @[AXI.scala 43:56]
        if (io_axi_in_arvalid) begin // @[AXI.scala 63:42]
          araddr <= _GEN_8;
        end
      end
    end else if (!(3'h2 == state)) begin // @[AXI.scala 41:18]
      if (3'h1 == state) begin // @[AXI.scala 41:18]
        araddr <= _GEN_37;
      end
    end
    if (reset) begin // @[AXI.scala 25:25]
      awaddr <= 64'h0; // @[AXI.scala 25:25]
    end else if (3'h0 == state) begin // @[AXI.scala 41:18]
      if (io_axi_in_awvalid & io_axi_in_wvalid) begin // @[AXI.scala 43:56]
        if (!(io_axi_in_awlen == 8'h0)) begin // @[AXI.scala 44:44]
          awaddr <= {{32'd0}, _awaddr_T_1}; // @[AXI.scala 55:28]
        end
      end
    end else if (3'h2 == state) begin // @[AXI.scala 41:18]
      if (!(awlen == 8'h0)) begin // @[AXI.scala 77:30]
        awaddr <= _GEN_23;
      end
    end
    if (reset) begin // @[AXI.scala 28:24]
      state <= 3'h0; // @[AXI.scala 28:24]
    end else if (3'h0 == state) begin // @[AXI.scala 41:18]
      if (io_axi_in_awvalid & io_axi_in_wvalid) begin // @[AXI.scala 43:56]
        if (io_axi_in_awlen == 8'h0) begin // @[AXI.scala 44:44]
          state <= 3'h3; // @[AXI.scala 45:27]
        end else begin
          state <= 3'h2; // @[AXI.scala 50:27]
        end
      end else if (io_axi_in_arvalid) begin // @[AXI.scala 63:42]
        state <= _GEN_6;
      end
    end else if (3'h2 == state) begin // @[AXI.scala 41:18]
      if (awlen == 8'h0) begin // @[AXI.scala 77:30]
        state <= 3'h3; // @[AXI.scala 82:23]
      end
    end else if (3'h1 == state) begin // @[AXI.scala 41:18]
      state <= _GEN_35;
    end else begin
      state <= _GEN_43;
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
  axi_wready = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  axi_bvalid = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  arlen = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  awlen = _RAND_3[7:0];
  _RAND_4 = {2{`RANDOM}};
  araddr = _RAND_4[63:0];
  _RAND_5 = {2{`RANDOM}};
  awaddr = _RAND_5[63:0];
  _RAND_6 = {1{`RANDOM}};
  state = _RAND_6[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
/* verilator lint_on UNOPTFLAT */

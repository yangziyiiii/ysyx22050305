module LSU(
  input         clock,
  input         reset,
  input  [63:0] io_pc,
  input         io_es_to_ms_valid,
  output        io_ms_allowin,
  input         io_rf_we,
  input  [4:0]  io_rf_dst,
  input  [63:0] io_alu_res,
  input  [63:0] io_store_data,
  input  [2:0]  io_load_type,
  input         io_wen,
  input  [7:0]  io_wstrb,
  input         io_ren,
  input  [63:0] io_maddr,
  output [63:0] io_to_ws_pc,
  output [63:0] io_ms_final_res,
  output        io_ms_to_ws_valid,
  output        io_to_ws_rf_we,
  output [4:0]  io_to_ws_rf_dst,
  output        io_to_ws_device,
  output        io_ms_valid,
  output        io_ms_rf_we,
  output [4:0]  io_ms_rf_dst,
  output        io_ms_fwd_ready,
  output [63:0] io_ms_fwd_res,
  input  [63:0] io_axi_in_rdata,
  input         io_axi_in_rvalid,
  input         io_axi_in_bvalid,
  output [31:0] io_axi_out_araddr,
  output        io_axi_out_arvalid,
  output [31:0] io_axi_out_awaddr,
  output        io_axi_out_awvalid,
  output [63:0] io_axi_out_wdata,
  output [7:0]  io_axi_out_wstrb,
  output        io_axi_out_wvalid
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [63:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg  ms_valid; // @[LSU.scala 37:27]
  reg [63:0] ms_pc; // @[LSU.scala 38:24]
  reg  ms_rf_we; // @[LSU.scala 42:27]
  reg [4:0] ms_rf_dst; // @[LSU.scala 43:28]
  reg [63:0] ms_res; // @[LSU.scala 44:25]
  reg [63:0] store_data; // @[LSU.scala 46:29]
  reg  wen; // @[LSU.scala 47:22]
  reg [7:0] wstrb; // @[LSU.scala 48:24]
  reg  ren; // @[LSU.scala 49:22]
  reg [63:0] maddr; // @[LSU.scala 50:24]
  reg [2:0] load_type; // @[LSU.scala 51:28]
  wire  ms_ready_go = wen & io_axi_in_bvalid | ren & io_axi_in_rvalid | ~(wen | ren); // @[LSU.scala 71:75]
  wire  ms_allowin = ~ms_valid | ms_ready_go; // @[LSU.scala 72:29]
  wire [31:0] _rdata_T_2 = io_axi_in_rdata[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _rdata_T_4 = {_rdata_T_2,io_axi_in_rdata[31:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rdata_T_7 = {56'h0,io_axi_in_rdata[7:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rdata_T_10 = {32'h0,io_axi_in_rdata[31:0]}; // @[Cat.scala 31:58]
  wire [47:0] _rdata_T_13 = io_axi_in_rdata[15] ? 48'hffffffffffff : 48'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _rdata_T_15 = {_rdata_T_13,io_axi_in_rdata[15:0]}; // @[Cat.scala 31:58]
  wire [55:0] _rdata_T_18 = io_axi_in_rdata[7] ? 56'hffffffffffffff : 56'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _rdata_T_20 = {_rdata_T_18,io_axi_in_rdata[7:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rdata_T_23 = {48'h0,io_axi_in_rdata[15:0]}; // @[Cat.scala 31:58]
  wire [63:0] _rdata_T_25 = 3'h1 == load_type ? _rdata_T_4 : io_axi_in_rdata; // @[Mux.scala 81:58]
  wire [63:0] _rdata_T_27 = 3'h2 == load_type ? io_axi_in_rdata : _rdata_T_25; // @[Mux.scala 81:58]
  wire [63:0] _rdata_T_29 = 3'h3 == load_type ? _rdata_T_7 : _rdata_T_27; // @[Mux.scala 81:58]
  wire [63:0] _rdata_T_31 = 3'h4 == load_type ? _rdata_T_10 : _rdata_T_29; // @[Mux.scala 81:58]
  wire [63:0] _rdata_T_33 = 3'h5 == load_type ? _rdata_T_15 : _rdata_T_31; // @[Mux.scala 81:58]
  wire [63:0] _rdata_T_35 = 3'h6 == load_type ? _rdata_T_20 : _rdata_T_33; // @[Mux.scala 81:58]
  wire [63:0] rdata = 3'h7 == load_type ? _rdata_T_23 : _rdata_T_35; // @[Mux.scala 81:58]
  wire  _io_ms_final_res_T = load_type != 3'h0; // @[LSU.scala 116:37]
  assign io_ms_allowin = ~ms_valid | ms_ready_go; // @[LSU.scala 72:29]
  assign io_to_ws_pc = ms_pc; // @[LSU.scala 120:17]
  assign io_ms_final_res = load_type != 3'h0 ? rdata : ms_res; // @[LSU.scala 116:27]
  assign io_ms_to_ws_valid = ms_valid & ms_ready_go; // @[LSU.scala 73:32]
  assign io_to_ws_rf_we = ms_rf_we; // @[LSU.scala 119:20]
  assign io_to_ws_rf_dst = ms_rf_dst; // @[LSU.scala 118:21]
  assign io_to_ws_device = maddr >= 64'ha0000000 & (ren | wen); // @[LSU.scala 121:50]
  assign io_ms_valid = ms_valid; // @[LSU.scala 123:17]
  assign io_ms_rf_we = ms_rf_we & ms_valid; // @[LSU.scala 125:28]
  assign io_ms_rf_dst = ms_rf_dst; // @[LSU.scala 124:18]
  assign io_ms_fwd_ready = ms_valid & ms_ready_go; // @[LSU.scala 73:32]
  assign io_ms_fwd_res = _io_ms_final_res_T ? rdata : ms_res; // @[LSU.scala 128:25]
  assign io_axi_out_araddr = maddr[31:0]; // @[LSU.scala 89:23]
  assign io_axi_out_arvalid = ren & ms_valid; // @[LSU.scala 90:31]
  assign io_axi_out_awaddr = maddr[31:0]; // @[LSU.scala 95:23]
  assign io_axi_out_awvalid = wen & ms_valid; // @[LSU.scala 96:31]
  assign io_axi_out_wdata = store_data; // @[LSU.scala 100:22]
  assign io_axi_out_wstrb = wstrb; // @[LSU.scala 101:22]
  assign io_axi_out_wvalid = wen; // @[LSU.scala 103:23]
  always @(posedge clock) begin
    if (reset) begin // @[LSU.scala 37:27]
      ms_valid <= 1'h0; // @[LSU.scala 37:27]
    end else if (ms_allowin) begin // @[LSU.scala 54:21]
      ms_valid <= io_es_to_ms_valid; // @[LSU.scala 55:18]
    end
    if (reset) begin // @[LSU.scala 38:24]
      ms_pc <= 64'h0; // @[LSU.scala 38:24]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      ms_pc <= io_pc; // @[LSU.scala 58:15]
    end
    if (reset) begin // @[LSU.scala 42:27]
      ms_rf_we <= 1'h0; // @[LSU.scala 42:27]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      ms_rf_we <= io_rf_we; // @[LSU.scala 59:18]
    end
    if (reset) begin // @[LSU.scala 43:28]
      ms_rf_dst <= 5'h0; // @[LSU.scala 43:28]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      ms_rf_dst <= io_rf_dst; // @[LSU.scala 60:19]
    end
    if (reset) begin // @[LSU.scala 44:25]
      ms_res <= 64'h0; // @[LSU.scala 44:25]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      ms_res <= io_alu_res; // @[LSU.scala 61:16]
    end
    if (reset) begin // @[LSU.scala 46:29]
      store_data <= 64'h0; // @[LSU.scala 46:29]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      store_data <= io_store_data; // @[LSU.scala 62:20]
    end
    if (reset) begin // @[LSU.scala 47:22]
      wen <= 1'h0; // @[LSU.scala 47:22]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      wen <= io_wen; // @[LSU.scala 63:13]
    end
    if (reset) begin // @[LSU.scala 48:24]
      wstrb <= 8'h0; // @[LSU.scala 48:24]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      wstrb <= io_wstrb; // @[LSU.scala 64:15]
    end
    if (reset) begin // @[LSU.scala 49:22]
      ren <= 1'h0; // @[LSU.scala 49:22]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      ren <= io_ren; // @[LSU.scala 65:13]
    end
    if (reset) begin // @[LSU.scala 50:24]
      maddr <= 64'h0; // @[LSU.scala 50:24]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      maddr <= io_maddr; // @[LSU.scala 66:15]
    end
    if (reset) begin // @[LSU.scala 51:28]
      load_type <= 3'h0; // @[LSU.scala 51:28]
    end else if (io_es_to_ms_valid & ms_allowin) begin // @[LSU.scala 57:40]
      load_type <= io_load_type; // @[LSU.scala 67:19]
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
  ms_valid = _RAND_0[0:0];
  _RAND_1 = {2{`RANDOM}};
  ms_pc = _RAND_1[63:0];
  _RAND_2 = {1{`RANDOM}};
  ms_rf_we = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  ms_rf_dst = _RAND_3[4:0];
  _RAND_4 = {2{`RANDOM}};
  ms_res = _RAND_4[63:0];
  _RAND_5 = {2{`RANDOM}};
  store_data = _RAND_5[63:0];
  _RAND_6 = {1{`RANDOM}};
  wen = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  wstrb = _RAND_7[7:0];
  _RAND_8 = {1{`RANDOM}};
  ren = _RAND_8[0:0];
  _RAND_9 = {2{`RANDOM}};
  maddr = _RAND_9[63:0];
  _RAND_10 = {1{`RANDOM}};
  load_type = _RAND_10[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule

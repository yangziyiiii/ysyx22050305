module WBU(
  input         clock,
  input         reset,
  input  [63:0] io_pc,
  input         io_ms_to_ws_valid,
  input  [63:0] io_ms_final_res,
  input         io_rf_we,
  input  [4:0]  io_rf_dst,
  output        io_we,
  output [4:0]  io_waddr,
  output [63:0] io_wdata,
  output        io_ws_valid,
  output        io_ws_rf_we,
  output [4:0]  io_ws_rf_dst,
  output [63:0] io_ws_fwd_res,
  output [63:0] io_ws_pc,
  input         io_device_access,
  output        io_skip
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg  ws_valid; // @[WBU.scala 28:27]
  reg [63:0] ws_pc; // @[WBU.scala 29:24]
  reg  ws_rf_we; // @[WBU.scala 33:27]
  reg [4:0] ws_rf_dst; // @[WBU.scala 34:28]
  reg [63:0] ws_res; // @[WBU.scala 35:25]
  reg  device_access; // @[WBU.scala 36:32]
  assign io_we = ws_rf_we & ws_valid; // @[WBU.scala 66:22]
  assign io_waddr = ws_rf_dst; // @[WBU.scala 67:14]
  assign io_wdata = ws_res; // @[WBU.scala 68:14]
  assign io_ws_valid = ws_valid; // @[WBU.scala 69:17]
  assign io_ws_rf_we = ws_rf_we; // @[WBU.scala 71:17]
  assign io_ws_rf_dst = ws_rf_dst; // @[WBU.scala 70:18]
  assign io_ws_fwd_res = ws_res; // @[WBU.scala 73:19]
  assign io_ws_pc = ws_pc; // @[WBU.scala 74:14]
  assign io_skip = device_access & ws_valid; // @[WBU.scala 75:30]
  always @(posedge clock) begin
    if (reset) begin // @[WBU.scala 28:27]
      ws_valid <= 1'h0; // @[WBU.scala 28:27]
    end else begin
      ws_valid <= io_ms_to_ws_valid;
    end
    if (reset) begin // @[WBU.scala 29:24]
      ws_pc <= 64'h0; // @[WBU.scala 29:24]
    end else if (io_ms_to_ws_valid) begin // @[WBU.scala 47:40]
      ws_pc <= io_pc; // @[WBU.scala 48:15]
    end
    if (reset) begin // @[WBU.scala 33:27]
      ws_rf_we <= 1'h0; // @[WBU.scala 33:27]
    end else if (io_ms_to_ws_valid) begin // @[WBU.scala 47:40]
      ws_rf_we <= io_rf_we; // @[WBU.scala 49:18]
    end
    if (reset) begin // @[WBU.scala 34:28]
      ws_rf_dst <= 5'h0; // @[WBU.scala 34:28]
    end else if (io_ms_to_ws_valid) begin // @[WBU.scala 47:40]
      ws_rf_dst <= io_rf_dst; // @[WBU.scala 50:19]
    end
    if (reset) begin // @[WBU.scala 35:25]
      ws_res <= 64'h0; // @[WBU.scala 35:25]
    end else if (io_ms_to_ws_valid) begin // @[WBU.scala 47:40]
      ws_res <= io_ms_final_res; // @[WBU.scala 51:16]
    end
    if (reset) begin // @[WBU.scala 36:32]
      device_access <= 1'h0; // @[WBU.scala 36:32]
    end else if (io_ms_to_ws_valid) begin // @[WBU.scala 47:40]
      device_access <= io_device_access; // @[WBU.scala 52:23]
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
  ws_valid = _RAND_0[0:0];
  _RAND_1 = {2{`RANDOM}};
  ws_pc = _RAND_1[63:0];
  _RAND_2 = {1{`RANDOM}};
  ws_rf_we = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  ws_rf_dst = _RAND_3[4:0];
  _RAND_4 = {2{`RANDOM}};
  ws_res = _RAND_4[63:0];
  _RAND_5 = {1{`RANDOM}};
  device_access = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule

/* verilator lint_off WIDTH */
module ALU(
  input         clock,
  input         reset,
  input  [63:0] io_src1_value,
  input  [63:0] io_src2_value,
  input  [31:0] io_ALUop,
  input         io_src_valid,
  output        io_alu_busy,
  input         io_res_ready,
  output [63:0] io_alu_res
);
  wire  Mul_clock; // @[ALU.scala 61:28]
  wire  Mul_reset; // @[ALU.scala 61:28]
  wire  Mul_io_mul_valid; // @[ALU.scala 61:28]
  wire  Mul_io_mulw; // @[ALU.scala 61:28]
  wire [63:0] Mul_io_multiplicand; // @[ALU.scala 61:28]
  wire [63:0] Mul_io_multiplier; // @[ALU.scala 61:28]
  wire  Mul_io_out_valid; // @[ALU.scala 61:28]
  wire  Mul_io_out_ready; // @[ALU.scala 61:28]
  wire [31:0] Mul_io_result_hi; // @[ALU.scala 61:28]
  wire [31:0] Mul_io_result_lo; // @[ALU.scala 61:28]
  wire  Div_clock; // @[ALU.scala 62:28]
  wire  Div_reset; // @[ALU.scala 62:28]
  wire [63:0] Div_io_dividend; // @[ALU.scala 62:28]
  wire [63:0] Div_io_divisor; // @[ALU.scala 62:28]
  wire  Div_io_div_valid; // @[ALU.scala 62:28]
  wire  Div_io_divw; // @[ALU.scala 62:28]
  wire  Div_io_div_signed; // @[ALU.scala 62:28]
  wire  Div_io_out_valid; // @[ALU.scala 62:28]
  wire [63:0] Div_io_quotient; // @[ALU.scala 62:28]
  wire [63:0] Div_io_remainder; // @[ALU.scala 62:28]
  wire  mul_valid = 32'h12 == io_ALUop | 32'h11 == io_ALUop; // @[Mux.scala 81:58]
  wire  div_valid = 32'h32 == io_ALUop | (32'h14 == io_ALUop | (32'h33 == io_ALUop | (32'h34 == io_ALUop | (32'h35 ==
    io_ALUop | (32'h13 == io_ALUop | (32'h30 == io_ALUop | 32'h31 == io_ALUop)))))); // @[Mux.scala 81:58]
  wire [63:0] add_res = io_src1_value + io_src2_value; // @[ALU.scala 80:30]
  wire [63:0] sub_res = io_src1_value - io_src2_value; // @[ALU.scala 81:30]
  wire [63:0] sra_res = $signed(io_src1_value) >>> io_src2_value[5:0]; // @[ALU.scala 82:60]
  wire [63:0] srl_res = io_src1_value >> io_src2_value[5:0]; // @[ALU.scala 83:30]
  wire [126:0] _GEN_0 = {{63'd0}, io_src1_value}; // @[ALU.scala 84:30]
  wire [126:0] sll_res = _GEN_0 << io_src2_value[5:0]; // @[ALU.scala 84:30]
  wire [31:0] _sraw_res_T_1 = io_src1_value[31:0]; // @[ALU.scala 85:43]
  wire [31:0] sraw_res = $signed(_sraw_res_T_1) >>> io_src2_value[4:0]; // @[ALU.scala 85:46]
  wire [31:0] srlw_res = io_src1_value[31:0] >> io_src2_value[4:0]; // @[ALU.scala 86:37]
  wire [62:0] _GEN_1 = {{31'd0}, io_src1_value[31:0]}; // @[ALU.scala 87:37]
  wire [62:0] sllw_res = _GEN_1 << io_src2_value[4:0]; // @[ALU.scala 87:37]
  wire [63:0] or_res = io_src1_value | io_src2_value; // @[ALU.scala 88:29]
  wire [63:0] xor_res = io_src1_value ^ io_src2_value; // @[ALU.scala 89:30]
  wire [63:0] and_res = io_src1_value & io_src2_value; // @[ALU.scala 90:30]
  wire [63:0] mlu_res = {Mul_io_result_hi,Mul_io_result_lo}; // @[Cat.scala 31:58]
  wire [31:0] divw_res = Div_io_quotient[31:0]; // @[ALU.scala 93:39]
  wire [31:0] remw_res = Div_io_remainder[31:0]; // @[ALU.scala 95:40]
  wire [63:0] _alu_res_T_1 = io_src1_value + 64'h4; // @[ALU.scala 118:29]
  wire  _alu_res_T_4 = io_src1_value < io_src2_value; // @[ALU.scala 121:33]
  wire  _alu_res_T_8 = $signed(io_src1_value) < $signed(io_src2_value); // @[ALU.scala 123:41]
  wire [31:0] _alu_res_T_12 = add_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _alu_res_T_14 = {_alu_res_T_12,add_res[31:0]}; // @[Cat.scala 31:58]
  wire [31:0] _alu_res_T_17 = sub_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _alu_res_T_19 = {_alu_res_T_17,sub_res[31:0]}; // @[Cat.scala 31:58]
  wire [31:0] _alu_res_T_22 = sllw_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _alu_res_T_24 = {_alu_res_T_22,sllw_res[31:0]}; // @[Cat.scala 31:58]
  wire [31:0] _alu_res_T_27 = sraw_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [31:0] _alu_res_T_28 = $signed(_sraw_res_T_1) >>> io_src2_value[4:0]; // @[ALU.scala 142:55]
  wire [63:0] _alu_res_T_29 = {_alu_res_T_27,_alu_res_T_28}; // @[Cat.scala 31:58]
  wire [31:0] _alu_res_T_32 = srlw_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _alu_res_T_34 = {_alu_res_T_32,srlw_res}; // @[Cat.scala 31:58]
  wire [31:0] _alu_res_T_37 = Mul_io_result_lo[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _alu_res_T_38 = {_alu_res_T_37,Mul_io_result_lo}; // @[Cat.scala 31:58]
  wire [31:0] _alu_res_T_41 = divw_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _alu_res_T_42 = {_alu_res_T_41,divw_res}; // @[Cat.scala 31:58]
  wire [31:0] _alu_res_T_49 = remw_res[31] ? 32'hffffffff : 32'h0; // @[Bitwise.scala 74:12]
  wire [63:0] _alu_res_T_50 = {_alu_res_T_49,remw_res}; // @[Cat.scala 31:58]
  wire [63:0] _alu_res_T_56 = 32'hf == io_ALUop ? add_res : 64'h0; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_58 = 32'h4 == io_ALUop ? io_src2_value : _alu_res_T_56; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_60 = 32'h5 == io_ALUop ? _alu_res_T_1 : _alu_res_T_58; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_62 = 32'h6 == io_ALUop ? _alu_res_T_1 : _alu_res_T_60; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_64 = 32'h1e == io_ALUop ? {{63'd0}, _alu_res_T_4} : _alu_res_T_62; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_66 = 32'h1f == io_ALUop ? {{63'd0}, _alu_res_T_8} : _alu_res_T_64; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_68 = 32'hc == io_ALUop ? _alu_res_T_14 : _alu_res_T_66; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_70 = 32'he == io_ALUop ? sub_res : _alu_res_T_68; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_72 = 32'h15 == io_ALUop ? sra_res : _alu_res_T_70; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_74 = 32'hb == io_ALUop ? or_res : _alu_res_T_72; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_76 = 32'h2e == io_ALUop ? xor_res : _alu_res_T_74; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_78 = 32'h8 == io_ALUop ? and_res : _alu_res_T_76; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_80 = 32'hd == io_ALUop ? _alu_res_T_19 : _alu_res_T_78; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_82 = 32'h16 == io_ALUop ? _alu_res_T_24 : _alu_res_T_80; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_84 = 32'h1c == io_ALUop ? _alu_res_T_29 : _alu_res_T_82; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_86 = 32'h1d == io_ALUop ? _alu_res_T_34 : _alu_res_T_84; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_88 = 32'h11 == io_ALUop ? mlu_res : _alu_res_T_86; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_90 = 32'h12 == io_ALUop ? _alu_res_T_38 : _alu_res_T_88; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_92 = 32'h13 == io_ALUop ? _alu_res_T_42 : _alu_res_T_90; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_94 = 32'h30 == io_ALUop ? Div_io_quotient : _alu_res_T_92; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_96 = 32'h31 == io_ALUop ? Div_io_quotient : _alu_res_T_94; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_98 = 32'h35 == io_ALUop ? _alu_res_T_42 : _alu_res_T_96; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_100 = 32'h14 == io_ALUop ? _alu_res_T_50 : _alu_res_T_98; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_102 = 32'h32 == io_ALUop ? _alu_res_T_50 : _alu_res_T_100; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_104 = 32'h33 == io_ALUop ? Div_io_remainder : _alu_res_T_102; // @[Mux.scala 81:58]
  wire [63:0] _alu_res_T_106 = 32'h34 == io_ALUop ? Div_io_remainder : _alu_res_T_104; // @[Mux.scala 81:58]
  wire [126:0] _alu_res_T_108 = 32'h37 == io_ALUop ? sll_res : {{63'd0}, _alu_res_T_106}; // @[Mux.scala 81:58]
  wire [126:0] _alu_res_T_110 = 32'h39 == io_ALUop ? {{63'd0}, sra_res} : _alu_res_T_108; // @[Mux.scala 81:58]
  wire [126:0] _alu_res_T_112 = 32'h38 == io_ALUop ? {{63'd0}, srl_res} : _alu_res_T_110; // @[Mux.scala 81:58]
  wire [126:0] _alu_res_T_114 = 32'h3f == io_ALUop ? {{63'd0}, io_src1_value} : _alu_res_T_112; // @[Mux.scala 81:58]
  wire [126:0] _alu_res_T_116 = 32'h46 == io_ALUop ? {{63'd0}, io_src1_value} : _alu_res_T_114; // @[Mux.scala 81:58]
  wire [126:0] alu_res = 32'h47 == io_ALUop ? {{63'd0}, io_src1_value} : _alu_res_T_116; // @[Mux.scala 81:58]
  Mul Mul ( // @[ALU.scala 61:28]
    .clock(Mul_clock),
    .reset(Mul_reset),
    .io_mul_valid(Mul_io_mul_valid),
    .io_mulw(Mul_io_mulw),
    .io_multiplicand(Mul_io_multiplicand),
    .io_multiplier(Mul_io_multiplier),
    .io_out_valid(Mul_io_out_valid),
    .io_out_ready(Mul_io_out_ready),
    .io_result_hi(Mul_io_result_hi),
    .io_result_lo(Mul_io_result_lo)
  );
  Div Div ( // @[ALU.scala 62:28]
    .clock(Div_clock),
    .reset(Div_reset),
    .io_dividend(Div_io_dividend),
    .io_divisor(Div_io_divisor),
    .io_div_valid(Div_io_div_valid),
    .io_divw(Div_io_divw),
    .io_div_signed(Div_io_div_signed),
    .io_out_valid(Div_io_out_valid),
    .io_quotient(Div_io_quotient),
    .io_remainder(Div_io_remainder)
  );
  assign io_alu_busy = mul_valid ? ~Mul_io_out_valid : div_valid & ~Div_io_out_valid; // @[ALU.scala 164:23]
  assign io_alu_res = alu_res[63:0]; // @[ALU.scala 165:16]
  assign Mul_clock = clock;
  assign Mul_reset = reset;
  assign Mul_io_mul_valid = mul_valid & io_src_valid; // @[ALU.scala 63:39]
  assign Mul_io_mulw = io_ALUop == 32'h12; // @[ALU.scala 46:22]
  assign Mul_io_multiplicand = io_src1_value; // @[ALU.scala 67:29]
  assign Mul_io_multiplier = io_src2_value; // @[ALU.scala 68:27]
  assign Mul_io_out_ready = io_res_ready; // @[ALU.scala 69:26]
  assign Div_clock = clock;
  assign Div_reset = reset;
  assign Div_io_dividend = io_src1_value; // @[ALU.scala 71:25]
  assign Div_io_divisor = io_src2_value; // @[ALU.scala 72:24]
  assign Div_io_div_valid = div_valid & io_src_valid; // @[ALU.scala 73:39]
  assign Div_io_divw = 32'h32 == io_ALUop | (32'h14 == io_ALUop | (32'h35 == io_ALUop | 32'h13 == io_ALUop)); // @[Mux.scala 81:58]
  assign Div_io_div_signed = 32'h14 == io_ALUop | (32'h34 == io_ALUop | (32'h13 == io_ALUop | 32'h31 == io_ALUop)); // @[Mux.scala 81:58]
endmodule
/* verilator lint_on WIDTH */

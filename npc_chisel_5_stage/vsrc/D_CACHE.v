module D_CACHE(
  input         clock,
  input         reset,
  input  [31:0] io_from_lsu_araddr,
  input         io_from_lsu_arvalid,
  input  [31:0] io_from_lsu_awaddr,
  input         io_from_lsu_awvalid,
  input  [63:0] io_from_lsu_wdata,
  input  [7:0]  io_from_lsu_wstrb,
  input         io_from_lsu_wvalid,
  output [63:0] io_to_lsu_rdata,
  output        io_to_lsu_rvalid,
  output        io_to_lsu_bvalid,
  output [31:0] io_to_axi_araddr,
  output [7:0]  io_to_axi_arlen,
  output        io_to_axi_arvalid,
  output [31:0] io_to_axi_awaddr,
  output [7:0]  io_to_axi_awlen,
  output        io_to_axi_awvalid,
  output [63:0] io_to_axi_wdata,
  output [7:0]  io_to_axi_wstrb,
  output        io_to_axi_wvalid,
  output        io_to_axi_bready,
  input  [63:0] io_from_axi_rdata,
  input         io_from_axi_rlast,
  input         io_from_axi_rvalid,
  input         io_from_axi_wready,
  input         io_from_axi_bvalid
);
`ifdef RANDOMIZE_MEM_INIT
  reg [127:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [127:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [63:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [127:0] cacheLine [0:63]; // @[d_cache.scala 24:24]
  wire  cacheLine_rdata_MPORT_en; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_rdata_MPORT_addr; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_rdata_MPORT_data; // @[d_cache.scala 24:24]
  wire  cacheLine_rdata_MPORT_1_en; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_rdata_MPORT_1_addr; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_rdata_MPORT_1_data; // @[d_cache.scala 24:24]
  wire  cacheLine_ldata_MPORT_en; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_ldata_MPORT_addr; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_ldata_MPORT_data; // @[d_cache.scala 24:24]
  wire  cacheLine_ldata_MPORT_1_en; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_ldata_MPORT_1_addr; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_ldata_MPORT_1_data; // @[d_cache.scala 24:24]
  wire  cacheLine_write_back_data_MPORT_en; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_write_back_data_MPORT_addr; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_write_back_data_MPORT_data; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_MPORT_data; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_MPORT_addr; // @[d_cache.scala 24:24]
  wire  cacheLine_MPORT_mask; // @[d_cache.scala 24:24]
  wire  cacheLine_MPORT_en; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_MPORT_2_data; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_MPORT_2_addr; // @[d_cache.scala 24:24]
  wire  cacheLine_MPORT_2_mask; // @[d_cache.scala 24:24]
  wire  cacheLine_MPORT_2_en; // @[d_cache.scala 24:24]
  wire [127:0] cacheLine_MPORT_7_data; // @[d_cache.scala 24:24]
  wire [5:0] cacheLine_MPORT_7_addr; // @[d_cache.scala 24:24]
  wire  cacheLine_MPORT_7_mask; // @[d_cache.scala 24:24]
  wire  cacheLine_MPORT_7_en; // @[d_cache.scala 24:24]
  reg  validMem [0:63]; // @[d_cache.scala 25:23]
  wire  validMem_valid_0_MPORT_en; // @[d_cache.scala 25:23]
  wire [5:0] validMem_valid_0_MPORT_addr; // @[d_cache.scala 25:23]
  wire  validMem_valid_0_MPORT_data; // @[d_cache.scala 25:23]
  wire  validMem_valid_1_MPORT_en; // @[d_cache.scala 25:23]
  wire [5:0] validMem_valid_1_MPORT_addr; // @[d_cache.scala 25:23]
  wire  validMem_valid_1_MPORT_data; // @[d_cache.scala 25:23]
  wire  validMem_valid_2_MPORT_en; // @[d_cache.scala 25:23]
  wire [5:0] validMem_valid_2_MPORT_addr; // @[d_cache.scala 25:23]
  wire  validMem_valid_2_MPORT_data; // @[d_cache.scala 25:23]
  wire  validMem_valid_3_MPORT_en; // @[d_cache.scala 25:23]
  wire [5:0] validMem_valid_3_MPORT_addr; // @[d_cache.scala 25:23]
  wire  validMem_valid_3_MPORT_data; // @[d_cache.scala 25:23]
  wire  validMem_MPORT_4_data; // @[d_cache.scala 25:23]
  wire [5:0] validMem_MPORT_4_addr; // @[d_cache.scala 25:23]
  wire  validMem_MPORT_4_mask; // @[d_cache.scala 25:23]
  wire  validMem_MPORT_4_en; // @[d_cache.scala 25:23]
  wire  validMem_MPORT_9_data; // @[d_cache.scala 25:23]
  wire [5:0] validMem_MPORT_9_addr; // @[d_cache.scala 25:23]
  wire  validMem_MPORT_9_mask; // @[d_cache.scala 25:23]
  wire  validMem_MPORT_9_en; // @[d_cache.scala 25:23]
  reg [31:0] tagMem [0:63]; // @[d_cache.scala 28:21]
  wire  tagMem_tagMatch_0_MPORT_en; // @[d_cache.scala 28:21]
  wire [5:0] tagMem_tagMatch_0_MPORT_addr; // @[d_cache.scala 28:21]
  wire [31:0] tagMem_tagMatch_0_MPORT_data; // @[d_cache.scala 28:21]
  wire  tagMem_tagMatch_1_MPORT_en; // @[d_cache.scala 28:21]
  wire [5:0] tagMem_tagMatch_1_MPORT_addr; // @[d_cache.scala 28:21]
  wire [31:0] tagMem_tagMatch_1_MPORT_data; // @[d_cache.scala 28:21]
  wire  tagMem_tagMatch_2_MPORT_en; // @[d_cache.scala 28:21]
  wire [5:0] tagMem_tagMatch_2_MPORT_addr; // @[d_cache.scala 28:21]
  wire [31:0] tagMem_tagMatch_2_MPORT_data; // @[d_cache.scala 28:21]
  wire  tagMem_tagMatch_3_MPORT_en; // @[d_cache.scala 28:21]
  wire [5:0] tagMem_tagMatch_3_MPORT_addr; // @[d_cache.scala 28:21]
  wire [31:0] tagMem_tagMatch_3_MPORT_data; // @[d_cache.scala 28:21]
  wire  tagMem_write_back_addr_MPORT_en; // @[d_cache.scala 28:21]
  wire [5:0] tagMem_write_back_addr_MPORT_addr; // @[d_cache.scala 28:21]
  wire [31:0] tagMem_write_back_addr_MPORT_data; // @[d_cache.scala 28:21]
  wire [31:0] tagMem_MPORT_3_data; // @[d_cache.scala 28:21]
  wire [5:0] tagMem_MPORT_3_addr; // @[d_cache.scala 28:21]
  wire  tagMem_MPORT_3_mask; // @[d_cache.scala 28:21]
  wire  tagMem_MPORT_3_en; // @[d_cache.scala 28:21]
  wire [31:0] tagMem_MPORT_8_data; // @[d_cache.scala 28:21]
  wire [5:0] tagMem_MPORT_8_addr; // @[d_cache.scala 28:21]
  wire  tagMem_MPORT_8_mask; // @[d_cache.scala 28:21]
  wire  tagMem_MPORT_8_en; // @[d_cache.scala 28:21]
  reg  dirtyMem [0:63]; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_12_en; // @[d_cache.scala 29:23]
  wire [5:0] dirtyMem_MPORT_12_addr; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_12_data; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_1_data; // @[d_cache.scala 29:23]
  wire [5:0] dirtyMem_MPORT_1_addr; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_1_mask; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_1_en; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_13_data; // @[d_cache.scala 29:23]
  wire [5:0] dirtyMem_MPORT_13_addr; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_13_mask; // @[d_cache.scala 29:23]
  wire  dirtyMem_MPORT_13_en; // @[d_cache.scala 29:23]
  reg [7:0] quene [0:15]; // @[d_cache.scala 77:20]
  wire  quene_replace_way_MPORT_en; // @[d_cache.scala 77:20]
  wire [3:0] quene_replace_way_MPORT_addr; // @[d_cache.scala 77:20]
  wire [7:0] quene_replace_way_MPORT_data; // @[d_cache.scala 77:20]
  wire  quene_MPORT_6_en; // @[d_cache.scala 77:20]
  wire [3:0] quene_MPORT_6_addr; // @[d_cache.scala 77:20]
  wire [7:0] quene_MPORT_6_data; // @[d_cache.scala 77:20]
  wire  quene_MPORT_11_en; // @[d_cache.scala 77:20]
  wire [3:0] quene_MPORT_11_addr; // @[d_cache.scala 77:20]
  wire [7:0] quene_MPORT_11_data; // @[d_cache.scala 77:20]
  wire [7:0] quene_MPORT_5_data; // @[d_cache.scala 77:20]
  wire [3:0] quene_MPORT_5_addr; // @[d_cache.scala 77:20]
  wire  quene_MPORT_5_mask; // @[d_cache.scala 77:20]
  wire  quene_MPORT_5_en; // @[d_cache.scala 77:20]
  wire [7:0] quene_MPORT_10_data; // @[d_cache.scala 77:20]
  wire [3:0] quene_MPORT_10_addr; // @[d_cache.scala 77:20]
  wire  quene_MPORT_10_mask; // @[d_cache.scala 77:20]
  wire  quene_MPORT_10_en; // @[d_cache.scala 77:20]
  wire [3:0] offset = io_from_lsu_araddr[3:0]; // @[d_cache.scala 20:36]
  wire [3:0] index = io_from_lsu_araddr[7:4]; // @[d_cache.scala 21:35]
  wire [23:0] tag = io_from_lsu_araddr[31:8]; // @[d_cache.scala 22:33]
  wire [7:0] _GEN_2 = {{4'd0}, index}; // @[d_cache.scala 41:48]
  wire [8:0] _valid_0_T_1 = {{1'd0}, _GEN_2}; // @[d_cache.scala 41:48]
  wire [7:0] _valid_1_T_2 = 8'h10 + _GEN_2; // @[d_cache.scala 41:48]
  wire [8:0] _GEN_6 = {{5'd0}, index}; // @[d_cache.scala 41:48]
  wire [8:0] _valid_2_T_2 = 9'h20 + _GEN_6; // @[d_cache.scala 41:48]
  wire [8:0] _valid_3_T_2 = 9'h30 + _GEN_6; // @[d_cache.scala 41:48]
  wire  valid_0 = validMem_valid_0_MPORT_data; // @[d_cache.scala 39:21 41:18]
  wire  valid_1 = validMem_valid_1_MPORT_data; // @[d_cache.scala 39:21 41:18]
  wire  valid_2 = validMem_valid_2_MPORT_data; // @[d_cache.scala 39:21 41:18]
  wire  valid_3 = validMem_valid_3_MPORT_data; // @[d_cache.scala 39:21 41:18]
  wire  allvalid = valid_0 & valid_1 & valid_2 & valid_3; // @[d_cache.scala 43:35]
  wire  _foundUnvalidIndex_T = ~valid_0; // @[d_cache.scala 45:10]
  wire  _foundUnvalidIndex_T_1 = ~valid_1; // @[d_cache.scala 46:10]
  wire  _foundUnvalidIndex_T_2 = ~valid_2; // @[d_cache.scala 47:10]
  wire  _foundUnvalidIndex_T_3 = ~valid_3; // @[d_cache.scala 48:10]
  wire [1:0] _foundUnvalidIndex_T_4 = _foundUnvalidIndex_T_3 ? 2'h3 : 2'h0; // @[Mux.scala 101:16]
  wire [1:0] _foundUnvalidIndex_T_5 = _foundUnvalidIndex_T_2 ? 2'h2 : _foundUnvalidIndex_T_4; // @[Mux.scala 101:16]
  wire [1:0] _foundUnvalidIndex_T_6 = _foundUnvalidIndex_T_1 ? 2'h1 : _foundUnvalidIndex_T_5; // @[Mux.scala 101:16]
  wire [1:0] foundUnvalidIndex = _foundUnvalidIndex_T ? 2'h0 : _foundUnvalidIndex_T_6; // @[Mux.scala 101:16]
  wire [5:0] _GEN_11 = {foundUnvalidIndex, 4'h0}; // @[d_cache.scala 50:43]
  wire [8:0] _unvalidIndex_T = {{3'd0}, _GEN_11}; // @[d_cache.scala 50:43]
  wire [8:0] unvalidIndex = _unvalidIndex_T + _GEN_6; // @[d_cache.scala 50:51]
  wire [31:0] _GEN_18 = {{8'd0}, tag}; // @[d_cache.scala 55:71]
  wire  tagMatch_0 = valid_0 & tagMem_tagMatch_0_MPORT_data == _GEN_18; // @[d_cache.scala 55:33]
  wire  tagMatch_1 = valid_1 & tagMem_tagMatch_1_MPORT_data == _GEN_18; // @[d_cache.scala 55:33]
  wire  tagMatch_2 = valid_2 & tagMem_tagMatch_2_MPORT_data == _GEN_18; // @[d_cache.scala 55:33]
  wire  tagMatch_3 = valid_3 & tagMem_tagMatch_3_MPORT_data == _GEN_18; // @[d_cache.scala 55:33]
  wire  anyMatch = tagMatch_0 | tagMatch_1 | tagMatch_2 | tagMatch_3; // @[d_cache.scala 57:38]
  wire [1:0] _foundtagIndex_T = tagMatch_3 ? 2'h3 : 2'h0; // @[Mux.scala 101:16]
  wire [1:0] _foundtagIndex_T_1 = tagMatch_2 ? 2'h2 : _foundtagIndex_T; // @[Mux.scala 101:16]
  wire [1:0] _foundtagIndex_T_2 = tagMatch_1 ? 2'h1 : _foundtagIndex_T_1; // @[Mux.scala 101:16]
  wire [1:0] foundtagIndex = tagMatch_0 ? 2'h0 : _foundtagIndex_T_2; // @[Mux.scala 101:16]
  wire [5:0] _GEN_138 = {foundtagIndex, 4'h0}; // @[d_cache.scala 64:35]
  wire [8:0] _tagIndex_T = {{3'd0}, _GEN_138}; // @[d_cache.scala 64:35]
  wire [8:0] tagIndex = _tagIndex_T + _GEN_6; // @[d_cache.scala 64:43]
  reg [127:0] write_back_data; // @[d_cache.scala 70:34]
  reg [31:0] write_back_addr; // @[d_cache.scala 71:34]
  reg [63:0] receive_data_0; // @[d_cache.scala 75:31]
  reg [63:0] receive_data_1; // @[d_cache.scala 75:31]
  reg [2:0] receive_num; // @[d_cache.scala 76:30]
  wire [1:0] replace_way = quene_replace_way_MPORT_data[7:6]; // @[d_cache.scala 79:35]
  wire [5:0] _GEN_177 = {replace_way, 4'h0}; // @[d_cache.scala 80:34]
  wire [8:0] _replaceIndex_T = {{3'd0}, _GEN_177}; // @[d_cache.scala 80:34]
  wire [8:0] _replaceIndex_T_2 = _replaceIndex_T + _GEN_6; // @[d_cache.scala 80:42]
  wire [5:0] shift_bit_t = {offset[2:0], 3'h0}; // @[d_cache.scala 82:35]
  wire [63:0] _wmask_T_4 = io_from_lsu_wstrb == 8'hff ? 64'hffffffffffffffff : 64'h0; // @[d_cache.scala 92:20]
  wire [63:0] _wmask_T_5 = io_from_lsu_wstrb == 8'hf ? 64'hffffffff : _wmask_T_4; // @[d_cache.scala 91:20]
  wire [63:0] _wmask_T_6 = io_from_lsu_wstrb == 8'h3 ? 64'hffff : _wmask_T_5; // @[d_cache.scala 90:20]
  wire [63:0] wmask = io_from_lsu_wstrb == 8'h1 ? 64'hff : _wmask_T_6; // @[d_cache.scala 89:20]
  wire [126:0] _GEN_247 = {{63'd0}, wmask}; // @[d_cache.scala 94:25]
  wire [126:0] _mask_shift_T = _GEN_247 << shift_bit_t; // @[d_cache.scala 94:25]
  wire [63:0] rdata = offset[3] ? cacheLine_rdata_MPORT_data[127:64] : cacheLine_rdata_MPORT_1_data[63:0]; // @[d_cache.scala 95:17]
  wire [63:0] ldata = offset[3] ? cacheLine_ldata_MPORT_data[63:0] : cacheLine_ldata_MPORT_1_data[127:64]; // @[d_cache.scala 96:17]
  wire [63:0] _change_data_T = io_from_lsu_wdata & wmask; // @[d_cache.scala 97:40]
  wire [126:0] _GEN_250 = {{63'd0}, _change_data_T}; // @[d_cache.scala 97:49]
  wire [126:0] _change_data_T_1 = _GEN_250 << shift_bit_t; // @[d_cache.scala 97:49]
  wire [63:0] mask_shift = _mask_shift_T[63:0]; // @[d_cache.scala 93:26 94:16]
  wire [63:0] _change_data_T_2 = ~mask_shift; // @[d_cache.scala 97:76]
  wire [63:0] _change_data_T_3 = rdata & _change_data_T_2; // @[d_cache.scala 97:74]
  wire [126:0] _GEN_185 = {{63'd0}, _change_data_T_3}; // @[d_cache.scala 97:65]
  wire [126:0] _change_data_T_4 = _change_data_T_1 | _GEN_185; // @[d_cache.scala 97:65]
  reg [2:0] state; // @[d_cache.scala 103:24]
  wire  _T = 3'h0 == state; // @[d_cache.scala 132:18]
  wire  _T_3 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000; // @[d_cache.scala 134:60]
  wire [2:0] _GEN_0 = io_from_lsu_awvalid ? 3'h2 : state; // @[d_cache.scala 140:44 141:23 103:24]
  wire [63:0] _GEN_3 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 ?
    io_from_axi_rdata : 64'h0; // @[d_cache.scala 109:21 134:99 135:27]
  wire  _GEN_5 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 & io_from_axi_rvalid; // @[d_cache.scala 111:22 134:99 135:27]
  wire  _GEN_8 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 & io_from_axi_bvalid; // @[d_cache.scala 114:22 134:99 135:27]
  wire  _GEN_13 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 & io_from_lsu_arvalid
    ; // @[d_cache.scala 116:23 134:99 136:27]
  wire [31:0] _GEN_15 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 ?
    io_from_lsu_awaddr : 32'h0; // @[d_cache.scala 122:22 134:99 136:27]
  wire  _GEN_19 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 & io_from_lsu_awvalid
    ; // @[d_cache.scala 123:23 134:99 136:27]
  wire [63:0] _GEN_20 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 ?
    io_from_lsu_wdata : 64'h0; // @[d_cache.scala 127:21 134:99 136:27]
  wire [7:0] _GEN_21 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 ?
    io_from_lsu_wstrb : 8'h0; // @[d_cache.scala 128:21 134:99 136:27]
  wire  _GEN_23 = (io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000 & io_from_lsu_wvalid; // @[d_cache.scala 130:22 134:99 136:27]
  wire [63:0] _io_to_lsu_rdata_T = rdata >> shift_bit_t; // @[d_cache.scala 145:38]
  wire [63:0] change_data = _change_data_T_4[63:0]; // @[d_cache.scala 85:27 97:17]
  wire [127:0] _T_9 = {change_data,ldata}; // @[Cat.scala 31:58]
  wire [127:0] _T_10 = {ldata,change_data}; // @[Cat.scala 31:58]
  wire [2:0] _GEN_30 = anyMatch ? 3'h0 : 3'h4; // @[d_cache.scala 161:27 171:23]
  wire [63:0] _GEN_189 = {{32'd0}, io_from_lsu_araddr}; // @[d_cache.scala 176:53]
  wire [63:0] _io_to_axi_araddr_T = _GEN_189 & 64'hfffffffffffffff0; // @[d_cache.scala 176:53]
  wire [63:0] _GEN_37 = ~receive_num[0] ? io_from_axi_rdata : receive_data_0; // @[d_cache.scala 182:{43,43} 75:31]
  wire [63:0] _GEN_38 = receive_num[0] ? io_from_axi_rdata : receive_data_1; // @[d_cache.scala 182:{43,43} 75:31]
  wire [2:0] _receive_num_T_1 = receive_num + 3'h1; // @[d_cache.scala 183:44]
  wire [2:0] _GEN_39 = io_from_axi_rlast ? 3'h5 : state; // @[d_cache.scala 103:24 184:40 185:27]
  wire [63:0] _GEN_40 = io_from_axi_rvalid ? _GEN_37 : receive_data_0; // @[d_cache.scala 181:37 75:31]
  wire [63:0] _GEN_41 = io_from_axi_rvalid ? _GEN_38 : receive_data_1; // @[d_cache.scala 181:37 75:31]
  wire [2:0] _GEN_42 = io_from_axi_rvalid ? _receive_num_T_1 : receive_num; // @[d_cache.scala 181:37 183:29 76:30]
  wire [2:0] _GEN_43 = io_from_axi_rvalid ? _GEN_39 : state; // @[d_cache.scala 103:24 181:37]
  wire [2:0] _GEN_44 = io_from_axi_bvalid ? 3'h0 : state; // @[d_cache.scala 203:59 204:23 103:24]
  wire  _T_18 = ~allvalid; // @[d_cache.scala 208:18]
  wire [9:0] _GEN_190 = {quene_MPORT_6_data, 2'h0}; // @[d_cache.scala 216:47]
  wire [10:0] _T_23 = {{1'd0}, _GEN_190}; // @[d_cache.scala 216:47]
  wire [10:0] _GEN_193 = {{9'd0}, foundUnvalidIndex}; // @[d_cache.scala 216:55]
  wire [10:0] _T_24 = _T_23 | _GEN_193; // @[d_cache.scala 216:55]
  wire [31:0] replaceIndex = {{23'd0}, _replaceIndex_T_2}; // @[d_cache.scala 66:28 80:18]
  wire [9:0] _GEN_226 = {quene_MPORT_11_data, 2'h0}; // @[d_cache.scala 221:47]
  wire [10:0] _T_29 = {{1'd0}, _GEN_226}; // @[d_cache.scala 221:47]
  wire [10:0] _GEN_227 = {{9'd0}, replace_way}; // @[d_cache.scala 221:55]
  wire [10:0] _T_30 = _T_29 | _GEN_227; // @[d_cache.scala 221:55]
  wire  _T_32 = dirtyMem_MPORT_12_data; // @[d_cache.scala 222:44]
  wire [39:0] _write_back_addr_T_2 = {tagMem_write_back_addr_MPORT_data,index,4'h0}; // @[Cat.scala 31:58]
  wire [127:0] _GEN_48 = dirtyMem_MPORT_12_data ? cacheLine_write_back_data_MPORT_data : write_back_data; // @[d_cache.scala 222:51 224:37 70:34]
  wire [39:0] _GEN_50 = dirtyMem_MPORT_12_data ? _write_back_addr_T_2 : {{8'd0}, write_back_addr}; // @[d_cache.scala 222:51 225:37 71:34]
  wire [2:0] _GEN_54 = dirtyMem_MPORT_12_data ? 3'h6 : 3'h1; // @[d_cache.scala 222:51 227:27 229:27]
  wire [2:0] _GEN_55 = ~allvalid ? 3'h1 : _GEN_54; // @[d_cache.scala 208:28 209:23]
  wire  _GEN_68 = ~allvalid ? 1'h0 : 1'h1; // @[d_cache.scala 208:28 24:24 218:26]
  wire  _GEN_79 = ~allvalid ? 1'h0 : _T_32; // @[d_cache.scala 208:28 24:24]
  wire [127:0] _GEN_80 = ~allvalid ? write_back_data : _GEN_48; // @[d_cache.scala 208:28 70:34]
  wire [39:0] _GEN_82 = ~allvalid ? {{8'd0}, write_back_addr} : _GEN_50; // @[d_cache.scala 208:28 71:34]
  wire [127:0] _write_back_data_T_1 = {{64'd0}, write_back_data[127:64]}; // @[d_cache.scala 245:52]
  wire [127:0] _GEN_86 = io_from_axi_wready ? _write_back_data_T_1 : write_back_data; // @[d_cache.scala 244:37 245:33 70:34]
  wire [2:0] _GEN_87 = io_from_axi_bvalid ? 3'h1 : state; // @[d_cache.scala 247:37 248:23 103:24]
  wire [31:0] _GEN_88 = 3'h6 == state ? write_back_addr : 32'h0; // @[d_cache.scala 132:18 122:22 234:30]
  wire [63:0] _GEN_91 = 3'h6 == state ? write_back_data[63:0] : 64'h0; // @[d_cache.scala 132:18 127:21 239:29]
  wire [7:0] _GEN_92 = 3'h6 == state ? 8'hff : 8'h0; // @[d_cache.scala 132:18 128:21 240:29]
  wire [127:0] _GEN_93 = 3'h6 == state ? _GEN_86 : write_back_data; // @[d_cache.scala 132:18 70:34]
  wire [2:0] _GEN_94 = 3'h6 == state ? _GEN_87 : state; // @[d_cache.scala 132:18 103:24]
  wire [2:0] _GEN_95 = 3'h5 == state ? _GEN_55 : _GEN_94; // @[d_cache.scala 132:18]
  wire [127:0] _GEN_120 = 3'h5 == state ? _GEN_80 : _GEN_93; // @[d_cache.scala 132:18]
  wire [39:0] _GEN_122 = 3'h5 == state ? _GEN_82 : {{8'd0}, write_back_addr}; // @[d_cache.scala 132:18 71:34]
  wire [31:0] _GEN_126 = 3'h5 == state ? 32'h0 : _GEN_88; // @[d_cache.scala 132:18 122:22]
  wire  _GEN_127 = 3'h5 == state ? 1'h0 : 3'h6 == state; // @[d_cache.scala 132:18 123:23]
  wire [63:0] _GEN_129 = 3'h5 == state ? 64'h0 : _GEN_91; // @[d_cache.scala 132:18 127:21]
  wire [7:0] _GEN_130 = 3'h5 == state ? 8'h0 : _GEN_92; // @[d_cache.scala 132:18 128:21]
  wire  _GEN_132 = 3'h4 == state & io_from_axi_bvalid; // @[d_cache.scala 132:18 114:22 191:30]
  wire [31:0] _GEN_134 = 3'h4 == state ? io_from_lsu_awaddr : _GEN_126; // @[d_cache.scala 132:18 193:30]
  wire  _GEN_135 = 3'h4 == state ? io_from_lsu_awvalid : _GEN_127; // @[d_cache.scala 132:18 194:31]
  wire [7:0] _GEN_136 = 3'h4 == state ? 8'h0 : {{7'd0}, _GEN_127}; // @[d_cache.scala 132:18 195:29]
  wire [63:0] _GEN_139 = 3'h4 == state ? io_from_lsu_wdata : _GEN_129; // @[d_cache.scala 132:18 198:29]
  wire [7:0] _GEN_140 = 3'h4 == state ? io_from_lsu_wstrb : _GEN_130; // @[d_cache.scala 132:18 199:29]
  wire  _GEN_142 = 3'h4 == state ? io_from_lsu_wvalid : _GEN_127; // @[d_cache.scala 132:18 201:30]
  wire  _GEN_143 = 3'h4 == state | _GEN_127; // @[d_cache.scala 132:18 202:30]
  wire [2:0] _GEN_144 = 3'h4 == state ? _GEN_44 : _GEN_95; // @[d_cache.scala 132:18]
  wire  _GEN_147 = 3'h4 == state ? 1'h0 : 3'h5 == state & _T_18; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_157 = 3'h4 == state ? 1'h0 : 3'h5 == state & _GEN_68; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_168 = 3'h4 == state ? 1'h0 : 3'h5 == state & _GEN_79; // @[d_cache.scala 132:18 24:24]
  wire [127:0] _GEN_169 = 3'h4 == state ? write_back_data : _GEN_120; // @[d_cache.scala 132:18 70:34]
  wire [39:0] _GEN_171 = 3'h4 == state ? {{8'd0}, write_back_addr} : _GEN_122; // @[d_cache.scala 132:18 71:34]
  wire [63:0] _GEN_176 = 3'h3 == state ? _io_to_axi_araddr_T : {{32'd0}, io_from_lsu_araddr}; // @[d_cache.scala 132:18 117:22 176:30]
  wire [63:0] _GEN_179 = 3'h3 == state ? _GEN_40 : receive_data_0; // @[d_cache.scala 132:18 75:31]
  wire [63:0] _GEN_180 = 3'h3 == state ? _GEN_41 : receive_data_1; // @[d_cache.scala 132:18 75:31]
  wire [2:0] _GEN_181 = 3'h3 == state ? _GEN_42 : receive_num; // @[d_cache.scala 132:18 76:30]
  wire [2:0] _GEN_182 = 3'h3 == state ? _GEN_43 : _GEN_144; // @[d_cache.scala 132:18]
  wire  _GEN_184 = 3'h3 == state ? 1'h0 : _GEN_132; // @[d_cache.scala 132:18 114:22]
  wire [31:0] _GEN_186 = 3'h3 == state ? 32'h0 : _GEN_134; // @[d_cache.scala 132:18 122:22]
  wire  _GEN_187 = 3'h3 == state ? 1'h0 : _GEN_135; // @[d_cache.scala 132:18 123:23]
  wire [7:0] _GEN_188 = 3'h3 == state ? 8'h0 : _GEN_136; // @[d_cache.scala 132:18 124:21]
  wire [63:0] _GEN_191 = 3'h3 == state ? 64'h0 : _GEN_139; // @[d_cache.scala 132:18 127:21]
  wire [7:0] _GEN_192 = 3'h3 == state ? 8'h0 : _GEN_140; // @[d_cache.scala 132:18 128:21]
  wire  _GEN_194 = 3'h3 == state ? 1'h0 : _GEN_142; // @[d_cache.scala 132:18 130:22]
  wire  _GEN_195 = 3'h3 == state ? 1'h0 : _GEN_143; // @[d_cache.scala 132:18 131:22]
  wire  _GEN_198 = 3'h3 == state ? 1'h0 : _GEN_147; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_208 = 3'h3 == state ? 1'h0 : _GEN_157; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_219 = 3'h3 == state ? 1'h0 : _GEN_168; // @[d_cache.scala 132:18 24:24]
  wire [127:0] _GEN_220 = 3'h3 == state ? write_back_data : _GEN_169; // @[d_cache.scala 132:18 70:34]
  wire [39:0] _GEN_222 = 3'h3 == state ? {{8'd0}, write_back_addr} : _GEN_171; // @[d_cache.scala 132:18 71:34]
  wire  _GEN_228 = 3'h2 == state ? anyMatch : _GEN_184; // @[d_cache.scala 132:18 160:30]
  wire  _GEN_236 = 3'h2 == state ? 1'h0 : 3'h3 == state; // @[d_cache.scala 132:18 116:23]
  wire [63:0] _GEN_237 = 3'h2 == state ? {{32'd0}, io_from_lsu_araddr} : _GEN_176; // @[d_cache.scala 132:18 117:22]
  wire [31:0] _GEN_243 = 3'h2 == state ? 32'h0 : _GEN_186; // @[d_cache.scala 132:18 122:22]
  wire  _GEN_244 = 3'h2 == state ? 1'h0 : _GEN_187; // @[d_cache.scala 132:18 123:23]
  wire [7:0] _GEN_245 = 3'h2 == state ? 8'h0 : _GEN_188; // @[d_cache.scala 132:18 124:21]
  wire [63:0] _GEN_248 = 3'h2 == state ? 64'h0 : _GEN_191; // @[d_cache.scala 132:18 127:21]
  wire [7:0] _GEN_249 = 3'h2 == state ? 8'h0 : _GEN_192; // @[d_cache.scala 132:18 128:21]
  wire  _GEN_251 = 3'h2 == state ? 1'h0 : _GEN_194; // @[d_cache.scala 132:18 130:22]
  wire  _GEN_252 = 3'h2 == state ? 1'h0 : _GEN_195; // @[d_cache.scala 132:18 131:22]
  wire  _GEN_255 = 3'h2 == state ? 1'h0 : _GEN_198; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_265 = 3'h2 == state ? 1'h0 : _GEN_208; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_276 = 3'h2 == state ? 1'h0 : _GEN_219; // @[d_cache.scala 132:18 24:24]
  wire [39:0] _GEN_279 = 3'h2 == state ? {{8'd0}, write_back_addr} : _GEN_222; // @[d_cache.scala 132:18 71:34]
  wire [63:0] _GEN_283 = 3'h1 == state ? _io_to_lsu_rdata_T : 64'h0; // @[d_cache.scala 132:18 109:21 145:29]
  wire  _GEN_284 = 3'h1 == state & anyMatch; // @[d_cache.scala 132:18 111:22 146:30]
  wire  _GEN_290 = 3'h1 == state ? 1'h0 : _GEN_228; // @[d_cache.scala 132:18 114:22]
  wire  _GEN_293 = 3'h1 == state ? 1'h0 : 3'h2 == state & anyMatch; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_297 = 3'h1 == state ? 1'h0 : _GEN_236; // @[d_cache.scala 132:18 116:23]
  wire [63:0] _GEN_298 = 3'h1 == state ? {{32'd0}, io_from_lsu_araddr} : _GEN_237; // @[d_cache.scala 132:18 117:22]
  wire [31:0] _GEN_303 = 3'h1 == state ? 32'h0 : _GEN_243; // @[d_cache.scala 132:18 122:22]
  wire  _GEN_304 = 3'h1 == state ? 1'h0 : _GEN_244; // @[d_cache.scala 132:18 123:23]
  wire [7:0] _GEN_305 = 3'h1 == state ? 8'h0 : _GEN_245; // @[d_cache.scala 132:18 124:21]
  wire [63:0] _GEN_308 = 3'h1 == state ? 64'h0 : _GEN_248; // @[d_cache.scala 132:18 127:21]
  wire [7:0] _GEN_309 = 3'h1 == state ? 8'h0 : _GEN_249; // @[d_cache.scala 132:18 128:21]
  wire  _GEN_311 = 3'h1 == state ? 1'h0 : _GEN_251; // @[d_cache.scala 132:18 130:22]
  wire  _GEN_312 = 3'h1 == state ? 1'h0 : _GEN_252; // @[d_cache.scala 132:18 131:22]
  wire  _GEN_315 = 3'h1 == state ? 1'h0 : _GEN_255; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_325 = 3'h1 == state ? 1'h0 : _GEN_265; // @[d_cache.scala 132:18 24:24]
  wire  _GEN_336 = 3'h1 == state ? 1'h0 : _GEN_276; // @[d_cache.scala 132:18 24:24]
  wire [39:0] _GEN_339 = 3'h1 == state ? {{8'd0}, write_back_addr} : _GEN_279; // @[d_cache.scala 132:18 71:34]
  wire [63:0] _GEN_350 = 3'h0 == state ? {{32'd0}, io_from_lsu_araddr} : _GEN_298; // @[d_cache.scala 132:18]
  wire [39:0] _GEN_402 = 3'h0 == state ? {{8'd0}, write_back_addr} : _GEN_339; // @[d_cache.scala 132:18 71:34]
  wire [39:0] _GEN_246 = reset ? 40'h0 : _GEN_402; // @[d_cache.scala 71:{34,34}]
  assign cacheLine_rdata_MPORT_en = 1'h1;
  assign cacheLine_rdata_MPORT_addr = tagIndex[5:0];
  assign cacheLine_rdata_MPORT_data = cacheLine[cacheLine_rdata_MPORT_addr]; // @[d_cache.scala 24:24]
  assign cacheLine_rdata_MPORT_1_en = 1'h1;
  assign cacheLine_rdata_MPORT_1_addr = tagIndex[5:0];
  assign cacheLine_rdata_MPORT_1_data = cacheLine[cacheLine_rdata_MPORT_1_addr]; // @[d_cache.scala 24:24]
  assign cacheLine_ldata_MPORT_en = 1'h1;
  assign cacheLine_ldata_MPORT_addr = tagIndex[5:0];
  assign cacheLine_ldata_MPORT_data = cacheLine[cacheLine_ldata_MPORT_addr]; // @[d_cache.scala 24:24]
  assign cacheLine_ldata_MPORT_1_en = 1'h1;
  assign cacheLine_ldata_MPORT_1_addr = tagIndex[5:0];
  assign cacheLine_ldata_MPORT_1_data = cacheLine[cacheLine_ldata_MPORT_1_addr]; // @[d_cache.scala 24:24]
  assign cacheLine_write_back_data_MPORT_en = _T ? 1'h0 : _GEN_336;
  assign cacheLine_write_back_data_MPORT_addr = replaceIndex[5:0];
  assign cacheLine_write_back_data_MPORT_data = cacheLine[cacheLine_write_back_data_MPORT_addr]; // @[d_cache.scala 24:24]
  assign cacheLine_MPORT_data = offset[3] ? _T_9 : _T_10;
  assign cacheLine_MPORT_addr = tagIndex[5:0];
  assign cacheLine_MPORT_mask = 1'h1;
  assign cacheLine_MPORT_en = _T ? 1'h0 : _GEN_293;
  assign cacheLine_MPORT_2_data = {receive_data_1,receive_data_0};
  assign cacheLine_MPORT_2_addr = unvalidIndex[5:0];
  assign cacheLine_MPORT_2_mask = 1'h1;
  assign cacheLine_MPORT_2_en = _T ? 1'h0 : _GEN_315;
  assign cacheLine_MPORT_7_data = {receive_data_1,receive_data_0};
  assign cacheLine_MPORT_7_addr = replaceIndex[5:0];
  assign cacheLine_MPORT_7_mask = 1'h1;
  assign cacheLine_MPORT_7_en = _T ? 1'h0 : _GEN_325;
  assign validMem_valid_0_MPORT_en = 1'h1;
  assign validMem_valid_0_MPORT_addr = _valid_0_T_1[5:0];
  assign validMem_valid_0_MPORT_data = validMem[validMem_valid_0_MPORT_addr]; // @[d_cache.scala 25:23]
  assign validMem_valid_1_MPORT_en = 1'h1;
  assign validMem_valid_1_MPORT_addr = _valid_1_T_2[5:0];
  assign validMem_valid_1_MPORT_data = validMem[validMem_valid_1_MPORT_addr]; // @[d_cache.scala 25:23]
  assign validMem_valid_2_MPORT_en = 1'h1;
  assign validMem_valid_2_MPORT_addr = _valid_2_T_2[5:0];
  assign validMem_valid_2_MPORT_data = validMem[validMem_valid_2_MPORT_addr]; // @[d_cache.scala 25:23]
  assign validMem_valid_3_MPORT_en = 1'h1;
  assign validMem_valid_3_MPORT_addr = _valid_3_T_2[5:0];
  assign validMem_valid_3_MPORT_data = validMem[validMem_valid_3_MPORT_addr]; // @[d_cache.scala 25:23]
  assign validMem_MPORT_4_data = 1'h1;
  assign validMem_MPORT_4_addr = unvalidIndex[5:0];
  assign validMem_MPORT_4_mask = 1'h1;
  assign validMem_MPORT_4_en = _T ? 1'h0 : _GEN_315;
  assign validMem_MPORT_9_data = 1'h1;
  assign validMem_MPORT_9_addr = replaceIndex[5:0];
  assign validMem_MPORT_9_mask = 1'h1;
  assign validMem_MPORT_9_en = _T ? 1'h0 : _GEN_325;
  assign tagMem_tagMatch_0_MPORT_en = 1'h1;
  assign tagMem_tagMatch_0_MPORT_addr = _valid_0_T_1[5:0];
  assign tagMem_tagMatch_0_MPORT_data = tagMem[tagMem_tagMatch_0_MPORT_addr]; // @[d_cache.scala 28:21]
  assign tagMem_tagMatch_1_MPORT_en = 1'h1;
  assign tagMem_tagMatch_1_MPORT_addr = _valid_1_T_2[5:0];
  assign tagMem_tagMatch_1_MPORT_data = tagMem[tagMem_tagMatch_1_MPORT_addr]; // @[d_cache.scala 28:21]
  assign tagMem_tagMatch_2_MPORT_en = 1'h1;
  assign tagMem_tagMatch_2_MPORT_addr = _valid_2_T_2[5:0];
  assign tagMem_tagMatch_2_MPORT_data = tagMem[tagMem_tagMatch_2_MPORT_addr]; // @[d_cache.scala 28:21]
  assign tagMem_tagMatch_3_MPORT_en = 1'h1;
  assign tagMem_tagMatch_3_MPORT_addr = _valid_3_T_2[5:0];
  assign tagMem_tagMatch_3_MPORT_data = tagMem[tagMem_tagMatch_3_MPORT_addr]; // @[d_cache.scala 28:21]
  assign tagMem_write_back_addr_MPORT_en = _T ? 1'h0 : _GEN_336;
  assign tagMem_write_back_addr_MPORT_addr = replaceIndex[5:0];
  assign tagMem_write_back_addr_MPORT_data = tagMem[tagMem_write_back_addr_MPORT_addr]; // @[d_cache.scala 28:21]
  assign tagMem_MPORT_3_data = {{8'd0}, tag};
  assign tagMem_MPORT_3_addr = unvalidIndex[5:0];
  assign tagMem_MPORT_3_mask = 1'h1;
  assign tagMem_MPORT_3_en = _T ? 1'h0 : _GEN_315;
  assign tagMem_MPORT_8_data = {{8'd0}, tag};
  assign tagMem_MPORT_8_addr = replaceIndex[5:0];
  assign tagMem_MPORT_8_mask = 1'h1;
  assign tagMem_MPORT_8_en = _T ? 1'h0 : _GEN_325;
  assign dirtyMem_MPORT_12_en = _T ? 1'h0 : _GEN_325;
  assign dirtyMem_MPORT_12_addr = replaceIndex[5:0];
  assign dirtyMem_MPORT_12_data = dirtyMem[dirtyMem_MPORT_12_addr]; // @[d_cache.scala 29:23]
  assign dirtyMem_MPORT_1_data = 1'h1;
  assign dirtyMem_MPORT_1_addr = tagIndex[5:0];
  assign dirtyMem_MPORT_1_mask = 1'h1;
  assign dirtyMem_MPORT_1_en = _T ? 1'h0 : _GEN_293;
  assign dirtyMem_MPORT_13_data = 1'h0;
  assign dirtyMem_MPORT_13_addr = replaceIndex[5:0];
  assign dirtyMem_MPORT_13_mask = 1'h1;
  assign dirtyMem_MPORT_13_en = _T ? 1'h0 : _GEN_336;
  assign quene_replace_way_MPORT_en = 1'h1;
  assign quene_replace_way_MPORT_addr = io_from_lsu_araddr[7:4];
  assign quene_replace_way_MPORT_data = quene[quene_replace_way_MPORT_addr]; // @[d_cache.scala 77:20]
  assign quene_MPORT_6_en = _T ? 1'h0 : _GEN_315;
  assign quene_MPORT_6_addr = io_from_lsu_araddr[7:4];
  assign quene_MPORT_6_data = quene[quene_MPORT_6_addr]; // @[d_cache.scala 77:20]
  assign quene_MPORT_11_en = _T ? 1'h0 : _GEN_325;
  assign quene_MPORT_11_addr = io_from_lsu_araddr[7:4];
  assign quene_MPORT_11_data = quene[quene_MPORT_11_addr]; // @[d_cache.scala 77:20]
  assign quene_MPORT_5_data = _T_24[7:0];
  assign quene_MPORT_5_addr = io_from_lsu_araddr[7:4];
  assign quene_MPORT_5_mask = 1'h1;
  assign quene_MPORT_5_en = _T ? 1'h0 : _GEN_315;
  assign quene_MPORT_10_data = _T_30[7:0];
  assign quene_MPORT_10_addr = io_from_lsu_araddr[7:4];
  assign quene_MPORT_10_mask = 1'h1;
  assign quene_MPORT_10_en = _T ? 1'h0 : _GEN_325;
  assign io_to_lsu_rdata = 3'h0 == state ? _GEN_3 : _GEN_283; // @[d_cache.scala 132:18]
  assign io_to_lsu_rvalid = 3'h0 == state ? _GEN_5 : _GEN_284; // @[d_cache.scala 132:18]
  assign io_to_lsu_bvalid = 3'h0 == state ? _GEN_8 : _GEN_290; // @[d_cache.scala 132:18]
  assign io_to_axi_araddr = _GEN_350[31:0];
  assign io_to_axi_arlen = 3'h0 == state ? 8'h0 : {{7'd0}, _GEN_297}; // @[d_cache.scala 132:18]
  assign io_to_axi_arvalid = 3'h0 == state ? _GEN_13 : _GEN_297; // @[d_cache.scala 132:18]
  assign io_to_axi_awaddr = 3'h0 == state ? _GEN_15 : _GEN_303; // @[d_cache.scala 132:18]
  assign io_to_axi_awlen = 3'h0 == state ? 8'h0 : _GEN_305; // @[d_cache.scala 132:18]
  assign io_to_axi_awvalid = 3'h0 == state ? _GEN_19 : _GEN_304; // @[d_cache.scala 132:18]
  assign io_to_axi_wdata = 3'h0 == state ? _GEN_20 : _GEN_308; // @[d_cache.scala 132:18]
  assign io_to_axi_wstrb = 3'h0 == state ? _GEN_21 : _GEN_309; // @[d_cache.scala 132:18]
  assign io_to_axi_wvalid = 3'h0 == state ? _GEN_23 : _GEN_311; // @[d_cache.scala 132:18]
  assign io_to_axi_bready = 3'h0 == state ? _T_3 : _GEN_312; // @[d_cache.scala 132:18]
  always @(posedge clock) begin
    if (cacheLine_MPORT_en & cacheLine_MPORT_mask) begin
      cacheLine[cacheLine_MPORT_addr] <= cacheLine_MPORT_data; // @[d_cache.scala 24:24]
    end
    if (cacheLine_MPORT_2_en & cacheLine_MPORT_2_mask) begin
      cacheLine[cacheLine_MPORT_2_addr] <= cacheLine_MPORT_2_data; // @[d_cache.scala 24:24]
    end
    if (cacheLine_MPORT_7_en & cacheLine_MPORT_7_mask) begin
      cacheLine[cacheLine_MPORT_7_addr] <= cacheLine_MPORT_7_data; // @[d_cache.scala 24:24]
    end
    if (validMem_MPORT_4_en & validMem_MPORT_4_mask) begin
      validMem[validMem_MPORT_4_addr] <= validMem_MPORT_4_data; // @[d_cache.scala 25:23]
    end
    if (validMem_MPORT_9_en & validMem_MPORT_9_mask) begin
      validMem[validMem_MPORT_9_addr] <= validMem_MPORT_9_data; // @[d_cache.scala 25:23]
    end
    if (tagMem_MPORT_3_en & tagMem_MPORT_3_mask) begin
      tagMem[tagMem_MPORT_3_addr] <= tagMem_MPORT_3_data; // @[d_cache.scala 28:21]
    end
    if (tagMem_MPORT_8_en & tagMem_MPORT_8_mask) begin
      tagMem[tagMem_MPORT_8_addr] <= tagMem_MPORT_8_data; // @[d_cache.scala 28:21]
    end
    if (dirtyMem_MPORT_1_en & dirtyMem_MPORT_1_mask) begin
      dirtyMem[dirtyMem_MPORT_1_addr] <= dirtyMem_MPORT_1_data; // @[d_cache.scala 29:23]
    end
    if (dirtyMem_MPORT_13_en & dirtyMem_MPORT_13_mask) begin
      dirtyMem[dirtyMem_MPORT_13_addr] <= dirtyMem_MPORT_13_data; // @[d_cache.scala 29:23]
    end
    if (quene_MPORT_5_en & quene_MPORT_5_mask) begin
      quene[quene_MPORT_5_addr] <= quene_MPORT_5_data; // @[d_cache.scala 77:20]
    end
    if (quene_MPORT_10_en & quene_MPORT_10_mask) begin
      quene[quene_MPORT_10_addr] <= quene_MPORT_10_data; // @[d_cache.scala 77:20]
    end
    if (reset) begin // @[d_cache.scala 70:34]
      write_back_data <= 128'h0; // @[d_cache.scala 70:34]
    end else if (!(3'h0 == state)) begin // @[d_cache.scala 132:18]
      if (!(3'h1 == state)) begin // @[d_cache.scala 132:18]
        if (!(3'h2 == state)) begin // @[d_cache.scala 132:18]
          write_back_data <= _GEN_220;
        end
      end
    end
    write_back_addr <= _GEN_246[31:0]; // @[d_cache.scala 71:{34,34}]
    if (reset) begin // @[d_cache.scala 75:31]
      receive_data_0 <= 64'h0; // @[d_cache.scala 75:31]
    end else if (!(3'h0 == state)) begin // @[d_cache.scala 132:18]
      if (!(3'h1 == state)) begin // @[d_cache.scala 132:18]
        if (!(3'h2 == state)) begin // @[d_cache.scala 132:18]
          receive_data_0 <= _GEN_179;
        end
      end
    end
    if (reset) begin // @[d_cache.scala 75:31]
      receive_data_1 <= 64'h0; // @[d_cache.scala 75:31]
    end else if (!(3'h0 == state)) begin // @[d_cache.scala 132:18]
      if (!(3'h1 == state)) begin // @[d_cache.scala 132:18]
        if (!(3'h2 == state)) begin // @[d_cache.scala 132:18]
          receive_data_1 <= _GEN_180;
        end
      end
    end
    if (reset) begin // @[d_cache.scala 76:30]
      receive_num <= 3'h0; // @[d_cache.scala 76:30]
    end else if (!(3'h0 == state)) begin // @[d_cache.scala 132:18]
      if (3'h1 == state) begin // @[d_cache.scala 132:18]
        if (!(anyMatch)) begin // @[d_cache.scala 148:27]
          receive_num <= 3'h0; // @[d_cache.scala 154:29]
        end
      end else if (!(3'h2 == state)) begin // @[d_cache.scala 132:18]
        receive_num <= _GEN_181;
      end
    end
    if (reset) begin // @[d_cache.scala 103:24]
      state <= 3'h0; // @[d_cache.scala 103:24]
    end else if (3'h0 == state) begin // @[d_cache.scala 132:18]
      if ((io_from_lsu_arvalid | io_from_lsu_awvalid) & io_from_lsu_araddr >= 32'ha0000000) begin // @[d_cache.scala 134:99]
        state <= 3'h0; // @[d_cache.scala 137:23]
      end else if (io_from_lsu_arvalid) begin // @[d_cache.scala 138:44]
        state <= 3'h1; // @[d_cache.scala 139:23]
      end else begin
        state <= _GEN_0;
      end
    end else if (3'h1 == state) begin // @[d_cache.scala 132:18]
      if (anyMatch) begin // @[d_cache.scala 148:27]
        state <= 3'h0;
      end else begin
        state <= 3'h3; // @[d_cache.scala 153:23]
      end
    end else if (3'h2 == state) begin // @[d_cache.scala 132:18]
      state <= _GEN_30;
    end else begin
      state <= _GEN_182;
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
  _RAND_0 = {4{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    cacheLine[initvar] = _RAND_0[127:0];
  _RAND_1 = {1{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    validMem[initvar] = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    tagMem[initvar] = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    dirtyMem[initvar] = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16; initvar = initvar+1)
    quene[initvar] = _RAND_4[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {4{`RANDOM}};
  write_back_data = _RAND_5[127:0];
  _RAND_6 = {1{`RANDOM}};
  write_back_addr = _RAND_6[31:0];
  _RAND_7 = {2{`RANDOM}};
  receive_data_0 = _RAND_7[63:0];
  _RAND_8 = {2{`RANDOM}};
  receive_data_1 = _RAND_8[63:0];
  _RAND_9 = {1{`RANDOM}};
  receive_num = _RAND_9[2:0];
  _RAND_10 = {1{`RANDOM}};
  state = _RAND_10[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule

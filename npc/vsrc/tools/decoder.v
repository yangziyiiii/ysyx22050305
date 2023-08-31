module decoder_2_4(
    input  wire [ 1:0] in,
    output wire [ 3:0] out
);

genvar i;
generate for (i=0; i<4; i=i+1) begin : gen_for_dec_2_4
    assign out[i] = (in == i);
end endgenerate

endmodule

module decoder_3_8(
    input  wire [ 2:0] in,
    output wire [ 7:0] out
);

genvar i;
generate for (i=0; i<8; i=i+1) begin : gen_for_dec_3_8
    assign out[i] = (in == i);
end endgenerate

endmodule

module decoder_4_16(
    input  wire [ 3:0] in,
    output wire [15:0] out
);

genvar i;
generate for (i=0; i<16; i=i+1) begin : gen_for_dec_4_16
    assign out[i] = (in == i);
end endgenerate

endmodule

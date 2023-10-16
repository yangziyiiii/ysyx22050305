`define DIV_INIT          2'b01
`define DIV_RUN           2'b10

module divisioner (
    input  wire clk,	//	时钟信号
    input  wire rst,	//	复位信号（高有效）
    input  wire div_valid,	//	为高表示输入的数据有效，如果没有新的除法输入，在除法被接受的下一个周期要置低
    input  wire flush,	//	为高表示取消除法
    input  wire divw,	//	为高表示是 32 位除法
    input  wire div_signed,	//	表示是不是有符号除法，为高表示是有符号除法
    input  wire [63:0] dividend,	//	被除数，xlen 表示除法器位数
    input  wire [63:0] divisor,	//	除数
    output wire div_ready,	//	为高表示除法器准备好，表示可以输入数据
    output wire out_valid,	//	为高表示除法器输出的结果有效
    output wire [63:0] quotient,	//	商
    output wire [63:0] remainder	//	余数
);

reg [127:0] A;
reg [ 63:0] A_w;
reg [ 64:0] B;
reg [ 32:0] B_w;

reg [ 63:0] dividend_r;
reg [ 63:0] divisor_r;

reg [1:0] div_state;
reg [1:0] div_nstate;

wire div_finish;
    
always @(posedge clk)begin
    if(rst) 
        div_state <= `DIV_INIT;
    else
        div_state <= div_nstate;
end 

always @(*) begin
    case(div_state)
    `DIV_INIT:
        if(div_valid & div_ready)
            div_nstate = `DIV_RUN;
    `DIV_RUN:
        if(div_finish || flush)
            div_nstate = `DIV_INIT;
    default:
       div_nstate = `DIV_INIT;         
    endcase
end

assign div_ready = div_state == `DIV_INIT;
assign out_valid = div_state == `DIV_RUN && div_finish;

//dividend and divisor abs
wire [63:0] dividend_u = (div_signed && dividend[63])? ~dividend + 1 : dividend;
wire [63:0] divisor_u  = (div_signed && divisor[63])?  ~divisor + 1 : divisor;

//32bit dividend and divisor abs
wire [31:0] dividend_uw = (div_signed && dividend[31])? ~dividend[31:0] + 1 : dividend[31:0];
wire [31:0] divisor_uw  = (div_signed && divisor[31])?  ~divisor[31:0] + 1 : divisor[31:0];


always @(posedge clk) begin
    if(div_valid & div_ready) begin
        dividend_r <= dividend;
        divisor_r <= divisor;
        B <= {1'b0 ,divisor_u};
        B_w <= {1'b0 ,divisor_uw};
    end
end

reg [6:0] cnt;
//64bit div
wire [64:0] sub_result = A[127: 63] - B;

always @ (posedge clk) begin
    if(div_valid & div_ready) begin
        A <= {64'b0,dividend_u};
    end
    else if(div_state == `DIV_RUN)begin
        if(sub_result[64]) begin
            A <= A << 1;
        end
        else begin
            A <= {sub_result[63:0], A[62:0], 1'b1};
        end
    end
end

//32 bit div
wire [32:0] sub_result_w = A_w[63: 31] - B_w;

always @ (posedge clk) begin
    if(div_valid & div_ready) begin
        A_w <= {32'b0,dividend_uw};
    end
    else if(div_state == `DIV_RUN)begin
        if(sub_result_w[32]) begin
            A_w <= A_w << 1;
        end
        else begin
            A_w <= {sub_result_w[31:0], A_w[30:0], 1'b1};
        end
    end
end

always @ (posedge clk) begin
    if(rst || div_state == `DIV_INIT || flush)
        cnt <= 0;
    else if(div_state == `DIV_RUN)
        cnt <= cnt + 1;
end

// assign the output
wire [31:0] quotient_w = (div_signed && dividend_r[31] ^ divisor_r[31])? ~A_w[31:0]+1 : A_w[31:0];
wire [31:0] remainder_w = (div_signed && dividend_r[31])? ~A_w[63:32]+1 : A_w[63:32];
wire [63:0] quotient_d = (div_signed && dividend_r[63] ^ divisor_r[63])? ~A[63:0]+1 : A[63:0];
wire [63:0] remainder_d = (div_signed && dividend_r[63])? ~A[127:64]+1 : A[127:64];

assign quotient = divw? {32'b0, quotient_w} : quotient_d;
assign remainder = divw? {32'b0, remainder_w} : remainder_d;

assign div_finish = divw? (cnt == 7'd32) : (cnt == 7'd64);
endmodule

`define MUL_INIT          2'b01
`define MUL_RUN           2'b10

module multiplier (
    input  wire clk,	//	时钟信号
    input  wire rst,	//	复位信号（高有效）
    input  wire mul_valid,	//	为高表示输入的数据有效，如果没有新的乘法输入，在乘法被接受的下一个周期要置低
    input  wire flush,	//	为高表示取消乘法
    input  wire mulw,	//	为高表示是 32 位乘法
    input  wire [1 :0] mul_signed,	//	2’b11（signed x signed）；2’b10（signed x unsigned）；2’b00（unsigned x unsigned）；
    input  wire [63:0] multiplicand,	//	被乘数，xlen 表示乘法器位数
    input  wire [63:0] multiplier,	//	乘数
    output wire mul_ready,	//	为高表示乘法器准备好，表示可以输入数据
    output wire out_valid,	//	为高表示乘法器输出的结果有效
    output wire [63:0] result_hi,	//	高 xlen bits 结果
    output wire [63:0] result_lo	//	低 xlen bits 结果
);

wire [127:0] partial_accumulation;
wire partial_c;

reg [127:0] x;
reg [ 64:0] y;
reg [127:0] result;

reg [1:0] mul_state;
reg [1:0] mul_nstate;

wire mul_finish;
    
always @(posedge clk)begin
    if(rst) 
        mul_state <= `MUL_INIT;
    else
        mul_state <= mul_nstate;
end 

always @(*) begin
    case(mul_state)
    `MUL_INIT:
        if(mul_valid & mul_ready)
        /* verilator lint_off COMBDLY */
            mul_nstate <= `MUL_RUN;
    `MUL_RUN:
        if(mul_finish || flush)
        /* verilator lint_off COMBDLY */
            mul_nstate <= `MUL_INIT;
    default:
    /* verilator lint_off COMBDLY */
       mul_nstate <= `MUL_INIT;         
    endcase
end

assign mul_ready = mul_state == `MUL_INIT;
assign out_valid = mul_state == `MUL_RUN && mul_finish;
assign {result_hi, result_lo} = result;
//assign {result_hi, result_lo} = x * y;

wire extend = (mul_signed==2'b11)? multiplicand[63] : 1'b0;

always @(posedge clk) begin
    if(mul_valid & mul_ready) begin
        x <= {{64{extend}},multiplicand};
        y <= {multiplier,1'b0};
    end
end


booth_sel booth_sel(.x(x), .src(y[2:0]), .p(partial_accumulation), .c(partial_c));

reg [4:0] cnt;
always @(posedge clk) begin
    if(mul_ready && mul_valid)begin
        result <= 0;
        cnt <= 0;
    end
    else if(mul_state == `MUL_RUN)begin
        /* verilator lint_off WIDTH */
        result <= result + partial_accumulation + partial_c;
        x <= x << 2;
        y <= y >> 2;
        cnt <= cnt+1;
    end
end

assign mul_finish = (cnt == 5'd31 || y == 0);
//assign mul_finish = 1;
endmodule
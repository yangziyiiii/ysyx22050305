module booth_sel (
    input wire [127:0] x,
    input wire [2:0] src,
    output wire [127:0] p,
    output wire c
);
    
///y+1,y,y-1///
wire y_add,y,y_sub;
wire sel_negative,sel_double_negative,sel_positive,sel_double_positive;

assign {y_add,y,y_sub} = src;

assign sel_negative =  y_add & (y & ~y_sub | ~y & y_sub);
assign sel_positive = ~y_add & (y & ~y_sub | ~y & y_sub);
assign sel_double_negative =  y_add & ~y & ~y_sub;
assign sel_double_positive = ~y_add &  y &  y_sub;

assign p = ~(~({128{sel_negative}} & ~x) & ~({128{sel_double_negative}} & ~(x<<1)) 
           & ~({128{sel_positive}} & x ) & ~({128{sel_double_positive}} &  (x<<1)));

assign c = sel_negative || sel_double_negative;
endmodule
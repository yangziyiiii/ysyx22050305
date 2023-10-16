import "DPI-C" function void ebreak();

module EBREAK(
    input wire [31:0] inst
);
always @(*) begin
    if(inst == 32'b0000000_00001_00000_000_00000_1110011) 
        ebreak();       
end
endmodule

`include "define.v"

module if_id_regs(
	input clk,
	input rst_n,
	input [63:0]pc_if_id_i,
	input [31:0]inst_if_id_i,
	output reg [63:0]pc_if_id_o,
	output reg [31:0]inst_if_id_o
);
    always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			pc_if_id_o<= `PC_ENTRY;
		else
			pc_if_id_o<=pc_if_id_i;
	end
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			inst_if_id_o<= `PC_ENTRY;
		else
			inst_if_id_o<=inst_if_id_i;
	end

endmodule

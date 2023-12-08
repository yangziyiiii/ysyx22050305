`include "define.v"

module if_stage(
	input clk,
	input rst_n,
	input [63:0]if_pc_i,
	output [63:0]if_pc_o,
	output [31:0]if_inst_o,

);
    reg [63:0]pc;
    always @(posedge clk) begin
        if (rst) begin
            pc <= `PC_ENTRY - 4;
        end
        else if (to_if_valid && id_allow_in) begin
            pc <= {32'b0, i_addr};
        end
    end

    wire [63:0] next_pc;
    wire        jump_taken;
    wire [63:0] jump_target;

    reg         jump_taken_r;
    reg  [63:0] jump_target_r;

    assign id_inst_cancel = jump_taken || jump_taken_r;

    always @(posedge clk) begin
        if(pre_if_ready_go)
            jump_taken_r <= 0;
        else if(jump_taken) begin
            jump_taken_r <= 1;
            jump_target_r <= jump_target;
        end
    end
    assign jump_taken = (ex && wb_valid) ||
                        (ex_ret && wb_valid) ||
                        (br_taken && id_valid);
    assign jump_target = (ex && wb_valid)? ex_entry :
                        (ex_ret && wb_valid)? epc :
                        (br_taken && id_valid)? br_target:
                        pc + 4;
    assign nextpc = jump_taken ? jump_target :
                    (jump_taken_r) ? jump_target_r :
                    pc + 4;

    assign if_pc_o = pc;

    wire [31:0] inst = pc[2]? i_rdata[63:32] : i_rdata[31:0];
	

endmodule

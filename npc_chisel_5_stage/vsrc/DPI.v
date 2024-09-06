import "DPI-C" function void ebreak_handle(input int flag);
import "DPI-C" function void ecall_handle(input int flag);
import "DPI-C" function void get_pc(input longint pc);

module DPI(
    input wire[31:0] flag,
    input wire[31:0] ecall_flag,
    input wire[63:0] pc
);

always@(*)begin
    ebreak_handle(flag);
    ecall_handle(ecall_flag);
    get_pc(pc);
end

endmodule

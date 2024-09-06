LDFLAGS += --diff=$(NEMU_HOME)/build/riscv64-nemu-interpreter-so

all:
	@echo "Write this Makefile by your self."

verilog:
	cd vsrc && sbt run

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@verilator --cc --trace --exe --build ./vsrc/*.v ./csrc/main.cpp ./csrc/*.c --top-module top --LDFLAGS "-fsanitize=address -lSDL2 -ldl $(shell llvm-config --cxxflags) -fPIE $(shell llvm-config --libs)"
	@./obj_dir/Vtop

copy_top:
	sed -n '/module top/,/endmodule/p' vsrc/output/top.v > vsrc/top.v
	echo "/* verilator lint_off UNUSED */" > vsrc/IFU.v
	sed -n '/module IFU_AXI/,/endmodule/p' vsrc/output/top.v >> vsrc/IFU.v
	echo "/* verilator lint_on UNUSED */" >> vsrc/IFU.v
	echo "/* verilator lint_off UNUSED */" > vsrc/IDU.v
	sed -n '/module IDU/,/endmodule/p' vsrc/output/top.v >> vsrc/IDU.v
	echo "/* verilator lint_on UNUSED */" >> vsrc/IDU.v
	echo "/* verilator lint_off UNUSED */" > vsrc/EXU.v
	echo "/* verilator lint_off WIDTH */" >> vsrc/EXU.v
	sed -n '/module EXU_AXI/,/endmodule/p' vsrc/output/top.v >> vsrc/EXU.v
	echo "/* verilator lint_on WIDTH */" >> vsrc/EXU.v
	echo "/* verilator lint_on UNUSED */" >> vsrc/EXU.v
	sed -n '/module AXI_IFU/,/endmodule/p' vsrc/output/top.v > vsrc/AXI_IFU.v
	sed -n '/module AXI_EXU/,/endmodule/p' vsrc/output/top.v > vsrc/AXI_EXU.v
	sed -n '/module AXI_ARBITER/,/endmodule/p' vsrc/output/top.v > vsrc/AXI_ARBITER.v
	echo "/* verilator lint_off UNOPTFLAT */" > vsrc/AXI.v	
	sed -n '/module AXI(/,/endmodule/p' vsrc/output/top.v >> vsrc/AXI.v
	echo "/* verilator lint_on UNOPTFLAT */" >> vsrc/AXI.v
	sed -n '/module LSU/,/endmodule/p' vsrc/output/top.v > vsrc/LSU.v
	sed -n '/module I_CACHE/,/endmodule/p' vsrc/output/top.v > vsrc/I_CACHE.v
	sed -n '/module D_CACHE/,/endmodule/p' vsrc/output/top.v > vsrc/D_CACHE.v
	sed -n '/module WBU/,/endmodule/p' vsrc/output/top.v > vsrc/WBU.v
	sed -n '/module Register/,/endmodule/p' vsrc/output/top.v > vsrc/Register.v	

copy_top_pipeline:
	sed -n '/module top/,/endmodule/p' vsrc/output/top.v > vsrc/top.v
	echo "/* verilator lint_off UNUSED */" > vsrc/IFU.v
	sed -n '/module IFU/,/endmodule/p' vsrc/output/top.v >> vsrc/IFU.v
	echo "/* verilator lint_on UNUSED */" >> vsrc/IFU.v
	echo "/* verilator lint_off UNUSED */" > vsrc/IDU.v
	sed -n '/module IDU/,/endmodule/p' vsrc/output/top.v >> vsrc/IDU.v
	echo "/* verilator lint_on UNUSED */" >> vsrc/IDU.v
	echo "/* verilator lint_off UNUSED */" > vsrc/EXU.v
	echo "/* verilator lint_off WIDTH */" >> vsrc/EXU.v
	sed -n '/module EXU/,/endmodule/p' vsrc/output/top.v >> vsrc/EXU.v
	echo "/* verilator lint_on WIDTH */" >> vsrc/EXU.v
	echo "/* verilator lint_on UNUSED */" >> vsrc/EXU.v
	sed -n '/module LSU/,/endmodule/p' vsrc/output/top.v > vsrc/LSU.v
	sed -n '/module WBU/,/endmodule/p' vsrc/output/top.v > vsrc/WBU.v
	sed -n '/module Register/,/endmodule/p' vsrc/output/top.v > vsrc/Register.v	
	echo "/* verilator lint_off WIDTH */" > vsrc/alu.v
	sed -n '/module ALU/,/endmodule/p' vsrc/output/top.v >> vsrc/alu.v	
	echo "/* verilator lint_on WIDTH */" >> vsrc/alu.v
	sed -n '/module Mul/,/endmodule/p' vsrc/output/top.v > vsrc/Mul.v
	sed -n '/module Div/,/endmodule/p' vsrc/output/top.v > vsrc/Div.v
	sed -n '/module partial_product/,/endmodule/p' vsrc/output/top.v > vsrc/partial_product.v
	sed -n '/module csr_reg/,/endmodule/p' vsrc/output/top.v > vsrc/csr_reg.v
	sed -n '/module AXI_ARBITER/,/endmodule/p' vsrc/output/top.v > vsrc/AXI_ARBITER.v
	echo "/* verilator lint_off UNOPTFLAT */" > vsrc/AXI.v	
	sed -n '/module AXI(/,/endmodule/p' vsrc/output/top.v >> vsrc/AXI.v
	echo "/* verilator lint_on UNOPTFLAT */" >> vsrc/AXI.v
	sed -n '/module I_CACHE/,/endmodule/p' vsrc/output/top.v > vsrc/I_CACHE.v
	sed -n '/module D_CACHE/,/endmodule/p' vsrc/output/top.v > vsrc/D_CACHE.v

clean:
	rm -r obj_dir/	

include ../Makefile

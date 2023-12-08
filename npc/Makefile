BUILD_DIR = ./build

export PATH := $(PATH):$(abspath ./utils)

verilog:
	$(call git_commit, "generate verilog")
	cd scala && sbt run
	

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@verilator --cc --trace --exe --build ./vsrc/*.v ./csrc/*.cpp --top-module top



clean:
	-rm -rf $(BUILD_DIR)




.PHONY: verilog clean sim 

include ../Makefile


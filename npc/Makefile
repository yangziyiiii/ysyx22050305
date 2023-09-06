TOPNAME = top
INC_PATH ?=
IMG ?=

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert -Wno-fatal --trace --timescale 1ps/1ps

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CFLAGS  += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
LDFLAGS += -lSDL2 -lSDL2_image -lreadline
LDFLAGS += $(shell llvm-config --cxxflags) -fPIE 
LDFLAGS += $(shell llvm-config --libs)
LDFLAGS += $(NEMU_HOME)/build/riscv64-nemu-interpreter-so
LDFLAGS += -fsanitize=address -lasan 


$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ $(SRC_AUTO_BIND)\
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

run: $(BIN)
	@rm -rf $(OBJ_DIR)
	@echo IMG PATH : $(IMG)
	@rm -rf *.bin
	@rm -rf *.elf
	@cp $(IMG).bin ./image.bin
	@cp $(IMG).elf ./image.elf
	@$^ $(IMG)
	$(call git_commit, "run RTL") # DO NOT REMOVE THIS LINE!!!

sim: $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	@cp $(IMG).bin ./image.bin
	@cp $(IMG).elf ./image.elf
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--trace \
		--top-module $(TOPNAME) $^\
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	$(BUILD_DIR)/$(TOPNAME)
	gtkwave wave.vcd

clean:
	rm -rf ./build

clean-wave:
	rm wave.vcd

.PHONY: default all clean run sim clean-wave

include ../Makefile

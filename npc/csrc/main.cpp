/* run nvboard
#include <nvboard.h>
#include <Vtop.h>

static TOP_NAME dut;

void nvboard_bind_all_pins(Vtop* top);

static void single_cycle() {
  dut.clock = 0; dut.eval();
  dut.clock = 1; dut.eval();
}

static void reset(int n) {
  dut.reset = 1;
  while (n -- > 0) single_cycle();
  dut.reset = 0;
}

int main() {
  nvboard_bind_all_pins(&dut);
  nvboard_init();

  reset(10);

  while(1) {
    nvboard_update();
    single_cycle();
  }
}
*/

// sim
#include <verilated.h>          
#include <verilated_vcd_c.h>    
#include "Vtop.h"
#include "svdpi.h"
#include "Vtop__Dpi.h"
#include "verilated_dpi.h"

#include "./include/common.h"



void dump_gpr();
void init_mem();
uint8_t* guest_to_host(paddr_t paddr);
uint32_t inst_fetch(paddr_t inst_addr);

void init_sdb();
word_t expr(char *e, bool *success);
void sdb_mainloop();

void init_disasm(const char *triple);
#ifdef CONFIG_DIFFTEST
  void difftest_step(vaddr_t pc, vaddr_t npc);
  void init_difftest(char *ref_so_file, long img_size, int port);
#endif
void init_device();
void device_update();

static VerilatedContext* contextp;
static Vtop* top;
static VerilatedVcdC* tfp;
static vluint64_t main_time = 0;
static const vluint64_t sim_time = 1000000000; //max sim time
static long cpu_cycle = 0;

extern uint64_t *cpu_gpr;
CPU_state npc_cpu = {.pc = RESET_VECTOR};
NPCState npc_state = {.state = NPC_STOP, .halt_ret = 0};

//itrace
static char iringbuf[16][65];
static int idx = 0;


void ebreak() {
    npc_state.halt_ret = 1;
    npc_state.halt_pc = npc_cpu.pc;
}

long load_image() {
  char image_path[] = "/home/yzy/ysyx-workbench/npc/image.bin";
  FILE *fp = fopen(image_path, "rb");
  if( fp == NULL ) {
		printf( "Can not open inst file!\n" );
		exit(1);
  }
  
  fseek(fp, 0, SEEK_END);
  size_t size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
  fclose(fp);
  return size;
}

void cpu_init() {
  top -> clk = 0;
  top -> rst = 1;
  top -> eval();
  #ifdef WAVE
  tfp->dump(main_time);
  #endif
  main_time ++;
  top -> clk = 1;
  top -> rst = 1;
  top -> eval();
  #ifdef WAVE
  tfp->dump(main_time);
  #endif
  main_time ++;
  top -> rst = 0;
  top -> eval();

}

void exec_once() {
  top->clk = !top->clk;
  top->eval();
  #ifdef WAVE
  tfp->dump(main_time);
  #endif
  main_time ++;

  //printf("pc: %lx\n",  top->pc);
  uint32_t i = top->inst;
#ifdef CONFIG_ITRACE
  char inst[32];
  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(inst, 32, top->pc, (uint8_t*)&top->inst, 4);
  printf("%s\n", inst);
  sprintf(iringbuf[idx++], "%016lx %s", top->pc, inst);
  if(idx >= 16)
    idx = 0;
#endif
  
  top->clk = !top->clk;
  top->eval(); 
  #ifdef WAVE
	tfp->dump(main_time);
  #endif
  main_time ++;

  npc_cpu.pc = top->pc;
  for(int i=0;i<32;i++)
    npc_cpu.gpr[i] = cpu_gpr[i];

#ifdef CONFIG_FTRACE
  void ftrace(uint32_t inst);
  ftrace(i);
#endif
}
 
void cpu_exec(uint64_t n) {
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  for(int i; i < n; i++){
      exec_once();
      cpu_cycle++;

      #ifdef CONFIG_DIFFTEST
        difftest_step(npc_cpu.pc, npc_cpu.pc+4);
      #endif
      device_update();
      if(npc_state.state != NPC_RUNNING) break;
      if(/*main_time > sim_time || */npc_state.halt_ret){
        npc_state.state = NPC_END;
        break;
      }
  }

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;
    case NPC_ABORT:
    case NPC_END: 
      if(npc_state.state == NPC_ABORT)
        printf("npc: ABORT at pc = %016lx ", npc_state.halt_pc);
      else
        printf("npc: END at pc = %016lx ", npc_state.halt_pc);

      if(npc_state.halt_ret){
        printf("\033[0m\033[1;32m%s\n\033[0m","Hit good trap!");
      }else{
        printf("\033[0m\033[1;31m%s\n\033[0m","Hit bad trap!");
      }

      #ifdef CONFIG_ITRACE
      for(int i=0; i< 16; i++){
        if(i==idx-1)
          printf("--> %s\n", iringbuf[i]);
        else
          printf("    %s\n", iringbuf[i]);
      }
      #endif
      // fall through
    case NPC_QUIT: return;
  }
}

int main(int argc, char** argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  top = new Vtop{contextp};
  //VCD波形设置
  #ifdef WAVE
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  top->trace(tfp, 0);
  tfp->open("wave.vcd");
  #endif

  //initial
  init_mem();
  long img_size = load_image();
  cpu_init();
  init_sdb();
  init_disasm("riscv64-pc-linux-gnu");
  init_device();

  //ftrace
  #ifdef CONFIG_FTRACE
  extern int elf_load();
  elf_load();
  #endif

  //difftest
  #ifdef CONFIG_DIFFTEST
      char diff_so_file[100] = "/home/yzy/ysyx-workbench/nemu/build/riscv64-nemu-interpreter-so";
      int difftest_port = 1234;
      init_difftest(diff_so_file, img_size, difftest_port);
  #endif
  
  sdb_mainloop();
  // clean
  #ifdef WAVE
  tfp->close();
  delete tfp;
  #endif
  delete top;
  printf("END\n");
  return 0;
}

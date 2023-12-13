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

// void init_sdb();
// word_t expr(char *e, bool *success);
// void sdb_mainloop();

// void init_disasm(const char *triple);
// #ifdef CONFIG_DIFFTEST
//   void difftest_step(vaddr_t pc, vaddr_t npc);
//   void init_difftest(char *ref_so_file, long img_size, int port);
// #endif
// void init_device();
// void device_update();

static VerilatedContext* contextp;
static Vtop* top;
static VerilatedVcdC* tfp;
static vluint64_t main_time = 0;
static const vluint64_t sim_time = -1; //max sim time
static const vluint64_t wave_start_time = 0; //wave start time
static long cpu_cycle = 0;


extern uint64_t *cpu_gpr;
CPU_state npc_cpu = {.pc = RESET_VECTOR};
NPCState npc_state = {.state = NPC_STOP, .halt_ret = 0};

void ebreak() {
    npc_state.halt_ret = 1;
    npc_state.halt_pc = npc_cpu.pc;
}

long load_image() {
  char image_path[] = "../npc/image.bin";
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
  tfp -> dump(main_time);
  main_time ++;

  top -> clk = 1;
  top -> rst = 1;
  top -> eval();
  tfp -> dump(main_time);
  main_time ++;

  top -> rst = 0;
  top -> eval();
}

void exec_once(VerilatedVcdC* tfp){
  top -> clk = 0;
  top -> eval();
  tfp -> dump(main_time);
  main_time ++;

  top -> clk = 1;
  top -> eval();
  tfp -> dump(main_time);
  main_time ++;
}

void cpu_exec(uint64_t n) {
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  for(int i = 0; i < n; i++) {
    exec_once(tfp);

    if (npc_state.state != NPC_RUNNING) break;

    if(main_time > sim_time || npc_state.halt_ret){
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
    case NPC_QUIT: 
      printf("NPC END\n");
      // printf("inst_cnt: %ld  cycle_cnt: %ld\n", cpu_cycle, main_time/2);
      // printf("IPC: %.4f\n", (float)cpu_cycle / (main_time/2));
      // printf("inst_cnt: %ld, icache_miss: %ld, miss_rate: %.6f\n", top->inst_cnt, top->icache_miss, (float)(top->icache_miss)/cpu_cycle);
      // printf("mem_cnt: %ld, dcache_miss: %ld, miss_rate: %.6f\n", top->mem_cnt, top->dcache_miss, (float)(top->dcache_miss)/(top->mem_cnt));
      // printf("device cnt: %ld\n", top->device_cnt);
      // printf("mul cnt: %ld\n", top->mul_cnt);
      // printf("div cnt: %ld\n", top->div_cnt);
    return;
  }
}



int main(int argc, char** argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  top = new Vtop{contextp};

  //vcd
  #ifdef WAVE
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace(tfp, 0);
    tfp->open("wave.vcd");
  #endif

  load_image();
  printf("load image success\n");

  //init
  cpu_init();
  init_mem();

  #ifdef HAS_VGA
    init_vga();
    init_i8042();
  #endif

  //difftest
  #ifdef CONFIG_DIFFTEST
    char diff_so_file[100] = "../nemu/build/riscv64-nemu-interpreter-so";
    int difftest_port = 1234;
    init_difftest(diff_so_file, img_size, difftest_port);
  #endif

  //ftrace    
  #ifdef CONFIG_FTRACE
    init_ftrace();

  #endif

  sdb_mainloop();

  //clean
  tfp->close();
  delete top;
  return 0;
}

#include "verilated_dpi.h"
#include "./include/common.h"
#include "svdpi.h"
#include "Vtop__Dpi.h"

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};  
uint64_t *cpu_gpr = NULL; //regfile

word_t isa_reg_str2val(const char *s, bool *success) {
  int i;
  for(i=0;i<32;i++){
    if(strcmp(s, regs[i]) == 0){
      return cpu_gpr[i];
    }
  }
  *success = false;
  printf("no reg name\n");
  return 0;
}

extern "C" void set_gpr_ptr(const svOpenArrayHandle r) {
  cpu_gpr = (uint64_t *)(((VerilatedDpiOpenVar*)r)->datap());
}

// 一个输出RTL中通用寄存器的值的示例
void dump_gpr() {
  int i;
  for (i = 0; i < 32; i++) {
    printf("gpr[%d] = 0x%lx\n", i, cpu_gpr[i]);
  }
}

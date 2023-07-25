/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <difftest-def.h>
#include <memory/paddr.h>

void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction) {
 	if (direction == DIFFTEST_TO_REF){
		paddr_t waddr = addr;
	  for(size_t i = 0; i< n; i++){
		  paddr_write(waddr++,1,*((uint8_t *)buf+i));
      //paddr_write(addr++,1,*((uint8_t *)buf+i));
	  }
	}
	else{
		assert(0);
	}
}

struct  diff_CPU_state{
	word_t gpr[32];
	word_t pc;
};

void difftest_regcpy(void *dut, bool direction) {
  // uint64_t *dut_t=(uint64_t *)dut;
  // if (direction == DIFFTEST_TO_REF) {
  //   for(int i=0;i<32;i++) {
  //     cpu.gpr[i]=*(dut_t+i);
  //   }
  // } else {
  //     for(int i=0;i<32;i++)
  //       *(dut_t+i)=cpu.gpr[i];
  // }
  if(direction == DIFFTEST_TO_REF){
    struct diff_CPU_state* ctx = (struct diff_CPU_state *)dut;
    for (int i = 0; i < 32;i++){
  	cpu.gpr[i] = ctx->gpr[i];
    }
    	cpu.pc = ctx->pc;
  }else{
    if(direction == DIFFTEST_TO_DUT){
      struct diff_CPU_state* ctx = (struct diff_CPU_state *)dut;
      for (int i = 0; i < 32;i++){
  	ctx->gpr[i] = cpu.gpr[i];
      }
    	ctx->pc = cpu.pc;
    }
  }
}

void difftest_exec(uint64_t n) {
  cpu_exec(n);
}

void difftest_raise_intr(word_t NO) {
  isa_raise_intr(NO,cpu.pc);
}

void difftest_init(int port) {
  /* Perform ISA dependent initialization. */
  init_isa();
}

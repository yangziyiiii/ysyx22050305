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
  int i;
  if(direction == DIFFTEST_TO_DUT){
    word_t rdata[1];
    for(i=0;i<n/4;i++){
      *rdata = paddr_read(addr+i*4, 4);
      memcpy(buf+i*4, (void*)rdata, 4);
    }
  }else{
    for(i=0;i<n/4;i++){
      paddr_write(addr+i*4, 4, *((uint32_t*)buf + i));
    }
  }
}

void difftest_regcpy(void *dut, bool direction) {
  int i; 
  CPU_state *dut_reg = dut;
  if(direction == DIFFTEST_TO_DUT){
    dut_reg->pc = cpu.pc;
    for(i=0;i<32;i++){
      dut_reg->gpr[i] = cpu.gpr[i];
    }
  }else{
    cpu.pc = dut_reg->pc;
    for(i=0;i<32;i++){
      cpu.gpr[i] = dut_reg->gpr[i];
    }
  }
}

void difftest_exec(uint64_t n) {
  cpu_exec(n);
}

void difftest_raise_intr(word_t NO) {
  cpu.pc = isa_raise_intr(NO,cpu.pc);
}

void difftest_init(int port) {
  /* Perform ISA dependent initialization. */
  init_isa();
}

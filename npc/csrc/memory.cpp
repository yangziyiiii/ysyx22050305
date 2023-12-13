#include "./include/device.h"
#include "verilated_dpi.h"
#include "svdpi.h"
#include "Vtop__Dpi.h"

#define CONFIG_MSIZE 0x8000000
#define CONFIG_MBASE 0x80000000
static uint8_t pmem[CONFIG_MSIZE] __attribute((aligned(4096))) = {};

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static bool out_of_bound(paddr_t addr) {
    if(addr >= CONFIG_MBASE && addr < CONFIG_MBASE+CONFIG_MSIZE)
        return 0;
    else{
        printf("addr out of bound: %lx at pc: %lx\n", addr, npc_cpu.pc);
        npc_state.state = NPC_ABORT;
        return 1;
    }
}

void init_mem() {
  uint32_t *p = (uint32_t *)pmem;
  int i;
  for (i = 0; i < (int)(CONFIG_MSIZE / sizeof(p[0])); i++) {
    p[i] = rand();
  }
  printf("physical memory area [%8x, %8x)\n", CONFIG_MBASE, CONFIG_MBASE+CONFIG_MSIZE);
}

extern "C" void inst_fetch(long long inst_addr, int* inst){
    if(out_of_bound(inst_addr)) return;
    *inst = *(uint32_t *)guest_to_host(inst_addr & ~0x3ull);
}


extern "C" void pmem_read(int raddr, int *rdata) {
  // 总是读取地址为`raddr & ~0x7ull`的8字节返回给`rdata`
  if(raddr == RTC_ADDR) {}
  //memory
  else { *rdata = ret;}

}
extern "C" void pmem_write(int waddr, int wdata, char wmask) {
  // 总是往地址为`waddr & ~0x7ull`的8字节按写掩码`wmask`写入`wdata`
  // `wmask`中每比特表示`wdata`中1个字节的掩码,
  // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
  if (waddr < CONFIG_MBASE) return;
  //memory
  else if((waddr >= CONFIG_MBASE) && (waddr < CONFIG_MAX)) {
    wdata >>= 8, wmask >>= 1, pt++;
  }
  //mmio-serial_port
  else if(waddr == SERIAL_PORT) {} 
}
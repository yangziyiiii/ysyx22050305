#include "./device/device.h"
#include "verilated_dpi.h"
#include "svdpi.h"
#include "Vtop__Dpi.h"

#include "time.h"

#define CONFIG_MSIZE 0x8000000
#define CONFIG_MBASE 0x80000000
static uint8_t pmem[CONFIG_MSIZE] __attribute((aligned(4096))) = {};

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static void out_of_bound(paddr_t addr) {
    if(addr >= CONFIG_MBASE && addr < CONFIG_MBASE+CONFIG_MSIZE)
        return;
    else
        printf("addr out of bound: %lx\n", addr);
        assert(0);
}

void init_mem() {
  uint32_t *p = (uint32_t *)pmem;
  int i;
  for (i = 0; i < (int)(CONFIG_MSIZE / sizeof(p[0])); i++) {
    p[i] = rand();
  }
  printf("physical memory area [%8x, %8x)\n", CONFIG_MBASE, CONFIG_MBASE+CONFIG_MSIZE);
}

extern "C" void inst_fetch(long long inst_addr, int * inst){
    out_of_bound(inst_addr);
    *inst = *(uint32_t *)guest_to_host(inst_addr & ~0x3ull);
}

extern "C" void pmem_read(long long raddr, long long *rdata, char ren) {
  // 总是读取地址为`raddr & ~0x7ull`的8字节返回给`rdata`
    if((uint8_t)ren == 0)
        return;
    
    //timer device
    uint32_t us_lo;
    uint32_t us_hi;
    if(raddr == RTC_ADDR){
        
        // time_t currentTime;
        // uint64_t us = currentTime;
        uint64_t us = get_time();
        us_lo = (uint32_t)us;
        us_hi = us >> 32;
        *rdata = us_lo;
        printf("lo paddr:%llx read:%llx ren:%x\n", raddr, *rdata, ren);
        return;
    }else if(raddr == RTC_ADDR+4){
        *rdata = us_hi;
        printf("hi paddr:%llx read:%llx ren:%x\n", raddr, *rdata, ren);
        return;
    }

    out_of_bound(raddr);
    *rdata = *(uint64_t *)guest_to_host(raddr & ~0x7ull); 
#ifdef CONFIG_MTRACE
    printf("paddr:%llx read:%llx ren:%x\n", raddr, *rdata, ren);
#endif
}

static int n = 0;

extern "C" void pmem_write(long long waddr, long long wdata, char wmask) {
  // 总是往地址为`waddr & ~0x7ull`的8字节按写掩码`wmask`写入`wdata`
  // `wmask`中每比特表示`wdata`中1个字节的掩码,
  // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
    if((uint8_t)wmask ==0)
        return;

    //uart device
    if(waddr == SERIAL_PORT){
        if(n%2==0)
            putchar((char)wdata);
        n++;
        return;
    }
    
    out_of_bound(waddr);
    uint8_t* waddr_p = guest_to_host(waddr);
#ifdef CONFIG_MTRACE
    printf("paddr:%llx wdata:%llx wmask:%x\n", waddr, wdata, (uint8_t)wmask);
#endif
    
    switch ((uint8_t)wmask) {  
        case 0x1:   *(uint8_t  *)waddr_p = wdata; return;
        case 0x2:   *(uint8_t  *)waddr_p = wdata; return;
        case 0x4:   *(uint8_t  *)waddr_p = wdata; return;
        case 0x8:   *(uint8_t  *)waddr_p = wdata; return;
        case 0x10:  *(uint8_t  *)waddr_p = wdata; return;
        case 0x20:  *(uint8_t  *)waddr_p = wdata; return;
        case 0x40:  *(uint8_t  *)waddr_p = wdata; return;
        case 0x80:  *(uint8_t  *)waddr_p = wdata; return;
        case 0x3:   *(uint16_t *)waddr_p = wdata; return;
        case 0xc:   *(uint16_t *)waddr_p = wdata; return;
        case 0x30:  *(uint16_t *)waddr_p = wdata; return;
        case 0xc0:  *(uint16_t *)waddr_p = wdata; return;
        case 0xf:   *(uint32_t *)waddr_p = wdata; return;
        case 0xf0:  *(uint32_t *)waddr_p = wdata; return;
        case 0xff:  *(uint64_t *)waddr_p = wdata; return;
        default: assert(0);
    }
}
#include "device.h"
#include "verilated_dpi.h"
#include "svdpi.h"
#include "Vtop__Dpi.h"

#define CONFIG_MSIZE 0x8000000
#define CONFIG_MBASE 0x80000000
static uint8_t pmem[CONFIG_MSIZE] __attribute((aligned(4096))) = {};
extern uint32_t *vgactl_port_base;
extern void *vmem;
uint32_t screen_size();
uint32_t key_dequeue();

void difftest_skip_ref();
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

extern "C" void pmem_read(long long raddr, long long *rdata, char ren) {
  // 总是读取地址为`raddr & ~0x7ull`的8字节返回给`rdata`
    if((uint8_t)ren == 0)
        return;
    
    //device
    #ifdef CONFIG_DEVICE
    uint32_t us_lo;
    uint32_t us_hi;
    if(raddr == RTC_ADDR){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        uint64_t us = get_time();
        us_lo = (uint32_t)us;
        us_hi = us >> 32;
        *rdata = us_lo;
        //printf("lo paddr:%llx read:%llx ren:%x\n", raddr, *rdata, ren);
        return;
    }else if(raddr == RTC_ADDR+4){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        *rdata = us_hi;
        //printf("hi paddr:%llx read:%llx ren:%x\n", raddr, *rdata, ren);
        return;
    }else if(raddr == VGACTL_ADDR){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        //printf("IO_read vgabase[0]: %d\n", vgactl_port_base[0]);
        *rdata =  vgactl_port_base[0];
        return;
    }else if (raddr == VGACTL_ADDR+4){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        //printf("IO_read vgabase[1]: %d\n", vgactl_port_base[1]);
        *rdata = vgactl_port_base[1];
        return;
    }else if(raddr == KBD_ADDR){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        // *rdata = i8042_key();
        *rdata = key_dequeue();
        return;
    }
    #endif
    if(out_of_bound(raddr)) return;
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

    //device
    #ifdef CONFIG_DEVICE
    if(waddr == SERIAL_PORT){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        if(n%3==0)
            putchar((char)wdata);
        n++;
        return;
    }else if(waddr == VGACTL_ADDR+4){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        vgactl_port_base[1] = (uint32_t)wdata;
        //printf("IO_write vgabase[1]: %d\n", vgactl_port_base[1]);
        return;
    }else if(waddr >= FB_ADDR && waddr < FB_ADDR + screen_size()){
        #ifdef CONFIG_DIFFTEST
            difftest_skip_ref();
        #endif
        *(uint32_t *)((uint8_t *)vmem + waddr - FB_ADDR) = wdata;
        //printf("IO_write FB addr:%llx wdata:%llx wmask:%x\n", waddr, wdata, (uint8_t)wmask);
        return;
    }
    #endif
    
    if(out_of_bound(waddr)) return;
    uint64_t* waddr_p = (uint64_t*)guest_to_host(waddr & ~0x7ull);
#ifdef CONFIG_MTRACE
    //printf("paddr:%llx wdata:%llx wmask:%x\n", waddr, wdata, (uint8_t)wmask);
#endif
    uint64_t wstrb;
    switch ((uint8_t)wmask) {  
        case 0x1:   wstrb = 0xf; break;
        case 0x2:   wstrb = 0xf0; break;
        case 0x4:   wstrb = 0xf00; break;
        case 0x8:   wstrb = 0xf000; break;
        case 0x10:  wstrb = 0xf0000; break;
        case 0x20:  wstrb = 0xf00000; break;
        case 0x40:  wstrb = 0xf000000; break;
        case 0x80:  wstrb = 0xf0000000; break;
        case 0x3:   wstrb = 0xff; break;
        case 0xc:   wstrb = 0xff00; break;
        case 0x30:  wstrb = 0xff0000; break;
        case 0xc0:  wstrb = 0xff000000; break;
        case 0xf:   wstrb = 0xffff; break;
        case 0xf0:  wstrb = 0xffff0000; break;
        case 0xff:  wstrb = 0xffffffff; break;
        default: assert(0);
    }
    *waddr_p = (*waddr_p & ~wmask) | (wdata & wmask);
}
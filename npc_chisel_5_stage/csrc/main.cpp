#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <termios.h>
#include <unistd.h>
#include <thread>
#include <SDL2/SDL.h>
#include <assert.h>
#include "Vtop.h"
#include <svdpi.h>
#include "verilated.h"
#include "Vtop__Dpi.h"
#include <verilated_dpi.h>
#include <verilated_vcd_c.h>
#include <dlfcn.h>
#include <time.h>

#define TIMER_HZ 60

#define DEVICE_BASE 0xa0000000
#define MMIO_BASE 0xa0000000

#define SERIAL_PORT     (DEVICE_BASE + 0x00003f8)
#define KBD_ADDR        (DEVICE_BASE + 0x0000060)
#define RTC_ADDR        (DEVICE_BASE + 0x0000048)
#define VGACTL_ADDR     (DEVICE_BASE + 0x0000100)
#define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
#define DISK_ADDR       (DEVICE_BASE + 0x0000300)
#define FB_ADDR         (MMIO_BASE   + 0x1000000)
#define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)


const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

//#define CONFIG_ITRACE
//#define CONFIG_FTRACE
//#define CONFIG_DIFFTEST  //difftest
//#define VerilatedVCD   //是否生成波形
#define batch_mode  //一键运行模式
#define HAS_VGA   //是否显示屏幕
#define HAS_AXI   //必须打开

void difftest_skip_ref();

void is_func(uint64_t pc, uint64_t dnpc,bool is_return);
void init_elf(char *elf_file);
void print_func();


int stop_status = 0;
int SDL_quite = 0;
int is_ecall = 0;

#define BITMASK(bits) ((1ull << (bits)) - 1)
#define BITS(x, hi, lo) (((x) >> (lo)) & BITMASK((hi) - (lo) + 1)) // similar to x[hi:lo] in verilog

#define MAX_SIM_TIME 5
vluint64_t sim_time = 0;
int cpu_stop = 0;
Vtop* top;
#ifdef VerilatedVCD
VerilatedVcdC* tfp;
#endif
VerilatedContext* contextp;
uint64_t pc_now;

void cpu_exec(int n);
typedef struct
{
  uint64_t gpr[32];
  uint64_t pc;
  uint64_t csr[4];
} CPU_state;

void ebreak_handle(int flag){
  cpu_stop = flag;
}

void ecall_handle(int flag){
  //if(flag)printf("ecall\n");
  is_ecall = flag;
}

void get_pc(long long pc){
  pc_now = pc;
}

uint64_t csr_reg[4];
extern "C" void set_csr_ptr(const svOpenArrayHandle r) {
  uint64_t *csr = NULL;
  csr = (uint64_t *)(((VerilatedDpiOpenVar*)r)->datap());
  for (int i = 0; i < 4; i++)
    csr_reg[i] = csr[i];
}


CPU_state ref_r;

//==========================================kEYBOARD_begin=====================================
#define KEYDOWN_MASK 0x8000
#define concat_temp(x, y) x ## y
#define MAP(c, f) c(f)
#define _KEYS(f) \
  f(ESCAPE) f(F1) f(F2) f(F3) f(F4) f(F5) f(F6) f(F7) f(F8) f(F9) f(F10) f(F11) f(F12) \
f(GRAVE) f(1) f(2) f(3) f(4) f(5) f(6) f(7) f(8) f(9) f(0) f(MINUS) f(EQUALS) f(BACKSPACE) \
f(TAB) f(Q) f(W) f(E) f(R) f(T) f(Y) f(U) f(I) f(O) f(P) f(LEFTBRACKET) f(RIGHTBRACKET) f(BACKSLASH) \
f(CAPSLOCK) f(A) f(S) f(D) f(F) f(G) f(H) f(J) f(K) f(L) f(SEMICOLON) f(APOSTROPHE) f(RETURN) \
f(LSHIFT) f(Z) f(X) f(C) f(V) f(B) f(N) f(M) f(COMMA) f(PERIOD) f(SLASH) f(RSHIFT) \
f(LCTRL) f(APPLICATION) f(LALT) f(SPACE) f(RALT) f(RCTRL) \
f(UP) f(DOWN) f(LEFT) f(RIGHT) f(INSERT) f(DELETE) f(HOME) f(END) f(PAGEUP) f(PAGEDOWN)

#define _KEY_NAME(k) _KEY_##k,

enum {
  _KEY_NONE = 0,
  MAP(_KEYS, _KEY_NAME)
};

#define SDL_KEYMAP(k) keymap[concat_temp(SDL_SCANCODE_, k)] = concat_temp(_KEY_, k);
static uint32_t keymap[256] = {};

static void init_keymap() {
  MAP(_KEYS, SDL_KEYMAP)
}

#define KEY_QUEUE_LEN 1024
static int key_queue[KEY_QUEUE_LEN] = {};
static int key_f = 0, key_r = 0;

static void key_enqueue(uint32_t am_scancode) {
  key_queue[key_r] = am_scancode;
  key_r = (key_r + 1) % KEY_QUEUE_LEN;
  assert(key_r != key_f);
}

static uint32_t key_dequeue() {
  uint32_t key = _KEY_NONE;
  if (key_f != key_r) {
    key = key_queue[key_f];
    key_f = (key_f + 1) % KEY_QUEUE_LEN;
  }
  return key;
}

void send_key(uint8_t scancode, bool is_keydown) {
  //printf("enquene %d %d\n",scancode,keymap[scancode] );
  if (cpu_stop!=1 && SDL_quite !=1 && keymap[scancode] != _KEY_NONE) {
    //printf("enquene\n");
    uint32_t am_scancode = keymap[scancode] | (is_keydown ? KEYDOWN_MASK : 0);
    key_enqueue(am_scancode);
  }
}

static uint32_t i8042_data_port_base[4];

static void i8042_data_io_handler(uint32_t offset, int len, bool is_write) {
  assert(!is_write);
  assert(offset == 0);
  i8042_data_port_base[0] = key_dequeue();
}

void init_i8042() {
  i8042_data_port_base[0] = _KEY_NONE;
  init_keymap();
}

//===========================================KEYBOARD_end======================================

//==========================================VGA_begin===========================================
#define SCREEN_W 400
#define SCREEN_H 300

uint32_t vmem[300*400];
uint32_t vgactl_port_base[8];

static uint32_t screen_width() {
  return SCREEN_W;
}

static uint32_t screen_height() {
  return SCREEN_H;
}

static uint32_t screen_size() {
  return screen_width() * screen_height() * sizeof(uint32_t);
}


static SDL_Event event;
static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;

static void init_screen() {
  SDL_Window *window = NULL;
  char title[128];
  sprintf(title, "riscv64-NPC");
  SDL_Init(SDL_INIT_VIDEO);
  SDL_CreateWindowAndRenderer(
      SCREEN_W * 2,
      SCREEN_H * 2,
      0, &window, &renderer);
  SDL_SetWindowTitle(window, title);
  texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888,
      SDL_TEXTUREACCESS_STATIC, SCREEN_W, SCREEN_H);
}

 void update_screen() {
  //printf("update\n");
  SDL_UpdateTexture(texture, NULL, vmem, SCREEN_W * sizeof(uint32_t));
  SDL_RenderClear(renderer);
  SDL_RenderCopy(renderer, texture, NULL, NULL);
  SDL_RenderPresent(renderer);
  //printf("update success\n");
}


void vga_update_screen() {
  // TODO: call `update_screen()` when the sync register is non-zero,
  // then zero out the sync register
  static uint64_t last = 0;
  struct timespec now;
  clock_gettime(CLOCK_MONOTONIC_COARSE, &now);
  uint64_t us = now.tv_sec * 1000000 + now.tv_nsec / 1000;
  if (us - last < 1000000 / TIMER_HZ) {
    return;
  }
  last = us;
  if (vgactl_port_base[1]) {
    update_screen();
    vgactl_port_base[1] = 0;
  }
  while (SDL_PollEvent(&event)) {
    switch (event.type) {
      case SDL_QUIT:
        printf("SDL quite\n");
        SDL_quite = 1;
        break;
      case SDL_KEYDOWN:
      case SDL_KEYUP: {
        //printf("has a key\n");
        uint8_t k = event.key.keysym.scancode;
        bool is_keydown = (event.key.type == SDL_KEYDOWN);
        send_key(k, is_keydown);
        //printf("%d",k);
        break;
      }
      default: break;
    }
  }
}

void init_vga() {
  //vgactl_port_base = (uint32_t *)malloc(sizeof(uint32_t)*8);
  vgactl_port_base[0] = (screen_width() << 16) | screen_height();
  //printf("%d\n", vgactl_port_base[0]);

  //vmem = malloc(screen_size());
  init_screen();
  memset(vmem, 0, screen_size());
}
//=========================================VGA_end===========================================


//===========================mem=========================
typedef uint64_t paddr_t;
#define PG_ALIGN __attribute((aligned(4096)))
#define CONFIG_MSIZE 0x8000000
#define CONFIG_MBASE 0x80000000
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {0};
uint8_t* guest_to_host(paddr_t paddr) { return paddr - CONFIG_MBASE + pmem; }
//paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static inline uint32_t host_read(void *addr) {
  return *(uint64_t *)addr;
}

 static uint32_t paddr_read(paddr_t addr) {
   uint32_t ret = host_read(guest_to_host(addr));
   return ret;
 }
time_t boot_time = 0;
extern "C" void pmem_read(long long raddr, long long *rdata) {
  // 总是读取地址为`raddr & ~0x7ull`的8字节返回给`rdata`
  // if(raddr>=DEVICE_BASE && raddr < DEVICE_BASE + 0x1200000 + 32){
  //   difftest_skip_ref();
  // }
  if(raddr>=RTC_ADDR && raddr <= RTC_ADDR+8){
    uint64_t time_now = 0;
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC_COARSE, &now);
    uint64_t us = now.tv_sec * 1000000 + now.tv_nsec / 1000;
    if(boot_time==0){
      boot_time = us;
      time_now = 0;
    }else{
      time_now = us - boot_time;
    }
    //printf("time : %lld\n",*rdata);
    if(raddr == RTC_ADDR){
      //*rdata = time_now & 0xffffffff;
      *rdata = time_now;
      //printf("read time :%lld\n",*rdata);
    }
    else if(raddr == RTC_ADDR + 4){
      *rdata = (time_now >> 32) & 0xffffffff;
      //printf("read time :%lld\n",*rdata);
    }
    return;
  }
  if(raddr >=VGACTL_ADDR && raddr <VGACTL_ADDR+32){
    //printf("base: %d\n",vgactl_port_base[0] );
    if(raddr==VGACTL_ADDR){
      //printf("read gpu size\n");
      *rdata = vgactl_port_base[0] & 0xffff;
      //*rdata = vgactl_port_base[0];
      //printf("%lld\n", *rdata);
    }else if(raddr == VGACTL_ADDR+2){
      //printf("read gpu size\n");
      *rdata = (vgactl_port_base[0]>>16);
      //printf("%lld\n", *rdata);
    }else if(raddr == VGACTL_ADDR+4){
      //printf("read gpu syn\n");
      *rdata = vgactl_port_base[1];
      //printf("%lld\n", *rdata);
    }
    #ifdef HAS_VGA
    //vga_update_screen();
    #endif
    return;
  }
  if(raddr==KBD_ADDR){
    i8042_data_port_base[0] = key_dequeue();
    *rdata = i8042_data_port_base[0];
    //if(*rdata!=0)printf("read key : %lld\n", *rdata);
    return;
  }
  if(raddr<CONFIG_MBASE||raddr>(CONFIG_MBASE+CONFIG_MSIZE)){
    //*rdata = 0;
    return;
  }
  *rdata = *((long long *)guest_to_host(raddr));
  //printf("read memory at %llx, value = %llx\n",raddr,*rdata);
  #ifdef CONFIG_MTRACE
    printf("read memory at %llx, value = %llx\n",raddr,*rdata);
  #endif
}


extern "C" void pmem_write(long long waddr, long long wdata, char wmask) {
  // 总是往地址为`waddr & ~0x7ull`的8字节按写掩码`wmask`写入`wdata`
  // `wmask`中每比特表示`wdata`中1个字节的掩码,
  // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
  // if(waddr>=DEVICE_BASE && waddr < DEVICE_BASE + 0x1200000 + 32){
  //   difftest_skip_ref();
  // }
  if(waddr==SERIAL_PORT){
    putchar((char)wdata&0xff);
    return ;
  }
  if(waddr >=VGACTL_ADDR && waddr <=VGACTL_ADDR+32){
    if(waddr==VGACTL_ADDR+4){
      //printf("write syn\n");
      //printf("syn:%lld\n",wdata);
      vgactl_port_base[1] = (uint32_t)wdata;
      return;
    }
  }
  if(waddr>=FB_ADDR && waddr<=FB_ADDR + 0x200000){
    //printf("write fb\n");
    uint64_t fb_addr = (waddr - FB_ADDR)/4;
    uint8_t* p = (uint8_t*)&vmem[fb_addr];
    for (int i = 0; i < 8; i++) {
      if (wmask & 0x1) *p = (wdata & 0xff);
      wdata >>= 8;
      wmask >>= 1;
     p++;
    }
    return;
  }
  if(waddr<CONFIG_MBASE||waddr>(CONFIG_MBASE+CONFIG_MSIZE)){
    //printf("write out of bound\n");
    return;
  }
  #ifdef CONFIG_MTRACE
    printf("write memory at %llx, mask = %x, value = %llx\n",waddr,wmask,wdata);
  #endif
  //printf("write memory at %llx, mask = %x, value = %llx\n",waddr,wmask,wdata);
  uint8_t* p = guest_to_host(waddr);
  for (int i = 0; i < 8; i++) {
    if (wmask & 0x1) *p = (wdata & 0xff);
    wdata >>= 8;
    wmask >>= 1;
    p++;
  }
}

//==========================sdb============================
CPU_state cpu_gpr;

extern "C" void set_gpr_ptr(const svOpenArrayHandle r) {
  uint64_t *gpr = NULL;
  gpr = (uint64_t *)(((VerilatedDpiOpenVar*)r)->datap());
  for (int i = 0; i < 32; i++)
        cpu_gpr.gpr[i] = gpr[i];
  cpu_gpr.pc = pc_now;
}


static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args) {
  cpu_stop = 1;
  return -1;
}

static int cmd_si(char *args){
  char *arg = strtok(NULL, " ");
  if (arg == NULL){
    cpu_exec(1);
    return 0;
  }
  int step;
  sscanf(arg,"%d",&step);
  if (step <= 0){
    return 0;
  }
  cpu_exec(step); 
  return 0;
}

void print_reg(){
  int i;
  printf("nemu_pc:%lx\n",ref_r.pc);
  for (i = 0; i < 32; i++) {
    printf("gpr[%d] %s = 0x%lx\t nemu[%d] %s = 0x%lx\n", i, regs[i], cpu_gpr.gpr[i],i, regs[i], ref_r.gpr[i]);
  }
}

static int cmd_info(char *args){
  print_reg();
  return 0;
}

static int cmd_x(char *args){
  char *num = strtok(NULL," ");
  char *addr = strtok(NULL," ");
  int gap=0;
  paddr_t paddr;
  sscanf(num,"%d",&gap);
  sscanf(addr,"%lx",&paddr);
  while(gap>0){
    printf("0x%lx:\t",paddr);
    uint32_t temp = paddr_read(paddr);
    printf("0x%x ", temp);
    printf("\n");
    paddr+=4;
    gap--;
  }
  return 0;
}

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit npc", cmd_q },

  /* TODO: Add more commands */
  { "si", "execute N step", cmd_si },
  { "info", "print infomation of registers", cmd_info },
  { "x", "scan the mem", cmd_x },
  //{ "p", "get the value of expr", cmd_p },
  //{ "w", "add a watchpoint", cmd_w },
  //{ "d", "delete a watch point", cmd_d },
};
#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))
#define NR_CMD ARRLEN(cmd_table)
int sdb_mainloop() {
  #ifndef batch_mode 
    char str[100] ;
    printf("(npc) ");
    if (fgets(str, sizeof(str), stdin) == NULL) { // 从标准输入中读取命令
        perror("fgets error");
        return 0; // 读取失败，返回错误代码
    }
    str[strcspn(str, "\n")] = '\0';
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { return 1; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }
    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return 0; }
        else return 1;
      }
    }
    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  #else
  cmd_c(NULL);
  #endif
  return 1;
}

//==============================itrace===============================
#if defined(__GNUC__) && !defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
#endif

#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCInstPrinter.h"
#if LLVM_VERSION_MAJOR >= 14
#include "llvm/MC/TargetRegistry.h"
#else
#include "llvm/Support/TargetRegistry.h"
#endif
#include "llvm/Support/TargetSelect.h"

#if defined(__GNUC__) && !defined(__clang__)
#pragma GCC diagnostic pop
#endif

#if LLVM_VERSION_MAJOR < 11
#error Please use LLVM with major version >= 11
#endif

using namespace llvm;

static llvm::MCDisassembler *gDisassembler = nullptr;
static llvm::MCSubtargetInfo *gSTI = nullptr;
static llvm::MCInstPrinter *gIP = nullptr;

extern "C" void init_disasm(const char *triple) {
  llvm::InitializeAllTargetInfos();
  llvm::InitializeAllTargetMCs();
  llvm::InitializeAllAsmParsers();
  llvm::InitializeAllDisassemblers();

  std::string errstr;
  std::string gTriple(triple);

  llvm::MCInstrInfo *gMII = nullptr;
  llvm::MCRegisterInfo *gMRI = nullptr;
  auto target = llvm::TargetRegistry::lookupTarget(gTriple, errstr);
  if (!target) {
    llvm::errs() << "Can't find target for " << gTriple << ": " << errstr << "\n";
    assert(0);
  }

  MCTargetOptions MCOptions;
  gSTI = target->createMCSubtargetInfo(gTriple, "", "");
  std::string isa = target->getName();
  if (isa == "riscv32" || isa == "riscv64") {
    gSTI->ApplyFeatureFlag("+m");
    gSTI->ApplyFeatureFlag("+a");
    gSTI->ApplyFeatureFlag("+c");
    gSTI->ApplyFeatureFlag("+f");
    gSTI->ApplyFeatureFlag("+d");
  }
  gMII = target->createMCInstrInfo();
  gMRI = target->createMCRegInfo(gTriple);
  auto AsmInfo = target->createMCAsmInfo(*gMRI, gTriple, MCOptions);
#if LLVM_VERSION_MAJOR >= 13
   auto llvmTripleTwine = Twine(triple);
   auto llvmtriple = llvm::Triple(llvmTripleTwine);
   auto Ctx = new llvm::MCContext(llvmtriple,AsmInfo, gMRI, nullptr);
#else
   auto Ctx = new llvm::MCContext(AsmInfo, gMRI, nullptr);
#endif
  gDisassembler = target->createMCDisassembler(*gSTI, *Ctx);
  gIP = target->createMCInstPrinter(llvm::Triple(gTriple),
      AsmInfo->getAssemblerDialect(), *AsmInfo, *gMII, *gMRI);
  gIP->setPrintImmHex(true);
  gIP->setPrintBranchImmAsAddress(true);
}

extern "C" void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte) {
  MCInst inst;
  llvm::ArrayRef<uint8_t> arr(code, nbyte);
  uint64_t dummy_size = 0;
  gDisassembler->getInstruction(inst, dummy_size, arr, pc, llvm::nulls());

  std::string s;
  raw_string_ostream os(s);
  gIP->printInst(&inst, pc, "", *gSTI, os);

  int skip = s.find_first_not_of('\t');
  const char *p = s.c_str() + skip;
  assert((int)s.length() - skip < size);
  strcpy(str, p);
}



//==========================itrace_end==============================

//==========================difftest================================
static int skip_dut_nr_inst = 0;
static bool is_skip_ref = false;
static bool is_skip_ref_s = false;

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
void (*ref_difftest_memcpy)(uint32_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;

void init_difftest(char *ref_so_file, long img_size) {
  assert(ref_so_file != NULL);
  
  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);
  
  ref_difftest_memcpy = (void (*)(uint32_t addr, void *buf, size_t n, bool direction))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);
  
  ref_difftest_regcpy = (void (*)(void *dut, bool direction))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);
  
  ref_difftest_exec = (void (*)(uint64_t n))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr = (void (*)(uint64_t NO))dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);

  void (*ref_difftest_init)(int) = (void (*)(int port))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);


  ref_difftest_init(1);
  ref_difftest_memcpy(CONFIG_MBASE, pmem, img_size, DIFFTEST_TO_REF);
  ref_difftest_regcpy(&cpu_gpr, DIFFTEST_TO_REF);
}

void difftest_skip_dut(int nr_ref, int nr_dut) {
  skip_dut_nr_inst += nr_dut;

  while (nr_ref -- > 0) {
    ref_difftest_exec(1);
  }
}

void difftest_skip_ref() {
  is_skip_ref = true;
  skip_dut_nr_inst = 0;
}

bool isa_difftest_checkregs(CPU_state *ref_r, uint64_t pc) {
  //printf("check pc:%lx\n",pc);
  if(cpu_stop)return true;
  // if(ref_r->pc != pc){
  //   printf("wrong pc %lx: npc = %lx   ref = %lx\n",pc, pc, ref_r->pc);
  //   return false;
  // }
  for (int i = 0; i < 32; i++) {
    if(ref_r->gpr[i] != cpu_gpr.gpr[i])
      {
        printf("Unmatched reg value at pc : %lx  reg%d %s: npc = %lx  ref = %lx\n", pc, i, regs[i],cpu_gpr.gpr[i], ref_r->gpr[i]);
        return false;
      }
  }
  return true;
}

static void checkregs(CPU_state *ref, uint64_t pc) {
  if (!isa_difftest_checkregs(ref, pc)) {
    print_reg();
    stop_status = 1;
    cpu_stop = 1;
  }
}

void difftest_step(uint64_t pc) {
  if (top->io_skip) {
    //printf("skip pc:%lx\n",pc);
    // to skip the checking of an instruction, just copy the reg state to reference design
    //printf("%lx %lx\n", cpu_gpr.pc, pc_now);
    //ref_difftest_regcpy(&cpu_gpr, DIFFTEST_TO_REF);
    is_skip_ref_s = true;
    return;
  }
  if(is_skip_ref_s){
    ref_difftest_regcpy(&cpu_gpr, DIFFTEST_TO_REF);
    ref_difftest_exec(1);
    is_skip_ref_s = false;
    return;
  }
  // if(is_ecall){
  //   printf("ecall\n");
  //   // ref_difftest_raise_intr(csr_reg[3]);
  //   // return;
  // }
  ref_difftest_exec(1);
  ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
  checkregs(&ref_r, pc);

}

//==========================difftest_end============================



//==========================load_img================================
void load_img(){
  
  char img_file[] = "../npc/image.bin";
  FILE *fp = fopen(img_file, "rb");
  
  fseek(fp, 0, SEEK_END);
  
  long long size = ftell(fp);
  
  fseek(fp, 0, SEEK_SET);
  
  int ret = fread(guest_to_host(CONFIG_MBASE), size, 1, fp);
  
  fclose(fp);
}
//============================load_img_end===========================
#ifdef CONFIG_ITRACE
FILE* log_file = fopen("../npc/npc-log.txt","w+");
#endif


void cpu_exec(int n){
  int flag = 0;
  if(n<0)flag=1;
  while (!cpu_stop && (flag==1||n--) && !SDL_quite) {
      top->reset = 0;
      top->clock ^= 1;
      top->eval();
      top->clock ^= 1;
      top->eval();
      //printf("%lx %x\n",top->io_pc , top->io_inst);
      //printf("%d\n",sim_time);
      #ifdef CONFIG_ITRACE
    char p[1024];
    char *s = p;
    s += snprintf(s, sizeof(p), "0x%016lx:", top->io_pc);
    s += snprintf(s, 16, " %08x", top->io_inst);
    //printf("%s\n", p);
    memset(s, ' ', 1);
    s += 1;
    disassemble(s, 256, top->io_pc, (uint8_t*)guest_to_host(top->io_pc), 4);
    //printf("%s\n", p);
    if(fputs(p, log_file)==EOF)exit(0);
    fputc('\n', log_file);
#endif
#ifdef CONFIG_FTRACE
    if(top->io_inst==0x8067){
      is_func(top->io_pc,top->io_pc, true);
    }
    else if(BITS(top->io_inst, 6, 0)==0x6f || (BITS(top->io_inst, 6, 0)==0x67 && BITS(top->io_inst, 11, 7)!=0x0)){
      is_func(top->io_pc,top->io_pc_next, false);
    }
#endif
#ifdef CONFIG_DIFFTEST
#ifdef HAS_AXI
    if(top->io_step){
      difftest_step(pc_now);
    }
#else
    difftest_step(pc_now);
#endif
#endif
    #ifdef VerilatedVCD
    tfp->dump(sim_time); //dump wave
    #endif
    #ifdef HAS_VGA
    vga_update_screen();
    #endif
    sim_time++;
  }
}


int main(int argc, char** argv) {
  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  top = new Vtop{contextp};
  #ifdef VerilatedVCD
  tfp = new VerilatedVcdC; //初始化VCD对象指针
  contextp->traceEverOn(true); //打开追踪功能
  top->trace(tfp, 0);
  tfp->open("wave.vcd"); //设置输出的文件wave.vcd
  #endif
  load_img();
  printf("image succuss\n");
  #ifdef HAS_VGA
  init_vga();
  init_i8042();
  #endif
  #ifdef CONFIG_ITRACE
  init_disasm("riscv64");
  #endif
  #ifdef CONFIG_FTRACE
  char elf_file[] = "../npc/image.elf";
  init_elf(elf_file);
  printf("elf succuss\n");
  #endif
  while (sim_time<3)
  {
    top->reset = 1;
    top->clock = 0;
    top->eval();
    top->clock = 1;
    top->eval();
    sim_time++;
  }
  cpu_gpr.pc = 0x80000000;
  #ifdef CONFIG_DIFFTEST
  char difftest_file[] = "../nemu/build/riscv64-nemu-interpreter-so";
  printf("so succuss\n");
  init_difftest(difftest_file,CONFIG_MSIZE);
  #endif
  while(sdb_mainloop() && !cpu_stop && !SDL_quite);
  //printf("%llx\n",*((long long *)(0x8204de98 - CONFIG_MBASE + pmem)));
  //printf("%lld %x\n",write_data,write_mask);
  if(stop_status==0)printf("\33[1;32mHIT GOOD TRAP\n\33[0m");
  else printf("\33[1;31mHIT BAD TRAP\n\33[0m");
  delete top;
  #ifdef VerilatedVCD
  tfp->close();
  #endif
  delete contextp;
  #ifdef CONFIG_FTRACE
  print_func(); 
  #endif
  return 0;
}

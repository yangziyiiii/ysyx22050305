#ifndef __COMMON_H__
#define __COMMON_H__

#define CONFIG_ITRACE
//#define CONFIG_MTRACE
//#define CONFIG_FTRACE
//#define CONFIG_DTRACE
// #define CONFIG_DIFFTEST
#define CONFIG_DEVICE
#define BATCH_MODE
#define CONFIG_HAS_KEYBOARD

#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <dlfcn.h>

#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))
#define RESET_VECTOR 0x80000000
#define BITMASK(bits) ((1ull << (bits)) - 1)
#define BITS(x, hi, lo) (((x) >> (lo)) & BITMASK((hi) - (lo) + 1)) // similar to x[hi:lo] in verilog
#define MAP(c, f) c(f)
#define concat_temp(x, y) x ## y
#define concat(x, y) concat_temp(x, y)

typedef __uint64_t word_t;
typedef __uint64_t paddr_t;
typedef __uint64_t vaddr_t;

//instrom
extern uint32_t inst_rom[100000];

enum { NPC_RUNNING, NPC_STOP, NPC_END, NPC_ABORT, NPC_QUIT };

typedef struct {
  int state;
  vaddr_t halt_pc;
  uint32_t halt_ret;
} NPCState;

extern NPCState npc_state;

typedef struct {
  word_t gpr[32];
  vaddr_t pc;
} CPU_state;

extern CPU_state npc_cpu;

#endif

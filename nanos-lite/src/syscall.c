#include <common.h>
#include <fs.h>
#include <sys/time.h>
#include "syscall.h"
#include <proc.h>

/*return 0 for success, or -1 for failure*/
static int gettime(struct timeval *tv, struct timezone *tz)
{
    uint64_t usec = io_read(AM_TIMER_UPTIME).us;
    tv->tv_sec  = usec / 1000000;
    tv->tv_usec = usec % 1000000;
    return 0;
}

void naive_uload(PCB *pcb, const char *filename);

void do_syscall(Context *c) {
  uintptr_t a[4];
  a[0] = c->GPR1;
  a[1] = c->GPR2;
  a[2] = c->GPR3;
  a[3] = c->GPR4;
  #ifdef STRACE
  printf("syscall ID = %d\n", a[0]);
  #endif
  switch (a[0]) {
    // case SYS_exit: naive_uload(NULL, "/bin/nterm"); break;
    case SYS_exit:  yield(); c->GPRx = 0; break;
    case SYS_yield: yield(); c->GPRx = 0; break;
    case SYS_open:  c->GPRx = fs_open((char*)a[1], a[2], a[3]); break;
    case SYS_read:  c->GPRx = fs_read(a[1], (void*)a[2], a[3]); break;
    case SYS_write: c->GPRx = fs_write(a[1], (void*)a[2], a[3]); break;
    case SYS_close: c->GPRx = fs_close(a[1]); break;
    case SYS_lseek: c->GPRx = fs_lseek(a[1], a[2], a[3]); break;
    case SYS_brk: c->GPRx = 0; break;
    case SYS_execve: naive_uload(NULL, (char*)a[1]); break;
    case SYS_gettimeofday: 
      c->GPRx = gettime((struct timeval *)a[1], (struct timezone *)a[2]); 
      break;
    default: panic("Unhandled syscall ID = %d", a[0]);
  }
}

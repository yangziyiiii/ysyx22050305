#include <common.h>
#include "syscall.h"

size_t fs_lseek(int fd, size_t offset, int whence);
int fs_open(const char *pathname, int flags, int mode);
size_t fs_write(int fd, const void *buf, size_t len);
size_t fs_read(int fd, void *buf, size_t len);
long int gettimeofday();
char* get_syscall_name(uintptr_t type);


int sys_write(int fd, void *buf, size_t count) {
  if(fd==1 || fd==2){
    for(size_t i = 0; i < count; i++){
      putch(*(char *)(buf+i));
    }
  }
  return count;  
}

void do_syscall(Context *c) {
  uintptr_t a[4];
  a[0] = c->GPR1;
  a[1] = c->GPR2;
  a[2] = c->GPR3;
  a[3] = c->GPR4;
  
  switch (a[0]) {
    case SYS_yield:{ printf(" SYS_yield = %d\n", a[0]); break;}
    case SYS_exit: { halt(a[1]); break;}
    case SYS_open: { c->GPRx = fs_open((char *)a[1],a[2],a[3]); break;}
    case SYS_read: { c->GPRx = fs_read(a[1],(char *)a[2],a[3]); break;}
    case SYS_write:{ c->GPRx = sys_write(a[1],(void *)a[2],a[3]); break;}
    case SYS_lseek:{ c->GPRx = fs_lseek(a[1],a[2],a[3]);break;}
    case SYS_close:{ c->GPRx = 0;break;}
    case SYS_brk:  { c->GPRx = 0;break;}
    case SYS_gettimeofday:{c->GPRx = gettimeofday();break;}
    default: panic("Unhandle default syscall ID = %d", a[0]);
  }

#ifdef CONFIG_STRACE
  char* getFinfoName(int i);
  type = a[0];
  if(type == SYS_open|| type == SYS_read || type == SYS_write || type == SYS_close || type == SYS_lseek){
    if(type == SYS_open) printf("strace detect file %s is doing %s :",a[0], get_syscall_name(type));
    else printf("strace detect file %s is doing %s :",getFinfoName(a[0]), get_syscall_name(type));
  }
  else{
    printf("strace detect syscall: %s, ",get_syscall_name(type));
  }
  printf("input regs a0=0x%lx, a1=0x%lx, a2=0x%lx, return value a0=0x%lx.\n",a[0],a[1],a[2],c->GPRx);
#endif

}

#ifdef CONFIG_STRACE
char* get_syscall_name(uintptr_t type){
  static char SyscallInfo[20];
  switch (type) {
    case SYS_exit         : strcpy(SyscallInfo,"sys_exit");         break;
    case SYS_yield        : strcpy(SyscallInfo,"sys_yield");        break;
    case SYS_open         : strcpy(SyscallInfo,"sys_open");         break;
    case SYS_read         : strcpy(SyscallInfo,"sys_read");         break;
    case SYS_write        : strcpy(SyscallInfo,"sys_write");        break;
    case SYS_kill         : strcpy(SyscallInfo,"sys_kill");         break;
    case SYS_getpid       : strcpy(SyscallInfo,"sys_getpid");       break;
    case SYS_close        : strcpy(SyscallInfo,"sys_close");        break;
    case SYS_lseek        : strcpy(SyscallInfo,"sys_lseek");        break;
    case SYS_brk          : strcpy(SyscallInfo,"sys_brk");          break;
    case SYS_fstat        : strcpy(SyscallInfo,"sys_fstat");        break;
    case SYS_time         : strcpy(SyscallInfo,"sys_time");         break;
    case SYS_signal       : strcpy(SyscallInfo,"sys_signal");       break;
    case SYS_execve       : strcpy(SyscallInfo,"sys_execve");       break;
    case SYS_fork         : strcpy(SyscallInfo,"sys_fork");         break;
    case SYS_link         : strcpy(SyscallInfo,"sys_link");         break;
    case SYS_unlink       : strcpy(SyscallInfo,"sys_unlink");       break;
    case SYS_wait         : strcpy(SyscallInfo,"sys_wait");         break;
    case SYS_times        : strcpy(SyscallInfo,"sys_times");        break;
    case SYS_gettimeofday : strcpy(SyscallInfo,"sys_gettimeofday"); break;
    default: panic("Unhandled syscall ID = %d", type);
  }
  return SyscallInfo;
}
#endif
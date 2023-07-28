#include <stdio.h>
#include <sys/time.h>
#include "NDL.h"

int main() {
  printf("timer-test!\n");
  int i = 1;
  NDL_Init(0);
  uint32_t begintime = NDL_GetTicks(); 
  while (1) {
    uint32_t us = NDL_GetTicks(); 
    if (us - begintime >= 500*i) {
      printf("timer-test from Navy-apps for the %dth time!\n", i ++);
    }
  }
  return 0;
}

#include <stdio.h>
#include <sys/time.h>
#include "NDL.h"

int main() {
  NDL_Init(0);
  int count = 0;
  while(1){
    long long time = NDL_GetTicks();
    if(time/500 >=count){
      count++;
      printf("hello from timer-test with count %d\n",count);
    }
    printf("%d count: %d\n", time, count);
  }
  NDL_Quit();
  return 0;
}

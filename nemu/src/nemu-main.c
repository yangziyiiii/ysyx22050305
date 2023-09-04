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

#include <common.h>

void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();
word_t expr(char *e, bool *success);

int main(int argc, char *argv[]) {
  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

  /* Start engine. */
  engine_start();

  /* test expr */
  /*FILE * fp;
  fp = fopen ("$(NEMU_HOME)/tools/gen-expr/input", "r");
  assert(fp!=NULL);
  int i;
  uint32_t value;
  char e[100];
  bool success;
  success = true;
  for(i=1;i<=100;i++){
    if(fscanf(fp, "%u %[^\n]", &value, e)<0)
      printf("fscanf error\n");
    if((uint32_t)expr(e,&success)!= value)
      printf("expr error: %d, %u, %s=%u\n", i, (uint32_t)expr(e,&success), e, value);
    if(success == false)
      printf("token error: %d\n", i);
  }
  fclose(fp);
  */
  return is_exit_status_bad();
}

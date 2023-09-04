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

#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"

static int is_batch_mode = true;
extern NPCState npc_state;

void init_regex();
void init_wp_pool();
void cpu_exec(uint64_t n);
void dump_gpr();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char *rl_gets()
{
  static char *line_read = NULL;

  if (line_read)
  {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(npc) ");

  if (line_read && *line_read)
  {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args)
{
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args)
{
  npc_state.state = NPC_QUIT;
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args)
{
  char *arg = strtok(args, " ");
  if (arg == NULL)
  {
    cpu_exec(1);
    return 0;
  }
  else
  {
    int n = atoi(arg);
    cpu_exec(n);
    return 0;
  }
}

static int cmd_info(char *args)
{
  char *arg = strtok(args, " ");
  if (arg == NULL)
  {
    printf("info r for reg, info w for watch point\n");
  }
  else if (strcmp(arg, "r") == 0)
  {
    dump_gpr();
  }
  else if (strcmp(arg, "w") == 0)
  {
    display_wp();
  }
  else
  {
    printf("Unknown command info '%s'\n", arg);
  }
  return 0;
}
/*
static int cmd_x(char *args)
{
  char *arg = strtok(args, " ");
  if (arg == NULL)
  {
    printf("x N EXPR: Evaluate the expression EXPR and use the result as \
    starting memory Address, output in hexadecimal form of N consecutive 4 bytes\n");
    return 1;
  }
  int n = atoi(arg);
  char *e = strtok(NULL, " ");
  if (e == NULL)
  {
    printf("x N EXPR: Evaluate the expression EXPR and use the result as \
    starting memory Address, output in hexadecimal form of N consecutive 4 bytes\n");
    return 1;
  }
  vaddr_t vaddr;
  sscanf(e, "0x%lx", &vaddr);
  int i;
  for (i = 0; i < n; i++)
  {
    printf("0x%.16lx: ", vaddr);
    word_t data = vaddr_read(vaddr, 4);
    printf("%.8lx ", data);
    vaddr += 4;
    printf("\n");
  }
  return 0;
}
*/
static int cmd_p(char *args)
{
  bool success = true;
  word_t value = expr(args, &success);
  if (!success)
  {
    printf("wrong expression\n");
  }
  else
    printf("0x%lx\n", value);
  return 0;
}

static int cmd_w(char *args)
{
  new_wp(args);
  return 0;
}

static int cmd_d(char *args)
{
  free_wp(args);
  return 0;
}

static struct
{
  const char *name;
  const char *description;
  int (*handler)(char *);
} cmd_table[] = {
    {"help", "Display information about all supported commands", cmd_help},
    {"c", "Continue the execution of the program", cmd_c},
    {"q", "Exit NEMU", cmd_q},
    {"si", "Single step N(<10) instructions", cmd_si},
    {"info", "Print program status(r for reg, w for watch point)", cmd_info},
    //{"x", "Scan memory", cmd_x},
    {"p", "Expression evaluation", cmd_p},
    {"w", "Set up watch points", cmd_w},
    {"d", "Delete watch points", cmd_d}
    /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args)
{
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL)
  {
    /* no argument given */
    for (i = 0; i < NR_CMD; i++)
    {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else
  {
    for (i = 0; i < NR_CMD; i++)
    {
      if (strcmp(arg, cmd_table[i].name) == 0)
      {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}


void sdb_mainloop()
{
  #ifdef BATCH_MODE
    cmd_c(NULL);
    return;
  #endif
  for (char *str; (str = rl_gets()) != NULL;)
  {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL)
    {
      continue;
    }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end)
    {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i++)
    {
      if (strcmp(cmd, cmd_table[i].name) == 0)
      {
        if (cmd_table[i].handler(args) < 0)
        {
          return;
        }
        break;
      }
    }

    if (i == NR_CMD)
    {
      printf("Unknown command '%s'\n", cmd);
    }
  }
}

void init_sdb()
{
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}

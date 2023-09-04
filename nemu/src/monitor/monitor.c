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

#include <isa.h>
#include <memory/paddr.h>

void init_rand();
void init_log(const char *log_file);
void init_mem();
void init_difftest(char *ref_so_file, long img_size, int port);
void init_device();
void init_sdb();
void init_disasm(const char *triple);

static void welcome() {
  Log("Trace: %s", MUXDEF(CONFIG_TRACE, ANSI_FMT("ON", ANSI_FG_GREEN), ANSI_FMT("OFF", ANSI_FG_RED)));
  IFDEF(CONFIG_TRACE, Log("If trace is enabled, a log file will be generated "
        "to record the trace. This may lead to a large log file. "
        "If it is not necessary, you can disable it in menuconfig"));
  Log("Build time: %s, %s", __TIME__, __DATE__);
  printf("Welcome to %s-NEMU!\n", ANSI_FMT(str(__GUEST_ISA__), ANSI_FG_YELLOW ANSI_BG_RED));
  printf("For help, type \"help\"\n");

}

#ifndef CONFIG_TARGET_AM
#include <getopt.h>

void sdb_set_batch_mode();

static char *log_file = NULL;
static char *diff_so_file = NULL;
static char *img_file = NULL;
static int difftest_port = 1234;


static long load_img() {
  if (img_file == NULL) {
    Log("No image is given. Use the default build-in image.");
    return 4096; // built-in image size
  }

  FILE *fp = fopen(img_file, "rb");
  Assert(fp, "Can not open '%s'", img_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  Log("The image is %s, size = %ld", img_file, size);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
  assert(ret == 1);

  fclose(fp);
  return size;
}

#ifdef CONFIG_FTRACE
#include <elf.h>
#include "sdb/sdb.h"
Elf64_Sym *symtab;
char strtab[100000];

Functab functab[1024]; 
int functab_len;
static int elf_load(){
  char elf[128];
  strcpy(elf, img_file);
  elf[strlen(img_file)-3] = '\0';
  strcat(elf, "elf");

  FILE *fp = fopen(elf, "r");

  Assert(fp, "Can not open '%s'", elf);
  
  Elf64_Ehdr elf_head;
  int a;
  a = fread(&elf_head, sizeof(Elf64_Ehdr), 1, fp);
  Assert(a, "fail to fread ELF_head");

  if (elf_head.e_ident[0] != 0x7F ||
      elf_head.e_ident[1] != 'E' ||
      elf_head.e_ident[2] != 'L' ||
      elf_head.e_ident[3] != 'F')
  {
    printf("Not a ELF file\n");
    assert(0);
  }
  // 解析section 分配内存 section * 数量
	Elf64_Shdr *shdr = (Elf64_Shdr*)malloc(sizeof(Elf64_Shdr) * elf_head.e_shnum);
  Assert(shdr, "shdr malloc failed");

	// 设置fp偏移量 offset，e_shoff含义
	a = fseek(fp, (long int)elf_head.e_shoff, SEEK_SET); //fseek调整指针的位置，采用参考位置+偏移量
  Assert((a==0), "fail to fseek");

	// 读取section 到 shdr, 大小为shdr * 数量
	a = fread(shdr, sizeof(Elf64_Shdr) * elf_head.e_shnum, 1, fp);
  Assert(a, "fail to read section");

	// 重置指针位置到文件流开头
	rewind(fp);
  int symtab_len=0;
	// 遍历
	for (int i = 0; i < elf_head.e_shnum; i++)
	{
    if(shdr[i].sh_type == SHT_SYMTAB){
      symtab = (Elf64_Sym*)malloc(shdr[i].sh_size);
      symtab_len = shdr[i].sh_size / sizeof(Elf64_Sym);
	    a = fseek(fp, shdr[i].sh_offset, SEEK_SET);
      Assert((a==0), "fail to fseek");
      a = fread(symtab, shdr[i].sh_size, 1, fp);
      Assert(a, "fail to read symtab");
    }
		if(shdr[i].sh_type == SHT_STRTAB && i != elf_head.e_shstrndx){
      a = fseek(fp, shdr[i].sh_offset, SEEK_SET);
      Assert((a==0), "fail to fseek");
      a = fread(strtab, shdr[i].sh_size, 1, fp);
      Assert(a, "fail to read strtab");
    } 
	 }
  free(shdr); 
  fclose(fp);
  for(int i=0;i < symtab_len; i++){
    if(ELF64_ST_TYPE(symtab[i].st_info) == STT_FUNC){
      strcpy(functab[functab_len].name, strtab+symtab[i].st_name);
      functab[functab_len].start = symtab[i].st_value;
      functab[functab_len].size = symtab[i].st_size;
      functab_len++;
    }
  }
  return 0;
}
#endif

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"    , no_argument      , NULL, 'b'},
    {"log"      , required_argument, NULL, 'l'},
    {"diff"     , required_argument, NULL, 'd'},
    {"port"     , required_argument, NULL, 'p'},
    {"help"     , no_argument      , NULL, 'h'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "-bhl:d:p:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'p': sscanf(optarg, "%d", &difftest_port); break;
      case 'l': log_file = optarg; break;
      case 'd': diff_so_file = optarg; break;
      case 1: img_file = optarg; 
        IFDEF(CONFIG_FTRACE, elf_load());
        return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-l,--log=FILE           output log to FILE\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

void init_monitor(int argc, char *argv[]) {
  /* Perform some global initialization. */

  /* Parse arguments. */
  parse_args(argc, argv);

  /* Set random seed. */
  init_rand();

  /* Open the log file. */
  init_log(log_file);

  /* Initialize memory. */
  init_mem();

  /* Initialize devices. */
  IFDEF(CONFIG_DEVICE, init_device());

  /* Perform ISA dependent initialization. */
  init_isa();

  /* Load the image to memory. This will overwrite the built-in image. */
  long img_size = load_img();

  /* Initialize differential testing. */
  init_difftest(diff_so_file, img_size, difftest_port);

  /* Initialize the simple debugger. */
  init_sdb();

  IFDEF(CONFIG_ITRACE, init_disasm(
    MUXDEF(CONFIG_ISA_x86,     "i686",
    MUXDEF(CONFIG_ISA_mips32,  "mipsel",
    MUXDEF(CONFIG_ISA_riscv32, "riscv32",
    MUXDEF(CONFIG_ISA_riscv64, "riscv64", "bad")))) "-pc-linux-gnu"
  ));

  /* Display welcome message. */
  welcome();
}
#else // CONFIG_TARGET_AM
static long load_img() {
  extern char bin_start, bin_end;
  size_t size = &bin_end - &bin_start;
  Log("img size = %ld", size);
  memcpy(guest_to_host(RESET_VECTOR), &bin_start, size);
  return size;
}

void am_init_monitor() {
  init_rand();
  init_mem();
  init_isa();
  load_img();
  IFDEF(CONFIG_DEVICE, init_device());
  welcome();
}
#endif

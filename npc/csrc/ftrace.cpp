#include"include/common.h"

#ifdef CONFIG_FTRACE
#include <elf.h>

static Elf64_Sym *symtab;
static char strtab[100000];

typedef struct {
    char name[64];
    paddr_t start;    
    size_t size;        
}Functab;      

static Functab functab[1024]; 
static int functab_len;

int elf_load(){
  char elf[] = "/home/yzy/ysyx-workbench/npc/image.elf";

  FILE *fp = fopen(elf, "r");

  assert(fp);
  
  Elf64_Ehdr elf_head;
  int a;
  a = fread(&elf_head, sizeof(Elf64_Ehdr), 1, fp);
  assert(a);

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
    assert(shdr);

	// 设置fp偏移量 offset，e_shoff含义
	a = fseek(fp, (long int)elf_head.e_shoff, SEEK_SET); //fseek调整指针的位置，采用参考位置+偏移量
    assert(a==0);

	// 读取section 到 shdr, 大小为shdr * 数量
	a = fread(shdr, sizeof(Elf64_Shdr) * elf_head.e_shnum, 1, fp);
    assert(a);

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
      assert(a==0);
      a = fread(symtab, shdr[i].sh_size, 1, fp);
      assert(a);
    }
		if(shdr[i].sh_type == SHT_STRTAB && i != elf_head.e_shstrndx){
      a = fseek(fp, shdr[i].sh_offset, SEEK_SET);
      assert((a==0));
      a = fread(strtab, shdr[i].sh_size, 1, fp);
      assert(a);
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

static int n = 0;
void ftrace(uint32_t inst){
  int rs1 = BITS(inst, 19, 15);
  int rd = BITS(inst, 11, 7);
  int op = BITS(inst, 6, 0);
  if(op == 0x67 && rs1 == 1 && rd == 0){
    for(int i=0; i<functab_len; i++){
      if(npc_cpu.pc >= functab[i].start && npc_cpu.pc < functab[i].start+functab[i].size){
        if(strcmp(functab[i].name, "putch") && strcmp(functab[i].name, "printf")){
          printf("%*cret: %s pc: %lx\n", n-1, ' ', functab[i].name, npc_cpu.pc);
          n--;
          break;
        }
      }
    }
  }else if((op == 0x67 || op == 0x6f) && rd == 1){
    for(int i=0; i<functab_len; i++){
      if(npc_cpu.pc >= functab[i].start && npc_cpu.pc < functab[i].start+functab[i].size){
        if(strcmp(functab[i].name, "putch") && strcmp(functab[i].name, "printf")){
          n++;
          printf("%*ccall: %s pc: %lx\n", n, ' ', functab[i].name, npc_cpu.pc);
          break;
        }
      }
    }
  }
}
#endif
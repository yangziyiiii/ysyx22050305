
#include <elf.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>

char strtab[10000];
Elf64_Sym symtab[200];
int symtab_entry_num = 0;
typedef struct
{
    uint64_t addr;
    uint64_t size;
    char* name;
}Func;

Func funcs[64];
int func_num = 0;

char ftrace_buf_pc[1024][100];
char ftrace_buf_dnpc[1024][100];
int ftrace_num = 0;
int ftrace_dep = 0;
int empty_num[1024]={0};
int tab_flag = 0;//0代表上次是call， 1代表上次是ret

void is_func(uint64_t pc, uint64_t dnpc,bool is_return){
    //printf("%lx\n",dnpc);
    for(int i =0;i<func_num;i++){
        if(dnpc>=funcs[i].addr && dnpc<funcs[i].addr+funcs[i].size){
            if(is_return){
                empty_num[ftrace_num] = tab_flag ? empty_num[ftrace_num-1]-1 : empty_num[ftrace_num-1];
                sprintf( ftrace_buf_pc[ftrace_num], "%lx:", pc);
                sprintf( ftrace_buf_dnpc[ftrace_num], " ret[%s]",funcs[i].name);
                tab_flag = 1;
            }
            else{
                if(ftrace_num!=0)empty_num[ftrace_num] = tab_flag ? empty_num[ftrace_num-1] : empty_num[ftrace_num-1]+1;
                sprintf(ftrace_buf_pc[ftrace_num], "%lx:", pc);
                sprintf(ftrace_buf_dnpc[ftrace_num], " call[%s@%lx]",funcs[i].name, funcs[i].addr);
                tab_flag = 0;
            }
            ftrace_num++;
        }
    }
}


void init_elf(char *elf_file){
    //printf("%s\n",elf_file);
    FILE *fp = fopen(elf_file, "r");
    //assert(fp, "Can not open '%s'", elf_file);
    fseek(fp, 0L, SEEK_SET);
    Elf64_Ehdr *ehdr = (Elf64_Ehdr*)malloc(sizeof(Elf64_Ehdr));
    if(fread(ehdr, sizeof(Elf64_Ehdr), 1, fp)==0){
        assert(0);
    }
    //printf("1\n");
    Elf64_Shdr shdr[64];
    fseek(fp, ehdr->e_shoff, SEEK_SET);
    if(fread(shdr, sizeof(Elf64_Shdr), ehdr->e_shnum, fp)==0){
        assert(0);
    }
    //printf("1\n");
    int symtab_num=-1, strtab_num=-1;
    for(int i = 0; i < ehdr->e_shnum; i++){
        if(shdr[i].sh_type==SHT_SYMTAB)symtab_num = i;
        if(shdr[i].sh_type==SHT_STRTAB){
            strtab_num = i;
            if(symtab_num!=-1)break;
        }
    }
    //printf("%d %d\n", symtab_num, strtab_num);
    fseek(fp, shdr[symtab_num].sh_offset, SEEK_SET);
    if(fread(symtab, 1, shdr[symtab_num].sh_size, fp)==0){
        assert(0);
    }
    //printf("1\n");
    fseek(fp, shdr[strtab_num].sh_offset, SEEK_SET);
    if(fread(strtab, 1, shdr[strtab_num].sh_size, fp)==0){
        assert(0);
    }
    //printf("1\n");
    symtab_entry_num = shdr[symtab_num].sh_size/shdr[symtab_num].sh_entsize;
    //printf("%d\n", symtab_entry_num);
    for(int i = 0;i< symtab_entry_num;i++){
        if(ELF64_ST_TYPE(symtab[i].st_info)==STT_FUNC){
            funcs[func_num].size = symtab[i].st_size;
            funcs[func_num].addr = symtab[i].st_value;
            funcs[func_num].name = (char*)(strtab + symtab[i].st_name);
            //printf("%ld %s\n",funcs[func_num].size,funcs[func_num].name);
            func_num++;
        }
    }
    free(ehdr);
    //printf("%d\n",func_num);
}

void print_func(){
    printf("==================ftrace====================\n");
    for(int i = 0;i< ftrace_num;i++){
        printf("%s", ftrace_buf_pc[i]);
        while(empty_num[i]--){
            printf(" ");
        }
        printf("%s\n",ftrace_buf_dnpc[i]);
    }
}
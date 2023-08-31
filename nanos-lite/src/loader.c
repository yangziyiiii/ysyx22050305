#include <proc.h>
#include <elf.h>
#include <fs.h>

#ifdef __LP64__
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
#endif

#if defined(__ISA_AM_NATIVE__)
# define EXPECT_TYPE EM_X86_64
#elif defined(__ISA_X86__)
# define EXPECT_TYPE EM_IA_64
#elif defined(__ISA_MIPS32__)
# define EXPECT_TYPE EM_MIPS
#elif defined(__ISA_RISCV32__) || defined(__ISA_RISCV64__)
# define EXPECT_TYPE EM_RISCV
#elif
# error unsupported ISA __ISA__
#endif



// static uintptr_t loader(PCB *pcb, const char *filename) {
//   Log("loader %s",filename);

//   // 调用文件系统接口打开文件
//   int fd = fs_open(filename, 0, 0);
//   Log("fd:%d",fd);

//   //读取 ELF 文件头
//   Elf64_Ehdr ehdr;
//   fs_read(fd, &ehdr, sizeof(ehdr));

//   // 遍历 ELF 文件中的所有程序头
//   Elf64_Phdr phdr;
//   for(int i =0;i<ehdr.e_phnum;i++){
//     // 根据程序头的偏移量读取程序头
//     fs_lseek(fd,ehdr.e_phoff+sizeof(Elf64_Phdr)*i,0);
//     fs_read(fd,&phdr,sizeof(Elf_Phdr));
//     // 如果程序头的类型是 PT_LOAD，说明这是一个需要加载到内存中的段
//     if(phdr.p_type==PT_LOAD){
//       // 根据程序头指定的偏移量，读取该段在文件中的内容，并将其写入内存中指定的地址
//       fs_lseek(fd,phdr.p_offset,0);
//       fs_read(fd,(void *)phdr.p_vaddr,phdr.p_memsz);

//       fs_lseek(fd,phdr.p_filesz,0);
//       printf("phdr.p_vaddr:%d\n",phdr.p_filesz);

//       // 如果文件中该段的长度小于内存中的长度，需要用 0 来填充剩余部分
//       for(long long int j = phdr.p_filesz;j<phdr.p_memsz;j++){
//         *(char *)(j+phdr.p_vaddr) = 0; 
//       }
//     }
//   }
//   Log("loader %s down",filename);
//   return ehdr.e_entry;
// }


static uintptr_t loader(PCB *pcb, const char *filename) {
  Elf_Ehdr ehdr;
  Elf_Phdr phdr;
  // read elf header
  int fd = fs_open(filename, 0, 0);
  printf("fd: %d\n", fd);
  fs_read(fd, &ehdr, sizeof(Elf_Ehdr));

  assert(*(uint32_t *)ehdr.e_ident == 0x464c457f);
  assert(ehdr.e_machine == EXPECT_TYPE);

  // read program header
  for (int i = 0; i < ehdr.e_phnum; i++){
    fs_lseek(fd, ehdr.e_phoff + i * ehdr.e_phentsize, SEEK_SET);
    fs_read(fd, &phdr, ehdr.e_phentsize);
    if (phdr.p_type == PT_LOAD){
      fs_lseek(fd, phdr.p_offset, SEEK_SET);
      fs_read(fd, (void *)phdr.p_vaddr, phdr.p_filesz);
      memset((void *)(phdr.p_vaddr + phdr.p_filesz), 0, phdr.p_memsz - phdr.p_filesz);
    }
  }
  fs_close(fd);
  return ehdr.e_entry;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  ((void(*)())entry) ();
}

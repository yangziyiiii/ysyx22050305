#include <fs.h>

typedef size_t (*ReadFn) (void *buf, size_t offset, size_t len);
typedef size_t (*WriteFn) (const void *buf, size_t offset, size_t len);

size_t ramdisk_read(void *buf, size_t offset, size_t len);
size_t ramdisk_write(const void *buf, size_t offset, size_t len);
size_t serial_write(const void *buf, size_t offset, size_t len);
size_t events_read(void *buf, size_t offset, size_t len);
size_t dispinfo_read(void *buf, size_t offset, size_t len) ;
size_t fb_write(const void *buf, size_t offset, size_t len);

typedef struct {
  char *name;
  size_t size;
  size_t disk_offset;
  ReadFn read;
  WriteFn write;
  size_t open_offset;
} Finfo;

// enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_EVENTS,FD_FB,FD_RAMDISK};
enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_EVENTS,FD_FB,FB_DISPINFO};

//无效的读写函数
size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

/* This is the information about all files in disk. */
static Finfo file_table[] __attribute__((used)) = {
  [FD_STDIN]  = {"stdin", 0, 0, invalid_read, invalid_write},
  [FD_STDOUT] = {"stdout", 0, 0, invalid_read, serial_write},
  [FD_STDERR] = {"stderr", 0, 0, invalid_read, serial_write},
  [FD_EVENTS] = {"/dev/events", 0, 0, events_read, invalid_write},
  [FD_FB]     = {"/dev/fb", 0, 0, invalid_read, fb_write},
  [FB_DISPINFO]  = {"/proc/dispinfo", 0, 0, dispinfo_read, invalid_write},
  // [FD_RAMDISK]= {"ramdisk.img",0,0,ramdisk_read,ramdisk_write},
#include "files.h"
};

void init_fs() {
  // TODO: initialize the size of /dev/fb  framebuffer
  // file_table[FD_RAMDISK].size = 300 * 400 * 4;
  // int fs_size = sizeof(file_table)/sizeof(file_table[0]);
  // printf("init fs , size = %d\n", fs_size);
  AM_GPU_CONFIG_T gpu_config = io_read(AM_GPU_CONFIG);
  int screen_w = gpu_config.width;
  int screen_h = gpu_config.height;
  file_table[FD_FB].size = screen_w * screen_h * 4;
}
int file_description = FD_FB;

int fs_open(const char *pathname, int flags, int mode) {
  // 遍历文件表，查找文件
  // int fs_size = sizeof(file_table)/sizeof(file_table[0]);
  for (int i = 0; i < sizeof(file_table)/sizeof(Finfo); i++) {
    if (!strcmp(file_table[i].name, pathname) ) {
      file_table[i].open_offset = 0;
      // printf("filetable[%d] %s\n",i,file_table[i].name);
      return i;
    }
  }
  printf("****************no find %s***************************\n",pathname);
  return 0;
}


size_t fs_read(int fd, void *buf, size_t len){
  if(file_table[fd].read){
    return file_table[fd].read(buf, 0, len);
  }
  assert(file_table[fd].size >= file_table[fd].open_offset);

  len = ((file_table[fd].size - file_table[fd].open_offset) > len)? 
        len : (file_table[fd].size - file_table[fd].open_offset);
  ramdisk_read(buf, file_table[fd].disk_offset + file_table[fd].open_offset, len);
  file_table[fd].open_offset += len;
  #ifdef STRACE
    printf("fs_read file %s at %d for len %d\n", file_table[fd].name, file_table[fd].open_offset, len);
  #endif
  return len;
}

size_t fs_write(int fd, const void *buf, size_t len){
  if(file_table[fd].write){
    return file_table[fd].write(buf, file_table[fd].open_offset, len);
  }
  assert(file_table[fd].size >= file_table[fd].open_offset);

  len = ((file_table[fd].size - file_table[fd].open_offset) > len)? 
        len : (file_table[fd].size - file_table[fd].open_offset);
  ramdisk_write(buf, file_table[fd].disk_offset + file_table[fd].open_offset, len);
  file_table[fd].open_offset += len;
  #ifdef STRACE
    printf("fs_write file %s at %d for len %d\n", file_table[fd].name, file_table[fd].open_offset, len);
  #endif
  return len;
}

size_t fs_lseek(int fd, size_t offset, int whence){
  size_t _offset;
  switch(whence){
    case SEEK_SET: _offset = offset; break;
    case SEEK_CUR: _offset = file_table[fd].open_offset + offset; break;
    case SEEK_END: _offset = file_table[fd].size + offset; break;
    default: panic("Invalid lseek mode: %d\n", whence);
  }
  file_table[fd].open_offset = _offset;
  // printf("_offset%d\n", _offset);
  return _offset;
}


int fs_close(int fd){
  file_table[fd].open_offset = 0;
  return 0;
}

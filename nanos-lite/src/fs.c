#include <fs.h>

typedef size_t (*ReadFn) (void *buf, size_t offset, size_t len);
typedef size_t (*WriteFn) (const void *buf, size_t offset, size_t len);

typedef struct {
  char *name;
  size_t size;
  size_t disk_offset;
  size_t open_offset;
  ReadFn read;
  WriteFn write;
} Finfo;

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_EVENTS, FD_FB, FD_DISPINFO};

size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t serial_write(const void *buf, size_t offset, size_t len);
size_t events_read(void *buf, size_t offset, size_t len);
size_t dispinfo_read(void *buf, size_t offset, size_t len);
size_t fb_write(const void *buf, size_t offset, size_t len);
size_t ramdisk_read(void *buf, size_t offset, size_t len);
size_t ramdisk_write(const void *buf, size_t offset, size_t len);


/* This is the information about all files in disk. */
static Finfo file_table[] __attribute__((used)) = {
  [FD_STDIN]  = {"stdin", 0, 0, 0, invalid_read, invalid_write},
  [FD_STDOUT] = {"stdout", 0, 0, 0, invalid_read, serial_write},
  [FD_STDERR] = {"stderr", 0, 0, 0, invalid_read, serial_write},
  [FD_EVENTS] = {"/dev/events", 0, 0, 0, events_read, invalid_write},
  [FD_FB]     = {"/dev/fb", 0, 0, 0, invalid_read, fb_write},
  [FD_DISPINFO] = {"/proc/dispinfo", 0, 0, 0, dispinfo_read, invalid_write},
#include "files.h"
};

void init_fs() {
  // TODO: initialize the size of /dev/fb
  AM_GPU_CONFIG_T gpu_config = io_read(AM_GPU_CONFIG);
  int screen_w = gpu_config.width;
  int screen_h = gpu_config.height;
  file_table[FD_FB].size = screen_w * screen_h * 4;
}

//open file return fd.
int fs_open(const char *pathname, int flags, int mode){
  int len = sizeof(file_table) / sizeof(Finfo);
  for(int i=0;i<len;i++){
    if(!strcmp(pathname, file_table[i].name)){
      return i;
    }
  }
  printf("file: %s not find.\n", pathname);
  assert(0);
}

/*
  read() attempts to read up to len bytes from file descriptor fd into the buffer
   starting at buf.
*/
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

/*
  writes() writes up to len bytes from the buffer starting at buf to the file referred 
  to by the file descriptor fd.
*/
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

/*
  lseek()  repositions  the file offset of the open file description associated with the
  file descriptor fd to the argument offset according to the directive whence.
*/
size_t fs_lseek(int fd, size_t offset, int whence){
  switch (whence)
  {
  case SEEK_SET:
    assert(file_table[fd].size >= offset);
    file_table[fd].open_offset = offset;
    break;
  case SEEK_CUR:
    assert(file_table[fd].size >= file_table[fd].open_offset + offset);
    file_table[fd].open_offset += offset;
    break;
  case SEEK_END:
    file_table[fd].open_offset = file_table[fd].size;
    break;
  default:
    printf("unkonwn whence: %d\n", whence);
    assert(0);
  }
  #ifdef STRACE
    printf("fs_lseek file %s to %d\n", file_table[fd].name, file_table[fd].open_offset);
  #endif
    return file_table[fd].open_offset;
}
int fs_close(int fd){
  file_table[fd].open_offset = 0;
  return 0;
}
#include <common.h>

extern uint8_t ramdisk_start;
extern uint8_t ramdisk_end;
#define RAMDISK_SIZE ((&ramdisk_end) - (&ramdisk_start))
/* The kernel is monolithic, therefore we do not need to
 * translate the address `buf' from the user process to
 * a physical one, which is necessary for a microkernel.
 */

/* read `len' bytes starting from `offset' of ramdisk into `buf' */
//该函数实现了从内存磁盘中读取数据的功能。函数参数包括一个指向缓冲区的指针buf，
// 偏移量offset和要读取的字节数len。该函数使用assert宏来确保偏移量和字节数不会导致读取超出内存磁盘的范围。
// 函数使用memcpy函数从内存磁盘中的指定位置复制数据到缓冲区，并返回读取的字节数。
size_t ramdisk_read(void *buf, size_t offset, size_t len) {
  assert(offset + len <= RAMDISK_SIZE);
  memcpy(buf, &ramdisk_start + offset, len);
  return len;
}

/* write `len' bytes starting from `buf' into the `offset' of ramdisk */
// 该函数实现了向内存磁盘中写入数据的功能。函数参数包括一个指向缓冲区的指针buf，
// 偏移量offset和要写入的字节数len。该函数使用assert宏来确保偏移量和字节数不会导致写入超出内存磁盘的范围。
// 函数使用memcpy函数将数据从缓冲区复制到内存磁盘中的指定位置，并返回写入的字节数。
size_t ramdisk_write(const void *buf, size_t offset, size_t len) {
  assert(offset + len <= RAMDISK_SIZE);
  memcpy(&ramdisk_start + offset, buf, len);
  return len;
}

void init_ramdisk() {
  Log("ramdisk info: start = %p, end = %p, size = %d bytes",
      &ramdisk_start, &ramdisk_end, RAMDISK_SIZE);
}

size_t get_ramdisk_size() {
  return RAMDISK_SIZE;
}

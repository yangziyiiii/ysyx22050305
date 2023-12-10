#ifndef __DEVICE_H__
#define __DEVICE_H__

#include "../include/common.h"

#define DEVICE_BASE 0xa0000000
#define MMIO_BASE 0xa0000000
#define TIMER_HZ 60

#define SERIAL_PORT     (DEVICE_BASE + 0x00003f8)
#define KBD_ADDR        (DEVICE_BASE + 0x0000060)
#define RTC_ADDR        (DEVICE_BASE + 0x0000048)
#define VGACTL_ADDR     (DEVICE_BASE + 0x0000100)
#define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
#define DISK_ADDR       (DEVICE_BASE + 0x0000300)
#define FB_ADDR         (MMIO_BASE   + 0x1000000)
#define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)

extern uint64_t get_time();
extern void vga_update_screen();

#endif
#include <am.h>
#include "include/npc.h"
#include <stdio.h>
#define SYNC_ADDR (VGACTL_ADDR + 4)

static uint32_t screen_size;

void __am_gpu_init() {
  screen_size = inl(VGACTL_ADDR);
  //printf("width: %d height: %d\n", screen_size >> 16, screen_size & 0xffff);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, 
    .has_accel = false,
    .width = screen_size >> 16, 
    .height = screen_size & 0xffff,
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  int width = screen_size >> 16;
  int x = ctl->x;
  int y = ctl->y;
  uint32_t *pixels = ctl->pixels;
  int w = ctl->w;
  int h = ctl->h;
  for (int j=0;j<h;j++){
    for(int i=0;i<w;i++){
      fb[x+i + (y+j) * width] = pixels[i + j * w];
    }
  }

  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}

#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
     .width = inw(VGACTL_ADDR+2),
     .height = inw(VGACTL_ADDR),
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  AM_GPU_CONFIG_T _config = io_read(AM_GPU_CONFIG);
  int w = _config.width;  
  int h = _config.height;  
  for(int i = 0; i < ctl->h; i++){
    for(int j = 0; j < ctl->w; j++){
      if((i + ctl->y < h) && (j + ctl->x < w)){
        outl(FB_ADDR+(w*(ctl->y+i)+ctl->x+j)*4,*((uint32_t*)ctl->pixels+i*ctl->w+j));
      }
    }
  }  
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}

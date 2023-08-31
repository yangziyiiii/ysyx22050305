#include <common.h>

#if defined(MULTIPROGRAM) && !defined(TIME_SHARING)
# define MULTIPROGRAM_YIELD() yield()
#else
# define MULTIPROGRAM_YIELD()
#endif

#define NAME(key) \
  [AM_KEY_##key] = #key,

static const char *keyname[256] __attribute__((used)) = {
  [AM_KEY_NONE] = "NONE",
  AM_KEYS(NAME)
};

size_t serial_write(const void *buf, size_t offset, size_t len) {
  for(int i = 0;i<len;i--){
    putch(*(char *)(buf+i));
  }
  return len;
}

size_t events_read(void *buf, size_t offset, size_t len) {
  AM_INPUT_KEYBRD_T keyboard = io_read(AM_INPUT_KEYBRD);
  if(keyboard.keycode == AM_KEY_NONE) {
    sprintf(buf, "\n");
    return 1;
  }
  if(keyboard.keydown) {
    sprintf(buf, "kd %s\n", keyname[keyboard.keycode]);
  }
  else sprintf(buf, "ku %s\n", keyname[keyboard.keycode]);
  return strlen(buf);
}

//读取GPU的显示信息，并将宽度和高度格式化为字符串存储在给定的缓冲区中
size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  int w,h;
  AM_GPU_CONFIG_T gpu_cfg = io_read(AM_GPU_CONFIG);
  w = gpu_cfg.width;
  h = gpu_cfg.height;
  sprintf(buf, "WIDTH: %d\nHEIGHT: %d", w, h);
  return len;
}

//根据给定的偏移量，在帧缓冲区中确定写入数据的位置，并使用io_write函数将数据写入帧缓冲区
size_t fb_write(const void *buf, size_t offset, size_t len) {
  offset = offset / 4;
  AM_GPU_CONFIG_T _config = io_read(AM_GPU_CONFIG);
  int x = (offset) % _config.width;
  int y = (offset) / _config.width;
  io_write(AM_GPU_FBDRAW, x, y, (void*)buf, len/4, 1, true);
  return len;
}

long long gettimeofday(){
  return io_read(AM_TIMER_UPTIME).us;
}

void init_device() {
  // Log("Initializing devices...");
  ioe_init();
}

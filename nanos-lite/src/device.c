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
  for (int i = 0; i < len; i++){
    putch(*((char *)buf + i));
  }
  return len;
}

size_t events_read(void *buf, size_t offset, size_t len) {
  AM_INPUT_KEYBRD_T key = io_read(AM_INPUT_KEYBRD);
  if(key.keycode!=AM_KEY_NONE){
    if(key.keydown)
      len=snprintf(buf, len, "kd %s\n",keyname[key.keycode]);
    else
      len=snprintf(buf, len, "ku %s\n",keyname[key.keycode]);
    return len;
  }
  return 0;
}

static int screen_w = 0, screen_h = 0;

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  AM_GPU_CONFIG_T gpu_config = io_read(AM_GPU_CONFIG);
  screen_w = gpu_config.width;
  screen_h = gpu_config.height;
  assert(len >= 32);

  return snprintf(buf, len, "WIDTH: %d\nHEIGHT: %d\n", screen_w, screen_h);
}

size_t fb_write(const void *buf, size_t offset, size_t len) {
  offset = offset / 4;
  int x = offset % screen_w;
  int y = offset / screen_w;

  io_write(AM_GPU_FBDRAW, x, y, (void*)buf, len / 4, 1, true);
  return 0;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
}

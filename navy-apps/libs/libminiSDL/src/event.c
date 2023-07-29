#include <NDL.h>
#include <SDL.h>
#include <assert.h>

#define keyname(k) #k,

static const char *keyname[] = {
  "NONE",
  _KEYS(keyname)
};

static uint8_t keystate[sizeof(keyname) / sizeof(char *)];

int SDL_PushEvent(SDL_Event *ev) {
  return 0;
}

int SDL_PollEvent(SDL_Event *ev) {
  char buf[64];
  if(NDL_PollEvent(buf, sizeof(buf))){
    char keydown[3];
    char event_keyname[16];
    printf("%s\n", buf);
    sscanf(buf, "%s %s\n", keydown, event_keyname);
    if(!strcmp(keydown, "kd")){
      ev->type = SDL_KEYDOWN;
    }else if(!strcmp(keydown, "ku")){
      ev->type = SDL_KEYUP;
    }else{
      printf("keydown: %s\n", keydown);
      assert(0);
    }
    for (int i=0; i<sizeof(keyname)/sizeof(char*); i++){
      if (!strcmp(event_keyname, keyname[i])){
        ev->key.keysym.sym = i;
        keystate[i] = ev->type == SDL_KEYDOWN ? 1 : 0;
        return 1;
      }
    }
    assert(0);
  }
  return 0;
}

int SDL_WaitEvent(SDL_Event *event) {
  char buf[64];
  while (!NDL_PollEvent(buf, sizeof(buf)));

  char keydown[3];
  char event_keyname[16];
  sscanf(buf, "%s %s\n", keydown, event_keyname);
  if(!strcmp(keydown, "kd")){
    event->type = SDL_KEYDOWN;
  }else if(!strcmp(keydown, "ku")){
    event->type = SDL_KEYUP;
  }else{
    printf("keydown: %s\n", keydown);
    assert(0);
  }
  for (int i=0; i<sizeof(keyname)/sizeof(char*); i++){
    if (!strcmp(event_keyname, keyname[i])){
      event->key.keysym.sym = i;
      keystate[i] = (event->type == SDL_KEYDOWN) ? 1 : 0;
      return 1;
    }
  }
  return 0;
}

int SDL_PeepEvents(SDL_Event *ev, int numevents, int action, uint32_t mask) {
  return 0;
}

uint8_t* SDL_GetKeyState(int *numkeys) {
  if (numkeys != NULL){
    *numkeys = sizeof(keystate) / sizeof(uint8_t);
  }
  return keystate;
}

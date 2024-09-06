#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <termios.h>
#include <unistd.h>
#include <thread>
#include <SDL2/SDL.h>

#define SCREEN_W 400
#define SCREEN_H 300

uint32_t vmem[300*400];
uint32_t vgactl_port_base[8];

void vga_update_screen();
void init_vga();
/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "sdb.h"

#define NR_WP 32

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */
WP* new_wp(char *e){
  assert(free_!=NULL);
  WP *p = free_;
  free_ = free_->next;

  bool success = true;
  strcpy(p->expr, e);
  p->value = expr(e, &success);
  assert(success);
  p->next = head;
  head = p;
  printf("Watch Point%d: %s %ld\n", p->NO, p->expr, p->value);
  return p;
}

void free_wp(char *e){
  WP *p = head, *t;
  if(head == NULL)
    return;
  if(strcmp(e, head->expr)==0){
    t = head;
    head = head->next;
  }else{
    while(p->next != NULL && strcmp(e, p->next->expr)!=0)
      p = p->next;
    if(p->next == NULL){
      printf("watch point not found\n");
      return;
    }
    t = p->next;
    p->next = t->next;
  }
  t->next = free_;
  free_ = t;
  return;
}

int difftest_watchpoint(){
  WP *p = head;
  bool success = true;
  int flag = 0;
  while(p != NULL){
    if(expr(p->expr, &success) != p->value){
      printf("watch point %d: %s %ld -> %ld\n", p->NO, 
        p->expr, p->value, expr(p->expr, &success));
      p->value = expr(p->expr, &success);
      flag = 1;
    }
    p = p->next;
  }
  if(flag)  return 1;
  else      return 0;
}

void display_wp(){
  WP* p;
  for(p=head;p!=NULL;p=p->next){
    printf("watch point %d: %s %ld\n", p->NO, 
        p->expr, p->value);
  }
}

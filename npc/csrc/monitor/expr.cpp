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


/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>
#include "sdb.h"

//word_t vaddr_read(vaddr_t addr, int len);
extern uint64_t *cpu_gpr ;

enum {
  TK_NOTYPE = 256, TK_EQ, TK_NEQ, TK_AND,
  TK_DEC, TK_HEX, //number
  TK_REG,
  TK_MINUS, TK_POINT 
  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"0x[0-9a-fA-F]+", TK_HEX}, 
  {"0|[1-9][0-9]*", TK_DEC},    
  {"\\$[0-9]{1,2}", TK_REG}, 
  {"\\(", '('},         
  {"\\)", ')'},         
  {"\\*", '*'},         // mul
  {"\\/", '/'},         // div
  {"\\+", '+'},         // plus
  {"-", '-'},           // sub
  {"==", TK_EQ},        // equal
  {"!=", TK_NEQ},       // not equal
  {"&&", TK_AND},       // and
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      printf("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

      //  Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
      //      i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
        if(substr_len >= 32){
          printf("warning: token strlen >= 32\n");
          assert(0);
        }
        switch (rules[i].token_type) {
          case TK_NOTYPE: break;
          case '*': //point or mul
            if(nr_token == 0 || (tokens[nr_token-1].type != TK_DEC && tokens[nr_token-1].type!= TK_HEX 
            && tokens[nr_token-1].type!= TK_REG && tokens[nr_token-1].type!=')'))  
              tokens[nr_token].type = TK_POINT;
            else
              tokens[nr_token].type = rules[i].token_type;
            nr_token++;
            break;
          case '-': //minus or sub
            if(nr_token == 0 || (tokens[nr_token-1].type != TK_DEC && tokens[nr_token-1].type!= TK_HEX 
            && tokens[nr_token-1].type!= TK_REG && tokens[nr_token-1].type!=')'))  
              tokens[nr_token].type = TK_MINUS;
            else
              tokens[nr_token].type = rules[i].token_type;
            nr_token++;
            break;
          case TK_EQ: 
          case TK_NEQ: 
          case TK_AND: 
          case '(':
          case ')':
          case '/':
          case '+':
            tokens[nr_token].type = rules[i].token_type;
            nr_token++;
            break;
          default: 
            tokens[nr_token].type = rules[i].token_type;
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len] = '\0';
            nr_token++;
        }
        break;
      }
    }
    if(nr_token >= 32){
      printf("warning: token more than 32\n");
      assert(0);
    }
    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

static bool check_parentheses(int p, int q){
  if(tokens[p].type != '(' || tokens[q].type != ')')
    return false;
  int i, num = 0;
  for(i=p;i<=q;i++){    
        if(tokens[i].type == '(') num++;
        else if(tokens[i].type == ')') num--;
        if(num <= 0 && i < q) 
          return false;  
    }                              
  if(num != 0) 
    return false;   
  return true;
}

static int prior(int type){
  switch (type)
  {
  case TK_POINT:
  case TK_MINUS:
    return 2;
  case '*':
  case '/':
    return 3;
  case '+':
  case '-':
    return 4;
  case TK_EQ:
  case TK_NEQ:
    return 7;
  case TK_AND:
    return 11;
  default:
    return 0;
  }
}

static word_t eval(int p, int q){
  if (p > q) {
    /* Bad expression */
    assert(0);
  }
  else if (p == q) {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
    int num;
    word_t value;
    int reg_idx;
    switch(tokens[p].type){
      case TK_HEX: sscanf(tokens[p].str, "0x%x", &num); return num;
      case TK_DEC: sscanf(tokens[p].str, "%d", &num); return num;
      case TK_REG: 
        strcpy(tokens[p].str, tokens[p].str+1);
        reg_idx = atoi(tokens[p].str);
        if(reg_idx < 0 || reg_idx > 31){
          printf("reg_idx out of bound\n");
          assert(0);
        }
        value = npc_cpu.gpr[reg_idx];
        return value;
      default: assert(0);
    }
  }
  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1);
  }
  else {
    if(tokens[p].type == TK_MINUS || tokens[p].type == TK_POINT ){
      switch (tokens[p].type)
      {
      case TK_MINUS:
        return - eval(p+1, q);
      case TK_POINT:
        return 0;
        //return vaddr_read(eval(p+1, q), 8);
      default:
        break;
      }
    }

    int op = p; //the position of 主运算符 in the token expression;
    int op_type = 0;
    int i, cnt=0;
    for(i=p;i<q;i++){
      if(tokens[i].type == '('){
        cnt++;
        while (cnt>0 && i<q)
        {
          i++;
          if(tokens[i].type == '(') cnt++;
          else if(tokens[i].type == ')') cnt--;
        }
      }
      else if(tokens[i].type != TK_DEC && tokens[i].type != TK_HEX && 
        tokens[i].type != TK_REG && prior(op_type)<= prior(tokens[i].type)){
          op_type = tokens[i].type;
          op = i;
        }
    }
    word_t val1 = eval(p, op - 1);
    word_t val2 = eval(op + 1, q);

    switch (op_type) {
      case '+': return val1 + val2;
      case '-': return val1 - val2;
      case '*': return val1 * val2;
      case '/': if(val2 == 0){
        printf("div-by-zero\n");
        return 0;
        }else      return val1 / val2;
      case TK_EQ:  return val1 == val2;
      case TK_NEQ: return val1 != val2;
      case TK_AND: return val1 && val2;
      default: assert(0);
    }
  }
}


word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  return eval(0, nr_token-1);

}

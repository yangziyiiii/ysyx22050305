#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)


void itoa(unsigned int n, char * buf,int base) { 
  int len,m;
  for(len=0,m=n;m/base!=0;len++)
    m/=base;
  for(int i=0;i<=len;i++){
    if(n%base<10){
      *(buf+len-i)=n%base+'0';
      n=n/base;
    }
    else{
      *(buf+len-i)=n%base+'0'+39;
      n=n/base;
    }
  }
  *(buf+len+1)='\0';
}

int printf(const char *fmt, ...) {
  char out[8196];
  va_list ap;
  va_start(ap, fmt);
  int n=vsprintf(out,fmt,ap);
  va_end(ap);
  for(int i=0;i<strlen(out);i++)
    putch(*(out+i));
  return n;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  char *str = out;
  int d;
  char *s,buf[100];

  while (*fmt){
    if((*fmt)=='%'){
    switch (*(++fmt)){
      case 's': 
        s = va_arg(ap, char *);
        while(*s) {
          *str=*s;str++;s++;
        }
        break;
      case 'c': 
        *str = (char)va_arg(ap, int);
        str ++;
        break;    
      case 'd': 
        d = va_arg(ap, int);
        if (d < 0){
          *str++ = '-';
          d = -d;
        }
        itoa(d, buf,10);
         memcpy(str, buf, strlen(buf));
        str += strlen(buf);
        break;
      case 'p':
      case 'x':
        d = va_arg(ap, int);
        itoa(d, buf,16);
        memcpy(str, buf, strlen(buf));
        str += strlen(buf);
        break;
      default:
        break;
      }
      fmt++;
    }
    else {
      *str++ = *fmt++;
    }
  }
  *str='\0';
  va_end(ap);
  return str-out;
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int num_chars=vsprintf(out,fmt,ap);
  va_end(ap);
  return num_chars;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
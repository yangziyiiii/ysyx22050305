#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static char sprint_buf[1024];

int printf(const char *fmt, ...) {
  va_list args; 
  int n;
  va_start(args, fmt);
  n = vsprintf(sprint_buf, fmt, args);
  va_end(args);
  for(int i=0;i<n;i++){
	putch(sprint_buf[i]);
  }
  return n;
}

static int getnum(const char **s){
	int i, c;

	for (i = 0; '0' <= (c = **s) && c <= '9'; ++*s)
		i = i*10 + c - '0';
	return i;
}

static char * number(char * str, unsigned long long num, int base, 
  int size, int precision, int signs, int type)
{
	char c,sign,tmp[66];
	const char *digits="0123456789abcdef";
	int i;

	c = (type == '0') ? '0' : ' ';
	sign = 0;//符号
	
	if (signs) //有符号与无符号的转换
    {
		if ((signed long long)num < 0) 
        {
			sign = '-';
			num = - (signed long long)num;
			size--;
		} else if (type == '+') //显示+
        {
			sign = '+';
			size--;
		}
	}
	
	i = 0;
	if (num == 0)
		tmp[i++]='0';
	else while (num != 0)
  {
		tmp[i++] = digits[num % base];
    num = num/base;
	}
  int len = i;
	if (type != '-' && type != '0')
		while (size-- > len)
			*str++ = ' ';
	if (sign)
		*str++ = sign;
    
	if (type != '-')
		while (size-- > len)
			*str++ = c;
	while (i-- > 0)
		*str++ = tmp[i];
	while (size-- > len)
		*str++ = ' '; 
	return str;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
	unsigned long long num;
	int i, base, sign;
	char * str;
	const char *s;

	int flags;		  // 标志: -左对齐
	int width;	    // 输出字段的宽度 
  int precision;	// 精度:用在浮点数时表示输出小数点后几位
  int length;     // long, short
	int qualifier;	// %c, %d, %f
	                  
	/*将字符逐个放到输出缓冲区中，直到遇到第一个%*/
	for (str=out ; *fmt ; ++fmt) 
    {
		if (*fmt != '%') {    
			*str++ = *fmt;
			continue;
		}
		++fmt;	

    //标志    
		flags = -1;
		if (*fmt == '-' || *fmt == '+' || *fmt == '0') {
			flags = *fmt;
			++fmt;
		}
		//字段宽度
		width = -1;
		if ('0' <= *fmt && *fmt <= '9')
			width = getnum(&fmt); 

		//精度 
		precision = -1;
		if (*fmt == '.') {
			++fmt;	
			if ('0' <= *fmt && *fmt <= '9')
				precision = getnum(&fmt);//获得精度
		}
	
		//length
		length = -1;
    if (*fmt == 'h' || *fmt == 'l' || *fmt == 'L') {
			length = *fmt;
			++fmt;
		}
  
		base = 10;
    sign = 0;
    //转换格式符
    qualifier = *fmt;
		switch (qualifier) {
		case 'c':
      if(flags != '-')
        while (--width > 0)
          *str++ = ' ';
			*str++ = (unsigned char) va_arg(ap, int);
      while (--width > 0)
        *str++ = ' ';
			continue;
          
		case 's':
			s = va_arg(ap, char *);
			if (!s)                  
				s = "<NULL>";
			int len = strlen(s);
			if (flags != '-')
				while (len < width--)
					*str++ = ' ';
			for (i = 0; i < len; ++i)
				*str++ = *s++;
			while (len < width--)
				*str++ = ' ';
			continue;

		/* integer number formats - set up the flags and "break" */
		case 'o':
			base = 8;
      sign = 1;
			break;
	
		case 'X':
		case 'x':  
			base = 16;
			break;
	
		case 'd':	
		case 'i':
			sign = 1;
		case 'u':
			break;
	
		default: 
			assert(0); // no match
		}

		if(length == 'l') {
			num = va_arg(ap, unsigned long);
			if (sign)
				num = (signed long) num;
		}else if (length == 'h') {
			num = (unsigned short) va_arg(ap, int);
			if (sign)
				num = (signed short) num;
		}else {
			num = va_arg(ap, unsigned int);
			if (sign)
				num = (signed int) num;
		}
        //转换为对应的个数再存到缓冲区中
		str = number(str, num, base, width, precision, sign, flags);
	}
	*str = '\0';//最后以'\0'结束
	return str-out;
}

int sprintf(char *out, const char *fmt, ...) {
  va_list args;
	int i;

	va_start(args, fmt);
	i=vsprintf(out,fmt,args);
	va_end(args);
	return i;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  va_list args;
	int i;

	va_start(args, fmt);
	i=vsnprintf(out,n,fmt,args);
	va_end(args);
	return i;
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif


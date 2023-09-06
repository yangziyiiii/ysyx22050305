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

int vsprintf(char *out, const char *fmt, va_list ap) {
	return vsnprintf(out, -1, fmt, ap);
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
  	unsigned long long num;
	int i, base, sign;
	int pos;
	const char *s;

	int flags;		// 标志: -左对齐
	int width;	    // 输出字段的宽度 
	int length;     // long, short
	int qualifier;	// %c, %d, %f
	                  
	/*将字符逐个放到输出缓冲区中，直到遇到第一个%*/
	for (pos=0; *fmt; ++fmt) 
    {
		if (*fmt != '%') {    
			out[pos++] = *fmt;
			if(pos >= n-1){
				out[pos] = '\0';
                return n;
			}
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
				while (--width > 0){
					out[pos++] = ' ';
					if(pos >= n-1){
						out[pos] = '\0';
						return n;
					}
				}
			out[pos++] = (unsigned char) va_arg(ap, int);
			if(pos >= n-1){
				out[pos] = '\0';
				return n;
			}
			while (--width > 0){
				out[pos++] = ' ';
				if(pos >= n-1){
					out[pos] = '\0';
					return n;
				}
			}
			continue;
          
		case 's':
			s = va_arg(ap, char *);
			if (!s)                  
				s = "<NULL>";
			int len = strlen(s);
			if (flags != '-')
				while (len < width--){
					out[pos++] = ' ';
					if(pos >= n-1){
						out[pos] = '\0';
						return n;
					}
				}
			for (i = 0; i < len; ++i){
				out[pos++] = *s++;
				if(pos >= n-1){
					out[pos] = '\0';
					return n;
				}
			}
			while (len < width--){
				out[pos++] = ' ';
				if(pos >= n-1){
					out[pos] = '\0';
					return n;
				}
			}
			continue;

		/* integer number formats - set up the flags and "break" */
		case 'o':
			base = 8;
      		sign = 1;
			break;

		case 'p':
			width = 16;
			flags = '0';
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
			putch(qualifier);
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
		const char *digits="0123456789abcdef";
		char pad = (flags == '0') ? '0' : ' ';
		char sign_flag = 0;
		char num_str[20] = {0};
		int length = 0;

		do{
			num_str[length++] = digits[num % base];
			num = num / base;
		} while(num > 0);
		if (sign) //有符号与无符号的转换
		{
			if ((signed long long)num < 0) 
			{
				sign_flag = '-';
				num = - (signed long long)num;
				width--;
			} else if (flags == '+') //显示+
			{
				sign_flag = '+';
				width--;
			}
		}
		// pad
		while (length < width){
			out[pos++] = pad;
			width--;
			if(pos >= n-1){
				out[pos] = '\0';
				return n;
			}
		}
		if(sign_flag){
			out[pos++] = sign_flag;
			if(pos >= n-1){
				out[pos] = '\0';
				return n;
			}
		}

		length--;
		while(length >= 0){
			out[pos++] = num_str[length];
			if(pos >= n-1){
				out[pos] = '\0';
				return n;
			}
			length--;
		}
	}
	out[pos] = '\0';
	return pos;
}

#endif
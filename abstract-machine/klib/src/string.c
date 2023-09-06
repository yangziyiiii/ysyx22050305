#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  	size_t len = 0;
    for (; *s != '\0'; s++)
        len++;
		
    return len;
}

char *strcpy(char *dst, const char *src) {
  char *ret = dst;
  assert(dst != NULL);
  assert(src != NULL);
 
  while((*dst++ = *src++));
  return ret;
}

char *strncpy(char *dst, const char *src, size_t n) {
  char *ret = dst;
  assert(dst != NULL);
  assert(src != NULL);
 
  while(n && (*dst++ = *src++))
    n--;
  while(n--)
    *dst++ = '\0';
  return ret;
}

char *strcat(char *dst, const char *src) {
  	char *ret = dst;
	while (*dst)
	{
		dst++;
	}
	while ((*dst++=*src++));

	return ret;
}

int strcmp(const char *s1, const char *s2) {
  	int ret = 0;
	assert(s2 != NULL);
	assert(s1 != NULL);
	while (!(ret=*(unsigned char*)s1 - *(unsigned char*)s2)&&*s2)
	{
		s2++;
		s1++;
	}
	if (ret > 0)
	{
		return 1;
	}
	else if (ret < 0)
	{
		return -1;
	}
	return ret;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  	int ret = 0;
	assert(s2 != NULL);
	assert(s1 != NULL);
	while (n && !(ret=*(unsigned char*)s1 - *(unsigned char*)s2) && *s2)
	{
		s2++;
		s1++;
    	n--;
	}

	return ret;
}

void *memset(void *s, int c, size_t n) {
  void *p = s;

  while (n--)
  {
    *(char *)s = (char)c;
    s = (char *)s + 1;
  }

  return p;
}

void *memmove(void *dst, const void *src, size_t n) {
  	char* _dst = dst;
	const char* _src = src;
	//从右向左拷贝，dst>src且有交集
	if (_dst > _src&&_dst < _src + n)
	{
		_dst = _dst + n - 1;
		_src = _src + n - 1;
		while (n)
		{
      *_dst = *_src;
			_dst--;
			_src--;
			n--;
		}
	}
	//剩余的就三种情况从左向右完全可以拷贝
	else
	{
		while (n)
		{
			*_dst = *_src;
			_dst++;
			_src++;
			n--;
		}
	}
  return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
  	char *dst = out;
    const char *src = in;
    while (n > 0)
    {
        *dst++ = *src++;
        n--;
    }
    return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  	int ret = 0;
	assert(s2);
	assert(s1);
	while (n && !(ret=*(unsigned char*)s1 - *(unsigned char*)s2))
	{
		s2 = (char*)s2 + 1;
		s1 = (char*)s1 + 1;
    n--;
	}
	return ret;
}

#endif

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "utils.h"

#ifdef DEBUG

void output_debug_info(const char *file, const char *fct, const int line)
{
	fprintf(stderr, "[%s:%s(%d)] ", file, fct, line);
}

void output_debug(const char *format, ...)
{
	va_list args;
	va_start(args, format);
	vfprintf(stderr, format, args);
	fprintf(stderr, "\n");
	va_end(args);
}

#endif

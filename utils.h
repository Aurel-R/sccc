#ifndef H_UTILS_H
#define H_UTILS_H

#ifdef DEBUG

void output_debug_info(const char *file, const char *fct, const int line);
void output_debug(const char *format, ...);

#define D(X) do {	\
	output_debug_info(__FILE__, __FUNCTION__, __LINE__);	\
	output_debug X;	\
} while (0)

#else

#define D(X) do { } while (0)

#endif

#endif

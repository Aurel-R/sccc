%{
#include <stdio.h>
#include "y.tab.h"
%}

identifier	[a-zA-Z_][0-9a-zA-Z_]*
number		[1-9][0-9]*

%%

"print"		{ return PRINT; }
{identifier}	{ yylval.string = strdup(yytext); return IDENTIFIER; }
{number}	{ yylval.value = atoi(yytext); return NUMBER; }
[()+*=;]	{ return yytext[0]; }
[[:space:]]	;
.		{ fprintf(stderr, "Unknow character: %s\n", yytext); }

%%

void lex_free(void)
{
	yy_delete_buffer(YY_CURRENT_BUFFER);
	free(yy_buffer_stack);
}

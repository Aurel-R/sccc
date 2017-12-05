%{
#include <stdio.h>
#include "y.tab.h"
%}

identifier	[a-zA-Z_][0-9a-zA-Z_]*
number		[0-9]*

%%

"int"		{ return INT; }
"main"		{ return MAIN; }
"return"	{ return RETURN; }
"if"		{ return IF; }
"else"		{ return ELSE; }
"while"		{ return WHILE; }
"for"		{ return FOR; }
"print"		{ return PRINT; }
"&&"		{ return AND; }
"||"		{ return OR; }
"=="		{ return EQ; }
"!="		{ return NE; }
">"		{ return GT; }
">="		{ return GE; }
"<"		{ return LT; }
"<="		{ return LE; }
"//".*		;
{identifier}	{ yylval.string = strdup(yytext); return ID; }
{number}	{ yylval.value = atoi(yytext); return NUM; /* assume octal to be an int */ }
[(){}+\-*/!=;]	{ return yytext[0]; }
[[:space:]]	;
.		{ fprintf(stderr, "Unknow character: %s\n", yytext); }

%%

void lex_free(void)
{
	yy_delete_buffer(YY_CURRENT_BUFFER);
	free(yy_buffer_stack);
}

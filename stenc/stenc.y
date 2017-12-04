%{
#include <stdio.h>
#include <stdlib.h>
#include "utils.h"

int yylex(void);
void yyerror(char *s);
void lex_free(void);

%}

%union {
	char *string;
	int value;
}

%token PP MM INT MAIN RETURN IF ELSE WHILE FOR PRINT AND OR EQ NE GT GE LT LE
%token <string> ID
%token <value> NUM

%left '+' '*' '/' '-' AND OR
%right '!'

%start axiom

%%

axiom: INT MAIN '(' ')' bloc;

bloc: 
  '{' instrlist '}'
| '{' '}'
;

instrlist: 
  instr instrlist 
| instr
| bloc	
;

instr:
  single ';'
| INT ID ';'
| INT ID '=' expr ';'
| RETURN return
| conditional_struct
;

conditional_struct:
  WHILE '(' conditional ')' bloc
| FOR '(' single ';' conditional ';' single ')' bloc
| IF '(' conditional ')' bloc
| IF '(' conditional ')' bloc ELSE bloc
;

return:
  expr
| conditional
;

z:
  ID PP
| ID MM
| PP ID
| MM ID
;

x:
  ID
| NUM 
| z
;

expr:
  '(' expr ')'
| x
| '-' expr
| expr '*' expr
| expr '/' expr
| expr '+' expr
| expr '-' expr
;

conditional:
  '(' conditional ')'
| '!' conditional
| expr relop expr
| conditional AND conditional
| conditional OR conditional
;

single:
  /* empty */
| ID '=' expr
| PRINT '(' ID ')'
| z
;

relop:
  LT
| LE
| GT
| GE
| EQ
| NE  
;

%%

void yyerror(char *s)
{
	fprintf(stderr, "[Yacc] error: %s\n", s);
}

int main(void)
{
	int ret = yyparse();
	
	lex_free();
	return ret;
}

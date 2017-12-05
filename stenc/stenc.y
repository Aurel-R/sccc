%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol.h"
#include "quad.h"
#include "mips.h"
#include "utils.h"

int yylex(void);
void yyerror(char *s);
void lex_free(void);

static struct symbol *symbol_table = NULL;
static struct quad *quad_list = NULL;

%}

%union {
	char *string;
	int value;
	struct {
		struct symbol *result;
		struct quad *code;
	} codegen;
}

%token INT MAIN RETURN IF ELSE WHILE FOR PRINT AND OR EQ NE GT GE LT LE
%token <string> ID
%token <value> NUM
%type <codegen> axiom bloc instrlist instr return x expr single conditional_struct

%left '+' '*' '/' '-' AND OR
%right '!'

%start axiom

%%

axiom: INT MAIN '(' ')' bloc { quad_list = $5.code; };

bloc: 
  '{' instrlist '}' { $$.code = $2.code; } 
| '{' '}' { $$.code = NULL; }
;

instrlist: 
  instr instrlist {$$.code = $1.code; quad_add(&$$.code, $2.code); }
| instr { $$.code = $1.code; }
| bloc { $$.code = $1.code; }	
;

instr:
  single ';' { $$.result = $1.result; $$.code = $1.code; }
| INT ID ';' {
	struct symbol *s = symbol_lookup(symbol_table, $2);
	
	if (s) {
		fprintf(stderr, "'%s' already declared\n", $2);
		return 1;
	} 

	$$.result = symbol_add(&symbol_table, $2);
	if ($$.result == NULL)
		return 1;
}
| INT ID '=' expr ';' {
	struct quad *quad;
	struct symbol *s = symbol_lookup(symbol_table, $2);
	
	if (s) {
		fprintf(stderr, "'%s' already declared\n", $2);
		return 1;
	} 

	$$.result = symbol_add(&symbol_table, $2);
	if ($$.result == NULL)
		return 1;

	quad = quad_gen(ASSIGN, $$.result, $4.result, NULL);
	if (!quad)
		return 1;
	
	quad_add(&$$.code, $4.code);
	quad_add(&$$.code, quad);
}
| RETURN return {}
| conditional_struct {}
;

conditional_struct:
  WHILE '(' conditional ')' bloc 	{}
| FOR '(' single ';' conditional ';' single ')' bloc	{}
| IF '(' conditional ')' bloc	{}
| IF '(' conditional ')' bloc ELSE bloc	{}
;

return:
  expr	{ }
| conditional {  }
;

x:
  ID {
	$$.code = NULL;
	$$.result = symbol_lookup(symbol_table, $1);
	if ($$.result == NULL) {
		fprintf(stderr, "'%s' undeclared\n", $1);
		return 1;	
	}
}
| NUM {
	$$.result = newtemp(&symbol_table);
	if ($$.result == NULL)
		return 1;
	$$.result->type = CONST;
	$$.result->value = $1;
	$$.code = NULL;
} 
;

expr:
  '(' expr ')' 	{ $$.result = $2.result; $$.code = $2.code; }
| x 		{ $$.result = $1.result; $$.code = $1.code; }
| '-' expr { }	
| expr '*' expr {
	struct quad *quad;
	$$.code = NULL;
	$$.result = newtemp(&symbol_table);
	if ($$.result == NULL)
		return 1;
	
	quad = quad_gen(MUL, $$.result, $1.result, $3.result);
	if (!quad)
		return 1;
	
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad);	
}
| expr '/' expr {
	struct quad *quad;
	$$.code = NULL;
	$$.result = newtemp(&symbol_table);
	if ($$.result == NULL)
		return 1;
	
	quad = quad_gen(DIV, $$.result, $1.result, $3.result);
	if (!quad)
		return 1;
	
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad);	

}
| expr '+' expr {
	struct quad *quad;
	$$.code = NULL;
	$$.result = newtemp(&symbol_table);
	if ($$.result == NULL)
		return 1;
	
	quad = quad_gen(ADD, $$.result, $1.result, $3.result);
	if (!quad)
		return 1;
	
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad);	

}
| expr '-' expr {
	struct quad *quad;
	$$.code = NULL;
	$$.result = newtemp(&symbol_table);
	if ($$.result == NULL)
		return 1;
	
	quad = quad_gen(MINUS, $$.result, $1.result, $3.result);
	if (!quad)
		return 1;
	
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad);	

}
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
| ID '=' expr {
	struct quad *quad;
	$$.code = NULL;
	$$.result = symbol_lookup(symbol_table, $1);
	if ($$.result == NULL) {
		fprintf(stderr, "'%s' undeclared\n", $1);
		return 1;
	}
	
	quad = quad_gen(ASSIGN, $$.result, $3.result, NULL);
	if (!quad)
		return 1;

	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad);
}
| PRINT '(' ID ')' {
	struct symbol *s = symbol_lookup(symbol_table, $3);
	
	if (!s) {
		fprintf(stderr, "'%s' undeclared\n", $3);	
		return 1;
	}
	
	$$.result = NULL;
	$$.code = quad_gen(SYS_PRINT, NULL, s, NULL);
	if ($$.code == NULL)
		return 1;
}
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
	
	if (!ret) 
		mips_gencode(symbol_table, quad_list);		

	quad_free(quad_list);
	symbol_free(symbol_table);	
	lex_free();
	return ret;
}

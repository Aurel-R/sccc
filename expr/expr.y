%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol.h"
#include "quad.h"
#include "mips.h"
#include "utils.h"

int yylex(void);
void yyerror(char *);
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

%token PRINT
%token <string> IDENTIFIER
%token <value> NUMBER
%type <codegen> expression instrlist instr

%left '+'
%left '*'

%start instrlist

%%

instrlist:
  instr ';' instrlist { 
	$$.code = NULL;
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_list = $$.code; 
} 
| instr { 
	$$.code = NULL;
	quad_add(&$$.code, $1.code); 
	quad_list = $$.code;	
};


instr:
IDENTIFIER '=' expression {
	D(("instr -> IDENTIFIER (%s) = expression", $1));
	struct quad *quad;
	$$.code = NULL;
	$$.result = symbol_lookup(symbol_table, $1);
	if ($$.result == NULL)
		$$.result = symbol_add(&symbol_table, $1);
	if ($$.result == NULL)	
		return 1;
	
	quad = quad_gen(ASSIGN, $$.result, $3.result, NULL);
	if (!quad)
		return 1;

	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad);
}

| PRINT IDENTIFIER {
	D(("instr -> PRINT IDENTIFIER (%s)", $2));
	struct symbol *s = symbol_lookup(symbol_table, $2);

	if (!s) {
		fprintf(stderr, "'%s' undeclared\n", $2);
		return 1;
	}

	$$.result = NULL;
	$$.code = quad_gen(SYS_PRINT, NULL, s, NULL);
	if (!$$.code)
		return 1;
};


expression:
expression '+' expression { 
	D(("expression -> expression + expression"));
	struct quad *quad;
	$$.code = NULL;
	$$.result = newtemp(&symbol_table);
	if (!$$.result)
		return 1;

	quad = quad_gen(ADD, $$.result, $1.result, $3.result);
	if (!quad)
		return 1;

	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad); 
}
  	
| expression '*' expression {
	D(("expression -> expression * expression"));
	struct quad *quad;
	$$.code = NULL;
	$$.result = newtemp(&symbol_table);
	if (!$$.result)
		return 1;

	quad = quad_gen(MUL, $$.result, $1.result, $3.result);
	if (!quad)
		return 1;
	
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, quad);
}
	
| '(' expression ')' {
	D(("expression -> ( expression )"));
	$$.result = $2.result;
	$$.code = $2.code;
}
  	
| IDENTIFIER {
	D(("expression -> IDENTIFIER (%s)", $1));
	$$.result = symbol_lookup(symbol_table, $1);
	if ($$.result == NULL) {
		fprintf(stderr, "'%s' undeclared\n", $1);
		return 1;
	}
	$$.code = NULL;
}

| NUMBER {
	D(("expression -> NUMBER (%d)", $1));
	$$.result = newtemp(&symbol_table);
	if (!$$.result)
		return 1;

	$$.result->type = CONST;
	$$.result->value = $1;
	$$.code = NULL;
};

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

/*
	printf("-----------------\nSymbol table:\n");
	symbol_print(symbol_table);
 	printf("-----------------\nQuad list:\n");
	quad_print(quad_list);
*/
	quad_free(quad_list);
	symbol_free(symbol_table);
	lex_free();
  	return ret;
}

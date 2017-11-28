%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol.h"
#include "quad.h"
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

%token <string> IDENTIFIER
%token <value> NUMBER
%type <codegen> expression

%left '+'
%left '*'

%%

axiom:
expression '\n' { 
	D(("Match :-) !"));
	return 0;
};

expression:
expression '+' expression { 
	D(("expression -> expression + expression"));
	$$.result = newtemp(&symbol_table);
	quad_add(&quad_list, $1.code);
	quad_add(&quad_list, $3.code);
	quad_add(&quad_list, quad_gen(ADD, $$.result, $1.result, $3.result));
	$$.code = quad_list;
}
  	
| expression '*' expression {
	D(("expression -> expression * expression"));
	$$.result = newtemp(&symbol_table);
	quad_add(&quad_list, $1.code);
	quad_add(&quad_list, $3.code);
	quad_add(&quad_list, quad_gen(MUL, $$.result, $1.result, $3.result));
	$$.code = quad_list;		
}
	
| '(' expression ')' {
	D(("expression -> ( expression )"));
	$$.result = $2.result;
	$$.code = $2.code;
}
  	
| IDENTIFIER {
	D(("expression -> IDENTIFIER (%s)", $1));
	$$.result = symbol_lookup(symbol_table, $1);
	if ($$.result == NULL)
		$$.result = symbol_add(&symbol_table, $1);
	$$.code = NULL;
}

| NUMBER {
	D(("expression -> NUMBER (%d)", $1));
	$$.result = newtemp(&symbol_table);
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
	printf("Enter an arithmetic expression:\n");
	yyparse();
	printf("-----------------\nSymbol table:\n");
	symbol_print(symbol_table);
 	printf("-----------------\nQuad list:\n");
	quad_print(quad_list);
	quad_free(quad_list);
	symbol_free(symbol_table);
	lex_free();
  	return 0;
}

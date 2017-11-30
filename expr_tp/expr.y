%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "symbol.h"
  #include "quad.h"

  void yyerror(char*);
  int yylex();

  Symbol tds = NULL;
  Quad quad_list = NULL;
%}

%union
{
  int value;
  char* car;
  struct {
		struct symbol *res;
		struct quad *code;
	} codegen;
}

%token <car> IDENTIFIER 
%token <value> NUMBER 
%type <codegen> expression

%left '+'
%left '*'

%%

axiom:
    expression '\n'
    { 
      printf("Match :-) !\n");
      quad_list = $1.code;
      return 0;
    }
  ;

expression:
    expression '+' expression
    { 
      printf("expression -> expression + expression\n");
      $$.res = symbol_newtemp(&tds);
      $$.code = $1.code;
      quad_add(&$$.code, $3.code);
      quad_add(&$$.code, quad_gen('+', $1.res, $3.res, $$.res));
    }
  | expression '*' expression
    {
      printf("expression -> expression * expression\n");
      $$.res = symbol_newtemp(&tds);
      $$.code = $1.code;
      quad_add(&$$.code, $3.code);
      quad_add(&$$.code, quad_gen('*', $1.res, $3.res, $$.res));
    }
  | '(' expression ')'
    {
      printf("expression -> ( expression )\n");
      $$.res= $2.res;
      $$.code = $2.code;
    }
  | IDENTIFIER
    {
      printf("expression -> IDENTIFIER (%s)\n",$1);
      symbol_add(&tds, $1);
      
    }
  | NUMBER
    {
      printf("expression -> NUMBER (%d)\n", $1);
      Symbol new=symbol_newtemp(&tds);
      new->isconst = true;
      new->val = $1;
    }
  ;

%%

void yyerror (char *s) {
    fprintf(stderr, "[Yacc] error: %s\n", s);
}

int main() {
  printf("Enter an arithmetic expression:\n");
  yyparse();
  printf("-----------------\nSymbol table:\n");
  symbol_print(tds);
  printf("-----------------\nQuad list:\n");

  return 0;
}

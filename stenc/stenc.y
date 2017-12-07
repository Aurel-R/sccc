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
	unsigned relop_code;
	char *string;
	int value;
	struct {
		struct symbol *result;
		struct quad *code;
		struct empty_quad *true_list;
		struct empty_quad *false_list;
	} codegen;
}

%token INT MAIN RETURN IF ELSE WHILE FOR PRINT AND OR EQ NE GT GE LT LE
%type <relop_code> relop
%token <string> ID
%token <value> NUM
%type <codegen> axiom bloc instrlist instr return x expr single 
		conditional_struct conditional

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
| conditional_struct { $$.code = $1.code; }
;

conditional_struct:
  WHILE '(' conditional ')' bloc {
	struct quad *true_label_quad, *false_label_quad;
	struct quad *loop_label_quad, *loop_quad;
	struct symbol *loop_label = newlabel(&symbol_table);
	struct symbol *true_label = newlabel(&symbol_table);
	struct symbol *false_label = newlabel(&symbol_table);

	if (!loop_label || !true_label || !false_label)
		return 1;

	true_label_quad = quad_gen(ADD_LABEL, true_label, NULL, NULL);
	false_label_quad = quad_gen(ADD_LABEL, false_label, NULL, NULL);
	loop_label_quad = quad_gen(ADD_LABEL, loop_label, NULL, NULL);
	loop_quad = quad_gen(GOTO, loop_label, NULL, NULL);
	if (!true_label_quad || !false_label_quad ||
	    !loop_label_quad || !loop_quad)
		return 1;

	empty_quad_complete($3.true_list, true_label);
	empty_quad_complete($3.false_list, false_label);
	quad_add(&$$.code, loop_label_quad);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, true_label_quad);
	quad_add(&$$.code, $5.code);
	quad_add(&$$.code, loop_quad);
	quad_add(&$$.code, false_label_quad);
	/* TODO: free true and false list*/
}
| FOR '(' single ';' conditional ';' single ')' bloc	{
	struct quad *true_label_quad, *false_label_quad;
	struct quad *loop_label_quad, *loop_quad;
	struct symbol *loop_label = newlabel(&symbol_table);
	struct symbol *true_label = newlabel(&symbol_table);
	struct symbol *false_label = newlabel(&symbol_table);

	if (!loop_label || !true_label || !false_label)
		return 1;

	true_label_quad = quad_gen(ADD_LABEL, true_label, NULL, NULL);
	false_label_quad = quad_gen(ADD_LABEL, false_label, NULL, NULL);
	loop_label_quad = quad_gen(ADD_LABEL, loop_label, NULL, NULL);
	loop_quad = quad_gen(GOTO, loop_label, NULL, NULL);
	if (!true_label_quad || !false_label_quad ||
	    !loop_label_quad || !loop_quad)
		return 1;

	empty_quad_complete($5.true_list, true_label);
	empty_quad_complete($5.false_list, false_label);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, loop_label_quad);
	quad_add(&$$.code, $5.code);
	quad_add(&$$.code, true_label_quad);
	quad_add(&$$.code, $9.code);
	quad_add(&$$.code, $7.code);
	quad_add(&$$.code, loop_quad);
	quad_add(&$$.code, false_label_quad);
	/* TODO: free true and false list*/

}
| IF '(' conditional ')' bloc	{ 
	struct quad *true_label_quad, *false_label_quad;
	struct symbol *true_label = newlabel(&symbol_table);
	struct symbol *false_label = newlabel(&symbol_table);

	if (!true_label || !false_label)
		return 1;

	true_label_quad = quad_gen(ADD_LABEL, true_label, NULL, NULL);
	false_label_quad = quad_gen(ADD_LABEL, false_label, NULL, NULL);
	if (!true_label_quad || !false_label_quad)
		return 1;

	empty_quad_complete($3.true_list, true_label);	
	empty_quad_complete($3.false_list, false_label);	
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, true_label_quad);
	quad_add(&$$.code, $5.code);
	quad_add(&$$.code, false_label_quad);
	/* TODO: free true and false list*/
}
| IF '(' conditional ')' bloc ELSE bloc	{
	struct quad *true_label_quad, *false_label_quad;
	struct quad *endif_jmp, *end_label_quad;
	struct symbol *true_label = newlabel(&symbol_table);
	struct symbol *false_label = newlabel(&symbol_table);
	struct symbol *end_label = newlabel(&symbol_table);

	if (!true_label || !false_label || !end_label)
		return 1;

	true_label_quad = quad_gen(ADD_LABEL, true_label, NULL, NULL);
	false_label_quad = quad_gen(ADD_LABEL, false_label, NULL, NULL);
	end_label_quad = quad_gen(ADD_LABEL, end_label, NULL, NULL);
	endif_jmp = quad_gen(GOTO, end_label, NULL, NULL);
	if (!true_label_quad || !false_label_quad || 
	    !end_label_quad  || !endif_jmp)
		return 1;

	empty_quad_complete($3.true_list, true_label); 
	empty_quad_complete($3.false_list, false_label);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, true_label_quad);
	quad_add(&$$.code, $5.code);
	quad_add(&$$.code, endif_jmp);
	quad_add(&$$.code, false_label_quad);
	quad_add(&$$.code, $7.code);
	quad_add(&$$.code, end_label_quad); 
	/* TODO: free true and false list*/
}
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
| '-' expr {
	/* TODO */ 
}	
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
  '(' conditional ')' {
	$$.code = $2.code;
	$$.true_list = $2.true_list;
	$$.false_list = $2.false_list;
}
| '!' conditional {
	$$.code = $2.code;
	$$.true_list = $2.false_list;
	$$.false_list = $2.true_list;
}
| expr relop expr {
	struct quad *q1 = quad_gen($2, NULL, $1.result, $3.result);
	struct quad *q2 = quad_gen(GOTO, NULL, NULL, NULL);
	
	if (!q1 || !q2)
		return 1;	

	empty_quad_new(&$$.true_list, q1);
	empty_quad_new(&$$.false_list, q2);
	if (!$$.true_list || !$$.false_list)
		return 1;

	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, $3.code);
	quad_add(&$$.code, q1);
	quad_add(&$$.code, q2);
}
| conditional AND conditional {
	struct quad *label_quad;
	struct symbol *label = newlabel(&symbol_table);

	if (!label)
		return 1;
	
	label_quad = quad_gen(ADD_LABEL, label, NULL, NULL);
	if (!label_quad)
		return 1;	

	empty_quad_complete($1.true_list, label);
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, label_quad);
	quad_add(&$$.code, $3.code);
	$$.true_list = $3.true_list;
	$$.false_list = empty_quad_cat($1.false_list, $3.false_list);

}
| conditional OR conditional {
	struct quad *label_quad;
	struct symbol *label = newlabel(&symbol_table);

	if (!label)
		return 1;
	
	label_quad = quad_gen(ADD_LABEL, label, NULL, NULL);
	if (!label_quad)
		return 1;	

	empty_quad_complete($1.false_list, label);
	quad_add(&$$.code, $1.code);
	quad_add(&$$.code, label_quad);
	quad_add(&$$.code, $3.code);
	$$.true_list = empty_quad_cat($1.true_list, $3.true_list);
	$$.false_list = $3.false_list;
}
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
  LT { $$ = LT_C; }
| LE { $$ = LE_C; }
| GT { $$ = GT_C; }
| GE { $$ = GE_C; }
| EQ { $$ = EQ_C; }
| NE { $$ = NE_C; }
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

	/* TODO: replace 'return 1' by an terminate function
	 * 	 to set quad_list (free under) */
	quad_free(quad_list);
	symbol_free(symbol_table);
	lex_free();
	return ret;
}

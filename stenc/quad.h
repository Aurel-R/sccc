#ifndef H_QUAD_H
#define H_QUAD_H

enum operand {
	SYS_PRINT = 1, /* operator */
	RET,
	ASSIGN,
	ADD,
	MUL,
	MINUS,
	DIV
};

struct quad {
	enum operand op; 
	struct symbol *res;
	struct symbol *arg1;
	struct symbol *arg2;
	struct quad *next;
	struct quad *prec; /* unused */
	struct quad *last;
};

struct quad *quad_gen(enum operand op, struct symbol *res, 
			struct symbol *arg1, struct symbol *arg2);
void quad_add(struct quad **qaud_list, struct quad *quad);
void quad_print(struct quad *quad);
void quad_free(struct quad *quad);

#endif

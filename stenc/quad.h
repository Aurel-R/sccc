#ifndef H_QUAD_H
#define H_QUAD_H

enum operand {
	SYS_PRINT = 1, /* operator */
	RET,
	ASSIGN,
	ADD,
	MUL,
	MINUS,
	DIV,
	ADD_LABEL,
	GOTO,
	EQ_C,
	NE_C,
	GT_C,
	GE_C,
	LT_C,
	LE_C,
	LOAD_ARRAY,
	INDEX,
	GET_ADDR,
	GET_VALUE
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

struct empty_quad {
	struct quad *quad;
	struct empty_quad *next;
};

void empty_quad_new(struct empty_quad **list, struct quad *quad);
struct empty_quad *empty_quad_cat(struct empty_quad *l1, struct empty_quad *l2);
void empty_quad_complete(struct empty_quad *list, struct symbol *s);
void empty_quad_free(struct empty_quad *list);

#endif

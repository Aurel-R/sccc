#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include "symbol.h"
#include "quad.h"

static inline void reach_last_no_empty(struct quad **quad_list, struct quad *quad)
{
	if (quad && quad->last) 
		(*quad_list)->last = quad->last;
}

static inline void reach_last_empty(struct quad **quad_list, struct quad *quad)
{
	(*quad_list)->last = (quad && quad->last) ? quad->last : quad;
}

static inline void prec_quad(struct quad **quad_list, struct quad *quad)
{
	if (quad) 
		quad->prec = ((*quad_list)->last) ? (*quad_list)->last : *quad_list;
}

void quad_add(struct quad **quad_list, struct quad *quad)
{
	if (*quad_list == NULL) {
		*quad_list = quad;
	} else if (!(*quad_list)->last){
		(*quad_list)->next = quad;
	/*	prec_quad(quad_list, quad);	unused for the moment */
		reach_last_empty(quad_list, quad);
	} else {
		(*quad_list)->last->next = quad;
	/*	prec_quad(quad_list, quad);	unused for the moment */
		reach_last_no_empty(quad_list, quad);
	}
}

struct quad *quad_gen(enum operand op, struct symbol *res, 
			struct symbol *arg1, struct symbol *arg2)
{
	struct quad *new = malloc(sizeof(struct quad));

	if (!new) {
		perror("malloc");
		return NULL;
	}	
	
	new->op = op;
	new->res = res;
	new->arg1 = arg1;
	new->arg2 = arg2;
	new->next = NULL;
	new->prec = NULL;
	new->last = NULL;
	return new;
}

void quad_print(struct quad *quad)
{
	for (; quad; quad = quad->next) {
		printf("\top: %d  res: %s  arg1: %s arg2: %s\n", quad->op,
			(quad->res) ? quad->res->name : "", 
			(quad->arg1) ? quad->arg1->name : "",
			(quad->arg2) ? quad->arg2->name : "");
	}	
}

void quad_free(struct quad *quad)
{
	struct quad *q;

	while ((q = quad) != NULL) {
		quad = q->next;
		free(q);	
	}
}

/**
 * @file   quad.h
 * @author Aurelien Rausch, Loubna Hennach
 * @brief  Definir les quads.
 */

#ifndef H_QUAD_H
#define H_QUAD_H

/**
 * @brief  enumeration de toute les operations supportees par la grammaire
 */
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
	enum operand op;    //Operation
	struct symbol *res; //Resultat
	struct symbol *arg1;//Argument 1.
	struct symbol *arg2;//Argument 2.
	struct quad *next;  //Quad suivant
	struct quad *prec; /* unused */
	struct quad *last;  //Dernier quad 
};
/**
 * @brief  Creer un nouveau Quad.
 * @param  op  Une operation.
 * @param  res  Le resultat.
 * @param  arg1 Une operande.
 * @param  arg2 Une operande.
 * @return Un Quad.
 */
struct quad *quad_gen(enum operand op, struct symbol *res, 
			struct symbol *arg1, struct symbol *arg2);
/**
 * @brief  Ajouter un Quad a une liste de quads.
 * @param  quad_list liste de quads.
 * @param  quad le quad a ajouter.
 */
void quad_add(struct quad **qaud_list, struct quad *quad);
/**
 * @brief Afficher le quad.
 * @param quad Un Quad.
 */
void quad_print(struct quad *quad);
/**
 * @brief Liberer la memoire occupee par un quad.
 * @param quad le quad à liberer.
 */
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

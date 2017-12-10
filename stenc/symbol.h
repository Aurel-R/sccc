/**
 * @file   symbol.h
 * @author Aurélien Rausch , Loubna Hennach 
 * @brief  Definir la table des symboles et les fonctions associées
 */

#ifndef H_SYMBOL_H
#define H_SYMBOL_H

#define NAME_LEN	128
#define MAX_DIM		10

enum symbol_type {
	CONST = 1,
	LABEL,
	ARRAY,
	ADDR
};

struct symbol {
	int value;
	char name[NAME_LEN];
	enum symbol_type type;
	unsigned n_dim;
	unsigned dim[MAX_DIM]; 
	struct symbol *next;
	struct symbol *last;
};
/**
 * @brief  Creer un nouveau symbole de type Label et l'ajouter dans la table
 * @param  table  La table des symboles.
 * @return table avec le nouveau symbole 
 */
struct symbol *newlabel(struct symbol **table);
/**
 * @brief  Creer un symbole temporaire et l'ajouter dans la table
 * @param  table  La table des symboles.
 * @return table avec le nouveau symbole
 */
struct symbol *newtemp(struct symbol **table);
/**
 * @brief  ajouter un symbole dans la table
 * @param  table  La table des symboles.
 * @param  name Le symbole a ajouter.
 * @return nouvelle table avec le symbole ajoute.
 */
struct symbol *symbol_add(struct symbol **table, const char *name);
/**
 * @brief  chercher et retourner un Symbol.
 * @param  table  La table des symboles.
 * @param  name Le symbole a chercher.
 * @return Le symbole trouve.
 */
struct symbol *symbol_lookup(struct symbol *table, const char *name);
/**
 * @brief Afficher la table des symboles.
 * @param table Table des symboles.
 */
void symbol_print(struct symbol *table);
/**
 * @brief Liberer la memoire occupee par une table de symboles.
 * @param table Table des symboles.
 */
void symbol_free(struct symbol *table);

#endif

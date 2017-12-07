#ifndef H_SYMBOL_H
#define H_SYMBOL_H

#define NAME_LEN	128

enum symbol_type {
	CONST = 1,
	LABEL
};

struct symbol {
	int value;
	char name[NAME_LEN];
	enum symbol_type type; 
	struct symbol *next;
	struct symbol *last;
};

struct symbol *newlabel(struct symbol **table);
struct symbol *newtemp(struct symbol **table);
struct symbol *symbol_add(struct symbol **table, const char *name);
struct symbol *symbol_lookup(struct symbol *table, const char *name);
void symbol_print(struct symbol *table);
void symbol_free(struct symbol *table);

#endif

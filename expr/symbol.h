#ifndef H_SYMBOL_H
#define H_SYMBOL_H

#define NAME_LEN	128
#define CONST		1

struct symbol {
	char name[NAME_LEN];
	int type; /* TODO: replace with enum */
	int value;
	struct symbol *next;
	struct symbol *last;
};

struct symbol *newtemp(struct symbol **table);
struct symbol *symbol_add(struct symbol **table, const char *name);
struct symbol *symbol_lookup(struct symbol *table, const char *name);
void symbol_print(struct symbol *table);
void symbol_free(struct symbol *table);

#endif

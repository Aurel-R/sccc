#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include "symbol.h"

struct symbol *symbol_lookup(struct symbol *table, const char *name)
{
	for (; table != NULL && strcmp(table->name + 1, name); 
	       table = table->next);
	return table;	
}

struct symbol *symbol_add(struct symbol **table, const char *name)
{
	struct symbol *sym;

	if (strlen(name) >= NAME_LEN - 1) {
		fprintf(stderr, "var name lenght '%s' is too long\n", name);
		return NULL;
	}
 
	if ((sym = calloc(1, sizeof(struct symbol))) == NULL) {
		perror("calloc");
		return NULL;
	}
		
	if (*table == NULL) 
		*table = sym;
	else
		(*table)->last->next = sym;

	(*table)->last = sym;
	/* prefix symbol name to avoid collision */ 
	*sym->name = '_'; 
	memcpy(sym->name + 1, name, strlen(name)); 
	sym->next = NULL;
	return sym;
}

struct symbol *newlabel(struct symbol **table)
{
	struct symbol *sym;
	static unsigned i = 1;
	char name[NAME_LEN] = { 0 };

	snprintf(name, NAME_LEN, "L%d", i++);
	sym = symbol_add(table, name);
	if (!sym)
		return NULL;
	
	sym->type = LABEL;
	return sym;
}

struct symbol *newtemp(struct symbol **table)
{
	static unsigned i = 1;
	char name[NAME_LEN] = { 0 };

	snprintf(name, NAME_LEN, "temp_%d", i++);
	return symbol_add(table, name);
}

void symbol_free(struct symbol *table)
{
	struct symbol *sym;

	while ((sym = table) != NULL) {
		table = sym->next;
		free(sym);
	}
}



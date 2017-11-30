#ifndef H_SYMBOL_H
#define H_SYMBOL_H

#include <stdio.h>
#include <stdbool.h>
#define SYMBOL_MAX_STRING 42


typedef struct symbol{
    char* id;
    bool isconst;
    int val;
    struct symbol* next;
} * Symbol;

Symbol symbol_alloc();
Symbol symbol_newtemp(Symbol*);
Symbol symbol_lookup(Symbol, char*);
Symbol symbol_add(Symbol*, char*);
void symbol_print(Symbol);

#endif
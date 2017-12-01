#include "symbol.h"

typedef struct quad
{
    char op;
    Symbol arg1, arg2, res;
    struct quad* next;
}*Quad;

Quad quad_gen(char, Symbol, Symbol, Symbol);
void quad_add(Quad*,Quad);

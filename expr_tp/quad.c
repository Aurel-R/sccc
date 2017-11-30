
#include "quad.h"
#include<stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

Quad quad_gen(char op, Symbol arg1, Symbol arg2, Symbol res)
{
    Quad new= malloc(sizeof(struct quad));
    new->op = op;
    new->arg1=arg1;
    new->arg2=arg2;
    new->res=res;
    new->next = NULL;
    return new;
}

void quad_add(Quad* dest, Quad src)
{
    if(*dest == NULL)
    {
        *dest = src;
    }
    else
    {
        Quad temp = *dest;
        while(temp -> next != NULL)
            temp=temp->next;
        temp->next = src;
    }
}


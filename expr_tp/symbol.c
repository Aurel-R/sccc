#include "symbol.h"
#include<stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

Symbol symbol_alloc()
{
    Symbol symbol = malloc(sizeof(struct symbol));
    symbol->id= NULL;
    symbol->isconst = false;
    symbol->val= 0;
    symbol->next=NULL;
    return symbol;
}

Symbol symbol_add(Symbol* table, char* name)
{
    if(*table == NULL)
    {
        *table = symbol_alloc();
        (*table)->id=strdup(name);
        return *table;
    }
    else
    {
        Symbol temp = *table;
        while(temp->next != NULL)
            temp = temp->next;
        temp->next=symbol_alloc();
        temp->next->id = strdup(name);
        return temp->next;
    }

}

Symbol symbol_newtemp(Symbol* table)
{
    static int temp = 0;
    char temp_name[SYMBOL_MAX_STRING];
    snprintf(temp_name, SYMBOL_MAX_STRING, "temp %d", temp);
    temp++;
    return symbol_add(table, temp_name);
}

Symbol symbol_lookup(Symbol table, char* identifier)
{
    while(table != NULL)
    {
        if(strcmp(table->id, identifier))
            return table;
        table=table->next;
    }
    return NULL;
}

void symbol_print(Symbol symbol)
{
    while (symbol != NULL)
    {
        printf("identifier : %s , isconstant: ", symbol->id);
        if (symbol->isconst)
            printf("true : value :  %d\n", symbol->val);
        else
            printf("false : value NAN\n");
        symbol=symbol->next;
    }
}
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "symbol.h"
#include "quad.h"
#include "mips.h"
#include "utils.h"

static inline void mul_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tmul $t0,$t0,$t1\n\tsw $t0,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void add_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tadd $t0,$t0,$t1\n\tsw $t0,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void assign_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tsw $t0,%s\n", quad->arg1->name, quad->res->name);	
}

static inline void sys_print_code(struct quad *quad)
{
	printf("\tli $v0,1\n\tlw $a0,%s\n\tsyscall\n", quad->arg1->name);
}

static void text_section(struct quad *quad)
{
	printf(".text\nmain:\n");

	for (; quad; quad = quad->next) {
		switch (quad->op) {
		case SYS_PRINT:
			sys_print_code(quad);
			break;
		case ASSIGN:
			assign_code(quad);
			break;
		case ADD:
			add_code(quad);
			break;
		case MUL:
			mul_code(quad);
			break;
		}
	}	
	
	printf("\tli $v0,10\n\tsyscall\n");
}

static void data_section(struct symbol *sym)
{
	printf("\n.data\n");
	
	for (; sym; sym = sym->next) {
		printf("\t%s: .word %d\n", sym->name, 
			(sym->type == CONST) ? sym->value : 0);
	}
}

void mips_gencode(struct symbol *sym, struct quad *quad)
{
	data_section(sym);
	text_section(quad);
}


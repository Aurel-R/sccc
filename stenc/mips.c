#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "symbol.h"
#include "quad.h"
#include "mips.h"
#include "utils.h"

/* print(id); is considered an operator (not a function) 
 * TODO: Add new line after print */
static inline void sys_print_code(struct quad *quad)
{
	printf("\tli $v0,1\n\tlw $a0,%s\n\tsyscall\n", quad->arg1->name);
}

static inline void assign_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tsw $t0,%s\n", quad->arg1->name, quad->res->name);	
}

static inline void add_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tadd $t0,$t0,$t1\n\tsw $t0,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void minus_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tsub $t0,$t0,$t1\n\tsw $t0,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void mul_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tmul $t0,$t0,$t1\n\tsw $t0,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void div_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tdiv $t0,$t0,$t1\n\tsw $t0,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void label_code(struct quad *quad)
{
	printf("%s:\n", quad->res->name);
}

static inline void goto_code(struct quad *quad)
{
	printf("\tb %s\n", quad->res->name);
}

static inline void eq_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tbeq $t0,$t1,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void ne_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tbne $t0,$t1,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void gt_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tbgt $t0,$t1,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void ge_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tbge $t0,$t1,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void lt_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tblt $t0,$t1,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
}

static inline void le_code(struct quad *quad)
{
	printf("\tlw $t0,%s\n\tlw $t1,%s\n\tble $t0,$t1,%s\n",
			quad->arg1->name, quad->arg2->name, quad->res->name);
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
		case MINUS:
			minus_code(quad);
			break;
		case MUL:
			mul_code(quad);
			break;
		case DIV:
			div_code(quad);
			break;
		case ADD_LABEL:
			label_code(quad);
			break;
		case GOTO:
			goto_code(quad);
			break;
		case EQ_C:
			eq_code(quad);
			break;
		case NE_C:
			ne_code(quad);
			break;
		case GT_C:
			gt_code(quad);
			break;
		case GE_C:
			ge_code(quad);
			break;
		case LT_C:
			lt_code(quad);
			break;
		case LE_C:
			le_code(quad);
			break;
		default:
			fprintf(stderr, "(%d) unimplemented \n", quad->op);
			break;
		}
	}	
	
	printf("\tli $v0,10\n\tsyscall\n");
}

static void data_section(struct symbol *sym)
{
	printf("\n.data\n");
	
	for (; sym; sym = sym->next) {
		if (sym->type != LABEL)
			printf("\t%s: .word %d\n", sym->name, 
				(sym->type == CONST) ? sym->value : 0);
	}
}

void mips_gencode(struct symbol *sym, struct quad *quad)
{
	data_section(sym);
	text_section(quad);
}


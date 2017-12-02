CC = gcc
LEX = lex
YACC = yacc -d -v
CFLAGS = -O2 -Wall -DDEBUG
LDFLAGS = -ly -lfl -DDEBUG# Linux: -lfl / OSX: -ll
EXEC = stenc
SRC =  utils.c
OBJ = $(SRC:.c=.o)

all: $(OBJ) y.tab.c lex.yy.c
	$(CC) -o $(EXEC) $^ $(LDFLAGS)

y.tab.c: $(EXEC).y
	$(YACC) $(EXEC).y

lex.yy.c: $(EXEC).l
	$(LEX) $(EXEC).l

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	/bin/rm $(EXEC) *.o y.tab.c y.tab.h lex.yy.c

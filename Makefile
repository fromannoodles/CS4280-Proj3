turing: tree.o turing.tab.o lex.yy.o main.o check.o
	gcc -o turing main.o tree.o turing.tab.o lex.yy.o check.o

main.o: main.c tree.h

tree.o: tree.c tree.h turing.tab.h

check.o: check.c tree.h ST.h

turing.tab.o: turing.tab.c tree.h
turing.tab.c: turing.y
	bison turing.y
turing.tab.h: turing.y
	bison -d turing.y 

lex.yy.o: lex.yy.c
lex.yy.c: turing.l
	flex turing.l
clean:
	-@ rm lex.yy.c turing.tab.c *.o turing.tab.h

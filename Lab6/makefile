#Name: Vensan Cabardo
#Date: 2-25-2019
#Course: CS370 Compilers 
#Description:  makefile that will compile both the yacc and the lex file and run the executable made by compiling. y.tab.c and lex.yy.c are needed for creating an executable
all: 
	yacc -d lab6.y
	lex lab6.l
	gcc y.tab.c lex.yy.c ast.c -o lab6
	./lab6 < mytest

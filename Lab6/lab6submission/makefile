#Name: Vensan Cabardo
#Date: 3-11-2019
#Course: CS370 Compilers 
#Description: This makefile will compile the yacc and lex elements and use those, along with the ast.c file, to create an executable. Afterwards, it runs the executable made by compiling. 
all: 
	yacc -d lab6.y
	lex lab6.l
	gcc y.tab.c lex.yy.c ast.c ast.h -o lab6
	./lab6 

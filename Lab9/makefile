#Name: Vensan Cabardo
#Date: 4/9/2019
#Course: CS370 Compilers 
#Description: This makefile will compile the yacc and lex elements and use those, along with the ast.c file, to create an executable. 
all: 
	yacc -d lab9.y
	lex lab9.l
	gcc y.tab.c lex.yy.c ast.c symtable.c -o lab9
	

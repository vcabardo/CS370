#Name: Vensan Cabardo
#Date: 2-15-2019
#Course: CS370 Compilers 
#Description:  makefile that will compile both the yacc and the lex file and run the executable made by compiling
all: 
	yacc -d lab2docalc.y
	lex lab2docalc.l
	gcc y.tab.c -o lab2docalc
	./lab2docalc 

#Name: Vensan Cabardo
#Date: 1/25/2019
#Course: CS370 Compilers 
#Description: This makefile contains the lines necessary for compiling the program.
#This is done so that everytime the lex and yacc file are updated, the makefile will run lex and yacc and compile the lex result
all: 
#yacc creates the files y.tab.c and y.tab.h
	yacc -d lab2docalc.y
#lex creates the file lex.yy.c. We cannot directly compile LEX because
#lex returns only tokens, with no work done to determine if those tokens
#are syntacticaly and semantically correct. That is why YACC is needed,
#to determine correctness from the stream of tokens and perform computations.
	lex lab2docalc.l
	gcc y.tab.c -o lab2docalc

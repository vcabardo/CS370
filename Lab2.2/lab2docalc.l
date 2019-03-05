/*Name: Vensan Cabardo
  Date: 1/25/2019
  Course: CS370 Compilers 
  Description: This is the LEX file that will parse the input and turn the characters into tokens that will eventually be passed to the YACC file
  Input: a text file
  Output: A stream of tokens
*/

/*                 Small LEX routine which returns two formal tokens (INTEGER and VARIABLE)
                   along with single string elements like '+'.
 
                    This LEX definition is the companion to the docalc.y YACC routine which
                   is a simple calculator

                    Shaun Cooper
                    January 2015
*/
%{

int mydebug=1;
#include "y.tab.h"
%}


%%

[a-z]		{	/*returns variable as a token
			upon encountering a single letter and prints
			a debug statement if mydebug = 1*/
			if (mydebug) fprintf(stderr,"Letter found\n"); 
                      	 yylval=*yytext-'a'; return(VARIABLE);
		}
[0-9][0-9]*	{	/*returns integer as a token after encountering 
			  a sequence of digits and prints a debug 
			  statement if mydebug = 1*/
			if (mydebug) fprintf(stderr,"Digit found\n"); 
                         yylval=atoi((const char *)yytext); return(INTEGER);
		}
[ \t]		{	/*prints a debug statement if mydebug = 1*/
			if (mydebug) fprintf(stderr,"Whitespace found\n");
		}
[=\-+*/%&|()] 	{ 	/*prints a debug statement if mydebug = 1*/
			if (mydebug) fprintf(stderr,"return a token %c\n",*yytext); 
                         return (*yytext); //added parenthesis to this directive
                }
\n 		{ if (mydebug) fprintf(stderr,"cariage return %c\n",*yytext); 
                       return (*yytext);}

%%

int yywrap(void)
{ return 1;}



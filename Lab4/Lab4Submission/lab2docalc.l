/*Name: Vensan Cabardo
  Date: 2-15-2019
  Course: CS370 Compilers 
  Description: LEX program that will scan a text file and return tokens - has been altered from the previous to 
  return INT tokens and accept strings of any length as VARIABLE tokens
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
int lineCount = 1;
#include "y.tab.h"
%}


%%
int                         {   /*this directive returns INT as a token upon encountering the string "int"*/
                                if (mydebug) fprintf(stderr,"int found\n"); 
                                return (INT); 
                            } 

[a-zA-Z][0-9|a-zA-Z]*		{	/*this regular expression indicates the format of a variable name - a letter followed 
                                  by 0 or more digits/letters. */
                                if (mydebug) fprintf(stderr,"Variable found: %s\n", yytext); 
                                yylval.string = strdup(yytext); //copy yytext to yylval.string 
                                return(VARIABLE); //return VARIABLE as a token
                            }
[0-9]+	                    {	/*returns INTEGER as a token after encountering 
                                a sequence of digits and prints a debug 
                                statement if mydebug = 1*/
                                if (mydebug) fprintf(stderr,"Digit found\n"); 
                                yylval.number=atoi((const char *)yytext); 
                                return(INTEGER);
                            }
[ \t]		                {	/*prints a debug statement if mydebug = 1*/
                                if (mydebug) fprintf(stderr,"Whitespace found\n");
                            }
[=\-+*/%&|();] 	            { 	/*prints a debug statement if mydebug = 1*/
                                if (mydebug) fprintf(stderr,"return a token %c\n",*yytext); 
                                return (*yytext); //returns the character that was found
                            }
\n 		                    { 
                                if (mydebug) fprintf(stderr,"carriage return %c\n",*yytext);
                                lineCount++; 
                                return (*yytext); //returns \n
                            }

%%

int yywrap(void)
{ return 1; }



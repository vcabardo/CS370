/*Name: Vensan Cabardo
  Date: 3-11-2019
  Course: CS370 Compilers 
  Description: This LEX file defines regular expressions for what we will expect to see in an ALGOL-C program and gives a stream oftokens to YACC for syntax checking. 
  Input: a text file
  Output: A stream of tokens
*/
%{

int mydebug = 0; //setting this to 1 causes the program to print any single characters and reserved words that it comes across
int mydebugconst = 0; //setting this to 1 causes the program to only print the numbers and variable names that are encountered
int lineCount = 1; //variable for storing the lineCount - this variable will be passed to YACC to use in announcing errors
#include "ast.h"
#include "y.tab.h"


%}

%%

int                         {   /*this directive returns INT as a token to YACC upon encountering the string "int"*/
                                if (mydebug) fprintf(stderr,"int found \n"); 
                                return (INT); 
                            } 
                            
void                        {   /*this directive returns VOID to YACC as a token upon encountering the string "void"*/
                                if (mydebug) fprintf(stderr,"void found \n"); 
                                return (VOID); 
                            }

boolean                     {   /*this directive returns BOOLEAN as a token to YACC upon encountering the string "boolean"*/
                                if (mydebug) fprintf(stderr,"boolean found \n"); 
                                return (BOOLEAN); 
                            }
                            
begin                       {   /*this directive returns BEGIN as a token to YACC upon encountering the string "begin"*/
                                if (mydebug) fprintf(stderr,"begin found \n"); 
                                return (BEG); 
                            }
                            
end                         {   /*this directive returns END as a token to YACC upon encountering the string "end"*/
                                if (mydebug) fprintf(stderr,"end found\n"); 
                                return (END); 
                            }
                            
if                          {   /*this directive returns IF as a token to YACC upon encountering the string "if"*/
                                if (mydebug) fprintf(stderr,"if found\n"); 
                                return (IF); 
                            }
                            
then                        {   /*this directive returns THEN as a token to YACC upon encountering the string "then"*/
                                if (mydebug) fprintf(stderr,"then found\n"); 
                                return (THEN); 
                            }
                            
else                        {   /*this directive returns ELSE as a token to YACC upon encountering the string "else"*/
                                if (mydebug) fprintf(stderr,"else found\n"); 
                                return (ELSE); 
                            }
                            
while                       {   /*this directive returns WHILE as a token to YACC upon encountering the string "while"*/
                                if (mydebug) fprintf(stderr,"while found\n"); 
                                return (WHILE); 
                            }
                            
do                          {   /*this directive returns DO as a token to YACC upon encountering the string "do"*/
                                if (mydebug) fprintf(stderr,"do found\n"); 
                                return (DO); 
                            }
                            
return                      {   /*this directive returns RETURN as a token to YACC upon encountering the string "return"*/
                                if (mydebug) fprintf(stderr,"return found\n"); 
                                return (RETURN); 
                            }
                            
read                        {   /*this directive returns READ as a token to YACC upon encountering the string "read"*/
                                if (mydebug) fprintf(stderr,"read found\n"); 
                                return (READ); 
                            }
                            
write                       {   /*this directive returns WRTIE as a token to YACC upon encountering the string "write"*/
                                if (mydebug) fprintf(stderr,"write found\n"); 
                                return (WRITE); 
                            }
                            
and                         {   /*this directive returns AND as a token to YACC upon encountering the string "and"*/
                                if (mydebug) fprintf(stderr,"and found\n"); 
                                return (AND); 
                            }
                            
or                          {   /*this directive returns OR as a token to YACC upon encountering the string "or"*/
                                if (mydebug) fprintf(stderr,"or found\n"); 
                                return (OR); 
                            }
                            
true                        {   /*this directive returns TRUE as a token to YACC upon encountering the string "true"*/
                                if (mydebug) fprintf(stderr,"true found\n"); 
                                return (TRUE); 
                            }
                            
false                       {   /*this directive returns FALSE as a token to YACC upon encountering the string "false"*/
                                if (mydebug) fprintf(stderr,"false found\n"); 
                                return (FALSE); 
                            }
                            
not                         {   /*this directive returns NOT as a token to YACC upon encountering the string "not"*/
                                if (mydebug) fprintf(stderr,"not found\n"); 
                                return (NOT); 
                            }
                            
[ \t]                       {   /*this directive simply prints a debug message if mydebug = 1*/
                                //if (mydebug) fprintf(stderr,"whitespace found %c\n",*yytext);    
                            }

\n		                    {   /*this directive increments the line count upon encountering a new line*/
                                if (mydebug) fprintf(stderr,"carriage return\n");
                                lineCount++; 
                            }
                            
[a-zA-Z][a-zA-Z0-9]*        {	/*this regular expression indicates the format of a variable name - a letter followed by 0 or more digits/letters. */
                                if (mydebugconst) fprintf(stderr,"ID found: %s\n", yytext); 
                                yylval.string = strdup(yytext); //copy yytext to yylval.string 
                                return(ID); //return ID as a token
                            }
                            
[0-9]+	                    {	/*returns NUMBER as a token after encountering a sequence of digits and prints a debug statement if mydebug = 1*/
                                yylval.number=atoi((const char *)yytext); 
                                if (mydebugconst) fprintf(stderr,"Number found: %d\n", yylval.number);
                                return(NUMBER);
                            }
                            

[;()\[\],+*/<>=\-]          { 	/*action for encountering the single characters that are a part of our language - these don't have a value that needs to be sent to yacc, so only the symbol itself is sent*/
                                if (mydebug) fprintf(stderr,"return a token %c\n",*yytext); 
                                return (*yytext); //returns the character that was found
                            }

[<][=]                      {   if (mydebug) fprintf(stderr,"Token found: <=\n");  //return LTE as a token
                                return(LTE);  }

[>][=]                      {   if (mydebug) fprintf(stderr,"Token found: >=\n");   //return GTE as a token
                                return(GTE);  }

[=][=]                      {   if (mydebug) fprintf(stderr,"Token found: ==\n");   //return E as a token
                                return(E);  }

[!][=]                      {   if (mydebug) fprintf(stderr,"Token found: !=\n");   //return NE as a token
                                return(NE);  }

%%

int yywrap(void)
{ return 1; }


%{

/*Name: Vensan Cabardo
  Date: 2-15-2019
  Course: CS370 Compilers 
  Description:  YACC file that reads the tokens returned from LEX, performs the computations 
  specified by the user, and prints the resultsto the screen
  Input: A stream of tokens.
  Output: The operations specified in the text file given to YACC are performed and printed to the screen
*/

/*
 *			**** CALC ****
 *
 * This routine will function like a desk calculator
 * There are 26 integer registers, named 'a' thru 'z'
 *
 */

/* This calculator depends on a LEX description which outputs either VARIABLE or INTEGER.
   The return type via yylval is integer 

   When we need to make yylval more complicated, we need to define a pointer type for yylval 
   and to instruct YACC to use a new type so that we can pass back better values
 
   The registers are based on 0, so we substract 'a' from each single letter we get.

   based on context, we have YACC do the correct memmory look up or the storage depending
   on position

   Shaun Cooper
    January 2015

   problems  fix unary minus, fix parenthesis, add multiplication
   problems  make it so that verbose is on and off with an input argument instead of compiled in
*/


	/* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "lex.yy.c"
#include "symboltable.c"
#define MAX 2 //user cannot exceed MAX variable declarations

int regs[MAX];
int base, debugsw = 1;
int offset = 0; //global offset variable to use as parameter to the insert function - used to ensure each variable gets a unique memory location

void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s\n", s);
}


%}
/*  defines the start symbol, what values come back from LEX and how the operators are associated  */

%start P //change start to P 

/* allow LEX to return integer or string */
%union
{
    int number; //treat token as a 32 bit integer
    char *string; //treat token as a 32 bit pointer to a string
}

%token <number> INTEGER //INTEGER tokens are ints
%token <string>VARIABLE //VARIABLE tokens are strings 
%token INT 

%type<number> expr //must specify the type of expr - it needs to be a number so computations can be performed

%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS


%%	/* end specs, begin rules */

/*extend the CFG to include declarations made at the top of the text file*/
P       :   DECLS list
        ;

/*any amount of declarations are permitted at the top of the file*/
DECLS   :   DECLS DECL
        |   /*empty*/
        ;
      
/*define what a declaration is in our language*/
DECL    :   INT VARIABLE';''\n' 
            { 
                /*semantic action for finding a declaration*/
                if( debugsw == 1 )
                    printf( "declaration found\n"); 
                    
                int result = Search($2); //returns -1 if not in table, and the offset if it is in the table
                
                /*will fall into this if condition if the variable has already been declared. Cannot insert a duplicate value*/
                if( result != -1 )
                {
                    //broadcast an error message
                    printf( "Error: variable already exists, error on line %d\n", lineCount  );
                    exit( 0 );
                }
                
                /*will fall into this else condition if the variable hasn't been declared yet. Insert the variable name and offset into the symbol table*/
                else
                {
                    if( size < MAX ) //if statement to ensure that no more than MAX variables are declared
                    {
                        Insert( $2, offset ); //insert new entry
                        offset++; //increase offset
                        
                        //display the symbol table after insertion
                        if( debugsw == 1 )
                            Display();
                    }
                    
                    else //if over MAX variables have been declared, print an error
                    {
                        fprintf( stderr, "Max number of variable declarations has been reached\n" );
                        exit(0);
                    }
                }
                
            }
        ;
        
list	:	/* empty */
	|	list stat '\n'
	|	list error '\n'
			{ yyerrok; }
	;

stat	:	/*The following code defines actions for when a single expression is left as 
     		  well as when an assignment statement is typed*/
        expr     
            { fprintf(stderr,"the answer is %d\n", $1); }
	|	VARIABLE '=' expr
            { 
            /*semantic action for finding a delcaration*/
                int result = Search($1);
                
                if( result == -1 ) //if variable doesn't exist, print an error as you cannot assign a value to a nonexistent variable
                {
                    fprintf(stderr,"Cannot assign a value to a nonexistent variable, error on line %d\n", lineCount );
                    exit(0);
                }
                else //otherwise, store the value in expr in a register
                {
                    regs[result] = $3;
                }
            }
	;

expr	:	/*The following code is used to transform tokens from LEX into expressions that YACC can
     		use to perform computations*/
                '(' expr ')'
			{ $$ = $2; }
	|	expr '-' expr
			{ $$ = $1 - $3; }
	|	expr '+' expr
			{ $$ = $1 + $3; }
	|	expr '/' expr
			{ $$ = $1 / $3; }
    |   expr '*' expr //added the definition for multiplication in expr
            { $$ = $1 * $3; } //manipulated the registers in the same way as the other arithmetic operators
	|	expr '%' expr
			{ $$ = $1 % $3; }
	|	expr '&' expr
			{ $$ = $1 & $3; }
	|	expr '|' expr
			{ $$ = $1 | $3; }
	|	'-' expr	%prec UMINUS //removed the first operator for unary minus
			{ $$ = -$2; }
	|	VARIABLE
			{ 
			/*semantic action for finding a variable name by itself*/
                int result = Search($1);
                
                if( result != -1 ) //in symbol table
                {
                    $$ = regs[result]; //get the value of the variable and store it in $$
                    fprintf(stderr,"found a variable value: %s = %d\n", $1, $$);
                    
                    if( debugsw == 1 )
                        Display();
                }
                else //not in symbol table
                {
                    $$ = 0; //all unknown variables are 0
                    fprintf(stderr,"\n");
                    fprintf( stderr, "Variable has not been declared, error on line %d", lineCount );
                    exit(0);
                }
            }
	|	INTEGER {$$=$1; fprintf(stderr,"found an integer\n");}
	;
	



%%	/* end of rules, start of program */

int main()
{ 
    yyparse();
}

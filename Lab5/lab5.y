%{

/*Name: Vensan Cabardo
  Date: 2-25-2019
  Course: CS370 Compilers 
  Description:  YACC program that defines the syntax rules for an ALGOL like language - this program parses only for syntactical correctness, there are no syntax directed semantic actions.
  Input: A stream of tokens from LEX
  Output: This program will print the line number of a syntax error if applicable, and will otherwise give the user a message stating that their program was syntactically correct.
*/


	/* begin specs */
#include <stdio.h>
#include <ctype.h>
/*lineCount is a variable that will be accessed from and incremented in LEX. This line allows YACC to access it and use it to print error messages*/
extern int lineCount; 

int yylex();

int base, debugsw = 1;

void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s on line %d\n", s, lineCount);
}


%}

%start PROGRAM

/* allow LEX to return integer or string */
%union
{
    int number; //treat token as a 32 bit integer
    char *string; //treat token as a 32 bit pointer to a string
}

/*define the tokens that will be used by yacc to check for syntax correctness - these were the bold elements in the grammar definition of this language.*/ 
%token <number> NUMBER
%token <string> ID
%token INT VOID BOOLEAN BEG END IF THEN ELSE WHILE DO RETURN READ WRITE AND OR TRUE FALSE NOT
%token LTE GTE E NE 


%%	/* end specs, begin rules */

/*program -> declaration-list*/
PROGRAM         :   DECLIST
                ;   

/*declaration-list -> declaration { declaration }*/
DECLIST         :   DECLARATION 
                |   DECLARATION DECLIST
                ;
      
/*declaration -> var-declaration | fun-declaration
defines what is considered a declaration in this language*/
DECLARATION     :   VAR_DEC
                |   FUN_DEC
                ;
                
/*var-declaration -> type-specifier var-list ;
defines a variable declaration*/
VAR_DEC         :   TYPE VAR_LIST ';' 
                ;
                
/*var-list -> ID | ID [ NUM ] | ID , var-list | ID [ NUM ] ,
defines the kinds of variables that can be included in a declaration:
any number of variables and arrays*/
VAR_LIST        :   ID
                |   ID '[' NUMBER ']'
                |   ID ',' VAR_LIST
                |   ID '[' NUMBER ']' ',' VAR_LIST
                ;
                
/*type-specifier -> int | void | boolean
defines the three types that will be used by this program*/
TYPE            :   INT 
                |   VOID
                |   BOOLEAN
                ;
                
/*fun-declaration -> type-specifier ID ( params ) compound-stmt
the production rules following this one must be included within 
a function declaration*/
FUN_DEC         :   TYPE ID '(' PARAMS ')' CMPD_STMT
                ;
                
/*params -> void | param-list
*/
PARAMS          :   VOID
                |   PARAM_LIST
                ;
                
/*param-list -> param { , param }*/
PARAM_LIST      :   PARAM
                |   PARAM ',' PARAM_LIST
                ;
                
/*param -> type-specifier ID [[]]*/
PARAM           :   TYPE ID
                |   TYPE ID '[' ']' 
                ;
                
/*compound-stmt -> begin local-declarations statement-list end*/
CMPD_STMT       :   BEG LOCAL_DECS STAT_LIST END
                ;
                
/*local-declaration -> { var-declarations }*/
LOCAL_DECS      :   /*EMPTY*/
                |   VAR_DEC LOCAL_DECS
                ;
                
/*statement-list -> { statement }*/
STAT_LIST       :   /*EMPTY*/
                |   STAT STAT_LIST
                ;
                
/*statement -> expression-stmt | compound-stmt | selection-stmt | iteration-stmt | assignment-stmt | return-stmt | read-stmt | write-stmt*/
STAT            :   EXPR_STMT
                |   CMPD_STMT
                |   SELECT_STMT
                |   ITER_STMT
                |   ASSIGN_STMT
                |   RETURN_STMT
                |   READ_STMT
                |   WRITE_STMT
                ;
                
/*expression-stmt -> expression ; | ;*/
EXPR_STMT       :   EXPR ';'
                |   ';' 
                ;
                
/*selection-stmt -> if expression then statement [ else statement ]*/
SELECT_STMT     :   IF EXPR THEN STAT
                |   IF EXPR THEN STAT ELSE STAT
                ;
                
/*iteration-stmt -> while expression do statement*/
ITER_STMT       :   WHILE EXPR DO STAT
                ;
                
/*return-stmt -> return [ expression ] ;*/
RETURN_STMT     :   RETURN ';'
                |   RETURN EXPR ';'
                ;
                 
/*read-stmt -> read variable ;*/
READ_STMT       :   READ VAR ';'
                ;
                
/*write-stmt -> write expression;*/
WRITE_STMT      :   WRITE EXPR ';' 
                ;
                
/*assignment-stmt -> var = simple-expression ;*/
ASSIGN_STMT     :   VAR '=' SIMP_EXPR ';'
                ;
                
/*expression -> simple-expression*/
EXPR            :   SIMP_EXPR
                ;
                
/*var -> ID [ [ expression ] ] */
VAR             :   ID
                |   ID '[' EXPR ']'
                ;
                
/*simple-expression -> additive-expression [ relop additive-expression ]*/
SIMP_EXPR       :   ADD_EXPR
                |   ADD_EXPR RELOP ADD_EXPR
                ;
                
/*relop -> <= | < | > | >= | == | !=*/
RELOP           :   LTE
                |   '<'
                |   '>'
                |   GTE
                |   E
                |   NE
                ;
                
/*additive-expression -> term { addop term }*/
ADD_EXPR        :   TERM
                |   ADD_EXPR ADDOP TERM
                ;
                
/*addop -> + | -*/
ADDOP           :   '+'
                |   '-'
                ;
                
/*term -> factor { multop factor }*/
TERM            :   FACTOR 
                |   TERM MULTOP FACTOR
                ;
                
/*multop -> * | / | and | or*/
MULTOP          :   '*'
                |   '/'
                |   AND
                |   OR
                ;
                
/* factor -> ( expression ) | NUM | var | call | true | false | not factor*/
FACTOR          :   '(' EXPR ')'
                |   NUMBER
                |   VAR
                |   CALL 
                |   TRUE
                |   FALSE
                |   NOT FACTOR
                ;
                
/*call -> ID ( args )*/
CALL            :   ID '(' ARGS ')'
                ;
                
/*args -> arg-list | empty*/
ARGS            :   ARG_LIST
                |   /*EMPTY*/
                ;
                
/*arg-list -> expression { , expression }*/
ARG_LIST        :   EXPR
                |   EXPR ',' EXPR
                ;
            

%%	/* end of rules, start of program */

int main()
{ 
    /*yyparse will return 0 if no syntax errors and the whole program was parsed. In this case, print a success message*/
    if( yyparse() == 0 )
    {
        printf( "The program is syntactically correct.\n" );
    }
    
}

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
#include "ast.h"
#include "y.tab.h"

struct ASTnodetype *myprogram = NULL;
enum SYSTEMTYPES Cur_Type; // used to maintain type during type variable declaration

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
    struct ASTnodetype *node; //allow AST nodes to be constructed by the program 
}

/*define the tokens that will be used by yacc to check for syntax correctness - these were the bold elements in the grammar definition of this language.*/ 
%token <number> NUMBER
%token <string> ID
%token BEG END IF THEN ELSE WHILE DO RETURN READ WRITE AND OR TRUE FALSE NOT INT VOID BOOLEAN
%token LTE GTE E NE 

/*define the types of some of the so that we can build nodes in the semantic actions for those productions or pass the reference to certain nodes to different productions*/
%type<node> PROGRAM DECLIST DECLARATION VAR_DEC VAR_LIST FUN_DEC CMPD_STMT PARAMS PARAM_LIST PARAM LOCAL_DECS STAT_LIST STAT

%%	/* end specs, begin rules */

/*program -> declaration-list*/
PROGRAM         :   DECLIST 
                    { 
                        myprogram = $1; /*store the final tree in myprogram so that we have a handle to it for printing*/
                    }
                ;   

/*declaration-list -> declaration { declaration }*/
DECLIST         :   DECLARATION 
                    {  
                        $$ = $1; /*pass all declarations and their associated nodes to DECLIST*/
                    }   
                |   DECLARATION DECLIST 
                    {   
                        $1->next = $2; /*next isused to connect sentences - it is used here to connect the different declarations in the tree*/
                        $$ = $1; /*pass the reference to the nodes that have been built up to DECLIST*/
                    }
                ;
      
/*declaration -> var-declaration | fun-declaration
defines what is considered a declaration in this language*/
DECLARATION     :   VAR_DEC     
                    { 
                        $$ = $1; /*pass the reference to the vardec nodes that have been built up to DECLARATION*/
                    }
                |   FUN_DEC     
                    { 
                        $$ = $1; /*pass the reference to the fundec nodes that have been built up to DECLARATION*/
                    }
                ;
                
/*var-declaration -> type-specifier var-list ;
defines a variable declaration*/
VAR_DEC         :   TYPE VAR_LIST ';'
                    {  
                        $2->mytype = Cur_Type; 
                        $$ = $2; /*the VARDEC nodes that are created will be stored in VAR_LIST, so pass that reference up to VAR_DEC*/
                    }
                ;
                
/*var-list -> ID | ID [ NUM ] | ID , var-list | ID [ NUM ] ,
defines the kinds of variables that can be included in a declaration:
any number of variables and arrays*/
/*in general, for each case a new node is built, with the name obtained from the ID token. The value attribute is only set for array variables, because value is used to store the size of the array. The nodes' types are set using the Cur_Type global variable. If multiple variable declarations are on the same line, then those nodes are connected using s1 to avoid overriding data, as would happen if the next attribute was used to connect.*/
VAR_LIST        :   ID
                    {
                        $$ = ASTCreateNode( VARDEC ); 
                        $$->name = $1; 
                        $$->mytype = Cur_Type; 
                    }
                |   ID '[' NUMBER ']'
                    {
                        $$ = ASTCreateNode( VARDEC );
                        $$->name = $1; 
                        $$->value = $3; 
                        $$->mytype = Cur_Type;
                    }
                |   ID ',' VAR_LIST
                    {
                        $$ = ASTCreateNode( VARDEC ); 
                        $$->name = $1;
                        $3->mytype = Cur_Type;  
                        $$->s1 = $3;
                    }
                |   ID '[' NUMBER ']' ',' VAR_LIST
                    {
                        $$ = ASTCreateNode( VARDEC ); 
                        $$->name = $1; 
                        $$->value = $3; 
                        $6->mytype = Cur_Type; 
                        $$->s1 = $6; 
                    }
                ;
                
/*type-specifier -> int | void | boolean
defines the three types that will be used by this program*/
/*Cur_Type will be used to specify the types when creating VARDEC and FUNDEC nodes*/ 
TYPE            :   INT         { Cur_Type = INTTYPE; }
                |   VOID        { Cur_Type = VOIDTYPE; }
                |   BOOLEAN     { Cur_Type = BOOLTYPE; }
                ;
                
/*fun-declaration -> type-specifier ID ( params ) compound-stmt
the production rules following this one must be included within 
a function declaration*/
FUN_DEC         :   TYPE ID '(' PARAMS ')' CMPD_STMT
                    {
                        $$ = ASTCreateNode( FUNDEC );
                        $$->name = $2;
                        $$->mytype = Cur_Type;
                        $$->s1 = $4;
                        $$->s2= $6;
                    }
                ;
                
/*params -> void | param-list
*/
PARAMS          :   VOID
                    {
                        $$ = ASTCreateNode( PARAM );
                        $$->mytype = VOIDTYPE;
                    }
                |   PARAM_LIST  { $$ = $1; }
                ;
                
/*param-list -> param { , param }*/
PARAM_LIST      :   PARAM       { $$ = $1; }
                |   PARAM ',' PARAM_LIST  { $$ = $1; $$->s1 = $3; }
                ;
                
/*param -> type-specifier ID [[]]*/
PARAM           :   TYPE ID
                    {
                        $$ = ASTCreateNode( PARAM );
                        $$->mytype = Cur_Type;
                        $$->name = $2;
                    }
                |   TYPE ID '[' ']' 
                    {
                        $$ = ASTCreateNode( PARAM );
                        $$->mytype = Cur_Type;
                        $$->name = $2;
                        $$->value = 1; //just choose some value that isn't 0 to differentiate the type of declaration in the print routine
                    }
                ;
                
/*compound-stmt -> begin local-declarations statement-list end*/
CMPD_STMT       :   BEG LOCAL_DECS STAT_LIST END
                    {
                        $$ = ASTCreateNode( BLOCK );
                        //?????????????????????????????????????????????????????????????
                        //$$->s1 = $2;
                        //$$->s2 = $3;
                    }
                ;
                
/*local-declaration -> { var-declarations }*/
LOCAL_DECS      :   /*EMPTY*/   { $$ = NULL; }
                |   VAR_DEC LOCAL_DECS
                ;
                
/*statement-list -> { statement }*/
STAT_LIST       :   /*EMPTY*/   { $$ = NULL; }
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
        ASTprint( 0, myprogram );
    }
    
}

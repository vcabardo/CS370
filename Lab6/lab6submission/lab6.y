%{
/*Name: Vensan Cabardo
  Date: 3-11-2019
  Course: CS370 Compilers 
  Description: This program takes a stream of tokens from lex and checks for syntac correctness. Additionally, it creates an immediate representation in the form of an AST. At the end of parsing the final AST is stored in the global variable myprogram. 
  Input: A stream of tokens
  Output: An AST is built and its contents are output by utilizing the print routine on myprogram. 
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
    enum OPERATORS operator;
}

/*define the tokens that will be used by yacc to check for syntax correctness - these were the bold elements in the grammar definition of this language.*/ 
%token <number> NUMBER
%token <string> ID
%token BEG END IF THEN ELSE WHILE DO RETURN READ WRITE AND OR TRUE FALSE NOT INT VOID BOOLEAN

/*define operator as a type for arithmetic operators and relational operators*/
%token<operator> LTE GTE E NE 
%type<operator> RELOP ADDOP MULTOP

/*define the types of some of the so that we can build nodes in the semantic actions for those productions or pass the reference to certain nodes to different productions*/
%type<node> PROGRAM DECLIST DECLARATION VAR_DEC VAR_LIST FUN_DEC CMPD_STMT PARAMS PARAM_LIST PARAM LOCAL_DECS STAT STAT_LIST READ_STMT FACTOR VAR RETURN_STMT EXPR_STMT EXPR SELECT_STMT ITER_STMT ASSIGN_STMT WRITE_STMT SIMP_EXPR ADD_EXPR TERM CALL ARGS ARG_LIST

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
                        $1->next = $2; /*next is used to connect sentences - it is used here to connect the different declarations in the tree*/
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
                
/*params -> void | param-list*/
/*if the parameter is void, create a new node and set the type without setting the name. otherwise
pass up the reference to the parameter list*/
PARAMS          :   VOID
                    {
                        $$ = ASTCreateNode( PARAM );
                        $$->mytype = VOIDTYPE;
                    }
                |   PARAM_LIST  { $$ = $1; }
                ;
                
/*param-list -> param { , param }*/
/*if a single parameter, just pass up the reference to the node that was created. if a list, 
connect the elements using s1*/
PARAM_LIST      :   PARAM       { $$ = $1; }
                |   PARAM ',' PARAM_LIST  { $$ = $1; $$->next = $3; }
                ;
                
/*param -> type-specifier ID [[]]*/
/*in this production rule we create the nodes that will represent the parameters in the parameter list. 
The type is assigned using the global variable Cur_Type.*/
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
/*create a BLOCK node that is connected to local decs and stat list using s1 and 
s2 respectively. */
CMPD_STMT       :   BEG LOCAL_DECS STAT_LIST END
                    {
                        $$ = ASTCreateNode( BLOCK );
                        $$->s1 = $2; //connect local decs to the block
                        $$->s2 = $3; //connect statements to the block
                    }
                ;
                
/*local-declaration -> { var-declarations }*/
/*this production returns NULL if no local declarations are made, and otherwise passes the reference 
to the vardec nodes, connecting multiple declarations using next*/
LOCAL_DECS      :   /*EMPTY*/   { $$ = NULL; }
                |   VAR_DEC LOCAL_DECS
                    {
                        $$ = $1;
                        $$->next = $2;  //connect multiple declarations together
                    }
                ;
                
/*statement-list -> { statement }*/
/*this production returns NULL if no statements are made, and otherwise passes the reference 
to the stat nodes, connecting multiple statements using next*/
STAT_LIST       :   /*EMPTY*/   { $$ = NULL; }
                |   STAT STAT_LIST
                    {
                        $$ = $1;
                        $$->next = $2; //connect multiple statements together
                    }
                ;
                
/*statement -> expression-stmt | compound-stmt | selection-stmt | iteration-stmt |
assignment-stmt | return-stmt | read-stmt | write-stmt*/
/*for each kind of statement, simply pass the references to the respective nodes up the tree*/
STAT            :   EXPR_STMT       { $$ = $1; }
                |   CMPD_STMT       { $$ = $1; }
                |   SELECT_STMT     { $$ = $1; }
                |   ITER_STMT       { $$ = $1; }
                |   ASSIGN_STMT     { $$ = $1; }
                |   RETURN_STMT     { $$ = $1; }
                |   READ_STMT       { $$ = $1; }
                |   WRITE_STMT      { $$ = $1; }
                ;
                
/*expression-stmt -> expression ; | ;*/

EXPR_STMT       :   EXPR ';'  
                    { 
                        $$ = ASTCreateNode( EXPRESSSTMT ); //create am expression statement node
                        $$->s1 = $1; //reference the expression using s1
                    }
                |   ';'       
                    { 
                        $$ = ASTCreateNode( EXPRESSSTMT ); //create an expression statement node
                    }
                ;
                
/*selection-stmt -> if expression then statement [ else statement ]*/
SELECT_STMT     :   IF EXPR THEN STAT
                    {
                        $$ = ASTCreateNode( IFTHEN );
                        $$->s1 = $2; //reference the expression
                        $$->s2 = $4; //reference the statement
                    }
                |   IF EXPR THEN STAT ELSE STAT
                    {
                        $$ = ASTCreateNode( IFTHEN );
                        $$->s1 = $2; //reference the expression
                        $$->s2 = ASTCreateNode( ELSEST ); //create a new node to hold both statements
                        $$->s2->s1 = $4; //connect the first statement to the else node using s1
                        $$->s2->s2 = $6; //connect the second statement to the else node using s2
                    }
                ;
                
/*iteration-stmt -> while expression do statement*/
/*create a while statement node and connect the conditional and statements
using s1 and s2 respectively*/
ITER_STMT       :   WHILE EXPR DO STAT
                    {
                        $$ = ASTCreateNode( WHILEST );
                        $$->s1 = $2; //connect expressions to the while node
                        $$->s2 = $4; //connect statements to the while node
                    }
                ;
                
/*return-stmt -> return [ expression ] ;*/
RETURN_STMT     :   RETURN ';'
                    {
                        $$ = ASTCreateNode( RET ); //simply create a return node without assigning any other values
                    }
                |   RETURN EXPR ';'
                    {
                        $$ = ASTCreateNode( RET );
                        $$->s1 = $2; //connect the expression that is associated with the return statement using s1
                    }
                ;
                 
/*read-stmt -> read variable ;*/
READ_STMT       :   READ VAR ';'
                    {
                        $$ = ASTCreateNode( READST ); 
                        $$->s1 = $2; //connect the variable to the read statement using s1
                    }
                ;
                
/*write-stmt -> write expression;*/
WRITE_STMT      :   WRITE EXPR ';' 
                    {
                        $$ = ASTCreateNode( WRITEST );
                        $$->s1 = $2; //connect the expression to the write statement using s1
                    }
                ;
                
/*assignment-stmt -> var = expression-statement ;*/
ASSIGN_STMT     :   VAR '=' SIMP_EXPR ';'
                    {
                        $$ = ASTCreateNode( ASSIGNST );
                        $$->s1 = $1; //connect the variable part of assignment using s1
                        $$->s2 = $3; //connect the expression part of the assignment using s2
                    }
                ;
                
/*expression -> simple-expression*/
EXPR            :   SIMP_EXPR  { $$ = $1; }
                ;
                
/*var -> ID [ [ expression ] ] */
VAR             :   ID
                    {
                        $$ = ASTCreateNode( IDENT ); 
                        $$->name = $1;
                    }
                |   ID '[' EXPR ']'
                    {
                        $$ = ASTCreateNode( IDENT );
                        $$->name = $1;
                        $$->value = 1; //set to a non-zero value for printing purposes
                        $$->s1 = $3;
                    }
                ;
                
/*simple-expression -> additive-expression [ relop additive-expression ]*/
SIMP_EXPR       :   ADD_EXPR  { $$ = $1; }
                |   SIMP_EXPR RELOP ADD_EXPR
                    {
                        $$ = ASTCreateNode( EXPRESS );
                        $$->operator = $2; //set the operator associated with the expression
                        $$->s1 = $1; //connect the left operand using s1
                        $$->s2 = $3; //connect the right operand using s2
                    }
                ;
                
/*relop -> <= | < | > | >= | == | !=*/
/*assign RELOP values based on the appropriate operators enum*/
RELOP           :   LTE     { $$ = LTEQ; }
                |   '<'     { $$ = LT; }
                |   '>'     { $$ = GT; }
                |   GTE     { $$ = GTEQ; }
                |   E       { $$ = EQ; }
                |   NE      { $$ = NEQ; }
                ;
                
/*additive-expression -> term { addop term }*/
ADD_EXPR        :   TERM   { $$ = $1; }
                |   ADD_EXPR ADDOP TERM
                    {
                        $$ = ASTCreateNode( EXPRESS );
                        $$->operator = $2; //set the addition operator associated with the expression
                        $$->s1 = $1; //connect the left operand using s1
                        $$->s2 = $3; //connect the right operand using s2
                    }
                ;
                
/*addop -> + | -*/
/*assign ADDOP values based on the appropriate operators enum*/
ADDOP           :   '+'     { $$ = PLUS; }
                |   '-'     { $$ = MINUS; }
                ;
                
/*term -> factor { multop factor }*/
TERM            :   FACTOR { $$ = $1; }
                |   TERM MULTOP FACTOR
                    {
                        $$ = ASTCreateNode( EXPRESS ); //for ease of implementation simply declare this sentence to be an expression - there's no use in differentating the types
                        $$->operator = $2; //store the operator
                        $$->s1 = $1; //s1 points to the left operand
                        $$->s2 = $3; //s2 points to the right operand
                    }
                ;
                
/*multop -> * | / | and | or*/
/*assign MULTOP values based on the appropriate operators enum*/
MULTOP          :   '*'     { $$ = MULTIPLY; }
                |   '/'     { $$ = DIVIDE; }
                |   AND     { $$ = ANDOP; }
                |   OR      { $$ = OROP; }
                ;
                
/* factor -> ( expression ) | NUM | var | call | true | false | not factor*/
FACTOR          :   '(' EXPR ')'
                    {
                        $$ = $2; //pass the reference to the expression to factor
                    }
                |   NUMBER
                    { 
                        $$ = ASTCreateNode( NUM ); //create a new node
                        $$->value = $1; //assign the nodes value to be the number
                    }
                |   VAR     { $$ = $1; }
                |   CALL    { $$ = $1; }
                |   TRUE
                    {
                        /*true is equivalent to 1*/
                        $$ = ASTCreateNode( NUM );
                        $$->value = 1;
                    }
                |   FALSE
                    {
                        /*false is equivalent to 0*/
                        $$ = ASTCreateNode( NUM );
                        $$->value = 0;
                    }
                |   NOT FACTOR 
                    { 
                        $$ = ASTCreateNode( EXPRESS ); 
                        $$->operator = MYNOT; //assign the operator to be NOT
                        $$->s1 = $2; //have this expression node reference factor through s1
                    }
                ;
                
/*call -> ID ( args )*/
CALL            :   ID '(' ARGS ')'
                    {
                        $$ = ASTCreateNode( CALLFUNC ); //create a call node
                        $$->name = $1; //set the name
                        $$->s1 = $3; //connect the argument list using s1
                    }
                ;
                
/*args -> arg-list | empty*/
ARGS            :   ARG_LIST  { $$ = $1; }
                |   /*EMPTY*/ { $$ = NULL; }
                ;
                
/*arg-list -> expression { , expression }*/
ARG_LIST        :   EXPR 
                    { 
                        $$ = ASTCreateNode( ARG ); //create an ARG node
                        $$->s1 = $1; //connnect the expression using s1
                    }
                |   EXPR ',' ARG_LIST 
                    { 
                        $$ = ASTCreateNode( ARG ); //create an ARG node
                        $$->s1 = $1; //connnect the expression using s1
                        $$->next = $3; //connect multiple arguments using next
                    }
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

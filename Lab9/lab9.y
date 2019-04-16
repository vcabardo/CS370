%{

/*Name: Vensan Cabardo
  Date:4/9/2019
  Course: CS370 Compilers 
  Description:  YACC program that defines the syntax rules for an ALGOL like language and has semantic action to create an intermediate representation and modify the symbol table to verify the declaration and usage of variables.
  Input: A stream of tokens from LEX
  Output: This program will print the line number of a syntax error if applicable, and will otherwise give the user a message stating that their program was syntactically correct. It will build an Abstract Syntax Tree out of the program's information and do variable/type checking through the symbol table
*/


	/* begin specs */
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "symtable.h"
#include "ast.h"
#include "EMITAST.h"

//for readability, define the constants to be used for the IsAFunc parameter of the Insert function
#define TYPE_SCALAR 0
#define TYPE_ARRAY 1
#define TYPE_FUNCTION 2

struct ASTnodetype *myprogram = NULL;
int level = 0; //this variable will be used in the symbol table to handle variable scope

int goffset = 0; //to hold the overall offset because the other offset variable will be reset when functions are entered

int offset = 0; //to hold the local offset

//used to allocate the maximum amount of offset for every function, because functions are unbounded
int maxoffset = 0; 

//lineCount is a variable that will be accessed from and incremented in LEX. This line allows YACC to access it and use it to print error messages
extern int lineCount; 

int yylex();
int max( int, int ); //prototype for the max function - used to maintain maxoffset
int CompareParams( ASTnode*, ASTnode* ); //prototype for the function that will test if formal and actual parameters are the same length and type

int base, debugsw = 0;

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
    enum OPERATORS operator; //allow some productions to be operators
    enum SYSTEMTYPES type; //allow some productions to be types
}

/*define the tokens that will be used by yacc to check for syntax correctness - these were the bold elements in the grammar definition of this language.*/ 
%token <number> NUMBER
%token <string> ID STRING
%token BEG END IF THEN ELSE WHILE DO RETURN READ WRITE AND OR TRUE FALSE NOT
/*define operator as a type for arithmetic operators and relational operators*/
%token<operator> LTE GTE E NE 
%type<operator> RELOP ADDOP MULTOP

%token<type> INT VOID BOOLEAN
%type<type> TYPE

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
                        $$ = $2; /*the VARDEC nodes that are created will be stored in VAR_LIST, so pass that reference up to VAR_DEC*/
                        
                        //go through every connected node in varlist and individually change the type and the type of the entry in the symbol table
                        ASTnode *p = $2;
                        while( p != NULL )
                        {
                            p->mytype = $1;
                            p->symbol->Type = $1;
                            p = p->s1;
                        }
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
                        struct SymbTab *p;
                        
                        //if the ID is already in the symbol table, it cannot be declared again - throw an error if thats the case
                        if( (p = Search( $1, level, 0 )) != NULL )
                        {
                            fprintf( stderr, "Error: variable %s has already been defined on level %d\n", $1, level );
                            exit(0);
                        }

                        //if it isn't in the symbol table, it's safe to insert. Do so, and then increment offset by one because a single scalar vardec only requires one word
                        else
                        {
                            $$->symbol = Insert( $1, offset, level, 1, TYPE_SCALAR, NULL, 0 );
                            offset++;
                            
                            if( debugsw )
                                Display();
                        }
                    }
                |   ID '[' NUMBER ']'
                    {
                        $$ = ASTCreateNode( VARDEC );
                        $$->name = $1; 
                        $$->value = $3; 
                        struct SymbTab *p;
                        
                        //if the ID is already in the symbol table, it cannot be declared again - throw an error if thats the case
                        if( (p = Search( $1, level, 0 )) != NULL )
                        {
                            fprintf( stderr, "Error: variable %s has already been defined on level %d\n", $1, level );
                            exit(0);
                        }

                        //otherwise, insert into the symbol table and increment offset by the size of the array
                        else
                        {
                            $$->symbol = Insert( $1, offset, level, $3, TYPE_ARRAY, NULL, 0 );
                            offset+=$3;
                            
                            if( debugsw )
                                Display();
                        }
                    }
                    
                |   ID ',' VAR_LIST
                    {
                        $$ = ASTCreateNode( VARDEC ); 
                        $$->name = $1; 
                        $$->s1 = $3;
                        struct SymbTab *p;
                        
                        //if the ID is already in the symbol table, it cannot be declared again - throw an error if thats the case
                        if( (p = Search( $1, level, 0 )) != NULL )
                        {
                            fprintf( stderr, "Error: variable %s has already been defined on level %d\n", $1, level );
                            exit(1);
                        }

                        //insert as before into the symbol table, incrementing the offset by one word
                        else
                        {
                            $$->symbol = Insert( $1, offset, level, 1, TYPE_SCALAR, NULL ,0 );
                            offset++;
                            
                            if( debugsw )
                                Display();
                        }
                    }
                |   ID '[' NUMBER ']' ',' VAR_LIST
                    {
                        $$ = ASTCreateNode( VARDEC ); 
                        $$->name = $1; 
                        $$->value = $3; 
                        $$->s1 = $6; 
                        struct SymbTab *p;
                        
                        //if the ID is already in the symbol table, it cannot be declared again - throw an error if thats the case
                        if( ( p = Search( $1, level, 0 )) != NULL )
                        {
                            fprintf( stderr, "Error: variable %s has already been defined on level %d\n", $1, level );
                            exit(1);
                        }

                        //insert as before, incrementing offset by the size of the array
                        else
                        {
                            $$->symbol = Insert( $1, offset, level, $3, TYPE_ARRAY, NULL, 0 );
                            offset+=$3;
                            
                            if( debugsw )
                                Display();
                        }
                    }
                ;
                
/*type-specifier -> int | void | boolean
defines the three types that will be used by this program*/
/*Cur_Type will be used to specify the types when creating VARDEC and FUNDEC nodes*/ 
TYPE            :   INT         { $$ = INTTYPE; }
                |   VOID        { $$ = VOIDTYPE; }
                |   BOOLEAN     { $$ = BOOLTYPE; }
                ;
                
/*fun-declaration -> type-specifier ID ( params ) compound-stmt
the production rules following this one must be included within 
a function declaration*/
FUN_DEC         :   TYPE ID '(' 
                    { 
                        struct SymbTab *p;
                        
                        //if the identifier doesn't exist at this level, insert the function into the symbol table
                        if( (p = Search( $2, 0, 0 )) == NULL )
                            Insert($2, 0, level, 0, TYPE_FUNCTION, NULL, $1);
                            
                        //otherwise broadcast an error
                        else
                        {
                            yyerror( "MULTIPLE FUNCTION DECLARATION" );
                        }
                            
                        goffset = offset; //set global offset before resetting offset
                        offset= 2; //reset offset to 2 (for the stack pointer and the base pointer)
                    }
                                  
                    PARAMS 
                    {
                        // at this point the parameters are known - change the type of the entry in the symbol table
                        (Search( $2, level, 0 ))->fparms = $5;
                    }
                    
                    ')' CMPD_STMT
                    {
                        $$ = ASTCreateNode( FUNDEC );
                        $$->symbol = Search( $2, 0, 0 );
                        $$->name = $2;
                        $$->mytype = $1;
                        $$->s1 = $5;
                        $$->s2= $8;
                            
                        $$->symbol->mysize = maxoffset;
                        $$->value = maxoffset;

                        offset-=Delete(1);  /* remove all the symbols from what we put in from the function call*/
                        level=0;  /* reset the level */
                        offset=goffset; // reset the offset to be what it was before the function declaration
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
                |   PARAM_LIST  
                    { 
                        $$ = $1; 
                    }
                ;
                
/*param-list -> param { , param }*/
/*if a single parameter, just pass up the reference to the node that was created. if a list, 
connect the elements using s1*/
PARAM_LIST      :   PARAM       
                    { 
                        $$ = $1; 
                    }
                |   PARAM ',' PARAM_LIST  
                    { 
                        $$ = $1; 
                        $$->next = $3; 
                    }
                ;
                
/*param -> type-specifier ID [[]]*/
/*in this production rule we create the nodes that will represent the parameters in the parameter list.*/
PARAM           :   TYPE ID
                    {
                        $$ = ASTCreateNode( PARAM );
                        struct SymbTab *p;
                        
                        //check if any parameters have the same name. If not, insert into the symbol table
                        if( (p = Search( $2, level + 1, 0 )) == NULL )
                            $$->symbol = Insert( $2, offset, level + 1, 1, TYPE_SCALAR, NULL, $1 );
                            
                        else
                        {
                            yyerror( "MULTIPLE IDENTICAL PARAMETERS" );
                            exit( 1 );
                        }
                            
                        offset++; //increment offset by one for every parameter
                        $$->mytype = $1;
                        $$->name = $2;
                    }
                |   TYPE ID '[' ']' 
                    {
                        $$ = ASTCreateNode( PARAM );
                        struct SymbTab *p;
                        
                        //check if any parameters have the same name. If not, insert into the symbol table
                        if( (p = Search( $2, level + 1, 0 )) == NULL )
                            $$->symbol = Insert( $2, offset, level + 1, 1, TYPE_ARRAY, NULL, 0 );
                            
                        else
                        {
                            yyerror( "MULTIPLE IDENTICAL PARAMETERS" );
                            exit( 1 );
                        }
                            
                        offset++; //increment offset by one for every parameter
                        $$->mytype = $1;
                        $$->name = $2;
                        $$->value = 1; //just choose some value that isn't 0 to differentiate the type of declaration in the print routine
                    }
                ;
                
/*compound-stmt -> begin local-declarations statement-list end*/
/*create a BLOCK node that is connected to local decs and stat list using s1 and 
s2 respectively. */
CMPD_STMT       :   BEG 
                    { 
                        level++; //increment level upon entering a compound statement
                    }
                    LOCAL_DECS STAT_LIST END
                    {
                        $$ = ASTCreateNode( BLOCK );
                        $$->s1 = $3; //connect local decs to the block
                        $$->s2 = $4; //connect statements to the block
                        maxoffset = max( maxoffset, offset ); //set maxoffset at the end of each compoundstatment
                        Display(); //display as per the requirement
                        offset -= Delete( level ); //decrement offset by the number items that were declared in the function and remove those items from the symbol table
                        level--; //decrement level upon leaving a compound statement
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
                    
                |   WRITE STRING ';'
                    {
                        $$ = ASTCreateNode( WRITEST );
                        $$->name = Get_Global_Label(); //connect the expression to the write statement using s1
                        $$->s1 = ASTCreateNode( STR );
                        $$->s1->name = $2;
                    }
                ;
                
/*assignment-stmt -> var = expression-statement ;*/
ASSIGN_STMT     :   VAR '=' SIMP_EXPR ';'
                    {
                        //in assignment the type of the LHS must match that of the RHS. Verify that here.
                        if( $1->mytype == $3->mytype )
                        {
                            //if the var doesn't exist in the symbol table, it can't be used. Broadcast an error
                            if( Search( $1->name, level, 1 ) == NULL )
                            {
                                yyerror( "ERROR: VARIABLE DOES NOT EXIST" );
                                exit( 1 );
                            }
                            
                            else
                            {
                                $$ = ASTCreateNode( ASSIGNST );
                                $$->mytype = $1->mytype; //inherit the type
                                $$->s1 = $1; //connect the variable part of assignment using s1
                                $$->s2 = $3; //connect the expression part of the assignment using s2
                                $$->name = CreateTemp();
                                $$->symbol = Insert( $$->name, offset, level, 1, TYPE_SCALAR, NULL, $$->mytype );
                                offset++;
                            }
                        }
                        
                        else
                        {
                            yyerror( "INCOMPATIBLE TYPES IN THE ASSIGNMENT" );
                            exit( 1 );
                        }
                    }
                ;
                
/*expression -> simple-expression*/
EXPR            :   SIMP_EXPR 
                    { 
                        $$ = $1;
                    }
                ;
                
/*var -> ID [ [ expression ] ] */
VAR             :   ID
                    {
                        struct SymbTab *p;
                        
                        //if this variable exists at this level or below
                        if( (p=Search( $1, level, 1 )) != NULL )
                        {
                            $$ = ASTCreateNode( IDENT );
                            $$->name = $1;
                            $$->mytype = p->Type; //set the type
                            
                            //the entry in the symbol table must have been declared as a scalar to be used here. That is verified here.
                            if( p->IsAFunc == TYPE_SCALAR )
                                $$->symbol = p;
                                
                            else
                            {
                                yyerror( "ERROR: TYPE MISMATCH, IDENTIFIER IS NOT A SCALAR" );
                                exit( 1 );
                            }
                        }
                        
                        else
                        {
                            yyerror( "ERROR: VARIABLE HAS NOT BEEN DECLARED" );
                            exit( 1 );
                        }
                    }
                |   ID '[' EXPR ']'
                    {
                        struct SymbTab *p;
                        
                        //if the variable exists at this level or at any level below
                        if( (p = Search( $1, level, 1)) != NULL )
                        {
                            $$ = ASTCreateNode( IDENT );
                            $$->name = $1;
                            $$->value = 1; //set to a non-zero value for printing purposes
                            $$->s1 = $3;
                            $$->mytype = p->Type; //set the type
                            
                            //the entry in the symbol table must have been declared as an array to be used here. That is verified here.
                            if( p->IsAFunc == TYPE_ARRAY )
                                $$->symbol = p;
                                
                            else
                            {
                                yyerror( "ERROR: TYPE MISMATCH, IDENTIFIER IS NOT AN ARRAY" );
                                exit( 1 );
                            }
                        }
                        
                        else
                        {
                            yyerror( "ERROR: UNDECLARED VARIABLE" );
                            exit( 1 );
                        }

                    }
                ;
                
/*simple-expression -> additive-expression [ relop additive-expression ]*/
SIMP_EXPR       :   ADD_EXPR  
                    {
                        $$ = $1;
                    }
                |   SIMP_EXPR RELOP ADD_EXPR
                    {
                        //check if the type of the left operand matches that of the right operand
                        
                        //don't allow expressions with void
                        if( $1->mytype == VOIDTYPE || $3->mytype == VOIDTYPE )
                        {
                            yyerror( "CANNOT PERFORM OPERATIONS WITH VOID" );
                            exit( 0 );
                        }
                        
                        if( $1->mytype == $3->mytype )
                        {
                            $$ = ASTCreateNode( EXPRESS );
                            $$->mytype == $1->mytype; //inherit the type
                            $$->name = CreateTemp(); //create a name for the temporary variable
                            $$->symbol = Insert( $$->name, offset, level, 1, TYPE_SCALAR, NULL, $$->mytype ); //insert the temporary variable into the symbol table
                            offset++; //increment offset by one for the result of the expression
                            
                            if( debugsw )
                                    Display();
                                    
                            $$->operator = $2; //set the operator associated with the expression
                            $$->s1 = $1; //connect the left operand using s1
                            $$->s2 = $3; //connect the right operand using s2
                        }
                        
                        else
                        {
                            yyerror( "INCOMPATIBLE TYPES IN THE EXPRESSION" );
                            exit( 1 );
                        }
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
ADD_EXPR        :   TERM   
                    { 
                        $$ = $1;
                    }
                |   ADD_EXPR ADDOP TERM
                    {
                        //don't allow expressions with void
                        if( $1->mytype == VOIDTYPE || $3->mytype == VOIDTYPE )
                        {
                            yyerror( "CANNOT PERFORM OPERATIONS WITH VOID" );
                            exit( 0 );
                        }
                        
                        //check if the type of the left operand matches that of the right operand
                        if( $1->mytype == $3->mytype )
                        {
                            $$ = ASTCreateNode( EXPRESS );
                            $$->mytype = $1->mytype; //inherit the type
                            $$->name = CreateTemp(); //create a name for the temporary variable
                            $$->symbol = Insert( $$->name, offset, level, 1, TYPE_SCALAR, NULL, $$->mytype ); //insert the temporary variable into the symbol table
                            offset++; //increment offset by one for the result of the expression
                            
                            if( debugsw )
                                    Display();
                                    
                            $$->operator = $2; //set the addition operator associated with the expression
                            $$->s1 = $1; //connect the left operand using s1
                            $$->s2 = $3; //connect the right operand using s2
                        }
                        
                        else
                        {
                            yyerror( "INCOMPATIBLE TYPES IN THE EXPRESSION" );
                            exit( 1 );
                        }
                    }
                ;
                
/*addop -> + | -*/
/*assign ADDOP values based on the appropriate operators enum*/
ADDOP           :   '+'     { $$ = PLUS; }
                |   '-'     { $$ = MINUS; }
                ;
                
/*term -> factor { multop factor }*/
TERM            :   FACTOR 
                    { 
                        $$ = $1; 
                    }
                |   TERM MULTOP FACTOR
                    {
                        //don't allow expressions with void
                        if( $1->mytype == VOIDTYPE || $3->mytype == VOIDTYPE )
                        {
                            yyerror( "CANNOT PERFORM OPERATIONS WITH VOID" );
                            exit( 0 );
                        }
                        
                        //check if the type of the left operand matches that of the right operand
                        if( $1->mytype == $3->mytype )
                        {
                            $$ = ASTCreateNode( EXPRESS ); //for ease of implementation simply declare this sentence to be an expression - there's no use in differentating the types
                            $$->mytype = $1->mytype; //inherit the type
                            $$->name = CreateTemp(); //create a name for the temporary variable
                            $$->symbol = Insert( $$->name, offset, level, 1, TYPE_SCALAR, NULL, $$->mytype ); //insert the temporary variable into the symbol table
                            offset++; //increment offset by one for the result of the expression
                            
                            if( debugsw )
                                    Display();
                                    
                            $$->operator = $2; //store the operator
                            $$->s1 = $1; //s1 points to the left operand
                            $$->s2 = $3; //s2 points to the right operand
                        }
                        
                        else
                        {
                            yyerror( "INCOMPATIBLE TYPES IN THE EXPRESSION" );
                            exit( 1 );
                        }
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
                        $$->mytype = INTTYPE; //set the type
                        $$->value = $1; //assign the nodes value to be the number
                    }
                |   VAR     { $$ = $1; }
                |   CALL    { $$ = $1; }
                |   TRUE
                    {
                        /*true is equivalent to 1*/
                        $$ = ASTCreateNode( NUM );
                        $$->mytype = BOOLTYPE; //set the type to differentiate from the number 1
                        $$->value = 1;
                    }
                |   FALSE
                    {
                        /*false is equivalent to 0*/
                        $$ = ASTCreateNode( NUM );
                        $$->mytype = BOOLTYPE; //set the type to differentiate from the number 0
                        $$->value = 0;
                    }
                |   NOT FACTOR 
                    { 
                        if( $2->type == BOOLTYPE )
                        {
                            $$ = ASTCreateNode( EXPRESS ); 
                            $$->type = BOOLTYPE;
                            $$->operator = MYNOT; //assign the operator to be NOT
                            $$->s1 = $2; //have this expression node reference factor through s1
                        }
                        else
                        {
                            yyerror( "CANNOT USE NOT ON A NON-BOOLEAN VALUE" );
                            exit( 1 );
                        }
                    }
                ;
                
/*call -> ID ( args )*/
CALL            :   ID '(' ARGS ')'
                    {
                        struct SymbTab *p;
                        
                         //check if it exists in the symbol table
                        if( (p = Search( $1, 0, 0 )) != NULL )
                        {
                            //if the result of searching isn't a function, error
                            if( p->IsAFunc != TYPE_FUNCTION )
                            {
                                yyerror( $1 );
                                yyerror( "FUNCTION NAME NOT DEFINED" );
                                exit( 1 );
                            }
                            
                            //check if parameter lists are the same size and type
                            if( CompareParams( p->fparms, $3 ) != 1 )
                            {
                                yyerror( "PARAMETER TYPE OR LENGTH MISMATCH" );
                                exit( 1 );
                            }
                            
                            $$ = ASTCreateNode( CALLFUNC ); //create a call node
                            $$->name = $1; //set the name
                            $$->s1 = $3; //connect the argument list using s1
                            $$->mytype = p->Type;
                        }
                        else
                        {
                            yyerror( "CANNOT USE A FUNCTION THAT HASN'T BEEN DECLARED" );
                            exit( 1 );
                        }
                        
                    }
                ;
                
/*args -> arg-list | empty*/
ARGS            :   ARG_LIST  { $$ = $1; }
                |   /*EMPTY*/ { $$ = NULL; }
                ;
                
/*arg-list -> expression { , expression }*/
ARG_LIST        :   EXPR 
                    { 
                        $$ = ASTCreateNode( ARG ); //create an arg node
                        $$->s1 = $1; //connect the expression using s1
                        $$->mytype = $1->mytype;
                    }
                |   EXPR ',' ARG_LIST 
                    { 
                        $$ = ASTCreateNode( ARG ); //create an arg node
                        $$->s1 = $1; //connect the expression using s1
                        $$->next = $3; //connect multiple arguments using next 
                        $$->mytype = $1->mytype;
                    }
                ;
            

%%	/* end of rules, start of program */

/*returns the maximum of two digits*/
int max( int x, int y )
{
    if( x >= y )
        return x;
    else
        return y;
}

/*compares the length and type of two parameter lists, with the first list representing formal parameters and the second representing actual arguments*/
int CompareParams( ASTnode *formal, ASTnode *actual )
{
    //declare pointers to the heads of each list
    ASTnode *f = formal; 
    ASTnode *a = actual;
    
    //go through the parameter lists
    while( f != NULL && a != NULL )
    {
        //check the type of each node in the list and return 0 if there is no match
        if( f->mytype != a->mytype )
            return 0;
        
        //move to the next element in both lists
        f = f->next;
        a = a->next;
    }
    
    //both pointers have to be null in order to return true
    return ( f == NULL && a == NULL );
}


int main( int argc, char *argv [])
{ 
    int i;
    char filename[100]; //array to store the filename after concatenating the .asm extension
    FILE *fp = NULL; //will point to the file that is to be edited/created
    
    for( i = 0 ; i < argc ; i++ )
    {
        if( strcmp( argv[ i ],  "-d" ) == 0 ) //if "-d" is an argument
        {
            debugsw = 1; //toggle the debug variable
        }
        
        if( strcmp( argv[ i ],  "-o" ) == 0 )
        {
            strcpy( filename, argv[ i + 1 ] );
            strcat( filename, ".asm" ); //concatenate the .asm extension
            
            if( debugsw )
                printf( "The created filename is %s\n", filename );
                
            fp = fopen( filename, "w" ); //create an empty file for writing the machine instructions or open an existing one - if null is returned fopen failed
            
            if( fp == NULL ) //check if opening the file was successful
            {
                fprintf( stderr, "Cannot open %s\n", filename );
            }
        }
    }
    
    yyparse();
    
    if( fp != NULL )
    {
        Emit_Program( fp, myprogram );
    }
    
    else
    {
        printf( "No output file specified. No action\n" );
    }
    
    fclose( fp );
        /*yyparse will return 0 if no syntax errors and the whole program was parsed. In this case, print a success message*/
//     if( yyparse() == 0 )
//     {
//         //printf( "The program is syntactically correct.\n" );
//         //ASTprint( 0, myprogram );
//         printf( "Main Symbol Table Start: \n" );
//         Display(); //print global variables after parsing
//     }
}

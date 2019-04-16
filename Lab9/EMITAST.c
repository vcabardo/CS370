#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "EMITAST.h"

#define WORD_SIZE 8
int labelNum = 0;
void Emit_Program( FILE *fp, ASTnode *p )
{
        fprintf( fp, "%%include \"io64.inc\"\n\n" );
        Emit_Global( fp, p );
        
        fprintf( fp, "section .data\n\n" );
        Emit_Global_Strings( fp, p );
        
        fprintf( fp, "section .text\n" );
        
        fprintf( fp, "\tglobal main\n\n\n" );
        Emit_AST( fp, p );
}

void Emit_AST( FILE *fp, ASTnode *p )
{
    if( p == NULL ) return;
    
    else
    {
       switch (p->type) 
       {
           case VARDEC:
//                 printf( "Variable " ); //broadcast that a variable has been found
//                 
//                 /*print the type of the variable declaration*/
//                 printType( p->mytype );
//                 
//                 printf( "%s  ", p->name ); //print the name
// 
//                 if( p->value > 0 ) //only print brackets if the variable is an array, which is the case when value is greater than 0
//                     printf( "[ %d ]", p->value );
//                 
//                 printf( "\n" );
// 
//                 ASTprint( level, p->s1 ); //if multiple vardecs are strung together, print those as well
                break;

        /*when printing a function print the type, the name, the parameters, and the function's associated block statement*/
	   case FUNDEC:
//                 /*print the type of the function*/
//                 printType( p->mytype );
//                
//                 /*broadcast that a function node has been found and print the name */
//                 printf( "FUNCTION %s \n( \n", p->name );
//                 
//                 ASTprint( level + 1, p->s1 ); //print the parameters to the function
//                 
//                 printf( ")\n" );
//                 
//                 ASTprint( level + 1, p->s2 ); //print the block statement
//                 
//                 printf( "\n" );
                Emit_Function( fp, p );
                
                break; 
           
        /*when printing a parameter print the type, the name( if applicable ), and brackets if the parameter is an array*/
       case PARAM:
//                 /*if no name was assigned, it is a void parameter, print only void and move on*/
//                 if( p->mytype == VOIDTYPE && p->name == NULL )
//                    printf( "VOID \n" );
//                 
//                 else
//                 {
//                     /*if not void then it is a parameter list - print the type*/
//                     printType( p->mytype );
//                     
//                     /*print the name*/
//                     printf( "%s", p->name );
//                     
//                     /*a value greater than zero indicates that the parameter is an array*/
//                     if( p->value > 0 )
//                         printf( "[]" );
//                     
//                     printf( "\n" );
//                     
//                     ASTprint( level, p->s1 ); //if there are multiple parameters, print those as well
//                 }
//                 
                break;
                
       case BLOCK:
//                 printf( "BLOCK STATEMENT\n");
//                 ASTprint( level + 1, p->s1 );//print localdecs
//                 ASTprint( level + 1, p->s2 );//print statlist  
//                 
                break;
                
       case EXPRESS:
//                 printf( "EXPR" ); //broadcast that an expression node was found
//                 
//                 /*switch statement to handle all of the possible operators that an expression can contain*/
//                 switch( p->operator )
//                 {
//                     case PLUS:
//                         printf( " + " );
//                         break;
//                         
//                     case MINUS:
//                         printf( " - " );
//                         break;
//                         
//                     case MULTIPLY:
//                         printf( " * " );
//                         break;
//                         
//                     case DIVIDE:
//                         printf( " / " );
//                         break;
//                         
//                     case LTEQ:
//                         printf( " <= " );
//                         break;
//                         
//                     case LT:
//                         printf( " < " );
//                         break;
//                         
//                     case GT:
//                         printf( " > " );
//                         break;
//                         
//                     case GTEQ:
//                         printf( " >= " );
//                         break;
//                         
//                     case EQ:
//                         printf( " == " );
//                         break;
//                         
//                     case NEQ:
//                         printf( " != " );
//                         break;
//                         
//                     case ANDOP:
//                         printf( " AND " );
//                         break;
//                         
//                     case OROP:
//                         printf( " OR " );
//                         break;
//                 }
//                 
//                 printf( "\n" );
//                 
//                 ASTprint( level + 1, p->s1 ); //print the left operand
//                 if (p->operator != MYNOT)
//                     ASTprint(level+1, p->s2); //print the right operand
//                 
                break;
                
       case EXPRESSSTMT:
//                 printf( "EXPRESSION STATEMENT\n" );
//                 if( p->s1 == NULL )
//                 {
//                     PT( level );
//                     printf( " Empty Expression\n" );
//                 }
//                 else    
//                     ASTprint( level + 1, p->s1 ); //print the expression referred to by the expression statement 
                break;
                
       case NUM:
//                 printf( "NUMBER with value %d\n", p->value ); //print the value of the number
                break;
                
       case READST:
//                 printf( "READ STATEMENT\n" );
//                 ASTprint( level + 1, p->s1 ); //print the identifier
                break;
                
       case WRITEST:
//                 printf( "WRITE STATEMENT\n" );
//                 ASTprint( level + 1, p->s1 ); //print the expression
                if( p->s1->type == STR )
                {
//                     char temp [100];
//                     sprintf( temp, "PRINT_STRING %s", p->name );
//                     emit( fp, "", temp, ";print a string" );
                }
                break;
                
       case ASSIGNST:
//                 printf( "ASSIGNMENT statement\n" );
//                 ASTprint( level + 1, p->s1 ); //print the variable 
//                 ASTprint( level + 1, p->s2 ); //print the expression being assigned to the variable
                break;
                
       case ARG:
//                 printf( "ARG \n" );
//                 ASTprint( level, p->s1 ); //print the contents of the argument - the expression
                break;
                        
                
       case IDENT:
//                 printf( "IDENTIFIER %s\n", p->name ); //broadcast that an identifier was found
//                 
//                 if( p->value > 0 ) //handles the case of the parameter being an array
//                 {
//                     PT( level );
//                     printf( "Array Reference [\n" );
//                     ASTprint( level + 1, p->s1 ); //print the expression within the brackets of the array idtentifier
//                     PT( level );
//                     printf( "] end array \n" );
//                 }
//                 
                break;
           
       case RET:
//                 PT( level );
//                 printf( "RETURN STATEMENT\n" ); //broadcast that a return node was found
//                 ASTprint( level, p->s1 ); //if an expression is being returned, print that 
                break;
                
       case CALLFUNC:
//                 printf( "FUNCTION CALL %s\n", p->name ); //broadcast that a function call node was found
//                 ASTprint( level + 1, p->s1 ); //print the arguments to the call
//                 printf( "\n" );
                break;
                
       case WHILEST:
//                 printf( "WHILE STATEMENT\n" ); //broadcast that a while node was found
//                 ASTprint( level + 1, p->s1 ); //print the conditional 
//                 ASTprint( level + 2, p->s2 ); //print the statements in the body
                break;
                
       case IFTHEN:
//                 printf( "IF \n" );
//                 ASTprint( level + 1, p->s1 ); //print the expression
//                 printf( "\n" );
//                 PT(level);
//                 printf( "THEN \n" );
//                 ASTprint( level, p->s2 ); //print the then (and the else if applicable)
                
                break;
                
       case ELSEST:
//                 ASTprint( level , p->s1 ); //print the then statement
//                 PT(level);
//                 printf( "ELSE\n" );
//                 ASTprint( level + 1, p->s2 ); //print the else statement
//                 printf( "\n" );
                break;
                
        default: printf("unknown type in ASTprint\n");
        
       }
       
       Emit_AST(fp, p->next); //print all statements connected using next
    }
}

void Emit_Global( FILE *fp, ASTnode *p )
{
        if( p == NULL ) return; //if null take no action - exit out of the method
        
        if( p->type == VARDEC ) 
        {
            fprintf( fp, "common\t%s\t%d\t;define a global variable\n", p->name, ( p->value * WORD_SIZE ) ); //write the string to the file pointed to by the first parameter - use value to get a size
            
            Emit_Global( fp, p->s1 ); //recursive call on s1 only to retrieve connected vardecs because we already know that s2 is null
        }
        
        Emit_Global( fp, p->next ); //multiple global vardecs will be connected with next
}

void Emit_Global_Strings( FILE *fp, ASTnode *p )
{
    if( p == NULL ) return;
    
    //write the global string to the file
    if( p->type == WRITEST && p->name != NULL )
    {
        fprintf( fp, "%s: db  %s, 0\n", p->name, p->s1->name );
    }
    
    //look through the entire tree for write statements, which will be the only places where string will be used
    Emit_Global_Strings( fp, p->s1 );
    Emit_Global_Strings( fp, p->s2 );
    Emit_Global_Strings( fp, p->next );
}

//generate a unique label for each string
char * Get_Global_Label()
{
    char hold[100];
    char *s;
    sprintf(hold,"_L%d",labelNum++);
    s=strdup(hold);
    return (s);
}

void Emit_Function( FILE *fp, ASTnode *p )
{
    char temp [100];
    sprintf( temp, "%s:", p->name );
    emit( fp, temp, "", ";Start of function" );
    
    if( strcmp( p->name, "main" ) == 0 )
        emit( fp, "", "mov      rbp, rsp", ";SPECIAL RSP to RSB for MAIN only" );
    
    emit( fp, "", "mov      r8, rsp", ";FUNC header RSP has to be at most RBP" );
    
    sprintf( temp, "add      r8, -%d", ( p->symbol->mysize * WORD_SIZE ) );
    emit( fp, "", temp, ";adjust Stack Pointer for Activation Record" );
    
    emit( fp, "", "mov      [r8], rbp", ";FUNC header store old BP" );
    
    sprintf( temp, "mov      [r8+%d], rsp", WORD_SIZE );
    emit( fp, "", temp, ";FUNC header store old SP" );
    
    emit( fp, "", "mov      rsp, r8", ";FUNC header new SP" );
    emit( fp, "", "", "" ); //blank line
    
    //body of function
    
    emit( fp, "", "mov      rbp, [rsp]", ";FUNC end restore old BP" );
    
    sprintf( temp, "mov      rsp, [rsp + %d]", WORD_SIZE );
    emit( fp, "", temp, ";FUNC end restore old SP" );
    
    if( strcmp( p->name, "main" ) == 0 )
        emit( fp, "", "mov      rsp, rbp", ";Stack and BP need to be same on exit for main" );
    
    emit( fp, "", "xor      rax, rax", ";no value specified, then in is 0" );
    emit( fp, "", "ret", "" );
}

void emit( FILE *fp, char* label, char *command, char *comment )
{
    fprintf( fp, "%s\t%s\t%s\t\n", label, command, comment );
}

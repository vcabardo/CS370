/*Name: Vensan Cabardo
  Date: 4/9/2019
  Course: CS370 Compilers 
  Description/Purpose: AST implementation that contains a method for creating nodes and a print routine for seeing the contents of the tree. The purpose of creating an AST as the text file is being parsed is so that we can create an immediate representation that will eventually be used to translate the original program into machine code. 
*/

#include<stdio.h>
#include<malloc.h>
#include "ast.h" 


/* uses malloc to create an ASTnode and passes back the heap address of the newley created node. The payload of the struct will be filled with garbage when the memory is allocated, so assign default values.*/
ASTnode *ASTCreateNode(enum ASTtype mytype)
{
    ASTnode *p;
    if (mydebug) fprintf(stderr,"Creating AST Node \n");
    p=(ASTnode *)malloc(sizeof(ASTnode));
    p->type = mytype; //corresponds to int, void, or boolean for this language
    p->name = NULL; 
    p->value = 1; //if the node being declared is an id or vardec with an array, use this field to store size
    p->next = NULL;
    p->s1=NULL;
    p->s2=NULL;
    return(p);
}

/*  Helper function to print tabbing - prints a number of spaces equal to the parameter*/
void PT(int howmany)
{
	 int i;
     for( i = 0 ; i < howmany ; i++ )
            printf( "  " );
}

void printType( enum SYSTEMTYPES type )
{
    if( type == INTTYPE )
        printf( "INT " );
    
    if( type == VOIDTYPE )
        printf( "VOID " );
    
    if( type == BOOLTYPE )
        printf( "BOOLEAN " );
}

/*  Print out the abstract syntax tree */
void ASTprint(int level,ASTnode *p)
{
   int i;
   if (p == NULL ) return;
   else
     { 
       PT(level); /*indent */
       switch (p->type) 
       {
           case VARDEC:
                printf( "Variable " ); //broadcast that a variable has been found
                
                /*print the type of the variable declaration*/
                printType( p->mytype );
                
                printf( "%s  ", p->name ); //print the name

                if( p->value > 0 ) //only print brackets if the variable is an array, which is the case when value is greater than 0
                    printf( "[ %d ]", p->value );
                
                printf( "\n" );

                ASTprint( level, p->s1 ); //if multiple vardecs are strung together, print those as well
                break;

        /*when printing a function print the type, the name, the parameters, and the function's associated block statement*/
	   case FUNDEC:
                /*print the type of the function*/
                printType( p->mytype );
               
                /*broadcast that a function node has been found and print the name */
                printf( "FUNCTION %s \n( \n", p->name );
                
                ASTprint( level + 1, p->s1 ); //print the parameters to the function
                
                printf( ")\n" );
                
                ASTprint( level + 1, p->s2 ); //print the block statement
                
                printf( "\n" );
                
                break; 
           
        /*when printing a parameter print the type, the name( if applicable ), and brackets if the parameter is an array*/
       case PARAM:
                /*if no name was assigned, it is a void parameter, print only void and move on*/
                if( p->mytype == VOIDTYPE && p->name == NULL )
                   printf( "VOID \n" );
                
                else
                {
                    /*if not void then it is a parameter list - print the type*/
                    printType( p->mytype );
                    
                    /*print the name*/
                    printf( "%s", p->name );
                    
                    /*a value greater than zero indicates that the parameter is an array*/
                    if( p->value > 0 )
                        printf( "[]" );
                    
                    printf( "\n" );
                    
                    ASTprint( level, p->s1 ); //if there are multiple parameters, print those as well
                }
                
                break;
                
       case BLOCK:
                printf( "BLOCK STATEMENT\n");
                ASTprint( level + 1, p->s1 );//print localdecs
                ASTprint( level + 1, p->s2 );//print statlist  
                
                break;
                
       case EXPRESS:
                printf( "EXPR" ); //broadcast that an expression node was found
                
                /*switch statement to handle all of the possible operators that an expression can contain*/
                switch( p->operator )
                {
                    case PLUS:
                        printf( " + " );
                        break;
                        
                    case MINUS:
                        printf( " - " );
                        break;
                        
                    case MULTIPLY:
                        printf( " * " );
                        break;
                        
                    case DIVIDE:
                        printf( " / " );
                        break;
                        
                    case LTEQ:
                        printf( " <= " );
                        break;
                        
                    case LT:
                        printf( " < " );
                        break;
                        
                    case GT:
                        printf( " > " );
                        break;
                        
                    case GTEQ:
                        printf( " >= " );
                        break;
                        
                    case EQ:
                        printf( " == " );
                        break;
                        
                    case NEQ:
                        printf( " != " );
                        break;
                        
                    case ANDOP:
                        printf( " AND " );
                        break;
                        
                    case OROP:
                        printf( " OR " );
                        break;
                }
                
                printf( "\n" );
                
                ASTprint( level + 1, p->s1 ); //print the left operand
                if (p->operator != MYNOT)
                    ASTprint(level+1, p->s2); //print the right operand
                
                break;
                
       case EXPRESSSTMT:
                printf( "EXPRESSION STATEMENT\n" );
                if( p->s1 == NULL )
                {
                    PT( level );
                    printf( " Empty Expression\n" );
                }
                else    
                    ASTprint( level + 1, p->s1 ); //print the expression referred to by the expression statement 
                break;
                
       case NUM:
                printf( "NUMBER with value %d\n", p->value ); //print the value of the number
                break;
                
       case READST:
                printf( "READ STATEMENT\n" );
                ASTprint( level + 1, p->s1 ); //print the identifier
                break;
                
       case WRITEST:
                printf( "WRITE STATEMENT\n" );
                ASTprint( level + 1, p->s1 ); //print the expression
                break;
                
       case ASSIGNST:
                printf( "ASSIGNMENT statement\n" );
                ASTprint( level + 1, p->s1 ); //print the variable 
                ASTprint( level + 1, p->s2 ); //print the expression being assigned to the variable
                break;
                
       case ARG:
                printf( "ARG \n" );
                ASTprint( level, p->s1 ); //print the contents of the argument - the expression
                break;
                        
                
       case IDENT:
                printf( "IDENTIFIER %s\n", p->name ); //broadcast that an identifier was found
                
                if( p->value > 0 ) //handles the case of the parameter being an array
                {
                    PT( level );
                    printf( "Array Reference [\n" );
                    ASTprint( level + 1, p->s1 ); //print the expression within the brackets of the array idtentifier
                    PT( level );
                    printf( "] end array \n" );
                }
                
                break;
           
       case RET:
                PT( level );
                printf( "RETURN STATEMENT\n" ); //broadcast that a return node was found
                ASTprint( level, p->s1 ); //if an expression is being returned, print that 
                break;
                
       case CALLFUNC:
                printf( "FUNCTION CALL %s\n", p->name ); //broadcast that a function call node was found
                ASTprint( level + 1, p->s1 ); //print the arguments to the call
                printf( "\n" );
                break;
                
       case WHILEST:
                printf( "WHILE STATEMENT\n" ); //broadcast that a while node was found
                ASTprint( level + 1, p->s1 ); //print the conditional 
                ASTprint( level + 2, p->s2 ); //print the statements in the body
                break;
                
       case IFTHEN:
                printf( "IF \n" );
                ASTprint( level + 1, p->s1 ); //print the expression
                printf( "\n" );
                PT(level);
                printf( "THEN \n" );
                ASTprint( level, p->s2 ); //print the then (and the else if applicable)
                
                break;
                
       case ELSEST:
                ASTprint( level , p->s1 ); //print the then statement
                PT(level);
                printf( "ELSE\n" );
                ASTprint( level + 1, p->s2 ); //print the else statement
                printf( "\n" );
                break;
                
        default: printf("unknown type in ASTprint\n");
        
       }
       
       ASTprint(level, p->next); //print all statements connected using next
     }
}



/* dummy main program so I can compile for syntax error independently   
main()
{
}
/* */

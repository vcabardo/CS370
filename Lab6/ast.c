#include<stdio.h>
#include<malloc.h>
#include "ast.h" 


/* uses malloc to create an ASTnode and passes back the heap address of the newley created node. The payload of the struct will be filled with garbage when the memory is allocated, so assign default values.*/
ASTnode *ASTCreateNode(enum ASTtype mytype)
{
    ASTnode *p;
    if (mydebug) fprintf(stderr,"Creating AST Node \n");
    p=(ASTnode *)malloc(sizeof(ASTnode));
    p->type = mytype;
    p->name = NULL;
    p->value = 0;
    p->next = NULL;
    p->s1=NULL;
    p->s2=NULL;
    return(p);
}

/*  Helper function to print tabbing */

void PT(int howmany)
{
	 int i;
     for( i = 0 ; i < howmany ; i++ )
            printf( "\t" );
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
                printf( "Variable " );
                
                if( p->mytype == INTTYPE )
                    printf( "INT " );
                
                if( p->mytype == VOIDTYPE )
                    printf( "VOID " );
                
                if( p->mytype == BOOLTYPE )
                    printf( "BOOLEAN " );
                
                printf( "%s  ", p->name );

                if( p->value > 0 )
                    printf( "[ %d ]", p->value );
                
                printf( "\n" );

                ASTprint( level, p->s1 );
                break;

        /*when printing a function print the type, the name, the parameters, and the function's associated block statement*/
	   case FUNDEC:
                if( p->mytype == INTTYPE )
                   printf( "INT " );
               
                if( p->mytype == VOIDTYPE )
                   printf( "VOID " );
               
                if( p->mytype == BOOLTYPE )
                   printf( "BOOLEAN " );
               
                printf( "FUNCTION %s \n( \n", p->name );
                
                ASTprint( level + 1, p->s1 ); //print the parameters to the function
                
                printf( ")\n" );
                
                ASTprint( level + 1, p->s2 ); //print the block statement
                
                printf( "\n" );
                
                break; 
           
        /*when printing a parameter print the type, the name( if applicable ), and brackets if the parameter is an array*/
       case PARAM:
                if( p->mytype == VOIDTYPE && p->name == NULL )
                   printf( "VOID \n" );
                
                else
                {
                    if( p->mytype == INTTYPE )
                        printf( "PARAMETER INT " );
                    
                    if( p->mytype == VOIDTYPE )
                        printf( "PARAMETER VOID " );
                
                    if( p->mytype == BOOLTYPE )
                        printf( "PARAMETER BOOLEAN " );
                    
                    printf( "%s", p->name );
                    
                    if( p->value > 0 )
                        printf( "[]" );
                    
                    printf( "\n" );
                    
                    ASTprint( level, p->s1 ); //if there are multiple parameters, print those as well
                }
                
                break;
                
       case BLOCK:
                printf( "BLOCK STATEMENT\n");
                ASTprint( level, p->s1 );//print localdecs
                ASTprint( level, p->s2 );//print statlist
                break;
                
       case EXPRESS:
                printf( "EXPR " );
                ASTprint( level, p->s1 ); 
                break;
                
        case NUM:
                printf( "NUMBER with value %d", p->value );
                break;
                        
           
        default: printf("unknown type in ASTprint\n");
        
       }
       
       ASTprint(level, p->next);
     }

}



/* dummy main program so I can compile for syntax error independently   
main()
{
}
/* */

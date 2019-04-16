/*Name: Vensan Cabardo
  Date: 4/9/2019
  Course: CS370 Compilers 
  Description/Purpose: This header files contains the AST struct as well as enums that will be used as fields for the ASTNode struct. It also contains the prototypes for the methods implemented in the ast.c file, including a method for creating nodes and a print routine. 

*/

/*   Abstract syntax tree code


 Header file   
 Shaun Cooper January 2019

*/

#include<stdio.h>
#include<malloc.h>

#ifndef AST_H
#define AST_H
extern int mydebug;

/* define the enumerated types for the AST.  THis is used to tell us what 
sort of production rule we came across */

/*define all of the types of nodes*/
enum ASTtype {
    VARDEC,
    FUNDEC,
    PARAM,
    BLOCK,
    EXPRESS,
    NUM,
    READST,
    IDENT,
    RET,
    WRITEST,
    ASSIGNST,
    CALLFUNC,
    WHILEST,
    IFTHEN,
    ELSEST,
    MYNOT,
    ARG,
    EXPRESSSTMT,
    STR
};

/*define the relevant operators used by our language*/
enum OPERATORS {
    PLUS,
    MINUS,
    MULTIPLY,
    DIVIDE,
    ANDOP,
    OROP,
    LT,
    GT,
    LTEQ,
    GTEQ,
    EQ,
    NEQ,
    PARENTH
};

/*define the relevant types used in our language*/
enum SYSTEMTYPES {
    INTTYPE,
    VOIDTYPE,
    BOOLTYPE
};

/* define a type AST node which will hold pointers to AST structs that will
   allow us to represent the parsed code 
*/
typedef struct ASTnodetype
{
     enum ASTtype type;
     enum OPERATORS operator;
     enum SYSTEMTYPES mytype;
     struct SymbTab *symbol;
     char * name;
     int value;
     struct ASTnodetype *next; //
     struct ASTnodetype *s1,*s2 ; /* used for holding IF and WHILE components -- not very descriptive */
} ASTnode;

/* uses malloc to create an ASTnode and passes back the heap address of the newley created node */
ASTnode *ASTCreateNode(enum ASTtype mytype);

void PT(int howmany);

void printType( enum SYSTEMTYPES type );

void ASTattachnext(ASTnode *p,ASTnode *q);

ASTnode *program;

/*  Print out the abstract syntax tree */
void ASTprint(int level,ASTnode *p);

#endif // of AST_H

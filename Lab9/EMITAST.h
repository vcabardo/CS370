#include "ast.h"
#include "symtable.h"

#ifndef EMITAST_H
#define EMITAST_H
void Emit_Program( FILE *fp, ASTnode *p );
void Emit_Global( FILE *fp, ASTnode *p );
void Emit_Global_Strings( FILE *fp, ASTnode *p );
char * Get_Global_Label();
void Emit_Function( FILE *fp, ASTnode *p );
void Emit_Function_Start( FILE *fp );
void Emit_Function_End( FILE *fp );
void Emit_AST( FILE *fp, ASTnode *p );
void emit( FILE *fp, char* label, char *command, char *comment );
#endif

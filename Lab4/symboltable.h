#ifndef SYMTABLE_H
#define SYMTABLE_H

//Prototypes for the necessary functions in symboltable.c
void Insert( char *n, int off );
void Display();
int Search(char *n);

/*SymbTab is a linked list with two fields for name and for offset, and 
 *pointers to the next element in the list as well as pointers to the first and last elements in the list*/
struct SymbTab
{
    char *name;
    int offset;
    struct SymbTab *next;
};

#endif

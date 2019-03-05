/*Name: Vensan Cabardo
  Date: 2-16-2019
  Course: CS370 Compilers 
  Description: The following code provides the tools necessary to work with a symbol table,
  including insert, delete, display, search, and modify functionalities. 
  Obtained from http://forgetcode.com/C/101-Symbol-table
  Changes made: This code was altered from the original - comments were added explaining the operations of the program, and the code itself was formatted to increase readability
*/

#include<stdio.h>
/* #include<conio.h> */
#include<malloc.h>
#include<string.h>
#include<stdlib.h>
#include "symboltable.h"
int size=0;

struct SymbTab *first,*last;

/*
Description: This method inserts an entry into the symbol table, but only if that label doesn't already exist in the symbol table. Insertion is done as in a standard linked list, where the newest node is inserted at the tail of the list. 
Postcondition: If the user is attempting to insert a duplicate entry into the symbol table, they are notified that this action is not possble. Otherwise, a new node is inserted into the symbol table with a name and offset specified by the user.
*/
void Insert( char *varName, int off )
{
    int n;
    n=Search( varName ); //search the symbol table to see if the label already exists.
    
    //duplicates cannot exist in the symbol table. Print a message and perform no further actions
    if(n != -1)
        printf("\n\tThe label exists already in the symbol table\n\tDuplicate can't be inserted");
    
    else
    {
        //Create a SymbTab pointer - this will serve as a pointer to the current element. 
        struct SymbTab *p;
        
        p=malloc(sizeof(struct SymbTab));
        p->name = varName;//the new node's label field s set to be the user input
        p->offset = off;
        
        /*the mark of the last node in a linked list is that its pointer to the next node is NULL. Since insertion in this case is occuring at the end, set the current nodes pointer to null to prepare it to be inserted.*/
        p->next=NULL;  

        //if size is 0, the node that is being created is the first element in the list and is thus the first and last element at this stage.
        if(size==0)
        {
            first=p;
            last=p;
        }
        
        //if the size is greater than 0, insert the new node at the tail of the list and update the pointer for last to be the new node. 
        else
        {
            last->next=p;
            last=p;
        }
        
        size++;
    }       

    printf("\n\tLabel inserted\n");
}

/*
    Description: This function traverses all of the elements in the symbol table ad prints out the fields of each node. 
    Postcondition: The label, symbol, and address of all of the existing entries in the symbol table are printed for the user to see
    */
void Display()
{
    int i; 
    struct SymbTab *p; //Start searching the symbol table starting at the first node
    p=first;
    printf("\n\tNAME\t\tOFFSET\n");
    //print the label, symbol, and address of the current node. Repeat for every node
    for(i=0;i<size;i++)
    {
        printf("\t%s\t\t%d\n",p->name,p->offset);
        p=p->next;
    }
}

    /*
    Description: This function tranverses the entirety of the Symbol Table
    Postcondition: 1 or 0 is returned based on whether the label in the parameter exists in the symbol table
    */
int Search( char *varName )
{
    int i,flag=-1;
    struct SymbTab *p;
    p=first; //start looking at the list from the beginning
    
    for(i=0;i<size;i++)
    {
        if(strcmp(p->name,varName)==0) //if strcmp is 0 the strings are the same
        flag=p->offset; 
        p=p->next; //move on to the next element in the list
    }
    
    return flag; //flag will contain a -1 if varName isn't in the symbol table, and the offset if it is 
}

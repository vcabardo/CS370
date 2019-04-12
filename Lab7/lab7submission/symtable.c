/*Name: Vensan Cabardo
  Date:4/9/2019
  Course: CS370 Compilers 
  Description:  Contains the methods associated with maintaining the symbol table for a program. This includes methods for insertion, deletion, and searching. It also includes methods for creating temporary variable names, and displaying the contents of the symbol table
  Input: Calls to the symbol table functions in YACC
  Output: The symbol table is maintained through these functions. That is, things are added to and removed from the symbol table appropriately
*/

/*  Symbol Table --linked list
    Used for Compilers class

    Modified Spring 2015 to allow for name to pointed to by symtable, instead of copied, since the name is copied
    into the heap

    Modified to have levels.  A level 0 means global variable, other levels means in range of the function.  We
    start out our offsets at 0 (from stack pointer) for level 1,,,when we enter a functional declaration.
    We increment offset each time we insert a new variable.  A variable is considered to be valid if it is found in
    the symbol table at our level or lesser level.  If at 0, then it is global.  

    We return a pointer to the symbol table when a variable matches our creteria.

    We add a routine to remove variables at our level and above.
*/

#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <string.h>
#include "symtable.h"

int GTEMP = 0;

struct SymbTab * first;

char * CreateTemp()
{    char hold[100];
     char *s;
     sprintf(hold,"_T%d",GTEMP++);
     s=strdup(hold);
     return (s);
}

/* Simple Insert into the symbol table with the size, type level that the name is being inserted into */

struct SymbTab * Insert(char *name, int offset, int level, int mysize, int IsAFunc, ASTnode *fparms, enum SYSTEMTYPES Type)
{
    struct SymbTab * n;
    n=Search(name, level, 0);
    if(n!=NULL) //verify that the identifier has not already been declared
    {
        printf("\n\tThe name %s exists at level %d already in the symbol table\n\tDuplicate can't be inserted", name, 0);
        return (NULL);
    }
    else
    {
        //set the values of the payload
        struct SymbTab *p;
        p = malloc(sizeof(struct SymbTab));
        p->name = name;
        p->offset = offset;
        p->level = level;
        p->mysize = mysize;
        p->IsAFunc = IsAFunc;
        p->fparms = fparms;
        p->Type = Type;

    /* Check on how many elements we have in the symbol table */
        if(first==NULL) //if the table is empty
        {
            first=p;
        }
        //if the table is not empty, insert at the head of the linked list
        else
        {
            p->next=first;
            first=p;
        }
        return (p);
    }
     
  printf("\n\tLabel inserted\n");
}

/* print out a single symbol table entry -- for debugging */
void PrintSym(struct SymbTab *s)
{
    printf("\t%s\t\t%d\t\t%d\n",s->name,s->offset, s->level);
}

/*  General display to see what is our symbol table */

void Display()
{
    int i;
    struct SymbTab *p;
    p=first;
    printf("\n\tLABEL\t\tOFFSET\t\tLEVEL\n");
    //call PrintSym on every element in the linked list
    while (p!=NULL)
    {
        PrintSym(p);
        p=p->next;
    }
}

/*  Search for a symbol name at level or below.  We have to do multiple passes into the symbol table because we have to find
   the name closest to us 


  If recur is non-zero, then we look through all of the levels, otherwise, only our level 
   We return a pointer to a SymbolTab structure so that we can use other functions/methods to get the attributes */

struct SymbTab * Search(char name[], int level, int recur)
{
   int i,flag=0;
   struct SymbTab *p;
   
   while( level >= 0 )
   {
        p=first; //start at the first node
        while (p!=NULL)
        {
                if((strcmp(p->name,name) == 0) && (p->level == level) ) //compare name AND level - if they match, return
                    return p;
                p=p->next; //move on in the list
        }
        
        if( recur == 0 ) //if the entire level was checked and the user does not want to move on - return null
            return NULL;
        
        level--; //look one level down
   }
 
   return  NULL;  /* did not find it, return 0 */
}

/* Remove all enteries that have the indicated level
   We need to take care about updating first pointer into the linked list when we are deleting edge elements */


int Delete(int level)
{
    struct SymbTab *p,*f=NULL;  /* we follow with pointer f */
    int SIZE=0;
    p=first;
    
  /* cruise through the list */

    while (p != NULL)
      {
        /* do we match? */
        if (p->level>= level )
        { /* if it is the first in the list we have to update first, we know this by f being NULL */
            SIZE+=p->mysize;
            if ( f==NULL) first=p->next;
            else /* not the first element */
            {
                f->next=p->next;
            }
            p=p->next;
        }
        else
        {
            /* update follow pointer, move the p pointer */
            f=p;
            p=p->next;
        }
      }
    return(SIZE);
}


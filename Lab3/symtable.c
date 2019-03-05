/*Name: Vensan Cabardo
  Date: 
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
int size=0;
void Insert();
void Display();
void Delete();
int Search(char lab[]);
void Modify();

/*The symbol table is being represented using a linked list, where each node has three fields: label, symbol, and address*/
struct SymbTab
{
    char label[10],symbol[10];
    int addr;
    struct SymbTab *next;
    struct SymbTab *first,*last;
};

struct SymbTab *first,*last;

void main()
{
    int op,y;//op stores the user input for action, and y stores the result of searching - whether or not something exists in the symbol table
    char la[10];
    
    /*The following is a sentinel loop allowing for the user to easily input what they would like to do with the symbol table.*/
    do
    {
        printf("\n\tSYMBOL TABLE IMPLEMENTATION\n");
        printf("\n\t1.INSERT\n\t2.DISPLAY\n\t3.DELETE\n\t4.SEARCH\n\t5.MODIFY\n\t6.END\n");
        printf("\n\tEnter your option : ");
        scanf("%d",&op);
        
        switch(op)
        {
            case 1:
                Insert();
                break;
            case 2:
                Display();
                break;
            case 3:
                Delete();
                break;
            case 4:
                printf("\n\tEnter the label to be searched : ");
                scanf("%s",la);
                y=Search(la);
                printf("\n\tSearch Result:");
                if(y==1)
                    printf("\n\tThe label is present in the symbol table\n");
                else
                    printf("\n\tThe label is not present in the symbol table\n");
                break;
            case 5:
                Modify();
                break;
            case 6:
                exit(0);
        }
    }while(op<6);

}  /* end of main */    

/*
    Description: This method inserts an entry into the symbol table, but only if that label doesn't already exist in the symbol table. Insertion is done as in a standard linked list, where the newest node is inserted at the tail of the list. 
    Postcondition: If the user is attempting to insert a duplicate entry into the symbol table, they are notified that this action is not possble. Otherwise, a new node is inserted into the symbol table with a label, symbol, and address inputted by the user.
    */
void Insert()
{
    int n;
    char l[10];
    printf("\n\tEnter the label : ");
    scanf("%s",l);
    n=Search(l); //search the symbol table to see if the label already exists.
    
    //duplicates cannot exist in the symbol table. Print a message and perform no further actions
    if(n==1)
        printf("\n\tThe label exists already in the symbol table\n\tDuplicate can't be inserted");
    
    else
    {
        //Create a SymbTab pointer - this will serve as a pointer to the current element. 
        struct SymbTab *p;
        
        p=malloc(sizeof(struct SymbTab));
        strcpy(p->label,l);//the new node's label field s set to be the user input
        
        //prompt the user to enter the values that will be inserted into the new node's symbol and address fields.
        printf("\n\tEnter the symbol : ");
        scanf("%s",p->symbol);
        printf("\n\tEnter the address : ");
        scanf("%d",&p->addr);
        
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
    printf("\n\tLABEL\t\tSYMBOL\t\tADDRESS\n");
    //print the label, symbol, and address of the current node. Repeat for every node
    for(i=0;i<size;i++)
    {
        printf("\t%s\t\t%s\t\t%d\n",p->label,p->symbol,p->addr);
        p=p->next;
    }
}

    /*
    Description: This function tranverses the entirety of the Symbol Table
    Postcondition: 1 or 0 is returned based on whether the label in the parameter exists in the symbol table
    */
int Search(char lab[])
{
    int i,flag=0;
    struct SymbTab *p;
    p=first; //start looking at the list from the beginning
    for(i=0;i<size;i++)
    {
        if(strcmp(p->label,lab)==0) //if strcmp is 0 the strings are the same
        flag=1; 
        p=p->next; //move on to the next element in the list
    }
    return flag;
}

    /*
    Description: This function allows you to modify the label or the address field of a specific entry in the symbol table
    Postcondition: The fields that the user chooses to modify are changed according to new input
    */
void Modify()
{
    char l[10],nl[10];
    int add,choice,i,s;
    struct SymbTab *p;
    p=first;
    printf("\n\tWhat do you want to modify?\n");
    printf("\n\t1.Only the label\n\t2.Only the address\n\t3.Both the label and address\n");
    printf("\tEnter your choice : ");
    scanf("%d",&choice);
    switch(choice)
    {
        /*Modify only the label by finding the label that is to be changed, and changing that nodes label field*/
        case 1:
            printf("\n\tEnter the old label : ");
            scanf("%s",l);
            s=Search(l); // check if the label exists
            
            //if the label does not exist
            if(s==0)
                printf("\n\tLabel not found\n");
            
            //if the label does exist
            else
            {
                printf("\n\tEnter the new label : ");
                scanf("%s",nl);
                for(i=0;i<size;i++) //search the symbol table for the label
                {
                    if(strcmp(p->label,l)==0) //once the entry is found
                    strcpy(p->label,nl); //change the label field to be the user input
                    p=p->next;
                }
                printf("\n\tAfter Modification:\n");
                Display(); //display results of modification
            }
            break;
            
        /*Modify only the address by finding the label that is to be changed, 
            *and changing that nodes address field*/
        case 2:
            printf("\n\tEnter the label where the address is to be modified : ");
            scanf("%s",l);
            s=Search(l);
            if(s==0)
                printf("\n\tLabel not found\n");
            else
            {
                printf("\n\tEnter the new address : ");
                scanf("%d",&add);
                for(i=0;i<size;i++) //search the symbol table for the address
                {
                    if(strcmp(p->label,l)==0) //once the entry is found
                    p->addr=add; //change the address field to be the user input
                    p=p->next;
                }
                printf("\n\tAfter Modification:\n");
                Display(); //display results of modification
            }
            break;
            
        /*Modify both the label and the address by finding the label and address that is 
            *to be changed, and changing that nodes label and address fields*/
        case 3:
            printf("\n\tEnter the old label : ");
            scanf("%s",l);
            s=Search(l);
            if(s==0)
                printf("\n\tLabel not found\n");
            else
            {
                printf("\n\tEnter the new label : ");
                scanf("%s",nl);
                printf("\n\tEnter the new address : ");
                scanf("%d",&add);
                for(i=0;i<size;i++) //search through the entire list
                {
                    if(strcmp(p->label,l)==0) //find the entry with the label the user entered
                    {
                        //change the label and address
                        strcpy(p->label,nl);
                        p->addr=add;
                    }
                    p=p->next;
                }
                printf("\n\tAfter Modification:\n");
                Display(); //display results of modification
            }
            break;
    }
}

/*
    Description: This function deletes an entry in the symbol table based on four conditions:
    if the node exists, if the node is first in the symbol table, if it is the last in the table, and 
    if it is somewhere in the middle. 
    Postcondition: The new symbol table with the entry deleted is displayed onto the screen. 
    */
void Delete()
{
    int a;
    char l[10];
    struct SymbTab *p,*q;
    p=first;
    printf("\n\tEnter the label to be deleted : ");
    scanf("%s",l);
    a=Search(l);
    
    //first case: label is not in symbol table
    if(a==0)
        printf("\n\tLabel not found\n");
    else
    {
        //second case: node is first in list
        if(strcmp(first->label,l)==0)
            first=first->next;
        
        //third case: node is last in list
        else if(strcmp(last->label,l)==0)
        {
            q=p->next;
            // go through the list until the last element, keeping a pointer to the previous
            while(strcmp(q->label,l)!=0) 
            {
                p=p->next;
                q=q->next;
            }
            p->next=NULL;
            last=p;
        }
        
        //fourth case: node is somewhere in the middle
        else
        {
            q=p->next;
             // go through the list until the label is found, keeping a pointer to the previous
            while(strcmp(q->label,l)!=0)
            {
                p=p->next;
                q=q->next;
            }
            p->next=q->next;
        }
        size--;
        printf("\n\tAfter Deletion:\n");
        Display();
    }
}

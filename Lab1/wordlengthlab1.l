  /*
    Name: Vensan Cabardo
    Date: 1/18/2019
    Course: CS370 Compilers 
    Description: This program will take a text file as input and print a frequency count of the number of words of a certain length in the file and the number of numbers in the file.
    Input: A text file
    Output: The frequency of the length of words in the text file and a count of the number of numbers in the file is printed 
  */
  /*  This lex routine uses a counting array to match alphabeticstrings 
         and make a frequency count.
  
         The real item to notice is that yywrap() is called at EOF and then is run
         to do what we need to do.   yywrap() returns true when we have a successful 
         end to the program.  We may want to return false (0) if we want to lexing process 
         to fail 

        Shaun Cooper
        January 2015
   */
	int lgths[100]; //This array is used to store the frequency count of the words and their lengths
	int numbers = 0; //This variable is used to store the count of the numbers in the file
%%
[a-zA-Z]+	{ lgths[yyleng]++; //everytime a word is encountered, increment the value in the array
            }
[0-9]+      { 
                numbers++; // every time a number is encountered, increment the numbers variable
            } 
.	|
\n	;
%%
yywrap()
{
    //the following prints the contents of the array so the user can see the frequency counts
	int i;
	printf("Length  No. words\n");
	for (i=1; i<100; i++) 
	{
		if (lgths[i] > 0) 
        {
			printf( "%5d%10d\n",i,lgths[i] );
		}
	}
	
	/*Every time a number is encountered, the numbers variable is incremented. That value is printed here for the user to see
	*/
	printf( "The number of numbers is: " );
	printf( "%d\n", numbers );
	
	return(1);
}

main()
{  
    yylex();
}

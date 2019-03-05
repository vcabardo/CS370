/*
Name: Vensan Cabardo
Date: 1/24/2018
Course: CS370 Compilers
Description: The following program removes the comments from a text file. 
If there are errors in the form of nested comments, it will print the line number
of the possible error.
Input: A text file
Output: The text file is printed with comments removed and possible errors printed 
along with the line numbers that they are on/*
Name: Vensan Cabardo
Date: 1/24/2018
Course: CS370 Compilers
Description: The following program removes the comments from a text file.
If there are errors in the form of nested comments, it will print the line number
of the possible error.
Input: A text file
Output: The text file is printed with comments removed and possible errors printed
along with the line numbers that they are on

*/

         /* simple lex program which removes comments from a source program

            The main key is that a variable "comment" is set when the start of a comment
            is seen and then unset when the ending set is seen.  It is possible to have
            two starts closed by on end.

            Shaun Cooper
            January 2015
 
         */
        int comment = 0;
	/*The following variable was changed to be initialized to 1 instead of 0 so that 
	  the program can check for nested comments immediately*/
        int debug = 1;  /* prints out debug statements if desired */
        int numLines = 1; //changed numLines from 0 to 1
%% 
	/*This directive was added so that everytime a new line is encountered, 
	  the counter variable is incremented. Additionally, new lines shouldn't be removed from the 
	  program, so this directive prints them.*/
\n	{
	  numLines++;
	  printf( "\n" );
	}

"/*"	{
	/*The following if statement was altered by adding the final parameter so that the 
	  line number of where the nested comment was found could be added.
	*/
	if (comment && debug) fprintf(stderr,
		" >>>>>>>> line %d: Possible Nested comment <<<<<<<<<<\n", numLines);
	comment = 1;
	}

"*/"	{
          if (!comment) printf("%s",yytext); /*print out if it is not in a comment */
	  /*When the closing comment characters are encountered, what follows is not a comment
	    unless the opening comment characters are encountered, so comment is set to 0.*/
  	  comment = 0;
	}

.       { if (!comment) printf("%s",yytext); }

%%

int yywrap(void)
{
 return 1;
}

main()
{
  yylex();
  //prints the number of lines for the user to see
  printf( "This file contains %d lines of code.\n", numLines );
}

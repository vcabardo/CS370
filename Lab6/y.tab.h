/* A Bison parser, made by GNU Bison 3.3.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2019 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NUMBER = 258,
    ID = 259,
    BEG = 260,
    END = 261,
    IF = 262,
    THEN = 263,
    ELSE = 264,
    WHILE = 265,
    DO = 266,
    RETURN = 267,
    READ = 268,
    WRITE = 269,
    AND = 270,
    OR = 271,
    TRUE = 272,
    FALSE = 273,
    NOT = 274,
    INT = 275,
    VOID = 276,
    BOOLEAN = 277,
    LTE = 278,
    GTE = 279,
    E = 280,
    NE = 281
  };
#endif
/* Tokens.  */
#define NUMBER 258
#define ID 259
#define BEG 260
#define END 261
#define IF 262
#define THEN 263
#define ELSE 264
#define WHILE 265
#define DO 266
#define RETURN 267
#define READ 268
#define WRITE 269
#define AND 270
#define OR 271
#define TRUE 272
#define FALSE 273
#define NOT 274
#define INT 275
#define VOID 276
#define BOOLEAN 277
#define LTE 278
#define GTE 279
#define E 280
#define NE 281

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 40 "lab6.y" /* yacc.c:1921  */

    int number; //treat token as a 32 bit integer
    char *string; //treat token as a 32 bit pointer to a string
    struct ASTnodetype *node; //allow AST nodes to be constructed by the program 

#line 116 "y.tab.h" /* yacc.c:1921  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */

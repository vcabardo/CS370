;Name: Vensan Cabardo
;Date: 4/12/2019
;Description: NASM assembly program that takes a number in as input and prints the sum of squares of that number
;For example, for the input 3, this program will output 3^2 + 2^2 + 1^2 = 14

%include "io64.inc"

section .data

_L0:	db "the sum of squares of ", 0	;global string
_L1:	db " is ", 0		         ;global string

section .text
 	global main
			
			
main:			;Start of Function 
	mov    rbp, rsp		;SPECIAL RSP to RSB for MAIN only
	mov    r8, rsp		;FUNC header RSP has to be at most RBP
	add    r8, -96,		;adjust Stack Pointer for Activation record
	mov    [r8], rbp		;FUNC header store old BP
	mov [r8+8],rsp		;FUNC header store old SP
	mov    rsp, r8		;FUNC header new SP

        PRINT_STRING _L0		;print a string
        NEWLINE		;standard Write a NEWLINE
	mov rax, 16		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	GET_DEC 8, [rax]		; READ in an integer 
        PRINT_DEC 8, [rax] 		;standard Write a value
        NEWLINE		;standard Write a NEWLINE 
	mov rax, 16		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov rsi, [rax]		; load rsi with the ident VALUE 
			
	mov rdx, 1		;ASSIGN a number 
	mov [rsp + 32], rdx 		; STORE RHS of ASSIGN temporarily
	mov rax, 24		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov  rdx, [rsp+32] 		; FETCH RHS of ASSIGN temporarily
	mov [rax], rdx		; ASSIGN final store 
	mov rdx, 0		;ASSIGN a number 
	mov [rsp + 40], rdx 		; STORE RHS of ASSIGN temporarily
	mov rax, 16		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov  rdx, [rsp+40] 		; FETCH RHS of ASSIGN temporarily
	mov [rax], rdx		; ASSIGN final store 
_L2:	 			; WHILE TOP target
	mov rax, 24		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov rax, [rax]		;LHS expression is identifier
	mov [rsp+48], rax		;store LHS of expression in memory
	mov rbx, rsi		; RHS expresion a number
	mov rax, [rsp+48]		;fetch LHS of expression from memory
	cmp rax, rbx		;EXPR Lessthan
	setle al		;EXPR Lessthan
	mov rbx, 1		;set rbx to one to filter rax
	and rax, rbx		;filter RAX
	mov [rsp+48], rax		;store RHS of expression in memory
	mov rax, [rsp+ 48]		;WHILE expression EXPR
	CMP  rax, 0		;WHILE compare 
	JE  _L3		;WHILE branch out
	mov rax, 16		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov rax, [rax]		;LHS expression is identifier
	mov [rsp+64], rax		;store LHS of expression in memory
	mov rax, 24		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov rax, [rax]		;LHS expression is identifier
	mov [rsp+56], rax		;store LHS of expression in memory
	mov rax, 24		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov rbx,  [rax]		;RHS expression is identifier
	mov rax, [rsp+56]		;fetch LHS of expression from memory
	imul rax, rbx		;EXPR MULT
	mov [rsp+56], rax		;store RHS of expression in memory
	mov rbx, [rsp+56]		; RHS is expression
	mov rax, [rsp+64]		;fetch LHS of expression from memory
	add rax, rbx		;EXPR ADD
	mov [rsp+64], rax		;store RHS of expression in memory
	mov rdx, [rsp+64] 		; ASSIGN EXPR
	mov [rsp + 72], rdx 		; STORE RHS of ASSIGN temporarily
	mov rax, 16		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov  rdx, [rsp+72] 		; FETCH RHS of ASSIGN temporarily
	mov [rax], rdx		; ASSIGN final store 
	mov rax, 24		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov rax, [rax]		;LHS expression is identifier
	mov [rsp+80], rax		;store LHS of expression in memory
	mov rbx, 1		; RHS expresion a number
	mov rax, [rsp+80]		;fetch LHS of expression from memory
	add rax, rbx		;EXPR ADD
	mov [rsp+80], rax		;store RHS of expression in memory
	mov rdx, [rsp+80] 		; ASSIGN EXPR
	mov [rsp + 88], rdx 		; STORE RHS of ASSIGN temporarily
	mov rax, 24		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov  rdx, [rsp+88] 		; FETCH RHS of ASSIGN temporarily
	mov [rax], rdx		; ASSIGN final store 
	JMP _L2		          ;WHILE Jump back
_L3:	 			; End of WHILE 
	PRINT_STRING _L1		;print a string
        NEWLINE		;standard Write a NEWLINE
	mov rax, 16		;get Identifier offset
	add rax, rsp		; Add the SP to have direct reference to memory 
	mov rsi, [rax]		; load rsi with the ident VALUE 
	PRINT_DEC 8, rsi 		;standard Write a value 
	NEWLINE		;standard Write a NEWLINE
	mov    rbp,[rsp] 		;FUNC end restore old BP
	mov rsp,[rsp+8]		;FUNC end restore old SP
	mov    rsp,rbp 		;stack and BP need to be same on exit for main 
	ret
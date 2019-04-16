%include "io64.inc"

common	x	8	;define a global variable
section .data

_L0: db  "hello world", 0
section .text
	global main


main:		;Start of function	
	mov      rbp, rsp	;SPECIAL RSP to RSB for MAIN only	
	mov      r8, rsp	;FUNC header RSP has to be at most RBP	
	add      r8, -16	;adjust Stack Pointer for Activation Record	
	mov      [r8], rbp	;FUNC header store old BP	
	mov      [r8+8], rsp	;FUNC header store old SP	
	mov      rsp, r8	;FUNC header new SP	
			
	mov      rbp, [rsp]	;FUNC end restore old BP	
	mov      rsp, [rsp + 8]	;FUNC end restore old SP	
	mov      rsp, rbp	;Stack and BP need to be same on exit for main	
	xor      rax, rax	;no value specified, then in is 0	
	ret		

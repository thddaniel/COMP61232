		AREA	swi, CODE, READWRITE
		EXPORT	My_SWI_Handler
		EXTERN	My_Monitor_Handler
		;install a swi handler for SWI 0xff to print string
		;inline in the source code
		
SWI_ANGEL EQU 0x123456		;SWI number for Angel semihosting	

		
My_SWI_Handler
		STR		r13, r13tmp			;save r13
		STR		r14, r14tmp			;save r13
		LDR		r13, [r14, #-4]		;get swi instruction
		BIC		r13, r13, #0xff000000		;extract swi number
		CMP		r13, #0x00			;this swi ?
		BEQ		DoIt
		LDR		r13, r13tmp			;restore r13
		MOVS	pc, r14				;return to user mode code
		
DoIt
		BL 		My_Monitor_Handler
		
		LDR		r13, r13tmp			;restore r13
		LDR		r14, r14tmp			;restore r13
		MOVS	pc, r14				;return to user mode code


r13tmp	  DCD 0
r14tmp	  DCD 0

		END

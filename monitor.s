        AREA Monitor, CODE,READONLY
        IMPORT  Getline
		
		EXPORT My_Monitor_Handler

		

;******************************************************
;        Enter your full name here please             
;					Hao Tang
;			https://github.com/thddaniel/COMP61232	  
;******************************************************

; This is a template for the monitor project
; it sets up the stack and reserves space for the struct returned
; by getline. The rest is up to you
;
; Reminder: This Monitor is usually called in privileged mode. Don't forget (for example, when displaying registers via the 'R/r' command) that the debugged application is running in user mode.

		

;***********************************************************************
;					My_Monitor_Handler
;***********************************************************************
		
My_Monitor_Handler

		
; First load the stack pointer (you might want to improve it)

	    STR		r13, R13TMP		;save r13
	    adrl    r13, StackInit
        ldr     r13, [r13]
		STMFD		sp!,{r0-r12,lr}
		
		
; call the Getline routine like this
L1      bl      Getline
        ldrb    r1, [r0]        ;get Command letter
        ldrb    r2, [r0, #1]    ;get no. of params
        ldr     r3, [r0, #4]    ;get 1st param
        ldr     r4, [r0, #8]    ;get 2nd param
        ldr     r5, [r0, #12]   ;get 3rd param

		ADRL		r6, StackInit	;StackTop,used for Mcommand first time; need to modify later
		ADRL		r7, StackInit	;StackTop,used for mcommand first time; need to modify later
		

; OK start your code here
		ADR		lr,	L1
		
		;................
		;................
		CMP		r1, #0x4D		; 'M' Ascii
		BEQ		MCommand
		CMP		r1, #0x6D		; 'm' Ascii
		BEQ		mCommand
		CMP		r1, #0x52		; 'R' Ascii
		BEQ		RCommand
        CMP		r1, #0x72		; 'r' Ascii
		BEQ		RCommand	
		CMP		r1, #0x44		; 'D' ascii
		BEQ		DCommand
		CMP		r1, #0x43		; 'C' ascii
		BEQ		CCommand
		CMP		r1, #0x45		; 'E' ascii
		BEQ		ECommand
		CMP		r1, #0x51		; 'Q' ascii
		BEQ		QCommand

		b       L1
	
		;Test Print functions with different display, depends on BASEM

;***********************************************************************
;				M COMMAND <Address> <Value>
;***********************************************************************
		
MCommand
		STR		lr, R14TMP
		CMP		r2, #0			; if params == 0
		BEQ		MPARAMS0
		CMP		r2, #1			; if params == 1
		BEQ		MPARAMS1
		CMP		r2, #2			; if params == 2
		BEQ		MPARAMS2
		BL TextOut
        	= "Invalid  Entered!! Try again!!",&0a, &0d, 0
		B 		EXIT

MPARAMS0
		LDR		r3,	[r6]		; Load last memory address
		ADD		r3, r3, #4		; use the previous word address + 4
		STR		r3,	[r6]		; Preserve r6 to restore last memory
		
MPARAMS1

		LDR		r2,	[r3]		; Prepare for printing
		STR		r3,	[r6]		; Preserve r6 to restore last memory
		
		ANDS	r0, r3,	#0x03	; Check word-aligned
		BLNE 	ADJUSTWORD
								
		BL		PRINT
		B 		EXIT
	
		
MPARAMS2
		STR		r3,	[r6]		; Preserve r6 to restore last memory
		ANDS	r0, r3,	#0x03	; Check word-aligned
		BLNE 	ADJUSTWORD
		MOV		r12, #4
		MOV		r2, #0
MLOOP	MOV		r0, r4, LSR r2	; Shift	Desired byte in least significant byte	
		BIC		r0, r0, #0xFFFFFF00 ; Mask out undesired bits
		STRB	r0, [r3]
		ADD		r3, r3, #1		; Move to next byte
		ADD		r2, r2, #8		; Adjust Shift counter
		SUBS	r12, r12, #1	; Adjust Byte Counter
		BNE		MLOOP
		B 		EXIT

	
		
ADJUSTWORD
		ADD		r3, r3, #4	
		SUB		r3, r3, r0
		LDR		r2,	[r3]	
		MOV		pc, lr
		
;***********************************************************************
;			m COMMAND <Address> <Value>
;			Should be changed later!!!LDRB STRB
;***********************************************************************
		

mCommand
		STR		lr, R14TMP
		CMP		r2, #0			; if params == 0
		BEQ		mPARAMS0
		CMP		r2, #1			; if params == 1
		BEQ		mPARAMS1
		CMP		r2, #2			; if params == 2
		BEQ		mPARAMS2
		BL TextOut
        	= "Invalid  Entered!! Try again!!",&0a, &0d, 0
		B 		EXIT


mPARAMS0
		LDR		r3,	[r7]		; Load last memory address
		ADD		r3, r3, #1		; use the previous word address + 1
		STR		r3,	[r7]		; Preserve r7 to restore last memory

mPARAMS1
		
		STR		r3,	[r7]		; Preserve r7 to restore last memory
		LDR		r2,	[r3]		; Prepare for printing
		
		MOV		r4, #1			;Prepare for print one byte
		ADRL		r8,	BASEB
		STR		r4,	[r8]
		
		BL		PRINT
		B 		EXIT
	

mPARAMS2	
		STR		r3,	[r7]		; Preserve r7 to restore last memory
		
		LDR		r2,	[r3]
		BIC		r2, r2, #0x000000FF 
		BIC		r4, r4, #0xFFFFFF00 
		ORR  	r4,	r4, r2
		STREQB	r4,	[r3]	
		B 		EXIT
	
;***********************************************************************
;				R\r COMMAND <Number> <Value>
;***********************************************************************
				
		
RCommand
		STR		lr, R14TMP
		CMP		r2, #0			; if params == 0
		BEQ		RPARAMS0
		CMP		r2, #1			; if params == 1
		BEQ		RPARAMS1
		CMP		r2, #2			; if params == 2
		BEQ		RPARAMS2
		BL TextOut
        	= "Invalid  Entered!! Try again!!",&0a, &0d, 0
		B 		EXIT
	
RPARAMS0
		
		ADRL		r8, Messages
		MOV		r9, #13
		MOV		r5, #0
		
RPRINT		
		BL		PrintNextMessage
		
		LDR 	r2, [sp,r5,LSL #2]
		ADD		r5,	r5, #1
		BL 		PRINT
		SUBS	r9, r9, #1	;
		BNE		RPRINT		;r0~r12
		
		BL		PrintNextMessage ;r13
		LDR		r2, R13TMP		 ;  value before entered exceptions
		BL 		PRINT
			
		BL		PrintNextMessage ;r14
		LDR 	r2, [sp,r5,LSL #2]
		BL 		PRINT
		;r15
		
		B 		EXIT

RPARAMS1
		
		CMP		r3, #0x0F		
		SUBGT	r3,	r3,	#6
		CMP		r3, #0x0E		
		BGT		EXIT
		;BL TextOut
        ;	= "Test r0~r14",&0a, &0d, 0
        
		
		CMP		r3, #0x0D 
		BLT		RPNORMAL		;print r0~12
		CMP		r3, #0x0D
		BEQ		RPSP			;print r13
		LDR 	r2, [sp,#52]
		BL 		PRINT		;print r14
		B 		EXIT
			

RPNORMAL		
		LDR 	r2, [sp,r3,LSL #2]
		B 		EXIT


RPSP		
		LDR		r2, R13TMP
		BL 		PRINT        
		B 		EXIT


RPARAMS2
		CMP		r3,	#0x0D		
		BLT		RWNORMAL		;Write r0~12
;		CMP		r3, #0x0D
;		BEQ		RWSP			;Write r13
		CMP		r3, #0x0E
		BEQ		RWLR
		B 		EXIT				

RWNORMAL		
		STR 	r4, [sp,r3,LSL #2]
		B 		EXIT


;RWSP		
;		STR		r4, R13    
;		B 		EXIT


RWLR
		STR 	r4, [sp,#52]	;Write r14			
		B 		EXIT

;***********************************************************************
;		C COMMAND  <r3:source> <r4:dest> <r5:length> 
;***********************************************************************
		
CCommand
		STR		lr, R14TMP
		CMP		r5, #0
		BEQ		EXIT
		CMP		r2, #3			
		BEQ		COPYMEMORY
		BL TextOut
        	= "Invalid  Entered!! Try again!!",&0a, &0d, 0
		B 		EXIT

		
COPYMEMORY
		CMP		r3, r4	     ;compare source & dest  
		BGT		FBCPLOOP     ;HIGHSOURCE
		ADD		r3,r3,r5    ;last source Address +1
		ADD		r4,r4,r5	 ;last dest Address +1
		BLT		BBCPLOOP	 ;HIGHDEST
		B 		EXIT

;HIGHSOURCE
;		ADD		r0, r4, r5	;dest+length>?source
;		SUB		r0,	r0, #1	; 
;		CMP		r0,	r3
;		BGE		CASE1		;interleaving
;		B		CASE2		;non-interleaving
;		B 		EXIT


		
;HIGHDEST		
;		ADD	r0, r3, r5	
;		SUB	r0,	r0, #1	
;		CMP	r0,	r4
;		BGE		CASE3		;interleaving
;		B		CASE4		;non-interleaving
;		B 		EXIT


;CASE1	
FBCPLOOP	;Forward copy (byte)

		LDRB	r0,	[r3],#1
		STRB	r0,	[r4],#1
		SUBS	r5, r5, #1
		BGT		FBCPLOOP
		B 		EXIT




;CASE3	
;		ADD		r3,r3,#r5;	last source Address +1
;		ADD		r4,r4,#r5;	last dest Address +1
	
BBCPLOOP	;backward copy (byte)

		SUB		r3, r3,	#1
		SUB		r4,	r4,	#1
		LDRB	r0,	[r3]
		STRB	r0,	[r4]
		SUBS	r5, r5, #1
		BGT		BBCPLOOP
		B 		EXIT



		

		
;***********************************************************************
;		D COMMAND  <10/16/2>  
;***********************************************************************
		

DCommand
		STR		lr, R14TMP
		CMP		r2, #1			
		BEQ	DSETDISPLAY
		BL TextOut
        	= "Invalid  Entered!! Try again!!",&0a, &0d, 0
		B 		EXIT
  


DSETDISPLAY	
		ADR		r0, BASEM
		CMP		r3,	#0x16
		MOVEQ	r3,	#0
		STR		r3,	[r0]
		CMP		r3,	#0x02
		MOVEQ	r3,	#0x01
		STR		r3,	[r0]
		CMP		r3,	#0x10
		MOVEQ	r3,	#0x02
		STR		r3,	[r0]
 	
		
		;******test***************************
;		ADR		r1,	BASEM
;		LDR		r1,	[r1]
;		LDR		r2, VALUE		;get value to print
;		CMP		r1, #0	
;		BEQ	PHexOut
;		CMP		r1, #1	
;		BEQ	PBinOut
;		CMP		r1, #2	
;		BEQ	PDecOut
		;******end test **********************

		B 		EXIT

		
;******test**********

;PHexOut
;		BL		TextOut
;		= "Test HexOut Function:", &0a, &0d, 0 
;		BL		HexOut			;call hexadecimal output
;		LDR		lr, R14TMP
;		MOV		pc, lr	
;		
;PBinOut		
;		BL		TextOut
;		= "Test BinOut Function:", &0a, &0d, 0 		
;		BL		BinOut			;call hexadecimal output
;		LDR		lr, R14TMP
;		MOV		pc, lr	
;
;PDecOut		
;		BL		TextOut
;		= "Test DecOut Function:", &0a, &0d, 0 		
;		BL		DecOut			;call hexadecimal output
;		LDR		lr, R14TMP
;		MOV		pc, lr	


;*******end test*****

		
;***********************************************************************
;		E COMMAND  <0/1>  
;***********************************************************************
		
ECommand
		STR		lr, R14TMP
		ADR		r0, ENDIAN
		CMP		r2, #0			; If no parameter return
		BEQ		ETOGGLE
		
		CMP		r3, #1
		BEQ		ESET
		CMP		r3, #0
		BEQ		ESET
		
		BL TextOut
        	= "Invalid  Entered!! Try again!!",&0a, &0d, 0
		
		B 		EXIT
	
ETOGGLE 
		LDR		r4, [r0]
		CMP		r4, #1
		
		MOVNE	r4, #1
		MOVEQ	r4, #0
		
		STR		r4, [r0]
		B 		EXIT

ESET	
		STR		r3,	[r0]	 
		B 		EXIT

		
;***********************************************************************
;		Q COMMAND  
;***********************************************************************
				
QCommand
		LDMFD	sp!, {r0-r12,pc}^
		LDR		r13, R13TMP			;restore r13
		MOVS	pc, r14				;return to user mode code
		
	
;***********************************************************

EXIT
		LDR		lr, R14TMP
		MOV		pc, lr
		
PRINT			
		ADR		r0,	BASEJUMP		;Select Base for printing
		ADR		r1,	BASEM
		LDR		r1,	[r1]
		LDR		pc,	[r0,r1,LSL #2]		; jump to appropriate routine



;********************************************************
;Print functions: HexOut, BinOut , DecOut , TextOut		*
;Usage:						
;		HexOut, BinOut , DecOut, first store value into r2 
;
;		BL		TextOut
		= "Test TextOut", &0a, &0d, 0 
;********************************************************

SWI_ANGEL EQU   0x123456        ;SWI number for Angel semihosting   

        MACRO
$l      Exit                    ;Angel SWI call to terminate execution
$l      MOV     r0, #0x18       ;select Angel SWIreason_ReportException(0x18)
        LDR     r1, =0x20026    ;report ADP_Stopped_ApplicationExit
        SWI     SWI_ANGEL       ;ARM semihosting SWI
        MEND

        MACRO
$l      WriteC                  ;Angel SWI call to output character in [r1]
$l      MOV     r0, #0x3        ;select Angel SYS_WRITEC function
        SWI     SWI_ANGEL
        MEND
        
        MACRO
$l      ReadC                   ;Angel SWI call to receive input of a character to [r0]
$l      MOV     r0, #0x7        ;select Angel SYS_READC function
        MOV     r1, #0x0        ;[r1] must be 0
        SWI     SWI_ANGEL
        MEND

HexOut	STR		r12,	REGTMP	; Preserve r12 value so we can use register
		MOV		r3, #8			;nibble count = 8
		ADRL		r1, CHAROUT
		MOV		r0, #0x30
		STR		r0, [r1]		;store character to print
		WriteC					;print character 0
		MOV		r0, #0x78
		STR		r0, [r1]		;store character to print
		WriteC					;print character x
		
		
		
		LDR		r4, BASEB
		CMP		r4, #1
		BEQ		PBYTE0
		
		LDR		r12, ENDIAN
		CMP		r12, #0
		BEQ		LELOOP
		MOV		r3, r3, LSR #1	;Change r3 to byte count
		B		BELOOP

		
PBYTE0	
		MOV		r4, #0
		ADRL	r8,	BASEB
		STR		r4,	[r8]		;restore 		
		MOV		r2, r2, LSL #24	;shift left one nibble
		MOV 	r3, #2

		


		
			
		
LELOOP	MOV		r0, r2, LSR #28	;get top nibble
		CMP		r0, #9			;0-9 or A-F
		ADDGT	r0, r0, #"A"-10	;ASCII alphabetic
		ADDLE	r0, r0, #"0"	;ASCI numeric
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		MOV		r2, r2, LSL #4	;shift left one nibble
		
		SUBS	r3, r3, #1	;decrement nibble count
		BNE		LELOOP		;if more do next nibble
		B		HexEx
		
		
			
BELOOP	BIC		r12, r2, #0xFFFFFF00 ;Clear upper bytes
		MOV		r0,	r12, LSR #4
		CMP		r0, #9			;0-9 or A-F
		ADDGT	r0, r0, #"A"-10	;ASCII alphabetic
		ADDLE	r0, r0, #"0"	;ASCI numeric
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		BIC		r0, r12, #0xF0
		CMP		r0, #9			;0-9 or A-F
		ADDGT	r0, r0, #"A"-10	;ASCII alphabetic
		ADDLE	r0, r0, #"0"	;ASCI numeric
		STR		r0, [r1]		;store character to print
		WriteC					;print character

		MOV		r2, r2, LSR #8	;shift right one byte
		SUBS	r3, r3, #1	;decrement nibble count
		
		BNE		BELOOP		;if more do next nibble
		
		
HexEx	MOV		r0, #0x0d
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		MOV		r0, #0x0a
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		
		LDR		r12,	REGTMP	;Restore r12. For APCS Compliance
		
		MOV		pc, r14		;return
		

BinOut	STR		r12,	REGTMP	; Preserve r12 value so we can use register
		ADRL	r1, CHAROUT
		MOV		r3, #32			
		
		LDR		r4, BASEB
		CMP		r4, #1
		BEQ		PBYTE1	
		
		LDR		r12, ENDIAN
		CMP		r12, #0
		BEQ		LOOP2
		;if big-endian flip bytes in word
		MOV		r0,	#32
		MOV		r12, #0
SWAP	SUB		r0, r0, #8
		BIC		r3, r2, #0x00FFFFFF
		MOV		r3,	r3, LSR r0
		ORR		r12, r12, r3
		MOV		r2, r2, LSL #8
		CMP		r0, #0
		BNE 	SWAP
		MOV		r2,	r12
		MOV		r3, #32
	
	
PBYTE1	
		MOV		r4, #0
		ADRL	r8,	BASEB
		STR		r4,	[r8]		;restore 		
		MOV		r2, r2, LSL #24	;shift left one nibble
		MOV 	r3, #8
		
			
LOOP2	MOV		r0, r2, LSR #31	;get top nibble
		ADD		r0, r0, #0x30	; get print number
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		MOV		r2, r2, LSL #1	;shift left one nibble
		SUBS	r3, r3, #1	;decrement nibble count
		BNE		LOOP2		;if more do next nibble
		
		MOV		r0, #0x0d
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		MOV		r0, #0x0a
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		
		LDR		r12,	REGTMP	;Restore r12. For APCS Compliance
				
		MOV		pc, r14		;return

DecOut	
		STR		r5,	REGTMP	; Preserve r5 value so we can use register
		MOV		r1, #1		;Initialize counters & variables
		MOV		r3,	#0
		SUB		r13,r13,#4
		STR		r3,	[r13]	;Intialiaze end of string
RDIV	MOV		r0, #10
		SUB		r13,r13,#4	; Alocate space on stack for character
		CMP		r2,	#10
		ADDLT	r2,	r2, #0x30
		STRLT	r2,	[r13]
		BLT		DECPRINT
SETDEC	CMP		r2, r0
		BLT		ADJ
		MOV		r0,	r0, LSL #1
		ADD		r3, r3, #1
		B		SETDEC

ADJ		MOV		r0,	r0,	LSR #1
		MOV		r5,	#0
GETCHAR	CMP		r3,	#0
		ADDEQ	r2,	r2, #0x30
		STREQ	r2,	[r13]
		MOVEQ	r2,	r5		
		BEQ		RDIV
		CMP		r2, r0
		SUB		r3,	r3, #1
		BLT		INC
		SUB		r2,	r2,	r0
		ADD		r5,	r5,	r1,	LSL r3
INC		MOV		r0,	r0,	LSR	#1
		B		GETCHAR
DECPRINT		
		ADRL	r1,	CHAROUT
		LDR		r0,	[r13]
		ADD		r13, r13, #4
		CMP		r0,	#0
		BEQ		DECEXIT
		STR	r0,	[r1]
		WriteC
		B		DECPRINT

DECEXIT	MOV		r0, #0x0d
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		MOV		r0, #0x0a
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		
		LDR		r5,	REGTMP		;Restore r5. For APCS Compliance
		MOV		pc, lr		;return




;;;;;;;;;;;;;start of TextOut routine from earlier exercise;;;;;;;;; 
TextOut	;output string starting at [r14]
		MOV		r0, #0x3			;select Angel SYS_WRITEC function
NxtTxt	LDRB	r1, [r14], #1		;get next character
		CMP		r1, #0				;test for end mark
		SUBNE	r1, r14, #1			;setup r1 for call to SWI
		SWINE	SWI_ANGEL			;if not end, print..
		BNE		NxtTxt				; ..and loop
		ADD		r14, r14, #3		;pass next word boundary
		BIC		r14, r14, #3		;round back to boundary
;;;;;;;;;;;;;end of textout routine from earlier exercise;;;;;;;;;;;
		MOV		pc,	lr
		
		



StackInit
        DCD     StackTop


VALUE	DCD		&1234abcd
BASEM	DCD		0
BASEB	DCD		0
CHAROUT	DCD		0		
REGTMP	DCD		0
ENDIAN	DCD		0
R13TMP	DCD		0
R14TMP	DCD		0

BASEJUMP
		DCD		HexOut
		DCD		BinOut
        DCD		DecOut


PrintNextMessage	;output string starting at [r8]
		MOV		r0, #0x3			;select Angel SYS_WRITEC function
NextTxt	LDRB	r1, [r8], #1		;get next character
		CMP		r1, #0				;test for end mark
		SUBNE	r1, r8, #1			;setup r1 for call to SWI
		SWINE	SWI_ANGEL			;if not end, print..
		BNE		NextTxt				; ..and loop
		MOV		pc, r14

Messages
		= "R0 = ", &0a, &0d, 0
		= "R1 = ", &0a, &0d, 0
		= "R2 = ", &0a, &0d, 0
		= "R3 = ", &0a, &0d, 0
		= "R4 = ", &0a, &0d, 0
		= "R5 = ", &0a, &0d, 0
		= "R6 = ", &0a, &0d, 0
		= "R7 = ", &0a, &0d, 0
		= "R8 = ", &0a, &0d, 0
		= "R9 = ", &0a, &0d, 0
		= "R10 = ", &0a, &0d, 0
		= "R11 = ", &0a, &0d, 0
		= "R12 = ", &0a, &0d, 0
		= "R13 = ", &0a, &0d, 0
		= "R14 = ", &0a, &0d, 0
;		= "R15 = ", &0a, &0d, 0
		ALIGN
		
		


        AREA stack, DATA, READWRITE
; Place your data here


StackBtm
        %        0x100
StackTop

        END


        AREA Monitor, CODE,READONLY
        IMPORT  Getline
		
		EXPORT My_Monitor_Handler

;******************************************************
;        Enter your full name here please             *
;					Hao Tang
;******************************************************

; This is a template for the monitor project
; it sets up the stack and reserves space for the struct returned
; by getline. The rest is up to you
;
; Reminder: This Monitor is usually called in privileged mode. Don't forget (for example, when displaying registers via the 'R/r' command) that the debugged application is running in user mode.

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
		ADR		r1, CHAROUT
		MOV		r0, #0x30
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		MOV		r0, #0x78
		STR		r0, [r1]		;store character to print
		WriteC					;print character
		
		LDR		r12, ENDIAN
		CMP		r12, #0
		BEQ		LELOOP
		MOV		r3, r3, LSR #1	;Change r3 to byte count
		B		BELOOP
			
		
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
		ADR		r1, CHAROUT
		MOV		r3, #32			;bit count = 8
		
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
		ADR		r1,	CHAROUT
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
		

;***********************************************************************
;
;
;
;
;
;
;
;***********************************************************************
        

My_Monitor_Handler

		
; First load the stack pointer (you might want to improve it)
;We store the user mode stackpointer in R13TMP and restore on return
	    STR		r13, R13TMP
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



; OK start your code here
		ADR		lr,	L1
		

		;................
		;................
		CMP		r1, #0x44		; 'D' ascii
		BEQ		DCommand
		CMP		r1, #0x45		; 'E' ascii
		BEQ		ECommand
		CMP		r1, #0x51		; 'Q' ascii
		BEQ		QCommand

		b       L1
	
		;Test Print functions with different display, depends on BASEM




		



DCommand
		STR		lr, R14TMP
		CMP		r2, #1			
		BEQ	DSETDISPLAY
		BL TextOut
        	= "Invalid  Entered!! Try again!!",&0a, &0d, 0
        LDR		lr, R14TMP
		MOV		pc, lr  


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
		ADR		r1,	BASEM
		LDR		r1,	[r1]
		LDR		r2, VALUE		;get value to print
		CMP		r1, #0	
		BEQ	PHexOut
		CMP		r1, #1	
		BEQ	PBinOut
		CMP		r1, #2	
		BEQ	PDecOut
		;******end test **********************

		LDR		lr, R14TMP
		MOV		pc, lr		
		
		
;******test**********

PHexOut
		BL		TextOut
		= "Test HexOut Function:", &0a, &0d, 0 
		BL		HexOut			;call hexadecimal output
		LDR		lr, R14TMP
		MOV		pc, lr	
		
PBinOut		
		BL		TextOut
		= "Test BinOut Function:", &0a, &0d, 0 		
		BL		BinOut			;call hexadecimal output
		LDR		lr, R14TMP
		MOV		pc, lr	

PDecOut		
		BL		TextOut
		= "Test DecOut Function:", &0a, &0d, 0 		
		BL		DecOut			;call hexadecimal output
		LDR		lr, R14TMP
		MOV		pc, lr	


;*******end test*****


ECommand
		STR		lr, R14TMP
		ADR		r0, ENDIAN
		CMP		r2, #0			; If no parameter return
		BEQ		ETOGGLE
		
		CMP		r3, #1
		BEQ		ESET
		CMP		r3, #0
		BEQ		ESET
		

		
		LDR		lr, R14TMP
		MOV		pc, lr 
		
		
ETOGGLE 
		LDR		r4, [r0]
		CMP		r4, #1
		
		MOVNE	r4, #1
		MOVEQ	r4, #0
		
		STR		r4, [r0]
		
		LDR		lr, R14TMP
		MOV		pc, lr
ESET	
		STR		r3,	[r0]
		LDR		lr, R14TMP
		MOV		pc, lr 
		


	
		

QCommand
		LDMFD	sp!, {r0-r12,pc}^
		MOVS	pc, r14				;return to user mode code
		
	
;***********************************************************
StackInit
        DCD     StackTop


VALUE	DCD		&1234abcd
BASEM	DCD		2
CHAROUT	DCD		0		
REGTMP	DCD		0
ENDIAN	DCD		0
R13TMP	DCD		0
R14TMP	DCD		0

        AREA stack, DATA, READWRITE
; Place your data here


StackBtm
        %        0x100
StackTop

        END


        AREA Monitor, CODE,READONLY
        IMPORT  Getline

;******************************************************
;        Enter your full name here please             *
;******************************************************

; This is a template for the monitor project
; it sets up the stack and reserves space for the struct returned
; by getline. The rest is up to you
;
; Reminder: This Monitor is usually called in privileged mode. Don't forget (for example, when displaying registers via the 'R/r' command) that the debugged application is running in user mode.


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
        

        
Monitor

; First load the stack pointer (you might want to improve it)
	    adrl    r13, StackInit
        ldr     r13, [r13]

; call the Getline routine like this
L1      bl      Getline
        ldrb    r1, [r0]        ;get Command letter
        ldrb    r2, [r0, #1]    ;get no. of params
        ldr     r3, [r0, #4]    ;get 1st param
        ldr     r4, [r0, #8]    ;get 2nd param
        ldr     r5, [r0, #12]   ;get 3rd param


; OK start your code here
        b       L1
        
        
        
StackInit
        DCD     StackTop

        AREA stack, DATA, READWRITE
; Place your data here

StackBtm
        %        0x100
StackTop
        END


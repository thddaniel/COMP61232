# Project Files

- monitor.s: A skeleton file for your monitor program.
- main.s: The test harness for your monitor. This file doesn't need to be modified. The main application (file main.s), running in User mode, is interrupted in two different manners. The first one is the execution of an undefined instruction. The second one is a software interrupt (SWI). Both interrupts should lead to a jump to your monitor program in order to debug the interrupted application. This should be done in a similar way as in the "SWI handler" exercise studied previously.
- getline.a: A binary of the line parsing routine is included since writing your own routine can be tricky. However, to get maximum marks for the project, you are expected to write your own replacement for this routine.
- vectors.s: Already seen in the "SWI handler" exercise, this is an example on how to initialise the ARM Vector Table to a default state. Modify it to link your monitor to the appropriate events.



# Mission


|  Command (params1, 2 , 3)       | Action  |
| :-------------: |:-------------:| 
| M	{\<address>}	{\<value>}     | Display the contents of the memory word starting at address \<address> and ending at \<address+3 bytes>. If \<address> is not specified, use the previous word address + 4. If \<value> is specified, overwrite the memory contents with the specified value. If \<address> is not word-aligned, data manipulations will be necesssary to display the proper word value.     |
| m	{\<address>} {\<value>}       |   Display the contents of the memory byte. If \<address> is not specified, use the previous byte address + 1. If \<value> is specified, overwrite the memory contents with the specified value.   |
| R\r {\<number>}	{\<value>}|   Display the contents of the specified register. If \<number> is not specified, display the contents of all registers. If \<value> is specified, overwrite the register contents with the specified value. Handle both decimal and hexadecimal register numbers: "R 12" and "R C" should point to the same register. Think about special needs for every value of \<value>. |
|C	\<source>	\<dest>	 \<length> (bytes)|    Copy a memory block of \<length> bytes starting at address \<source> to a destination address starting at \<dest>. Your program should cope with \<dest> being an arbitrary location i.e. below \<source>, above \<source+length> or in-between the two. Addresses can be non-word-aligned. Points will be given for efficiency (e.g. use words and multi-words copies when possible). |
| E	{0 \| 1}        |  Change the data representation to either little-endian ("E 0", default) or big-endian ("E 1"). No parameter indicates toggle the representation.|
| D	{10 \| 16 \| 2} |   Change the display of memory/register to decimal, hexadecimal or binary. |
| Q      |   Leave the monitor and return to the main application.  |





# Plan

**Todo:**


1. ~~Handle undefined instructions and Implement Q command~~
2. ~~Implement D command (decimal, hexadecimal and binary print functions)~~
3. ~~Implement E command ( little-endian & big-endian)~~
4. Implement software interrupt (SWI)
5. Implement M command
6. Implement m command
7. Implement R/r command
8. Implement C command
9. Write parsing routine to replace getline.a
10. Optimize the code

#Resource

All subroutines should adhere to the APCS [ARM Cross-Platform Development](https://moodle.cs.man.ac.uk/file.php/274/lowpower-cbt/system_development/arm_cross/step1.html)

Some answers of labs(swi) [answers](http://apt.cs.manchester.ac.uk/ftp/pub/apt/john/peve-arm/answers/)

#Changelog
##08/03/2016

- Change vectors.s. Raised an exception and handle undefined instructions successfully.
![1](https://raw.githubusercontent.com/thddaniel/COMP61232/master/images/1.png =250x)
- Add Q command, return to user mode code.
- Write HexOut, BinOut , DecOut and TextOut functions. First store initial value(0x1234abcd) into r2 and then test the program in the DCOMMAND routine. BASEM records the way to print. 
![2](https://raw.githubusercontent.com/thddaniel/COMP61232/master/images/2.png =250x)
- Add little-endian & big-endian support in print functions, write a E command to switch on the basis of ENDIAN.
![3](https://raw.githubusercontent.com/thddaniel/COMP61232/master/images/3.png =250x)

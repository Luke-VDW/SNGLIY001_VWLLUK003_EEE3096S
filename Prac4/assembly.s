/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
    LDR R0, GPIOA_BASE       @ Load button base address
    LDR R3, [R0, #0x10]      @ Load input from pushbuttons (IDR register)
	BL delay_long
	MOVS R5, #1					@ Default increment is 1

	@ Check SW2:
    LDR R6, #SW2_MASK
    TST R3, R6
    BEQ pressed_sw2

    @ Check SW0:
    LDR R6, #SW0_MASK
    TST R3, R6
    BEQ pressed_sw0

    @ Check SW1:
    LDR R6, #SW1_MASK
    TST R3, R6
    BEQ pressed_sw1

main_loop2:

	BL pressed_sw3

	STR R2, [R1, #0x14]
	BL delay_loop				@ Call delay routine

    ADD R2, R2, R5            	@ Increment LED pattern by value in R5

    B main_loop               	@ Repeat the loop

pressed_sw0:

    MOVS R5, #2

    @ Check SW1:
    LDR R6, #SW1_MASK
    TST R3, R6
    BEQ pressed_sw1

    B main_loop2

pressed_sw1:

    BL delay_short
    B main_loop2

pressed_sw2:
	MOVS R7, #0xAA
	STR R7, [R1, #0x14]
	B main_loop

pressed_sw3:
	LDR R3, [R0, #0x10]
    LDR R6, #SW3_MASK
    TST R3, R6
    BEQ pressed_sw3
	BX LR

delay_long:
    LDR R4, =LONG_DELAY_CNT		@ Load delay count into R0
    LDR R4, [R4]
    BX LR

delay_short:
	LDR R4, =SHORT_DELAY_CNT	@ Load delay count into R0
    LDR R4, [R4]
    BX LR

delay_loop:
    SUBS R4, R4, #1            	@ Decrement R0
    BNE delay_loop             	@ Loop until R0 reaches 0
    BX LR                      	@ Return from delay

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 2800000    @ Long delay for 0.7 seconds
SHORT_DELAY_CNT: 	.word 1200000    @ Short delay for 0.3 seconds

@ TODO: Add bit masks for buttons
SW0_MASK:           .word 0x01     @ SW0 button mask
SW1_MASK:           .word 0x02     @ SW1 button mask
SW2_MASK:           .word 0x04     @ SW2 button mask
SW3_MASK:           .word 0x08     @ SW3 button mask

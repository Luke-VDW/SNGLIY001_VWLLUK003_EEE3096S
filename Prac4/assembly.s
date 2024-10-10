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

    BL check_buttons          @ Check button states

    STR R2, [R1, #0x14]       @ Write current LED pattern to output data register (ODR)

    BL delay                  @ Call delay routine

    ADD R2, R2, R5            @ Increment LED pattern by value in R5
    B main_loop               @ Repeat the loop

check_buttons:
    MOVS R5, #1                @ Default increment is 1
    LDR R0, [R0, #0x10] 	   @ Load button states (IDR register)

    @ Check SW0: increment by 2
    LDR R5, #SW0_MASK
    TST R0, R5         			@ Check if SW0 is pressed
    BEQ skip_sw0
    MOVS R5, #2           	    @ Set increment to 2 if SW0 is pressed
skip_sw0:

    @ Check SW1: change delay to short delay
    LDR R5, #SW1_MASK
    TST R0, R5
    BEQ skip_sw1
    LDR R4, SHORT_DELAY_CNT    @ Use short delay if SW1 is pressed
skip_sw1:

    @ Check SW2: set LEDs to 0xAA
    LDR R5, #SW2_MASK
    TST R0, R5
    BEQ skip_sw2
    MOVS R2, #0xAA             @ Set LED pattern to 0xAA
    B exit_check_buttons       @ Skip remaining checks
skip_sw2:

    @ Check SW3: freeze pattern
    LDR R5, #SW3_MASK
    TST R0, R5
    BEQ exit_check_buttons
    B main_loop               @ Freeze pattern until SW3 is released

exit_check_buttons:
    BX LR                      @ Return from subroutine

delay:
    MOV R0, R4                 @ Load delay count into R0
delay_loop:
    SUBS R0, R0, #1            @ Decrement R0
    BNE delay_loop             @ Loop until R0 reaches 0
    BX LR                      @ Return from delay

write_leds:
	STR R2, [R1, #0x14]
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 700000    @ Long delay for 0.7 seconds
SHORT_DELAY_CNT: 	.word 300000    @ Short delay for 0.3 seconds

@ TODO: Add bit masks for buttons
SW0_MASK:           .word 0x01     @ SW0 button mask
SW1_MASK:           .word 0x02     @ SW1 button mask
SW2_MASK:           .word 0x04     @ SW2 button mask
SW3_MASK:           .word 0x08     @ SW3 button mask

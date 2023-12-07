BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const SCREEN_TOP_LEFT_ADDR 		= $0400

		.const X_CHAR						= $56
		.const SPACE_CHAR					= $20

		.var screen_loc_pointer				= $fb

init:
		jsr empty_screen
		jsr init_screen_loc

loop:
		jsr set_screen_loc
		jsr draw
		jmp loop

//------------------------------------------------------------------------
// LOOP SUBROUTINES

draw:
		ldy #$00
		lda #X_CHAR
		sta (screen_loc_pointer), y
		rts

//------------------------------------------------------------------------
// INIT SUBROUTINES

empty_screen:
		lda #SPACE_CHAR
		ldx #$fa							// 250 byte chunks
!:		sta SCREEN_TOP_LEFT_ADDR-1, x
		sta SCREEN_TOP_LEFT_ADDR+249, x
		sta SCREEN_TOP_LEFT_ADDR+499, x
		sta SCREEN_TOP_LEFT_ADDR+749, x
		dex
		bne !-
		// set border and background color
		lda #$0f
		sta BORDER_COLOR_ADDR
		lda #$00
		sta BG_COLOR_ADDR
		rts

// set the x and y position of where to draw
init_screen_loc:
		lda #$13
		sta x_pos
		lda #$0c
		sta y_pos
		rts

//------------------------------------------------------------------------
// HELPER SUBROUTINES

// set screen_loc_pointer to the coordinates stored at x_pos and y_pos
set_screen_loc: {
		// reset screen_loc_pointer to top left corner
		lda #<SCREEN_TOP_LEFT_ADDR
		sta screen_loc_pointer
		lda #>SCREEN_TOP_LEFT_ADDR
		sta screen_loc_pointer+1
		// load x_pos and y_pos
		lda x_pos							// x_pos (between 0 and 39)
		ldy y_pos							// y_pos (between 0 and 24)
	loop_y:
		cpy #$00
		beq screen_loc_done
		clc
		adc #$28							// add 40 for each row
		bcs inc_page
		dey
		jmp loop_y
	inc_page:
		ldx screen_loc_pointer+1
		inx
		stx screen_loc_pointer+1
		dey
		bne loop_y
	screen_loc_done:
		sta screen_loc_pointer
		rts
}

//------------------------------------------------------------------------
// DATA

x_pos:
	.byte $00

y_pos:
	.byte $00
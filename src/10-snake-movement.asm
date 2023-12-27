BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const SCREEN_TOP_LEFT_COLOR_ADDR 	= $d800
		.const RASTER_LINE_ADDR				= $d012
		.const SNAKE_SCREEN_PTR_START_ADDR	= $2000
		.const SNAKE_SCREEN_PTR_END_ADDR	= $27ff

		.const CHAR_SPACE					= $20

		.var snake_head_ptr					= $fb
		.var snake_tail_ptr					= $fd

init:
		sei
		jsr empty_screen
		jsr init_snake

loop:
		jsr wait
		jmp loop

//------------------------------------------------------------------------
// INIT SUBROUTINES

empty_screen:
		ldx #$fa							// 250 byte chunks
		// fill screen with spaces
!:		lda #CHAR_SPACE
		sta SCREEN_TOP_LEFT_ADDR-1, x
		sta SCREEN_TOP_LEFT_ADDR+249, x
		sta SCREEN_TOP_LEFT_ADDR+499, x
		sta SCREEN_TOP_LEFT_ADDR+749, x
		// fill screen char color ram with green
		lda #$05
		sta SCREEN_TOP_LEFT_COLOR_ADDR-1, x
		sta SCREEN_TOP_LEFT_COLOR_ADDR+249, x
		sta SCREEN_TOP_LEFT_COLOR_ADDR+499, x
		sta SCREEN_TOP_LEFT_COLOR_ADDR+749, x
		dex
		bne !-
		lda #$00
		sta BORDER_COLOR_ADDR
		lda #$00
		sta BG_COLOR_ADDR
		rts

init_snake:
		lda #$ff
		sta snake_head_ptr
		sta snake_tail_ptr
		lda #$27
		sta snake_head_ptr+1
		sta snake_tail_ptr+1
		lda #$00
		sta SNAKE_SCREEN_PTR_END_ADDR
		lda #$05
		sta SNAKE_SCREEN_PTR_END_ADDR-1

		lda #$57
		sta SCREEN_TOP_LEFT_ADDR
		lda #$57
		sta SCREEN_TOP_LEFT_ADDR+1
		lda #$57
		sta SCREEN_TOP_LEFT_ADDR+2
		lda #$51
		sta SCREEN_TOP_LEFT_ADDR+3
		rts

//------------------------------------------------------------------------
// LOOP SUBROUTINES

wait:
		lda RASTER_LINE_ADDR
		cmp #$fb
		beq wait
!:		lda RASTER_LINE_ADDR
		cmp #$fb
		bne !-
		rts

//------------------------------------------------------------------------
// DATA

*= $2800 "Generic data"
BasicUpstart2(init)

		*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const CHAR_SPACE					= $20
		.const RASTER_LINE_ADDR				= $d012
		.const SCREEN_BOTTOM_LEFT_ADDR 		= $07c0
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const SCREEN_TOP_LEFT_COLOR_ADDR 	= $d800
		.const STATUS_COLOR					= $05
		.const STATUS_OFF_CHAR				= $20
		.const STATUS_ON_CHAR		 		= $51
		.const STATUS_LOC_ADDR 				= $0400
		.const STATUS_BLINK_SPEED 			= $3c

		.var temp_addr						= $fb

init:
		jsr empty_screen
		jsr init_status

loop:
		jsr wait
		jsr draw_status
		jmp loop

//------------------------------------------------------------------------
// LOOP SUBROUTINES

wait:
		lda #STATUS_BLINK_SPEED
		sta temp_addr
!:		lda RASTER_LINE_ADDR
		cmp #$ff
		bne !-
		dec temp_addr
		bne !-
		rts

draw_status:
		lda STATUS_LOC_ADDR
		cmp #STATUS_ON_CHAR
		bne !+
		lda #STATUS_OFF_CHAR
		jmp !++
!:		lda #STATUS_ON_CHAR
!:		sta STATUS_LOC_ADDR
		rts

//------------------------------------------------------------------------
// INIT SUBROUTINES

empty_screen:
		lda #CHAR_SPACE
		ldx #$fa							// 250 byte chunks
!:		sta SCREEN_TOP_LEFT_ADDR-1, x
		sta SCREEN_TOP_LEFT_ADDR+249, x
		sta SCREEN_TOP_LEFT_ADDR+499, x
		sta SCREEN_TOP_LEFT_ADDR+749, x
		dex
		bne !-
		rts

init_status:
		lda #$00
		sta BORDER_COLOR_ADDR
		sta BG_COLOR_ADDR
		lda #STATUS_ON_CHAR
		sta STATUS_LOC_ADDR
		lda #STATUS_COLOR
		sta SCREEN_TOP_LEFT_COLOR_ADDR
		rts
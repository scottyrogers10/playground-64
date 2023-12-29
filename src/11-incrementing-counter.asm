BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR				= $d020
		.const BG_COLOR_ADDR					= $d021
		.const SCREEN_TOP_LEFT_ADDR 			= $0400
		.const SCREEN_TOP_LEFT_COLOR_ADDR 		= $d800
		.const RASTER_LINE_ADDR					= $d012

		.const CHAR_SPACE						= $20
		.const CHAR_0							= $30

		.var tmp_ptr							= $02

init:
		sei
		jsr empty_screen
		jsr init_score

loop:
		jsr wait
		jsr update_score
		jmp loop

//------------------------------------------------------------------------
// LOOP SUBROUTINES

wait:
		lda RASTER_LINE_ADDR
		cmp #$fb
		beq wait
	!:	lda RASTER_LINE_ADDR
		cmp #$fb
		bne !-
		rts

update_score:
		// ones
		inc SCREEN_TOP_LEFT_ADDR+22
		lda SCREEN_TOP_LEFT_ADDR+22
		cmp #$3a
		bne done
		lda #CHAR_0
		sta SCREEN_TOP_LEFT_ADDR+22
		// tens
		inc SCREEN_TOP_LEFT_ADDR+21
		lda SCREEN_TOP_LEFT_ADDR+21
		cmp #$3a
		bne done
		lda #CHAR_0
		sta SCREEN_TOP_LEFT_ADDR+21
		// hundreds
		inc SCREEN_TOP_LEFT_ADDR+20
		lda SCREEN_TOP_LEFT_ADDR+20
		cmp #$3a
		bne done
		lda #CHAR_0
		sta SCREEN_TOP_LEFT_ADDR+20
		// thousands
		inc SCREEN_TOP_LEFT_ADDR+19
		lda SCREEN_TOP_LEFT_ADDR+19
		cmp #$3a
		bne done
		lda #CHAR_0
		sta SCREEN_TOP_LEFT_ADDR+19
		// ten thousands
		inc SCREEN_TOP_LEFT_ADDR+18
		lda SCREEN_TOP_LEFT_ADDR+18
		cmp #$3a
		bne done
		lda #CHAR_0
		sta SCREEN_TOP_LEFT_ADDR+18
		// hundred thousands
		inc SCREEN_TOP_LEFT_ADDR+17
		lda SCREEN_TOP_LEFT_ADDR+17
		cmp #$3a
		bne done
		lda #CHAR_0
		sta SCREEN_TOP_LEFT_ADDR+17
	done:
		rts

//------------------------------------------------------------------------
// INIT SUBROUTINES

empty_screen:
		ldx #$fa								// 250 byte chunks
		// fill screen with spaces
	!:	lda #CHAR_SPACE
		sta SCREEN_TOP_LEFT_ADDR-1, x
		sta SCREEN_TOP_LEFT_ADDR+249, x
		sta SCREEN_TOP_LEFT_ADDR+499, x
		sta SCREEN_TOP_LEFT_ADDR+749, x
		// fill screen char color ram with white
		lda #$01
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

init_score:
		lda #CHAR_0
		sta SCREEN_TOP_LEFT_ADDR+17
		sta SCREEN_TOP_LEFT_ADDR+18
		sta SCREEN_TOP_LEFT_ADDR+19
		sta SCREEN_TOP_LEFT_ADDR+20
		sta SCREEN_TOP_LEFT_ADDR+21
		sta SCREEN_TOP_LEFT_ADDR+22
		rts

//------------------------------------------------------------------------
// DATA

*= $2000 "Generic data"

score:
		.byte $00, $00
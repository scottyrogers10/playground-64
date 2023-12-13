BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const SPRITE_COLOR_ADDR			= $d027
		.const SPRITE_POINTER_ADDR			= $07f8
		.const SPRITE_X_POS_ADDR			= $d000
		.const SPRITE_Y_POS_ADDR			= $d001
		.const RASTER_LINE_ADDR				= $d012

		.const CHAR_SPACE					= $20
		.const LOOP_SPEED 					= $01

		.var temp_pointer					= $fb

init:
		jsr empty_screen
		jsr init_sprite_0

loop:
		jsr wait
		jsr draw
		jmp loop

//------------------------------------------------------------------------
// LOOP SUBROUTINES

wait:
		ldx #LOOP_SPEED
!:		lda RASTER_LINE_ADDR
		cmp #$ff
		bne !-
		dex
		cpx #$ff
		bne !-
		rts

draw:
		lda SPRITE_Y_POS_ADDR
		sec
		sbc #$01
		sta SPRITE_Y_POS_ADDR
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
		lda #$0b
		sta BORDER_COLOR_ADDR
		lda #$00
		sta BG_COLOR_ADDR
		rts

init_sprite_0:
		lda #$80							// #$80 x #$40 = #$2000 (sprite data)
		sta SPRITE_POINTER_ADDR
		lda #$ab
		sta SPRITE_X_POS_ADDR
		lda #$e8
		sta SPRITE_Y_POS_ADDR
		lda #$03
		sta SPRITE_COLOR_ADDR
		lda #%00000001
		sta $d015							// enable sprite 0
		rts

//------------------------------------------------------------------------
// DATA

*= $2000 "Sprite data"
sprite_0:
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$18,$00,$00
		.byte $3c,$00,$00,$7e,$00,$00,$db,$00
		.byte $00,$db,$00,$00,$99,$00,$04,$bd
		.byte $20,$0c,$3c,$30,$0c,$76,$30,$0d
		.byte $7e,$b0,$0f,$f7,$f0,$0d,$7e,$b0
		.byte $0c,$76,$30,$04,$3c,$20,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$04
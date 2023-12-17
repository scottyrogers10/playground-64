BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const SPRITE_COLOR_ADDR			= $d027
		.const SPRITE_POINTER_ADDR			= $07f8
		.const SPRITE_X_OVERFLOW_ADDR		= $d010
		.const SPRITE_X_POS_ADDR			= $d000
		.const SPRITE_Y_POS_ADDR			= $d001
		.const RASTER_LINE_ADDR				= $d012

		.const BORDER_BOTTOM				= $e5
		.const BORDER_LEFT					= $18
		.const BORDER_RIGHT					= $51
		.const BORDER_TOP					= $22
		.const CHAR_SPACE					= $20
		.const SPEED 						= $01

		.var temp_pointer					= $fb

init:
		sei
		jsr empty_screen
		jsr init_sprite_0

loop:
		jsr wait
		jsr collision_detection
		jsr update_y_position
		jsr update_x_position
		jmp loop

//------------------------------------------------------------------------
// LOOP SUBROUTINES

wait:
		lda RASTER_LINE_ADDR
		cmp #$f8
		beq wait
!:		lda RASTER_LINE_ADDR
		cmp #$f8
		bne !-
		rts

collision_detection: {
	collision_bottom:
		lda SPRITE_Y_POS_ADDR
		cmp #BORDER_BOTTOM
		bcc collision_top
		lda #$00
		sta sprite_y_dir
	collision_top:
		lda SPRITE_Y_POS_ADDR
		cmp #BORDER_TOP
		bcs collision_left
		lda #$01
		sta sprite_y_dir
	collision_left:
		lda SPRITE_X_OVERFLOW_ADDR
		and #%00000001
		bne collision_right
		lda SPRITE_X_POS_ADDR
		cmp #BORDER_LEFT
		bcs !+
		lda #$01
		sta sprite_x_dir
		jmp !+
	collision_right:
		lda SPRITE_X_POS_ADDR
		cmp #BORDER_RIGHT
		bcc !+
		lda #$00
		sta sprite_x_dir
!:		rts
}

update_y_position: {
		lda sprite_y_dir
		beq move_up
		lda SPRITE_Y_POS_ADDR
		clc
		adc #SPEED
		sta SPRITE_Y_POS_ADDR
		rts
	move_up:
		lda SPRITE_Y_POS_ADDR
		sec
		sbc #SPEED
		sta SPRITE_Y_POS_ADDR
		rts
}

update_x_position: {
		lda sprite_x_dir
		beq move_left
		lda SPRITE_X_POS_ADDR
		clc
		adc #SPEED
		sta SPRITE_X_POS_ADDR
		bcc !+
		lda #$01
		sta SPRITE_X_OVERFLOW_ADDR
!:		rts
	move_left:
		lda SPRITE_X_POS_ADDR
		sec
		sbc #SPEED
		sta SPRITE_X_POS_ADDR
		bcs !+
		lda #$00
		sta SPRITE_X_OVERFLOW_ADDR
!:		rts
}

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
		lda #$0f
		sta BORDER_COLOR_ADDR
		lda #$00
		sta BG_COLOR_ADDR
		rts

init_sprite_0:
		lda #$80							// #$80 x #$40 = #$2000 (sprite data)
		sta SPRITE_POINTER_ADDR
		lda #$01
		sta SPRITE_X_OVERFLOW_ADDR
		lda #BORDER_RIGHT
		sta SPRITE_X_POS_ADDR
		lda #BORDER_TOP
		sta SPRITE_Y_POS_ADDR
		lda #$01
		sta SPRITE_COLOR_ADDR
		lda #%00000001
		sta $d015							// enable sprite 0
		rts

//------------------------------------------------------------------------
// DATA

*= $2000 "Sprite data"
sprite_0:
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $7c,$00,$00,$fe,$00,$00,$fe,$00
		.byte $00,$fe,$00,$00,$7c,$00,$00,$01

sprite_x_dir:
		.byte $00							// 0 = left, 1 = right

sprite_y_dir:
		.byte $00							// 0 = up, 1 = down
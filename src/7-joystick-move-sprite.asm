BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const JOYSTICK_2_ADDR				= $dc00
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const SPRITE_COLOR_ADDR			= $d027
		.const SPRITE_POINTER_ADDR			= $07f8
		.const SPRITE_X_POS_ADDR			= $d000
		.const SPRITE_Y_POS_ADDR			= $d001
		.const RASTER_LINE_ADDR				= $d012

		.const BORDER_BOTTOM				= $e5
		.const BORDER_LEFT					= $18
		.const CHAR_SPACE					= $20

init:
		sei
		jsr empty_screen
		jsr init_sprite

loop:
		jsr wait
		jsr process_input
		jsr update_y_position
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

process_input: {
		lda #%00000001
		bit JOYSTICK_2_ADDR
		beq move_paddle_up
		lda #%00000010
		bit JOYSTICK_2_ADDR
		beq move_paddle_down
		lda #$00
		sta paddle_speed
		rts
	move_paddle_up:
		lda #$00
		sta paddle_y_dir
		jmp !+
	move_paddle_down:
		lda #$01
		sta paddle_y_dir
!:		lda #$02
		sta paddle_speed
		rts
}

update_y_position: {
		lda paddle_y_dir
		beq move_up
		lda SPRITE_Y_POS_ADDR
		clc
		adc paddle_speed
		sta SPRITE_Y_POS_ADDR
		rts
	move_up:
		lda SPRITE_Y_POS_ADDR
		sec
		sbc paddle_speed
		sta SPRITE_Y_POS_ADDR
		rts
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
		lda #$00
		sta BORDER_COLOR_ADDR
		lda #$00
		sta BG_COLOR_ADDR
		rts

init_sprite:
		lda #$80							// #$80 x #$40 = #$2000 (sprite data)
		sta SPRITE_POINTER_ADDR
		lda #BORDER_LEFT+5
		sta SPRITE_X_POS_ADDR
		lda #BORDER_BOTTOM / 2 + 21
		sta SPRITE_Y_POS_ADDR
		lda #$08
		sta SPRITE_COLOR_ADDR
		lda #%00000001
		sta $d015							// enable sprite 0
		rts

//------------------------------------------------------------------------
// DATA

*= $2000 "Sprite data"
sprite_paddle:
		.byte $3e,$00,$00,$7f,$00,$00,$ff,$80
		.byte $00,$bf,$80,$00,$bf,$80,$00,$bf
		.byte $80,$00,$bf,$80,$00,$bf,$80,$00
		.byte $bf,$80,$00,$bf,$80,$00,$bf,$80
		.byte $00,$bf,$80,$00,$bf,$80,$00,$bf
		.byte $80,$00,$bf,$80,$00,$bf,$80,$00
		.byte $bf,$80,$00,$bf,$80,$00,$ff,$80
		.byte $00,$7f,$00,$00,$3e,$00,$00,$01

paddle_speed:
		.byte $00							// pixels to move per frame

paddle_y_dir:
		.byte $00							// 0 = up, 1 = down
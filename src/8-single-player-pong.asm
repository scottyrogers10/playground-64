BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const JOYSTICK_2_ADDR				= $dc00
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const SPRITE_0_COLOR_ADDR			= $d027
		.const SPRITE_0_POINTER_ADDR		= $07f8
		.const SPRITE_0_X_POS_ADDR			= $d000
		.const SPRITE_0_Y_POS_ADDR			= $d001
		.const SPRITE_ENABLE_ADDR			= $d015
		.const SPRITE_X_OVERFLOW_ADDR		= $d010
		.const RASTER_LINE_ADDR				= $d012

		.const BALL_HEIGHT					= $05
		.const BALL_WIDTH					= $07
		.const BALL_X_OFFSET				= $00
		.const BALL_Y_OFFSET				= $10
		.const BORDER_BOTTOM				= $fa
		.const BORDER_LEFT					= $18
		.const BORDER_RIGHT					= $58
		.const BORDER_TOP					= $32
		.const CHAR_SPACE					= $20
		.const PADDLE_HEIGHT				= $15
		.const PADDLE_WIDTH					= $09
		.const PADDLE_X_OFFSET				= $00
		.const PADDLE_Y_OFFSET				= $00

		.var temp_pointer					= $fb

init:
		sei
		jsr empty_screen
		jsr init_sprites

loop:
		jsr wait
		jsr process_input
		jsr collision_detection
		jsr update_ball_y_position
		jsr update_ball_x_position
		jsr update_paddle_position
		jmp loop

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
!:		lda #$04
		sta paddle_speed
		rts
}

collision_detection: {
	collision_bottom:
		lda SPRITE_0_Y_POS_ADDR+2
		cmp #BORDER_BOTTOM-(BALL_HEIGHT+BALL_Y_OFFSET)
		bcc collision_top
		lda #$00
		sta ball_y_dir
	collision_top:
		lda SPRITE_0_Y_POS_ADDR+2
		cmp #BORDER_TOP-BALL_Y_OFFSET
		bcs collision_left
		lda #$01
		sta ball_y_dir
	collision_left:
		lda SPRITE_X_OVERFLOW_ADDR
		and #%00000010
		bne collision_right
		lda SPRITE_0_X_POS_ADDR+2
		cmp #BORDER_LEFT
		bcs collision_paddle
		lda #$00
		sta ball_speed
		rts
	collision_right:
		lda SPRITE_0_X_POS_ADDR+2
		cmp #BORDER_RIGHT-BALL_WIDTH
		bcc !+
		lda #$00
		sta ball_x_dir
	collision_paddle:
		lda SPRITE_0_X_POS_ADDR+2
		cmp #BORDER_LEFT+PADDLE_WIDTH+1
		bcs !+
		lda SPRITE_0_Y_POS_ADDR+2
		clc
		adc #BALL_Y_OFFSET+BALL_HEIGHT
		cmp SPRITE_0_Y_POS_ADDR
		bcc !+
		lda SPRITE_0_Y_POS_ADDR
		clc
		adc #PADDLE_HEIGHT
		sta paddle_calc_y
		lda SPRITE_0_Y_POS_ADDR+2
		clc
		adc #BALL_Y_OFFSET
		cmp paddle_calc_y
		bcs !+
		lda #$01
		sta ball_x_dir
!:		rts
}

update_ball_y_position: {
		lda ball_y_dir
		beq move_up
		lda SPRITE_0_Y_POS_ADDR+2
		clc
		adc ball_speed
		sta SPRITE_0_Y_POS_ADDR+2
		rts
	move_up:
		lda SPRITE_0_Y_POS_ADDR+2
		sec
		sbc ball_speed
		sta SPRITE_0_Y_POS_ADDR+2
		rts
}

update_ball_x_position: {
		lda ball_x_dir
		beq move_left
		lda SPRITE_0_X_POS_ADDR+2
		clc
		adc ball_speed
		sta SPRITE_0_X_POS_ADDR+2
		bcc !+
		lda #%00000010
		sta SPRITE_X_OVERFLOW_ADDR
!:		rts
	move_left:
		lda SPRITE_0_X_POS_ADDR+2
		sec
		sbc ball_speed
		sta SPRITE_0_X_POS_ADDR+2
		bcs !+
		lda #%00000000
		sta SPRITE_X_OVERFLOW_ADDR
!:		rts
}

update_paddle_position: {
		lda paddle_y_dir
		beq move_up
		lda SPRITE_0_Y_POS_ADDR
		clc
		adc paddle_speed
		sta SPRITE_0_Y_POS_ADDR
		rts
	move_up:
		lda SPRITE_0_Y_POS_ADDR
		sec
		sbc paddle_speed
		sta SPRITE_0_Y_POS_ADDR
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
		lda #$06
		sta BORDER_COLOR_ADDR
		lda #$00
		sta BG_COLOR_ADDR
		rts

init_sprites:
		// sprite 0
		lda #$80							// #$80 x #$40 = #$2000 (sprite data)
		sta SPRITE_0_POINTER_ADDR
		lda #BORDER_LEFT+2
		sta SPRITE_0_X_POS_ADDR
		lda #(BORDER_BOTTOM/2)+(PADDLE_HEIGHT/2)
		sta SPRITE_0_Y_POS_ADDR
		lda #$08
		sta SPRITE_0_COLOR_ADDR
		//sprite 1
		lda #$81							// #$81 x #$40 = #$2040 (sprite data)
		sta SPRITE_0_POINTER_ADDR+1
		lda #%00000010
		sta SPRITE_X_OVERFLOW_ADDR
		lda #BORDER_RIGHT-BALL_WIDTH
		sta SPRITE_0_X_POS_ADDR+2
		lda #BORDER_TOP-BALL_Y_OFFSET
		sta SPRITE_0_Y_POS_ADDR+2
		lda #$01
		sta SPRITE_0_COLOR_ADDR+1
		//enable sprites
		lda #%00000011
		sta SPRITE_ENABLE_ADDR
		rts

//------------------------------------------------------------------------
// DATA

*= $2000 "Sprite data"
sprite_0:
		.byte $3e,$00,$00,$7f,$00,$00,$ff,$80
		.byte $00,$bf,$80,$00,$bf,$80,$00,$bf
		.byte $80,$00,$bf,$80,$00,$bf,$80,$00
		.byte $bf,$80,$00,$bf,$80,$00,$bf,$80
		.byte $00,$bf,$80,$00,$bf,$80,$00,$bf
		.byte $80,$00,$bf,$80,$00,$bf,$80,$00
		.byte $bf,$80,$00,$bf,$80,$00,$ff,$80
		.byte $00,$7f,$00,$00,$3e,$00,$00,$01

sprite_1:
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $7c,$00,$00,$fe,$00,$00,$fe,$00
		.byte $00,$fe,$00,$00,$7c,$00,$00,$01

ball_speed:
		.byte $03							// pixels to move per frame

ball_x_dir:
		.byte $00							// 0 = left, 1 = right

ball_y_dir:
		.byte $00							// 0 = up, 1 = down

paddle_speed:
		.byte $00							// pixels to move per frame

paddle_y_dir:
		.byte $00							// 0 = up, 1 = down

paddle_calc_y:
		.byte $00							// store calculated paddle position


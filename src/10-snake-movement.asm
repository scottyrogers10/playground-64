BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR					= $d020
		.const BG_COLOR_ADDR						= $d021
		.const JOYSTICK_2_ADDR						= $dc00
		.const SCREEN_TOP_LEFT_ADDR 				= $0400
		.const SCREEN_TOP_LEFT_COLOR_ADDR 			= $d800
		.const RASTER_LINE_ADDR						= $d012
		.const SNAKE_SCREEN_PTR_TBL_START_ADDR		= $2000
		.const SNAKE_SCREEN_PTR_TBL_END_ADDR		= $27ff

		.const CHAR_SPACE							= $20
		.const CHAR_FILLED_CIRCLE					= $51
		.const CHAR_OUTLINE_CIRCLE					= $57

		.const SNAKE_SPEED							= $0a

		.var snake_head_dbl_ptr						= $fb
		.var snake_head_screen_ptr					= $02
		.var snake_tail_dbl_ptr						= $fd
		.var snake_tail_screen_ptr					= $04
		.var temp_ptr								= $06

init:
		sei
		jsr empty_screen
		jsr init_snake

loop:
		jsr wait
		jsr process_input
		jsr update_position
		jsr draw
		jmp loop

//------------------------------------------------------------------------
// LOOP SUBROUTINES

wait:
		ldx #SNAKE_SPEED
		lda RASTER_LINE_ADDR
		cmp #$fb
		beq wait
	!:	lda RASTER_LINE_ADDR
		cmp #$fb
		bne !-
		dex
		bne !-
		rts

process_input: {
		// up
		lda #%00000001
		bit JOYSTICK_2_ADDR
		beq set_snake_dir
		// down
		lda #%00000010
		bit JOYSTICK_2_ADDR
		beq set_snake_dir
		// left
		lda #%00000100
		bit JOYSTICK_2_ADDR
		beq set_snake_dir
		// right
		lda #%00001000
		bit JOYSTICK_2_ADDR
		beq set_snake_dir
		jmp end
	set_snake_dir:
		sta snake_dir
	end:
		rts
}

update_position: {
		lda snake_dir
		lsr
		beq move_up
		lsr
		beq move_down
		lsr
		beq move_left
		lsr
		beq move_right
	move_up:
		lda snake_head_screen_ptr
		sec
		sbc #$28
		sta snake_head_screen_ptr
		bcs end
		lda snake_head_screen_ptr+1
		sbc #$00
		sta snake_head_screen_ptr+1
		jmp end
	move_down:
		lda snake_head_screen_ptr
		clc
		adc #$28
		sta snake_head_screen_ptr
		bcc end
		lda snake_head_screen_ptr+1
		adc #$00
		sta snake_head_screen_ptr+1
		jmp end
	move_left:
		lda snake_head_screen_ptr
		sec
		sbc #$01
		sta snake_head_screen_ptr
		bcs end
		lda snake_head_screen_ptr+1
		sbc #$00
		sta snake_head_screen_ptr+1
		jmp end
	move_right:
		lda snake_head_screen_ptr
		clc
		adc #$01
		sta snake_head_screen_ptr
		bcc end
		lda snake_head_screen_ptr+1
		adc #$00
		sta snake_head_screen_ptr+1
	end:
		rts
}

draw:
		//clear tail
		ldy #$00
		lda #CHAR_SPACE
		sta (snake_tail_screen_ptr), y
		// draw body on previous position
		lda (snake_head_dbl_ptr), y
		sta temp_ptr
		iny
		lda (snake_head_dbl_ptr), y
		sta temp_ptr+1
		lda #CHAR_OUTLINE_CIRCLE
		ldy #$00
		sta (temp_ptr), y
		// draw new position
		lda #CHAR_FILLED_CIRCLE
		sta (snake_head_screen_ptr), y
		// update head ptr table and dbl ptr
		inc snake_head_dbl_ptr
		inc snake_head_dbl_ptr
		bne !+
		inc snake_head_dbl_ptr+1
	!:	lda snake_head_screen_ptr
		sta (snake_head_dbl_ptr), y
		lda snake_head_screen_ptr+1
		iny
		sta (snake_head_dbl_ptr), y
		// update tail ptr table and dbl ptr
		inc snake_tail_dbl_ptr
		inc snake_tail_dbl_ptr
		bne !+
		inc snake_tail_dbl_ptr+1
	!:	ldy #$00
		lda (snake_tail_dbl_ptr), y
		sta snake_tail_screen_ptr
		iny
		lda (snake_tail_dbl_ptr), y
		sta snake_tail_screen_ptr+1
		rts

//------------------------------------------------------------------------
// INIT SUBROUTINES

empty_screen:
		ldx #$fa									// 250 byte chunks
		// fill screen with spaces
	!:	lda #CHAR_SPACE
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
		lda #<[SNAKE_SCREEN_PTR_TBL_START_ADDR+10]
		sta snake_head_dbl_ptr
		lda #>[SNAKE_SCREEN_PTR_TBL_START_ADDR+10]
		sta snake_head_dbl_ptr+1
		lda #<SNAKE_SCREEN_PTR_TBL_START_ADDR
		sta snake_tail_dbl_ptr
		lda #>SNAKE_SCREEN_PTR_TBL_START_ADDR
		sta snake_tail_dbl_ptr+1
		ldx #$05
		stx snake_head_screen_ptr
		stx snake_head_screen_ptr+1
		stx snake_tail_screen_ptr+1
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+11
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+10
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+9
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+7
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+5
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+3
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+1
		dex
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+8
		dex
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+6
		dex
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+4
		dex
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR+2
		dex
		stx SNAKE_SCREEN_PTR_TBL_START_ADDR
		stx snake_tail_screen_ptr
		//draw body
	  	ldx #$05
		ldy #$00
		stx temp_ptr+1
		lda #CHAR_OUTLINE_CIRCLE
	!:	dex
		stx temp_ptr
		sta (temp_ptr), y
		bne !-
		// draw head
		lda #CHAR_FILLED_CIRCLE
		sta (snake_head_screen_ptr), y
		rts

//------------------------------------------------------------------------
// DATA

*= $2800 "Generic data"

snake_dir:
		.byte %00001000		// bit #0 = up, bit #1 = down, bit #2 = left, bit #3 = right
//------------------------------------------------------------------------
// Randomly select a screen location, on selection highlight and set char,
// on next selection remove highlight. Keep going until the entire screen
// is filled.
//
// + Randomly select a screen location from $0400 - $07e7
// + Change color of previous location.
// + Fill current location with active color.
// + Set current location as previous location at pointer temp var.
//------------------------------------------------------------------------

BasicUpstart2(init)

		*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const RASTER_LINE_ADDR				= $d012
		.const RAND_VAL_ADDR				= $d41b

		.const CHAR_FILL		 			= $d0
		.const CHAR_SPACE					= $20
		.const LOOP_SPEED 					= $40
		.const ACTIVE_COLOR					= $06
		.const INACTIVE_COLOR				= $0b
		.const HI_BYTE_COLOR_RAM_OFFSET 	= $d4

		.var prev_loc_pointer				= $fd
		.var temp_pointer					= $fb

init:
		jsr empty_screen
		jsr init_sid_rand

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
		cpx #$00
		bne !-
		rts

draw:
		lda prev_loc_pointer
		sta temp_pointer
		lda prev_loc_pointer+1
		clc
		adc #HI_BYTE_COLOR_RAM_OFFSET
		sta temp_pointer+1
		lda #INACTIVE_COLOR
		ldy #$00
		sta (temp_pointer), y				// change color of prev loc to inactive
		lda RAND_VAL_ADDR
		and #%00000111						// val $07 or less
		cmp #$04							// val greater or equal to $04
		bcs !+
		adc #$04							// if less than $04 add $04
!:		sta temp_pointer+1
		sta prev_loc_pointer+1
		cmp #$07
		bne !+
		lda RAND_VAL_ADDR					// if page is $07 then check to make sure we stay in screen memory ($07e7)
		cmp #$e8
		bcc !++
		and #%11100111
		jmp !++
!:		lda RAND_VAL_ADDR
!:		sta temp_pointer
		sta prev_loc_pointer
		lda #CHAR_FILL
		ldy #$00
		sta (temp_pointer), y
		lda temp_pointer+1
		clc
		adc #HI_BYTE_COLOR_RAM_OFFSET
		sta temp_pointer+1
		lda #ACTIVE_COLOR
		ldy #$00
		sta (temp_pointer), y				// change color of curr loc to active
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
		lda #$00							// set border and background color to black (#$00)
		sta BORDER_COLOR_ADDR
		sta BG_COLOR_ADDR
		sta prev_loc_pointer				// init prev loc to $0400
		lda #$04
		sta prev_loc_pointer+1
		rts

init_sid_rand:
		lda #$ff							// max freq val
		sta $d40e							// sids voice 3 low byte
		sta $d40f							// sids voice 4 high byte
		lda #$80
		sta $d412							// sids voice 3 control register
		rts
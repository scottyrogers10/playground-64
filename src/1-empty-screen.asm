BasicUpstart2(init)

		*= $c000 "Init"

		.const CHAR_SPACE 				= $20
		.const SCREEN_TOP_LEFT_ADDR 	= $0400

init:
		lda #CHAR_SPACE
		ldx #$fa							// 250 byte chunks
!:		sta SCREEN_TOP_LEFT_ADDR-1, x
		sta SCREEN_TOP_LEFT_ADDR+249, x
		sta SCREEN_TOP_LEFT_ADDR+499, x
		sta SCREEN_TOP_LEFT_ADDR+749, x
		dex
		bne !-

loop:
		jmp loop
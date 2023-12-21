BasicUpstart2(init)
*= $c000 "Init"

		.const BORDER_COLOR_ADDR			= $d020
		.const BG_COLOR_ADDR				= $d021
		.const SCREEN_TOP_LEFT_ADDR 		= $0400
		.const SPRITE_COLOR_ADDR			= $d027
		.const SPRITE_MULTICOLOR_ADDR		= $d01c
		.const SPRITE_EXTRA_COLOR_1_ADDR	= $d025
		.const SPRITE_EXTRA_COLOR_2_ADDR	= $d026
		.const SPRITE_POINTER_ADDR			= $07f8
		.const SPRITE_X_POS_ADDR			= $d000
		.const SPRITE_Y_POS_ADDR			= $d001
		.const SPRITE_ENABLE_ADDR			= $d015
		.const RASTER_LINE_ADDR				= $d012

		.const ANIMATION_FRAMES				= $04
		.const ANIMATION_SPEED				= $09
		.const BORDER_BOTTOM				= $fa
		.const BORDER_LEFT					= $18
		.const BORDER_RIGHT					= $58
		.const BORDER_TOP					= $32
		.const CHAR_SPACE					= $20
		.const SPRITE_HEIGHT				= $0d
		.const SPRITE_WIDTH					= $0a

		.var temp_pointer					= $fb

init:
		sei
		jsr empty_screen
		jsr init_sprite

loop:
		jsr wait
		jsr animate_sprite
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

animate_sprite:
		lda animation_delay
		cmp #$00
		bne !+
		// reset animation delay
		lda #ANIMATION_SPEED
		sta animation_delay
		// animate next frame
		ldx current_frame
		lda frames, x
		sta SPRITE_POINTER_ADDR
		lda frames_height, x
		sta SPRITE_Y_POS_ADDR
		inx
		stx current_frame
		cpx #ANIMATION_FRAMES
		bne !+
		// reset animation frame index
		ldx #$00
		stx current_frame
!:		dec animation_delay
		rts

//------------------------------------------------------------------------
// INIT SUBROUTINES

empty_screen:
		lda #CHAR_SPACE
		ldx #$fa										// 250 byte chunks
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

init_sprite:
		// sprite 0 screen position (x,y)
		lda #$81										// #$81 x #$40 = #$2040 (sprite data)
		sta SPRITE_POINTER_ADDR
		lda #BORDER_LEFT+100
		sta SPRITE_X_POS_ADDR
		lda #BORDER_BOTTOM-100
		sta SPRITE_Y_POS_ADDR
		// sprite 0 turn on multicolor
		lda #%00000001
		sta SPRITE_MULTICOLOR_ADDR
		// sprite multicolor 1
		lda #$02
		sta SPRITE_EXTRA_COLOR_1_ADDR
		// sprite multicolor 2
		lda #$01
		sta SPRITE_EXTRA_COLOR_2_ADDR
		// sprite 0 color
		lda #$06
		sta SPRITE_COLOR_ADDR
		//enable sprite 0
		lda #%00000001
		sta SPRITE_ENABLE_ADDR
		rts

//------------------------------------------------------------------------
// DATA

*= $2000 "Sprite data"
sprite_downflap:
		.byte $00,$a8,$00,$02,$af,$00,$0a,$bf
		.byte $c0,$0a,$bc,$c0,$2a,$bc,$c0,$2a
		.byte $bc,$c0,$2a,$af,$c0,$2a,$a5,$50
		.byte $ff,$d5,$50,$ff,$55,$40,$fe,$aa
		.byte $80,$fa,$aa,$00,$ca,$a0,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$86

sprite_midflap:
		.byte $00,$a8,$00,$02,$af,$00,$0a,$bf
		.byte $c0,$0a,$bc,$c0,$2a,$bc,$c0,$2a
		.byte $bc,$c0,$2a,$af,$c0,$2a,$a5,$50
		.byte $ff,$d5,$50,$ff,$55,$40,$2a,$aa
		.byte $80,$2a,$aa,$00,$0a,$a0,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$86

sprite_upflap:
		.byte $00,$a8,$00,$02,$af,$00,$0a,$bf
		.byte $c0,$0a,$bc,$c0,$2a,$bc,$c0,$2a
		.byte $bc,$c0,$ff,$af,$c0,$ff,$e5,$50
		.byte $ff,$d5,$50,$ff,$55,$40,$3f,$aa
		.byte $80,$2a,$aa,$00,$0a,$a0,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$86

animation_delay:
		.byte ANIMATION_SPEED

current_frame:
		.byte $00

frames:
		.byte $80, $81, $82, $81

frames_height:
		.byte BORDER_BOTTOM-100, BORDER_BOTTOM-94, BORDER_BOTTOM-100, BORDER_BOTTOM-98
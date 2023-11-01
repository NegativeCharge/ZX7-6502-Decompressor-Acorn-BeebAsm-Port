; vim: set ft=a65:ts=4:et

; ZX7 decompressor based on
; ZX7 data decompressor for Apple II
; by Peter Ferrie (peter.ferrie@gmail.com)
;

.dzx7_unpack
	lda #0
	sta	last
	sta	ecx
	sta	ecx+1

.dzx7s_copy_byte_loop:
	jsr	getput

.dzx7s_main_loop:
	jsr	dzx7s_next_bit
	bcc	dzx7s_copy_byte_loop
	ldy	#0

.dzx7s_len_size_loop:
	iny
	jsr	dzx7s_next_bit
	bcc	dzx7s_len_size_loop
	jmp	dzx7s_len_value_skip

.dzx7s_next_bit:
	asl	last
	bne	dzx7s_next_bit_ret
	jsr	getsrc
	sec
	rol a
	sta	last

.dzx7s_next_bit_ret:
	rts

.dzx7s_len_value_loop:
	jsr	dzx7s_next_bit

.dzx7s_len_value_skip:
	rol	ecx
	rol	ecx+1
	bcs	dzx7s_next_bit_ret
	dey
	bne	dzx7s_len_value_loop
	inc	ecx
	bne	skip_inc_ecx
	inc	ecx+1
.skip_inc_ecx
	jsr	getsrc
	rol a
	sta	tmp
	tya
	bcc	dzx7s_offset_end
	lda	#$10

.dzx7s_rld_next_bit
	pha
	jsr	dzx7s_next_bit
	pla
	rol a
	bcc	dzx7s_rld_next_bit
	clc
	adc #1
	lsr a

.dzx7s_offset_end
	sta	tmp+1
	ror	tmp
	ldx	src+1
	ldy	src
	lda	dst
	sbc	tmp
	sta	src
	lda	dst+1
	sbc	tmp+1
	sta	src+1
.another_getput
	jsr	getput
	jsr	dececx
	ora	ecx+1
	bne	another_getput
	sty	src
	stx	src+1
	jmp	dzx7s_main_loop

.dececx
	lda	ecx
	bne	skip_ecx_dec
	dec	ecx+1
.skip_ecx_dec
	sec
	sbc #1
	sta	ecx
	rts

.getput
	jsr	getsrc

.putdst
	sty tmpy
	ldy #0
	sta	(dst), y
	ldy tmpy
	inc	dst
	bne	skip_inc_dst
	inc	dst+1
.skip_inc_dst
	rts

.getsrc
	sty tmpy
	ldy #0
	lda	(src), y
	ldy tmpy
	inc	src
	bne	skip_inc_src
	inc	src+1
.skip_inc_src
	rts
  
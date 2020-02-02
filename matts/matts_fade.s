	IFND	MATTS_FADE_S
MATTS_FADE_S SET	1

;
; Fade_Control :	A call to Fade_Control every verticle blank will
; 			assure that all fading is automatic and smooth
;			Initially set to fade in, when finished will
;			setup for a fade out and wait for the signal bit
;			to be cleared before commencing the fade out
;
; Fade_Wait :		Waits until the current fade either in or out has
;			been completed
; Fade_In :		Code for the fade in
;
; Fade Out :		Code for the fade out command
;			In all cases will fade to black
;
;			 .---------- (1) Signal Complete
;			 |.---------
;			 ||.--------
;			 |||.-------
;			 ||||.------
;			 |||||.-----
;			 ||||||.---- (0) Fade Setup Needed
;			 |||||||.--- (1) Fade OUT -/- (0) Fade IN
;			 ||||||||
Fade_Flag:	DC.B	%10000000,0
Fade_In_Mask:	DC.L	$FFFFFFFF	; mask for colors to fade in
Fade_Out_Mask:	DC.L	$FFFFFFFF	; mask for colors to fade out
Fade_Colours:	DC.L	0		; location of colours to fade
Fade_Number:	DC.W	0		; amount of colours to fade
Fade_Speed:	DC.W	1		; speed of fade
Fade_Cnt:	DC.W	0		; a counter for use with fade speed
Fade_Count:	DC.W	0		; a general counter
Fade_Cols:	DS.W	32

_Fade_Wait:	; wait for a fade to complete
 IFND	debug
	btst	#6,$BFE001
	beq.s	Fade_Wait_Exit
	btst	#7,Fade_Flag-PC(a5)
	beq.s	Fade_Wait
Fade_Wait_Exit:
 ENDC
	rts

_Fade_Control:	; controller for use by the vertical blank interrupt
	push	a5
	lea	PC(pc),a5
	btst	#7,Fade_Flag-PC(a5)	; test if fade complete
	bne	Fade_Control_Complete

	addq.w	#1,Fade_Cnt-PC(a5)
	move.w	Fade_Speed-PC(a5),d0
	addq.w	#1,d0
	move.w	Fade_Cnt-PC(a5),d1
	divu	d0,d1
	tst.w	d1
	beq	Fade_Control_Complete
	clr.w	Fade_Cnt-PC(a5)
	
	btst	#0,Fade_Flag-PC(a5)	; if set to fade in
	bne	Fade_Not_In
	btst	#1,Fade_Flag-PC(a5)
	bne.s	.not_fade_in_setup
;	move.l	Fade_Colours-PC(a5),a0	; copy new colours to buffer
;	lea	Fade_Cols-PC(a5),a1
;;	lea	Copper_Colours-PC(a5),a2
;	move.w	(a0)+,d7
;;	divu	#32,d7
;;	clr.w	d7
;;	swap	d7
;;	move.w	d7,Fade_Number-PC(a5)
;	bra.s	.1
;.fade_in_setup_loop
;	move.w	(a0)+,(a1)+
;;	clr.w	2(a2)
;;	addq.w	#4,a2
;.1
;	dbra	d7,.fade_in_setup_loop
	bset	#1,Fade_Flag-PC(a5)
.not_fade_in_setup
	bsr	Fade_In
	bra	Fade_Count_Change
Fade_Not_In:

;	btst	#0,Fade_Flag-PC(a5)	; if set to fade out
;	beq	Fade_Not_Out
	btst	#1,Fade_Flag-PC(a5)
	bne.s	.not_fade_out_setup

;	move.l	Fade_Colours-PC(a5),a0	; copy colours to copper
;	lea	Fade_Cols-PC(a5),a1
;	lea	Copper_Colours-PC(a5),a2
;	move.w	(a0)+,d7
;	divu	#32,d7
;	clr.w	d7
;	swap	d7
;	move.w	d7,Fade_Number-PC(a5)
;	bra.s	.1
;.fade_in_setup_loop
;	move.w	(a1)+,2(a2)
;	clr.w	(a0)+
;	addq.w	#4,a2
;.1
;	dbra	d7,.fade_in_setup_loop

	bset	#1,Fade_Flag-PC(a5)
.not_fade_out_setup
	bsr	Fade_Out
	bra	Fade_Count_Change
Fade_Not_Out:
Fade_Count_Change:
	addq.w	#1,Fade_Count-PC(a5)
	cmp.w	#16,Fade_Count-PC(a5)
	bls.s	.fade_not_complete
	bset	#7,Fade_Flag-PC(a5)	; signal complete
	bchg	#0,Fade_Flag-PC(a5)	; auto change fadein to fadeout & vice versa
	bclr	#1,Fade_Flag-PC(a5)
	clr.w	Fade_Count-PC(a5)
.fade_not_complete

Fade_Control_Complete:
	pop	a5

	rts

Fade_In:
;	move.w	#FADE_SPEED,Fade_Speed-PC(a5)
;	moveq.l	#16,d6
;.fade_in_top
;	move.w	Fade_Speed-PC(a5),d7
;.1
;	cmp.b	#$e0,$DFF006
;	bne.s	.1
;	dbra	d7,.1

	lea	Copper_Colours-PC(a5),a0
	lea	Fade_Cols-PC(a5),a1
	move.w	Fade_Number-PC(a5),d7
	bra.s	.fade_loop_pass
.fade_loop
	move.w	2(a0),d0
	move.w	(a1)+,d2
	move.w	d0,d1
	andi.w	#$0F00,d1
	lsr.w	#8,d1
	move.w	d2,d3
	andi.w	#$0F00,d3
	lsr.w	#8,d3	
	cmp.w	d3,d1
	bhs.s	.red_ok
	addq.w	#1,d1
.red_ok
	lsl.w	#8,d1
	andi.w	#$00FF,d0
	or.w	d1,d0

	move.w	d0,d1
	andi.w	#$00F0,d1
	lsr.w	#4,d1
	move.w	d2,d3
	andi.w	#$00F0,d3
	lsr.w	#4,d3
	cmp.w	d3,d1
	bhs.s	.green_ok
	addq.w	#1,d1
.green_ok
	lsl.w	#4,d1
	andi.w	#$0F0F,d0
	or.w	d1,d0

	move.w	d0,d1
	andi.w	#$000F,d1
;	lsr.w	#0,d1
	move.w	d2,d3
	andi.w	#$000F,d3
;	lsr.w	#0,d3
	cmp.w	d3,d1
	bhs.s	.blue_ok
	addq.w	#1,d1
.blue_ok
;	lsl.w	#0,d1
	andi.w	#$0FF0,d0
	or.w	d1,d0
	move.l	Fade_In_Mask-PC(a5),d1
	btst	d7,d1
	beq.s	.fade_col_off
	move.w	d0,2(a0)
.fade_col_off
	addq.l	#4,a0
.fade_loop_pass
	dbra	d7,.fade_loop
;	subq.w	#1,d6
;	tst.w	d6
;	beq.s	.fade_end
;	btst	#7,$BFE001
;	bne.s	.fade_quick_skip
;	move.w	#FADE_FAST,Fade_Speed-PC(a5)
;.fade_quick_skip
;	bra	.fade_in_top
;.fade_end	
	rts

Fade_Out:
;	move.w	#FADE_SPEED,Fade_Speed-PC(a5)
;.fade_in_top
;	move.w	Fade_Speed-PC(a5),d7
;.1
;	cmp.b	#$e0,$DFF006
;	bne.s	.1
;	dbra	d7,.1
;	moveq.l	#0,d6			; or all cols to check when all $0000

	lea	Copper_Colours-PC(a5),a0
	lea	Fade_Cols-PC(a5),a1
	move.w	Fade_Number-PC(a5),d7
	bra.s	.fade_loop_pass
;	moveq.l	#SCREEN_COLOURS-1,d7
.fade_loop
	move.w	2(a0),d0
	move.w	d0,d1
	andi.w	#$0F00,d1
	lsr.w	#8,d1
	cmp.w	#0,d1
	beq.s	.red_ok
	subq.w	#1,d1
.red_ok
	lsl.w	#8,d1
	andi.w	#$00FF,d0
	or.w	d1,d0

	move.w	d0,d1
	andi.w	#$00F0,d1
	lsr.w	#4,d1
	cmp.w	#0,d1
	beq.s	.green_ok
	subq.w	#1,d1
.green_ok
	lsl.w	#4,d1
	andi.w	#$0F0F,d0
	or.w	d1,d0

	move.w	d0,d1
	andi.w	#$000F,d1
;	lsr.w	#0,d1
	cmp.w	#0,d1
	beq.s	.blue_ok
	subq.w	#1,d1
.blue_ok
;	lsl.w	#0,d1
	andi.w	#$0FF0,d0
	or.w	d1,d0
	move.l	Fade_Out_Mask-PC(a5),d1
	btst	d7,d1
	beq.s	.fade_col_off
	move.w	d0,2(a0)
.fade_col_off
	addq.l	#4,a0
.fade_loop_pass
	dbra	d7,.fade_loop
;	tst.w	d6
;	beq.s	.fade_end
;	btst	#7,$BFE001
;	bne.s	.fade_quick_skip
;	move.w	#FADE_FAST,Fade_Speed-PC(a5)
;.fade_quick_skip
;	bra	.fade_in_top
;.fade_end	
	rts

	ENDC


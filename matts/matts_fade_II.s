	IFND	MATTS_FADE_II_S
MATTS_FADE_II_S	SET	1

 IFND	FADE_AMOUNT
FADE_AMOUNT	EQU	4
 ENDC

;FADE_II_TEST	EQU	1
	IFD	FADE_II_TEST

	include	"matts_macros.s"
	include	"include:exec/types.i"

fade_setup	macro	; set,flags,colours,count,speed
	move.l	#\1,d3	; which set
	move.l	#\2,d0	; flags
	move.l	#\3,a1	; colour/colours
	move.w	\4,d1	; count
	move.l	#\5,d2	; speed
	bsr	_Fade_Setup
		endm
fade_it	macro
	move.b	#\1+1,_Fade_On
	endm

_Fade_Test:
	fade_setup	0,0,Colours,(a1)+,0


;	move.l	#0,d3		; setup fade 0
;	move.l	#1,d2		; speed

;	lea	Copper,a0

;	move.l	#0,d0			; fade all colours in copper
;	lea	Colours,a1		; using the colours pointed to by a1
;	move.w	(a1)+,d1		; not used with above flags

;	move.l	#FADEF_A1_VAL,d0	; fade all colours in copper
;	move.l	#$0888,a1		; using the value in a1
;	move.w	#2,d1			; not used with above flags

;	move.l	#FADEF_COUNT,d0		; fade for the count of d1
;	lea	Colours,a1		; using the colours pointed to by a1
;	move.w	(a1)+,d1		; number of colours to fade

;	move.l	#FADEF_A1_VAL!FADEF_COUNT,d0	; fade for the count of d1
;	move.l	#$0FF4,a1		; to the value of a1
;	move.w	#2,d1			; number of colours to fade


;	bset	#FADEB_DONE,_Fade_Flag
	fade_it	0
.1
	bsr	_Fade_Control
	tst.b	_Fade_On
	bne.s	.1
;	btst	#FADEB_DONE,_Fade_Flag(pc)
;	bne.s	.1
	rts	

Copper:	
;	DC.L	$01200000,$01220000
	DC.L	$01800000,$01820000,$01840000,$01860000
	DC.L	$FFFFFFFE

Colours:	DC.W	4,$0222,$0333,$0123,$0321
	ENDC

 BITDEF	FADE,A1_VAL,0
 BITDEF	FADE,COUNT,1

    STRUCTURE	Fade,0
	UBYTE	fd_Flag
	UBYTE	fd_Flag_Kludge
	ULONG	fd_Flags
	UWORD	fd_Speed
	UWORD	fd_SCnt
	UWORD	fd_Count
	LABEL	fd_Colours
	APTR	fd_Colour	
	LABEL	fd_SIZEOF

_Fade:	*************************************************
* a0 -> copper list					*
* a1 -> colour list to match colours in copper list	*
* OR =  value to fade to eg. $0000 - $0FFF		*
* d0 =  flags						*
* d1 =  number of colours to change			*
*********************************************************

	push	d0-d1/d3-d7/a0-a1
	moveq.l	#0,d6

.next_colour
	cmp.l	#$FFFFFFFE,(a0)		; is it the end of copper list?
	beq.s	.end_fade		; then exit
	move.w	(a0),d2			; get copper write reg
	cmp.w	#$0180,d2		; is it > $180
	blo.s	.colour_next
	cmp.w	#$01C0,d2		; is it < $1C0
	bhs.s	.colour_next
	move.w	a1,d2
	btst	#FADEB_A1_VAL,d0
	bne.s	.no_value
	move.w	(a1)+,d2
.no_value	
	move.w	2(a0),d3
	move.w	#$FFF,d5
	and.w	d5,d2
	and.w	d5,d3
	cmp.w	d2,d3
	beq.s	.colour_next
	move.w	#$100,d6
	move.w	#8,d7
	bsr	_Fade_Decide_Colour_Action
	move.w	#$10,d6
	move.w	#4,d7
	bsr	_Fade_Decide_Colour_Action
	move.w	#$1,d6
	move.w	#0,d7
	bsr	_Fade_Decide_Colour_Action
.colour_next
	addq.l	#4,a0
	btst	#FADEB_COUNT,d0
	beq.s	.no_colour_countdown
	subq.w	#1,d1
	tst.w	d1
	beq.s	.end_fade
.no_colour_countdown
	bra	.next_colour
.end_fade
	move.w	d6,d2
	pop	d0-d1/d3-d7/a0-a1
	rts

_Fade_Decide_Colour_Action:	***************************
* d2 = colour
* d3 = final colour
* d6 = add/sub  val for red #$100 - green #$010 - blue #$001
* d7 = shift val for red #8 - green #4 - blue #0
	move.w	d2,d4			; single out red component
	move.w	d3,d5
	lsr.w	d7,d4
	lsr.w	d7,d5
	and.w	#$F,d4
	and.w	#$F,d5
	sub.w	d4,d5
	beq.s	.add_comp
	bmi.s	.fade_add
	sub.w	d6,2(a0)
	bra.s	.add_comp
.fade_add	
	add.w	d6,2(a0)
.add_comp
	rts

_Fade_Setup:	;
* d0 - flags
* d1 - count
* d2 - speed
* d3 - position
	push	a5
	lea	_Fade_Vars(pc),a5
;	subq.w	#1,d2
	mulu	#fd_SIZEOF,d3
	add.l	d3,a5
;	move.l	a0,fd_Copper(a5)
	move.l	a1,fd_Colours(a5)
	move.w	d0,fd_Flags(a5)
	move.w	d1,fd_Count(a5)
	move.w	d2,fd_Speed(a5)
	pop	a5

	rts

_Fade_Vars:	DS.B	fd_SIZEOF*FADE_AMOUNT

;_Fade_Flag:
		DC.B	0
_Fade_On:	DC.B	0
_Fade_Copper:	DC.L	0

_Fade_Control:
	push	a5
	tst.b	_Fade_On
	beq.s	.fade_complete	
;	btst	#FADEB_DONE,_Fade_Flag(pc)
;	beq.s	.fade_complete
	lea	_Fade_Vars(pc),a5
	move.b	_Fade_On(pc),d2
	ext.w	d2
	subq.w	#1,d2
	mulu	#fd_SIZEOF,d2
	add.l	d2,a5
	add.w	#1,fd_SCnt(a5)
	move.w	fd_SCnt(a5),d0
	cmp.w	fd_Speed(a5),d0
	ble.s	.fade_complete
	move.w	#0,fd_SCnt(a5)
	move.l	_Fade_Copper,a0
	move.l	fd_Colours(a5),a1
	move.w	fd_Flags(a5),d0
	move.w	fd_Count(a5),d1
.val_d1_ok
	bsr	_Fade
	tst.b	d2
	bne.s	.fade_not_finished
	move.b	d2,_Fade_On
.fade_not_finished

.fade_complete
	pop	a5
	rts

_Fade_Wait:
 IFND	debug
	btst	#6,$BFE001
	beq.s	.fade_wait_exit
	tst.b	_Fade_On
;	btst	#FADEB_DONE,_Fade_Flag
	bne.s	_Fade_Wait
.fade_wait_exit
 ENDC
	rts


	ENDC

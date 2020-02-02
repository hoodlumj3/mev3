 IFND	MEV3_UTILITY_B_S
MEV3_UTILITY_B_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
*
* $VER:mev3_utility_B.s 39.01  © (00/April/94) M.J.Edwards
*
*

_TextPrintf:
	rts

;********************
; Graphics Functions
;********************

_Clear_Box:
	lea	_Raised_Box_Colour,a0
	push	d0-d3
	move.w	0(a0),d0
	bsr	_SetAPen
	pull	d0-d3
	bsr	_RectFill	; base
	pop	d0-d3
	rts
_Clear_Raised_Box:	; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	bsr	_Clear_Box
_Draw_Raised_Box:	; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	lea	_Raised_Box_Colour,a0
	bsr	_Draw_A_Box
	rts

_Clear_Lowered_Box:	; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	bsr	_Clear_Box
_Draw_Lowered_Box:	; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	lea	_Lowered_Box_Colour,a0
	bsr	_Draw_A_Box
	rts

_Draw_A_Box:
	push	a6
	move.l	a0,a6
	push	d0-d3

;	move.w	0(a6),d0
;	bsr	_SetAPen
;	pull	d0-d3
;	bsr	_RectFill	; base

	move.w	2(a6),d0
	bsr	_SetAPen


	pull	d0-d3
	move.l	d0,d2
	subq.l	#1,d3
	bsr	_Line		; left
	pull	d0-d3
	move.l	d1,d3
	subq.l	#1,d2
	bsr	_Line		; top

	move.w	4(a6),d0
	bsr	_SetAPen

	pull	d0-d3
	move.l	d2,d0
	addq.l	#1,d1
	bsr	_Line		; right
	pull	d0-d3
	move.l	d3,d1
	addq.l	#1,d0
	bsr	_Line		; bottom
	pop	d0-d3

	pop	a6
	rts

_Clear_Raised_Hires_Box:	; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	bsr	_Clear_Box
_Draw_Raised_Hires_Box:		; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	lea	_Raised_Box_Colour,a0
	bsr	_Draw_A_Hires_Box
	rts

_Clear_Lowered_Hires_Box:	; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	bsr	_Clear_Box
_Draw_Lowered_Hires_Box:		; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	lea	_Lowered_Box_Colour,a0
	bsr	_Draw_A_Hires_Box
	rts

_Draw_A_Hires_Box:
	push	a6
	move.l	a0,a6
	push	d0-d3

	move.w	#RP_JAM1,d0
	bsr	_SetDrMd

;	move.w	0(a6),d0
;	bsr	_SetAPen
;	pull	d0-d3
;	bsr	_RectFill	; base

	move.w	2(a6),d0
	bsr	_SetAPen

	pull	d0-d3
	move.l	d1,d3
	subq.l	#1,d2
	bsr	_Line		; top
	
	pull	d0-d3
	move.l	d0,d2
	bsr	_Line		; outer left

	pull	d0-d3
	addq.w	#1,d0
	move.l	d0,d2
	addq.w	#1,d1
	subq.l	#1,d3	
	bsr	_Line		; inner left

	move.w	4(a6),d0
	bsr	_SetAPen

	pull	d0-d3
	move.l	d3,d1
	addq.l	#1,d0
	bsr	_Line		; bottom

	pull	d0-d3
	subq.w	#1,d2
	move.l	d2,d0
	addq.l	#1,d1
	subq.w	#1,d3
	bsr	_Line		; inner right

	pull	d0-d3
	move.l	d2,d0
	bsr	_Line		; outer right
	pop	d0-d3

	pop	a6
	rts


_SetAPen:		; d0 - pen #
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	SetAPen
	pop	a1/a6
	rts

_SetBPen:		; d0 - pen #
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	SetBPen
	pop	a1/a6
	rts

_SetDrMd:		; d0 - mode
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	SetDrMd
	pop	a1/a6
	rts

_RectFill:		; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	push	a1/a6
	bsr	_Test_X1_X2_Y1_Y2_And_Set
	move.l	_Global_RastPort,a1
	base	Graphics
	call	RectFill
	pop	a1/a6
	rts

_Test_X1_X2_Y1_Y2_And_Set:
	cmp.w	d0,d2
	bgt.s	.x1_x2_ok
	exg.l	d0,d2
.x1_x2_ok
	cmp.w	d1,d3
	bgt.s	.y1_y2_ok
	exg.l	d1,d3
.y1_y2_ok
	rts

_Rect:			; d0 - left, d1 - top, d2 - right, d3 - bottom : edge
	bsr	_Test_X1_X2_Y1_Y2_And_Set
	push	d0-d3
	move.l	d1,d3
	subq.l	#1,d2
	jsr	_Line		; top
	pull	d0-d3
	move.l	d2,d0
	subq.l	#1,d3
	bsr	_Line		; right
	pull	d0-d3
	move.l	d3,d1
	addq.l	#1,d0
	bsr	_Line		; bottom
	pull	d0-d3
	move.l	d0,d2
	addq.l	#1,d1
	bsr	_Line		; left
	pop	d0-d3
	rts

_Draw:		; d0 - x, d1 - y
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	Draw
	pop	a1/a6
	rts

_Move:		; d0 - x, d1 - y
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	Move
	pop	a1/a6
	rts

_Line:			; d0 - x1, d1 - y1, d2 - x2, d3 - y2
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	push	d2-d3
	call	Move
	pop	d0-d1
	call	Draw
	pop	a1/a6
	rts

_ReadPixel:		; d0 - x, d1 - y
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	ReadPixel
	pop	a1/a6
	rts

_WritePixel:		; d0 - x, d1 - y
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	WritePixel
	pop	a1/a6
	rts

_DisplayText:	; d0 - x, d1 - y, d2 - strlen, a0 - string
	push	a1-a2/a6
	push	d2/a0
	move.l	_Global_RastPort,a1
	move.l	rp_Font(a1),a2
	add.w	tf_Baseline(a2),d1
	jsr	_Move
	pop	d0/a0
	jsr	_Text
	pop	a1-a2/a6
	rts

_Text:		; d0 - strlen, a0 - string
	push	a1-a2/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	Text
	pop	a1-a2/a6
	rts

_TextLength:	; a0 - string
	push	a0-a1/a6
	jsr	_StrLen
	move.l	_Global_RastPort,a1
	base	Graphics
	call	TextLength
	pop	a0-a1/a6
	rts

;_LoadRGB4:		; d0 - Count, a0 - Viewport, a1 - Colours
;	push	a6
;	base	Graphics
;	call	LoadRGB4
;	pop	a6
;	rts

;_SetRGB4:		; d0 - Colour#, d1 - Red, d2 - Green ,d3 - Blue, a0 - Viewport
;	push	a6
;	base	Graphics
;	call	SetRGB4
;	pop	a6
;	rts

_LoadRGB32:		; d0 - Count, a0 - Viewport, a1 - Colours
	move.l	d0,d4
	moveq.l	#0,d0
.next_colour
	cmp.w	d4,d0
	beq.s	.no_more_colours
	move.b	(a1)+,d1
	move.b	(a1)+,d2
	move.b	(a1)+,d3
	push	d0/d4/a0-a1
	call	_SetRGB32
	pop	d0/d4/a0-a1
	addq.l	#1,d0
	bra.s	.next_colour
.no_more_colours
;	push	a6
;	base	Graphics
;	call	LoadRGB32
;	pop	a6
	rts

_SetRGB32:		; d0 - Colour#, d1 - Red, d2 - Green ,d3 - Blue, a0 - Viewport
	push	d4/a6
	move.l	#$FF,d4
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	ror.l	#8,d1
	ror.l	#8,d2
	ror.l	#8,d3
	base	Graphics
	call	SetRGB32
	pop	d4/a6
	rts

_InitBitMap:
	push	d0-d2/a0/a6
	base	Graphics
	call	InitBitMap
	pop	d0-d2/a0/a6
	rts

_BltBitMap:
	push	d0-d7/a0-a2/a6
	base	Graphics
	call	BltBitMap
	pop	d0-d7/a0-a2/a6
	rts

_SetFont:		; a0 - textfont, a1 - rastport
	push	a6
	base	Graphics
	call	SetFont
	pop	a6
	rts

_AddFont:		; a1 - textfont
	push	a6
	base	Graphics
	call	AddFont
	pop	a6
	rts

_RemFont:		; a1 - textfont
	push	a6
	base	Graphics
	call	RemFont
	pop	a6
	rts

_InitBitMapRastPort:	; d0 - depth, d1 - width, d2 - height
	push	d3-d4/a0-a1/a5
	sub.l	#8,sp
	move.l	sp,a5
	push	d0-d2
	add.w	#$F,d1
	asr.w	#4,d1
	add.w	d1,d1
	mulu	d1,d2
	move.l	d2,d3				; save plane size
	mulu	d2,d0
	add.l	#bm_SIZEOF+rp_SIZEOF+4,d0	; calc sizeof rp bp & bm mem
	move.l	d0,d4
	pop	d0-d2
	push	d0-d3
	move.l	d4,d0
	call	_Malloc_CHIP
	move.l	d0,a0
	move.l	a0,0(a5)			; rastport location
	push	a0
	move.l	a0,a1
	base	Graphics
	call	InitRastPort			; initialize rastport
	pop	a0
	move.l	a0,a1
	add.l	#rp_SIZEOF,a0
	move.l	a0,rp_BitMap(a1)		; write bitmap to rastport
	move.l	a0,4(a5)

	pull	d0-d3
	base	Graphics
	call	InitBitMap
	pop	d0-d3
	move.l	a0,a1
	add.l	#bm_SIZEOF,a1
	lea	bm_Planes(a0),a2
	bra.s	.next_depth_p
.next_depth
	move.l	a1,(a2)+			; fill in the plane pointers of bitmap
	adda.l	d3,a1
.next_depth_p
	dbra	d0,.next_depth
	pop	d0-d1
	pop	d3-d4/a0-a1/a5	
	rts	; d0 - rastport, d1 - bitmap

_FreeBitMapRastPort:	; a0 - rastport
	call	_Free
	rts	

_Draw_Map_Line:		; d0 - x1, d1 - y1, d2 - x2, d3 - y2, a0 - execute routine
X1	EQUR	d0
Y1	EQUR	d1
X2	EQUR	d2
Y2	EQUR	d3
XSTEP	EQUR	d4
YSTEP	EQUR	d5
INCX	EQUR	d6
INCY	EQUR	d7

	cmp.w	X2,X1
	bge.s	.10
	move.w	X2,XSTEP
	sub.w	X1,XSTEP
	move.w	#1,INCX
	bra.s	.11
.10
	move.w	X1,XSTEP
	sub.w	X2,XSTEP
	move.w	#-1,INCX
.11
	cmp.w	Y2,Y1
	bge.s	.20
	move.w	Y2,YSTEP
	sub.w	Y1,YSTEP
	move.w	#1,INCY
	bra.s	.21
.20
	move.w	Y1,YSTEP
	sub.w	Y2,YSTEP
	move.w	#-1,INCY
.21
	jsr	(a0)
;	bsr	Plot_Point_In_Map

INC	EQUR	d2
DEC	EQUR	d3

	cmp.w	XSTEP,YSTEP	; if ( xstep > ystep )
	bge.s	.40		; then {
	move.w	YSTEP,INC	;   inc = ystep << 1
	lsl.w	#1,INC		; 
	move.w	XSTEP,DEC	;   dec = ( xstep - ystep ) << 1
	sub.w	YSTEP,DEC	; 
	lsl.w	#1,DEC		; 
	movem.l	d0,-(sp)	;   control = inc - xstep
	move.w	INC,d0		; 
	sub.w	XSTEP,d0	; 
	move.w	d0,_Control	; 
	movem.l	(sp)+,d0	; 
	tst.w	d4
	beq.s	.60
	subq.w	#1,d4
.30				;   while ( xstep-- ) {
	add.w	INCX,X1		;     x1 += incx
	tst.w	_Control	;     if (control < 0)
	bge.s	.35		;     then {
	add.w	INC,_Control	;       Control += inc
	bra.s	.36		;     }
.35				;     else {
	sub.w	DEC,_Control	;       control -= dec
	add.w	INCY,Y1		;       y1 += incy
.36				;     }
	jsr	(a0)
;	bsr	Plot_Point_In_Map;     putpixel (x1,y1)
	dbra	d4,.30		;   }
	bra.s	.60		; }
.40				; else {
	move.w	XSTEP,INC	;   inc = xstep << 1
	lsl.w	#1,INC		; 
	move.w	YSTEP,DEC	;   dec = ( ystep - xstep ) << 1
	sub.w	XSTEP,DEC	; 
	lsl.w	#1,DEC		; 
	movem.l	d0,-(sp)	;   control = inc - ystep
	move.w	INC,d0		; 
	sub.w	YSTEP,d0	; 
	move.w	d0,_Control	; 
	movem.l	(sp)+,d0	; 
	tst.w	d5
	beq.s	.60
	subq.w	#1,d5
.50				;   while ( ystep-- ) {
	add.w	INCY,Y1		;     y1 += incy
	tst.w	_Control		;     if ( control < 0 )
	bge.s	.55		;     then {
	add.w	INC,_Control	;       Control += inc
	bra.s	.56		;     }
.55				;     else {
	sub.w	DEC,_Control	;       control -= dec
	add.w	INCX,X1		;       x1 += incx
.56				;     }
	jsr	(a0)
;	bsr	Plot_Point_In_Map;     putpixel (x1,y1)
	dbra	d5,.50		;   }
;	bra.s	.60		; }
.60	
	rts


_Draw_Horizontal_Line:	; d0 - x1, d1 - y, d2 - x2, d3 - y2, a0 - execute routine

	cmp.w	d2,d0
	bge.s	.10
	exg.l	d2,d0
.10
	sub.w	d2,d0
.next_width
	push	d0-d1
	add.w	d2,d0
	jsr	(a0)
	pop	d0-d1
	dbra	d0,.next_width
	rts

_Draw_Verticle_Line:	; d0 - x1, d1 - y, d2 - x2, d3 - y2, a0 - execute routine

	cmp.w	d3,d1
	bge.s	.10
	exg.l	d3,d1
.10
	sub.w	d3,d1
.next_width
	push	d0-d1
	add.w	d3,d1
	jsr	(a0)
	pop	d0-d1
	dbra	d1,.next_width
	rts


;******************
; Memory Functions
;******************

_Copy_Bytes:		; d0 - # bytes, a0 - source, a1 - destination
	push	d0/a0-a1/a6
	base	Sys
	call	CopyMem
;	bra.s	..1
;..0
;	move.b	(a0)+,(a1)+
;..1
;	dbra	d0,..0
	pop	d0/a0-a1/a6
	rts

_Copy_Words:		; d0 - # words, a0 - source, a1 - destination
	push	d0
	add.l	d0,d0
	call	_Copy_Bytes
	pop	d0
;	push	d0/a0-a1
;	bra.s	..1
;..0
;	move.w	(a0)+,(a1)+
;..1
;	dbra	d0,..0
;	pop	d0/a0-a1
	rts

_Copy_LongWords:	; d0 - # lwords, a0 - source, a1 - destination
	push	d0
	add.l	d0,d0
	add.l	d0,d0
	call	_Copy_Bytes
	pop	d0

;	push	d0/a0-a1
;	bra.s	..1
;..0
;	move.l	(a0)+,(a1)+
;..1
;	dbra	d0,..0
;	pop	d0/a0-a1
	rts



;*************************************
; Intuition Message Handling Function
;*************************************


_Execute_Intuition_Message:	; a0 - idcmp list
	lea	_Message,a1
.next_check_idcmp
	move.l	(a0)+,d0		; get idcmp
	tst.l	d0			; test if end of list
	bmi.s	.execute_int_message_end
	cmp.l	im_Class(a1),d0		; is it idcmp loaded
	bgt.s	.execute_int_message_end
	bne.s	.check_next_idcmp	; no so jump to end
	push	d0-d7/a0-a6
	move.l	(a0)+,d0		; get jump loc
	tst.l	d0			; is it null
	beq.s	.nothing_to_execute
	move.l	d0,a0			; not null - so execute
	jsr	(a0)
.nothing_to_execute
	pop	d0-d7/a0-a6
	bra.s	.execute_int_message_end
.check_next_idcmp
	addq.l	#4,a0			; skip jump
	bra.s	.next_check_idcmp	; go around again
.execute_int_message_end
	rts

_Execute_VanillaKey_List:	; a0 - vanillakey list
	lea	_Message,a1
.next_check_vanillakey
	clr.l	d0
	move.b	(a0)+,d0		; get ascii key
	move.b	(a0)+,d1		; get qualifier
	tst.b	d0			; test if end of list
	bmi.s	.execute_vanillakey_end
	cmp.w	im_Code(a1),d0		; is it key loaded
	bne.s	.check_next_vanillakey	; no so jump to end
;	tst.w	d1
;	beq.s	.execute_vanilla_key
;	move.w	im_Qualifier(a1),d2
;	and.w	d1,d2
;	tst.w	d2
;	cmp.w	im_Qualifier(a1),d1	; is it same qualifier
;	beq.s	.check_next_vanillakey
	cmp.b	#-1,d1			; -1 means skip qualifier
	beq.s	.execute_vanilla_key
	move.w	im_Qualifier(a1),d2
	andi.w	#$FF,d2
	cmp.w	d2,d1			; is it same qualifier
	bne.s	.check_next_vanillakey
.execute_vanilla_key
	push	d0-d7/a0-a6
	move.l	(a0),d0			; get jump loc
	tst.l	d0			; is it null
	beq.s	.nothing_to_execute
	move.l	d0,a0			; not null - so execute
	jsr	(a0)
.nothing_to_execute
	pop	d0-d7/a0-a6
;	bra.s	.execute_vanillakey_end
.check_next_vanillakey
	addq.l	#4,a0			; skip jump
	bra.s	.next_check_vanillakey	; go around again
.execute_vanillakey_end
	rts

_Execute_Gadget_List:		; a0 - gadget list
	lea	_Message,a1
	move.l	im_IAddress(a1),a2
.next_check_gadget
	clr.l	d0
	move.w	(a0)+,d0		; get gadget ID
	tst.w	d0			; test if end of list
	bmi.s	.execute_gadget_end	; end of list signal - so exit
	cmp.w	gg_GadgetID(a2),d0	; is it the gadgetID loaded
	bne.s	.check_next_gadget	; no so jump to end
	move.w	d0,d1
	move.l	(a0),d0			; get jump loc
	push	d0-d7/a0-a6
	tst.l	d0			; is it null
	beq.s	.nothing_to_execute
	move.l	d0,a0			; not null - so execute
	move.w	im_MouseX(a1),d0
	sub.w	gg_LeftEdge(a2),d0
	move.w	im_MouseY(a1),d1
	sub.w	gg_TopEdge(a2),d1	
	jsr	(a0)
.nothing_to_execute
	pop	d0-d7/a0-a6
	bra.s	.execute_gadget_end
.check_next_gadget
	addq.l	#4,a0			; skip jump
	bra.s	.next_check_gadget	; go around again
.execute_gadget_end
	rts

;*********************
; Requester Functions
;*********************

_EasyRequestArgs:	; sp -> window - title - body - gadgets - args list ...
	push	a0-a4/a6
	lea	7*4(sp),a4
	
	move.l	3*4(a4),-(sp)	; gadgets
	move.l	2*4(a4),-(sp)	; body
	move.l	1*4(a4),-(sp)	; title
	pea	0.w		; easy struct flags
	pea	es_SIZEOF	; sizeof(struct easystruct)
	move.l	0*4(a4),a0	; window
	move.l	sp,a1		; &easystruct
	sub.l	a2,a2		; idcmp ptr
	lea	4*4(a4),a3	; arg list
	move.l	_IntuitionBase,a6
	call	EasyRequestArgs			
	lea	5*4(sp),sp
	pop	a0-a4/a6
	rts

_Setup_ASL_Requester:	; a0 - window - hail - OKText - file - dir - pattern
	push	a0
	move.l	a0,a1
	lea	Asl_Requester_Tags(pc),a0
	
	move.l	00(a1),Asl_Requester_Window-Asl_Requester_Tags+4(a0)
	move.l	04(a1),Asl_Requester_Hail-Asl_Requester_Tags+4(a0)
	move.l	08(a1),Asl_Requester_OKText-Asl_Requester_Tags+4(a0)
	move.l	12(a1),Asl_Requester_File-Asl_Requester_Tags+4(a0)
	move.l	16(a1),Asl_Requester_Dir-Asl_Requester_Tags+4(a0)
	move.l	20(a1),Asl_Requester_Pattern-Asl_Requester_Tags+4(a0)

	move.l	#ASL_FileRequest,d0
;	lea	Asl_Requester_Tags,a0
	push	a6
	base	Asl
	call	AllocAslRequest
	pop	a6
	move.l	d0,_FileReq
	pop	a0
	rts

_ASL_Requester:		; nothing
	push	a0
	move.l	_FileReq,a0
	sub.l	a1,a1
	push	a6
	base	Asl
	call	AslRequest
	pop	a6
	tst.l	d0
	pop	a0
	rts

_ShutDown_ASL_Requester:
	push	a0
	move.l	_FileReq,a0
	push	a6
	base	Asl
	call	FreeAslRequest
	pop	a6
	pop	a0
	rts

_FileReq:		DC.L	0
;_File_Name_Ptr:		DC.L	0

Asl_Requester_Tags:
Asl_Requester_Window:	Tag	ASL_Window,0
Asl_Requester_OKText:	Tag	ASL_OKText,0
Asl_Requester_Hail:	Tag	ASL_Hail,0
Asl_Requester_Pattern:	Tag	ASL_Pattern,0
Asl_Requester_File:	Tag	ASL_File,0
Asl_Requester_Dir:	Tag	ASL_Dir,0
			Tag	ASL_Height,200-11
			Tag	ASL_Width,330
			Tag	ASL_LeftEdge,0
			Tag	ASL_TopEdge,11
			Tag	ASL_FuncFlags,FILF_MULTISELECT|FILF_PATGAD ;FILF_SAVE
			Tag_End



 ENDC

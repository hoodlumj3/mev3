 IFND	MEV3_UTILITY_A_S
MEV3_UTILITY_A_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
*
* $VER:mev3_utility_A.s 39.01  © (00/April/94) M.J.Edwards
*
*

_Find_Greater:		; d0.l - num, d1.l - num
	cmp.l	d1,d0
	bge.s	.number_d0_greater
	exg.l	d0,d1
.number_d0_greater	
	rts		; d0 - highest number of both, d1 - lowest number of both

_Power_Of_2:		; d0 - power(32)
	push	d1
	moveq.l	#1,d1
	asl.l	d0,d1
	move.l	d1,d0
	pop	d1
	rts

_Mult32:	; d0 - num1 (*) d1 - num2
	push	a0
	move.l	_UtilityBase,a0
	jsr	_LVOUmult32(a0)
	pop	a0
	rts	; d0 value (d0*d1)

_Divi32:	; d0 - num1 (/) d1 - num2
	push	a0
	move.l	_UtilityBase,a0
	jsr	_LVOUdivMod32(a0)
	pop	a0
	rts	; d0 - value (d0/d1), d1 - remainder

; start :	; (first run run_id <- -1)
;    status <- 1				/* set status for setup */
;    inside <- 0
;    outside <- 0
;    read id,x1,y1,x2,y2,jump
;    while (x1 != -1) {
;        if (mouse is inside box(x1,y1,x2,y2)) {
;            if (run_id != id) {
;                status <- SHUTDOWN
;                execute(jump_pointer)
;                jump_pointer <- NULL
;                status <- SETUP
;                run_id <- -1
;            }
;            run_id <- id
;            jump_pointer <- jump
;            execute(jump_pointer)
;        }
;        else {
;            if ( run_id == id ) {
;                status <- SHUTDOWN
;                execute(jump_pointer)
;                jump_pointer <- NULL
;                status <- SETUP
;                run_id <- -1
;            }
;        }
;        read x1,y1,x2,y2,jump
;    }

_Check_Regions:		; d0 - mouse x, d1 - mouse y, a0 - region list (id.w, x.w, y.w, w.w, h.w, routine.l)
	push	d2-d6/a0
.while
	move.w	0(a0),d6
	tst.w	d6
	bmi	.end_while
	btst	#6,(a0)
	bne	.while_next
	movem.w	2(a0),d2-d5
	add.w	d2,d4
	add.w	d3,d5
	sub.w	#1,d4
	sub.w	#1,d5
	cmp.w	d2,d0		; x1
	blo	.outside_of_box
	cmp.w	d4,d0		; x2
	bhi	.outside_of_box
	cmp.w	d3,d1		; y1
	blo	.outside_of_box
	cmp.w	d5,d1		; y2
	bhi	.outside_of_box
	sub.w	d2,d0
	sub.w	d3,d1	
	cmp.w	_Region_Run_ID,d6
	beq.s	.no_prev_shut
	move.b	#-1,_Region_Status	; set to shutdown previous
	bsr	Do_Coord_Jump
	move.l	#0,_Region_Execution
	move.b	#1,_Region_Status	; set to setup for next	
	move.w	#-1,_Region_Run_ID
.no_prev_shut
	move.w	d6,_Region_Run_ID
	move.l	10(a0),_Region_Execution
	bsr	Do_Coord_Jump		; setup & run in one
	bra.s	.end_while
.outside_of_box
	cmp.w	_Region_Run_ID,d6
	bne.s	.while_next
	move.b	#-1,_Region_Status	; set to shutdown
	bsr	Do_Coord_Jump
	move.l	#0,_Region_Execution	
	move.b	#1,_Region_Status	; set for setup
	move.w	#-1,_Region_Run_ID
.while_next
	add.l	#rg_SIZEOF,a0
	bra	.while
.end_while
	pop	d2-d6/a0

	rts

Do_Coord_Jump:	; d0 - mouse x, d1 - mouse y
	tst.b	_Regions_On
	beq.s	.regions_end
	push	d0-d7/a0-a6
	push	d0-d1
	pop	d2-d3
	move.l	_Region_Execution,d0
	tst.l	d0
	beq.s	.no_jump_avail
	move.l	d0,a0
	move.b	_Region_Status,d0
	jsr	(a0)
.no_jump_avail
	pop	d0-d7/a0-a6	
.regions_end
	rts

_Region_Execution:	DC.L	0
_Region_Status:		DC.B	1,0
_Region_Run_ID:		DC.W	0

;;-

_Inform_Request:	; a0 - args, a1 - body
	lea	_Text_OK+1,a2		; button
	lea	_Text_Mev3_Inform,a3	; title
	bsr	_A_Request
	rts
;	push	a0			; arg
;	pea	_Text_OK+1(pc)		; gadget
;	push	a1			; body
;	pea	_Text_Mev3_Inform(pc)	; title
;	move.l	_Ed_Window,-(sp)	; window
;	jsr	_EasyRequestArgs
;	lea	5*4(sp),sp	
;	rts

_Ask_Request:		; a0 - args, a1 - body
	lea	_Text_Req_DoItForgetIt,a2	; button
	lea	_Text_Mev3_Inform,a3		; title
	bsr	_A_Request
	rts

_A_Request:	; a0 - args, a1 - body, a2 - button text, a3 - title
	push	a0			; args
	push	a2			; button
	push	a1			; body
	push	a3			; title
;	move.l	_Ed_Window,-(sp)	; window
	pea	0.w
	jsr	_EasyRequestArgs
	lea	5*4(sp),sp	
	rts

_Transfer_Cut:	*****************************************
* d0 == srce x						*
* d1 == srce y						*
* d2 == srce w						*
* d3 == srce h						*
* d4 == dest w						*
* d5 == dest h						*
* a0 -> srce mem					*
* a1 -> dest mem					*
*********************************************************
	push	a5
	push	d2		; 00sw
	move.l	sp,a5
	push	d0-d3/a0-a1

	bra.s	.next_y_p
.next_y
	push	d0/d2
	bra.s	.next_x_p
.next_x

	cmp.w	#0,d0		; check word is in map
	blo.s	.not_in_map
	cmp.w	#0,d1
	blo.s	.not_in_map
	cmp.w	d4,d0
	bhs	.not_in_map
	cmp.w	d5,d1
	bhs	.not_in_map

	move.l	0(a5),d6	; srce width
	mulu	d1,d6		; * srce y
	add.l	d0,d6		; + srce x
	add.l	d6,d6		; srce offset *2
	move.l	d4,d7		; dest width
	mulu	d1,d7		; * dest y
	add.l	d0,d7		; + dest x
	add.l	d7,d7		; dest offset * 2
	move.w	(a0,d6.l),(a1,d7.l)
.not_in_map
	addq.w	#1,d0		; increase x
.next_x_p
	dbra	d2,.next_x
	pop	d0/d2
	addq.w	#1,d1		; increase y
.next_y_p
	dbra	d3,.next_y

	pop	d0-d3/a0-a1	
	addq.l	#4,sp
	pop	a5
	rts

	IFD	dugbarry
_Transfer_Cut_2:	*********************************
* d0 == srce x						*
* d1 == srce y						*
* d2 == srce w						*
* d3 == srce h						*
* d4 == dest x						*
* d5 == dest y						*
* d6 == dest w						*
* d7 == dest h						*
* a0 -> srce mem					*
* a1 -> dest mem					*
*********************************************************

	push	a5
	push	0.w		; 12 width
	pea	0.w		; 08 height
	pea	0.w		; 04 srce width
	pea	0.w		; 00 dest width
	move.l	sp,a5
	move.l	d2,04(a5)
	move.l	d6,00(a5)
	
	push	d0-d1
	move.l	d2,d0
	move.l	d6,d1
	bsr	_Find_Greater	; find the smaller of the widths
	move.l	d1,12(a5)	; width
	move.l	d3,d0
	move.l	d7,d1
	bsr	_Find_Greater	; find the smaller of the heights
	move.l	d1,08(a5)	; height
	pop	d0-d1
	move.l	d4,d2		; dest x
	move.l	d5,d3		; dest y
	move.l	12(a5),d4
	
	bra.s	.next_y_p
.next_y
	push	d0/d2
	move.l	08(a5),d5

	bra.s	.next_x_p
.next_x

	cmp.w	#0,d0		; check word is in map
	blo.s	.not_in_map
	cmp.w	#0,d1
	blo.s	.not_in_map
	cmp.l	d4,d0
	bhs	.not_in_map
	cmp.l	d5,d1
	bhs	.not_in_map

	move.l	0(a5),d6	; srce width
	mulu	d1,d6		; * srce y
	add.l	d0,d6		; + srce x
	add.l	d6,d6		; srce offset *2
	move.l	d4,d7		; dest width
	mulu	d1,d7		; * dest y
	add.l	d0,d7		; + dest x
	add.l	d7,d7		; dest offset * 2
	move.w	(a0,d6.l),(a1,d7.l)
.not_in_map
	addq.w	#1,d0		; increase x
.next_x_p
	dbra	d2,.next_x
	pop	d0/d2
	addq.w	#1,d1		; increase y
.next_y_p
	dbra	d3,.next_y

	pop	d0-d3/a0-a1	
	addq.l	#4,sp
	pop	a5
	rts
	ENDC

_Init_Write_Map_Tile:	; d0 - x in map, d1 - y in map
	push	d0-d1/a0-a1
	cmp.w	#0,d0
	blo	.write_tile_end		; exit if < left edge
	cmp.w	map_Width(a1),d0
	bhs	.write_tile_end		; exit if > right edge

	cmp.w	#0,d1
	blo	.write_tile_end		; exit if < top edge
	cmp.w	map_Height(a1),d1
	bhs	.write_tile_end		; exit if > bottom edge

	move.l	map_Location(a1),a0
	mulu	map_Width(a1),d1
	add.l	d1,d0
	add.l	d0,d0
	move.w	#$FFFF,(a0,d0.l)
.write_tile_end
	pop	d0-d1/a0-a1
	rts

;;-

;*****************************
; Intuition Functions
;*****************************

_SetPointer:		; a0 - window, a1 - pointer
	push	d0-d3/a6
	movem.w	(a1)+,d0-d3
	move.l	_IntuitionBase,a6
	jsr	_LVOSetPointer(a6)	
	pop	d0-d3/a6
	rts

_ClearPointer:		; a0 - window
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOClearPointer(a6)	
	pop	a6
	rts

_Wait:			; a0 - userport
	push	d0-d1/a6
	moveq.l	#0,d1
	move.b	$f(a0),d1		; mp_SigBit
	move.l	#$1,d0
	asl.l	d1,d0
	base	Sys
	jsr	_LVOWait(a6)		; wait for a message from window
	pop	d0-d1/a6
	rts

_GT_GetIMsg:		; a0 - userport
	push	a6
	move.l	_GadToolsBase,a6
	jsr	_LVOGT_GetIMsg(a6)
	pop	a6
	rts

_GT_ReplyIMsg:		; a1 - message
	push	a6
	move.l	_GadToolsBase,a6
	jsr	_LVOGT_ReplyIMsg(a6)
	pop	a6
	rts

_GT_SetGadgetAttrs:	; a0 - gt_gad, a1 - window, a2 - req, a3 - tags
	push	a2/a6
	sub.l	a2,a2
	move.l	_GadToolsBase,a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
	pop	a2/a6
	rts

;_GT_SetGadgetAttrs:	; a0 - gadget, a1 - window, a2 - ??, a3 - tags
;	push	a6
;	base	GadTools
;	call	GT_SetGadgetAttrsA
;	pop	a6
;	rts

_DrawBorder:		; d0 - x, d1 - y, a0 - border
	push	a0-a1/a6
	move.l	a0,a1
	move.l	_Global_RastPort,a0
	move.l	_IntuitionBase,a6
	jsr	_LVODrawBorder(a6)
	pop	a0-a1/a6
	rts

_ScreenToFront:
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOScreenToFront(a6)
	pop	a6
	rts

_MoveScreenTo:	; d0 - x, d1 - y, a0 - screen
	push	d2-d3
	move.w	sc_LeftEdge(a0),d2
	move.w	sc_TopEdge(a0),d3
	push	d2-d3
	sub.w	d2,d0
	sub.w	d3,d1
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOMoveScreen(a6)
	pop	a6
	pop	d0-d1
	pop	d2-d3
	rts

_MoveWindowTo:	; d0 - x, d1 - y, a0 - window
	push	d2-d3
	move.w	wd_LeftEdge(a0),d2
	move.w	wd_TopEdge(a0),d3
	push	d2-d3
	sub.w	d2,d0
	sub.w	d3,d1
	push	a6
	base	Intuition
	call	MoveWindow
	pop	a6
	pop	d0-d1
	pop	d2-d3
	rts

_ActivateWindow:
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOActivateWindow(a6)
	pop	a6
	rts


_Check_Out_Bits_And_Get_A1_Accordingly:	; d0 - gadget id (tick), d1 - bit # to set, a0 - windows gadget list, a1 - flags ptr.w
	jsr	_Find_GadgetID
	move.w	gg_Flags(a0),d2		; get gadget flags
	move.w	(a1),d0			; get format
	btst	#7,d2			; see if gadget is selected
	beq.s	.not_set		; not set so clear
	bset	d1,d0			; set bit in format
	bra.s	.bit_ok	
.not_set
	bclr	d1,d0			; clear bit in format
.bit_ok	
	move.w	d0,(a1)			; write format
	rts

_Check_Out_Bits_And_Set_A1_Accordingly:
	jsr	_Find_GadgetID
	move.w	(a1),d2			; get format
	move.w	gg_Flags(a0),d0		; get gadget flags
	btst	d1,d2			; test bit in format
	beq.s	.not_set		; not set so clear bit in format
	bset	#7,d0			
	bra.s	.bit_ok			; set bit in format
.not_set
	bclr	#7,d0			; clear bit in format
.bit_ok	
	move.w	d0,gg_Flags(a0)		; write gadget flags
	rts

 ENDC

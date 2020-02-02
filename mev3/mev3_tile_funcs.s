 IFND	MEV3_TILE_FUNCS_S
MEV3_TILE_FUNCS_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
**
*** $VER:mev3_tile_funcs.s 39.01  © (7/May/94) M.J.Edwards
**
*

_Draw_On:	DC.W	0
_Palette_On:	DC.W	0

_Prev_X1:	DC.W	0
_Prev_Y1:	DC.W	0
_Prev_X2:	DC.W	0
_Prev_Y2:	DC.W	0

_Magnify_CX:		DC.W	0
_Magnify_CY:		DC.W	0
_Magnify_SizeX:		DC.W	2
_Magnify_SizeY:		DC.W	2

_LayerInfo:	DC.L	0
_Layer:		DC.L	0
_TempRaster:	DC.L	0
_Rast_Width:	DC.W	0
_Rast_Height:	DC.W	0
_Area_Table:	DS.W	500
_AreaInfo:	DS.B	ai_SIZEOF
 EVEN
_TmpRas:	DS.B	tr_SIZEOF
 EVEN

*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****		Palette Setup, Handler & ShutDown Functions		*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************


dbgt2:
_Tile_Work_Palette_Setup:
	tst.l	_Active_Gadgets
	bne	.end_palette_setup

	move.l	_Wait_Routine,_Wait_Routine_Old

	moveq.l	#-1,d0			; Shutdown
	jsr	_jsr_Routine_Wait

	lea	_Tile_Work_Palette_Gadget_List,a0
	jsr	_Work_Global_Setup_First
	jsr	_Tile_Work_Palette_Setup_Setup

	move.l	_Wk_RastPort,_Global_RastPort


	coord.w	048+030,006,221,9	; draw red slider box
	jsr	_Clear_Lowered_Box	; clear box
	coord.w	048+030,016,221,9	; draw green slider box
	jsr	_Clear_Lowered_Box	; clear box
	coord.w	048+030,026,221,9	; draw blue slider box
	jsr	_Clear_Lowered_Box	; clear box

	jsr	_Work_Global_Setup_Last

	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	push	d0
	mulu	#3,d0
	jsr	_Malloc
	move.l	d0,_Backup_Palette
	pop	d1
	add.l	d1,d0
	move.l	d0,_Undo_Palette
	add.l	d1,d0
	move.l	d0,_Temp_Palette

	jsr	_Orig_Back_Tile_Palette
	jsr	_Orig_Undo_Tile_Palette

	sf	_Tools_On
	st	_Regions_On
	st	_Palette_On

	jsr	_Change_RGB_Prop_Gadgets

.end_palette_setup

	rts

_Tile_Work_Palette_Setup_Setup:

	move.w	#CHGF_PALETTESET,d0
	or.w	d0,_Something_Changed-PC(gl)
	move.w	d0,_Something_Mask-PC(gl)

	rts

_Tile_Work_Palette_Apply
	rts
dbgt7:
_Tile_Work_Palette_Cancel:
;
;;	restore original tile colours and set colours em'
;
	jsr	_Back_Orig_Tile_Palette
	jsr	_Set_Tile_Palette
	jsr	_Tile_Work_Palette_ShutDown
	rts

_Tile_Work_Palette_Ok:
;
;;	leave altered palette alone and remove buffer
;
	jsr	_Tile_Work_Palette_Apply
	jsr	_Tile_Work_Palette_ShutDown
	rts

_Tile_Work_Palette_ShutDown:






	moveq.l	#-1,d0			; Shutdown old routine (if any)
	jsr	_jsr_Routine_Wait

	jsr	_Work_Global_ShutDown

	move.l	_Wait_Routine_Old,a0
	jsr	_SetUp_Routine_Wait	; setup of old old wait routine button
	move.l	#0,_Wait_Routine_Old

	moveq.l	#1,d0			; Setup old old routine (if any)
	jsr	_jsr_Routine_Wait

	move.l	_Backup_Palette,a0
	jsr	_Free


	sf	_Palette_On
	st	_Tools_On
	st	_Regions_On

	jsr	_Tile_Work_Display

	rts

_Tile_Work_Palette_Undo:
	jsr	_Orig_Temp_Tile_Palette
	jsr	_Undo_Orig_Tile_Palette
	jsr	_Temp_Undo_Tile_Palette
	jsr	_Set_Tile_Palette
	jsr	_Change_RGB_Prop_Gadgets
	rts


_Tile_Work_Palette_Revert:
	jsr	_Orig_Undo_Tile_Palette		; save off for undo of change
	jsr	_Back_Orig_Tile_Palette		; restore to state at which we entered palette editor
	jsr	_Set_Tile_Palette
	jsr	_Change_RGB_Prop_Gadgets
	rts

_Work_Eor_Select_Gadget:	; d0 - gadget_id
	move.l	_Wk_Window,a1
	move.l	wd_FirstGadget(a1),a0
	jsr	_Find_GadgetID
	move.w	#GFLG_SELECTED,d0
	move.w	gg_Flags(a0),d1
	eor.w	d0,d1
	move.w	d1,gg_Flags(a0)
	moveq.l	#1,d0
	jsr	_RefreshGList
	rts

dbgt3:
_Tile_Work_Palette_Copy:
	lea	.wait_copy,a0
	jsr	_SetUp_Routine_Wait

.wait_copy	; d0 = > 0 : setup, d0 = 0 : execute, d0 = -1 : shutdown
	tst.l	d0
	bmi.s	.copy_shutdown
	beq.s	.copy_execute
.copy_setup




	move.l	#BUTTON_ID_PALETTECOPY,d0
	jsr	_Work_Eor_Select_Gadget	
	move.w	_Colour_Edit_1,_First_Colour

	bra.s	.copy_end
.copy_execute
	cmp.w	#TILE_COLOUR_REGION_ID,_Wait_On_Signal
	bne.s	.copy_end
	move.l	_Ed_RastPort,_Global_RastPort
	jsr	_Orig_Undo_Tile_Palette		; save off for undo of change
	move.w	_Colour_Edit_1,_Second_Colour
	move.w	_First_Colour,d0
	jsr	_Get_A_Tile_Colour32
	move.w	_Second_Colour,d0
	jsr	_Put_A_Tile_Colour32
	jsr	_Set_Tile_Palette
	jsr	_Change_RGB_Prop_Gadgets
;	move.l	#BUTTON_ID_PALETTECOPY,d0
;	jsr	_Work_Eor_Select_Gadget	

;	bra.s	.copy_end
.copy_shutdown
	jsr	_CleanUp_Routine_Wait
	move.l	#BUTTON_ID_PALETTECOPY,d0
	jsr	_Work_Eor_Select_Gadget	
.copy_end
	rts


;dbgt3:
;_Tile_Work_Palette_Copy:
;	move.l	#BUTTON_ID_PALETTECOPY,d0
;	jsr	_Work_Eor_Select_Gadget	
;	lea	.wait_copy,a0
;	jsr	_SetUp_Routine_Wait
;	tst.l	d0
;	bmi.s	.cleanup_copy
;	beq.s	.end_copy
;	move.w	_Colour_Edit_1,_First_Colour
;	bra.s	.end_copy
;.wait_copy
;	cmp.w	#TILE_COLOUR_REGION_ID,_Wait_On_Signal
;	bne.s	.end_copy
;	jsr	_Orig_Undo_Tile_Palette		; save off for undo of change
;	move.w	_Colour_Edit_1,_Second_Colour
;	move.w	_First_Colour,d0
;	jsr	_Get_A_Tile_Colour32
;	move.w	_Second_Colour,d0
;	jsr	_Put_A_Tile_Colour32
;	jsr	_Set_Tile_Palette
;	jsr	_Change_RGB_Prop_Gadgets
;	move.l	#BUTTON_ID_PALETTECOPY,d0
;	jsr	_Work_Eor_Select_Gadget	
;	
;.cleanup_copy
;	jsr	_CleanUp_Routine_Wait
;.end_copy
;	rts

_Tile_Work_Palette_Exchange:
	lea	.wait_exchange,a0
	jsr	_SetUp_Routine_Wait

.wait_exchange	; d0 = > 0 : setup, d0 = 0 : execute, d0 = -1 : shutdown
	tst.l	d0
	bmi	.exchange_shutdown
	beq.s	.exchange_execute
.exchange_setup
	move.l	#BUTTON_ID_PALETTEEXCHG,d0
	jsr	_Work_Eor_Select_Gadget	
	move.w	_Colour_Edit_1,_First_Colour

	bra.s	.exchange_end
.exchange_execute
	cmp.w	#TILE_COLOUR_REGION_ID,_Wait_On_Signal
	bne.s	.exchange_end
	move.l	_Ed_RastPort,_Global_RastPort
	jsr	_Orig_Undo_Tile_Palette		; save off for undo of change
	move.w	_Colour_Edit_1,_Second_Colour

	move.w	_First_Colour,d0	; swap first & second colour
	jsr	_Get_A_Tile_Colour32
	push	d0-d3
	move.w	_Second_Colour,d0
	jsr	_Get_A_Tile_Colour32
	pop	d4-d7
	exg.l	d0,d4
	push	d4-d7
	jsr	_Put_A_Tile_Colour32
	pop	d0-d3
	jsr	_Put_A_Tile_Colour32
	
	jsr	_Set_Tile_Palette

	jsr	_Change_RGB_Prop_Gadgets

.exchange_shutdown
	jsr	_CleanUp_Routine_Wait
	move.l	#BUTTON_ID_PALETTEEXCHG,d0
	jsr	_Work_Eor_Select_Gadget	
.exchange_end
	rts



_Tile_Work_Palette_Spread:
	lea	.wait_spread,a0
	jsr	_SetUp_Routine_Wait

.wait_spread	; d0 = > 0 : setup, d0 = 0 : execute, d0 = -1 : shutdown
	tst.l	d0
	bmi.s	.spread_shutdown
	beq.s	.spread_execute
.spread_setup
	move.l	#BUTTON_ID_PALETTESPREAD,d0
	jsr	_Work_Eor_Select_Gadget	
	move.w	_Colour_Edit_1,_First_Colour

	bra.s	.spread_end
.spread_execute
	cmp.w	#TILE_COLOUR_REGION_ID,_Wait_On_Signal
	bne.s	.spread_end
	move.l	_Ed_RastPort,_Global_RastPort
	jsr	_Orig_Undo_Tile_Palette		; save off for undo of change
	move.w	_Colour_Edit_1,_Second_Colour

	move.w	_First_Colour,d0
	move.w	_Second_Colour,d1
	cmp.w	d0,d1
	beq.s	.spread_shutdown
	move.l	_Tile_Colours,a0	
	jsr	_Palette_Spread_Colours

	jsr	_Set_Tile_Palette
	jsr	_Change_RGB_Prop_Gadgets

.spread_shutdown
	jsr	_CleanUp_Routine_Wait
	move.l	#BUTTON_ID_PALETTESPREAD,d0
	jsr	_Work_Eor_Select_Gadget	
.spread_end
	rts

dbgt6:
_Tile_Work_Palette_Pick:
	lea	.wait_pick,a0
	jsr	_SetUp_Routine_Wait

.wait_pick	; d0 = > 0 : setup, d0 = 0 : execute, d0 = -1 : shutdown
	tst.l	d0
	bmi.s	.pick_shutdown
	beq.s	.pick_execute
.pick_setup
	move.l	#BUTTON_ID_PALETTEPICK,d0
	jsr	_Work_Eor_Select_Gadget	
	move.w	_Colour_Edit_1,_First_Colour

	bra.s	.pick_end
.pick_execute
	cmp.w	#0,_Select_Button
	beq.s	.pick_end

	move.l	_Ed_RastPort,_Global_RastPort

	jsr	_Orig_Undo_Tile_Palette		; save off for undo of change

	move.l	_Ed_Window,a0
	move.w	wd_MouseX(a0),d0
	move.w	wd_MouseY(a0),d1
	move.l	wd_RPort(a0),a1
	jsr	_ReadPixel
	move.w	d0,_Colour_Edit_1

	jsr	_Change_Highlight_Colour

	st	_Regions_On

	jsr	_Change_RGB_Prop_Gadgets

.pick_shutdown
	jsr	_CleanUp_Routine_Wait
	move.l	#BUTTON_ID_PALETTEPICK,d0
	jsr	_Work_Eor_Select_Gadget	
.pick_end
	rts

;dbgt6:
;_Tile_Work_Palette_Pick:
;	move.l	#BUTTON_ID_PALETTEPICK,d0
;	jsr	_Work_Eor_Select_Gadget
;
;	not.b	_Regions_On
;	lea	.wait_pick,a0
;	jsr	_SetUp_Routine_Wait
;	tst.l	d0
;	bmi.s	.cleanup_pick
;	beq.s	.end_pick
;;	move.w	_Select_Button
;;	move.w	_Colour_Edit_1,_First_Colour
;	bra.s	.end_pick
;.wait_pick
;	cmp.w	#0,_Select_Button
;	beq.s	.end_pick
;
;
;	jsr	_Orig_Undo_Tile_Palette		; save off for undo of change
;
;	move.l	_Ed_Window,a0
;	move.w	wd_MouseX(a0),d0
;	move.w	wd_MouseY(a0),d1
;	move.l	wd_RPort(a0),a1
;	jsr	_ReadPixel
;	move.w	d0,_Colour_Edit_1
;
;	jsr	_Change_Highlight_Colour
;
;	jsr	_Change_RGB_Prop_Gadgets
;	st	_Regions_On
;	move.l	#BUTTON_ID_PALETTEPICK,d0
;	jsr	_Work_Eor_Select_Gadget	
;.cleanup_pick
;	jsr	_CleanUp_Routine_Wait
;.end_pick
;	rts

    STRUCTURE	Stack_Vars1,0
    	APTR	sv1_Colours
	UWORD	sv1_NumChanges
	UWORD	sv1_FirstCol
	UWORD	sv1_LastCol
	UWORD	sv1_FirstRed
	UWORD	sv1_FirstGreen
	UWORD	sv1_FirstBlue
	UWORD	sv1_LastRed
	UWORD	sv1_LastGreen
	UWORD	sv1_LastBlue
	ULONG	sv1_RedDifference
	UWORD	sv1_RedDirection
	ULONG	sv1_RedIncrement
	ULONG	sv1_RedBase
	ULONG	sv1_GreenDifference
	UWORD	sv1_GreenDirection
	ULONG	sv1_GreenIncrement
	ULONG	sv1_GreenBase
	ULONG	sv1_BlueDifference
	UWORD	sv1_BlueDirection
	ULONG	sv1_BlueIncrement
	ULONG	sv1_BlueBase
	LABEL	sv1_SIZEOF

dbgt4:
_Palette_Spread_Colours:	; d0 - colour start, d1 - colour end, a0 - colour set
	nop

	push	lo
	lea	-sv1_SIZEOF(sp),sp
	move.l	sp,lo
	move.l	a0,sv1_Colours(lo)
	ext.l	d0
	ext.l	d1
	cmp.w	d0,d1
	bhi.s	.not_d0_greater_d1
	exg.l	d0,d1
.not_d0_greater_d1
	move.l	d0,d6
	move.l	d1,d7

;
;; find smallest colour index for each colour
;
	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	subq.l	#1,d0
	move.l	d0,d5
	move.l	d6,d1
	jsr	_Find_Greater	; d0 = greater of (d0,d1)
	move.w	d1,sv1_FirstCol(lo)
	move.l	d5,d0
	move.l	d7,d1
	jsr	_Find_Greater	; d0 = greater of (d0,d1)
	move.w	d1,sv1_LastCol(lo)

	move.w	sv1_FirstCol(lo),d0
	sub.w	d0,d1
;	subq.w	#1,d1
	move.w	d1,sv1_NumChanges(lo)

	cmp.w	#1,d1		; no colours in between these two selected colours
	ble	.end_spread
	
;
;; get first colour from colourmap
;	

	move.w	sv1_FirstCol(lo),d0
	jsr	_Get_A_Tile_Colour32
	move.w	d1,sv1_FirstRed(lo)
	move.w	d2,sv1_FirstGreen(lo)
	move.w	d3,sv1_FirstBlue(lo)
	

;
;; get second colour from colourmap
;
	move.w	sv1_LastCol(lo),d0
	jsr	_Get_A_Tile_Colour32
	move.w	d1,sv1_LastRed(lo)
	move.w	d2,sv1_LastGreen(lo)
	move.w	d3,sv1_LastBlue(lo)
;
;; get the difference of the all (RGB) components and their direction (eg +tve -tve)
;
; red
	moveq.l	#0,d0
	move.l	d0,d1
	move.w	sv1_FirstRed(lo),d0
	move.w	sv1_LastRed(lo),d1
	jsr	_Get_Difference
	swap	d0
	move.l	d0,sv1_RedDifference(lo)
	move.w	d1,sv1_RedDirection(lo)
	moveq.l	#0,d1
	move.w	sv1_NumChanges(lo),d1
	jsr	_Divi32
	move.l	d0,sv1_RedIncrement(lo)
; green
	moveq.l	#0,d0
	move.l	d0,d1
	move.w	sv1_FirstGreen(lo),d0
	move.w	sv1_LastGreen(lo),d1
	jsr	_Get_Difference
	swap	d0
	move.l	d0,sv1_GreenDifference(lo)
	move.w	d1,sv1_GreenDirection(lo)
	moveq.l	#0,d1
	move.w	sv1_NumChanges(lo),d1
	jsr	_Divi32
	move.l	d0,sv1_GreenIncrement(lo)
; blue
	moveq.l	#0,d0
	move.l	d0,d1
	move.w	sv1_FirstBlue(lo),d0
	move.w	sv1_LastBlue(lo),d1
	jsr	_Get_Difference
	swap	d0
	move.l	d0,sv1_BlueDifference(lo)
	move.w	d1,sv1_BlueDirection(lo)
	moveq.l	#0,d1
	move.w	sv1_NumChanges(lo),d1
	jsr	_Divi32
	move.l	d0,sv1_BlueIncrement(lo)

	moveq.l	#0,d7		; counter
;
;; perform the loop for the incrementing colours
;

	moveq.l	#0,d0
	move.w	sv1_FirstRed(lo),d0
	swap	d0
	move.l	d0,sv1_RedBase(lo)
	moveq.l	#0,d0
	move.w	sv1_FirstGreen(lo),d0
	swap	d0
	move.l	d0,sv1_GreenBase(lo)
	moveq.l	#0,d0
	move.w	sv1_FirstBlue(lo),d0
	swap	d0
	move.l	d0,sv1_BlueBase(lo)

.while_spread_loop1
	move.w	sv1_NumChanges(lo),d6
	subq.w	#1,d6
	cmp.w	d6,d7
	bhs.s	.end_spread_loop1
	addq.l	#1,d7

	move.l	sv1_BlueBase(lo),d0
	tst.w	sv1_BlueDirection(lo)
	bpl.s	.blue_sign_not_minus
	sub.l	sv1_BlueIncrement(lo),d0
	bra.s	.blue_sign_ok
.blue_sign_not_minus
	add.l	sv1_BlueIncrement(lo),d0
.blue_sign_ok
	move.l	d0,sv1_BlueBase(lo)
	swap	d0
	move.l	d0,d3

	move.l	sv1_GreenBase(lo),d0
	tst.w	sv1_GreenDirection(lo)
	bpl.s	.green_sign_not_minus
	sub.l	sv1_GreenIncrement(lo),d0
	bra.s	.green_sign_ok
.green_sign_not_minus
	add.l	sv1_GreenIncrement(lo),d0
.green_sign_ok
	move.l	d0,sv1_GreenBase(lo)
	swap	d0
	move.l	d0,d2

	move.l	sv1_RedBase(lo),d0
	tst.w	sv1_RedDirection(lo)
	bpl.s	.red_sign_not_minus
	sub.l	sv1_RedIncrement(lo),d0
	bra.s	.red_sign_ok
.red_sign_not_minus
	add.l	sv1_RedIncrement(lo),d0
.red_sign_ok
	move.l	d0,sv1_RedBase(lo)
	swap	d0
	move.l	d0,d1

; do blue
;	move.l	d7,d0				; mult val
;	move.l	sv1_BlueIncrement(lo),d1
;	jsr	_Mult32
;	clr.w	d0
;	swap	d0
;	tst.w	sv1_BlueDirection(lo)
;	bpl.s	.blue_sign_not_minus
;	sub.w	sv1_FirstBlue(lo),d0
;	neg.w	d0
;	bra.s	.blue_sign_ok
;.blue_sign_not_minus
;	add.w	sv1_FirstBlue(lo),d0
;.blue_sign_ok
;	move.w	d0,d3

; do green
;	move.l	d7,d0				; mult val
;	move.l	sv1_GreenIncrement(lo),d1
;	jsr	_Mult32
;	clr.w	d0
;	swap	d0
;	tst.w	sv1_GreenDirection(lo)
;	bpl.s	.green_sign_not_minus
;	sub.w	sv1_FirstGreen(lo),d0
;	neg.w	d0
;	bra.s	.green_sign_ok
;.green_sign_not_minus
;	add.w	sv1_FirstGreen(lo),d0
;.green_sign_ok
;	move.w	d0,d2


;	move.l	d7,d0				; mult val
;	move.l	sv1_RedIncrement(lo),d1
;	jsr	_Mult32
;	clr.w	d0
;	swap	d0
;	tst.w	sv1_RedDirection(lo)
;	bpl.s	.red_sign_not_minus
;	sub.w	sv1_FirstRed(lo),d0
;	neg.w	d0
;	bra.s	.red_sign_ok
;.red_sign_not_minus
;	add.w	sv1_FirstRed(lo),d0
;.red_sign_ok
;	move.w	d0,d1

	move.w	sv1_FirstCol(lo),d0
	add.w	d7,d0
	jsr	_Put_A_Tile_Colour32
	bra	.while_spread_loop1
.end_spread_loop1


.end_spread
	lea	sv1_SIZEOF(sp),sp
	pop	lo
	rts

_Get_Difference:
	push	d2
	moveq.l	#1,d2
	cmp.w	d0,d1
	bhi.s	.not_d0_greater_d1
	exg.l	d0,d1
	moveq.l	#-1,d2
.not_d0_greater_d1
	sub.l	d0,d1
	move.l	d1,d0
	move.l	d2,d1
	pop	d2

	rts

_Calculate_Palette_Size:
	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
;
;;	decide if we are using 24 bit or only 12 bit colour and adjust size
;
	rts

_Set_Tile_Palette:	
	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	move.l	_Ed_ViewPort,a0
	move.l	_Tile_Colours,a1
;	jsr	_LoadRGB4
	jsr	_LoadRGB32
	
	rts

_Set_A_Tile_Colour:	; d0 - colour#
	jsr	_Get_A_Tile_Colour32
	move.l	_Ed_ViewPort,a0
;	jsr	_SetRGB4
	jsr	_SetRGB32
	rts

;_Get_A_Tile_Colour4:	; d0 - colour#
;	move.w	d0,d1
;	add.w	d1,d1
;	move.l	_Tile_Colours,a0
;	move.w	0(a0,d1),d3
;	move.w	d3,d2
;	lsr.w	#4,d2
;	move.w	d3,d1
;	lsr.w	#8,d1
;	move.w	#$F,d4
;	and.w	d4,d1
;	and.w	d4,d2
;	and.w	d4,d3
;	rts	; d0 col#, d1 - r, d2 - g, d3 - b

;_Put_A_Tile_Colour4:	; d0 - colour#, d1 - r, d2 - g, d3 - b 
;	move.w	#$F,d4
;	and.w	d4,d1
;	and.w	d4,d2
;	and.w	d4,d3
;	lsl.w	#8,d1
;	or.w	d3,d1
;	lsl.w	#4,d2
;	or.w	d2,d1
;	move.w	d0,d2
;	add.w	d2,d2
;	move.l	_Tile_Colours,a0
;	move.w	d1,0(a0,d2.w)
;	rts

_Get_A_Tile_Colour32:	; d0 - colour#
	ext.l	d0
	move.l	d0,d4
	add.l	d4,d4
	add.l	d0,d4
	moveq.l	#0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	_Tile_Colours,a0
	move.b	0(a0,d4.l),d1
	move.b	1(a0,d4.l),d2
	move.b	2(a0,d4.l),d3
	rts	; d0 col#, d1 - r, d2 - g, d3 - b

_Put_A_Tile_Colour32:	; d0 - colour#, d1 - r, d2 - g, d3 - b 
	ext.l	d0
	move.l	d0,d4
	add.l	d4,d4
	add.l	d0,d4
	move.l	_Tile_Colours,a0
	move.b	d1,0(a0,d4.l)
	move.b	d2,1(a0,d4.l)
	move.b	d3,2(a0,d4.l)
	rts	; d0 col#, d1 - r, d2 - g, d3 - b


_Orig_Back_Tile_Palette:		; copies original to a backup buffer
	move.l	_Tile_Colours,a0	; from
	move.l	_Backup_Palette,a1	; to
	bra.s	_Copy_Tile_Palette

_Back_Orig_Tile_Palette:		; copies backup to original
	move.l	_Backup_Palette,a0	; from
	move.l	_Tile_Colours,a1	; to
	bra.s	_Copy_Tile_Palette

_Orig_Undo_Tile_Palette:		; copies original to a undo buffer
	move.l	_Tile_Colours,a0	; from
	move.l	_Undo_Palette,a1	; to
	bra.s	_Copy_Tile_Palette

_Orig_Temp_Tile_Palette:		; copies original buff to temp buff
	move.l	_Tile_Colours,a0	; from
	move.l	_Temp_Palette,a1	; to
	bra.s	_Copy_Tile_Palette

_Temp_Undo_Tile_Palette:		; copies temp buff to undo buff
	move.l	_Temp_Palette,a0	; from
	move.l	_Undo_Palette,a1	; to
	bra.s	_Copy_Tile_Palette

_Undo_Orig_Tile_Palette:		; copies undo buff to original
	move.l	_Undo_Palette,a0	; from
	move.l	_Tile_Colours,a1	; to

_Copy_Tile_Palette:
	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	jsr	_Copy_Bytes
	rts


;_Write_In_Colour4:	; d0 - colour#, d1 - colourval, d2 - shiftval
;	push	d0-d2
;	add.w	d0,d0
;	move.l	_Tile_Colours,a0	; to
;	move.w	(a0,d0),d3		; retrieve RGB
;	andi.w	#$F,d1			; mask actual supplied val
;	ror.w	d2,d3			; roll colour around
;	andi.w	#$FFF0,d3		; mask out old R|G|B that we want to keep
;	or.w	d1,d3			; place supplied component into old vals
;	rol.w	d2,d3			; re roll back to orig position
;	move.w	d3,(a0,d0)		; write back new colour
;	pop	d0-d2
;	jsr	_Set_A_Tile_Colour
;	rts

_Write_In_Colour32:	; d0 - colour#, d1 - colourval, d2 - shiftval
	push	d0-d2
	ext.l	d0
	move.l	d0,d3
	add.l	d0,d0
	add.l	d3,d0
	add.w	d2,d0			; val in colourset RGB
	move.l	_Tile_Colours,a0	; to
	move.b	d1,(a0,d0.l)		; write
	pop	d0-d2
	jsr	_Set_A_Tile_Colour
	rts

_Change_RGB_Prop_Gadgets:
	tst.b	_Palette_On
	beq.s	.no_palette_active
	move.w	_Colour_Edit_1,d0
	jsr	_Set_Colour_Prop_Gads
	jsr	_Tile_Work_Palette_Slider_Red
	jsr	_Tile_Work_Palette_Slider_Green
	jsr	_Tile_Work_Palette_Slider_Blue
.no_palette_active
	rts




_Set_Colour_Prop_Gads:	; d0 - colour#
	jsr	_Get_A_Tile_Colour32

	move.l	_Wk_Window,a1
	move.l	wd_FirstGadget(a1),a0

	push	d1-d3/a0-a1

	move.l	#SLIDER_ID_PALETTERED,d0
	jsr	_Find_GadgetID

	move.l	d1,d0
	clr.l	d1
	jsr	_ModifyProp

	pull	d1-d3/a0-a1
	move.l	#SLIDER_ID_PALETTEGREEN,d0
	jsr	_Find_GadgetID

	move.l	d2,d0
	clr.l	d1
	jsr	_ModifyProp

	pull	d1-d3/a0-a1
	move.l	#SLIDER_ID_PALETTEBLUE,d0
	jsr	_Find_GadgetID

	move.l	d3,d0
	clr.l	d1
	jsr	_ModifyProp

	pop	d1-d3/a0-a1
	rts

_ModifyProp:	; d0 - horizpos, d1 - vertpos, a0 - gadget, a1 - window
	push	a6
	move.l	d1,d2
	move.l	d0,d1
	move.l	gg_SpecialInfo(a0),a2
	move.w	pi_Flags(a2),d0
	move.w	pi_HorizBody(a2),d3
	move.w	pi_VertBody(a2),d4
	mulu	d3,d1
	mulu	d4,d2
	
	sub.l	a2,a2
	base	Intuition
	call	ModifyProp
	pop	a6
	rts

_Show_R_G_B_Text:	; d0 buttonid, d1 - x, d2 - y
	push	d1-d2
	move.l	_Wk_Window,a0
	move.l	wd_FirstGadget(a0),a0
	jsr	_Find_GadgetID
	lea	gg_SIZEOF(a0),a0
	clr.l	d2
	move.w	pi_HorizPot(a0),d2
;	cmp.w	#32768,d2
;	bhi.s	.sub_alter
;	add.w	#256,d2
;	bra.s	.no_alter
;.sub_alter
;	sub.w	#256,d2
;.no_alter
	divu	#MAXBODY/255,d2
;	lsr.w	#4,d2
;	lsr.w	#4,d2
;	lsr.w	#4,d2
	ext.l	d2
	pop	d0-d1
	push	d2
	jsr	_Show_RGB_Text
	pop	d1
	rts

_Tile_Work_Palette_Slider_Red:

	jsr	_Show_Palette_Red_Text
	move.w	_Colour_Edit_1,d0
;	move.w	#8,d2			; for rbg4
	move.w	#0,d2
	jsr	_Write_In_Colour32

	rts

_Tile_Work_Palette_Slider_Green:
	jsr	_Show_Palette_Green_Text
	move.w	_Colour_Edit_1,d0
;	move.w	#4,d2			; for rbg4
	move.w	#1,d2
	jsr	_Write_In_Colour32
	rts

_Tile_Work_Palette_Slider_Blue:
	jsr	_Show_Palette_Blue_Text
	move.w	_Colour_Edit_1,d0
;	move.w	#0,d2			; for rbg4
	move.w	#2,d2
	jsr	_Write_In_Colour32
	rts

_Show_Palette_Red_Text:
	move.l	#SLIDER_ID_PALETTERED,d0
	move.l	#48+256,d1
	moveq.l	#7,d2
	jsr	_Show_R_G_B_Text
	rts

_Show_Palette_Green_Text:
	move.l	#SLIDER_ID_PALETTEGREEN,d0
	move.l	#48+256,d1
	moveq.l	#17,d2
	jsr	_Show_R_G_B_Text
	rts

_Show_Palette_Blue_Text:
	move.l	#SLIDER_ID_PALETTEBLUE,d0
	move.l	#48+256,d1
	moveq.l	#27,d2
	jsr	_Show_R_G_B_Text
	rts


_Tile_Work_Palette_RGB_Display:
	move.b	_Palette_Display,d0
	addq.b	#1,d0
	cmp.w	#1,d0
	bls.s	.1
	move.w	#0,d0
.1
	move.b	d0,_Palette_Display
	jsr	_Display_RGB_All_Text
	rts

_Display_RGB_All_Text:
	jsr	_Show_Palette_Red_Text
	jsr	_Show_Palette_Green_Text
	jsr	_Show_Palette_Blue_Text
	rts

_Show_RGB_Text:
	push	d0-d1
	push	d2
	moveq.l	#0,d0
	move.b	_Palette_Display,d0
	mulu	#6,d0
	lea	_Format_RGB,a0
	add.l	d0,a0
	push	a0	
;	pea	_Format_RGB
	pea	_Buffer_RGB
	jsr	_SPrintf
	lea	3*4(sp),sp	
	move.w	#RP_JAM2,d0
	call	_SetDrMd
	pop	d0-d1
	move.l	_Wk_RastPort,_Global_RastPort
	moveq.l	#1,d2
	lea	_Buffer_RGB,a0

;	tst.b	_Palette_Display
;	beq.s	.1
;	addq.w	#3,d0
;.1
	jsr	Display_Text
	rts


_Format_RGB:	DC.B	"%03ld",0
		DC.B	"%02lx ",0

_Buffer_RGB:	DS.B	10

 EVEN

;;- routine to change to the next palette that user has in mem OR create a new palette

_Palette_Work_Prev_PaletteSet:
.minus_palette
	move.w	_Palette_Set-PC(gl),d0
	move.w	#0,d1	; min set
	cmp.w	d1,d0
	beq.s	.ok_minus
	subq.w	#1,d0
	cmp.w	d1,d0
	bgt.s	.minus_ok
	move.w	d1,d0
.minus_ok
;	push	d0
;	jsr	Write_Map_Info
;	jsr	Write_Tile_Info
;	pop	d0
	move.w	d0,_Palette_Set-PC(gl)
	jsr	_Check_Tile_Edit_Screen
.ok_minus
	rts


_Palette_Work_Next_PaletteSet:
.plus_palette
	move.w	_Palette_Set-PC(gl),d0
	move.w	#MAX_PALETTES,d1
	cmp.w	d1,d0
	beq.s	.ok_plus
	addq.w	#1,d0
	cmp.w	d1,d0
	blt.s	.plus_ok
	move.w	d1,d0
.plus_ok
	push	d0
	jsr	_Count_Palette_Nodes		; count nodes
	move.l	d0,d1
	pop	d0
	cmp.w	d1,d0
	blt.s	.not_new_map
	lea	_Text_FileType_Palette,a0
	lea	_Text_Create_New,a1
	push	d0
	jsr	_Ask_Request
	move.l	d0,d1
	pop	d0
	tst.l	d1
	beq.s	.ok_plus
.not_new_map
;	push	d0
;	jsr	Write_Map_Info
;	jsr	Write_Tile_Info
;	pop	d0
	move.w	d0,_Palette_Set-PC(gl)
	jsr	_Check_Tile_Edit_Screen
.ok_plus
	rts


*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****									*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************

_Reset_Tile_Edit_Tools_Buttons:		; d2 - gadget to set
;	move.l	_Wk_Gadgets,a0		; reset all gadgets
;	move.w	#BUTTON_ID_SCRIBBLE,d0	; from this one
;	move.w	#NUMBER_TILE_WORK_TOOLS,d1	; for this count
;	jsr	_Alter_Map_Edit_Tool_List
;	rts

;    ***************************************	
;**** Scribble draw routine for Tile Editor ****
;    ***************************************

_Tile_Work_Scribble:	*********************************
*********************************************************

	move.w	#BUTTON_ID_SCRIBBLE,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.scribble_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#1,_Draw_On
	rts

.scribble_procedure
	lea	.scribble_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.scribble_tool_routine
	move.l	_Use_RastPort,_Global_RastPort
;	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d3
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pop	d0-d3
	jsr	_WritePixel

	move.w	_Tile_Edit_X,d0
	move.w	_Tile_Edit_Y,d1
	move.w	d0,_Line_X1
	move.w	d1,_Line_Y1
	jsr	_WritePixel
	
	rts

_Tile_Work_Draw:	*********************************
*********************************************************

	move.w	#BUTTON_ID_DRAW,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.draw_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#1,_Draw_On
	rts

.draw_procedure
	lea	.draw_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.draw_tool_routine
	move.l	_Use_RastPort,_Global_RastPort
;	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d3
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pop	d0-d3
	jsr	_Line


	move.w	_Tile_Edit_X,d0
	move.w	_Tile_Edit_Y,d1
	move.w	d0,_Line_X1
	move.w	d1,_Line_Y1
	
	rts


_Tile_Work_Line:	*********************************
*********************************************************

	move.w	#BUTTON_ID_LINE,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.line_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#0,_Draw_On	
	rts

.line_procedure
	lea	.line_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.line_tool_routine
	move.l	_Use_RastPort,_Global_RastPort
;	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d3
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pop	d0-d3
	jsr	_Line
	rts

_Tile_Work_Bend:	*********************************
*********************************************************
	move.w	#BUTTON_ID_BEND,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.bend_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#0,_Draw_On
	rts
.bend_procedure
	lea	.bend_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.bend_tool_routine:
	rts


_Tile_Work_Poly:	*********************************
*********************************************************
	move.w	#BUTTON_ID_POLY,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.poly_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#0,_Draw_On
	rts
.poly_procedure
	lea	.poly_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.poly_tool_routine:
	rts

_Tile_Work_Rectangle:	*********************************
*********************************************************
	move.w	#BUTTON_ID_RECTANGLE,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.rectangle_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#0,_Draw_On	
	rts

.rectangle_procedure
	lea	.rectangle_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.rectangle_tool_routine
	move.l	_Use_RastPort,_Global_RastPort
;	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d3
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pop	d0-d3
	jsr	_RectFill
	rts

_Tile_Work_Circle:	*********************************
*********************************************************
	move.w	#BUTTON_ID_CIRCLE,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.circle_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#0,_Draw_On	
	rts

.circle_procedure
	lea	.circle_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.circle_tool_routine
	move.l	_Use_RastPort,_Global_RastPort
;	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d3
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pop	d0-d3
	sub.w	d0,d2
	push	d2
	jsr	_Abs_w
	pop	d2
	move.l	d2,d3
;	jsr	_Circle
	rts

_Abs_w:
	push	d0
	move.l	8(sp),d0
	ext.l	d0
	tst.l	d0
	bpl.s	.num_ok
	neg.l	d0
.num_ok
	move.l	d0,8(sp)
	pop	d0
	rts

_Circle:
	push	a1/a6
	move.l	_Global_RastPort,a1
	base	Graphics
	call	AreaEllipse
	move.l	_Global_RastPort,a1
	call	AreaEnd
	pop	a1/a6
	rts

_Tile_Work_Fill:	*********************************
*********************************************************
	move.w	#BUTTON_ID_FILL,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.fill_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#0,_Draw_On
	rts

.fill_procedure
	lea	.fill_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.fill_tool_routine
	move.l	_Use_RastPort,_Global_RastPort
;	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d3
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pop	d0-d3
	jsr	_Flood_Fill
	rts

_Tile_Work_Cut:	*****************************************
*********************************************************
	move.w	#BUTTON_ID_CUT,d2
	jsr	_Reset_Tile_Edit_Tools_Buttons
	lea	.cut_procedure,a0
	move.l	a0,_Tool_Procedure
	move.w	#0,_Line_On
	move.w	#0,_Draw_On
	rts
.cut_procedure
	lea	.cut_tool_routine(pc),a0
	jsr	_Tool_Parse_Procedure
	rts

.cut_tool_routine:
	rts



_Tool_Parse_Procedure:	*********************************
* executes a procedure on the editing tile		*
*********************************************************
* a0 -> tool procedure to run				*
*********************************************************
	
.tool_procedure
	jsr	_Select_Colour_Depending_On_Button

	cmp.w	#TOOL_DISPLAY_FLAG,d7
	bne	.not_display

	tst.w	_Line_On
	bne.s	.no_display_object
	jsr	Display_Tile_Object

.no_display_object

	tst.w	_Select_Button
	bne.s	.select_ok
	tst.w	_Menu_Button
	beq	.no_display_tool
.select_ok

	cmp.w	#TILE_EDIT_REGION_ID,_Region_Run_ID
	bne	.no_display_tool

	tst.w	_Line_On
	beq	.no_display_tool

;	jsr	_Save_Prev_Coords

	clr.l	d0
	clr.l	d1
	
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Tile_Edit_X,d2
	move.w	_Tile_Edit_Y,d3
	push	d0-d3
	jsr	(a0)

	jsr	_Copy_Tile_Use_To_Screen


	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
;	move.w	_Line_X2,d2
;	move.w	_Line_Y2,d3

	move.w	_Tile_Edit_X,d2
	move.w	_Tile_Edit_Y,d3

	move.w	_Prev_X1,d4
	move.w	_Prev_Y1,d5
	move.w	_Prev_X2,d6
	move.w	_Prev_Y2,d7
	jsr	_Figure_Out_Biggest_Block
	jsr	_Scale_Part_BitMap
	pop	d0-d3
	move.w	d0,_Prev_X1
	move.w	d1,_Prev_Y1
	move.w	d2,_Prev_X2
	move.w	d3,_Prev_Y2

.no_display_tool
	bra	.tool_end
.not_display

	cmp.w	#TOOL_LEAVE_FLAG,d7
	bne.s	.not_leave
	tst.w	_Draw_On
	bne.s	.no_leave_tool
	tst.w	_Line_On
	beq.s	.no_leave_tool
	jsr	_Copy_Tile_Backup_To_Use
.no_leave_tool
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	bra	.tool_end
.not_leave


	cmp.w	#TOOL_RESTORE_FLAG,d7
	bne.s	.not_restore
	tst.w	_Line_On
	bne.s	.no_restore_tool

	jsr	Restore_Tile_Object

	bra	.tool_end

.no_restore_tool
	tst.w	_Draw_On
	bne.s	.no_backup
	jsr	_Copy_Tile_Backup_To_Use
.no_backup
	bra	.tool_end
.not_restore

	cmp.w	#TILE_EDIT_REGION_ID,_Region_Run_ID
	bne	.no_shutdown_tool

	cmp.w	#TOOL_BUTTONDOWN_FLAG,d7
	bne.s	.not_setup
	jsr	_Copy_Tile_Use_To_Backup
	move.w	_Tile_Edit_X,_Line_X1
	move.w	_Tile_Edit_Y,_Line_Y1
	move.w	#1,_Line_On	

	bra	.tool_end
.not_setup
	cmp.w	#TOOL_WRITE_FLAG,d7
	bne.s	.not_write
	move.w	_Tile_Edit_X,_Line_X2
	move.w	_Tile_Edit_Y,_Line_Y2

	bra	.tool_end
.not_write

	cmp.w	#TOOL_BUTTONUP_FLAG,d7
	bne	.not_shutdown

;	move.w	#0,_Draw_On	

	tst.w	_Line_On
	beq	.no_shutdown_tool
	clr.l	d0
	clr.l	d1
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Line_X2,d2
	move.w	_Line_Y2,d3
	push	d0-d3
	jsr	(a0)
	jsr	_Copy_Tile_Use_To_Screen

	

	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Line_X2,d2
	move.w	_Line_Y2,d3

	move.w	_Prev_X1,d4
	move.w	_Prev_Y1,d5
	move.w	_Prev_X2,d6
	move.w	_Prev_Y2,d7
	jsr	_Figure_Out_Biggest_Block

	jsr	_Scale_Part_BitMap
	pop	d0-d3

	move.w	d0,_Prev_X1
	move.w	d1,_Prev_Y1
	move.w	d2,_Prev_X2
	move.w	d3,_Prev_Y2

.no_shutdown_tool
	move.w	#0,_Line_On	
	bra.s	.tool_end
.not_shutdown
	nop
.tool_end
	rts

_Save_Prev_Coords:
;	move.w	_Line_X1,_Prev_X1
;	move.w	_Line_Y1,_Prev_Y1
;	move.w	_Line_X2,_Prev_X2
;	move.w	_Line_Y2,_Prev_Y2

	rts


_Sort_Out_Coordinates:	; d0 d1 d2 d3
	cmp.w	d0,d2
	bhi.s	.x_higher
	exg.l	d0,d2
.x_higher
	cmp.w	d1,d3
	bhi.s	.y_higher
	exg.l	d1,d3
.y_higher

	rts

_Figure_Out_Biggest_Block:	; d0 d1 d2 d3 d4 d5 d6 d7
	jsr	_Sort_Out_Coordinates
	push	d0-d3
	push	d4-d7
	pop	d0-d3
	jsr	_Sort_Out_Coordinates
	push	d0-d3
	pop	d4-d7
	pop	d0-d3

	cmp.w	d0,d4
	bhs.s	.x1_x1_smaller
	exg.l	d0,d4
.x1_x1_smaller

	cmp.w	d1,d5
	bhs.s	.y1_y1_smaller
	exg.l	d1,d5
.y1_y1_smaller

	cmp.w	d2,d6
	bls.s	.x2_x2_higher
	exg.l	d2,d6
.x2_x2_higher
	cmp.w	d3,d7
	bls.s	.y2_y2_higher
	exg.l	d3,d7
.y2_y2_higher
;	move.l	d0,LL1
;	move.l	d1,LL2
;	move.l	d2,LL3
;	move.l	d3,LL4

	rts

;;- draw copy routines so it looks like you are editing smoothly

_Init_Backup_Use_Temp_RastPorts:
	move.w	_Tile_Depth,d0
	move.w	_Tile_Width,d1
	move.w	_Tile_Height,d2
	push	d0-d2
	jsr	_InitBitMapRastPort	; init Backup rastport/bitmap
	move.l	d0,_Backup_RastPort
	move.l	d1,_Backup_BitMap
	pull	d0-d2
	jsr	_InitBitMapRastPort	; init temp rastport/bitmap
	move.l	d0,_Temp_RastPort
	move.l	d1,_Temp_BitMap
	pull	d0-d2
	jsr	_InitBitMapRastPort	; init use rastport/bitmap
	move.l	d0,_Use_RastPort
	move.l	d1,_Use_BitMap
	pop	d0-d2
	push	a6
	push	d1-d2
;	base	Layers
;	jsr	NewLayerInfo
;	move.l	d0,_LayerInfo
;
;	pull	d2-d3
;	moveq.l	#0,d0
;	moveq.l	#0,d1
;	subq.w	#1,d2
;	subq.w	#1,d3
;	move.l	#1,d4
;	move.l	_LayerInfo,a0
;	move.l	_Use_BitMap,a1
;	suba.l	a2,a2
;	jsr	CreateUpfrontLayer
;	move.l	d0,_Layer

	pull	d0-d1

	add.w	#$F,d0
	asr.w	#4,d0
	add.w	d0,d0
	mulu	d0,d1
	move.l	d1,d2			; calc size of raster
	pop	d0-d1
	move.w	d0,_Rast_Width
	move.w	d1,_Rast_Height
	base	Graphics
	call	AllocRaster
	move.l	d0,_TempRaster
	
	lea	_TmpRas,a0
	move.l	_TempRaster,a1
	move.l	d2,d0	
	base	Graphics
	call	InitTmpRas
	
	lea	_AreaInfo,a0
	lea	_Area_Table,a1
	move.l	#100,d0
	base	Graphics
	call	InitArea

	move.l	_Use_RastPort,a0
;	move.l	_LayerInfo,a1
;	move.l	a1,rp_Layer(a0)
	lea	_AreaInfo,a1
	move.l	a1,rp_AreaInfo(a0)

	lea	_TmpRas,a1
	move.l	a1,rp_TmpRas(a0)

	pop	a6

	rts







_Free_Backup_Use_Temp_RastPorts


;	suba.l	a0,a0
;	move.l	_Layer,a1
;	base	Layers
;	jsr	DeleteLayer
;	move.l	_LayerInfo,a0
;	jsr	DisposeLayerInfo
;	pull	a0
	
	push	a6
	lea	_TmpRas,a1
	move.l	tr_RasPtr(a1),a0
	move.w	_Rast_Width,d0
	move.w	_Rast_Height,d1
	base	Graphics
	call	FreeRaster
	pop	a6
	move.l	_Use_RastPort,a0
	jsr	_FreeBitMapRastPort
	move.l	_Temp_RastPort,a0
	jsr	_FreeBitMapRastPort
	move.l	_Backup_RastPort,a0
	jsr	_FreeBitMapRastPort


	rts



_Copy_Tile_Use_To_Original:	; d0 - tile number
	move.l	d0,d3
	ext.l	d3
	mulu	_Tile_Height,d3	; dest x
	moveq.l	#0,d2		; dest y
	move.l	d2,d0		; srce x
	move.l	d0,d1		; scre y
	lea	_Tile_BitMap,a1
	move.l	_Use_BitMap,a0
	bra.s	Copy_BM_3

_Copy_Tile_Original_To_Use:	; d0 - tile number
	move.l	d0,d1
	ext.l	d1
	mulu	_Tile_Height,d1	; srce y
	moveq.l	#0,d0		; srce x
	lea	_Tile_BitMap,a0
	move.l	_Use_BitMap,a1
	bra.s	Copy_BM_2

_Copy_Tile_Temp_To_Use:
	move.l	_Temp_BitMap,a0
	move.l	_Use_BitMap,a1
	bra.s	Copy_BM
_Copy_Tile_Use_To_Temp:
	move.l	_Use_BitMap,a0
	move.l	_Temp_BitMap,a1
	bra.s	Copy_BM
_Copy_Tile_Temp_To_Backup:
	move.l	_Temp_BitMap,a0
	move.l	_Backup_BitMap,a1
	bra.s	Copy_BM
_Copy_Tile_Backup_To_Use:
	move.l	_Backup_BitMap,a0
	move.l	_Use_BitMap,a1
	bra.s	Copy_BM
_Copy_Tile_Use_To_Backup:
	move.l	_Use_BitMap,a0
	move.l	_Backup_BitMap,a1
Copy_BM:
	moveq.l	#0,d0	; srce x
	moveq.l	#0,d1	; srce y
Copy_BM_2:

	moveq.l	#0,d2	; dest x
	moveq.l	#0,d3	; dest y

Copy_BM_3:
	moveq.l	#0,d4	; width
	moveq.l	#0,d5	; height
	move.w	_Tile_Width,d4
	move.w	_Tile_Height,d5
	move.l	#$C0,d6
	move.l	#$FF,d7
	jsr	_BltBitMap
	rts

_Copy_Tile_Use_To_Screen:
	moveq.l	#0,d0			; srce x
	moveq.l	#0,d1			; srce y
	lea	Region_Tile_Tile,a0
	movem.w	rg_LeftEdge(a0),d2-d3	; dest x & dest y
	move.w	_Tile_Width,d4		; width
	move.w	_Tile_Height,d5		; height
	move.l	#$C0,d6			; min term	
	move.l	_Use_BitMap,a0
	move.l	_Ed_RastPort,a1
	push	a6
	base	Graphics
	call	BltBitMapRastPort
	pop	a6
	rts

_Copy_Screen_To_Tile_Use:
	lea	Region_Tile_Tile,a0
	movem.w	rg_LeftEdge(a0),d0-d1	; srce x & srce y
	moveq.l	#0,d2			; dest x
	moveq.l	#0,d3			; dest y
	move.w	_Tile_Width,d4		; width
	move.w	_Tile_Height,d5		; height
	move.l	#$C0,d6			; min term	
	move.l	#$FF,d7
	move.l	_Ed_RastPort,a0
	move.l	rp_BitMap(a0),a0
	move.l	_Use_BitMap,a1
	jsr	_BltBitMap
	rts

; *****
; ** **
; *****

_Tile_Increase_Color0:
	move.l	_Ed_RastPort,_Global_RastPort
	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	subq.w	#1,d0
	move.w	_Colour_Edit_1,d1
	addq.w	#1,d1
	and.w	d0,d1
	move.w	d1,_Colour_Edit_1

	move.w	#-1,_Tile_Last_X

	jsr	_ReDisplay_New_Colour
	jsr	_Change_RGB_Prop_Gadgets
	rts

_Tile_Decrease_Color0:
	move.l	_Ed_RastPort,_Global_RastPort
	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	subq.w	#1,d0
	move.w	_Colour_Edit_1,d1
	subq.w	#1,d1
	and.w	d0,d1
	move.w	d1,_Colour_Edit_1

	move.w	#-1,_Tile_Last_X

	jsr	_ReDisplay_New_Colour
	jsr	_Change_RGB_Prop_Gadgets
	rts

_ReDisplay_New_Colour:
	moveq.l	#0,d0
	jsr	_SetAPen
	move.w	_Colour_Last_1,d0
	jsr	Highlight_Colour		; clear highlight

	move.w	#1,d0
	jsr	_SetAPen
	move.w	_Colour_Edit_1,d0
	move.w	d0,_Colour_Last_1
	jsr	Highlight_Colour		; set highlight
	jsr	_Display_Edit_Colours
	rts

_Tile_Increase_Color1:
	rts

_Tile_Decrease_Color1:
	rts

_Tile_Increase_Depth:
	move.w	_Tile_Depth,d0
	move.w	_Max_Depth,d1
	cmp.w	d1,d0
	beq.s	.depth_fine
	addq.w	#1,d0
	cmp.w	d1,d0
	bls.s	.depth_ok
	move.w	d1,d0
.depth_ok
	move.w	d0,_Tile_Depth
;	jsr	_ReOpen_Tile_Edit_Screen
;	jsr	Close_Tile_Edit_Screen
;	jsr	ReOpen_Tile_Edit_Screen

	jsr	_Close_Tile_Edit_Screen_Window

	jsr	_Init_Backup_Use_Temp_RastPorts
;	jsr	SetUp_Tile_Edit_Screen_Window
	jsr	_Open_Edit_Screen_Tile
	jsr	_Setup_Tile_Edit_Screen_Last

	move.l	_Wk_Screen,a0
	jsr	_ScreenToFront

.depth_fine
	rts

_Tile_Decrease_Depth:
	move.w	_Tile_Depth,d0
	move.w	_Min_Depth,d1
	cmp.w	d1,d0
	beq.s	.depth_fine
	subq.w	#1,d0
	cmp.w	d1,d0
	bhs.s	.depth_ok
	move.w	d1,d0
.depth_ok
	move.w	d0,_Tile_Depth
;	jsr	_ReOpen_Tile_Edit_Screen
;	jsr	Close_Tile_Edit_Screen
;	jsr	ReOpen_Tile_Edit_Screen

	jsr	_Close_Tile_Edit_Screen_Window
	jsr	_Init_Backup_Use_Temp_RastPorts
;	jsr	SetUp_Tile_Edit_Screen_Window
	jsr	_Open_Edit_Screen_Tile
	jsr	_Setup_Tile_Edit_Screen_Last

	move.l	_Wk_Screen,a0
	jsr	_ScreenToFront
.depth_fine
	rts

_Tile_Increase_MagnifyFactor:
	move.w	_Magnify_SizeX,d0
	ext.w	d0
	move.w	#32,d1
	addq.w	#1,d0
	cmp.w	d1,d0
	bls.s	.sizex_ok
	move.w	d1,d0
.sizex_ok
	move.w	d0,_Magnify_SizeX
	move.w	d0,_Magnify_SizeY
	jsr	Region_Edit_Re_Size
	jsr	_Scale_BitMap
	rts

_Tile_Decrease_MagnifyFactor:
	move.w	_Magnify_SizeX,d0
	ext.w	d0
	move.w	#2,d1
	subq.w	#1,d0
	cmp.w	d1,d0
	bhs.s	.sizex_ok
	move.w	d1,d0
.sizex_ok
	move.w	d0,_Magnify_SizeX
	move.w	d0,_Magnify_SizeY
	jsr	Region_Edit_Re_Size
	jsr	_Scale_BitMap
	rts

; ******
; **  **
; ******

_Colour_Box_Table:	;       blkw  blkh  cw ch
;			DC.B	032-1,112-1,32,56,01,02	; 1 ;   2
;			DC.B	032-1,112-1,32,28,01,04	; 2 ;   4
;			DC.B	032-1,112-1,16,28,02,04	; 3 ;   8
;			DC.B	032-1,112-1,16,14,02,08	; 4 ;  16
;			DC.B	032-1,112-1,08,14,04,08	; 5 ;  32
;			DC.B	032-1,112-1,08,07,04,16	; 6 ;  64
;			DC.B	032-1,112-1,04,07,08,16	; 7 ; 128
;			DC.B	032-1,096-1,04,03,08,32	; 8 ; 256

;			DC.B	064-1,064-1,64,32,01,02	; 1 ;   2
;			DC.B	064-1,064-1,64,16,01,04	; 2 ;   4
;			DC.B	064-1,064-1,32,16,02,04	; 3 ;   8
;			DC.B	064-1,064-1,32,08,02,08	; 4 ;  16
;			DC.B	064-1,064-1,16,08,04,08	; 5 ;  32
;			DC.B	064-1,064-1,16,04,04,16	; 6 ;  64
;			DC.B	064-1,064-1,08,04,08,16	; 7 ; 128
;			DC.B	064-1,064-1,04,04,16,16	; 8 ; 256

			DC.B	028-1,112-1,28,56,01,02	; 1 ;   2
			DC.B	028-1,112-1,28,28,01,04	; 2 ;   4
			DC.B	028-1,112-1,14,28,02,04	; 3 ;   8
			DC.B	028-1,112-1,14,14,02,08	; 4 ;  16
			DC.B	028-1,112-1,07,14,04,08	; 5 ;  32
			DC.B	028-1,112-1,07,07,04,16	; 6 ;  64
			DC.B	056-1,112-1,07,07,08,16	; 7 ; 128
			DC.B	112-1,112-1,07,07,16,16	; 8 ; 256

Draw_Colour_Box:
	lea	Region_Tile_Colour,a0
	lea	_Colour_Box_Table,a1
	move.w	_Tile_Depth,d0
	subq.w	#1,d0
	mulu	#cbt_SIZEOF,d0
	add.l	d0,a1
	clr.l	d0
	move.b	cbt_Width(a1),d0
	move.w	d0,rg_Width(a0)
	clr.l	d0
	move.b	cbt_Height(a1),d0
	move.w	d0,rg_Height(a0)
	move.w	rg_LeftEdge(a0),d0
	move.w	rg_TopEdge(a0),d1
	move.b	cbt_ColWidth(a1),d2
	ext.w	d2
	move.b	cbt_ColHeight(a1),d3
	ext.w	d3
	move.w	#0,d4			; colour number
	move.b	cbt_NumWidth(a1),d7
	ext.w	d7
	bra.s	.col_bar_width_pass
.col_bar_width
	push	d1
	move.b	cbt_NumHeight(a1),d6
	ext.w	d6
	bra.s	.col_bar_height_pass
.col_bar_height
	push	d0-d4
	move.w	d4,d0
	jsr	_SetAPen
	pull	d0-d4
	add.w	d0,d2
	add.w	d1,d3
	subq.w	#2,d2
	subq.w	#2,d3
;	addq.w	#1,d0
;	addq.w	#1,d1

;	addq.w	#1,d2
;	addq.w	#1,d3

	jsr	_RectFill
	pop	d0-d4
	add.w	d3,d1
	addq.w	#1,d4
.col_bar_height_pass
	dbra	d6,.col_bar_height
	pop	d1
	add.w	d2,d0

.col_bar_width_pass
	dbra	d7,.col_bar_width
	rts


_Display_Tile_List_Tile:
	lea	Region_Tile_Select,a1
	bra.s	_Display_Tile_List

_Display_Tile_List_Map:
	lea	Region_Map_Choice,a1
_Display_Tile_List:
	moveq.l	#0,d0			; srce x
	move.w	#0,d1			; srce y
	move.w	_Tile_Win_Width,d1
	mulu	_Tile_Top,d1
	mulu	_Tile_Height,d1
	move.w	rg_LeftEdge(a1),d2	; dest x
	move.w	rg_TopEdge(a1),d3	; dest y
	move.w	_Tile_Width,d4		; width
	move.w	_Tile_Height,d5		; height
	lea	_Tile_BitMap,a0		; srce bm
	move.l	_Ed_RastPort,a1
	move.l	rp_BitMap(a1),a1	; dest bm
	move.l	a1,a2			; temp
	move.w	_Tile_Win_Height,d7
	bra.s	.display_height_pass
.display_height
	push	d2
	move.w	_Tile_Win_Width,d6
	bra.s	.display_width_pass
.display_width
	push	d6-d7
	moveq.l	#$CC,d6			; minterm
	moveq.l	#$FF,d7			; mask
	jsr	_BltBitMap
	add.w	d5,d1			; add to srce y
	add.w	d4,d2			; add width to dest x
	pop	d6-d7
.display_width_pass
	dbra	d6,.display_width
	pop	d2
	add.w	d5,d3
.display_height_pass
	dbra	d7,.display_height
	
	rts

Pre_Calculate_Edit_Tile_Select_Region:
	move.l	_Ed_Window,a0
	
	lea	Region_Tile_Select(pc),a1
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	
	move.w	#320,d0
	move.w	_Tile_Width,d1
	move.w	_Tile_Amount,d2
	divu	d1,d0			; width/tilewidth (scale down)
	cmp.w	d2,d0			; if (d0 > amount) {
	blt.s	.tile_choice_width_ok	;     d0 = amount
	move.w	d2,d0			; }
.tile_choice_width_ok
	move.w	d0,d4
	mulu	d1,d0			; width*tilewidth (scale up)
	move.w	d0,rg_Width(a1)

	move.w	wd_Width(a0),d1		; centre ->
;	sub.w	d0,d1
;	lsr.w	#1,d1
	moveq.l	#0,d1
	move.w	d1,rg_LeftEdge(a1)	; centre window
	
	divu	d4,d2			; amount / (scaled)width
	swap	d2
	tst.w	d2
	beq.s	.tile_calc_height_ok
	swap	d2
	ext.l	d2
	addq.w	#1,d2
	swap	d2
.tile_calc_height_ok
	swap	d2

	move.w	#MAXHEIGHT_TILE,d0
	move.w	_Tile_Height,d1
	divu	d1,d0			; scale height = num blocks high
	cmp.w	d2,d0			; if (d0 > scaled amount)
	blt.s	.tile_choice_height_ok  ;     d0 = scaled amount
	move.w	d2,d0			; }
.tile_choice_height_ok
	mulu	d1,d0			; rescale height
	move.w	d0,rg_Height(a1)

;	lea	Region_Map_Edit(pc),a2
;	move.w	rg_TopEdge(a2),d0	; place choice region directly
;	add.w	rg_Height(a2),d0	; under map edit region
;	btst	#FLAG0B_SLIDER_Y_ON,_Preference_Flags0
;	beq.s	.no_slider_for_y
;	add.w	#MAPSCROLLERX_HEIGHT,d0
;.no_slider_for_y
	move.l	#200-64,d0
	move.w	d0,rg_TopEdge(a1)

	rts

Calculate_Tile_Select_Boundries:
	lea	Region_Tile_Select,a1
	clr.l	d0
	move.w	rg_Width(a1),d0		; width
	divu	_Tile_Width,d0
	move.w	_Tile_Amount,d1
	cmp.w	d1,d0
	bls.s	.1
	move.w	d1,d0
.1
	move.w	d0,_Tile_Win_Width
	clr.l	d0
	move.w	rg_Height(a1),d0		; height
	divu	_Tile_Height,d0
	move.w	d0,_Tile_Win_Height
	rts


Region_Edit_Re_Size:
	move.l	_Ed_RastPort,_Global_RastPort
	lea	Region_Tile_Edit,a1
	movem.w	rg_LeftEdge(a1),d0-d3

	jsr	_Convert_Coords
	subq.w	#1,d0
	subq.w	#1,d1
	addq.w	#1,d2
	addq.w	#1,d3

	push	d0-d3/a1

	move.w	_Magnify_SizeX,d2
	move.w	d2,d0
	mulu	_Tile_Width,d0			; max pixels mag will be
	move.w	#MAXEDIT_WIDTH,d1		; is it greater than 128 pixels
	cmp.w	d1,d0
	bls.s	.width_smaller
	move.w	d1,d0				; yes > 128 pixels
	divu	d2,d0				; div 128 by mag size
	ext.l	d0
	mulu	d2,d0				; should be width of region as per mag size
.width_smaller
	move.w	d0,rg_Width(a1)
	move.l	d0,d1
	divu	d2,d1
	ext.l	d1
	move.l	d1,d2
	add.w	_Magnify_CX,d1
	move.w	_Tile_Width,d3
	cmp.w	d3,d1
	blo.s	.wp_smaller
	move.w	d3,d1
.wp_smaller	
	sub.w	d2,d1
	move.w	d1,_Magnify_CX


	move.w	#MAXEDIT_WIDTH,d1
	sub.w	d0,d1
	lsr.w	#1,d1
	addq.w	#1,d1				; ****
	move.w	d1,rg_LeftEdge(a1)

	move.w	_Magnify_SizeY,d2
	move.w	d2,d0
	mulu	_Tile_Height,d0
	move.w	#MAXEDIT_HEIGHT,d1
	cmp.w	d1,d0
	bls.s	.height_smaller
	move.w	d1,d0
	divu	d2,d0
	ext.l	d0
	mulu	d2,d0
.height_smaller
	move.w	d0,rg_Height(a1)

	move.l	d0,d1
	divu	d2,d1
	ext.l	d1
	move.l	d1,d2
	add.w	_Magnify_CY,d1
	move.w	_Tile_Height,d3
	cmp.w	d3,d1
	blo.s	.hp_smaller
	move.w	d3,d1
.hp_smaller	
	sub.w	d2,d1
	move.w	d1,_Magnify_CY

	move.w	#MAXEDIT_HEIGHT,d1
	sub.w	d0,d1
	lsr.w	#1,d1
	addq.w	#1,d1				; ****
	move.w	d1,rg_TopEdge(a1)

	push	a1
	lea	Region_Tile_Tile,a1
	move.w	_Tile_Width,rg_Width(a1)
	move.w	_Tile_Height,rg_Height(a1)
	pop	a1

	move.w	#-1,_Tile_Last_X
dbg48:
	moveq.l	#1,d0
	jsr	_SetAPen
	pull	d0-d3/a1

	movem.w	rg_LeftEdge(a1),d0-d3
	jsr	_Convert_Coords
	subq.w	#1,d0
	subq.w	#1,d1
	addq.w	#1,d2
	addq.w	#1,d3
	push	d0-d3
	jsr	_Draw_Lowered_Box
	moveq.l	#0,d0
	jsr	_SetAPen

	pop	d4-d7
	subq.w	#1,d4
	subq.w	#1,d5
	addq.w	#1,d6
	addq.w	#1,d7

	pop	d0-d3/a1

	cmp.w	d0,d4
	blt.s	.no_left_right_clear
	push	d0-d7
	move.w	d4,d2
	jsr	_RectFill	; left

	pull	d0-d7
	move.w	d6,d0
	jsr	_RectFill	; right
	pop	d0-d7
.no_left_right_clear

	cmp.w	d1,d5
	blt.s	.no_top_bottom_clear

	push	d0-d7
	move.w	d5,d3
	jsr	_RectFill	; top

	pull	d0-d7
	move.w	d7,d1
	jsr	_RectFill	; bottom
	pop	d0-d7
.no_top_bottom_clear

	rts

_Convert_Coords:
	add.w	d0,d2
	add.w	d1,d3
	subq.w	#1,d2
	subq.w	#1,d3
	rts


_Scale_Part_BitMap:	*********************************
* d0 - x1 pos						*
* d1 - y1
* d2 - x2
* d3 - y2
*********************************************************
	cmp.w	#1,_Magnify_SizeX
	bne.s	.magnify_bigger_1

	rts
.magnify_bigger_1

	lea	-bsa_SIZEOF(sp),sp
	move.l	sp,a0

	cmp.w	d0,d2
	bhi.s	.x_higher
	exg.l	d0,d2
.x_higher
	cmp.w	d1,d3
	bhi.s	.y_higher
	exg.l	d1,d3
.y_higher

	move.w	_Magnify_CX,d4
	cmp.w	d4,d0
	bhi.s	.x1_higher
	move.l	d4,d0
;	moveq.l	#0,d0
.x1_higher

	move.w	_Magnify_CY,d5
	cmp.w	d5,d1
	bhi.s	.y1_higher
	move.l	d5,d1
;	moveq.l	#0,d1
.y1_higher
	


	lea	Region_Tile_Edit,a1	; pos to mag window

	move.w	rg_Width(a1),d4
	divu	_Magnify_SizeX,d4
	add.w	_Magnify_CX,d4
	subq.w	#1,d4
	cmp.w	d4,d2
	bls.s	.x2_lower
	move.l	d4,d2
.x2_lower

	move.w	rg_Height(a1),d5
	divu	_Magnify_SizeY,d5
	subq.w	#1,d5
	add.w	_Magnify_CY,d5
	cmp.w	d5,d3
	bls.s	.y2_lower
	move.l	d5,d3
.y2_lower

	sub.w	_Magnify_CX,d0
	sub.w	_Magnify_CY,d1
	sub.w	_Magnify_CX,d2
	sub.w	_Magnify_CY,d3

;	move.l	_Ed_RastPort,_Global_RastPort
;	push	d0-d3
;	moveq.l	#3,d0
;	jsr	_SetAPen
;	
;	pop	d0-d3	
;
;	jsr	_Line
;
;;.end_scale
;	lea	bsa_SIZEOF(sp),sp
;	rts

	sub.w	d0,d2
	sub.w	d1,d3
	add.w	#1,d2
	add.w	#1,d3


	tst.w	d2
;	beq	.end_scale
	bmi	.end_scale
	tst.w	d3
;	beq	.end_scale
	bmi	.end_scale

	andi.l	#$FFFF,d0
	andi.l	#$FFFF,d1
	andi.l	#$FFFF,d2
	andi.l	#$FFFF,d3


;	move.l	d0,LL1
;	move.l	d1,LL2
;	move.l	d2,LL3
;	move.l	d3,LL4
	
	lea	Region_Tile_Tile,a1

	move.l	d0,d4			; pos from edit tile
	add.w	_Magnify_CX,d4
	add.w	rg_LeftEdge(a1),d4
	move.w	d4,bsa_SrcX(a0)

	move.l	d1,d5
	add.w	_Magnify_CY,d5
	add.w	rg_TopEdge(a1),d5
	move.w	d5,bsa_SrcY(a0)


	move.w	#1,d4
	move.w	d4,bsa_XSrcFactor(a0)
	move.w	d4,bsa_YSrcFactor(a0)


	move.w	d2,bsa_DestWidth(a0)	; to width
	move.w	d3,bsa_DestHeight(a0)	; to height
	move.w	d2,bsa_SrcWidth(a0)
	move.w	d3,bsa_SrcHeight(a0)	

	move.w	_Magnify_SizeX,bsa_XDestFactor(a0)
	move.w	_Magnify_SizeY,bsa_YDestFactor(a0)


	lea	Region_Tile_Edit,a1	; pos to mag window

;	sub.w	_Magnify_CX,d0
;	sub.w	_Magnify_CY,d1

;	addq.w	#1,d0
;	addq.w	#1,d1

;	move.l	d0,LL1
;	move.l	d1,LL2
;	move.l	d2,LL3
;	move.l	d3,LL4

	mulu	_Magnify_SizeX,d0
	add.w	rg_LeftEdge(a1),d0
	move.w	d0,bsa_DestX(a0)

	mulu	_Magnify_SizeY,d1
	add.w	rg_TopEdge(a1),d1
	move.w	d1,bsa_DestY(a0)



;	move.l	_Global_RastPort,a1
	move.l	_Ed_RastPort,a1
	move.l	rp_BitMap(a1),bsa_SrcBitMap(a0)
	move.l	rp_BitMap(a1),bsa_DestBitMap(a0)

	clr.l	bsa_Flags(a0)
	clr.w	bsa_XDDA(a0)
	clr.w	bsa_YDDA(a0)
	clr.l	bsa_Reserved1(a0)
	clr.l	bsa_Reserved2(a0)


	push	a6
	base	Graphics
	call	BitMapScale
	pop	a6

.end_scale
	lea	bsa_SIZEOF(sp),sp
	rts

_Scale_BitMap:

	cmp.w	#1,_Magnify_SizeX
	bne.s	.magnify_bigger_1

	rts
.magnify_bigger_1
	lea	-bsa_SIZEOF(sp),sp
	move.l	sp,a0

	lea	Region_Tile_Tile,a1

	moveq.l	#0,d0
	move.w	_Magnify_CX,d0
	add.w	rg_LeftEdge(a1),d0
	move.w	d0,bsa_SrcX(a0)

	move.w	_Magnify_CY,d0
	add.w	rg_TopEdge(a1),d0
	move.w	d0,bsa_SrcY(a0)

	lea	Region_Tile_Edit,a1
	move.w	rg_LeftEdge(a1),bsa_DestX(a0)
	move.w	rg_TopEdge(a1),bsa_DestY(a0)

	move.w	#1,d0
	move.w	d0,bsa_XSrcFactor(a0)
	move.w	d0,bsa_YSrcFactor(a0)

	moveq.l	#0,d0
	move.w	rg_Width(a1),d0
	move.w	d0,bsa_DestWidth(a0)

	moveq.l	#0,d1
	move.w	_Magnify_SizeX,d1
	move.w	d1,bsa_XDestFactor(a0)
	divu	d1,d0
	move.w	d0,bsa_SrcWidth(a0)

	moveq.l	#0,d0
	move.w	rg_Height(a1),d0
	move.w	d0,bsa_DestHeight(a0)

	moveq.l	#0,d1
	move.w	_Magnify_SizeY,d1
	move.w	d1,bsa_YDestFactor(a0)
	divu	d1,d0
	move.w	d0,bsa_SrcHeight(a0)	

;	move.l	_Global_RastPort,a1
	move.l	_Ed_RastPort,a1
	move.l	rp_BitMap(a1),bsa_SrcBitMap(a0)
	move.l	rp_BitMap(a1),bsa_DestBitMap(a0)

	clr.l	bsa_Flags(a0)
	clr.w	bsa_XDDA(a0)
	clr.w	bsa_YDDA(a0)
	clr.l	bsa_Reserved1(a0)
	clr.l	bsa_Reserved2(a0)

	push	a6
	base	Graphics
	call	BitMapScale
	pop	a6

	lea	bsa_SIZEOF(sp),sp
	rts


_Select_Colour_Depending_On_Button
	move.w	_Colour_Edit_1,_Colour_Edit
	cmp.w	#TILE_EDIT_REGION_ID,_Menu_Button
	bne.s	.not_menu
	move.w	_Colour_Edit_0,_Colour_Edit	
.not_menu
	rts


;Function_On_Use:
;	move.l	_Use_RastPort,_Global_RastPort
;	moveq.l	#2,d0
;	jsr	_SetAPen
;	moveq.l	#0,d0
;	moveq.l	#0,d1
;	move.l	_X,d2
;	move.l	_Y,d3
;	jsr	_RectFill
;	rts

_Flood_Fill:	; d0 - x, d1 - y
;	push	d0-d2/a1/a6
;	moveq.l	#1,d2
;	move.l	_Global_RastPort,a1
;	base	Graphics
;	jsr	Flood
;	pop	d0-d2/a1/a6
;	rts

_Fill:			; d0 - x in tile ; d1 - y in tile
	push	d0-d1
	jsr	_ReadPixel
	move.w	d0,d6
	pop	d0-d1
	cmp.w	_Colour_Edit,d6
	bne.s	Fill_Start
	rts

Fill_Start:
	push	d0-d4
	move.w	d0,d2
	move.w	d1,d3
200$
	bsr.s	Fill_Check_Bounds
	bne.s	210$
	bsr.s	Fill_Set_Pixel
	subq.w	#1,d0
	bra.s	200$
210$
	addq.w	#1,d0
	exg	d0,d2
	addq.w	#1,d0
300$
	bsr.s	Fill_Check_Bounds
	bne.s	310$
	bsr.s	Fill_Set_Pixel
	addq.w	#1,d0
	bra.s	300$
310$
	subq.w	#1,d0
	move.w	d0,d4
	move.w	d2,d0
	addq.w	#1,d1
	bsr.s	Fill_Foward
	move.w	d2,d0
	move.w	d3,d1
	subq.w	#1,d1
	bsr.s	Fill_Foward
	pop	d0-d4
	rts

Fill_Foward:
	bsr.s	Fill_Check_Bounds
	bne.s	10$
	bsr.s	Fill_Start
10$
	addq.w	#1,d0
	cmp.w	d0,d4
	bge.s	Fill_Foward
	rts

Fill_Check_Bounds:
	tst.w	d0
	bmi.s	Fill_Set_Flag
	tst.w	d1
	bmi.s	Fill_Set_Flag
	cmp.w	_Tile_Width,d0
	bge.s	Fill_Set_Flag
	cmp.w	_Tile_Height,d1
	bge.s	Fill_Set_Flag
	push	d0-d1
	jsr	_ReadPixel
	move.w	d0,d5
	cmp.b	d5,d6
	pop	d0-d1
	rts

Fill_Set_Flag:
	andi.b	#$FB,CCR
	rts

Fill_Set_Pixel:
	push	d0-d2
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pull	d0-d2
;	add.l	Mag_Srce_X-PC(a5),d0
;	add.l	Mag_Srce_Y-PC(a5),d1
	jsr	_WritePixel
	pop	d0-d2
	rts





	IFD	DUGBARRY

Function_Copy:
	tst.b	Function_2nd_Prep-PC(a5)
	bne.s	.900
	jsr	Save_Tile_From_Screen
	move.l	Mag_Srce_X-PC(a5),d0	; sx
	move.l	Mag_Srce_Y-PC(a5),d1	; sy
	move.l	#200,d2			; dx
	move.l	#000,d3			; dy
	move.w	Var_TileWidth-PC(a5),d4
	move.w	Var_TileHeight-PC(a5),d5

	move.w	#$C0,d6
	move.w	#$FF,d7	
	move.l	BitMap2-PC(a5),a0
	move.l	BitMap2-PC(a5),a1
	move.l	BitMap2-PC(a5),a2
	jsr	BltBitMap	
	jsr	Magnify_Part_2_0
	move.b	#0,Function_NCS-PC(a5)
	move.b	#$80,Function_2nd_Prep-PC(a5)
.900
	rts

Function_Paste:
	tst.b	Function_2nd_Prep-PC(a5)
	bne.s	.900
	jsr	Save_Tile_From_Screen
	move.l	#200,d0			; sx
	move.l	#000,d1			; sy
	move.l	Mag_Srce_X-PC(a5),d2	; dx
	move.l	Mag_Srce_Y-PC(a5),d3	; dy
	move.w	Var_TileWidth-PC(a5),d4
	move.w	Var_TileHeight-PC(a5),d5
	move.w	#$C0,d6
	move.w	#$FF,d7	
	move.l	BitMap2-PC(a5),a0
	move.l	BitMap2-PC(a5),a1
	move.l	BitMap2-PC(a5),a2
	jsr	BltBitMap	
	jsr	Magnify_Part_2_0
	move.b	#0,Function_NCS-PC(a5)
	move.b	#$80,Function_2nd_Prep-PC(a5)
.900
	rts

Merge:
	move.l	Mag_Srce_X-PC(a5),d0
	move.l	Mag_Srce_Y-PC(a5),d1
	moveq.l	#0,d2
	move.w	Function_Var1-PC(a5),d3
	mulu	Var_TileHeight,d3
	move.w	Var_TileHeight-PC(a5),d7
	subq.w	#1,d7
10$
	move.w	Var_TileWidth-PC(a5),d6
	subq.w	#1,d6
20$
	movem.l	d0-d3/d6-d7,-(sp)
	move.l	RastPort2-PC(a5),RP-PC(a5)
	add.w	d6,d0
	add.w	d7,d1
	jsr	ReadPixel
	cmp.w	Var_Color0-PC(a5),d0
	bne.s	50$
	movem.l	(sp),d0-d3/d6-d7
	move.l	TileRastPort-PC(a5),RP-PC(a5)
	exg.l	d0,d2
	exg.l	d1,d3
	add.w	d6,d0
	add.w	d7,d1
	jsr	ReadPixel
	move.l	RastPort2-PC(a5),RP-PC(a5)
	jsr	SetAPen
	exg.l	d0,d2
	exg.l	d1,d3
	add.w	d6,d0
	add.w	d7,d1
	jsr	WritePixel
50$
	movem.l	(sp)+,d0-d3/d6-d7
	dbra	d6,20$
	dbra	d7,10$
	rts

Duplicate:
	moveq.l	#0,d0			; sx
	move.w	Function_Var1-PC(a5),d1
	mulu	Var_TileHeight,d1	; sy
	move.l	Mag_Srce_X-PC(a5),d2	; dx
	move.l	Mag_Srce_Y-PC(a5),d3	; dy

	move.w	Var_TileWidth-PC(a5),d4
	move.w	Var_TileHeight-PC(a5),d5
	move.w	#$C0,d6
	move.w	#$FF,d7	
	move.l	TileBitMap-PC(a5),a0
	move.l	BitMap2-PC(a5),a1
	move.l	BitMap2-PC(a5),a2
	jsr	BltBitMap	

	rts

	ENDC
 ENDC

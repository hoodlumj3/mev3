 IFND	MEV3_MAP_FUNCS_S
MEV3_MAP_FUNCS_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC


*
*
* $VER:mev3_map_funcs.s 39.01  © (00/April/94) M.J.Edwards
*
*

;****************************************************
;                   Map Functions
;****************************************************

_Reset_Map_Edit_Tools_Buttons:		; d2 - gadget to set

	move.l	_Wk_Gadgets,a0		; reset all gadgets
	move.w	#BUTTON_ID_SCRIBBLE,d0	; from this one
	move.w	#NUMBER_WORK_TOOLS,d1	; for this count
	bsr	_Alter_Map_Edit_Tool_List
.reset_end
	rts

_Alter_Map_Edit_Tool_List:	; d0 - first gadget ID, d1 - # gads, d2 - Gadget to set, a0 - gadgets
	push	d1
	jsr	_ResetGadgets

	push	a0
	move.w	d2,d0
	jsr	_Find_GadgetID
	ori.w	#(GFLG_SELECTED),gg_Flags(a0)	; turn on gadget
	pop	a0

	pop	d0
	
	move.l	_Wk_Window,a1
	jsr	_RefreshGList
	rts

;    **************************************	
;**** Scribble draw routine for Map Editor ****
;    **************************************

_Map_Work_Scribble:
	move.w	#BUTTON_ID_SCRIBBLE,d2
	bsr	_Reset_Map_Edit_Tools_Buttons
	lea	.scribble_procedure,a0
	move.l	a0,_Tool_Procedure
.reset_end
	rts

.scribble_procedure
	cmp.w	#TOOL_DISPLAY_FLAG,d7
	bne.s	.not_display
	bsr	Display_Object
	bra.s	.scribble_end
.not_display
	cmp.w	#TOOL_RESTORE_FLAG,d7
	bne.s	.not_restore
	bsr	Restore_Object
	bra.s	.scribble_end
.not_restore
	cmp.w	#TOOL_WRITE_FLAG,d7
	bne.s	.not_write
	bsr	Write_Object
	bra.s	.scribble_end
.not_write
	nop
.scribble_end
	rts

;    **********************************	
;**** Line draw routine for Map Editor ****
;    **********************************

_Map_Work_Line:
	move.w	#BUTTON_ID_LINE,d2
	bsr	_Reset_Map_Edit_Tools_Buttons
	lea	.line_procedure,a0
	move.l	a0,_Tool_Procedure
	move.b	#0,_Line_On
	rts

.line_procedure

	cmp.w	#TOOL_DISPLAY_FLAG,d7		; **
	bne.s	.not_display

	; This is only here to display the shape/object if
	; the user is in the edit window but has not pressed the
	; select button
	; {

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne.s	.no_display_object
	tst.b	_Line_On		; is line on?
	bne.s	.no_display_object	; yes so leave
	bsr	Display_Object		; it is? well display it on screen then
;	bra.s	.no_display_line
.no_display_object
	; }

	; This bit of code is used when the user is in the edit window,
	; has pressed the select button and is holding it down
	; {
	cmp.w	#MAP_EDIT_REGION_ID,_Select_Button
	bne.s	.no_display_line

	tst.b	_Line_On
	beq.s	.no_display_line
	clr.l	d0
	clr.l	d1
	
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Edit_X,d2
	move.w	_Map_Edit_Y,d3
	lea	_Show_Line_Tile,a0
	jsr	_Draw_Map_Line
;	bsr	Display_Object
.no_display_line
	; }
	bra	.line_end
.not_display
	cmp.w	#TOOL_RESTORE_FLAG,d7		; **
	bne.s	.not_restore

	; This code : user is in edit window and button has not yet
	; been pressed
	; {

	tst.b	_Line_On
	bne.s	.no_restore_object
	bsr	Restore_Object

;	jsr	_Show_Shape_Tiles

;	bra.s	.no_restore_line
.no_restore_object
	; }

	; This code : in edit window, button is pressed and is held down
	; {
	tst.b	_Line_On
	beq.s	.no_restore_line

	tst.w	_Map_Last_X
	bmi.s	.no_restore_line
	clr.l	d0
	clr.l	d1
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Last_X,d2
	move.w	_Map_Last_Y,d3
	lea	_Restore_Line_Tile,a0
	jsr	_Draw_Map_Line

;	bsr	Restore_Object
.no_restore_line
	; }
	bra	.line_end
.not_restore
	cmp.w	#TOOL_BUTTONDOWN_FLAG,d7		; **
	bne.s	.not_setup
	move.w	_Map_Edit_X,_Line_X1
	move.w	_Map_Edit_Y,_Line_Y1
	move.b	#1,_Line_On	
	bra	.line_end
.not_setup
	cmp.w	#TOOL_WRITE_FLAG,d7		; **
	bne.s	.not_write

	move.w	_Map_Edit_X,_Line_X2
	move.w	_Map_Edit_Y,_Line_Y2

;	bsr	Write_Object

	bra.s	.line_end
.not_write
	cmp.w	#TOOL_BUTTONUP_FLAG,d7		; **
	bne.s	.not_shutdown
	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne.s	.no_shutdown_line
	tst.b	_Line_On
	beq.s	.no_shutdown_line

	clr.l	d0
	clr.l	d1
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Edit_X,d2
	move.w	_Map_Edit_Y,d3
	lea	_Write_Line_Tile,a0
;	lea	_Write_Object,a0
	jsr	_Draw_Map_Line

.no_shutdown_line
	move.b	#0,_Line_On	
	bra.s	.line_end
.not_shutdown
	nop
.line_end
	rts

_Write_Line_Tile:
	push	d0-d7/a0-a6
	bsr	Write_Object
	pop	d0-d7/a0-a6
	rts

_Restore_Line_Tile:
	push	d0-d7/a0-a6
	bsr	Restore_Object_1
	pop	d0-d7/a0-a6
	rts

_Show_Line_Tile:
	push	d0-d7/a0-a6
	bsr	Display_Object
	pop	d0-d7/a0-a6
	rts



;    ***************************************	
;**** Rectangle draw routine for Map Editor ****
;    ***************************************

_Map_Work_Rectangle:
	move.l	#BUTTON_ID_RECTANGLE,d0
	move.l	_Wk_Gadgets,a0
	jsr	_Find_GadgetID
;	lea	Work_Image_Array,a1

	cmp.w	#7,d1
	bhi.s	.set_filled_rectangle
.set_normal_rectangle
;	move.l	#IMAGE_RECTANGLE1*ia_SIZEOF,d1
;	move.l	(a1,d1.w),gg_GadgetText(a0)
	move.w	#0,_Rectangle_Filled
			
	bra.s	.end_set_rectangle
.set_filled_rectangle
;	move.l	#IMAGE_RECTANGLE2*ia_SIZEOF,d1
;	move.l	(a1,d1.w),gg_GadgetText(a0)
	move.w	#1,_Rectangle_Filled
.end_set_rectangle
	move.w	#BUTTON_ID_RECTANGLE,d2
	push	a0-a1
	bsr	_Reset_Map_Edit_Tools_Buttons
	pop	a0-a1
;	move.l	#IMAGE_RECTANGLE*ia_SIZEOF,d1
;	move.l	(a1,d1.w),gg_GadgetText(a0)

	lea	.rectangle_procedure,a0
	move.l	a0,_Tool_Procedure
	move.b	#0,_Rectangle_On
;	move.w	#0,_Rectangle_Filled
	rts

.rectangle_procedure
	cmp.w	#TOOL_DISPLAY_FLAG,d7		; **
	bne.s	.not_display

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne.s	.no_display_object
	tst.b	_Rectangle_On
	bne.s	.no_display_object
	bsr	Display_Object
;	bra.s	.no_display_line
.no_display_object
	cmp.w	#MAP_EDIT_REGION_ID,_Select_Button
	bne.s	.no_draw_rectangle

	tst.b	_Rectangle_On
	beq.s	.no_draw_rectangle
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Edit_X,d2
	move.w	_Map_Edit_Y,d3
	lea	_Show_Line_Tile,a0
	jsr	_Rectangle_Tile
;	bsr	Display_Object
.no_draw_rectangle
;	btst	#0,_Shape_Ed
;	beq.s	.no_show_edit_shape
;	jsr	_Show_Shape_Tiles
;.no_show_edit_shape

	bra	.rectangle_end
.not_display
	cmp.w	#TOOL_RESTORE_FLAG,d7		; **
	bne.s	.not_restore

	tst.b	_Rectangle_On
	bne.s	.no_restore_object
	bsr	Restore_Object

;	bra.s	.no_restore_line
.no_restore_object

	tst.b	_Rectangle_On
	beq.s	.no_restore_rectangle
;	tst.w	_Map_Last_X
;	bmi.s	.no_restore_rectangle
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3

	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Last_X,d2
	move.w	_Map_Last_Y,d3
	lea	_Restore_Line_Tile,a0
	jsr	_Rectangle_Tile
;	bsr	Restore_Object
.no_restore_rectangle
	bra	.rectangle_end
.not_restore
	cmp.w	#TOOL_BUTTONDOWN_FLAG,d7		; **
	bne.s	.not_setup
	move.w	_Map_Edit_X,_Line_X1
	move.w	_Map_Edit_Y,_Line_Y1
	move.b	#1,_Rectangle_On	
	bra	.rectangle_end
.not_setup
	cmp.w	#TOOL_WRITE_FLAG,d7
	bne.s	.not_write

	move.w	_Map_Edit_X,_Line_X2
	move.w	_Map_Edit_Y,_Line_Y2

	bra	.rectangle_end
.not_write
	cmp.w	#TOOL_BUTTONUP_FLAG,d7		; **
	bne.s	.not_shutdown

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne.s	.no_shutdown_rectangle

	tst.b	_Rectangle_On
	beq.s	.no_shutdown_rectangle
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
;	move.w	_Line_X2,d2
;	move.w	_Line_Y2,d3
	move.w	_Map_Edit_X,d2
	move.w	_Map_Edit_Y,d3
	lea	_Write_Line_Tile,a0
	jsr	_Rectangle_Tile

.no_shutdown_rectangle
	move.b	#0,_Rectangle_On	
	bra.s	.rectangle_end
.not_shutdown
	nop
.rectangle_end
	rts

_Rectangle_Tile:	; d0 - x1, d1 - y1, d2 - x2, d3 - y2, a0 - plot routine
	tst.w	_Rectangle_Filled
	bne.s	.draw_rectangle_filled
	push	d0-d3
	move.w	d1,d3		; top line
	jsr	_Draw_Horizontal_Line
	pull	d0-d3
	move.w	d2,d0		; right line
	jsr	_Draw_Verticle_Line
	pull	d0-d3
	move.w	d3,d1		; bottom line
	jsr	_Draw_Horizontal_Line
	pull	d0-d3
	move.w	d0,d2		; left line
	jsr	_Draw_Verticle_Line
	pop	d0-d3
	bra.s	.draw_rectangle_end
.draw_rectangle_filled

	push	d0-d3

	cmp.w	d3,d1
	bge.s	.10
	exg.l	d3,d1
.10
	sub.w	d3,d1
.next_width
	push	d0-d3
	add.w	d3,d1
	jsr	_Draw_Horizontal_Line
	pop	d0-d3
	dbra	d1,.next_width

	pop	d0-d3
.draw_rectangle_end
	rts

;    ****************************	
;**** Cut routine for Map Editor ****
;    ****************************


_Map_Work_Cut:
	move.w	#BUTTON_ID_CUT,d2
	bsr	_Reset_Map_Edit_Tools_Buttons
	lea	.cut_procedure,a0
	move.l	a0,_Tool_Procedure
	move.b	#0,_Cut_On
	rts

.cut_procedure
	cmp.w	#TOOL_DISPLAY_FLAG,d7		; **
	bne.s	.not_display

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne.s	.no_draw_cut
	tst.b	_Cut_On
	bne.s	.no_display_object

	clr.l	d0
	clr.l	d1
	
;	move.w	_Line_X1,d0
;	move.w	_Line_Y1,d1
	move.w	_Map_Edit_X,d0
	move.w	_Map_Edit_Y,d1
	move.l	d0,d2
	move.l	d1,d3
	jsr	_Display_Cut_Tile

	bra.s	.no_draw_cut
.no_display_object
;	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
;	bne.s	.no_draw_cut

	tst.b	_Cut_On
	beq.s	.no_draw_cut
	clr.l	d0
	clr.l	d1
	
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Edit_X,d2
	move.w	_Map_Edit_Y,d3
	jsr	_Display_Cut_Tile

.no_draw_cut

	bra	.cut_end
.not_display
	cmp.w	#TOOL_RESTORE_FLAG,d7		; **
	bne.s	.not_restore

	tst.b	_Cut_On
	bne.s	.no_restore_dispcut

	tst.w	_Map_Last_X
	bmi.s	.no_restore_cut
	clr.l	d0
	clr.l	d1

;	move.w	_Line_X1,d0
;	move.w	_Line_Y1,d1
	move.w	_Map_Last_X,d0
	move.w	_Map_Last_Y,d1
	move.l	d0,d2
	move.l	d1,d3
	jsr	_Display_Cut_Tile

	bra.s	.no_restore_cut
.no_restore_dispcut

	tst.b	_Cut_On
	beq.s	.no_restore_cut
	tst.w	_Map_Last_X
	bmi.s	.no_restore_cut
	clr.l	d0
	clr.l	d1

	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Last_X,d2
	move.w	_Map_Last_Y,d3
	jsr	_Display_Cut_Tile
;	bsr	Restore_Object
.no_restore_cut
	bra	.cut_end
.not_restore
	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne	.no_shutdown_cut

	cmp.w	#TOOL_BUTTONDOWN_FLAG,d7		; **
	bne.s	.not_setup
	clr.l	d0
	clr.l	d1
	move.w	_Map_Last_X,d0
	move.w	_Map_Last_Y,d1
	move.l	d0,d2
	move.l	d1,d3
	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure

	move.w	_Map_Edit_X,_Line_X1
	move.w	_Map_Edit_Y,_Line_Y1
	move.b	#1,_Cut_On	
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Line_X1,d2
	move.w	_Line_Y1,d3
	bsr	_Display_Cut_Tile
	bra	.cut_end
.not_setup
	cmp.w	#TOOL_WRITE_FLAG,d7
	bne.s	.not_write

	move.w	_Map_Edit_X,_Line_X2
	move.w	_Map_Edit_Y,_Line_Y2

	bra	.cut_end
.not_write
	cmp.w	#TOOL_BUTTONUP_FLAG,d7			; **
	bne.s	.not_shutdown

	tst.b	_Cut_On
	beq.s	.no_shutdown_cut
	clr.l	d0
	clr.l	d1
	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Edit_X,d2
	move.w	_Map_Edit_Y,d3
	jsr	_Display_Cut_Tile

	move.w	_Line_X1,d0
	move.w	_Line_Y1,d1
	move.w	_Map_Edit_X,d2
	move.w	_Map_Edit_Y,d3
	jsr	_Cut_Tile

	bsr	_Map_Work_Scribble

	tst.b	_Shape_Ed
	bne.s	.already_using_shapes
	jsr	_Map_Work_Shape_Setup
.already_using_shapes


	move.w	_Map_Edit_X,d0
	move.w	_Map_Edit_Y,d1
	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure

.no_shutdown_cut
	move.b	#0,_Cut_On	
	bra.s	.cut_end
.not_shutdown
	nop
.cut_end
	rts

_Cut_Tile:		; d0 - x1, d1 - y1, d2 - x2, d3 - y2, a0 - plot routine
	cmp.w	d0,d2
	bge.s	.x1_x2_ok
	exg.l	d0,d2
.x1_x2_ok
	cmp.w	d1,d3
	bge.s	.y1_y2_ok
	exg.l	d1,d3
.y1_y2_ok
	sub.w	d0,d2
	sub.w	d1,d3
	addq.w	#1,d2	; w
	addq.w	#1,d3	; h
	push	d0-d3

	move.l	d2,d1
	move.l	d3,d2
	move.w	_Shape_Edit,d0	; #
	moveq.l	#0,d3	; c
	moveq.l	#1,d4	; f
	bsr	_Replace_Shape_Node

;	bsr	_Count_Shape_Nodes
;	subq.w	#1,d0
;	move.w	d0,_Shape_Edit

	bsr	_Calculate_Shape_Node
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.cut_end

	move.w	shape_Width(a0),d0
	move.w	shape_Height(a0),d1
	asr.w	#1,d0
	asr.w	#1,d1
	neg.w	d0
	neg.w	d1
	move.w	d0,shape_HotX(a0)
	move.w	d1,shape_HotY(a0)	; calc hotspot

	move.l	shape_Location(a0),a1	; dest in last node of shape list
	move.l	a0,a2
	push	a1
	bsr	_Calculate_Map_Node
	moveq.l	#0,d4
	moveq.l	#0,d5	
	move.w	map_Width(a0),d4
	move.w	map_Height(a0),d5
	move.l	map_Location(a0),a0	; srce
	pop	a1

	pull	d0-d3
	exg.l	d4,d2
	exg.l	d5,d3
	moveq.l	#0,d6
	moveq.l	#0,d7
	exg.l	d4,d6
	exg.l	d5,d7
	bsr	_Transfer_Cut_2
.cut_end	
	pop	d0-d3
	move.w	shape_Width(a2),d0
	move.w	shape_Height(a2),d1
	asr.w	#1,d0
	asr.w	#1,d1
	neg.w	d0
	neg.w	d1
	move.w	d0,shape_HotX(a2)
	move.w	d1,shape_HotY(a2)


	rts

_Transfer_Cut_2:	
* d0 - srce x	00
* d1 - srce y	04
* d2 - srce w	08
* d3 - srce h	12
* a0 - srce location
* d4 - dest x	16
* d5 - dest y	20
* d6 - dest w	24
* d7 - dest h	28
* a1 - dest location

* sp - width	32
* sp - height	36

	push	a5
	pea	0.w
	pea	0.w
	push	d0-d7
	move.l	sp,a5
	move.l	d2,d0
	move.l	d6,d1
	jsr	_Find_Greater
	move.l	d1,32(a5)

	move.l	d3,d0
	move.l	d7,d1
	jsr	_Find_Greater
	move.l	d1,36(a5)

	moveq.l	#0,d5	; y
	move.l	36(a5),d7
	bra.s	.next_y_p
.next_y

	moveq.l	#0,d4	; x
	move.l	32(a5),d6
	bra.s	.next_x_p
.next_x

	move.l	d4,d0		; x
	add.l	00(a5),d0	; +srce left
	move.l	d5,d1		; y
	add.l	04(a5),d1	; +srce top
	move.l	08(a5),d2	; srce width
	mulu	d2,d1		; width*top
	add.l	d1,d0		; ^+x
	add.l	d0,d0

	move.l	d4,d1		; x
	add.l	16(a5),d1	; +dest left
	move.l	d5,d2		; y
	add.l	20(a5),d2	; +dest top
	move.l	24(a5),d3	; dest width
	mulu	d3,d2		; width*top
	add.l	d2,d1		; ^+x
	add.l	d1,d1
	move.w	(a0,d0.l),(a1,d1.l)
	
	addq.l	#1,d4		; x++
.next_x_p
	dbra	d6,.next_x
	addq.l	#1,d5		; y++
.next_y_p
	dbra	d7,.next_y

	add.l	#(8*4)+(2*4),sp
	pop	a5
	rts

_Display_Cut_Tile:	; d0 - x1, d1 - y1, d2 - x2, d3 - y2
	move.l	_Ed_RastPort,_Global_RastPort

	cmp.w	d0,d2
	bge.s	.x1_x2_ok
	exg.l	d0,d2
.x1_x2_ok
	cmp.w	d1,d3
	bge.s	.y1_y2_ok
	exg.l	d1,d3
.y1_y2_ok

	move.w	_Map_Left,d4
	move.w	_Map_Top,d5

	cmp.w	d4,d0
	bgt.s	.x1_ok
	move.w	d4,d0
.x1_ok
	cmp.w	d5,d1
	bgt.s	.y1_ok
	move.w	d5,d1
.y1_ok
	
	add.w	_Map_Edit_Width,d4
	subq.w	#1,d4
	cmp.w	d4,d2
	blt.s	.x2_ok
	move.w	d4,d2
.x2_ok
	add.w	_Map_Edit_Height,d5
	subq.w	#1,d5
	cmp.w	d5,d3
	blt.s	.y2_ok
	move.w	d5,d3
.y2_ok

	move.w	_Map_Left,d4
	move.w	_Map_Top,d5	
	sub.w	d4,d0
	sub.w	d5,d1
	sub.w	d4,d2
	sub.w	d5,d3
	mulu	_Tile_Width,d0
	mulu	_Tile_Height,d1
	mulu	_Tile_Width,d2
	mulu	_Tile_Height,d3
	add.w	_Tile_Width,d2
	add.w	_Tile_Height,d3
	sub.w	#1,d2
	sub.w	#1,d3
	lea	Region_Map_Edit,a0
	move.w	rg_LeftEdge(a0),d4
	move.w	rg_TopEdge(a0),d5
	add.w	d4,d0
	add.w	d5,d1
	add.w	d4,d2
	add.w	d5,d3
	push	d0-d3
	move.w	#RP_JAM2!RP_COMPLEMENT,d0
	jsr	_SetDrMd
	pull	d0-d3
;	bsr	_RectFill
	jsr	_Move
	pull	d0-d3
	move.w	d2,d0		; right top corner
	jsr	_Draw
	pull	d0-d3
	move.w	d2,d0		; bottom right corner
	move.w	d3,d1		; bottom right corner
	jsr	_Draw
	pull	d0-d3
	move.w	d3,d1		; left bottom corner
	jsr	_Draw
	pull	d0-d3
	jsr	_Draw
	pop	d0-d3
	move.w	#RP_JAM2,d0
	jsr	_SetDrMd
	rts

;****************************************************
;              Shape Control & Functions
;****************************************************

_Calculate_Shape:

	bsr	_Calculate_Shape_Pointer
	move.l	a0,d7
	move.l	d7,a0
	beq	.shape_calc_end

	move.w	#-1,d2	; min x
	move.w	#-1,d3	; min y
	move.w	#0,d4	; max x
	move.w	#0,d5	; max y
	
	move.l	shape_Location(a0),a1
	move.w	shape_Count(a0),d7
	push	d7/a1
	bra.s	.1
.next_analize_shape_entry
	cmp.w	0(a1),d2
	bls.s	.d2_smaller
	move.w	0(a1),d2
.d2_smaller
	cmp.w	2(a1),d3
	bls.s	.d3_smaller
	move.w	2(a1),d3
.d3_smaller
	cmp.w	0(a1),d4
	bhs.s	.d4_larger
	move.w	0(a1),d4
.d4_larger
	cmp.w	2(a1),d5
	bhs.s	.d5_larger
	move.w	2(a1),d5
.d5_larger
	add.l	#6,a1
.1
	dbra	d7,.next_analize_shape_entry
	pop	d7/a1

	bra.s	.2
.next_alter_shape_entry
	sub.w	d2,0(a1)	; sub min x
	sub.w	d3,2(a1)	; sub min y
	add.l	#6,a1
.2
	dbra	d7,.next_alter_shape_entry

	sub.w	d2,d4		; width
	addq.w	#1,d4
	sub.w	d3,d5		; height
	addq.w	#1,d5
;	sub.w	d0,d2		; hot x
;	sub.w	d1,d3		; hot y 
	move.w	d4,shape_Width(a0)
	move.w	d5,shape_Height(a0)
	asr.w	#1,d4
	asr.w	#1,d5
	neg.w	d4
	neg.w	d5
	move.w	d4,shape_HotX(a0)
	move.w	d5,shape_HotY(a0)

.shape_calc_end
	rts

_Check_Shape_Entry:	; d0 - x, d1 - y, d2 - tile
	push	d7/a0-a1
	bsr	_Calculate_Shape_Pointer

	move.l	a0,d7
	move.l	d7,a0
	beq.s	.shape_check_end

	move.w	shape_Count(a0),d7
	move.l	shape_Location(a0),a1
	bra.s	.shape_check_loop_p
.shape_check_loop
	cmp.w	0(a1),d0
	bne.s	.not_present
	cmp.w	2(a1),d1
	bne.s	.not_present
	cmp.w	4(a1),d2
	beq.s	.entry_present
.not_present
	addq.l	#2*3,a1
.shape_check_loop_p
	dbra	d7,.shape_check_loop
	tst.w	d7
	bmi.s	.shape_check_end
.entry_present
	moveq.l	#-1,d0
.shape_check_end
	pop	d7/a0-a1
	cmp.l	#-1,d0
	rts

_Save_Shape_Entry:	; d0 - x, d1 - y, d2 - tile

	bsr	_Calculate_Shape_Pointer

	move.l	a0,d7
	move.l	d7,a0
	beq.s	.shape_save_end

	cmp.w	#SHAPE_MEM_SIZE-1,shape_Count(a0)	; have we filled the shape mem?
	bge.s	.shape_filled			; yep - so leave

	clr.l	d3
	move.w	shape_Count(a0),d3	; shape entry count
	mulu	#(2*3),d3			; x.w, y.w, tile.w
	move.l	shape_Location(a0),a1	; shape mem location
	move.l	a1,a2
.next_shape_entry
	tst.w	0(a1)			; if end of list then
	bmi.s	.shape_entry_not_found	; shape entry was not found
	cmp.w	0(a1),d0		; else check all other entrys
	bne.s	.not_shape_entry
	cmp.w	2(a1),d1
	bne.s	.not_shape_entry
	cmp.w	4(a1),d2
	bne.s	.not_shape_entry
.shape_entry_found		; when here, shape entry is already in list
	bra.s	.shape_filled	; so skip the store
.not_shape_entry
	addq.l	#6,a1
	bra.s	.next_shape_entry

.shape_entry_not_found
	add.l	d3,a2			; get to index entry
	move.w	d0,(a2)+		; store new data
	move.w	d1,(a2)+
	move.w	d2,(a2)+	
	move.w	#-1,(a2)+
	addq.w	#1,shape_Count(a0)	; increase entry count

	btst	#SHPB_GETTING,_Shape_Ed		; check if getting shape
	bne.s	.shape_filled
	jsr	_Show_Shape_Tiles
.shape_filled
.shape_save_end
	rts

_Calculate_Shape_Pointer:
	push	d0-d1
	bsr	_Calculate_Shape_Node
	pop	d0-d1
	rts

_Show_Shape_Tiles:	;; d0 - x, d1 - y

	bsr	_Calculate_Shape_Pointer

	move.l	a0,d7
	move.l	d7,a0
	beq.s	.shape_show_end


	move.l	shape_Location(a0),a1	; shape location
	move.w	shape_Count(a0),d7	; shape entry count

	bra.s	.1
.next_shape_entry
	push	d0-d1/d7
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	push	a1
	jsr	_Reverse_Tile
	pop	a1
	pop	d0-d1/d7
.1	
	dbra	d7,.next_shape_entry
.shape_show_end
	rts


_Show_Shape:	; d0 - map x, d1 - map y, d2 - shape

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne	.not_editing_map

	bsr	_Calculate_Shape_Pointer

	move.l	a0,d7
	move.l	d7,a0
	beq	.not_editing_map

	move.l	shape_Location(a0),a1	; shape location

	move.w	shape_Flags(a0),d3

	btst	#FLGB_CUT,d3
	beq.s	.not_shape_cut

	move.w	shape_Height(a0),d7
	bra.s	.shape_nh_p
.shape_nh
	move.w	shape_Width(a0),d6
	bra.s	.shape_nw_p
.shape_nw
	push	d0-d1/d6-d7
	move.w	shape_Width(a0),d2	; width
	mulu	d7,d2			; * curr y
	add.w	d6,d2			; + curr x
	add.w	d2,d2			; *2
	move.w	(a1,d2.w),d2
	add.w	d6,d0
	add.w	d7,d1
	add.w	shape_HotX(a0),d0
	add.w	shape_HotY(a0),d1
	
	push	a0-a1
	jsr	_Show_Tile
	pop	a0-a1	
	pop	d0-d1/d6-d7

.shape_nw_p
	dbra	d6,.shape_nw
.shape_nh_p
	dbra	d7,.shape_nh
	bra.s	.not_editing_map
.not_shape_cut

	move.w	shape_Count(a0),d7	; shape entry count
	bra.s	.1
.next_shape_entry
	push	d0-d1/d7
	add.w	(a1)+,d0
	add.w	shape_HotX(a0),d0
	add.w	(a1)+,d1
	add.w	shape_HotY(a0),d1
	move.w	(a1)+,d2
	push	a0-a1
	jsr	_Show_Tile
	pop	a0-a1
	pop	d0-d1/d7
.1	
	dbra	d7,.next_shape_entry

.not_editing_map
	rts

_Restore_Shape:	; d0 - screen x, d1 - screen y, d2 - shape

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne	.not_restoring_map

	bsr	_Calculate_Shape_Pointer

	move.l	a0,d7
	move.l	d7,a0
	beq	.not_restoring_map

	move.l	shape_Location(a0),a1	; shape location
	move.w	shape_Flags(a0),d3
	btst	#FLGB_CUT,d3
	beq.s	.not_shape_cut
	move.w	shape_Height(a0),d7
	bra.s	.shape_nh_p
.shape_nh
	move.w	shape_Width(a0),d6
	bra.s	.shape_nw_p
.shape_nw
	push	d0-d1/d6-d7
	add.w	d6,d0
	add.w	d7,d1	
	add.w	shape_HotX(a0),d0
	add.w	shape_HotY(a0),d1
	push	a0-a1
	jsr	_Read_Map_Tile
	jsr	_Show_Tile
	pop	a0-a1	
	pop	d0-d1/d6-d7
.shape_nw_p
	dbra	d6,.shape_nw
.shape_nh_p
	dbra	d7,.shape_nh
	bra.s	.not_restoring_map
.not_shape_cut

	move.w	shape_Count(a0),d7	; shape entry count
	bra.s	.1
.next_shape_entry
	push	d0-d1/d7
	add.w	(a1)+,d0
	add.w	shape_HotX(a0),d0
	add.w	(a1)+,d1
	add.w	shape_HotY(a0),d1
	move.w	(a1)+,d2
	push	a0-a1
	jsr	_Read_Map_Tile
	jsr	_Show_Tile
	pop	a0-a1
	pop	d0-d1/d7
.1	
	dbra	d7,.next_shape_entry

.not_restoring_map
	rts

_Write_Map_Shape:	; d0 - map x, d1 - map y, d2 - shape

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne	.not_writing_map

	bsr	_Calculate_Shape_Pointer
	move.l	a0,d7
	move.l	d7,a0
	beq	.not_writing_map
	move.l	shape_Location(a0),a1	; shape location

	move.w	shape_Flags(a0),d3
	btst	#FLGB_CUT,d3
	beq.s	.not_shape_cut

;	moveq.l	#0,d0			; srce x
;	move.l	d0,d1			; srce y
;	move.l	d0,d2			; srce x
;	move.l	d0,d3			; srce y
;	move.l	d0,d4			; srce x
;	move.l	d0,d5			; srce y
;	move.l	d0,d6			; srce x
;	move.l	d0,d7			; srce y
;	move.w	shape_Width(a0),d2	; srce w
;	move.w	shape_Height(a0),d3	; srce h
;	move.w	_Map_Edit_X,d4		; dest x
;	add.w	shape_HotX(a0),d4
;	move.w	_Map_Edit_Y,d5		; dest y
;	add.w	shape_HotY(a0),d5
;	move.w	_Map_Width,d6		; dest w
;	move.w	_Map_Height,d7		; dest h
;	move.l	shape_Location(a0),a0	; srce
;	move.l	_Map_Location,a1	; dest
;	bsr	_Transfer_Cut_2

	move.w	shape_Height(a0),d7
	bra.s	.shape_nh_p
.shape_nh
	move.w	shape_Width(a0),d6
	bra.s	.shape_nw_p
.shape_nw
	push	d0-d1/d6-d7
	move.w	shape_Width(a0),d2	; width
	mulu	d7,d2			; * curr y
	add.w	d6,d2			; + curr x
	add.w	d2,d2			; *2
	move.w	(a1,d2.w),d2
	add.w	d6,d0
	add.w	d7,d1
	add.w	shape_HotX(a0),d0
	add.w	shape_HotY(a0),d1	
	push	a0-a1
	jsr	_Write_Map_Tile
	jsr	_Show_Tile
	pop	a0-a1	
	pop	d0-d1/d6-d7

.shape_nw_p
	dbra	d6,.shape_nw
.shape_nh_p
	dbra	d7,.shape_nh


	bra.s	.not_writing_map
.not_shape_cut
	move.w	shape_Count(a0),d7	; shape entry count

	bra.s	.1
.next_shape_entry
	push	d0-d1/d7
	add.w	(a1)+,d0
	add.w	shape_HotX(a0),d0
	add.w	(a1)+,d1
	add.w	shape_HotY(a0),d1
	move.w	(a1)+,d2
	push	a0-a1
	jsr	_Write_Map_Tile
	jsr	_Show_Tile
	pop	a0-a1
	pop	d0-d1/d7
.1	
	dbra	d7,.next_shape_entry

.not_writing_map
	rts

;****************************************************
;                Text Display Routines
;****************************************************
dbgm90:
_Display_Outline_Text:	; d0 - x, d1 - y, d2 - col_text, d3 - col_outline, a0 - string
	push	d0-d3/a0
	move.w	#RP_JAM1,d0
	call	_SetDrMd
	pull	d0-d3/a0
	move.l	d3,d2
	subq.w	#1,d0
	subq.w	#1,d1
	moveq.l	#3,d7
	bra.s	.y_pass_1
.y_pass

	moveq.l	#3,d6
	bra.s	.x_pass_1
.x_pass
	push	d0-d2/d6-d7/a0
	add.w	d6,d0
	add.w	d7,d1
	jsr	_Display_String
	pop	d0-d2/d6-d7/a0
.x_pass_1
	dbra	d6,.x_pass
.y_pass_1
	dbra	d7,.y_pass

	pop	d0-d3/a0

	jsr	_Display_String

	move.w	#RP_JAM2,d0
	call	_SetDrMd
	
	rts

_Display_String:	; d0 - x, d1 - y, d2 - col, a0 - string
	push	d0-d2/a0
;	moveq.l	#RP_JAM1,d0
;	jsr	_SetDrMd
;	pull	d0-d2/a0
	move.l	d2,d0
	jsr	_SetAPen
	pop	d0-d2/a0
	push	d0
	jsr	_StrLen
	move.l	d0,d2
	pop	d0
	jsr	_DisplayText

;	moveq.l	#RP_JAM2,d0
;	jsr	_SetDrMd

	rts

Display_Text_Format:	; d0 - x, d1 - y, d2 - col, d3 - number, a0 - format string
	push	d0-d3/a0
	move.l	d2,d0
	jsr	_SetAPen
;	move.w	#RP_JAM2,d0
;	jsr	_SetDrMd
	pop	d0-d3/a0
	push	d0-d1
	push	d3
	push	a0
	pea	_StringBuffer
	jsr	_SPrintf
	lea	3*4(sp),sp
	pop	d0-d1
	lea	_StringBuffer,a0
	push	d0
	jsr	_StrLen
	move.l	d0,d2
	pop	d0
	jsr	_DisplayText
	rts

Display_Text:	; d0 - x, d1 - y, d2 - col,  a0 - string
	push	d0-d3/a0
	move.l	d2,d0
	jsr	_SetAPen
;	move.w	#RP_JAM2,d0
;	jsr	_SetDrMd
	pop	d0-d3/a0
	push	d0
	jsr	_StrLen
	move.l	d0,d2
	pop	d0
	jsr	_DisplayText
	rts

Display_Text_Tile:

	moveq.l	#0,d1
	btst	#0,_Object_Type
	beq.s	.not_shape
	move.w	_Shape_Edit,d1
	bra.s	.1
.not_shape
	move.w	_Tile_Edit,d1
.1
	move.l	#STRING_ID_CURRTILE,d0
	push	d0/a0
	push	d1
	jsr	_Get_WorkGadgetStringBuffer
	pea	_Tile_Format
	push	a0
	jsr	_SPrintf
	lea	(3*4)(sp),sp
	pop	d0/a0

	moveq.l	#1,d1
	move.l	_Wk_Window,a0
	jsr	_Refresh_Num_Gadgets

	andi.w	#~(CHGF_TILE),_Something_Changed-PC(gl)
	rts


_Work_Get_Set_Refresh_String:
	push	d0/a0
	jsr	_Get_WorkGadgetStringBuffer
	move.l	a0,a1
	pull	d0/a0
	jsr	_StrCpy
	pop	d0/a0

	moveq.l	#1,d1
	move.l	_Wk_Window,a0
	jsr	_Refresh_Num_Gadgets
	rts

Display_Text_Map_Set:
	bsr	_Calculate_Map_Node
	move.l	map_Name(a0),a0
	move.l	#STRING_ID_MAPNAME,d0
	jsr	_Work_Get_Set_Refresh_String
	andi.w	#~(CHGF_MAPSET),_Something_Changed-PC(gl)
	rts

Display_Text_Tile_Set:
	bsr	_Calculate_Tile_Node
	move.l	tile_Name(a0),a0
	move.l	#STRING_ID_TILENAME,d0
	jsr	_Work_Get_Set_Refresh_String
	andi.w	#~(CHGF_TILESET),_Something_Changed-PC(gl)
	rts


Display_Text_Palette_Set:
	bsr	_Calculate_Palette_Node
	move.l	palette_Name(a0),a0
	move.l	#STRING_ID_PALETTENAME,d0
	jsr	_Work_Get_Set_Refresh_String
	andi.w	#~(CHGF_PALETTESET),_Something_Changed-PC(gl)
	rts


Display_Text_Map_X:
	move.l	_Wk_RastPort,_Global_RastPort
	move.l	#174,d0			; x
	moveq.l	#4,d1			; y
	moveq.l	#1,d2			; col
	clr.l	d3
	move.w	_Map_Edit_X,d3
	lea	_Text_Edit_Map_X,a0	; format
	bsr	Display_Text_Format
	andi.w	#~(CHGF_XCOORD),_Something_Changed-PC(gl)
	rts

Display_Text_Map_Y:
	move.l	_Wk_RastPort,_Global_RastPort
	move.l	#214,d0			; x
	moveq.l	#4,d1			; y
	moveq.l	#1,d2			; col
	clr.l	d3
	move.w	_Map_Edit_Y,d3
	lea	_Text_Edit_Map_Y,a0	; format
	bsr	Display_Text_Format
	andi.w	#~(CHGF_YCOORD),_Something_Changed-PC(gl)
	rts

Display_Text_Shell_XY:
	move.l	_Wk_RastPort,_Global_RastPort
	lea	_Text_Edit_XY_ShellM,a0	; format
	jsr	_StrLen
	move.l	d0,d2
	move.l	#174-16,d0			; x
	moveq.l	#4,d1			; y
	bsr	Display_Text
	andi.w	#~(CHGF_SHELL_XY),_Something_Changed-PC(gl)
	rts

Display_Text_Tile_X:
	move.l	_Wk_RastPort,_Global_RastPort
	move.l	#174,d0			; x
	moveq.l	#4,d1			; y
	moveq.l	#1,d2			; col
	clr.l	d3
	move.w	_Tile_Edit_X,d3
	lea	_Text_Edit_Tile_X,a0	; format
	bsr	Display_Text_Format
	andi.w	#~(CHGF_XCOORD),_Something_Changed-PC(gl)
	rts

Display_Text_Tile_Y:
	move.l	_Wk_RastPort,_Global_RastPort
	move.l	#214,d0			; x
	moveq.l	#4,d1			; y
	moveq.l	#1,d2			; col
	clr.l	d3
	move.w	_Tile_Edit_Y,d3
	lea	_Text_Edit_Tile_Y,a0	; format
	bsr	Display_Text_Format
	andi.w	#~(CHGF_YCOORD),_Something_Changed-PC(gl)
	rts

;****************************************************
;                Object & Tile Routines
;****************************************************

Write_Object:
	btst	#SHPB_GET,_Shape_Ed		; check if getting shape
	beq.s	.not_get_shape

	jsr	_Read_Map_Tile

	bset	#SHPB_GETTING,_Shape_Ed
	jsr	_Save_Shape_Entry
	bclr	#SHPB_GETTING,_Shape_Ed

	bra.s	.write_end
.not_get_shape
	btst	#0,_Object_Type		; if ( Object_Type == BLOCK ) {
	bne.s	.not_write_tile
	move.w	_Tile_Edit,d2
	bsr	_Write_Map_Tile		;     write block into map
	bra.s	.write_end		; }
.not_write_tile				; else {
	bsr	_Write_Map_Shape	;     write shape into map
	bra.s	.write_end		; }
.not_write_shape
	nop
.write_end
	rts

Display_Object:			; d0 - x, d1 - y
	btst	#SHPB_GET,_Shape_Ed	; if creating a shape
	beq.s	.not_reverse_block	; then display reversed edit block

	andi.l	#$FFFF,d0
	andi.l	#$FFFF,d1
	push	d0-d1
	jsr	_Read_Map_Tile
	pop	d0-d1
	jsr	_Reverse_Tile

	bra.s	.display_end
.not_reverse_block

	btst	#0,_Object_Type
	bne.s	.not_display_tile	; if ( Object_Type == BLOCK ) then {
	move.w	_Tile_Edit,d2
	jsr	_Show_Tile		;     display selected block in edit area
	bra	.display_end		; }
.not_display_tile			; else {
	jsr	_Show_Shape		;     display shape in edit area
	bra	.display_end
.not_display_shape			; }
	nop
.display_end
	rts

Restore_Object_1:	; d0 - x, d1 - y
	btst	#SHPB_GET,_Shape_Ed		; if creating a shape
	beq.s	.not_reverse_block	; then restore reversed block

	andi.l	#$FFFF,d0
	andi.l	#$FFFF,d1
	push	d0-d1
	jsr	_Read_Map_Tile
	bsr	_Check_Shape_Entry
	beq.s	.entry_present
	jsr	_Show_Tile
.entry_present
	pop	d0-d1

;	bset	#SHPB_GETTING,_Shape_Ed
;	jsr	_Save_Shape_Entry
;	bclr	#SHPB_GETTING,_Shape_Ed

	bra.s	.restore_end
.not_reverse_block

	btst	#0,_Object_Type
	bne.s	.not_restore_tile	; if ( Object_Type == 0 ) then {
	tst.w	d0
	bmi.s	.dont_restore_last_tile
	jsr	_Read_Map_Tile
	jsr	_Show_Tile
.dont_restore_last_tile
	bra.s	.restore_end		; }
.not_restore_tile			; else {
	tst.w	d0
	bmi.s	.dont_restore_last_tile
	jsr	_Restore_Shape
	bra.s	.restore_end		; }
.not_restore_shape
	nop
.restore_end
	rts

Restore_Object:
	btst	#SHPB_GET,_Shape_Ed		; if creating a shape
	beq.s	.not_reverse_block	; then don't restore

	clr.l	d0
	clr.l	d1
	move.w	_Map_Last_X,d0
	move.w	_Map_Last_Y,d1
	push	d0-d1
	jsr	_Read_Map_Tile
	bsr	_Check_Shape_Entry
	beq.s	.entry_present
	jsr	_Show_Tile
.entry_present
	pop	d0-d1

;	bset	#SHPB_GETTING,_Shape_Ed
;	jsr	_Save_Shape_Entry
;	bclr	#SHPB_GETTING,_Shape_Ed

	bra.s	.restore_end
.not_reverse_block

	btst	#0,_Object_Type
	bne.s	.not_restore_tile	; if ( Object_Type == BLOCK ) then {

	tst.w	_Map_Last_X
	bmi.s	.dont_restore_tile
	push	d0-d1
	clr.l	d0
	clr.l	d1
	move.w	_Map_Last_X,d0
	move.w	_Map_Last_Y,d1
	jsr	_Read_Map_Tile		; read tile from map
	jsr	_Show_Tile		; and display it onscreen
	pop	d0-d1
.dont_restore_tile
	bra.s	.restore_end		; }
.not_restore_tile			; else {
	tst.w	_Map_Last_X
	bmi.s	.dont_restore_shape
	push	d0-d1
	clr.l	d0
	clr.l	d1
	move.w	_Map_Last_X,d0
	move.w	_Map_Last_Y,d1
	jsr	_Restore_Shape		; erase shape from screen
	pop	d0-d1
.dont_restore_shape
	bra.s	.restore_end		; }
.not_restore_shape
	nop
.restore_end
	rts

_Read_Map_Tile:	; d0 - x in map, d1 - y in map
	push	d0-d1/a0
	move.l	_Map_Location,a0
	mulu	_Map_Width,d1
	add.l	d1,d0
	add.l	d0,d0
	move.w	(a0,d0.l),d2
	pop	d0-d1/a0
	rts		; d2 - cell number

_Write_Map_Tile:	; d0 - x in map, d1 - y in map, d2 - tile
	cmp.w	#0,d0
	blo	.write_tile_end		; exit if < left edge
	cmp.w	_Map_Width,d0
	bhs	.write_tile_end		; exit if > right edge

	cmp.w	#0,d1
	blo	.write_tile_end		; exit if < top edge
	cmp.w	_Map_Height,d1
	bhs	.write_tile_end		; exit if > bottom edge

	push	d0-d1/a0
	move.l	_Map_Location,a0
	mulu	_Map_Width,d1
	add.l	d1,d0
	add.l	d0,d0
	move.w	d2,(a0,d0.l)
	pop	d0-d1/a0
.write_tile_end
	rts


_Show_Tile:	; d0 - map x, d1 - map y, d2 - tile

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne	.show_tile_end

	cmp.w	_Screen_Min_X,d0
	blo	.show_tile_end		; exit if < left edge
	cmp.w	_Screen_Max_X,d0
	bhi	.show_tile_end		; exit if > right edge

	cmp.w	_Screen_Min_Y,d1
	blo	.show_tile_end		; exit if < top edge
	cmp.w	_Screen_Max_Y,d1
	bhi	.show_tile_end		; exit if > bottom edge

	sub.w	_Map_Left,d0
	sub.w	_Map_Top,d1

	move.w	_Tile_Width,d4
	move.w	_Tile_Height,d5
	mulu	d4,d0
	mulu	d5,d1
	add.w	Region_Map_Edit+2,d0	; left
	add.w	Region_Map_Edit+4,d1	; top


	cmp.w	_Tile_Amount,d2
	blo.s	.0
	lea	_Blank_BitMap,a0	
;	push	d0-d2
	moveq.l	#0,d2
;	bsr.s	.1
;	pull	d0-d2
;	andi.l	#$FFFF,d2
;;	ext.l	d2
;	push	d2
;	pea	_Hex_Tile_Format
;	pea	_Hex_Map_Tile_Buffer
;	bsr	_SPrintf
;	lea	3*4(sp),sp
;	pop	d0-d2
;	move.l	_Ed_RastPort,_Global_RastPort
;	addq.w	#6,d1
;	bsr	_Move
;	lea	_Hex_Map_Tile_Buffer,a0
;	bsr	_StrLen
;	bsr	_Text
;	bra.s	.show_tile_end
	bra.s	.1
.0
	lea	_Tile_BitMap,a0		; source bitmap
.1

	exg.l	d0,d2
	exg.l	d1,d3
	move.l	#0,d1
	mulu	d5,d0
	exg.l	d0,d1
	

	move.l	_Ed_RastPort,a1
	move.l	rp_BitMap(a1),a1
	move.l	a1,a2
	moveq.l	#$CC,d6
	moveq.l	#$FF,d7		
	jsr	_BltBitMap
.show_tile_end
	rts


_Reverse_Tile:	; d0 - map x, d1 - map y, d2 - tile

	cmp.w	#MAP_EDIT_REGION_ID,_Region_Run_ID
	bne.s	.show_shape_tile_end

	cmp.w	_Screen_Min_X,d0
	blo	.show_shape_tile_end		; exit if < left edge
	cmp.w	_Screen_Max_X,d0
	bhi	.show_shape_tile_end		; exit if > right edge

	cmp.w	_Screen_Min_Y,d1
	blo	.show_shape_tile_end		; exit if < top edge
	cmp.w	_Screen_Max_Y,d1
	bhi	.show_shape_tile_end		; exit if > bottom edge

	sub.w	_Map_Left,d0
	sub.w	_Map_Top,d1

;	move.l	_Ed_RastPort,_Global_RastPort
;	move.w	_Tile_Width,d2
;	move.w	_Tile_Height,d3
;	mulu	d2,d0
;	mulu	d3,d1
;	add.w	d0,d2
;	add.w	d1,d3
;	subq.w	#1,d2
;	subq.w	#1,d3
;	push	d0-d3
;	move.w	#3,d0
;	bsr	_SetDrMd
;	pop	d0-d3
;	bsr	_RectFill
;	move.w	#1,d0
;	bsr	_SetDrMd
	
	move.w	_Tile_Width,d4
	move.w	_Tile_Height,d5
	mulu	d4,d0
	mulu	d5,d1
	add.w	Region_Map_Edit+2,d0	; left
	add.w	Region_Map_Edit+4,d1	; top

	exg.l	d0,d2
	exg.l	d1,d3
	move.l	#0,d1
	mulu	d5,d0
	exg.l	d0,d1
	
	lea	_Tile_BitMap,a0
	move.l	_Ed_RastPort,a1
	move.l	rp_BitMap(a1),a1
	move.l	a1,a2
	moveq.l	#$33,d6
	moveq.l	#$FF,d7		
	jsr	_BltBitMap
.show_shape_tile_end
	rts

 IFD	dugbarry
Display_Map_2:
	push	d0-d7/a0-a2

	lea	_Tile_BitMap,a0		; source
	move.l	_Ed_RastPort,a1
	move.l	rp_BitMap(a1),a1	; destin
	move.l	a1,a2			; temp
	move.l	_Map_Location,a3
	clr.l	d0
	move.w	_Map_Top,d0
	mulu	_Map_Width,d0
	add.w	_Map_Left,d0
	add.l	d0,d0
	add.l	d0,a3			; top left of map

	move.w	_Tile_Width,d4		; size x
	move.w	_Tile_Height,d5		; size y

	moveq.l	#0,d0			; srce x
	moveq.l	#0,d1			; srce y
	move.w	Region_Map_Edit+2,d2	; dest x
	move.w	Region_Map_Edit+4,d3	; dest y
	move.w	_Map_Edit_Height,d7
	bra.s	.display_height_pass
.display_height
	move.w	_Map_Edit_Width,d6
	bra.s	.display_width_pass
.display_width
	push	d6-d7
	move.w	(a3)+,d1
	push	a0
	cmp.w	_Tile_Amount,d1
	blo.s	.normal_tile
.blank_tile	
	lea	_Blank_BitMap,a0
	moveq.l	#0,d1
	bra.s	.tile_ok
.normal_tile
	mulu	_Tile_Height,d1
.tile_ok

	moveq.l	#$CC,d6			; minterm
	moveq.l	#$FF,d7			; mask

	jsr	_BltBitMap
	pop	a0
	pop	d6-d7
	add.l	d4,d2
.display_width_pass
	dbra	d6,.display_width
	moveq.l	#0,d6
	move.w	_Map_Width,d6
	sub.w	_Map_Edit_Width,d6
	add.l	d6,d6
	add.l	d6,a3			; skip to next line in map
	move.w	Region_Map_Edit+2,d2	; dest x
	add.l	d5,d3
.display_height_pass
	dbra	d7,.display_height
	pop	d0-d7/a0-a2

	rts
 ENDC

Display_Map:
	push	d0-d7/a0-a2

	lea	_Tile_BitMap,a0		; source
	move.l	_Ed_RastPort,a1
	move.l	rp_BitMap(a1),a1	; destin
	move.l	a1,a2			; temp
	move.l	_Map_Location,a3
	clr.l	d0
	move.w	_Map_Top,d0
	mulu	_Map_Width,d0
	add.w	_Map_Left,d0
	add.l	d0,d0
	add.l	d0,a3			; top left of map

	move.w	_Tile_Width,d4		; size x
	move.w	_Tile_Height,d5		; size y

	moveq.l	#0,d0			; srce x
	moveq.l	#0,d1			; srce y
	move.w	Region_Map_Edit+2,d2	; dest x
	move.w	Region_Map_Edit+4,d3	; dest y
	move.w	_Map_Edit_Height,d7
	bra.s	.display_height_pass
.display_height
	move.w	_Map_Edit_Width,d6
	bra.s	.display_width_pass
.display_width
	push	d6-d7
	move.w	(a3)+,d1
	push	a0
	cmp.w	_Tile_Amount,d1
	blo.s	.normal_tile
.blank_tile	
	lea	_Blank_BitMap,a0
	moveq.l	#0,d1
	bra.s	.tile_ok
.normal_tile
	mulu	_Tile_Height,d1
.tile_ok

	moveq.l	#$CC,d6			; minterm
	moveq.l	#$FF,d7			; mask

	jsr	_BltBitMap
	pop	a0
	pop	d6-d7
	add.l	d4,d2
.display_width_pass
	dbra	d6,.display_width
	moveq.l	#0,d6
	move.w	_Map_Width,d6
	sub.w	_Map_Edit_Width,d6
	add.l	d6,d6
	add.l	d6,a3			; skip to next line in map
	move.w	Region_Map_Edit+2,d2	; dest x
	add.l	d5,d3
.display_height_pass
	dbra	d7,.display_height
	pop	d0-d7/a0-a2

	rts


;****************************************************
;            Read & Write Map Information
;****************************************************

Read_Map_Info:
	bsr	_Calculate_Map_Node
	move.l	a0,d0
	move.l	d0,a0
	bne.s	.map_defined
	move.w	_Map_Set,d0
	move.w	#20,d1	; width
	move.w	#12,d2	; height
	move.w	#0,d3	; flags
	bsr	_Add_Map_Node
	bsr	_Calculate_Map_Node
.map_defined
	move.w	map_Width(a0),_Map_Width	; setup map info
	move.w	map_Height(a0),_Map_Height
	move.l	map_Location(a0),_Map_Location
	move.w	map_Top(a0),_Map_Top
	move.w	map_Left(a0),_Map_Left
	move.w	map_Tiles(a0),_Tile_Set
	move.w	map_Shape(a0),_Shape_Set

	bsr	_Calculate_Shape_Header_Node
	move.l	a0,d0
	move.l	d0,a0
	bne.s	.shphdr_defined
	move.w	_Shape_Set,d0
	move.w	#0,d1	; flags
	bsr	_Add_Shape_Header_Node
	bsr	_Calculate_Shape_Header_Node
.shphdr_defined
	lea	shphdr_First(a0),a0
	move.l	a0,_Shape_Node
.shphdr_ready

.map_ready
	rts
dbgm0:
Read_Tile_Info:
	bsr	_Calculate_Tile_Node
	move.l	a0,d0
	move.l	d0,a0
	bne.s	.tile_defined
	move.w	_Tile_Set,d0
	move.w	#16,d1	; width
	move.w	#16,d2	; height
	move.w	#4,d3	; depth
	move.w	#1,d4	; amount
	move.w	#0,d5	; flags
	bsr	_Add_Tile_Node
	bsr	_Calculate_Tile_Node	
.tile_defined
	move.w	tile_Amount(a0),_Tile_Amount
	move.w	tile_Width(a0),_Tile_Width
	move.w	tile_Height(a0),_Tile_Height
	move.w	tile_Depth(a0),_Tile_Depth
	move.w	tile_Edit(a0),_Tile_Edit
	move.w	tile_Top(a0),_Tile_Top
	move.w	tile_Left(a0),_Tile_Left
	move.w	tile_Flags(a0),_Tile_Flags
	move.l	tile_Location(a0),d3
	move.w	tile_Palette(a0),_Palette_Set


.tile_ready
	move.w	#1,d0
	move.w	_Tile_Width,d1
	move.w	_Tile_Height,d2
	lea	_Mask_BitMap,a0
	jsr	_InitBitMap

	move.w	_Tile_Depth,d0
	move.w	_Tile_Width,d1
	move.w	_Tile_Height,d2
	lea	_Tile_BitMap,a0
	jsr	_InitBitMap

	lea	_Tile_BitMap,a0
	lea	bm_Planes(a0),a0
	add.w	#$F,d1		; ((width + 15)>>4)*2
	asr.w	#4,d1
	add.w	d1,d1		; # bytes width
	mulu	d2,d1		; height*width
	mulu	_Tile_Amount,d1	; 
	move.w	_Tile_Flags,d2
	btst	#FLGB_MASK,d2	; is there a mask?
	beq.s	.tile_no_mask	; nope
	push	a0
	lea	_Mask_BitMap,a0
	move.l	d3,bm_Planes(a0)
	pop	a0
	add.l	d1,d3		; skip masks
.tile_no_mask

	move.w	_Tile_Depth,d0
	bra.s	.1
.next_bitplane:			; setup bitmap plane pointers
	move.l	d3,(a0)+	; location of tiles
	add.l	d1,d3
.1
	dbra	d0,.next_bitplane

	bsr	_Calculate_Palette_Node
	move.l	a0,d0
	move.l	d0,a0
	bne.s	.palette_defined
	move.w	_Palette_Set,d0
	move.w	#4,d1	; depth
	move.w	#0,d2	; flags
	bsr	_Add_Palette_Node
.palette_defined
	bsr	_Calculate_Palette_Node	
	move.l	palette_Location(a0),_Tile_Colours

	rts

Write_Map_Info:
	bsr	_Calculate_Shape_Header_Node
	move.w	_Shape_Edit,shphdr_Edit(a0)

	bsr	_Calculate_Map_Node
	move.w	_Map_Top,map_Top(a0)
	move.w	_Map_Left,map_Left(a0)
	move.w	_Tile_Set,map_Tiles(a0)

.map_ready
	rts	

Write_Tile_Info:
	bsr	_Calculate_Tile_Node
	move.w	_Tile_Edit,tile_Edit(a0)
	move.w	_Tile_Top,tile_Top(a0)
	move.w	_Tile_Left,tile_Left(a0)
	move.w	_Palette_Set,tile_Palette(a0)
.tile_ready
	rts

 ENDC

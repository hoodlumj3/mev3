 IFND	MEV3_TILE_EDIT_S
MEV3_TILE_EDIT_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

MINWIDTH_TILE	EQU	4
MAXWIDTH_TILE	EQU	64
MINHEIGHT_TILE	EQU	4
MAXHEIGHT_TILE	EQU	64

MAXEDIT_WIDTH	EQU	128
MAXEDIT_HEIGHT	EQU	128


*
**
*** $VER:mev3_tile_edit.s 39.01  © (7/May/94) M.J.Edwards
**
*



;****************************************************
;                Tile Editor Screen
;****************************************************

Setup_Tile_Ed:

;; setup the exit / closedown routine in case an
;; error occurs so we can cleanup properley

	st	_Regions_On
	st	_Tools_On
	

	lea	Shutdown_Tile_Ed,a0
	jsr	_Set_Exit_Jump

	move.w	#-1,_Tile_Last_X

	jsr	Read_Tile_Info
	jsr	_Open_Tile_Edit_Screen_Window

	jsr	_Open_Tile_Work_Screen_Window

	
	move.l	_Wk_RastPort,_Global_RastPort


; setup scribble edit tool

	jsr	_Tile_Work_Scribble

; display text and information

	jsr	Display_Text_Tile_Set
	jsr	Display_Text_Tile
;	jsr	Display_Text_XY_ShellT
;	jsr	Display_Text_Tile_X
;	jsr	Display_Text_Tile_Y

	rts

_Tile_Work_Display:
	move.w	#CHGF_TILE!CHGF_TILESET!CHGF_XCOORD!CHGF_YCOORD!CHGF_SHELL_XY,d0
	or.w	d0,_Something_Changed-PC(gl)
	move.w	d0,_Something_Mask-PC(gl)
;	jsr	_Display_Work_Display
	rts

Shutdown_Tile_Ed:

	moveq.l	#-1,d0
	moveq.l	#-1,d1
	lea	_Tile_Region_Coordinates,a0
	jsr	_Check_Regions

	jsr	_Close_Tile_Work_Screen_Window

	jsr	_Close_Tile_Edit_Screen_Window

	jsr	_Clear_Exit_Jump

	rts



_Open_Work_Screen:
	lea	_Default_Preferences,a0
	pea	TAG_DONE		;
	move.l	_Ed_Screen,a1
	moveq.l	#0,d0

	tst.w	_Zoom_Ed-PC(gl)
	bne.s	.no_center_screen
	move.w	sc_Width(a1),d0
	sub.w	#320,d0
	lsr.w	#1,d0
.no_center_screen
	push	d0			;
	pea	SA_Left			;
	move.w	sc_Height(a1),d0
	cmp.w	#SECTION_MAP,Run_Prog_Section
	bne.s	.no_zoom_top
	tst.w	_Zoom_Ed-PC(gl)
	beq.s	.no_zoom_top
	lsr.w	#1,d0
.no_zoom_top
	sub.w	#53,d0
;	moveq.l	#0,d0
	push	d0			;
	pea	SA_Top			;
	pea	0
	pea	SA_BlockPen
	pea	0
	pea	SA_DetailPen
	pea	Minus_1			;
	pea	SA_Pens			;
	lea	_Work_Screen_Colours,a1
	push	a1			;
	pea	SA_Colors		;
	lea	_System80,a1
	push	a1			;
	pea	SA_Font			;
	pea	TRUE			;
	pea	SA_AutoScroll		;
	pea	FALSE			;
	pea	SA_Behind		;
	pea	FALSE			;
	pea	SA_ShowTitle		;
	pea	HIRES_KEY		;
	pea	SA_DisplayID		;
	pea	3.w			;
	pea	SA_Depth		;
	pea	53.w			;
	pea	SA_Height		;
	pea	640.w			;
	pea	SA_Width		;
	move.l	_Ed_Screen,d0
;	push	d0
;	pea	$8000003D
;	pea	1.w
;	pea	$80000045
		
	move.l	sp,a1
	sub.l	a0,a0
	
; open screen
	jsr	_Open_Screen
	move.l	d0,_Wk_Screen
	lea	29*4(sp),sp
;	lea	33*4(sp),sp

; open window ed
	pea	TAG_DONE
	move.l	#IDCMP_MOUSEBUTTONS!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEMOVE!IDCMP_REFRESHWINDOW!IDCMP_GADGETDOWN!IDCMP_GADGETUP!IDCMP_INTUITICKS,d0
	push	d0
	pea	WA_IDCMP
	move.l	#WFLG_SMART_REFRESH!WFLG_BACKDROP!WFLG_BORDERLESS!WFLG_REPORTMOUSE,d0 ;!WFLG_ACTIVATE
	push	d0
	pea	WA_Flags
	move.l	_Wk_Screen,d0
	push	d0
	pea	WA_CustomScreen
	pea	TRUE
	pea	WA_AutoAdjust
	move.l	sp,a1	
	
	sub.l	a0,a0
	jsr	_Open_Window
	move.l	d0,_Wk_Window
	move.l	d1,_Wk_RastPort
	move.l	d2,_Wk_ViewPort
	move.l	d3,_Wk_UserPort
	lea	9*4(sp),sp
	rts


_Open_Tile_Work_Screen_Window:

; create work gadgets
	move.l	#_Wk_Gadgets,d0
	lea	_Tile_Work_Gadget_List,a0
	jsr	_Create_Work_Gadgets

	jsr	_Open_Work_Screen
	
	move.l	_Wk_RastPort,_Global_RastPort

	move.l	_Wk_Gadgets,a0
	jsr	_Count_Gadgets
	move.l	a0,a1
	move.l	d0,d1
	moveq.l	#0,d0
	move.l	_Wk_Window,a0
	jsr	_AddGList

	jsr	_Tile_Work_Display

	move.w	#STRING_ID_CURRTILE,d0		; set tile gad string to be centered and longint
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation

	move.l	_Wk_Screen,a0
	jsr	_ScreenToFront

	rts

_Close_Tile_Work_Screen_Window:
	
; remove work gadgets

	move.l	_Wk_Window,a1
	move.l	wd_FirstGadget(a1),a0
	jsr	_Count_Gadgets
	exg.l	a0,a1
	jsr	_RemoveGList

	jsr	_Remove_All_Work_Gadgets

; close work window
	move.l	_Wk_Window,a0
	jsr	_Close_Window
	move.l	#0,_Wk_Window
; close work screen
	move.l	_Wk_Screen,a0
	jsr	_Close_Screen
	move.l	#0,_Wk_Screen
	rts






_Check_Tile_Edit_Screen:
	jsr	Read_Tile_Info
	move.l	_Ed_Screen,d0
	move.l	d0,a0
	beq.s	.shit_quick_open_it
	lea	sc_BitMap(a0),a1
	moveq.l	#0,d0
	move.b	bm_Depth(a1),d0
	cmp.w	_Tile_Depth,d0
	beq.s	.there_the_same
	jsr	_Close_Tile_Edit_Screen_Window
.shit_quick_open_it
	jsr	_Open_Tile_Edit_Screen_Window
	bra.s	.no_setup
.there_the_same
	jsr	_Free_Backup_Use_Temp_RastPorts
	jsr	_Setup_Tile_Edit_Screen_First
	jsr	_Init_Backup_Use_Temp_RastPorts
	jsr	_Setup_Tile_Edit_Screen_Last
.no_setup
	move.l	_Wk_Screen,a0
	jsr	_ScreenToFront

	rts



_Open_Tile_Edit_Screen_Window:
	jsr	_Setup_Tile_Edit_Screen_First
	jsr	_Init_Backup_Use_Temp_RastPorts
	jsr	_Open_Edit_Screen_Tile
	jsr	_Setup_Tile_Edit_Screen_Last
	rts

_Close_Tile_Edit_Screen_Window:
	move.w	_Tile_Edit,d0
	jsr	_Copy_Tile_Use_To_Original
	jsr	_Close_Edit_Screen
	jsr	_Free_Backup_Use_Temp_RastPorts
	rts


_Setup_Tile_Edit_Screen_First:
	jsr	Read_Tile_Info

	move.w	#-1,_Tile_Last_X
	or.w	#CHGF_TILESET,_Something_Changed

;	jsr	SetUp_Tile_Edit_Screen_Window
	rts

dbgt5:
_Setup_Tile_Edit_Screen_Last:
	jsr	_Set_Tile_Palette

	jsr	_Find_Brightest_Pen

	move.l	_Ed_RastPort,_Global_RastPort
	moveq.l	#0,d0
	jsr	_SetAPen
	coord.w	0,0,640,512
	jsr	_RectFill


	jsr	Pre_Calculate_Edit_Tile_Select_Region
	jsr	Calculate_Tile_Select_Boundries

	lea	_Tile_Region_Coordinates,a0
	jsr	_Draw_Region_Boxes

	jsr	Draw_Colour_Box

	jsr	Region_Edit_Re_Size

	move.w	_Tile_Edit,d0
	jsr	_Copy_Tile_Original_To_Use
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap

	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	subq.w	#1,d0
	move.w	_Colour_Edit_1,d1
	jsr	_Find_Greater
	move.w	d1,_Colour_Edit_1

	move.w	_Tile_Depth,d0
	jsr	_Power_Of_2
	subq.w	#1,d0
	move.w	_Colour_Edit_0,d1
	jsr	_Find_Greater
	move.w	d1,_Colour_Edit_0
	
	move.w	_Brightest_Pen,d0
	jsr	_SetAPen
	move.w	_Colour_Edit_1,d0
	move.w	d0,_Colour_Last_1
	jsr	Highlight_Colour		; set highlight

	jsr	_Display_Edit_Colours

	jsr	_Display_Tile_List_Tile

	rts


;_Set_Tile_Palette:
;	move.w	_Tile_Depth,d0
;	jsr	_Power_Of_2
;	move.l	_Ed_ViewPort,a0
;	move.l	_Tile_Colours,a1
;	jsr	_LoadRGB4
;	rts

_Open_Edit_Screen_Tile:
	lea	_Default_Preferences,a0
	pea	TAG_DONE		;
	pea	Minus_1		;
	pea	SA_Pens			;
	pea	1.w			; OSCAN_TEXT
	pea	SA_Overscan		;
	pea	TRUE			;
	pea	SA_AutoScroll		;
	pea	FALSE			;
	pea	SA_ShowTitle		;
	move.l	prefs_NormScrMode(a0),d0
	push	d0			;
	pea	SA_DisplayID		;
	moveq.l	#0,d0
	move.w	_Tile_Depth,d0
	push	d0			;
	pea	SA_Depth		;
	move.w	prefs_NormScrHeight(a0),d0
	push	d0			;
	pea	SA_Height		;
	move.w	prefs_NormScrWidth(a0),d0
	push	d0			;
	pea	SA_Width		;
	
	move.l	sp,a1
	sub.l	a0,a0
	
; open screen
	jsr	_Open_Screen
	move.l	d0,_Ed_Screen
	lea	17*4(sp),sp

; find visual info
	move.l	_Ed_Screen,a0
	jsr	_GetVisualInfo
	move.l	d0,_Ed_VisualInfo
	move.l	d0,_Gl_VisualInfo

; open window ed
	move.l	_Ed_Screen,a0

	pea	TAG_DONE		;
	pea	WFLG_SMART_REFRESH!WFLG_BACKDROP!WFLG_BORDERLESS!WFLG_REPORTMOUSE!WFLG_RMBTRAP!WFLG_ACTIVATE
	pea	WA_Flags		;
	pea	IDCMP_MOUSEBUTTONS!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEMOVE!IDCMP_REFRESHWINDOW!IDCMP_INTUITICKS!IDCMP_GADGETUP!IDCMP_GADGETDOWN!SLIDERIDCMP	
	pea	WA_IDCMP		;
	pea	TRUE			;
	pea	WA_AutoAdjust		;
	moveq.l	#0,d0
	move.w	sc_Width(a0),d0
	push	d0			;
	pea	WA_Width		;
	move.w	sc_Height(a0),d0
	push	d0			;
	pea	WA_Height		;
	push	a0			;
	pea	WA_CustomScreen		;
	moveq.l	#0,d0
	push	d0			;
	pea	WA_Top			;
	push	d0			;
	pea	WA_Left			;
	sub.l	a0,a0
	move.l	sp,a1
	jsr	_Open_Window
	lea	(17*4)(sp),sp
	move.l	d0,_Ed_Window
	move.l	d1,_Ed_RastPort
	move.l	d2,_Ed_ViewPort
	move.l	d3,_Ed_UserPort

	rts

_Get_Window_SigBit:	; a0 - userport
	push	d1
	moveq.l	#0,d1
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	pop	d1
	rts

_Wait_Sig:	; d0 - signal mask
	push	a6
	base	Sys
	call	Wait
	pop	a6
	rts

Handle_Tile_Ed_Messages:
	move.w	#0,_Quit		; exit signal
.wait_for_message

	moveq.l	#0,d1
	moveq.l	#0,d0
	move.l	_Ed_UserPort,a0
	call	_Get_Window_SigBit
	move.l	_Wk_UserPort,a0
	call	_Get_Window_SigBit
	call	_Wait_Sig

.get_next_work_message
	move.l	_Wk_UserPort,a0
	jsr	_GetMsg			; get the message
	tst.l	d0
	beq.s	.no_work_message
	jsr	_Copy_Intuition_Message
	move.l	d0,a1
	jsr	_ReplyMsg		; reply as quickley as possible
	lea	_Tile_Work_Message_List,a0
	jsr	_Execute_Intuition_Message
	bra.s	.get_next_work_message
.no_work_message

.get_next_edit_message

	move.l	_Ed_UserPort,a0
	jsr	_GetMsg			; get the message
	tst.l	d0
	beq.s	.no_edit_message
;	push	d0/a0/a6
;	move.l	_Ed_Window,a0
;	move.l	#0,d0
;	base	Intuition
;	jsr	ReportMouse
;	pop	d0/a0/a6
	jsr	_Copy_Intuition_Message
	move.l	d0,a1
	jsr	_ReplyMsg		; reply as quickley as possible
	lea	_Tile_Edit_Message_List,a0
	jsr	_Execute_Intuition_Message

	bra.s	.get_next_edit_message
.no_edit_message	
;	push	d0/a0/a6
;	move.l	_Ed_Window,a0
;	move.l	#1,d0
;	base	Intuition
;	jsr	ReportMouse
;	pop	d0/a0/a6

	moveq.l	#0,d0			; Execute
	jsr	_jsr_Routine_Wait

	tst.w	_Quit
	bne.s	.handle_end
	btst	#7,$BFE001
	beq.s	.handle_end
	bra	.wait_for_message	
.handle_end
	rts

_Work_Goto_Tile_To_Map:
	move.w	#SECTION_MAP,Run_Prog_Section
	bra.s	_Work_Goto_Tile_To_Section
_Work_Goto_Tile_To_File:
	move.w	#SECTION_FILE,Run_Prog_Section
	bra.s	_Work_Goto_Tile_To_Section
	nop

_Work_Goto_Tile_To_Section:
	jsr	Write_Tile_Info
	move.w	#1,_Quit
	rts

*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****			Work Edit Tools & Functions			*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************

_Tile_Work_Mask:

	call	_Calculate_Tile_Node
	move.w	tile_Flags(a0),d0
	andi.w	#FLGF_MASK,d0
	beq.s	.no_masks_for_this_set_of_tiles

	move.w	_Tile_Edit,d0
	call	_Copy_Tile_Use_To_Original


	lea	-bm_SIZEOF(sp),sp
	move.l	sp,a2
	lea	_Tile_BitMap,a0
	move.l	a2,a1
	moveq.l	#bm_SIZEOF,d0
	call	_Copy_Bytes
	
	lea	_Mask_BitMap,a0
	lea	_Tile_BitMap,a1
	moveq.l	#bm_SIZEOF,d0
	call	_Copy_Bytes

	move.l	a2,a0
	lea	_Mask_BitMap,a1
	moveq.l	#bm_SIZEOF,d0
	call	_Copy_Bytes
	
	lea	bm_SIZEOF(sp),sp	

	move.l	_Use_RastPort,_Global_RastPort
	call	_Clear_Global_RastPort	

	move.w	_Tile_Edit,d0
	call	_Copy_Tile_Original_To_Use
;	lea	Region_Tile_Edit,a0
;	call	_Clear_Out_Region
;	lea	Region_Tile_Tile,a0
;	call	_Clear_Out_Region
	call	_Copy_Tile_Use_To_Screen
	call	_Scale_BitMap
	not.b	_Mask_On
.no_masks_for_this_set_of_tiles
	rts

_Clear_Out_Region:
	move.l	_Ed_RastPort,_Global_RastPort
	push	a0
	moveq.l	#0,d0
	call	_SetAPen
	pop	a0
	move.w	rg_LeftEdge(a0),d0
	move.w	rg_TopEdge(a0),d1
	move.w	rg_Width(a0),d2
	move.w	rg_Height(a0),d3

	add.w	d0,d2
	add.w	d1,d3
	sub.w	#1,d2
	sub.w	#1,d3
	call	_RectFill
	rts

_Tile_Work_Clear:
	jsr	_Copy_Tile_Use_To_Backup
	move.l	_Use_RastPort,_Global_RastPort
	call	_Clear_Global_RastPort
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap

	rts

_Clear_Global_RastPort:
	move.l	_Use_RastPort,_Global_RastPort
	move.w	_Colour_Edit_0,d0
	jsr	_SetAPen
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.w	_Tile_Width,d2
	move.w	_Tile_Height,d3
	add.l	d0,d2
	add.l	d1,d3
	subq.l	#1,d2	
	subq.l	#1,d3
	jsr	_RectFill
	rts

_Tile_Work_Undo:
	jsr	_Copy_Tile_Use_To_Temp
	jsr	_Copy_Tile_Backup_To_Use
	jsr	_Copy_Tile_Temp_To_Backup
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	rts

_Tile_Work_Flip_X:
	jsr	_Copy_Tile_Use_To_Backup
	move.l	_Use_RastPort,_Global_RastPort
	
	moveq.l	#0,d0		; srce x
	moveq.l	#0,d1		; srce y
	moveq.l	#0,d2		; dest x
	moveq.l	#0,d3		; dest y
	move.w	_Tile_Width,d4
	move.w	_Tile_Height,d5
	subq.w	#1,d4
	move.w	d4,d7		; height count
	move.w	d4,d2		; dest x
	move.w	#1,d4		; height
	move.w	#$C0,d6		; minterm
	move.l	_Backup_BitMap,a0
	move.l	_Use_BitMap,a1
	sub.l	a2,a2
;	move.l	BitMap2-PC(a5),a2
10$
	movem.l	d7,-(sp)
	move.w	#$FF,d7
	jsr	_BltBitMap
	movem.l	(sp)+,d7
	addq.w	#1,d0
	subq.w	#1,d2
	dbra	d7,10$
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	
	rts

_Tile_Work_Flip_Y:
	jsr	_Copy_Tile_Use_To_Backup
	move.l	_Use_RastPort,_Global_RastPort
	
	moveq.l	#0,d0		; srce x
	moveq.l	#0,d1		; srce y
	moveq.l	#0,d2		; dest x
	moveq.l	#0,d3		; dest y
	move.w	_Tile_Width,d4
	move.w	_Tile_Height,d5
	subq.w	#1,d5
	move.w	d5,d7		; width count
	move.w	d5,d3		; dest y
	move.w	#1,d5		; height
	move.w	#$C0,d6		; minterm
	move.l	_Backup_BitMap,a0
	move.l	_Use_BitMap,a1
	sub.l	a2,a2
;	move.l	BitMap2-PC(a5),a2
10$
	movem.l	d7,-(sp)
	move.w	#$FF,d7
	jsr	_BltBitMap
	movem.l	(sp)+,d7
	addq.w	#1,d1
	subq.w	#1,d3
	dbra	d7,10$
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	
	rts

_Tile_Work_Rotate:		; rotate a tile 90 degrees
	move.w	_Tile_Width,d0
	cmp.w	_Tile_Height,d0
	bne.s	.end_rotate
	jsr	_Copy_Tile_Use_To_Backup
	move.l	_Use_RastPort,_Global_RastPort

	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3

	move.w	_Tile_Height,d7
	bra.s	.next_height_pass
.next_height
	move.w	_Tile_Width,d6
	bra.s	.next_width_pass
.next_width
	push	d0-d3
	move.l	_Backup_RastPort,_Global_RastPort
	jsr	_ReadPixel
	move.l	_Use_RastPort,_Global_RastPort
	jsr	_SetAPen
	pull	d0-d3
	move.w	d7,d1
	exg.l	d0,d1
	jsr	_WritePixel
	pop	d0-d3
	addq.w	#1,d0
.next_width_pass
	dbra	d6,.next_width
	moveq.l	#0,d0
	addq.w	#1,d1
.next_height_pass
	dbra	d7,.next_height

	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
.end_rotate
	rts

_Tile_Work_Swap:		; rotate a tile 90 degrees
	lea	.wait_swap,a0
	jsr	_SetUp_Routine_Wait

.wait_swap	; d0 = > 0 : setup, d0 = 0 : execute, d0 = -1 : shutdown
	tst.l	d0
	bmi	.swap_shutdown
	beq.s	.swap_execute
.swap_setup
	move.l	#BUTTON_ID_SWAP,d0
	jsr	_Work_Eor_Select_Gadget	
	move.w	_Tile_Edit,_Tile_Select_First
	bra	.swap_end
.swap_execute
	cmp.w	#TILE_SELECT_REGION_ID,_Wait_On_Signal
	bne.s	.swap_end
	move.l	_Use_RastPort,_Global_RastPort

	move.w	_Tile_Edit,_Tile_Select_Second

;	jsr	_Copy_Tile_Use_To_Backup

	move.w	_Tile_Select_First,d0
	jsr	_Copy_Tile_Original_To_Use
	jsr	_Copy_Tile_Use_To_Temp

	move.w	_Tile_Select_Second,d0
	jsr	_Copy_Tile_Original_To_Use
	move.w	_Tile_Select_First,d0
	jsr	_Copy_Tile_Use_To_Original
	
	jsr	_Copy_Tile_Temp_To_Use
	move.w	_Tile_Select_Second,d0	
	jsr	_Copy_Tile_Use_To_Original

	jsr	_Copy_Tile_Use_To_Backup

	jsr	_Display_Tile_List_Tile
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap

.swap_shutdown
	jsr	_CleanUp_Routine_Wait
	move.l	#BUTTON_ID_SWAP,d0
	jsr	_Work_Eor_Select_Gadget	
.swap_end
	rts
dbgt9:
_Tile_Work_Merge:

	lea	.wait_merge,a0
	jsr	_SetUp_Routine_Wait

.wait_merge	; d0 = > 0 : setup, d0 = 0 : execute, d0 = -1 : shutdown
	tst.l	d0
	bmi	.merge_shutdown
	beq.s	.merge_execute
.merge_setup
	move.l	#BUTTON_ID_MERGE,d0
	jsr	_Work_Eor_Select_Gadget	
	move.w	_Tile_Edit,_Tile_Select_First
	bra	.merge_end
.merge_execute
	cmp.w	#TILE_SELECT_REGION_ID,_Wait_On_Signal
	bne	.merge_end
	move.l	_Use_RastPort,_Global_RastPort
	jsr	_Copy_Tile_Use_To_Backup

	move.w	_Tile_Edit,_Tile_Select_Second
	
	move.w	_Tile_Select_First,d0
	jsr	_Copy_Tile_Original_To_Use
	jsr	_Copy_Tile_Use_To_Temp
	move.w	_Tile_Select_Second,d0
	jsr	_Copy_Tile_Original_To_Use

	moveq.l	#0,d0
	moveq.l	#0,d1

	move.w	_Tile_Height,d7
	bra.s	.next_height_pass
.next_height
	move.w	_Tile_Width,d6
	bra.s	.next_width_pass
.next_width
	push	d0-d3/d6-d7
	move.l	_Use_RastPort,_Global_RastPort
	add.w	d6,d0
	add.w	d7,d1
	jsr	_ReadPixel
	cmp.w	_Colour_Edit_0,d0
	bne.s	.not_sel_colour
	pull	d0-d3/d6-d7
	move.l	_Temp_RastPort,_Global_RastPort
	exg.l	d0,d2
	exg.l	d1,d3
	add.w	d6,d0
	add.w	d7,d1
	jsr	_ReadPixel
	move.l	_Use_RastPort,_Global_RastPort
	jsr	_SetAPen
	exg.l	d0,d2
	exg.l	d1,d3
	add.w	d6,d0
	add.w	d7,d1
	jsr	_WritePixel
.not_sel_colour
	pop	d0-d3/d6-d7
.next_width_pass
	dbra	d6,.next_width
.next_height_pass
	dbra	d7,.next_height

	move.w	_Tile_Select_Second,d0
	jsr	_Copy_Tile_Use_To_Original

	jsr	_Display_Tile_List_Tile
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap

.merge_shutdown
	jsr	_CleanUp_Routine_Wait
	move.l	#BUTTON_ID_MERGE,d0
	jsr	_Work_Eor_Select_Gadget	
.merge_end
	rts


_Tile_Work_Copy_Clip:
	rts

_Tile_Work_Clip_Paste:
	rts

_Tile_Work_Duplicate:
	rts

_Tile_Work_Erase:
	rts


_Set_Tile_XYWHMM:
	moveq.l	#0,d0			; srce x
	moveq.l	#0,d1			; srce y
	moveq.l	#0,d2			; dest x
	moveq.l	#0,d3			; dest y
	move.w	_Tile_Width,d4		; width
	move.w	_Tile_Height,d5		; height
	move.w	#$CC,d6
	move.w	#$FF,d7
	move.l	_Backup_BitMap,a0	; srce
	move.l	_Use_BitMap,a1		; dest
	sub.l	a2,a2
	rts


_Tile_Work_Roll_Up:
	move.l	_Use_RastPort,_Global_RastPort
	jsr	_Copy_Tile_Use_To_Backup
	jsr	_Set_Tile_XYWHMM
	subq.w	#1,d5
	addq.w	#1,d1
	jsr	_BltBitMap
	add.w	d5,d3
	move.w	#1,d5
	subq.w	#1,d1
	jsr	_BltBitMap
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	rts

_Tile_Work_Roll_Down:
	move.l	_Use_RastPort,_Global_RastPort
	jsr	_Copy_Tile_Use_To_Backup
	jsr	_Set_Tile_XYWHMM
	subq.w	#1,d5
	addq.w	#1,d3
	jsr	_BltBitMap
	add.w	d5,d1
	move.w	#1,d5
	subq.w	#1,d3
	jsr	_BltBitMap
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	rts

_Tile_Work_Roll_Left:
	move.l	_Use_RastPort,_Global_RastPort
	jsr	_Copy_Tile_Use_To_Backup
	jsr	_Set_Tile_XYWHMM
	subq.w	#1,d4
	addq.w	#1,d0
	jsr	_BltBitMap
	add.w	d4,d2
	move.w	#1,d4
	subq.w	#1,d0
	jsr	_BltBitMap
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	rts

_Tile_Work_Roll_Right:
	move.l	_Use_RastPort,_Global_RastPort
	jsr	_Copy_Tile_Use_To_Backup
	jsr	_Set_Tile_XYWHMM
	subq.w	#1,d4
	addq.w	#1,d2
	jsr	_BltBitMap
	add.w	d4,d0
	move.w	#1,d4
	subq.w	#1,d2
	jsr	_BltBitMap
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Scale_BitMap
	rts

;	IFD	dugbarry
;	
;Function_Roll_Up:
;	jsr	Save_Tile_From_Screen
;	jsr	Calc_Tile_XYWH
;	subq.w	#1,d5
;	addq.w	#1,d1
;	move.w	#$CC,d6
;	move.w	#$FF,d7	
;	move.l	TileBitMap-PC(a5),a0
;	move.l	BitMap2-PC(a5),a1
;	move.l	BitMap2-PC(a5),a2
;	jsr	BltBitMap
;	add.w	d5,d3
;	move.w	#1,d5
;	subq.w	#1,d1
;	jsr	BltBitMap
;	jsr	Magnify_Part_2_0
;	rts
;
;Function_Roll_Rt:
;	jsr	Save_Tile_From_Screen
;	jsr	Calc_Tile_XYWH
;	subq.w	#1,d4
;	addq.w	#1,d2
;	move.w	#$CC,d6
;	move.w	#$FF,d7	
;	move.l	TileBitMap-PC(a5),a0
;	move.l	BitMap2-PC(a5),a1
;	move.l	BitMap2-PC(a5),a2
;	jsr	BltBitMap
;	add.w	d4,d0
;	move.w	#1,d4
;	subq.w	#1,d2
;	jsr	BltBitMap
;	jsr	Magnify_Part_2_0
;	rts
;
;Function_Roll_Dn:
;	jsr	Save_Tile_From_Screen
;	jsr	Calc_Tile_XYWH
;	subq.w	#1,d5
;	addq.w	#1,d3
;	move.w	#$CC,d6
;	move.w	#$FF,d7	
;	move.l	TileBitMap-PC(a5),a0
;	move.l	BitMap2-PC(a5),a1
;	move.l	BitMap2-PC(a5),a2
;	jsr	BltBitMap
;	add.w	d5,d1
;	move.w	#1,d5
;	subq.w	#1,d3
;	jsr	BltBitMap
;	jsr	Magnify_Part_2_0
;	rts
;
;Function_Roll_Lf:
;	jsr	Save_Tile_From_Screen
;	jsr	Calc_Tile_XYWH
;	subq.w	#1,d4
;	addq.w	#1,d0
;	move.w	#$CC,d6
;	move.w	#$FF,d7	
;	move.l	TileBitMap-PC(a5),a0
;	move.l	BitMap2-PC(a5),a1
;	move.l	BitMap2-PC(a5),a2
;	jsr	BltBitMap
;	add.w	d4,d2
;	move.w	#1,d4
;	subq.w	#1,d0
;	jsr	BltBitMap
;	jsr	Magnify_Part_2_0
;	rts
;	ENDC

*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****		     Global Work Screen Setup Functions			*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************

_Work_Global_Setup_First:	; a0 - gadget_list
	push	a0
	move.w	#0,_Something_Mask-PC(gl)

	move.l	_Wk_RastPort,_Global_RastPort

	coord.w	000,000,048,53		; draw icon box
	jsr	_Clear_Raised_Hires_Box	; clear box

	coord.w	048,000,558,53		; draw the rest of the display as blank
	jsr	_Clear_Raised_Hires_Box	; clear box

	coord.w	606,000,034,53		; draw the rest of the display as blank
	jsr	_Clear_Raised_Hires_Box	; clear box

	move.l	_Wk_Gadgets,a0			; remove all current work gadgets
	jsr	_Count_Gadgets
	move.l	a0,a1
	move.l	_Wk_Window,a0
	jsr	_RemoveGList

	pop	a0

;;- create all tile work gadgets

;	lea	_Tile_Work_Define_Gadget_List,a0

	lea	_ReActive_Gadgets,a1		; create map define control gadgets/buttons
	move.l	a1,d0
	jsr	_Create_Work_Gadgets

	move.l	_ReActive_Gadgets,a0
	jsr	_Count_Gadgets
	move.l	a0,a1
	move.l	d0,d1				; # gads
	moveq.l	#0,d0				; beginning of list
	move.l	_Wk_Window,a0
	jsr	_AddGList			; add tile define gadgets/buttons to window

	rts	


_Work_Global_Setup_Last:
	move.l	_ReActive_Gadgets,a0
	jsr	Refresh_Work_Gadgets		; ok refresh all gadgets
	rts

_Work_Global_ShutDown:
;	move.w	#BUTTON_ID_DEFINES,d0		; enable activate button
;	move.l	_Active_Gadgets,a0
;	jsr	_Find_GadgetID
;	jsr	_Enable_Gadget

	move.l	_ReActive_Gadgets,a0
	jsr	_Count_Gadgets
	move.l	a0,a1
	move.l	_Wk_Window,a0
	jsr	_RemoveGList		; remove all define gadgets

	move.l	_ReActive_Gadgets,a0
	jsr	_Remove_Work_Gadgets

	move.l	_Wk_Gadgets,a0
	jsr	_Count_Gadgets
	move.l	a0,a1	
	move.l	d0,d1			; # gads
	moveq.l	#0,d0
	move.l	_Wk_Window,a0
	jsr	_AddGList		; add define gadgets to window
	
	move.l	_Wk_RastPort,_Global_RastPort

	move.l	#0,_ReActive_Gadgets
	move.l	#0,_Active_Gadgets

;	move.w	#CHGF_TILE!CHGF_MAPSET!CHGF_XCOORD!CHGF_YCOORD,d0
;	or.w	d0,_Something_Changed-PC(gl)
;	move.w	d0,_Something_Mask-PC(gl)

	rts


_jsr_Routine_Wait:	; d0 = < 0 : shutdown, 0 : execute, > 0 : setup
	push	d1
	move.l	_Wait_Routine,d1
	move.l	d1,a0
	move.l	a0,d1
	beq.s	.end_jsr_wait
	push	d0-d7/a0-a6
	jsr	(a0)
	pop	d0-d7/a0-a6
.end_jsr_wait
	pop	d1
	rts

_SetUp_Routine_Wait:
	moveq.l	#0,d0
	cmpa.l	_Wait_Routine,a0	; see if jsring routine is already running
	bne.s	.not_same		; no not same routine
	not.l	d0			; yes jsrer is same routine, signal this
	bra.s	.end_setup_wait
.not_same
	tst.l	_Wait_Routine		; test if a routine running
	bne.s	.end_setup_wait		; yes so exit with signal
	move.l	a0,_Wait_Routine	; no so set wait to jsrer
	move.l	a0,d0			; and signal
	move.w	#0,_Wait_On_Signal	; clear wait signal
.end_setup_wait
	rts

_CleanUp_Routine_Wait:
;	moveq.l	#-1,d0			; ShutDown
;	jsr	_jsr_Routine_Wait
	move.l	#0,_Wait_Routine
	move.w	#0,_Wait_On_Signal
	rts



*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****		   Define Tiles Setup, Handler & ShutDown		*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************
dbgt10:
_Tile_Work_Define_Setup_Setup:


	move.l	_Wk_RastPort,_Global_RastPort

	jsr	_Calculate_Tile_Node
	move.l	a0,a1
	move.w	#STRING_ID_DEFINE1STR,d0
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation
	move.w	tile_Width(a1),d1
	jsr	_Write_Define_Numeric_Gadget_String
	
	move.w	#STRING_ID_DEFINE2STR,d0
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation
	move.w	tile_Height(a1),d1
	jsr	_Write_Define_Numeric_Gadget_String

	move.w	#STRING_ID_DEFINE3STR,d0
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation
	move.w	tile_Depth(a1),d1
	jsr	_Write_Define_Numeric_Gadget_String

	move.w	#STRING_ID_DEFINE4STR,d0
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation
	move.w	tile_Amount(a1),d1
	jsr	_Write_Define_Numeric_Gadget_String


	jsr	_Calculate_Tile_Node

	lea	_Tile_Values,a1
	move.w	tile_Width(a0),(0*pdv_SIZEOF)+pdv_value(a1)
	move.w	tile_Height(a0),(1*pdv_SIZEOF)+pdv_value(a1)
	move.w	tile_Depth(a0),(2*pdv_SIZEOF)+pdv_value(a1)
	move.w	tile_Amount(a0),(3*pdv_SIZEOF)+pdv_value(a1)
	move.w	tile_Flags(a0),d0
	bset	#FLGB_RETAIN,d0
	move.w	d0,(4*pdv_SIZEOF)+pdv_value(a1)
	move.l	a1,a0
	jsr	_Tile_Work_Define_Tick_Setup
	jsr	_Tile_Work_Define_MX_Setup

	move.w	#CHGF_TILESET,d0
	or.w	d0,_Something_Changed-PC(gl)
	move.w	d0,_Something_Mask-PC(gl)

	call	_Work_Global_Setup_Last	

	rts

_Tile_Work_Define_Setup:
	tst.l	_Active_Gadgets
	bne	.end_define_setup
	lea	_Tile_Work_Define_Gadget_List,a0
	jsr	_Work_Global_Setup_First
	jsr	_Tile_Work_Define_Setup_Setup
	jsr	_Work_Global_Setup_Last
.end_define_setup
	rts

_Tile_Values:
_Tile_Width_Value:	DC.W	0,MINWIDTH_TILE,MAXWIDTH_TILE,0
_Tile_Height_Value:	DC.W	0,MINHEIGHT_TILE,MAXHEIGHT_TILE,0
_Tile_Depth_Value:	DC.W	0,1,8,0
_Tile_Amount_Value:	DC.W	0,2,1024,0
_Tile_Format_Value:	DC.W	0,$0000,$FFFF,0


_Tile_Work_Define_Width_Inc:
	move.w	#STRING_ID_DEFINE1STR,d0
	lea	_Tile_Width_Value,a0
	bra.s	_Tile_Increase_Define
_Tile_Work_Define_Height_Inc:
	move.w	#STRING_ID_DEFINE2STR,d0
	lea	_Tile_Height_Value,a0
	bra.s	_Tile_Increase_Define
_Tile_Work_Define_Depth_Inc:
	move.w	#STRING_ID_DEFINE3STR,d0
	lea	_Tile_Depth_Value,a0
	bra.s	_Tile_Increase_Define
_Tile_Work_Define_Amount_Inc:
	move.w	#STRING_ID_DEFINE4STR,d0
	lea	_Tile_Amount_Value,a0
;	bra.s	_Tile_Increase_Define
_Tile_Increase_Define:
	jsr	_Increase_Work_Define_Value
	rts

_Tile_Work_Define_Width_Dec:
	move.w	#STRING_ID_DEFINE1STR,d0
	lea	_Tile_Width_Value,a0
	bra.s	_Tile_Decrease_Define
_Tile_Work_Define_Height_Dec:
	move.w	#STRING_ID_DEFINE2STR,d0
	lea	_Tile_Height_Value,a0
	bra.s	_Tile_Decrease_Define
_Tile_Work_Define_Depth_Dec:
	move.w	#STRING_ID_DEFINE3STR,d0
	lea	_Tile_Depth_Value,a0
	bra.s	_Tile_Decrease_Define
_Tile_Work_Define_Amount_Dec:
	move.w	#STRING_ID_DEFINE4STR,d0
	lea	_Tile_Amount_Value,a0
;	bra.s	_Tile_Decrease_Define
_Tile_Decrease_Define
	jsr	_Decrease_Work_Define_Value
	rts

_Tile_Work_Define_Width_SetFromString:
	move.w	#STRING_ID_DEFINE1STR,d0
	lea	_Tile_Width_Value,a0
	bra.s	_Tile_SetFromString_Define
_Tile_Work_Define_Height_SetFromString:
	move.w	#STRING_ID_DEFINE2STR,d0
	lea	_Tile_Height_Value,a0
	bra.s	_Tile_SetFromString_Define
_Tile_Work_Define_Depth_SetFromString:
	move.w	#STRING_ID_DEFINE3STR,d0
	lea	_Tile_Depth_Value,a0
	bra.s	_Tile_SetFromString_Define
_Tile_Work_Define_Amount_SetFromString:
	move.w	#STRING_ID_DEFINE4STR,d0
	lea	_Tile_Amount_Value,a0
	bra.s	_Tile_SetFromString_Define

	nop

_Tile_SetFromString_Define:	
	jsr	_SetFromString_Define
;	jsr	_Get_WorkGadgetStringInteger	; get value from string longint gad
;	move.w	d0,pdv_value(a0)
	
	rts	

_Tile_Work_Define_Tick_Setup:
	jsr	_Tile_Work_Define_Retain_Setup
	jsr	_Tile_Work_Define_Mask_Setup
	jsr	_Tile_Work_Define_NoCols_Setup
	jsr	_Tile_Work_Define_16Bit_Setup
	jsr	_Tile_Work_Define_Sprite_Setup
	rts

dbg22:


_Tile_Work_Define_Set_Retain:
	move.w	#BUTTON_ID_DEFINE1TICK,d0
	move.w	#FLGB_RETAIN,d1
	rts
_Tile_Work_Define_Set_Mask:
	move.w	#BUTTON_ID_DEFINE2TICK,d0
	move.w	#FLGB_MASK,d1
	rts
_Tile_Work_Define_Set_NoCols:
	move.w	#BUTTON_ID_DEFINE3TICK,d0
	move.w	#FLGB_NOCOLS,d1
	rts
_Tile_Work_Define_Set_16Bit:
	move.w	#BUTTON_ID_DEFINE4TICK,d0
	move.w	#FLGB_16BIT,d1
	rts
_Tile_Work_Define_Set_Sprite:
	move.w	#BUTTON_ID_DEFINE4TICK,d0
	move.w	#FLGB_SPRITE,d1
	rts	

_Tile_Work_Define_Retain:
	jsr	_Tile_Work_Define_Set_Retain
	bra.s	_Tile_Work_Define_Bit_Manip_Get
_Tile_Work_Define_Mask:
	jsr	_Tile_Work_Define_Set_Mask
	bra.s	_Tile_Work_Define_Bit_Manip_Get
_Tile_Work_Define_NoCols:
	jsr	_Tile_Work_Define_Set_NoCols
	bra.s	_Tile_Work_Define_Bit_Manip_Get
_Tile_Work_Define_16Bit:
	jsr	_Tile_Work_Define_Set_16Bit
	bra.s	_Tile_Work_Define_Bit_Manip_Get
_Tile_Work_Define_Sprite:
	jsr	_Tile_Work_Define_Set_Sprite
	bra.s	_Tile_Work_Define_Bit_Manip_Get
	nop

_Tile_Work_Define_Bit_Manip_Get:
	jsr	_Work_Window_Gadgets_Ptr
	lea	_Tile_Format_Value,a1
	jsr	_Check_Out_Bits_And_Get_A1_Accordingly
	rts

dbgt8:
_Tile_Work_Define_Retain_Setup:
	jsr	_Tile_Work_Define_Set_Retain
	bra.s	_Tile_Work_Define_Bit_Manip_Set
_Tile_Work_Define_Mask_Setup:
	jsr	_Tile_Work_Define_Set_Mask
	bra.s	_Tile_Work_Define_Bit_Manip_Set
_Tile_Work_Define_NoCols_Setup:
	jsr	_Tile_Work_Define_Set_NoCols
	bra.s	_Tile_Work_Define_Bit_Manip_Set
_Tile_Work_Define_16Bit_Setup:
	jsr	_Tile_Work_Define_Set_16Bit
	bra.s	_Tile_Work_Define_Bit_Manip_Set
_Tile_Work_Define_Sprite_Setup:
	jsr	_Tile_Work_Define_Set_Sprite
	bra.s	_Tile_Work_Define_Bit_Manip_Set

	nop

_Tile_Work_Define_Bit_Manip_Set:
	jsr	_Work_Window_Gadgets_Ptr
	lea	_Tile_Format_Value,a1
	jsr	_Check_Out_Bits_And_Set_A1_Accordingly
	rts


_Work_Window_Gadgets_Ptr:
	move.l	_Wk_Window,a0
	move.l	wd_FirstGadget(a0),a0
	rts

dbg21:

_Tile_Work_Define_MX_Control:	; d0 - start mx gad id, d1 - mx gad to set, d2 - max mx gads in list
;	move.l	_Wk_Gadgets,a0
;	move.l	_Wk_Window,a1
;	move.l	wd_FirstGadget(a1),a0
	jsr	_Work_Window_Gadgets_Ptr
	push	d0-d2/a0
	move.w	d2,d1
	jsr	_ResetGadgets
	pull	d0-d2/a0
	move.w	d1,d0
	jsr	_SetGadget
	pop	d0-d2/a0
	jsr	_Find_GadgetID
	move.w	d2,d0
	move.l	_Wk_Window,a1
	jsr	_RefreshGList
	rts

_Tile_Work_Define_MX_Setup:
;	move.w	#BUTTON_ID_DEFINE1MX,d1
	move.w	_Tile_Format_Value,d1
	andi.w	#FLGF_STB0|FLGF_STB1,d1
	add.w	#BUTTON_ID_DEFINE1MX,d1
	bra.s	_Tile_Work_Define_MX_Do
_Tile_Work_Define_MX1:
	move.w	#BUTTON_ID_DEFINE1MX,d1
	bra.s	_Tile_Work_Define_MX_Do
_Tile_Work_Define_MX2:
	move.w	#BUTTON_ID_DEFINE2MX,d1
	bra.s	_Tile_Work_Define_MX_Do
_Tile_Work_Define_MX3:
	move.w	#BUTTON_ID_DEFINE3MX,d1
	bra.s	_Tile_Work_Define_MX_Do
_Tile_Work_Define_MX4:
	move.w	#BUTTON_ID_DEFINE4MX,d1
	bra.s	_Tile_Work_Define_MX_Do
	nop
_Tile_Work_Define_MX_Do:
	push	d1
	sub.w	#BUTTON_ID_DEFINE1MX,d1
	move.w	_Tile_Format_Value,d0		; get current flags
	andi.w	#~(FLGF_STB0|FLGF_STB1),d0	; cut out not format bits
	or.w	d1,d0
	move.w	d0,_Tile_Format_Value
	pop	d1	
	move.w	#BUTTON_ID_DEFINE1MX,d0
	move.w	#4,d2
	jsr	_Tile_Work_Define_MX_Control
	rts


_Tile_Work_Define_Cancel:
	jsr	_Tile_Work_Define_ShutDown
	rts

_Tile_Work_Define_Apply:
	lea	_Tile_Values,a0
	move.w	_Tile_Set-PC(gl),d0
	move.w	(0*pdv_SIZEOF)+pdv_value(a0),d1	; width
	move.w	(1*pdv_SIZEOF)+pdv_value(a0),d2	; height
	move.w	(2*pdv_SIZEOF)+pdv_value(a0),d3	; depth
	move.w	(3*pdv_SIZEOF)+pdv_value(a0),d4	; amount
	move.w	(4*pdv_SIZEOF)+pdv_value(a0),d5		; flags

	cmp.w	_Tile_Width-PC(gl),d1
	bne.s	.value_changed
	cmp.w	_Tile_Height-PC(gl),d2
	bne.s	.value_changed
	cmp.w	_Tile_Depth-PC(gl),d3
	bne.s	.value_changed
	cmp.w	_Tile_Amount-PC(gl),d4
	bne.s	.value_changed
	move.w	_Tile_Flags-PC(gl),d6
	move.w	d5,d7
;	andi.w	#$0,d6
;	andi.w	#$0,d7
	
	cmp.w	d6,d7
	bne.s	.value_changed
	bra.s	.end_apply
.value_changed
	push	d0-d7
	move.w	_Tile_Edit,d0
	jsr	_Copy_Tile_Use_To_Original
	pop	d0-d7
	jsr	_Replace_Tile_Node
	jsr	_Check_Tile_Edit_Screen
.end_apply
	rts

_Tile_Work_Define_Ok:
	jsr	_Tile_Work_Define_Apply
	jsr	_Tile_Work_Define_ShutDown
	rts

_Tile_Work_Define_ShutDown:
	jsr	_Work_Global_ShutDown
	jsr	_Tile_Work_Display
	rts


*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****		     Work Intuition Handling Routines			*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************


_Tile_Work_Message_List:
	DC.L	IDCMP_MOUSEMOVE,_Handle_Tile_Work_MouseMove
	DC.L	IDCMP_GADGETDOWN,_Handle_Tile_Work_GadgetDown
	DC.L	IDCMP_GADGETUP,_Handle_Tile_Work_GadgetUp
	DC.L	IDCMP_INTUITICKS,_Handle_Tile_Work_IntuiTicks
	DC.L	IDCMP_VANILLAKEY,_Handle_Tile_Work_VanillaKey
	DC.L	-1

;**********************
;**  Work MouseMove  **
;**********************

_Handle_Tile_Work_MouseMove:
	move.l	_Wk_Window,a1
	move.w	wd_MouseX(a1),d0
	move.w	wd_MouseY(a1),d1
	tst.w	d1
	bpl.s	.not_on_edit_screen
	move.l	_Ed_Window,a0
	jsr	_ActivateWindow
.not_on_edit_screen

;	jsr	_Handle_Tile_Work_MouseMove
	rts

;************************
;**  Work Gadget Down  **
;************************

_Handle_Tile_Work_GadgetDown:
;	move.w	#$0f0,$DFF180
	lea	_Tile_Work_GadgetDown_List,a0
	jsr	_Handle_Work_GadgetDown
	rts

_Tile_Work_GadgetDown_List:
	SetGadgetID	BUTTON_ID_SHIFTU,_Tile_Work_Roll_Up
	SetGadgetID	BUTTON_ID_SHIFTD,_Tile_Work_Roll_Down
	SetGadgetID	BUTTON_ID_SHIFTL,_Tile_Work_Roll_Left
	SetGadgetID	BUTTON_ID_SHIFTR,_Tile_Work_Roll_Right
	SetGadgetID	BUTTON_ID_TILEPREV,_Tile_Work_Prev_Tile
	SetGadgetID	BUTTON_ID_TILENEXT,_Tile_Work_Next_Tile

;
;;	define gadget in & dec buttons
;

	SetGadgetID	BUTTON_ID_DEFINE1DEC,_Tile_Work_Define_Width_Dec
	SetGadgetID	BUTTON_ID_DEFINE1INC,_Tile_Work_Define_Width_Inc
	SetGadgetID	BUTTON_ID_DEFINE2DEC,_Tile_Work_Define_Height_Dec
	SetGadgetID	BUTTON_ID_DEFINE2INC,_Tile_Work_Define_Height_Inc
	SetGadgetID	BUTTON_ID_DEFINE3DEC,_Tile_Work_Define_Depth_Dec
	SetGadgetID	BUTTON_ID_DEFINE3INC,_Tile_Work_Define_Depth_Inc
	SetGadgetID	BUTTON_ID_DEFINE4DEC,_Tile_Work_Define_Amount_Dec
	SetGadgetID	BUTTON_ID_DEFINE4INC,_Tile_Work_Define_Amount_Inc
;
;;	palette sliders
;

	SetGadgetID	SLIDER_ID_PALETTERED,_Tile_Work_Palette_Slider_Red
	SetGadgetID	SLIDER_ID_PALETTEGREEN,_Tile_Work_Palette_Slider_Green
	SetGadgetID	SLIDER_ID_PALETTEBLUE,_Tile_Work_Palette_Slider_Blue


	DC.W		-1

;**********************
;**  Work Gadget Up  **
;**********************

_Handle_Tile_Work_GadgetUp:
;	move.w	#$00f,$DFF180
	lea	_Tile_Work_GadgetUp_List,a0
	jsr	_Execute_Gadget_List
	rts

_Tile_Work_FromStringSet_Tile:

	move.w	#STRING_ID_CURRTILE,d0
	jsr	_Get_WorkGadgetStringInteger	; get value from string longint gad

	move.w	_Tile_Amount,d1
	subq.w	#1,d1
	cmp.w	d1,d0
	bls.s	.tile_ok
	move.w	d1,d0
.tile_ok

	jsr	_Save_OldTile_Load_NewTile

.new_object_display

	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	rts


_Tile_Work_GadgetUp_List:
;	SetGadgetID	BUTTON_ID_MAP,_Work_Goto_Tile_To_Map
;;	SetGadgetID	BUTTON_ID_ANIM,_Work_Goto_Tile_To_Anim
;;	SetGadgetID	BUTTON_ID_COPPER,_Work_Goto_Tile_To_Copper
;	SetGadgetID	BUTTON_ID_FILE,_Work_Goto_Tile_To_File
;
;	SetGadgetID	STRING_ID_TILENAME,_Tile_Work_Name_Change
;
;	SetGadgetID	BUTTON_ID_MASK,_Tile_Work_Mask
;
;	SetGadgetID	BUTTON_ID_CLEAR,_Tile_Work_Clear
;	SetGadgetID	BUTTON_ID_UNDO,_Tile_Work_Undo
;
;
;	SetGadgetID	BUTTON_ID_FLIPX,_Tile_Work_Flip_X
;	SetGadgetID	BUTTON_ID_FLIPY,_Tile_Work_Flip_Y
;	SetGadgetID	BUTTON_ID_ROTATE,_Tile_Work_Rotate
;;	SetGadgetID	BUTTON_ID_COPY,_Tile_Work_ToClip
;;	SetGadgetID	BUTTON_ID_PASTE,_Tile_Work_FromClip
;
;	SetGadgetID	BUTTON_ID_SWAP,_Tile_Work_Swap
;	SetGadgetID	BUTTON_ID_MERGE,_Tile_Work_Merge
;;	SetGadgetID	BUTTON_ID_DUPLICATE,_Tile_Work_Duplicate
;;	SetGadgetID	BUTTON_ID_ERASE,_Tile_Work_Erase
;
;		
;.tile_work_tools_start
;	SetGadgetID	BUTTON_ID_SCRIBBLE,_Tile_Work_Scribble
;	SetGadgetID	BUTTON_ID_DRAW,_Tile_Work_Draw
;	SetGadgetID	BUTTON_ID_LINE,_Tile_Work_Line
;	SetGadgetID	BUTTON_ID_BEND,_Tile_Work_Bend
;	SetGadgetID	BUTTON_ID_POLY,_Tile_Work_Poly
;	SetGadgetID	BUTTON_ID_RECTANGLE,_Tile_Work_Rectangle
;	SetGadgetID	BUTTON_ID_CIRCLE,_Tile_Work_Circle
;	SetGadgetID	BUTTON_ID_FILL,_Tile_Work_Fill
;	
;	SetGadgetID	BUTTON_ID_CUT,_Tile_Work_Cut
;.tile_work_tools_end
;NUMBER_TILE_WORK_TOOLS	equ	(.tile_work_tools_end-.tile_work_tools_start)/6
;
;;
;;; these six (6) are now in the gadget down message list
;;
;
;;	SetGadgetID	BUTTON_ID_SHIFTU,_Tile_Work_Roll_Up
;;	SetGadgetID	BUTTON_ID_SHIFTD,_Tile_Work_Roll_Down
;;	SetGadgetID	BUTTON_ID_SHIFTL,_Tile_Work_Roll_Left
;;	SetGadgetID	BUTTON_ID_SHIFTR,_Tile_Work_Roll_Right
;
;;	SetGadgetID	BUTTON_ID_TILEPREV,_Tile_Work_Prev_Tile
;;	SetGadgetID	BUTTON_ID_TILENEXT,_Tile_Work_Next_Tile
;
;	SetGadgetID	STRING_ID_CURRTILE,_Tile_Work_FromStringSet_Tile
;
;
;	SetGadgetID	BUTTON_ID_TILESETPREV,_Tile_Work_Prev_TileSet
;	SetGadgetID	BUTTON_ID_TILESETNEXT,_Tile_Work_Next_TileSet
;
;
;;
;;; these have not yet been written
;;
;
;;	SetGadgetID	BUTTON_ID_TILECHG,_Tile_Work_Change_Tile
;
;;	SetGadgetID	BUTTON_ID_DEFINE,_Tile_Work_Change_Tile
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;									 ;
;;;		Defines gadget entries : for defining tile sizes	;;
;;									 ;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	SetGadgetID	BUTTON_ID_CONFIGURATION,_Tile_Work_Define_Setup
;
;	SetGadgetID	BUTTON_ID_DEFINEPREV,_Define_Tile_Work_Prev_TileSet
;	SetGadgetID	BUTTON_ID_DEFINENEXT,_Define_Tile_Work_Next_TileSet
;
;	SetGadgetID	STRING_ID_DEFINE1STR,_Tile_Work_Define_Width_SetFromString
;	SetGadgetID	STRING_ID_DEFINE2STR,_Tile_Work_Define_Height_SetFromString
;	SetGadgetID	STRING_ID_DEFINE3STR,_Tile_Work_Define_Depth_SetFromString
;	SetGadgetID	STRING_ID_DEFINE4STR,_Tile_Work_Define_Amount_SetFromString
;
;	SetGadgetID	BUTTON_ID_DEFINE1TICK,_Tile_Work_Define_Retain
;	SetGadgetID	BUTTON_ID_DEFINE2TICK,_Tile_Work_Define_Mask
;	SetGadgetID	BUTTON_ID_DEFINE3TICK,_Tile_Work_Define_NoCols
;	SetGadgetID	BUTTON_ID_DEFINE4TICK,_Tile_Work_Define_16Bit
;	SetGadgetID	BUTTON_ID_DEFINE5TICK,_Tile_Work_Define_Sprite
;
;	SetGadgetID	BUTTON_ID_DEFINE1MX,_Tile_Work_Define_MX1
;	SetGadgetID	BUTTON_ID_DEFINE2MX,_Tile_Work_Define_MX2
;	SetGadgetID	BUTTON_ID_DEFINE3MX,_Tile_Work_Define_MX3
;	SetGadgetID	BUTTON_ID_DEFINE4MX,_Tile_Work_Define_MX4
;
;	SetGadgetID	BUTTON_ID_DEFINEOK,_Tile_Work_Define_Ok
;;	SetGadgetID	BUTTON_ID_DEFINEAPPLY,_Map_Work_Define_Apply
;	SetGadgetID	BUTTON_ID_DEFINECANCEL,_Tile_Work_Define_Cancel
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;									 ;
;;;			Palette gadget entries				;;
;;									 ;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	SetGadgetID	BUTTON_ID_PALETTE,_Tile_Work_Palette_Setup
;
;	SetGadgetID	SLIDER_ID_PALETTERED,_Tile_Work_Palette_Slider_Red
;	SetGadgetID	SLIDER_ID_PALETTEGREEN,_Tile_Work_Palette_Slider_Green
;	SetGadgetID	SLIDER_ID_PALETTEBLUE,_Tile_Work_Palette_Slider_Blue
;
;	SetGadgetID	BUTTON_ID_PALETTESETPREV,_Palette_Work_Prev_PaletteSet
;	SetGadgetID	BUTTON_ID_PALETTESETPREV,_Palette_Work_Next_PaletteSet
;
;	SetGadgetID	STRING_ID_PALETTENAME,_Palette_Work_Name_Change
;
;	SetGadgetID	BUTTON_ID_PALETTERGBDISP,_Tile_Work_Palette_RGB_Display
;
;	SetGadgetID	BUTTON_ID_PALETTEOK,_Tile_Work_Palette_Ok
;	SetGadgetID	BUTTON_ID_PALETTECOPY,_Tile_Work_Palette_Copy
;	SetGadgetID	BUTTON_ID_PALETTEEXCHG,_Tile_Work_Palette_Exchange
;	SetGadgetID	BUTTON_ID_PALETTESPREAD,_Tile_Work_Palette_Spread
;	SetGadgetID	BUTTON_ID_PALETTEPICK,_Tile_Work_Palette_Pick
;	SetGadgetID	BUTTON_ID_PALETTEUNDO,_Tile_Work_Palette_Undo
;	SetGadgetID	BUTTON_ID_PALETTEREVERT,_Tile_Work_Palette_Revert
;	SetGadgetID	BUTTON_ID_PALETTECANCEL,_Tile_Work_Palette_Cancel
;
;
	DC.L	-1



_Define_Tile_Work_Prev_TileSet:
	call	_Tile_Work_Prev_TileSet
	call	_Tile_Work_Define_Setup_Setup
	call	_Work_Global_Setup_Last
	rts

_Define_Tile_Work_Next_TileSet:
	call	_Tile_Work_Next_TileSet
	call	_Tile_Work_Define_Setup_Setup
	call	_Work_Global_Setup_Last

	rts

_Tile_Work_Prev_TileSet:
.minus_tile
	move.w	_Tile_Set,d0
	move.w	#0,d1	; min set
	cmp.w	d1,d0
	beq.s	.ok_minus
	subq.w	#1,d0
	cmp.w	d1,d0
	bgt.s	.minus_ok
	move.w	d1,d0
.minus_ok
	push	d0
	jsr	Write_Tile_Info
;	jsr	Write_Map_Info
;	jsr	Read_Map_Info
	pop	d0
	move.w	d0,_Tile_Set
	jsr	_Check_Tile_Edit_Screen
.ok_minus
	rts


_Tile_Work_Next_TileSet:
.plus_tile
	move.w	_Tile_Set,d0
	move.w	#MAX_TILES,d1
	cmp.w	d1,d0
	beq.s	.ok_plus
	addq.w	#1,d0
	cmp.w	d1,d0
	blt.s	.plus_ok
	move.w	d1,d0
.plus_ok
	push	d0
	jsr	_Count_Tile_Nodes		; count nodes
	move.l	d0,d1
	pop	d0
	cmp.w	d1,d0
	blt.s	.not_new_tile
	lea	_Text_FileType_Tile,a0
	lea	_Text_Create_New,a1
	push	d0
	jsr	_Ask_Request
	move.l	d0,d1
	pop	d0
	tst.l	d1
	beq.s	.ok_plus
.not_new_tile
	push	d0
	jsr	Write_Tile_Info
;	jsr	Write_Map_Info
;	jsr	Read_Map_Info
	pop	d0
	move.w	d0,_Tile_Set
	jsr	_Check_Tile_Edit_Screen
.ok_plus
	rts

_Tile_Work_Prev_Tile:
	move.w	_Tile_Edit,d0
	move.w	#0,d1
	sub.w	#1,d0
	cmp.w	d1,d0
	bpl.s	.tile_not_min
	move.w	d1,d0
.tile_not_min
;	move.w	d0,_Tile_Edit

	jsr	_Save_OldTile_Load_NewTile

	lea	Region_Tile_Select,a1

	move.w	_Tile_Edit,d0
	ext.l	d0

	cmp.w	#0,d0
	ble.s	.new_object_display

	move.w	rg_Width(a1),d2
	move.w	rg_Height(a1),d3
	ext.l	d2
	ext.l	d3
	divu	_Tile_Width,d2		; now # of tiles wide select rg is
	divu	_Tile_Height,d3
	ext.l	d2
	move.w	_Tile_Top,d4
	divu	d2,d0
	move.w	d0,d1
	clr.w	d0
	swap	d0
	cmp.w	d4,d1
	bge.s	.new_object_display
	
	subq.w	#1,_Tile_Top
	jsr	_Display_Tile_List_Tile
.new_object_display


	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	rts


_Tile_Work_Next_Tile:

	move.w	_Tile_Edit,d0
	move.w	_Tile_Amount,d1
	subq.w	#1,d1
	add.w	#1,d0
	cmp.w	d1,d0
	blo.s	.tile_not_max
	move.w	d1,d0
.tile_not_max
;	move.w	d0,_Tile_Edit

	jsr	_Save_OldTile_Load_NewTile

	lea	Region_Tile_Select,a1

	move.w	_Tile_Edit,d0
	ext.l	d0
	
	cmp.w	_Tile_Amount,d0
	bge.s	.new_object_display
	
	move.w	rg_Width(a1),d2
	move.w	rg_Height(a1),d3
	ext.l	d2
	ext.l	d3
	divu	_Tile_Width,d2		; now # of tiles wide select rg is
	divu	_Tile_Height,d3
	move.w	_Tile_Top,d4
	mulu	d2,d4
	sub.w	d4,d0
	divu	d2,d0
	move.w	d0,d1
	clr.w	d0
	swap	d0
	cmp.w	d3,d1
	blt.s	.new_object_display
	
	addq.w	#1,_Tile_Top

	jsr	_Display_Tile_List_Tile

.new_object_display


	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	rts


;***********************
;**  Work IntuiTicks  **
;***********************
dbgt1:
_Handle_Tile_Work_IntuiTicks:
	jsr	_Handle_IntuiTicks_Text
	jsr	_Handle_Tile_Work_MouseMove

	rts

;***********************
;**  Work VanillaKey  **
;***********************
dbgtv1:
_Handle_Tile_Work_VanillaKey:
	lea	_Tile_Work_VanillaKey_List,a0
	jsr	_Execute_VanillaKey_List
	rts

_Tile_Edit_VanillaKey_List:
_Tile_Work_VanillaKey_List:

	SetVanilla	$2C,-1,_Tile_Work_Prev_Tile	; comma
	SetVanilla	".",-1,_Tile_Work_Next_Tile	; period

	SetVanilla	"]",-1,_Tile_Increase_Color0	;
	SetVanilla	"[",-1,_Tile_Decrease_Color0	;
	SetVanilla	"}",-1,_Tile_Increase_Color1	;
	SetVanilla	"{",-1,_Tile_Decrease_Color1	;

	SetVanilla	"+",-1,_Tile_Increase_Depth	;
	SetVanilla	"=",-1,_Tile_Increase_Depth	;
	SetVanilla	"_",-1,_Tile_Decrease_Depth	;
	SetVanilla	"-",-1,_Tile_Decrease_Depth	;

	SetVanilla	">",-1,_Tile_Increase_MagnifyFactor
	SetVanilla	"<",-1,_Tile_Decrease_MagnifyFactor


	SetVanilla	$1b,-1,_Map_Edit_Escape
	SetVanilla	$20,-1,_Map_Edit_Space
	DC.W	-1



*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****		     Edit Intuition Handling Routines			*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************


_Tile_Edit_Message_List:
	DC.L	IDCMP_MOUSEBUTTONS,_Handle_Tile_Edit_MouseButtons
	DC.L	IDCMP_MOUSEMOVE,_Handle_Tile_Edit_MouseMove
	DC.L	IDCMP_RAWKEY,_Handle_Tile_Edit_RawKey
	DC.L	IDCMP_VANILLAKEY,_Handle_Tile_Edit_VanillaKey
	DC.L	IDCMP_INTUITICKS,_Handle_Tile_Edit_IntuiTicks
	DC.L	-1

_Handle_Tile_Edit_MouseButtons:
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.w	_Tile_Edit_X,d0
	move.w	_Tile_Edit_Y,d1


	move.w	#0,_Select_Button

	moveq.l	#0,d2
	move.w	im_Qualifier(a1),d2
;	move.l	d2,abc
	btst	#14,d2
	beq.s	.not_select
	move.w	_Region_Run_ID,_Select_Button

	move.w	#TOOL_BUTTONDOWN_FLAG,d7
	jsr	Execute_Tool_Procedure
	
	bra.s	.buttons_ok
.not_select
	move.w	#TOOL_BUTTONUP_FLAG,d7
	jsr	Execute_Tool_Procedure
;	bra.s	.buttons_ok
.select_end

	move.w	#0,_Menu_Button

	btst	#13,d2
	beq.s	.not_menu
	move.w	_Region_Run_ID,_Menu_Button
	move.w	#TOOL_BUTTONDOWN_FLAG,d7
	jsr	Execute_Tool_Procedure
	bra.s	.buttons_ok
.not_menu
	move.w	#TOOL_BUTTONUP_FLAG,d7
	jsr	Execute_Tool_Procedure

.buttons_ok
	jsr	Check_Tile_Select_Button
	jsr	Check_Tile_Menu_Button
.pick_ok
	jsr	_Handle_Tile_Edit_MouseMove

;	moveq.l	#0,d0
;	move.w	_Region_Run_ID,d0
;	move.l	d0,LL1


	rts

Check_Tile_Select_Button:
	cmp.w	#TILE_EDIT_REGION_ID,_Select_Button
	bne.s	.select_button_end
	clr.l	d0
	clr.l	d1
	move.w	_Tile_Edit_X,d0
	move.w	_Tile_Edit_Y,d1

	move.w	#TOOL_WRITE_FLAG,d7
	jsr	Execute_Tool_Procedure	
.select_button_end
	rts

Check_Tile_Menu_Button:
	cmp.w	#TILE_EDIT_REGION_ID,_Menu_Button
	bne.s	.select_button_end
	clr.l	d0
	clr.l	d1
	move.w	_Tile_Edit_X,d0
	move.w	_Tile_Edit_Y,d1

	move.w	#TOOL_WRITE_FLAG,d7
	jsr	Execute_Tool_Procedure

.select_button_end
	rts


;**********************
;**  Edit MouseMove  **
;**********************


_Handle_Tile_Edit_MouseMove:
	move.l	_Ed_Window,a1
	move.w	wd_MouseX(a1),d0
	move.w	wd_MouseY(a1),d1

;	lea	_Message,a1
;	move.w	im_MouseX(a1),d0
;	move.w	im_MouseY(a1),d1
	lea	_Tile_Region_Coordinates,a0
	jsr	_Check_Regions

	moveq.l	#0,d0
	move.w	_Region_Run_ID,d0
;	move.l	d0,LL2
	moveq.l	#0,d0
	move.w	_Select_Button,d0
;	move.l	d0,LL3

	rts

; pal

;_BaseScreenWidth:	DC.W	320
;_BaseScreenHeight:	DC.W	256
;
;_
;
;_Position_Regions:
;; we have to cater for hires & superhires screen, laced as well
;; to do this we calculate the ratio's of the screen that is being
;; used.  a base screen is 320x200 for NTSC and 320x256 for PAL
;	
;	move.w	_BaseScreenWidth,d0
;	
;
;	rts


_Tile_Region_Coordinates:
Region_Tile_Edit:	DC.W	TILE_EDIT_REGION_ID,000,000,128,128
			DC.L	Tile_Edit_Region
Region_Tile_Select:	DC.W	TILE_SELECT_REGION_ID,000,136,320,064
			DC.L	Tile_Select_Region
Region_Tile_Colour:	DC.W	TILE_COLOUR_REGION_ID,208,000,028,112
			DC.L	Tile_Colour_Region
Region_Tile_Tile:	DC.W	TILE_TILE_REGION_ID,136,000,064,064
			DC.L	0	;Tile_Tile_Region
Region_Tile_Move:	DC.W	TILE_MOVE_REGION_ID,136,064,064,064
			DC.L	0
Region_Tile_Pick:	DC.W	TILE_PICK_REGION_ID,208,112,027,016
			DC.L	0
			DC.W	-1
 ifd dugbarry
Tile_Tile_Region:
	rts
;	cmp.w	#MAP_LEFT_REGION_ID,_Select_Button
;	bne.s	.tile_edit_end

	tst.b	d0
	beq.s	.tile_edit_execute
	bmi	.tile_edit_shutdown

.tile_edit_setup		; d0 > 0

	push	d0-d3
	move.l	_Ed_Window,a0
	lea	_Sprite_Pointer_Cross,a1
	jsr	_SetPointer
	jsr	Display_Text_XY_ShellT
	jsr	Display_Text_Tile_X
	jsr	Display_Text_Tile_Y
	pop	d0-d3
	move.b	#0,_Region_Status

.tile_edit_execute	; d0 = 0
	move.l	_Ed_RastPort,_Global_RastPort

	exg.l	d0,d2
	exg.l	d1,d3
	ext.l	d0
	ext.l	d1

;	divu	_Magnify_SizeX,d0
;	divu	_Magnify_SizeY,d1
;	add.w	_Tile_Left,d0
;	add.w	_Magnify_CX,d0
;	add.w	_Tile_Top,d1
;	add.w	_Magnify_CY,d1
	move.w	d0,_Tile_Edit_X
	move.w	d1,_Tile_Edit_Y

;	jsr	Calculate_Tile_Mouse_Coordinates
	cmp.w	_Tile_Last_X-PC(gl),d0
	bne.s	.edit_xy_changed
	cmp.w	_Tile_Last_Y-PC(gl),d1
	beq	.edit_xy_end
.edit_xy_changed

	jsr	Check_Tile_Select_Button
	jsr	Check_Tile_Menu_Button

;


;;- restore tile under last tile

	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure


;;- show tile on display

	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure


	or.w	#CHGF_XCOORD!CHGF_YCOORD,_Something_Changed-PC(gl)	; signal x & y coord changed

	move.w	_Tile_Edit_X,_Tile_Last_X
	move.w	_Tile_Edit_Y,_Tile_Last_Y

	jsr	_Save_Prev_Coords

.edit_xy_end
	bra.s	.tile_edit_end
.tile_edit_shutdown	; d0 < 0
	nop

	move.w	#TOOL_LEAVE_FLAG,d7
	jsr	Execute_Tool_Procedure

; clear the x & y coordinates from the work screen

	move.l	_Wk_RastPort,_Global_RastPort
	moveq.l	#0,d0
	jsr	_SetAPen
	coord.w	76,3,44,7
	jsr	_RectFill

	andi.w	#~(CHGF_XCOORD!CHGF_YCOORD),_Something_Changed-PC(gl)
	move.w	#-1,_Tile_Last_X-PC(gl)

	move.l	_Ed_Window-PC(gl),a0
	jsr	_ClearPointer

.tile_edit_end
	rts
 endc

Tile_Edit_Region:
;	cmp.w	#MAP_LEFT_REGION_ID,_Select_Button
;	bne.s	.tile_edit_end

	tst.b	d0
	beq.s	.tile_edit_execute
	bmi	.tile_edit_shutdown

.tile_edit_setup		; d0 > 0

	push	d0-d3
	move.l	_Ed_Window,a0
	lea	_Sprite_Pointer_Cross,a1
	jsr	_SetPointer

	or.w	#CHGF_XCOORD!CHGF_YCOORD!CHGF_SHELL_XY,_Something_Changed-PC(gl)	; signal x & y coord changed


;	jsr	Display_Text_XY_ShellT
;	jsr	Display_Text_Tile_X
;	jsr	Display_Text_Tile_Y

	pop	d0-d3
	move.b	#0,_Region_Status

.tile_edit_execute	; d0 = 0
	move.l	_Ed_RastPort,_Global_RastPort
	clr.l	d0
	move.w	_Tile_Left,d0
	move.l	d0,LL1
	clr.l	d0
	move.w	_Magnify_CX,d0
	move.l	d0,LL2
	
	exg.l	d0,d2
	exg.l	d1,d3
	ext.l	d0
	ext.l	d1
	jsr	Calculate_Tile_Mouse_Coordinates
	cmp.w	_Tile_Last_X,d0
	bne.s	.edit_xy_changed
	cmp.w	_Tile_Last_Y,d1
	beq	.edit_xy_end
.edit_xy_changed

	push	d0-d1
	jsr	Check_Tile_Select_Button
	jsr	Check_Tile_Menu_Button
	pop	d0-d1
;


;;- restore tile under last tile

	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure


;;- show tile on display

	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure


	or.w	#CHGF_XCOORD!CHGF_YCOORD,_Something_Changed-PC(gl)	; signal x & y coord changed

	move.w	_Tile_Edit_X,_Tile_Last_X
	move.w	_Tile_Edit_Y,_Tile_Last_Y

	jsr	_Save_Prev_Coords

.edit_xy_end
	bra.s	.tile_edit_end
.tile_edit_shutdown	; d0 < 0
	nop

	move.w	#TOOL_LEAVE_FLAG,d7
	jsr	Execute_Tool_Procedure

; clear the x & y coordinates from the work screen

;	move.l	_Wk_RastPort,_Global_RastPort
;	moveq.l	#0,d0
;	jsr	_SetAPen
;	coord.w	76,3,44,7
;	jsr	_RectFill

	andi.w	#~(CHGF_XCOORD!CHGF_YCOORD),_Something_Changed-PC(gl)
	move.w	#-1,_Tile_Last_X

	move.l	_Ed_Window,a0
	jsr	_ClearPointer

.tile_edit_end
	rts

Display_Tile_Object:	; d0 - x, d1 - y
;	move.w	_Tile_Edit_X,d0
;	move.w	_Tile_Edit_Y,d1
Display_Tile_Object_1:
	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d1
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pop	d0-d1
	jsr	Draw_Magnified_Pixel
	rts

Restore_Tile_Object:
	move.w	_Tile_Last_X,d0
	move.w	_Tile_Last_Y,d1
Restore_Tile_Object_1:	; d0 - x, d1 - y
	tst.w	d0
	bmi.s	.no_restore
	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d1
	lea	Region_Tile_Tile,a0
	add.w	rg_LeftEdge(a0),d0
	add.w	rg_TopEdge(a0),d1
	jsr	_ReadPixel
	jsr	_SetAPen
	pop	d0-d1
	jsr	Draw_Magnified_Pixel
.no_restore
	rts


Write_Tile_Object:	; d0 - x, d1 - y
	move.l	_Ed_RastPort,_Global_RastPort
	push	d0-d1
	move.w	_Colour_Edit,d0
	jsr	_SetAPen
	pull	d0-d1
	lea	Region_Tile_Tile,a0
	add.w	rg_LeftEdge(a0),d0
	add.w	rg_TopEdge(a0),d1
	jsr	_WritePixel
	pop	d0-d1
	jsr	Draw_Magnified_Pixel
	rts

Calculate_Tile_Mouse_Coordinates:
	divu	_Magnify_SizeX,d0
	divu	_Magnify_SizeY,d1
;	add.w	_Tile_Left,d0
	add.w	_Magnify_CX,d0
;	add.w	_Tile_Top,d1
	add.w	_Magnify_CY,d1
	move.w	d0,_Tile_Edit_X
	move.w	d1,_Tile_Edit_Y
	rts

Draw_Magnified_Pixel:	; d0 - tile x, d1 - tile y
	move.l	_Ed_RastPort,_Global_RastPort
	sub.w	_Magnify_CX,d0
	sub.w	_Magnify_CY,d1
	move.w	_Magnify_SizeX,d2
	move.w	_Magnify_SizeY,d3
	mulu	d2,d0
	mulu	d3,d1
	lea	Region_Tile_Edit,a0
	add.w	rg_LeftEdge(a0),d0
	add.w	rg_TopEdge(a0),d1
	add.w	d0,d2
	add.w	d1,d3
	subq.w	#1,d2
	subq.w	#1,d3
	jsr	_RectFill
	rts



Tile_Select_Region:

	tst.b	d0
	beq.s	.tile_select_execute
	bmi	.tile_select_shutdown
.tile_select_setup		; d0 > 0

;	move.l	_Ed_Window,a0
;	lea	_Sprite_Pointer_Sleep,a1
;	jsr	_SetPointer
	move.b	#0,_Region_Status

.tile_select_execute	; d0 = 0
	cmp.w	#TILE_SELECT_REGION_ID,_Select_Button
	bne	.tile_select_end

	move.w	#TILE_SELECT_REGION_ID,_Wait_On_Signal

	lea	Region_Tile_Select,a0
	move.w	rg_Width(a0),d0
	ext.l	d0
	move.w	_Tile_Width,d1
	ext.l	d2
	divu	d1,d2			; get x coord
	divu	d1,d0
	divu	_Tile_Height,d3		; get y coord
	mulu	d0,d3
	add.w	d3,d2
	move.w	_Tile_Top,d3
	mulu	d3,d0
	add.w	d0,d2
	move.w	_Tile_Amount,d0
	subq.w	#1,d0
	ext.l	d2
	ext.l	d0
	move.w	d2,d1
	call	_Find_Greater
	move.w	d1,d0

;	move.w	d1,_Tile_Edit
	
;	exg.l	d0,d2
;	exg.l	d1,d3
;	andi.l	#$FFFF,d0
;	andi.l	#$FFFF,d1
;;	move.l	d0,LL1
;;	move.l	d1,LL2
;	divu	_Tile_Width,d0
;	divu	_Tile_Height,d1
;	ext.l	d0
;	ext.l	d1
;	move.l	d0,LL3
;	move.l	d1,LL4
;	lea	Region_Tile_Select,a1
;	move.w	rg_Width(a1),d2
;	ext.l	d2
;	divu	_Tile_Width,d2
;	ext.l	d2
;	mulu	d2,d1
;	add.l	d1,d0
;
;	move.w	_Tile_Amount,d1
;	subq.w	#1,d1
;	cmp.w	d1,d0
;	bls.s	.tile_in_range
;	move.w	d1,d0
;.tile_in_range	

	cmp.w	_Tile_Edit,d0
	beq.s	.same_tile_in_use

	jsr	_Save_OldTile_Load_NewTile

	or.w	#CHGF_TILE,_Something_Changed-PC(gl)

.same_tile_in_use

	bra.s	.tile_select_end
.tile_select_shutdown	; d0 < 0
	nop

;	move.l	_Ed_Window,a0
;	jsr	_ClearPointer

.tile_select_end
	rts

_Save_OldTile_Load_NewTile:	; d0 - new tile

;								 ;
;;			Save off old altered tile		;;
;								 ;
	push	d0
	move.w	_Tile_Edit,d0
	jsr	_Copy_Tile_Use_To_Original
	pop	d0
;								 ;
;;			Load up new selected			;;
;								 ;
	move.w	d0,_Tile_Edit	
	move.w	_Tile_Edit,d0
	jsr	_Copy_Tile_Original_To_Use
	jsr	_Copy_Tile_Use_To_Screen
	jsr	_Copy_Tile_Use_To_Backup
	jsr	_Scale_BitMap

	rts



Tile_Colour_Region:
;	cmp.w	#TILE_COLOUR_REGION_ID,_Select_Button
;	bne.s	.tile_colour_end

	tst.b	d0
	beq.s	.tile_colour_execute
	bmi	.tile_colour_shutdown

.tile_colour_setup		; d0 > 0

;	move.l	_Ed_Window,a0
;	lea	_Sprite_Pointer_Q,a1
;	jsr	_SetPointer
	move.b	#0,_Region_Status

.tile_colour_execute	; d0 = 0
	move.l	_Ed_RastPort,_Global_RastPort
	ext.l	d2
	ext.l	d3
	jsr	Calculate_Colour_Box_Offset
	clr.l	d4
	move.b	cbt_ColWidth(a0),d4
	divu	d4,d2
	ext.l	d2
;	move.l	d2,abc

	clr.l	d5
	move.b	cbt_ColHeight(a0),d5
	divu	d5,d3
	ext.l	d3
;	move.l	d3,def
	clr.l	d5
	move.b	cbt_NumHeight(a0),d5
	mulu	d5,d2
	add.l	d3,d2

	cmp.w	#TILE_COLOUR_REGION_ID,_Select_Button
	bne.s	.not_select_button

	move.w	#TILE_COLOUR_REGION_ID,_Wait_On_Signal

	cmp.w	_Colour_Edit_1,d2
	beq.s	.tile_colour_execute_end
	move.w	d2,_Colour_Edit_1

	cmp.w	_Colour_Last_1,d2
	beq.s	.select_button_end
;	moveq.l	#0,d0
;	jsr	_SetAPen
;	move.w	_Colour_Last_1,d0
;	jsr	Highlight_Colour		; clear highlight
;
;	move.w	#1,d0
;	jsr	_SetAPen
;	move.w	_Colour_Edit_1,d0
;	move.w	d0,_Colour_Last_1
;	jsr	Highlight_Colour		; set highlight
	jsr	_Change_Highlight_Colour
.select_button_end
	bra.s	.display_colours
.not_select_button
	cmp.w	#TILE_COLOUR_REGION_ID,_Menu_Button
	bne.s	.not_menu_button
	move.w	d2,_Colour_Edit_0
.display_colours
	jsr	_Display_Edit_Colours
	jsr	_Change_RGB_Prop_Gadgets
.not_menu_button

;	move.w	_Colour_Edit_1,d0
;	ext.l	d0
;	move.l	d0,abc
;	move.w	_Colour_Edit_0,d0
;	ext.l	d0
;	move.l	d0,def

.tile_colour_execute_end
	bra.s	.tile_colour_end
.tile_colour_shutdown	; d0 < 0
	nop

;	move.l	_Ed_Window,a0
;	jsr	_ClearPointer

.tile_colour_end
	rts


_Find_Brightest_Pen:
	jsr	_Calculate_Palette_Node
	move.w	palette_Depth(a0),d0
	jsr	_Power_Of_2
	move.l	palette_Location(a0),a1
	moveq.l	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4

	bra.s	.next_colour_pass
.next_colour
	move.w	(a1)+,d4		; get colour
	cmp.w	d3,d1			; test if colour is > than last stored colour
	bhi.s	.col_darker
	move.w	d3,d1			; store biggest colour so far
	move.w	d2,d3			; mark pen #
.col_darker
	addq.l	#1,d2			; pen num
.next_colour_pass
	dbra	d0,.next_colour
	move.w	d3,_Brightest_Pen
	rts


_Change_Highlight_Colour:
	moveq.l	#0,d0
	jsr	_SetAPen
	move.w	_Colour_Last_1,d0
	jsr	Highlight_Colour		; clear highlight

	move.w	_Brightest_Pen,d0
	jsr	_SetAPen
	move.w	_Colour_Edit_1,d0
	move.w	d0,_Colour_Last_1
	jsr	Highlight_Colour		; set highlight
	rts

_Display_Edit_Colours:
	move.l	_Ed_RastPort,_Global_RastPort
	move.w	_Colour_Edit_0,d0
	jsr	_SetAPen
	lea	Region_Tile_Pick,a0
	move.w	rg_LeftEdge(a0),d0
	move.w	rg_TopEdge(a0),d1
	move.w	d0,d2
	move.w	d1,d3
	add.w	rg_Width(a0),d2
	add.w	rg_Height(a0),d3
	subq.w	#1,d2
	subq.w	#1,d3
	push	d0-d3
	jsr	_RectFill
	move.w	_Colour_Edit_1,d0
	jsr	_SetAPen
	pop	d0-d3
	addq.w	#6,d0
	addq.w	#4,d1
	subq.w	#6,d2
	subq.w	#4,d3
	jsr	_RectFill
	
	rts

Highlight_Colour:	; d0 - colour
	ext.l	d0
	jsr	Calc_Colour_Coords
	add.w	d0,d2
	add.w	d1,d3
	subq.w	#1,d0
	subq.w	#1,d1
	subq.w	#1,d2
	subq.w	#1,d3
;	jsr	_Draw_Raised_Box
	jsr	_Rect
	rts

;DeHighlight_Colour:	; d0 - colour
;	jsr	Calc_Colour_Coords
;	add.w	d0,d2
;	add.w	d1,d3
;	subq.w	#1,d0
;	subq.w	#1,d1
;	subq.w	#1,d2
;	subq.w	#1,d3
;	jsr	_Rect
;	rts

;Restore_Colour:		; d0 - colour
;	push	d0
;	jsr	_SetAPen
;	pop	d0
;	jsr	Calc_Colour_Coords
;	push	d0-d3
;	add.w	d0,d2
;	add.w	d1,d3
;	subq.w	#1,d2
;	subq.w	#1,d3
;	jsr	_Rect
;	push	d0-d3
;
;	rts

Calc_Colour_Coords:	; d0 - colour
	jsr	Calculate_Colour_Box_Offset
	clr.l	d2
	move.b	cbt_NumHeight(a0),d2
	divu	d2,d0	; x pos
	swap	d0
	move.w	d0,d1
	swap	d0
	ext.l	d0	; x
	ext.l	d1	; y
	clr.l	d2
	move.b	cbt_ColWidth(a0),d2
	mulu	d2,d0
	clr.l	d3
	move.b	cbt_ColHeight(a0),d3
	mulu	d3,d1
	lea	Region_Tile_Colour,a1
	add.w	rg_LeftEdge(a1),d0
	add.w	rg_TopEdge(a1),d1
	rts


Calculate_Colour_Box_Offset:
	lea	_Colour_Box_Table,a0
	push	d0
	move.w	_Tile_Depth,d0
	subq.w	#1,d0
	mulu	#cbt_SIZEOF,d0
	add.l	d0,a0
	pop	d0
	rts

;*******************
;**  Edit RawKey  **
;*******************

_Handle_Tile_Edit_RawKey:
	lea	_Tile_Edit_RawKey_List,a0
	jsr	_Execute_VanillaKey_List
	rts

_Tile_Edit_RawKey_List:
	SetVanilla	$4c,QUAL_IGNORE,_Tile_Edit_Move_Magnify_Up
	SetVanilla	$4d,QUAL_IGNORE,_Tile_Edit_Move_Magnify_Down
	SetVanilla	$4e,QUAL_IGNORE,_Tile_Edit_Move_Magnify_Right
	SetVanilla	$4f,QUAL_IGNORE,_Tile_Edit_Move_Magnify_Left
	DC.W	-1

_Tile_Edit_Move_Magnify_Up:
	moveq.l	#0,d0
	lea	Region_Tile_Edit,a1
;	move.w	rg_Height(a1),d0
;	divu	_Magnify_SizeX,d0	; width of current edit window
	add.w	_Magnify_CY,d0
	
	cmp.w	#0,d0
	bls.s	.no_move
	move.w	#-1,_Tile_Last_X
	subq.w	#1,_Magnify_CY
	jsr	_Scale_BitMap
.no_move
;	move.w	#$F00,$DFF180
	rts

_Tile_Edit_Move_Magnify_Down:
	moveq.l	#0,d0
	lea	Region_Tile_Edit,a1
	move.w	rg_Height(a1),d0
	divu	_Magnify_SizeY,d0	; width of current edit window
	add.w	_Magnify_CY,d0
	
	cmp.w	_Tile_Height,d0
	bhs.s	.no_move
	move.w	#-1,_Tile_Last_X
	addq.w	#1,_Magnify_CY
	jsr	_Scale_BitMap
.no_move
;	move.w	#$0F0,$DFF180
	rts

dbg25:
_Tile_Edit_Move_Magnify_Right:

	moveq.l	#0,d0
	lea	Region_Tile_Edit,a1
	move.w	rg_Width(a1),d0
	divu	_Magnify_SizeX,d0	; width of current edit window
	add.w	_Magnify_CX,d0
	
	cmp.w	_Tile_Width,d0
	bhs.s	.no_move
	move.w	#-1,_Tile_Last_X
	addq.w	#1,_Magnify_CX
	jsr	_Scale_BitMap
.no_move
	
;	move.w	#$00F,$DFF180
	rts

_Tile_Edit_Move_Magnify_Left:
	moveq.l	#0,d0
	lea	Region_Tile_Edit,a1
;	move.w	rg_Width(a1),d0
;	divu	_Magnify_SizeX,d0	; width of current edit window
	add.w	_Magnify_CX,d0
	
	cmp.w	#0,d0
	bls.s	.no_move
	move.w	#-1,_Tile_Last_X
	subq.w	#1,_Magnify_CX
	jsr	_Scale_BitMap
.no_move
;	move.w	#$F0F,$DFF180
	rts

;***********************
;**  Edit VanillaKey  **
;***********************
dbgtv0:
_Handle_Tile_Edit_VanillaKey:
	lea	_Tile_Edit_VanillaKey_List,a0
	jsr	_Execute_VanillaKey_List
	rts

_Handle_Tile_Edit_IntuiTicks:
;	move.w	#$333,$DFF180
	jsr	_Handle_IntuiTicks_Text
	jsr	_Handle_Tile_Edit_MouseMove
	jsr	_Show_Debug_Line_Info
	rts



 STRUCTURE	COLOUR_BOX_TABLE,0
	UBYTE	cbt_Width
	UBYTE	cbt_Height
	UBYTE	cbt_ColWidth
	UBYTE	cbt_ColHeight
	UBYTE	cbt_NumWidth
	UBYTE	cbt_NumHeight
	LABEL	cbt_SIZEOF
	


_Tile_Work_Gadget_List:
;;		SetGadget	000,02,13,11,BUTTON_ID_CLOSE,IMAGE_CLOSE
;		SetGadget	610,02,26,11,BUTTON_ID_BEHIND,IMAGE_BEHIND
;		SetGadget	610,14,26,11,BUTTON_ID_ICONIZE,IMAGE_ICONIZE
;;;;;
;
;		SetGadget	008+(00*34),05+(0*17),32,16,BUTTON_ID_MAP,IMAGE_MAP
;		SetGadget	008+(01*34),05+(0*17),32,16,BUTTON_ID_ANIM,IMAGE_ANIM
;		SetGadget	008+(02*34),05+(0*17),32,16,BUTTON_ID_COPPER,IMAGE_COPPER
;		SetGadget	008+(03*34),05+(0*17),32,16,BUTTON_ID_FILE,IMAGE_FILE
;		SetGadget	008+(00*34),05+(1*17),32,16,BUTTON_ID_PALETTE,IMAGE_PALETTE
;		SetGadget	008+(01*34),05+(1*17),32,16,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	008+(02*34),05+(1*17),32,16,BUTTON_ID_CONFIGURATION,IMAGE_CONFIGURATION
;		SetGadget	008+(03*34),05+(1*17),32,16,BUTTON_ID_PREFERENCES,IMAGE_PREFERENCES
;
;		SetGadget	160+(00*30),25+(0*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	160+(01*30),25+(0*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	160+(02*30),25+(0*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;
;		SetGadget	176,014,16,09,BUTTON_ID_TILEPREV,IMAGE_NEWARROWLEFT
;		SetGadget	232,014,16,09,BUTTON_ID_TILENEXT,IMAGE_NEWARROWRIGHT
;
;		SetGadget	194,013,036,11,STRING_ID_CURRTILE,GAD_STRING
;
;		SetGadget	008,041,16,09,BUTTON_ID_TILESETPREV,IMAGE_NEWARROWLEFT
;		SetGadget	026,041,16,09,BUTTON_ID_TILESETNEXT,IMAGE_NEWARROWRIGHT
;
;		SetGadget	044,040,204,11,STRING_ID_TILENAME,GAD_STRING
;
;
;
;
;		SetGadget	260+(00*30),05+(0*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	260+(00*30),05+(1*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	260+(00*30),05+(2*15),28,14,BUTTON_ID_MASK,IMAGE_MASK
;		SetGadget	260+(01*30),05+(0*15),28,14,BUTTON_ID_CLEAR,IMAGE_CLEAR
;		SetGadget	260+(01*30),05+(1*15),28,14,BUTTON_ID_UNDO,IMAGE_UNDO
;		SetGadget	260+(01*30),05+(2*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;
;
;		SetGadget	324+(00*30),05+(0*15),28,14,BUTTON_ID_SCRIBBLE,IMAGE_SCRIBBLE
;		SetGadget	324+(01*30),05+(0*15),28,14,BUTTON_ID_DRAW,IMAGE_DRAW
;		SetGadget	324+(02*30),05+(0*15),28,14,BUTTON_ID_LINE,IMAGE_LINE
;		SetGadget	324+(03*30),05+(0*15),28,14,BUTTON_ID_BEND,IMAGE_BEND
;		SetGadget	324+(04*30),05+(0*15),28,14,BUTTON_ID_POLY,IMAGE_POLY
;		SetGadget	324+(05*30),05+(0*15),28,14,BUTTON_ID_RECTANGLE,IMAGE_RECTANGLE
;		SetGadget	324+(06*30),05+(0*15),28,14,BUTTON_ID_CIRCLE,IMAGE_CIRCLE
;		SetGadget	324+(07*30),05+(0*15),28,14,BUTTON_ID_FILL,IMAGE_FILL
;		SetGadget	324+(08*30),05+(0*15),28,14,BUTTON_ID_CUT,IMAGE_CUT
;
;		SetGadget	324+(00*30),05+(1*15),28,14,BUTTON_ID_FLIPX,IMAGE_FLIPX
;		SetGadget	324+(01*30),05+(1*15),28,14,BUTTON_ID_FLIPY,IMAGE_FLIPY
;		SetGadget	324+(02*30),05+(1*15),28,14,BUTTON_ID_ROTATE,IMAGE_ROTATE
;		SetGadget	324+(03*30),05+(1*15),28,14,BUTTON_ID_COPY,IMAGE_COPY
;		SetGadget	324+(04*30),05+(1*15),28,14,BUTTON_ID_PASTE,IMAGE_PASTE
;
;		SetGadget	324+(00*30),05+(2*15),28,14,BUTTON_ID_SWAP,IMAGE_SWAP
;		SetGadget	324+(01*30),05+(2*15),28,14,BUTTON_ID_MERGE,IMAGE_MERGE
;		SetGadget	324+(02*30),05+(2*15),28,14,BUTTON_ID_DUPLICATE,IMAGE_DUPLICATE
;		SetGadget	324+(03*30),05+(2*15),28,14,BUTTON_ID_ERASE,IMAGE_ERASE
;
;
;		SetGadget	538+16,022+00,18,07,BUTTON_ID_SHIFTU,IMAGE_POINTUP
;		SetGadget	538+00,022+08,14,09,BUTTON_ID_SHIFTL,IMAGE_POINTLEFT
;		SetGadget	538+16,022+18,18,07,BUTTON_ID_SHIFTD,IMAGE_POINTDOWN
;		SetGadget	538+36,022+08,14,09,BUTTON_ID_SHIFTR,IMAGE_POINTRIGHT
;		SetGadget	538+16,022+08,18,09,BUTTON_ID_NULL,IMAGE_HASH
;
;;		SetGadget	004,002,7,7,BUTTON_ID_TILEPREV,IMAGE_DECREASE
;;		SetGadget	011,002,7,7,BUTTON_ID_TILENEXT,IMAGE_INCREASE
;
;;		SetGadget	004,044,7,7,BUTTON_ID_TILEPREV,IMAGE_DECREASE
;;		SetGadget	011,044,7,7,BUTTON_ID_TILENEXT,IMAGE_INCREASE
;
		DC.L		-1

_Tile_Work_Define_Gadget_List:
;		SetGadget	610,002,026,011,BUTTON_ID_BEHIND,IMAGE_BEHIND
;		SetGadget	610,014,026,011,BUTTON_ID_ICONIZE,IMAGE_ICONIZE
;
;		SetGadget	048+008,003,018,009,BUTTON_ID_DEFINE1TICK,TEXT_RTILES|GAD_TICKON
;
;		SetGadget	048+009,026,014,009,BUTTON_ID_DEFINE1DEC,IMAGE_POINTLEFT
;		SetGadget	048+063,026,014,009,BUTTON_ID_DEFINE1INC,IMAGE_POINTRIGHT
;		SetGadget	048+025,025,036,011,STRING_ID_DEFINE1STR,GAD_STRING
;
;		SetGadget	048+081,026,014,009,BUTTON_ID_DEFINE2DEC,IMAGE_POINTLEFT
;		SetGadget	048+135,026,014,009,BUTTON_ID_DEFINE2INC,IMAGE_POINTRIGHT
;		SetGadget	048+097,025,036,011,STRING_ID_DEFINE2STR,GAD_STRING
;
;		SetGadget	048+153,026,014,009,BUTTON_ID_DEFINE3DEC,IMAGE_POINTLEFT
;		SetGadget	048+199,026,014,009,BUTTON_ID_DEFINE3INC,IMAGE_POINTRIGHT
;		SetGadget	048+169,025,028,011,STRING_ID_DEFINE3STR,GAD_STRING
;
;		SetGadget	048+217,026,014,009,BUTTON_ID_DEFINE4DEC,IMAGE_POINTLEFT
;		SetGadget	048+279,026,014,009,BUTTON_ID_DEFINE4INC,IMAGE_POINTRIGHT
;		SetGadget	048+233,025,044,011,STRING_ID_DEFINE4STR,GAD_STRING
;
;		SetGadget	048+301,026,018,009,BUTTON_ID_DEFINE1MX,GAD_MXOFF
;		SetGadget	048+322,026,018,009,BUTTON_ID_DEFINE2MX,GAD_MXOFF
;		SetGadget	048+343,026,018,009,BUTTON_ID_DEFINE3MX,GAD_MXOFF
;		SetGadget	048+364,026,018,009,BUTTON_ID_DEFINE4MX,GAD_MXOFF
;
;		SetGadget	048+391,008,018,009,BUTTON_ID_DEFINE2TICK,TEXT_MASK|GAD_TICKOFF
;		SetGadget	048+391,018,018,009,BUTTON_ID_DEFINE3TICK,TEXT_NOCOLS|GAD_TICKOFF
;		SetGadget	048+391,028,018,009,BUTTON_ID_DEFINE4TICK,TEXT_16BIT|GAD_TICKOFF
;
;		SetGadget	048+466,008,018,009,BUTTON_ID_DEFINE5TICK,TEXT_SPRITE|GAD_TICKOFF
;		SetGadget	048+466,018,018,009,BUTTON_ID_DEFINE6TICK,TEXT_24BITCOL|GAD_TICKOFF
;		SetGadget	048+466,028,018,009,BUTTON_ID_DEFINE7TICK,GAD_TICKOFF
;
;		SetGadget	048+008,041,016,009,BUTTON_ID_DEFINEPREV,IMAGE_NEWARROWLEFT
;		SetGadget	048+026,041,016,009,BUTTON_ID_DEFINENEXT,IMAGE_NEWARROWRIGHT
;
;		SetGadget	048+044,040,204,011,STRING_ID_TILENAME,GAD_STRING
;
;
;
;		SetGadget	048+358,040,64,11,BUTTON_ID_DEFINEOK,GAD_TEXT|TEXT_OK
;;		SetGadget	048+424,040,64,11,BUTTON_ID_DEFINEAPPLY,GAD_TEXT|TEXT_APPLY
;		SetGadget	048+490,040,64,11,BUTTON_ID_DEFINECANCEL,GAD_TEXT|TEXT_CANCEL
;
		DC.L		-1

_Tile_Work_Palette_Gadget_List:
;		SetGadget	610,02,26,11,BUTTON_ID_BEHIND,IMAGE_BEHIND
;		SetGadget	610,14,26,11,BUTTON_ID_ICONIZE,IMAGE_ICONIZE
;
;		SetGadget	048+253,005,31,31,BUTTON_ID_PALETTERGBDISP,GAD_TEXT|TEXT_NULL
;		SetGadget	048+008,005,20,31,BUTTON_ID_PALETTERGBHSV,GAD_TEXT|TEXT_NULL
;
;		SetGadget	048+030,006,221,9,SLIDER_ID_PALETTERED,GAD_SETON!GAD_PROP
;		SetGadget	048+030,016,221,9,SLIDER_ID_PALETTEGREEN,GAD_SETON!GAD_PROP
;		SetGadget	048+030,026,221,9,SLIDER_ID_PALETTEBLUE,GAD_SETON!GAD_PROP
;
;
;		SetGadget	048+358,015,064,011,BUTTON_ID_PALETTESPREAD,GAD_TEXT|TEXT_SPREAD
;		SetGadget	048+358,027,064,011,BUTTON_ID_PALETTEPICK,GAD_TEXT|TEXT_PICK
;		SetGadget	048+358,040,064,011,BUTTON_ID_PALETTEOK,GAD_TEXT|TEXT_OK
;
;		SetGadget	048+424,015,064,011,BUTTON_ID_PALETTECOPY,GAD_TEXT|TEXT_COPY
;		SetGadget	048+424,027,064,011,BUTTON_ID_PALETTEEXCHG,GAD_TEXT|TEXT_EXG
;
;		SetGadget	048+490,015,064,011,BUTTON_ID_PALETTEREVERT,GAD_TEXT|TEXT_REVERT
;		SetGadget	048+490,027,064,011,BUTTON_ID_PALETTEUNDO,GAD_TEXT|TEXT_UNDO
;		SetGadget	048+490,040,064,011,BUTTON_ID_PALETTECANCEL,GAD_TEXT|TEXT_CANCEL
;
;		SetGadget	048+008,041,016,009,BUTTON_ID_PALETTESETPREV,IMAGE_NEWARROWLEFT
;		SetGadget	048+026,041,016,009,BUTTON_ID_PALETTESETNEXT,IMAGE_NEWARROWRIGHT
;
;		SetGadget	048+044,040,204,011,STRING_ID_PALETTENAME,GAD_STRING
;
		DC.L		-1


 ENDC


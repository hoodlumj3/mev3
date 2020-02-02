 IFND	MEV3_TEST_S
MEV3_TEST_S SET 1
MEV3_MAIN_S SET 1

*
*
* $VER:mev3.0.s 39.01  © (28/Mar/94) M.J.Edwards
* 
*

	Section Code,Code_C

	include	"mev3_macros.s"

_main:
	push	d0-d7/a0-a6
	move.l	sp,_Initial_SP

	jsr	Open_Libraries

	lea	Work_Image_Array,a0
	jsr	Create_All_Work_Images

	move.w	#-1,Last_Prog_Section
	move.w	#-1,Prev_Prog_Section
	move.w	#0,Run_Prog_Section

_main_running_loop:
	moveq.l	#0,d0
	move.w	Run_Prog_Section,d0	; running section
	move.w	d0,Last_Prog_Section
	tst.w	d0
	bmi.s	_main_shut_down

_main_setup:
		;	********************************
		;	 setup section & screen & stuff
		;	********************************


	lea	Prog_Section_Setup,a0
	jsr	Do_Designated_Execution
_main_run:
		;		  *************
		;		   run section
		;		  *************

	lea	Prog_Section_Run,a0
	jsr	Do_Designated_Execution
_main_shutown:
		;		******************
		;		 shutdown section
		;		******************
	lea	Prog_Section_Shutdown,a0
	jsr	Do_Designated_Execution

	tst.w	Last_Prog_Section
	bmi.s	.dont_save_prev
	move.w	d0,Prev_Prog_Section	
.dont_save_prev
	btst	#7,$BFE001
	beq.s	_main_shut_down
	bra	_main_running_loop

_main_shut_down:
	jsr	Dispose_All_Work_Images

	jsr	Close_Libraries	

	move.l	_Initial_SP,sp
	pop	d0-d7/a0-a6

	rts

Do_Designated_Execution:
	push	d0-d7/a0-a6
	mulu	#4,d0
	move.l	(a0,d0.l),d0
	tst.l	d0
	beq.s	.1
	move.l	d0,a0
	jsr	(a0)
.1
	pop	d0-d7/a0-a6
	rts

Run_Prog_Section:	DC.W	0
Last_Prog_Section:	DC.W	0
Prev_Prog_Section:	DC.W	0

Prog_Section_Setup:
			DC.L	Setup_Map_Ed			; test
Prog_Section_Run:
			DC.L	Handle_Map_Ed_Messages		; test
Prog_Section_Shutdown:
			DC.L	Shutdown_Map_Ed			; test

;****************************************************
;               Library Opens & Closes
;****************************************************

Open_Libraries:
	lea	Close_Libraries,a0
	move.l	a0,_Routine_To_Shutdown_If_Error+4

	move.l	$4.w,_SysBase

	moveq.l	#0,d0			; version ?? dos
	lea	_DosName,a1
	jsr	Open_Library
	move.l	d0,_DosBase

	moveq.l	#0,d0			; version ?? intuition
	lea	_IntuitionName,a1
	jsr	Open_Library
	move.l	d0,_IntuitionBase

	moveq.l	#0,d0			; version ?? graphics
	lea	_GraphicsName,a1
	jsr	Open_Library
	move.l	d0,_GraphicsBase

	moveq.l	#0,d0			; version ?? gadtools
	lea	_GadToolsName,a1
	jsr	Open_Library
	move.l	d0,_GadToolsBase

	moveq.l	#0,d0			; version ?? diskfont
	lea	_DiskFontName,a1
	jsr	Open_Library
	move.l	d0,_DiskFontBase

	lea	_DPaint50,a0
	jsr	Open_DiskFont
	move.l	d0,_DPaintFont
	rts

Close_Libraries:
	move.l	_DPaintFont,a1
	jsr	Close_Font
	
	move.l	_DiskFontBase,a1
	jsr	Close_Library

	move.l	_GadToolsBase,a1
	jsr	Close_Library

	move.l	_GraphicsBase,a1
	jsr	Close_Library

	move.l	_IntuitionBase,a1
	jsr	Close_Library

	move.l	_DosBase,a1
	jsr	Close_Library

	move.l	#0,_Routine_To_Shutdown_If_Error+4

	rts




;****************************************************
;          Map Editor Screen & Util Window
;****************************************************


Display_Text_Format:	; d0 - x, d1 - y, d2 - col, d3 - number, a0 - format string
	push	d0-d3/a0
	move.l	d2,d0
	jsr	_SetAPen
	pop	d0-d3/a0
	push	d0-d1
	push	d3
	push	a0
	pea	_StringBuffer(pc)
	jsr	_SPrintf
	lea	3*4(sp),sp
	pop	d0-d1
	lea	_StringBuffer(pc),a0
	push	d0
	jsr	_StrLen
	move.l	d0,d2
	pop	d0
	jsr	_DisplayText
	
	rts

_StringBuffer:	DS.B	80
 EVEN

Setup_Map_Ed:
	lea	Shutdown_Map_Ed,a0
	jsr	_Set_Exit_Jump

; create work gadgets

	move.l	#_Wk_Gadgets,d0
	lea	Work_Gadget_List,a0
	jsr	Create_Work_Gadgets

; open screen work
	sub.l	a0,a0
	lea	Work_Screen_TagList,a1
	jsr	Open_Screen
	move.l	d0,_Wk_Screen
; open window work
	move.l	_Wk_Screen,Work_Window_Screen+4
	move.l	_Wk_Gadgets,Work_Window_Gadget+4
	sub.l	a0,a0
	lea	Work_Window_TagList,a1
	jsr	Open_Window
	move.l	d0,_Wk_Window
	move.l	d1,_Wk_RastPort
	move.l	d2,_Wk_ViewPort
	move.l	d3,_Wk_UserPort

;	move.l	#0,d0
;	move.l	#50,d1
;	move.l	_Wk_Window,a0
;	move.l	_Wk_Gadgets,a1
;	jsr	_AddGList

	move.l	_Wk_Gadgets,a0
	move.l	_Wk_Window,a1
	jsr	_RefreshGadgets

	move.l	_DPaintFont,a0
	move.l	_Wk_RastPort,a1
	jsr	_SetFont

	move.l	_Wk_RastPort,_Global_RastPort

	move.l	#0,d0
	move.l	#0,d1
	move.l	#319,d2
	move.l	#52,d3
	jsr	_Draw_Raised_Box

	rts

Shutdown_Map_Ed:


	move.l	#50,d0
	move.l	_Wk_Window,a0
	move.l	_Wk_Gadgets,a1
	jsr	_RemoveGList

	move.l	_Wk_Gadgets,a0
	jsr	Remove_Work_Gadgets
;	move.l	#0,_Wk_Gadgets
; close window work
	move.l	_Wk_Window,a0
	jsr	Close_Window
;	move.l	#0,_Wk_Window
; close screen work
	move.l	_Wk_Screen,a0
	jsr	Close_Screen
;	move.l	#0,_Wk_Screen

	jsr	_Clear_Exit_Jump

	rts


Handle_Map_Ed_Messages:
	move.w	#0,_Quit		; exit signal
.wait_for_message
;	move.l	_My_Window,a3
;	move.l	_My_UserPort,a0
;	jsr	_Wait

.get_next_work_message
	move.l	_Wk_UserPort,a0
	jsr	_GetMsg			; get the message
	tst.l	d0
	beq.s	.no_work_message
	jsr	Copy_Intuition_Message
	move.l	d0,a1
	jsr	_ReplyMsg		; reply as quickley as possible
	lea	_Map_Work_Message_List,a0
	jsr	_Execute_Intuition_Message
.no_work_message

	tst.w	_Quit
	bne.s	.handle_end
	btst	#7,$BFE001
	beq.s	.handle_end
	bra	.wait_for_message	
.handle_end
	rts

_Map_Work_Message_List:
;	DC.L	IDCMP_MOUSEMOVE,_Handle_Map_Work_MouseMove
;	DC.L	IDCMP_GADGETUP,_Handle_Map_Work_GadgetUp
	DC.L	-1

_Map_Work_GadgetUp_List:
;	SetGadgetID	BUTTON_ID_TILE,_Map_Work_Goto_Tile
;	SetGadgetID	BUTTON_ID_ANIM,_Map_Work_Goto_Anim
;	SetGadgetID	BUTTON_ID_COPPER,_Map_Work_Goto_Copper
;	SetGadgetID	BUTTON_ID_FILE,_Map_Work_Goto_File

;	SetGadgetID	BUTTON_ID_ZOOM,_Map_Work_Zoom
;	SetGadgetID	BUTTON_ID_SHAPES,_Map_Work_Shapes
	DC.W	-1

;_Handle_Map_Work_GadgetUp:
;	lea	_Map_Work_GadgetUp_List,a0
;	jsr	_Execute_Gadget_List
;	rts



;        *************************************************
;    *********************************************************
;*****************************************************************
;    *********************************************************
;        *************************************************

Work_Gadget_List:
;		SetGadget	000+00+02,02,13,11,BUTTON_ID_CLOSE,IMAGE_CLOSE
		SetGadget	320-26-03,02,13,11,BUTTON_ID_ICONIZE,IMAGE_ICONIZE
		SetGadget	320-13-02,02,13,11,BUTTON_ID_BEHIND,IMAGE_BEHIND

		SetGadget	03+(00*17),10+(0*17),16,16,BUTTON_ID_TILE,IMAGE_TILE
		SetGadget	03+(01*17),10+(0*17),16,16,BUTTON_ID_ANIM,IMAGE_ANIM
		SetGadget	03+(02*17),10+(0*17),16,16,BUTTON_ID_COPPER,IMAGE_COPPER
		SetGadget	03+(03*17),10+(0*17),16,16,BUTTON_ID_FILE,IMAGE_FILE
		SetGadget	03+(00*17),10+(1*17),16,16,BUTTON_ID_PALETTE,IMAGE_PALETTE
		SetGadget	03+(01*17),10+(1*17),16,16,BUTTON_ID_NULL,IMAGE_BLANK
		SetGadget	03+(02*17),10+(1*17),16,16,BUTTON_ID_DEFINES,IMAGE_DEFINES
		SetGadget	03+(03*17),10+(1*17),16,16,BUTTON_ID_PREFERENCES,IMAGE_PREFERENCES

		SetGadget	75+(00*17),10+(0*17),16,16,BUTTON_ID_NULL,IMAGE_BLANK
		SetGadget	75+(00*17),10+(1*17),16,16,BUTTON_ID_NULL,IMAGE_BLANK

		SetGadget	96+(00*17),10+(0*17),16,16,BUTTON_ID_SCRIBBLE,IMAGE_SCRIBBLE
		SetGadget	96+(01*17),10+(0*17),16,16,BUTTON_ID_LINE,IMAGE_LINE
		SetGadget	96+(02*17),10+(0*17),16,16,BUTTON_ID_RECTANGLE,IMAGE_RECTANGLE
		SetGadget	96+(03*17),10+(0*17),16,16,BUTTON_ID_CUT,IMAGE_CUT
;		SetGadget	96+(05*17),10+(0*17),16,16,BUTTON_ID_BRUSH,IMAGE_BRUSH
		SetGadget	96+(00*17),10+(1*17),16,16,BUTTON_ID_SHAPES,IMAGE_SHAPES
		SetGadget	96+(01*17),10+(1*17),16,16,BUTTON_ID_ZOOM,IMAGE_ZOOM

		DC.L		-1


Work_Screen_TagList:	DC.L	SA_Top,203
			DC.L	SA_Width,320
			DC.L	SA_Height,53
			DC.L	SA_Depth,3
			DC.L	SA_DisplayID,LORES_KEY
			DC.L	SA_AutoScroll,TRUE
			DC.L	SA_ShowTitle,FALSE
;			DC.L	SA_Quiet,TRUE
			DC.L	SA_Pens,Minus_1
			DC.L    SA_Colors,Work_Screen_Colours
			DC.L	TAG_DONE

Work_Window_TagList:
Work_Window_Screen:	DC.L	WA_CustomScreen,0
Work_Window_Gadget:	DC.L	WA_Gadgets,0
			DC.L    WA_AutoAdjust,1
			DC.L    WA_IDCMP,IDCMP_MOUSEBUTTONS!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEMOVE!IDCMP_REFRESHWINDOW!IDCMP_GADGETUP
			DC.L    WA_Flags,WFLG_SMART_REFRESH!WFLG_ACTIVATE!WFLG_BACKDROP!WFLG_BORDERLESS!WFLG_REPORTMOUSE
			DC.L	TAG_DONE

Work_Screen_Colours:	; $AAA $000 $FFF $555
		DC.W     0,$AA,$AA,$AA
		DC.W     1,$00,$00,$00
		DC.W     2,$FF,$FF,$FF
		DC.W     3,$55,$55,$55
		DC.W	 4,$00,$66,$99
		DC.W	 5,$00,$44,$66
		DC.W	 6,$00,$33,$44
		DC.W	 7,$00,$88,$00
		DC.W    -1,$00,$00,$00


_Border_R10:		NewBorder	0,0,2,3,_Coords_Border_10_TL,_Border_R11
_Border_R11:		NewBorder	0,0,3,3,_Coords_Border_10_BR,0
_Border_L10:		NewBorder	0,0,3,3,_Coords_Border_10_TL,_Border_L11
_Border_L11:		NewBorder	0,0,2,3,_Coords_Border_10_BR,0

_Coords_Border_10_TL:	DC.W	12,00,00,00,00,10
_Coords_Border_10_BR:	DC.W	01,10,12,10,12,00


_Border_R00:		NewBorder	0,0,2,3,_Coords_Border_00_TL,_Border_R01
_Border_R01:		NewBorder	0,0,3,3,_Coords_Border_00_BR,0
_Border_L00:		NewBorder	0,0,3,3,_Coords_Border_00_TL,_Border_L01
_Border_L01:		NewBorder	0,0,2,3,_Coords_Border_00_BR,0

_Coords_Border_00_TL:	DC.W	15,00, 00,00, 00,15
_Coords_Border_00_BR:	DC.W	01,15, 15,15, 15,00

Work_Image_Dummy:	DC.W	1,1,16,16,3
			DC.L	0
			DC.B	%00000111,%00000111
			DC.L	0

Work_Image_Array:	DS.L	MAX_WORK_IMAGES

;Work_Gadget_Dummy:	DC.L	0
;			DC.W	0,0,0,0
;			DC.W	GFLG_GADGHIMAGE!GFLG_LABELIMAGE,GACT_RELVERIFY!GACT_IMMEDIATE,GTYP_BOOLGADGET
;			DC.L	_Border_R00,_Border_L00,0,0,0
;			DC.W	0
;			DC.L	0

 
	include	"/matts/matts_easystart.s"
	include "/matts/matts_funcs.s"

	INSTALL_Library_Funcs
	INSTALL_Font_Funcs
	INSTALL_DiskFont_Funcs
;	INSTALL_ScreenLock_Funcs
	INSTALL_Screen_Funcs	TagList
	INSTALL_Window_Funcs	TagList
;	INSTALL_Visual_Funcs

;	include	"mev3_file.s"
	include	"mev3_gadget.s"
;	include	"mev3_none.s"
	include	"mev3_utility_B.s"


_ActivateWindow:
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOActivateWindow(a6)
	pop	a6
	rts

_SysBase:		DC.L	0
_DosBase:		DC.L	0
_IntuitionBase:		DC.L	0
_GraphicsBase:		DC.L	0
_GadToolsBase:		DC.L	0
_AslBase:		DC.L	0
_DiskFontBase:		DC.L	0

_File_Handle:		DC.L	0

_SystemFont:		DC.L	0
_DPaintFont:		DC.L	0
_My_VisualInfo:		DC.L	0

_Wk_Screen:		DC.L	0
_Wk_Window:		DC.L	0
_Wk_UserPort:		DC.L	0
_Wk_RastPort:		DC.L	0
_Wk_ViewPort:		DC.L	0
_Wk_Gadgets:		DC.L	0

_Global_RastPort:	DC.L	0


 EVEN

_Raised_Box_Colour:	DC.W	0,2,3
_Lowered_Box_Colour:	DC.W	0,3,2

_System_Colours:	DC.W	$0468,$0024,$0FFF,$079B ;,$0024,$0999,$0000,$0EEE

_Message:		DS.L	im_SIZEOF/4
_Quit:			DC.W	0

Minus_1:		DC.L	-1

File_Gadget_Count:	DC.L	0
Image_Gadget_Count:	DC.L	0


_System80:		DC.L	_SystemName,$00080001
_DPaint50:		DC.L	_DpaintName,$00050002

Text_Req_Yes_No:	DC.B	"Yes|No",0

Text_Mev3_Title:	DC.B	"Mev3.0 © 1994 M.J.Edwards",0

Text_Mev3_Confirm:	DC.B	"Mev3.0 : Confirm...",0
Text_Mev3_Query:	DC.B	"Mev3.0 : Query...",0
Text_Mev3_Inform:	DC.B	"Mev3.0 : Information...",0

Text_No_Mem:		DC.B	"Not enough memory",10
			DC.B	"for requested %s size"
			DC.B	0

Text_File_Not_Found:	DC.B	"File not found",0

Text_Are_You_Sure:	DC.B	"Delete : ",34,"%s",34,"!",10
			DC.B	"Are you sure?",0

Text_File_Exists:	DC.B	34,"%s",34
			DC.B	" already exists !",10
			DC.B	"Overwrite?",0

Text_Edit_Tile:		DC.B	"TILE:%3ld ",0
Text_Edit_Map:		DC.B	"MAP:%ld ",0
Text_Edit_Map_X:	DC.B	"MAP X:%3ld ",0
Text_Edit_Map_Y:	DC.B	"MAP Y:%3ld ",0
Text_Edit_Region:	DC.B	"In Region",0

		
_SystemName:		DC.B	"system.font",0
_DpaintName:		DC.B	"dpaint.font",0
_DosName:		DC.B	"dos.library",0
_IntuitionName:		DC.B	"intuition.library",0
_GraphicsName:		DC.B	"graphics.library",0
_GadToolsName:		DC.B	"gadtools.library",0
_AslName:		DC.B	"asl.library",0
_DiskFontName:		DC.B	"diskfont.library",0

 EVEN

Work_Image:		incbin	"/bin/mev3_icons.img"

 EVEN
 ENDC


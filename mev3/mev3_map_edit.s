 IFND	MEV3_MAP_EDIT_S
MEV3_MAP_EDIT_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
*
* $VER:mev3_map_edit.s 39.01  © (12/April/94) M.J.Edwards
*
*

MAPSCROLLERX_HEIGHT	EQU	16

	BITDEF	FLAG0,SLIDER_X_ON,0
	BITDEF	FLAG0,SLIDER_X_IN,1
	BITDEF	FLAG0,SLIDER_Y_ON,2	; #FLAG0B_SLIDER_Y_ON,_Preference_Flags0
	BITDEF	FLAG0,SLIDER_Y_IN,3
;	BITDEF	FLAG0,SCREEN_DETECT,4

	BITDEF	SHP,GET,0
	BITDEF	SHP,PUT,1
	BITDEF	SHP,GETTING,2



 EVEN

_WorkWindow_List:
	NewWorkWindow	ProjectMain,0,_Work_Window_Setup,_Work_ProjectMain_Gadget_List,0,0,640,34

	NewWorkWindow	MapMain,1,_Work_Setup_Map_Main,_Work_MapMain_Gadget_List,0,0,640,34
	NewWorkWindow	MapFile,2,_Work_Window_Setup,_Work_MapFile_Gadget_List,0,0,640,22
	NewWorkWindow	MapShapes,3,_Work_Window_Setup,_Work_MapShapes_Gadget_List,0,0,640,22
	NewWorkWindow	MapShapesFile,4,_Work_Window_Setup,_Work_MapShapesFile_Gadget_List,0,0,640,22
	NewWorkWindow	MapConfiguration,5,_Work_Window_Setup,_Work_MapConfiguration_Gadget_List,0,0,640,34
	NewWorkWindow	MapPreferences,6,_Work_Window_Setup,_Work_MapPreferences_Gadget_List,0,0,640,34

	NewWorkWindow	TileMain,1,_Work_Setup_Tile_Main,_Work_TileMain_Gadget_List,0,0,640,34

	DC.W	-1


_Work_ProjectMain_Gadget_List:
		SetGadget	610,02,26,11,BUTTON_ID_BEHIND,IMAGE_BEHIND
		SetGadget	610,14,26,11,BUTTON_ID_ICONIZE,IMAGE_ICONIZE

		SetGadget	006,003,32,16,BUTTON_ID_NULL,IMAGE_PROJECT

		SetGadget	044+(00*34)+6,03+(0*17),32,16,BUTTON_ID_PROJECTFILE,IMAGE_FILE
		SetGadget	044+(01*34)+6,03+(0*17),32,16,BUTTON_ID_WORKBENCH,IMAGE_WORKBENCH
		SetGadget	044+(02*34)+6,03+(0*17),32,16,BUTTON_ID_MAP,IMAGE_MAP
		SetGadget	044+(03*34)+6,03+(0*17),32,16,BUTTON_ID_TILE,IMAGE_TILE
		SetGadget	044+(04*34)+6,03+(0*17),32,16,BUTTON_ID_ANIM,IMAGE_ANIM
		SetGadget	044+(05*34)+6,03+(0*17),32,16,BUTTON_ID_COPPER,IMAGE_COPPER
		SetGadget	044+(06*34)+6,03+(0*17),32,16,BUTTON_ID_CONFIGURATION,IMAGE_CONFIGURATION
		SetGadget	044+(07*34)+6,03+(0*17),32,16,BUTTON_ID_PREFERENCES,IMAGE_PREFERENCES

		SetGadget	044+000+6,022,016,009,BUTTON_ID_PROJECTPREV,IMAGE_NEWARROWLEFT
		SetGadget	044+018+6,022,016,009,BUTTON_ID_PROJECTNEXT,IMAGE_NEWARROWRIGHT
		SetGadget	044+036+6,021,204,011,STRING_ID_PROJECTNAME,GAD_STRING
		SetGadget	044+242+6,021,016,011,BUTTON_ID_PROJECTSELECT,IMAGE_SMALLQUESTIONMARK

		DC.W	-1

_Work_MapMain_Gadget_List:

		SetGadget	006,003,32,16,BUTTON_ID_NULL,IMAGE_MAP

		SetGadget	044+(00*34)+6,03+(0*17),32,16,BUTTON_ID_OPENMAPFILE,IMAGE_FILE
		SetGadget	044+(01*34)+6,03+(0*17),32,16,BUTTON_ID_OPENMAPSHAPES,IMAGE_SHAPES
		SetGadget	044+(02*34)+6,03+(0*17),32,16,BUTTON_ID_OPENMAPCONFIG,IMAGE_CONFIGURATION

		SetGadget	044+268+(00*32),02+(0*11),36,08,BUTTON_ID_NULL,IMAGE_UNDO
		SetGadget	044+268+(00*32),02+(1*11),36,08,BUTTON_ID_NULL,IMAGE_ZOOM
;		SetGadget	044+268+(00*32),02+(2*11),36,08,BUTTON_ID_NULL,IMAGE_BLANK

		SetGadget	044+308+(00*26),02+(0*13),24,12,BUTTON_ID_CLEAR,IMAGE_CLEAR
		SetGadget	044+308+(01*26),02+(0*13),24,12,BUTTON_ID_SCRIBBLE,IMAGE_SCRIBBLE
		SetGadget	044+308+(02*26),02+(0*13),24,12,BUTTON_ID_LINE,IMAGE_LINE
		SetGadget	044+308+(03*26),02+(0*13),24,12,BUTTON_ID_RECTANGLE,IMAGE_RECTANGLE
		SetGadget	044+308+(04*26),02+(0*13),24,12,BUTTON_ID_CUT,IMAGE_CUT

		SetGadget	044+000+6,021+1,016,009,BUTTON_ID_MAPPREV,IMAGE_NEWARROWLEFT
		SetGadget	044+018+6,021+1,016,009,BUTTON_ID_MAPNEXT,IMAGE_NEWARROWRIGHT
		SetGadget	044+036+6,021+0,204,011,STRING_ID_MAPNAME,GAD_STRING
		SetGadget	044+242+6,021+0,016,011,BUTTON_ID_MAPSELECT,IMAGE_SMALLQUESTIONMARK
		DC.W	-1

_Work_MapFile_Gadget_List:
		SetGadget	006,003,32,16,BUTTON_ID_CLOSEMAPFILE,IMAGE_FILE

		SetGadget	044+(00*34)+6,03+(0*17),32,16,BUTTON_ID_NULL,IMAGE_FILESAVE
		SetGadget	044+(01*34)+6,03+(0*17),32,16,BUTTON_ID_NULL,IMAGE_FILELOAD

		DC.W	-1

_Work_MapShapes_Gadget_List:
		SetGadget	006,003,32,16,BUTTON_ID_CLOSEMAPSHAPES,IMAGE_SHAPES

		SetGadget	044+(00*34)+6,03+(0*17),32,16,BUTTON_ID_OPENMAPSHAPESFILE,IMAGE_FILE
		SetGadget	44+090,000+003,64,11,BUTTON_ID_SHAPEPAINT,GAD_TEXT|TEXT_PAINT
		SetGadget	44+150,000+003,64,11,BUTTON_ID_SHAPEERASE,GAD_TEXT|TEXT_ERASE
		SetGadget	44+210,000+003,64,11,BUTTON_ID_SHAPEPICKUP,GAD_TEXT|TEXT_PICKUP

		DC.W	-1

_Work_MapShapesFile_Gadget_List:
		SetGadget	006,003,32,16,BUTTON_ID_CLOSEMAPSHAPESFILE,IMAGE_FILE

		SetGadget	044+(00*34)+6,03+(0*17),32,16,BUTTON_ID_NULL,IMAGE_FILESAVE
		SetGadget	044+(01*34)+6,03+(0*17),32,16,BUTTON_ID_NULL,IMAGE_FILELOAD

		DC.W	-1

_Work_MapConfiguration_Gadget_List:
		SetGadget	006,003,32,16,BUTTON_ID_CLOSEMAPCONFIG,IMAGE_CONFIGURATION
		DC.W	-1

_Work_MapPreferences_Gadget_List:
		SetGadget	006,003,32,16,BUTTON_ID_CLOSEMAPPREFS,IMAGE_PREFERENCES
		DC.W	-1


	
_Work_TileMain_Gadget_List:

		SetGadget	006,003,32,16,BUTTON_ID_NULL,IMAGE_MAP

		SetGadget	044+(00*34)+6,03+(0*17),32,16,BUTTON_ID_OPENMAPFILE,IMAGE_FILE
		SetGadget	044+(01*34)+6,03+(0*17),32,16,BUTTON_ID_OPENMAPSHAPES,IMAGE_SHAPES
		SetGadget	044+(02*34)+6,03+(0*17),32,16,BUTTON_ID_OPENMAPCONFIG,IMAGE_CONFIGURATION

		SetGadget	044+268+(00*32),02+(0*11),36,08,BUTTON_ID_NULL,IMAGE_UNDO
		SetGadget	044+268+(00*32),02+(1*11),36,08,BUTTON_ID_NULL,IMAGE_ZOOM
;		SetGadget	044+268+(00*32),02+(2*11),36,08,BUTTON_ID_NULL,IMAGE_BLANK

		SetGadget	044+308+(00*26),02+(0*13),24,12,BUTTON_ID_CLEAR,IMAGE_CLEAR
		SetGadget	044+308+(01*26),02+(0*13),24,12,BUTTON_ID_SCRIBBLE,IMAGE_SCRIBBLE
		SetGadget	044+308+(02*26),02+(0*13),24,12,BUTTON_ID_LINE,IMAGE_LINE
		SetGadget	044+308+(03*26),02+(0*13),24,12,BUTTON_ID_RECTANGLE,IMAGE_RECTANGLE
		SetGadget	044+308+(04*26),02+(0*13),24,12,BUTTON_ID_CUT,IMAGE_CUT

		SetGadget	044+000+6,021+1,016,009,BUTTON_ID_MAPPREV,IMAGE_NEWARROWLEFT
		SetGadget	044+018+6,021+1,016,009,BUTTON_ID_MAPNEXT,IMAGE_NEWARROWRIGHT
		SetGadget	044+036+6,021+0,204,011,STRING_ID_MAPNAME,GAD_STRING
		SetGadget	044+242+6,021+0,016,011,BUTTON_ID_MAPSELECT,IMAGE_SMALLQUESTIONMARK
		DC.W	-1


_Work_Window_Setup:	; a0 - window
	push	a0
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.w	#44,d2
	move.w	wd_Height(a0),d3
	subq.w	#1,d2
	subq.w	#1,d3
	move.l	wd_RPort(a0),_Global_RastPort
	call	_Clear_Lowered_Hires_Box

	pull	a0

	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.w	#44,d0
	move.w	wd_Width(a0),d2
	move.w	wd_Height(a0),d3
	subq.w	#1,d2
	subq.w	#1,d3
	move.l	wd_RPort(a0),_Global_RastPort
	call	_Clear_Raised_Hires_Box

	pull	a0
	push	a1
	move.l	a0,a1
	move.l	wd_FirstGadget(a1),a0
	call	_Count_Gadgets
	call	_RefreshGList
	pop	a1
	pop	a0
	rts

_These_MapShapeFileWindows_WereActive:	DC.L	0


_Work_Open_Map_Main:
	
	moveq.l	#gcWinMapMain,d0
	call	_AddWorkWindow	

_Work_Setup_Map_Main:

	moveq.l	#gcWinMapMain,d0
	call	_Set_Current_WorkWindow
	tst.l	d0
	beq.s	.no_window
	push	d0-d2
	move.l	d0,a0
	call	_Work_Window_Setup
	pop	d0-d2

	move.w	#STRING_ID_CURRTILE,d0		; set tile gad string to be centered and longint
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation

	jsr	_Map_Work_Scribble

	jsr	_Map_Work_Display
.no_window
	rts

_Work_Open_Map_ShapesFile:

	move.l	#0,d0
	bset	#gcWinMapShapesFile,d0
	call	_IsWindowOpen
	tst.l	d0
	bne.s	.no_file_win_open
	move.l	#-1,d0
	bclr	#gcWinMapShapes,d0
	call	_CloseTheseWindows
	move.l	d0,_These_MapShapeFileWindows_WereActive
	move.l	#gcWinMapShapesFile,d0
	call	_AddWorkWindow	
.no_file_win_open
	rts
	
_Work_Open_Map_Shapes:
	move.l	#gcWinMapShapes,d0
	bra.s	_Work_Open_A_Window

_Work_Open_Map_Configuration:
	move.l	#-1,d0
	call	_CloseTheseWindows
	move.l	d0,_These_MapConfigWindows_WereActive
	move.l	#gcWinMapConfiguration,d0
	bra.s	_Work_Open_A_Window

_Work_Open_Map_Preferences:
	move.l	#gcWinMapPreferences,d0
	bra.s	_Work_Open_A_Window

_Work_Open_Map_File:
	move.l	#gcWinMapFile,d0
	bra.s	_Work_Open_A_Window

	nop

_Work_Open_A_Window:
	call	_AddWorkWindow	
	rts


_These_MapConfigWindows_WereActive:	DC.L	0


_Work_Close_Map_Main:

	move.l	#gcWinMapMain,d0
	bra.s	_Work_Close_A_Window

_Work_Close_Map_ShapesFile:

	move.l	#gcWinMapShapesFile,d0
	bsr.s	_Work_Close_A_Window
	move.l	_These_MapShapeFileWindows_WereActive,d0
	call	_OpenTheseWindows

	rts

_Work_Close_Map_Shapes:
	
	move.l	#0,d0
	bset	#gcWinMapShapesFile,d0
	call	_IsWindowOpen
	tst.l	d0
	bne.s	.no_file_win_open
	move.l	#gcWinMapShapes,d0
	call	_RemoveWorkWindow	
.no_file_win_open
	rts

_Work_Close_Map_Configuration:
	move.l	#gcWinMapConfiguration,d0
	bsr.s	_Work_Close_A_Window
	move.l	_These_MapConfigWindows_WereActive,d0
	call	_OpenTheseWindows
	rts
_Work_Close_Map_Preferences:
	move.l	#gcWinMapPreferences,d0
	bra.s	_Work_Close_A_Window

_Work_Close_Map_File:
	move.l	#gcWinMapFile,d0
	bra.s	_Work_Close_A_Window
	nop
_Work_Close_A_Window:
	call	_RemoveWorkWindow	
	
	rts


_Work_Open_Tile_Main:
	
	moveq.l	#gcWinTileMain,d0
	call	_AddWorkWindow	

_Work_Setup_Tile_Main:

	moveq.l	#gcWinTileMain,d0
	call	_Set_Current_WorkWindow
	tst.l	d0
	beq.s	.no_window
	push	d0-d2
	move.l	d0,a0
	call	_Work_Window_Setup
	pop	d0-d2

;	move.w	#STRING_ID_CURRTILE,d0		; set tile gad string to be centered and longint
;	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
;	jsr	_Set_Work_Gadget_Activation

;	jsr	_Map_Work_Scribble
;
;	jsr	_Map_Work_Display
.no_window
	rts




;****************************************************
;          Map Editor Screen & Util Window
;****************************************************

TOOL_RESTORE_FLAG	EQU	$0001	;  1
TOOL_DISPLAY_FLAG	EQU	$0002	;  2
TOOL_WRITE_FLAG		EQU	$0003	;  3
TOOL_READ_FLAG		EQU	$0004	;  4
TOOL_LEAVE_FLAG		EQU	$0005	;  5
TOOL_BUTTONUP_FLAG	EQU	$0006	;  6
TOOL_BUTTONDOWN_FLAG	EQU	$0007	;  7


;main()
;{
;    select (intuimessage) {
;        case MOUSEMOVE :
;            if (last_mouse_pos is_different_from present_mouse_pos) {
;                restore object
;                draw object
;            }
;            break;
;        case MOUSEBUTTONS :
;
;            break;
;    }


Setup_Map_Ed:
	lea	Shutdown_Map_Ed,a0
	jsr	_Set_Exit_Jump

	st	_Tools_On-PC(gl)
	st	_Regions_On-PC(gl)


	jsr	_Open_Map_Edit_Screen_Window

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	jsr	_Open_Map_Work_Screen_Window


;	move.l	_Wk_RastPort-PC(gl),_Global_RastPort-PC(gl)
;
;; if the shapes display was activated when we exited, then we need to
;; redraw it when we enter again
;
;; set the tool "scribble" for editing the map
;

;
;	tst.b	_Shape_Ed-PC(gl)
;	beq.s	.not_using_shapes
;	jsr	_Map_Work_Shape_Setup
;;	bra	.gadget_setup_complete
;.not_using_shapes
;
;
;; all these would of changed since last time we were here
;	move.w	#CHGF_TILE!CHGF_MAPSET!CHGF_XCOORD!CHGF_YCOORD!CHGF_SHELL_XY,_Something_Mask-PC(gl)
;
;; now update the above changed texts
;	jsr	Display_Text_Map_Set
;	jsr	Display_Text_Tile
;	jsr	Display_Text_Map_X
;	jsr	Display_Text_Map_Y
;

	move.l	_Wk_Screen-PC(gl),a0
	jsr	_ScreenToFront

	rts

_Map_Work_Display:
	move.w	#CHGF_TILE!CHGF_MAPSET!CHGF_XCOORD!CHGF_YCOORD!CHGF_SHELL_XY,d0
	or.w	d0,_Something_Changed-PC(gl)
	move.w	d0,_Something_Mask-PC(gl)
	rts

; this shutsdown the map editor : removes all acitve/inactive gadgets/menus 
;				: windows edit & work
;				: screens edit & work



Shutdown_Map_Ed:

;	moveq.l	#-1,d0
;	moveq.l	#-1,d1
;	lea	_Map_Region_Coordinates,a0
;	jsr	_Check_Regions


	jsr	_Close_Map_Edit_Screen_Window

	jsr	_Close_Map_Work_Screen_Window

	jsr	_Clear_Exit_Jump

	rts


_Open_Map_Work_Screen_Window:

	call	_AddWorkScreen

	call	_Work_Open_Map_Main
	
;	move.l	#gcWinMapMain,d0
;	call	_AddWorkWindow	

;	move.l	#_Wk_Gadgets,d0
;	lea	_Map_Work_Gadget_List,a0
;	jsr	_Create_Work_Gadgets
;
;
;	jsr	_Open_Work_Screen
;
;	move.l	_Wk_Gadgets-PC(gl),a0
;	jsr	_Count_Gadgets
;	move.l	a0,a1
;	move.l	d0,d1
;	moveq.l	#0,d0
;	move.l	_Wk_Window-PC(gl),a0
;	jsr	_AddGList
;



;
;;	jsr	_Map_Work_Zoom_Setup
;
	rts	

_Set_Current_WorkWindow:	; d0 - gcWin<window>
	call	_GetWorkWindowHandle
	move.l	d0,_Wk_Window
	move.l	d1,_Wk_Gadgets
	move.l	d2,_Wk_RastPort	
	rts

_Close_Map_Work_Screen_Window

	call	_Work_Close_Map_Main

;	move.l	#gcWinMapMain,d0
;	call	_RemoveWorkWindow	

;	move.l	#gcWinProjectMain,d0
;	call	_RemoveWorkWindow

	call	_RemoveWorkScreen
	
;
;	move.l	_Wk_Window-PC(gl),a0
;	jsr	_Remove_Windows_Gadget_List
;	jsr	_Remove_All_Work_Gadgets
;
;; close window work
;	move.l	_Wk_Window-PC(gl),a0
;	jsr	_Close_Window
;	move.l	#0,_Wk_Window-PC(gl)
;; close screen work
;	move.l	_Wk_Screen-PC(gl),a0
;	jsr	_Close_Screen
;	move.l	#0,_Wk_Screen-PC(gl)
;
	rts


;
;;
;;;- open, close check screen for map edit
;;
;

; opens the editor screen for the map editor
; gets in map, tile, shape, palette info etc...

Close_Open_Edit_Screen:
	jsr	_Close_Map_Edit_Screen_Window
	jsr	_Open_Map_Edit_Screen_Window
	move.l	_Wk_Screen-PC(gl),a0
	jsr	_ScreenToFront
	rts

_Open_Edit_Screen_Map:
	lea	_Default_Preferences-PC(gl),a0
	moveq.l	#0,d7
	move.w	_Zoom_Ed-PC(gl),d7
	mulu	#prefs_NormSIZEOF,d7
	pea	TAG_DONE		;
	pea	Minus_1			;
	pea	SA_Pens			;
	pea	1.w			; OSCAN_TEXT
	pea	SA_Overscan		;
	pea	TRUE			;
	pea	SA_AutoScroll		;
	pea	FALSE			;
	pea	SA_ShowTitle		;
	move.l	prefs_NormScrMode(a0,d7.w),d0
	push	d0			;
	pea	SA_DisplayID		;
	moveq.l	#0,d0
	move.w	_Tile_Depth,d0
	push	d0			;
	pea	SA_Depth		;

	move.w	prefs_NormScrHeight(a0,d7.w),d0
	push	d0			;
	pea	SA_Height		;
	move.w	prefs_NormScrWidth(a0,d7.w),d0
	push	d0			;
	pea	SA_Width		;

	move.l	sp,a1
	sub.l	a0,a0
	
; open screen
;	sub.l	a0,a0
;	lea	Edit_Screen_TagList,a1
	jsr	_Open_Screen
	move.l	d0,_Ed_Screen-PC(gl)
	lea	17*4(sp),sp

; find visual info
	move.l	_Ed_Screen-PC(gl),a0
	jsr	_GetVisualInfo
	move.l	d0,_Ed_VisualInfo-PC(gl)
	move.l	d0,_Gl_VisualInfo-PC(gl)

; open window ed
	move.l	_Ed_Screen-PC(gl),a0

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
	move.l	d0,_Ed_Window-PC(gl)
	move.l	d1,_Ed_RastPort-PC(gl)
	move.l	d2,_Ed_ViewPort-PC(gl)
	move.l	d3,_Ed_UserPort-PC(gl)

	rts


_Close_Edit_Screen:
; close window ed
	move.l	_Ed_Window-PC(gl),a0
	jsr	_Close_Window
	move.l	#0,_Ed_Window-PC(gl)
; remove visual info
	move.l	_Ed_VisualInfo-PC(gl),a0
	jsr	_RemoveVisualInfo
	move.l	#0,_Ed_VisualInfo-PC(gl)
; close screen ed
	move.l	_Ed_Screen-PC(gl),a0
	jsr	_Close_Screen
	move.l	#0,_Ed_Screen-PC(gl)
	rts

_Check_Map_Edit_Screen:	
	jsr	Read_Map_Info
	jsr	Read_Tile_Info


	move.l	_Ed_Screen-PC(gl),d0
	move.l	d0,a0
	beq.s	.shit_quick_open_it
	lea	sc_BitMap(a0),a1
	moveq.l	#0,d0
	move.b	bm_Depth(a1),d0
	cmp.w	_Tile_Depth-PC(gl),d0
;	beq.s	.there_the_same
	bne.s	.there_not_the_same
;	move.w	sc_Width(a0),d0
;	move.l	Edit_Screen_Width+4,d1
;	cmp.w	d1,d0
;	bne.s	.there_not_the_same
	bra.s	.there_the_same
.there_not_the_same
	jsr	_Close_Map_Edit_Screen_Window
.shit_quick_open_it
	jsr	_Open_Map_Edit_Screen_Window
	bra.s	.no_setup
.there_the_same
	jsr	_ShutDown_Map_Edit_Screen_First
	jsr	_Setup_Map_Edit_Screen_First
	jsr	_Setup_Map_Edit_Screen_Last
.no_setup
	move.l	_Wk_Screen-PC(gl),a0
	jsr	_ScreenToFront

	rts


_Setup_Map_Edit_Screen_First:
	jsr	Read_Map_Info
	jsr	Read_Tile_Info
	move.w	#-1,_Map_Last_X-PC(gl)
	or.w	#CHGF_MAPSET,_Something_Changed-PC(gl)
	rts

_Setup_Map_Edit_Screen_Last:

	jsr	_SetUp_Map_Edit_Screen_Window

	move.w	_Tile_Depth-PC(gl),d0
	jsr	_Power_Of_2
	move.l	_Ed_ViewPort-PC(gl),a0
	move.l	_Tile_Colours-PC(gl),a1
	jsr	_LoadRGB32
;	jsr	_LoadRGB4

	jsr	_Create_Map_Edit_Gadgets

; set ed screen/window colours

	move.l	_Ed_RastPort-PC(gl),_Global_RastPort-PC(gl)
	moveq.l	#0,d0
	jsr	_SetAPen
	coord.w	0,0,640,512
	jsr	_RectFill
	lea	_Map_Region_Coordinates,a0
	jsr	_Draw_Region_Boxes

	jsr	Display_Map
	jsr	_Display_Tile_List_Map

	move.l	_Ed_Gadgets-PC(gl),a0
	jsr	_Count_Gadgets
	move.l	_Ed_Window-PC(gl),a1
	jsr	_RefreshGList

	rts

_Open_Map_Edit_Screen_Window:
	jsr	_Setup_Map_Edit_Screen_First
	jsr	_Open_Edit_Screen_Map
	jsr	_Setup_Map_Edit_Screen_Last
	rts

_ShutDown_Map_Edit_Screen_First:
	jsr	_Remove_Map_Edit_Gadgets
	rts

_Close_Map_Edit_Screen_Window:
	jsr	_ShutDown_Map_Edit_Screen_First
	jsr	_Close_Edit_Screen
	rts

;;- more gadget function for map editor

_Remove_All_Work_Gadgets:
	move.l	_Wk_Gadgets-PC(gl),a0
	jsr	_Remove_Work_Gadgets
	move.l	#0,_Wk_Gadgets-PC(gl)
	move.l	_ReActive_Gadgets,a0
	jsr	_Remove_Work_Gadgets
	move.l	#0,_Active_Gadgets-PC(gl)
	move.l	#0,_ReActive_Gadgets-PC(gl)
	rts

_Remove_Windows_Gadget_List:	; a0 - window
	exg.l	a0,a1
	move.l	wd_FirstGadget(a1),a0
	jsr	_Count_Gadgets
	exg.l	a1,a0
	jsr	_RemoveGList
	rts

_Add_Window_Gadget_List:	; a0 - gadgets list, a1 - window
	jsr	_Count_Gadgets
	exg.l	a0,a1
	move.l	d0,d1
	moveq.l	#0,d0
	jsr	_AddGList
	rts


_Create_Map_Edit_Gadgets:
	lea	_Gad_Tags_MapScrollerY,a0
	moveq.l	#0,d0
	move.w	_Map_Edit_Height-PC(gl),d0
	move.l	d0,_Gad_MapScrollerY_Visible-_Gad_Tags_MapScrollerY+4(a0)
	moveq.l	#0,d0
	move.w	_Map_Height-PC(gl),d0
	move.l	d0,_Gad_MapScrollerY_Total-_Gad_Tags_MapScrollerY+4(a0)

	lea	_Gad_Tags_MapScrollerX,a0
	moveq.l	#0,d0
	move.w	_Map_Edit_Width-PC(gl),d0
	move.l	d0,_Gad_MapScrollerX_Visible-_Gad_Tags_MapScrollerX+4(a0)
	moveq.l	#0,d0
	move.w	_Map_Width-PC(gl),d0
	move.l	d0,_Gad_MapScrollerX_Total-_Gad_Tags_MapScrollerX+4(a0)

	lea	_Ed_Gadgets-PC(gl),a0
	
	jsr	_CreateContext		; -> d0 = gad(get) pointer

	lea	_Work_MapScrollerY,a0
	lea	Region_Map_Edit,a1
	move.w	rg_LeftEdge(a1),d1
	add.w	rg_Width(a1),d1
	addq.w	#1,d1
	move.w	d1,6(a0)
	move.w	rg_Height(a1),12(a0)

	lea	_Work_MapScrollerX,a0
	lea	Region_Map_Edit,a1
	move.w	rg_LeftEdge(a1),6(a0)	; leftedge
	move.w	rg_TopEdge(a1),d1
	add.w	rg_Height(a1),d1
	addq.w	#1,d1
	move.w	d1,8(a0)		; topedge
	move.w	rg_Width(a1),10(a0)	; width

	lea	_Work_Map_Gadget_List,a0
	jsr	_Create_Gadgets_List

	move.l	_Ed_Gadgets-PC(gl),a0
	move.l	_Ed_Window-PC(gl),a1
	jsr	_Add_Window_Gadget_List

	rts


_Remove_Map_Edit_Gadgets:
	move.l	_Ed_Window-PC(gl),a0
	jsr	_Remove_Windows_Gadget_List
	move.l	_Ed_Gadgets-PC(gl),a0
	jsr	_FreeGadgets
	rts


_Work_Map_Gadget_List:
_Work_MapScrollerY:	NewGadget	SCROLLER_KIND,_Gad_Tags_MapScrollerY,506,000,015,100,NULL,NULL,BUTTON_ID_MAPSCROLLERY,NULL,NULL,NULL
_Work_MapScrollerX:	NewGadget	SCROLLER_KIND,_Gad_Tags_MapScrollerX,000,000,000,013,NULL,NULL,BUTTON_ID_MAPSCROLLERX,NULL,NULL,NULL
			DC.W	-1

_Gad_Tags_MapScrollerY:
_Gad_MapScrollerY_Total:	DC.L	GTSC_Total,12
_Gad_MapScrollerY_Visible:	DC.L	GTSC_Visible,4
				DC.L	GTSC_Arrows,15
				DC.L	PGA_Freedom,LORIENT_VERT
				DC.L	GA_RelVerify,1
				DC.L	TAG_DONE

_Gad_Tags_MapScrollerX:
_Gad_MapScrollerX_Total:	DC.L	GTSC_Total,12
_Gad_MapScrollerX_Visible:	DC.L	GTSC_Visible,4
				DC.L	GTSC_Arrows,14
				DC.L	PGA_Freedom,LORIENT_HORIZ
				DC.L	GA_RelVerify,1
				DC.L	TAG_DONE


dbg51:
_Setup_Map_Edit_Screen_Window:
	move.l	_Ed_Screen-PC(gl),a0
	
	
	
	lea	Region_Map_Edit,a1
	moveq.l	#0,d0
	move.w	sc_Width(a0),d0

	btst	#FLAG0B_SLIDER_Y_ON,_Preference_Flags0-PC(gl)
	beq.s	.no_slider_for_y
	sub.w	#16,d0
.no_slider_for_y	
;	move.w	d0,rg_Width(a1)

	move.l	d0,d1
	move.w	_Tile_Width-PC(gl),d2
	divu	d2,d1
	andi.w	#$FFFF,d1
	move.w	_Map_Width-PC(gl),d3
	cmp.w	d3,d1
	bls.s	.map_width_ok
	move.w	d3,d1
.map_width_ok	

	move.w	d1,_Map_Edit_Width-PC(gl)
	mulu	d2,d1
	sub.w	d1,d0
	tst.w	d0
	beq.s	.no_width_left
	lsr.w	#1,d0	
.no_width_left	
	move.w	d0,rg_LeftEdge(a1)
	move.w	d1,rg_Width(a1)

	moveq.l	#0,d0
	move.w	sc_Height(a0),d0

	sub.w	#MAXHEIGHT_TILE,d0		; for tiles

	btst	#FLAG0B_SLIDER_X_ON,_Preference_Flags0-PC(gl)
	beq.s	.no_slider_for_x
	sub.w	#16,d0
.no_slider_for_x
;	move.w	d0,rg_Width(a1)

	move.l	d0,d1
	move.w	_Tile_Height-PC(gl),d2
	divu	d2,d1
	andi.w	#$FFFF,d1
	move.w	_Map_Height-PC(gl),d3
	cmp.w	d3,d1
	bls.s	.map_height_ok
	move.w	d3,d1
.map_height_ok	
	move.w	d1,_Map_Edit_Height-PC(gl)
	mulu	d2,d1

;	cmp.w	d0,d1
;	bhs.s	.no_height_left
	moveq.l	#0,d0
;	sub.w	d1,d0
;	lsr.w	#1,d0
;.no_height_left
	move.w	d0,rg_TopEdge(a1)
	move.w	d1,rg_Height(a1)

	
;	move.w	_Zoom_Ed-PC(gl),d7
;	ext.l	d7
;	addq.l	#1,d7
;	move.w	sc_Width(a0),d0
;	mulu	d7,d0
;
;	move.w	_Map_Width-PC(gl),d1
;	move.w	_Tile_Width-PC(gl),d2
;	mulu	d2,d1
;	moveq.l	#0,d3
;	cmp.l	d0,d1		; test if mapwidth is smaller than screen width
;	blt.s	.some_width_left
;
;	move.w	d0,d1
;	btst	#FLAG0B_SLIDER_Y_ON,_Preference_Flags0-PC(gl)
;	beq.s	.no_slider_for_y
;;;- make region as small as screen
;	
;;;- region is bigger than screen so make room on right of screen for gadget
;	add.w	#16,d0
;
;	btst	#FLAG0B_SLIDER_Y_IN,_Preference_Flags0-PC(gl)
;	beq.s	.no_slider_for_y
;	sub.w	#16,d0
;	sub.w	#16,d1
;.no_slider_for_y
;	
;	bra.s	.left_width_ok
;.some_width_left
;	sub.w	d1,d0
;	cmp.w	#16,d0
;	bhi.s	.gad_will_fit
;	move.w	#16,d0
;.gad_will_fit
;	add.w	d1,d0
;	move.w	d0,d3
;	sub.w	d1,d3
;	sub.w	#16,d3
;	asr.w	#1,d3
;.left_width_ok
;	divu	d2,d1
;	ext.l	d1
;
;;	move.l	d0,Edit_Screen_Width+4-PC(gl)		; set screen &
;;	move.l	d0,Edit_Window_Width+4-PC(gl)		; window width
;	move.w	d1,_Map_Edit_Width-PC(gl)		; width of edit region
;	mulu	d2,d1
;	move.w	d1,rg_Width(a1)
;	move.w	d3,rg_LeftEdge(a1)
;
;;	move.w	#256,d0
;	move.w	sc_Height(a0),d0
;	mulu	d7,d0
;	move.w	_Map_Height-PC(gl),d1
;	move.w	_Tile_Height-PC(gl),d2
;	mulu	d2,d1
;	moveq.l	#0,d3
;	cmp.l	d0,d1
;	blt.s	.some_height_left
;;;- map is taller than screen
;;;- make region as small as screen
;	move.w	d0,d1
;
;;;- remove the region height from max edit region height
;
;	move.w	#64,d5
;	mulu	d7,d5
;;	add.w	#MAPSCROLLERX_HEIGHT,d5
;
;	sub.w	d5,d1
;
;	btst	#FLAG0B_SLIDER_X_ON,_Preference_Flags0-PC(gl)
;	beq.s	.no_slider_for_x
;
;;;- if gadget slider x if on - remove the gadget slider height from max edit region height
;	sub.w	#MAPSCROLLERX_HEIGHT,d1
;
;.no_slider_for_x
;	bra.s	.top_height_ok
;.some_height_left
;	move.w	d0,d4
;	sub.w	d1,d4
;	move.w	#64,d5
;	mulu	d7,d5
;	add.w	#MAPSCROLLERX_HEIGHT,d5
;	cmp.w	d5,d4
;	bhi.s	.gad_x_will_fit
;	sub.w	d5,d4
;	add.w	d4,d1
;.gad_x_will_fit		
;	
;	nop	
;
;.top_height_ok
;	divu	d2,d1
;	ext.l	d1
;
;;	move.l	d0,Edit_Screen_Height+4-PC(gl)		; set screen &
;;	move.l	d0,Edit_Window_Height+4-PC(gl)		; window height
;	move.w	d1,_Map_Edit_Height-PC(gl)		; height of edit region
;	mulu	d2,d1
;	move.w	d1,rg_Height(a1)
;	move.w	d3,rg_TopEdge(a1)
;	
	rts	


dbg49:
_SetUp_Map_Edit_Screen_Window:


	lea	Region_Map_Edit,a0

	push	d0-a7/a0-a6
	jsr	_Setup_Map_Edit_Screen_Window
	pop	d0-a7/a0-a6

	jsr	Pre_Calculate_Map_Edit_Choice_Region

	jsr	Calculate_Map_Edit_Boundries
	jsr	Calculate_Tile_Win_Boundries
	rts

_Draw_Region_Boxes:	; a0 - region list
.0
	tst.w	(a0)
	bmi.s	.1
	movem.w	2(a0),d0-d3
	add.w	d0,d2
	add.w	d1,d3
	sub.w	#1,d2
	sub.w	#1,d3
	push	a0
	jsr	_Draw_Raised_Box
	pop	a0
	add.l	#rg_SIZEOF,a0
	bra.s	.0
.1
	rts




Pre_Calculate_Map_Edit_Choice_Region:
	lea	Region_Map_Choice,a1
	move.l	_Ed_Window-PC(gl),a0
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	
	move.w	#320,d0
	move.w	_Tile_Width-PC(gl),d1
	move.w	_Tile_Amount-PC(gl),d2
	divu	d1,d0			; width/tilewidth (scale down)
	cmp.w	d2,d0			; if (d0 > amount) {
	blt.s	.tile_choice_width_ok	;     d0 = amount
	move.w	d2,d0			; }
.tile_choice_width_ok
	move.w	d0,d4
	mulu	d1,d0			; width*tilewidth (scale up)
	move.w	d0,rg_Width(a1)
	moveq.l	#0,d1
	move.w	wd_Width(a0),d1
;	move.l	Edit_Window_Width+4-PC(gl),d1	; centre ->
	sub.w	d0,d1
	lsr.w	#1,d1
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
	move.w	_Tile_Height-PC(gl),d1
	divu	d1,d0			; scale height = num blocks high
	cmp.w	d2,d0			; if (d0 > scaled amount)
	blt.s	.tile_choice_height_ok  ;     d0 = scaled amount
	move.w	d2,d0			; }
.tile_choice_height_ok
	mulu	d1,d0			; rescale height
	move.w	d0,rg_Height(a1)

	lea	Region_Map_Edit,a2
	move.w	rg_TopEdge(a2),d0	; place choice region directly
	add.w	rg_Height(a2),d0	; under map edit region
	btst	#FLAG0B_SLIDER_Y_ON,_Preference_Flags0-PC(gl)
	beq.s	.no_slider_for_y
	add.w	#MAPSCROLLERX_HEIGHT,d0
.no_slider_for_y
	move.w	d0,rg_TopEdge(a1)

	rts

Calculate_Tile_Win_Boundries:
	lea	Region_Map_Choice,a1
	clr.l	d0
	move.w	rg_Width(a1),d0		; width
	divu	_Tile_Width-PC(gl),d0
	move.w	_Tile_Amount-PC(gl),d1
	cmp.w	d1,d0
	bls.s	.1
	move.w	d1,d0
.1
	move.w	d0,_Tile_Win_Width-PC(gl)
	clr.l	d0
	move.w	rg_Height(a1),d0		; height
	divu	_Tile_Height-PC(gl),d0
	move.w	d0,_Tile_Win_Height-PC(gl)
	rts

Calculate_Map_Edit_Boundries:
	move.w	_Map_Left-PC(gl),d0
	move.w	d0,_Screen_Min_X-PC(gl)
	add.w	_Map_Edit_Width-PC(gl),d0
	sub.w	#1,d0
	move.w	d0,_Screen_Max_X-PC(gl)

	move.w	_Map_Top-PC(gl),d0
	move.w	d0,_Screen_Min_Y-PC(gl)
	add.w	_Map_Edit_Height-PC(gl),d0
	sub.w	#1,d0
	move.w	d0,_Screen_Max_Y-PC(gl)
	rts


;Display_Tile_List:
;	moveq.l	#0,d0			; srce x
;	move.w	#0,d1			; srce y
;	move.w	Region_Map_Choice+2,d2	; dest x
;	move.w	Region_Map_Choice+4,d3	; dest y
;	move.w	_Tile_Width,d4		; width
;	move.w	_Tile_Height,d5		; height
;	lea	_Tile_BitMap,a0		; srce bm
;	move.l	_Ed_RastPort,a1
;	move.l	rp_BitMap(a1),a1	; dest bm
;	move.l	a1,a2			; temp
;	move.w	_Tile_Win_Height,d7
;	bra.s	.display_height_pass
;.display_height
;	push	d2
;	move.w	_Tile_Win_Width,d6
;	bra.s	.display_width_pass
;.display_width
;	push	d6-d7
;	moveq.l	#$CC,d6			; minterm
;	moveq.l	#$FF,d7			; mask
;	jsr	_BltBitMap
;	add.w	d5,d1			; add to srce y
;	add.w	d4,d2			; add width to dest x
;	pop	d6-d7
;.display_width_pass
;	dbra	d6,.display_width
;	pop	d2
;	add.w	d5,d3
;.display_height_pass
;	dbra	d7,.display_height
;	
;	rts

_Display_Tile_List_2:
	move.w	_Tile_Edit-PC(gl),d0
	move.w	_Tile_Left-PC(gl),d1
	sub.w	d1,d0
	bmi.s	.tile_before_window
	beq.s	.tile_in_window
	move.w	Region_Map_Choice+6,d2
	divu	_Tile_Width-PC(gl),d2
	cmp.w	d2,d0
	blt.s	.tile_in_window		; if left-tile >= 0 and <= win_width then tile is already displayed
.tile_after_window	
	sub.w	d2,d0
	addq.w	#1,d0
;	move.w	d0,_Tile_Left-PC(gl)		; if left-tile  > 0 then tile is after display
;	bra.s	.tile_in_window
.tile_before_window
	add.w	d1,d0
	move.w	d0,_Tile_Left-PC(gl)
.tile_in_window

	moveq.l	#0,d0			; srce x
	move.w	_Tile_Left-PC(gl),d1		; srce y
	move.w	Region_Map_Choice+2,d2	; dest x
	move.w	Region_Map_Choice+4,d3	; dest y
	move.w	_Tile_Width-PC(gl),d4		; width
	move.w	_Tile_Height-PC(gl),d5		; height
	mulu	d5,d1	
	lea	_Tile_BitMap-PC(gl),a0		; srce bm
	move.l	_Ed_RastPort-PC(gl),a1
	move.l	rp_BitMap(a1),a1	; dest bm
	move.l	a1,a2			; temp
	move.w	_Tile_Amount-PC(gl),d7
	move.w	Region_Map_Choice+6,d6
	ext.l	d6
	divu	d4,d6

	cmp.w	d6,d7
	bls.s	.amount_smaller
	move.w	d6,d7
.amount_smaller
	
	bra.s	.2
.1
	push	d7
	moveq.l	#$CC,d6			; minterm
	moveq.l	#$FF,d7			; mask
	jsr	_BltBitMap
	add.w	d5,d1
	add.w	d4,d2
	pop	d7
.2
	dbra	d7,.1

	rts

; handles the main part of the Map Editor
dbg50:
Handle_Map_Ed_Messages:
	move.w	#0,_Quit-PC(gl)		; exit signal
.wait_for_message
	
	call	_Collect_WorkWindow_SigBits	; d0 -> sigbits
	move.l	_Ed_UserPort-PC(gl),a0
	call	_Get_Window_SigBit
	call	_Wait_Sig

	push	d0

;.get_next_work_message

.try_work_message
.get_next_work_message
	moveq.l	#0,d0
	call	_Collect_WorkWindow_SigBits	; d0 -> sigbits
	pull	d1
	and.l	d1,d0
	tst.l	d0
	beq.s	.no_work_message	
	call	_Retrieve_Ports_Using_SigBit
	tst.l	d0
	beq.s	.no_work_message
	move.l	d0,_Wk_UserPort
	move.l	d1,_Wk_RastPort
	move.l	d2,_Wk_Window

	move.l	_Wk_UserPort,a0			; get message from work screen
	cmp.l	#0,a0
	beq.s	.no_work_message
	call	_GetMsg				; get the message
	tst.l	d0				; see if there's any message from this window
	beq.s	.no_work_message
	call	_Copy_Intuition_Message		; yes there is so copy message
	move.l	d0,a1				; and
	call	_ReplyMsg			; reply as quickley as possible
	lea	_Map_Work_Message_List,a0
	jsr	_Execute_Intuition_Message	; sort out work message
	bra.s	.get_next_work_message
.no_work_message


.try_edit_message
	moveq.l	#0,d0
	move.l	_Ed_UserPort,a0		; check editor window for a message
	call	_Get_Window_SigBit
	pull	d1
	and.l	d1,d0
	tst.l	d0
	beq.s	.no_edit_message

.get_next_edit_message
;	move.w	#$FF0,$DFF180
	move.l	_Ed_UserPort,a0		; check editor window for a message
	call	_GT_GetIMsg			; get message
	tst.l	d0				; is there any messages ?
	beq.s	.no_edit_message
	call	_Copy_Intuition_Message		; yep so copy it and
	move.l	d0,a1
	call	_GT_ReplyIMsg			; reply as quickley as possible
	lea	_Map_Edit_Message_List,a0
	call	_Execute_Intuition_Message	; now execute routine if valid message
	bra.s	.get_next_edit_message		; go check for another message
.no_edit_message	
	pop	d0
	tst.w	_Quit				; has user selected quit?
	bne.s	.handle_end			; yep so exit
	btst	#7,$BFE001			; just in case something doesn't work properley
	beq.s	.handle_end
	bra	.wait_for_message		; go around again
.handle_end
	rts

_GadgetDown_Routine:	DC.L	0,0	; for the gadget down routine, pretty primitive :)

_Map_Work_Message_List:				; list of IDCMP's &  routines
	DC.L	IDCMP_MOUSEMOVE,_Handle_Map_Work_MouseMove
	DC.L	IDCMP_GADGETDOWN,_Handle_Map_Work_GadgetDown
	DC.L	IDCMP_GADGETUP,_Handle_Map_Work_GadgetUp
	DC.L	IDCMP_INTUITICKS,_Handle_Map_Work_IntuiTicks
	DC.L	-1

_Map_Work_GadgetUp_List:			; list of GADGETUP ID's & routines

	SetGadgetID	BUTTON_ID_OPENMAPSHAPES,_Work_Open_Map_Shapes
	SetGadgetID	BUTTON_ID_CLOSEMAPSHAPES,_Work_Close_Map_Shapes

	SetGadgetID	BUTTON_ID_OPENMAPSHAPESFILE,_Work_Open_Map_ShapesFile
	SetGadgetID	BUTTON_ID_CLOSEMAPSHAPESFILE,_Work_Close_Map_ShapesFile

	SetGadgetID	BUTTON_ID_OPENMAPFILE,_Work_Open_Map_File
	SetGadgetID	BUTTON_ID_CLOSEMAPFILE,_Work_Close_Map_File

	SetGadgetID	BUTTON_ID_OPENMAPCONFIG,_Work_Open_Map_Configuration
	SetGadgetID	BUTTON_ID_CLOSEMAPCONFIG,_Work_Close_Map_Configuration


.map_work_tools_start
	SetGadgetID	BUTTON_ID_SCRIBBLE,_Map_Work_Scribble
	SetGadgetID	BUTTON_ID_LINE,_Map_Work_Line
	SetGadgetID	BUTTON_ID_RECTANGLE,_Map_Work_Rectangle
	SetGadgetID	BUTTON_ID_CUT,_Map_Work_Cut
.map_work_tools_end
NUMBER_WORK_TOOLS	equ	(.map_work_tools_end-.map_work_tools_start)/6


;
;;;- normal buttons found on each screen (give or take a few)
;
;	SetGadgetID	BUTTON_ID_TILE,_Work_Goto_Map_To_Tile
;	SetGadgetID	BUTTON_ID_ANIM,_Work_Goto_Map_To_Anim
;	SetGadgetID	BUTTON_ID_COPPER,_Work_Goto_Map_To_Copper
;	SetGadgetID	BUTTON_ID_FILE,_Work_Goto_Map_To_File
;
;	SetGadgetID	BUTTON_ID_PREFERENCES,_Work_Goto_Map_To_Prefs
;
;;	SetGadgetID	BUTTON_ID_MAPCHG,_Map_Work_Change_Map
;
;;
;;;	the next two (2) are in the gadgetdown list
;;
;
;;;	SetGadgetID	BUTTON_ID_TILEPREV,_Map_Edit_Prev_Tile
;;;	SetGadgetID	BUTTON_ID_TILENEXT,_Map_Edit_Next_Tile
;
;	SetGadgetID	STRING_ID_CURRTILE,_Map_Edit_FromStringSet_Tile_OR_Shape
;
;	SetGadgetID	BUTTON_ID_MAPSETNEXT,_Map_Work_Next_MapSet
;	SetGadgetID	BUTTON_ID_MAPSETPREV,_Map_Work_Prev_MapSet
;
;	SetGadgetID	BUTTON_ID_TILECHG,_Map_Work_Change_Tile
;
;	SetGadgetID	BUTTON_ID_PALETTECHG,_Map_Work_Change_Palette
;
;
;	SetGadgetID	STRING_ID_MAPNAME,_Map_Work_Name_Change
;
;	SetGadgetID	BUTTON_ID_ZOOM,_Map_Work_Zoom
;
;;;- tools for editing maps
;
;.map_work_tools_start
;	SetGadgetID	BUTTON_ID_SCRIBBLE,_Map_Work_Scribble
;	SetGadgetID	BUTTON_ID_LINE,_Map_Work_Line
;	SetGadgetID	BUTTON_ID_RECTANGLE,_Map_Work_Rectangle
;	SetGadgetID	BUTTON_ID_CUT,_Map_Work_Cut
;.map_work_tools_end
;NUMBER_WORK_TOOLS	equ	(.map_work_tools_end-.map_work_tools_start)/6
;
;;;- buttons for defining the map size (width,height)
;
;	SetGadgetID	BUTTON_ID_CONFIGURATION,_Map_Work_Define_Setup
;	SetGadgetID	BUTTON_ID_DEFINEPREV,_Define_Map_Work_Prev_MapSet
;	SetGadgetID	BUTTON_ID_DEFINENEXT,_Define_Map_Work_Next_MapSet
;
;	SetGadgetID	BUTTON_ID_DEFINE1TICK,_Map_Work_Define_Retain
;
;	SetGadgetID	BUTTON_ID_DEFINE1MX,_Map_Work_Define_MX1
;	SetGadgetID	BUTTON_ID_DEFINE2MX,_Map_Work_Define_MX2
;	SetGadgetID	BUTTON_ID_DEFINE3MX,_Map_Work_Define_MX3
;
;	SetGadgetID	STRING_ID_DEFINE1STR,_Map_Work_Define_Width_SetFromString
;	SetGadgetID	STRING_ID_DEFINE2STR,_Map_Work_Define_Height_SetFromString
;
;;	SetGadgetID	STRING_ID_MAPNAME,_Map_Work_Define_String_Test
;
;	SetGadgetID	BUTTON_ID_DEFINEOK,_Map_Work_Define_Ok
;	SetGadgetID	BUTTON_ID_DEFINEAPPLY,_Map_Work_Define_Apply
;	SetGadgetID	BUTTON_ID_DEFINECANCEL,_Map_Work_Define_Cancel
;
;;;- buttons for defining shapes
;
;	SetGadgetID	BUTTON_ID_SHAPES,_Map_Work_Shape_Setup
;	SetGadgetID	BUTTON_ID_SHAPEPREV,_Map_Edit_Prev_Tile
;	SetGadgetID	BUTTON_ID_SHAPENEXT,_Map_Edit_Next_Tile
;	SetGadgetID	BUTTON_ID_SHAPEPAINT,_Map_Work_Shape_Paint
;	SetGadgetID	BUTTON_ID_SHAPEPICKUP,_Map_Work_Shape_Pickup
;;	SetGadgetID	BUTTON_ID_SHAPEERASE,0
;	SetGadgetID	BUTTON_ID_SHAPEOK,_Map_Work_Shape_ShutDown
;	SetGadgetID	BUTTON_ID_SHAPECANCEL,_Map_Work_Shape_ShutDown
	DC.W		-1

;;- the gadget list for the gadget down and hold routine
;;- if a gadget if here then it can be pressed once and let go - will jsr routine once
;;- if a gadget is held down - will jsr the routine once wait a length of time
;;-                            and then jsr the routine continuously (approx 10 times a second)

_Map_Work_GadgetDown_List:
	SetGadgetID	BUTTON_ID_DEFINE1DEC,_Map_Work_Define_Width_Dec
	SetGadgetID	BUTTON_ID_DEFINE1INC,_Map_Work_Define_Width_Inc
	SetGadgetID	BUTTON_ID_DEFINE2DEC,_Map_Work_Define_Height_Dec
	SetGadgetID	BUTTON_ID_DEFINE2INC,_Map_Work_Define_Height_Inc

	SetGadgetID	BUTTON_ID_TILEPREV,_Map_Edit_Prev_Tile
	SetGadgetID	BUTTON_ID_TILENEXT,_Map_Edit_Next_Tile

	DC.W		-1


_Map_Work_Name_Change:
	bsr	_Calculate_Map_Node
	move.l	map_Name(a0),a1
	move.l	#STRING_ID_MAPNAME,d0
	bra.s	_Work_Name_Change
_Tile_Work_Name_Change:
	bsr	_Calculate_Tile_Node
	move.l	tile_Name(a0),a1
	move.l	#STRING_ID_TILENAME,d0
	bra.s	_Work_Name_Change
_Palette_Work_Name_Change:
	bsr	_Calculate_Palette_Node
	move.l	palette_Name(a0),a1
	move.l	#STRING_ID_PALETTENAME,d0
	bra.s	_Work_Name_Change

	nop
_Work_Name_Change:

	push	d0/a1
	jsr	_Get_WorkGadgetStringBuffer
	pull	d0/a1
	jsr	_StrCpy
	pop	d0/a1

	moveq.l	#1,d1
	move.l	_Wk_Window-PC(gl),a0
	jsr	_Refresh_Num_Gadgets
	rts


;;- routine to change to the previous map that user has in mem
dbg07:
_Define_Map_Work_Prev_MapSet:
	call	_Map_Work_Prev_MapSet
	call	_Map_Work_Define_Setup_Setup
	call	_Work_Global_Setup_Last
	rts

_Define_Map_Work_Next_MapSet:
	call	_Map_Work_Next_MapSet
	call	_Map_Work_Define_Setup_Setup
	call	_Work_Global_Setup_Last
	rts

;;- routine to change to the next map that user has in mem OR create a new map

_Map_Work_Prev_MapSet:
.minus_map
	move.w	_Map_Set-PC(gl),d0
	move.w	#0,d1	; min set
	cmp.w	d1,d0
	beq.s	.ok_minus
	subq.w	#1,d0
	cmp.w	d1,d0
	bgt.s	.minus_ok
	move.w	d1,d0
.minus_ok
	push	d0
	jsr	Write_Map_Info
	jsr	Write_Tile_Info
	pop	d0
	move.w	d0,_Map_Set-PC(gl)
	jsr	_Check_Map_Edit_Screen
.ok_minus
	rts


_Map_Work_Next_MapSet:
.plus_map
	move.w	_Map_Set-PC(gl),d0
	move.w	#MAX_MAPS,d1
	cmp.w	d1,d0
	beq.s	.ok_plus
	addq.w	#1,d0
	cmp.w	d1,d0
	blt.s	.plus_ok
	move.w	d1,d0
.plus_ok
	push	d0
	jsr	_Count_Map_Nodes		; count nodes
	move.l	d0,d1
	pop	d0
	cmp.w	d1,d0
	blt.s	.not_new_map
	lea	_Text_FileType_Map,a0
	lea	_Text_Create_New,a1
	push	d0
	jsr	_Ask_Request
	move.l	d0,d1
	pop	d0
	tst.l	d1
	beq.s	.ok_plus
.not_new_map
	push	d0
	jsr	Write_Map_Info
	jsr	Write_Tile_Info
	pop	d0
	move.w	d0,_Map_Set-PC(gl)
	jsr	_Check_Map_Edit_Screen
.ok_plus
	rts

;_Map_Work_Change_Map:
;	cmp.w	#7,d1
;	bhi.s	.minus_map
;	jsr	_Map_Work_Next_Map
;	bra.s	.ok_map
;.minus_map
;	jsr	_Map_Work_Prev_Map
;.ok_map
;	rts

;;- for use by prev map & next map for closing down edit screen and
;;- reopening it up with diffrent map/tile/palette/shape/anim/copper set


;;- changes the tile set used in this map to prev or next, if no next then creates a new one

_Map_Work_Change_Tile:
	cmp.w	#7,d1	; check to see if it was the upper or lower part of the button that was pressed
	bhi.s	.minus_tile

.plus_tile			; upper part of button was selected +

	move.w	_Tile_Set-PC(gl),d0
	move.w	#MAX_TILES,d1
	cmp.w	d1,d0
	beq.s	.ok_plus
	addq.w	#1,d0
	cmp.w	d1,d0
	blt.s	.plus_ok
	move.w	d1,d0
.plus_ok
	push	d0
	jsr	Write_Tile_Info
	pop	d0
	addq.w	#1,_Palette_Set-PC(gl)	; new palette for new tiles
	move.w	d0,_Tile_Set-PC(gl)
	jsr	Write_Map_Info
	jsr	Read_Map_Info
	jsr	Read_Tile_Info
	jsr	_Check_Map_Edit_Screen
	
.ok_plus
	bra.s	.ok_tile
.minus_tile				; lower part of button was selected -
	move.w	_Tile_Set-PC(gl),d0
	move.w	#0,d1
	cmp.w	d1,d0
	beq.s	.ok_minus
	subq.w	#1,d0
	cmp.w	d1,d0
	bgt.s	.minus_ok
	move.w	d1,d0
.minus_ok
	push	d0
	jsr	Write_Tile_Info
	pop	d0
	subq.w	#1,_Palette_Set-PC(gl)		; who knows???
	move.w	d0,_Tile_Set-PC(gl)
	jsr	Write_Map_Info
	jsr	_Check_Map_Edit_Screen
.ok_minus	
.ok_tile
	rts

;;- changes the palette set used in this map to prev or next, if no next then creates a new one
dbg76:
_Map_Work_Change_Palette:
	cmp.w	#7,d1	; check to see if it was the upper or lower part of the button that was pressed
	bhi.s	.minus_tile

.plus_tile			; upper part was selected of button was selected +
	move.w	_Palette_Set-PC(gl),d0

	move.w	#MAX_PALETTES,d1
	cmp.w	d1,d0
	beq.s	.ok_plus
	addq.w	#1,d0
	cmp.w	d1,d0
	blt.s	.plus_ok
	move.w	d1,d0
.plus_ok
	move.w	d0,_Palette_Set-PC(gl)
	jsr	Write_Tile_Info
	jsr	Read_Tile_Info
	jsr	_Check_Map_Edit_Screen
	
.ok_plus
	bra.s	.ok_tile
.minus_tile				; lower part of button was selected -
	move.w	_Palette_Set-PC(gl),d0
	move.w	#0,d1
	cmp.w	d1,d0
	beq.s	.ok_minus
	subq.w	#1,d0
	cmp.w	d1,d0
	bgt.s	.minus_ok
	move.w	d1,d0
.minus_ok
	move.w	d0,_Palette_Set-PC(gl)
	jsr	Write_Tile_Info
	jsr	Read_Tile_Info
	jsr	_Check_Map_Edit_Screen
.ok_minus	
.ok_tile
	rts

;****************************************************************

;;- handler for gadgetup messages

_Handle_Map_Work_GadgetUp:
;	move.w	#$00f,$DFF180
	lea	_Map_Work_GadgetUp_List,a0
	jsr	_Execute_Gadget_List
	rts

;;- handler for gadget down messages

_Handle_Map_Work_GadgetDown:
;	move.w	#$0f0,$DFF180
	lea	_Map_Work_GadgetDown_List,a0
	bsr	_Handle_Work_GadgetDown
	rts

_Handle_IntuiTicks_GadgetDown:
	push	d0-d7/a0-a6
	lea	_GadgetDown_Routine,a1
	clr.l	d0
	move.w	4(a1),d0		; get gadget id
	move.l	_Wk_Window-PC(gl),a0
	move.l	wd_FirstGadget(a0),a0
;	move.l	_ReActive_Gadgets,a0
	jsr	_Find_GadgetID
	move.w	gg_Flags(a0),d0
	andi.w	#GFLG_SELECTED,d0
	tst.w	d0
	beq.s	.no_gadget_down
	move.l	(a1),d0
	beq.s	.no_gadget_down
	move.w	6(a1),d1
	addq.w	#1,6(a1)	
	cmp.w	#6,6(a1)	; wait 1 second
	blt.s	.no_gadget_down
	move.l	d0,a0
;	move.l	a0,d0
;	beq.s	.no_gadget_down
	jsr	(a0)
.no_gadget_down
	pop	d0-d7/a0-a6
	rts

_Handle_Work_GadgetDown:

	moveq.l	#0,d0
	lea	_GadgetDown_Routine,a1
	move.l	d0,(a1)+
	move.l	d0,(a1)+
;	lea	_Map_Work_GadgetDown_List,a0
	jsr	_Execute_Gadget_List
	cmp.w	#-1,d0			; if end of list then no gadget down
	beq.s	.1
	move.l	d0,_GadgetDown_Routine
	move.w	d1,_GadgetDown_Routine+4
.1
	rts

;;- handler for mousemove messages

_Handle_Map_Work_MouseMove:
	move.l	_Wk_Window-PC(gl),a1
	move.w	wd_MouseX(a1),d0
	move.w	wd_MouseY(a1),d1
	tst.w	d1
	bpl.s	.not_on_edit_screen
	move.l	_Ed_Window-PC(gl),a0
	jsr	_ActivateWindow
.not_on_edit_screen

;	lea	_Map_Region_Coordinates,a0
;	jsr	_Check_Regions
	
	rts

_Handle_Map_Work_IntuiTicks:
	jsr	_Handle_IntuiTicks_Text
	jsr	_Handle_Map_Work_MouseMove
	rts

 BITDEF	FLG,ZOOM,0

;;- zoom out the map

;_Map_Work_Set_Zoom:
;	move.w	#BUTTON_ID_ZOOM,d0
;	move.w	#FLGB_ZOOM,d1
;	rts


_Map_Work_Zoom:
	move.w	_Zoom_Ed,d0
	not.w	d0
	andi.w	#FLGF_ZOOM,d0
	move.w	d0,_Zoom_Ed
;	jsr	_Map_Work_Set_Zoom
;	lea	_Zoom_Ed-PC(gl),a1
;	jsr	_Work_Window_Gadgets_Ptr
;	jsr	_Check_Out_Bits_And_Get_A1_Accordingly

	jsr	Close_Open_Edit_Screen

	rts

;_Map_Work_Zoom_Setup:
;	jsr	_Map_Work_Set_Zoom
;	lea	_Zoom_Ed-PC(gl),a1
;	jsr	_Work_Window_Gadgets_Ptr
;	jsr	_Check_Out_Bits_And_Set_A1_Accordingly
;	rts


;_Map_Work_Zoom:
;	move.w	_Zoom_Ed-PC(gl),d0
;	bchg	#0,d0
;	move.w	d0,_Zoom_Ed-PC(gl)
;
;	jsr	Close_Open_Edit_Screen
;
;;	jsr	Close_Edit_Screen_Window
;;	jsr	Open_Edit_Screen_Window
;;	move.l	_Wk_Screen-PC(gl),a0
;;	jsr	_ScreenToFront
;
;	rts


;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************


;
;;- define map characteristics eg height,width setup routine
;



 EVEN
dbgm10:
_Map_Work_Define_Setup_Setup:

;;- create all map define gadgets

;	lea	_ReActive_Gadgets,a0		; create map define control gadgets/buttons
;	move.l	a0,d0
;	lea	_Map_Work_Define_Gadget_List,a0
;	jsr	_Create_Work_Gadgets

;;- now draw screen

	move.l	_Wk_RastPort-PC(gl),_Global_RastPort-PC(gl)
	move.l	#24+300,d0
	moveq.l	#5,d1
	moveq.l	#2,d2
	moveq.l	#1,d3
	lea	_Text_Define_Map,a0
	jsr	_Display_Outline_Text

;	jsr	_Calculate_Map_Node
;	move.l	map_Name(a0),a0
;	lea	_StringBuffer2,a1
;	jsr	_StrToUpper
;	push	a1			; arg
;	pea	Text_Edit_Map_Name	; format
;	pea	_StringBuffer		; buffer
;	jsr	_SPrintf
;	lea	3*4(sp),sp
;	pea	_StringBuffer		; arg	
;	pea	Text_Edit_Define	; format
;	pea	_StringBuffer2		; buffer
;	jsr	_SPrintf
;	lea	3*4(sp),sp

;	lea	_StringBuffer2,a0
;	jsr	_TextLength
;	neg.w	d0
;	add.w	#279,d0
;	lsr.w	#1,d0
;	add.w	#24,d0
;	move.w	#000+004,d1
;	move.w	#1,d2
;	lea	_StringBuffer2,a0
;	jsr	_Display_String			; show "define" text

	jsr	_Calculate_Map_Node
	move.l	a0,a1
	move.w	#STRING_ID_DEFINE1STR,d0
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation
	move.w	map_Width(a1),d1
	jsr	_Write_Define_Numeric_Gadget_String
	
	move.w	#STRING_ID_DEFINE2STR,d0
	move.l	#GACT_STRINGCENTER!GACT_LONGINT,d1
	jsr	_Set_Work_Gadget_Activation
	move.w	map_Height(a1),d1
	jsr	_Write_Define_Numeric_Gadget_String

	lea	_Map_Values,a0
	move.w	map_Width(a1),(0*pdv_SIZEOF)+pdv_value(a0)
	move.w	map_Height(a1),(1*pdv_SIZEOF)+pdv_value(a0)
	moveq.l	#0,d0
	move.b	map_UnitSize(a1),d0
	asl.w	#8,d0
	move.b	map_Format(a1),d0
	bset	#FLGB_RETAIN,d0
	move.w	d0,(2*pdv_SIZEOF)+pdv_value(a0)
	move.w	d0,_Tile_Format_Value

	jsr	_Map_Work_Define_Retain_Setup
	jsr	_Map_Work_Define_MX_Setup

;	jsr	_Tile_Work_Define_Tick_Setup
;	jsr	_Tile_Work_Define_MX_Setup

	move.w	#CHGF_MAPSET,d0
	or.w	d0,_Something_Changed-PC(gl)
	move.w	d0,_Something_Mask-PC(gl)
	rts

_Map_Work_Define_Setup:
	tst.l	_Active_Gadgets
	bne	.end_define_setup
	lea	_Map_Work_Define_Gadget_List,a0
	jsr	_Work_Global_Setup_First
	jsr	_Map_Work_Define_Setup_Setup
	jsr	_Work_Global_Setup_Last
.end_define_setup
	rts

;;
;

_Set_Work_Gadget_Activation:	; d0 - gadget_id, d1 - activation
	push	d0-d1/a0-a1
;	push	d0-d1
;	move.l	d2,d0
;	call	_GetWindowHandle
;	move.l	d0,d2
;	pop	d0-d1
;	tst.l	d2
;	beq.s	.no_gadget_found
;	move.l	d2,a0
	
	move.l	_Wk_Window,a0
	move.l	wd_FirstGadget(a0),a1
	exg.l	a0,a1
	jsr	_Find_GadgetID
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.no_gadget_found
	or.w	d1,gg_Activation(a0)
	moveq.l	#1,d0
	jsr	_RefreshGList
.no_gadget_found
	pop	d0-d1/a0-a1
	rts

_Refresh_Define_Numeric_String:	; d0 - gadget_id
	push	d0
	moveq.l	#0,d1
	move.w	pdv_value(a0),d1
;	lea	_Text_Format_0,a0
	jsr	_Write_Define_Numeric_Gadget_String
	pop	d0
	moveq.l	#1,d1
	move.l	_Wk_Window-PC(gl),a0
	jsr	_Refresh_Num_Gadgets
	rts


_Refresh_Num_Gadgets:	; d0 - gadget id, d1 - number of gadgets, a0 - window
	push	d0-d1/a0-a1
	move.l	wd_FirstGadget(a0),a1
	exg.l	a0,a1
	jsr	_Find_GadgetID
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.no_gadget_found
	move.l	d1,d0
	jsr	_RefreshGList
.no_gadget_found
	pop	d0-d1/a0-a1
	rts

_SetFromString_Define:	
	push	d0
	jsr	_Get_WorkGadgetStringInteger	; get value from string longint gad
	move.w	pdv_min(a0),d1
	jsr	_Find_Greater			; make sure in range specified
	move.w	pdv_max(a0),d1
	jsr	_Find_Greater
	move.w	d1,pdv_value(a0)
	pop	d0
	jsr	_Refresh_Define_Numeric_String
	rts	

;;
;

;
;;	format the value in d1 to be a "%ld" and the write it to the gadget id's string buffer
;

_Write_Define_Numeric_Gadget_String:	; d0 - gadget id, d1 - value
	push	a0
	lea	.number_format_string,a0
	jsr	_Write_Gadget_String
	pop	a0
	rts
.number_format_string	DC.B	"%ld",0

;
;;	all up to here goes with "_Write_Define_Numeric_Gadget_String"
;

;
;;

_Write_Gadget_String:	; d0 - gadget id, d1 - value, a0 - format string
	push	a0-a1
	push	a0
	jsr	_Get_WorkGadgetStringBuffer
	pop	a1
	push	d1				; value
	push	a1				; format
	push	a0				; buffer
	jsr	_SPrintf
	lea	(3*4)(sp),sp	
	pop	a0-a1
	rts

_FontHeight:
	push	a0
	move.l	_Global_RastPort-PC(gl),a0
	move.w	rp_TxHeight(a0),d0
	pop	a0
	rts

_Re_Eval_d1:	; d1 - value.w
	cmp.w	#5,d1
	blo.s	.dont_mod_yet
	divu	#5,d1
	bra.s	.only_1
.dont_mod_yet
	move.w	#1,d1
.only_1
	rts

_Increase_Work_Define_Value:	; a0 -> pdv
	push	d0
	move.l	_Wk_RastPort-PC(gl),_Global_RastPort-PC(gl)
	move.w	pdv_value(a0),d0
	move.w	pdv_max(a0),d2
	jsr	_Re_Eval_d1
	add.w	d1,d0
	cmp.w	d2,d0
	ble.s	.value_ok
	move.w	d2,d0
.value_ok
	move.w	d0,pdv_value(a0)
	pop	d0
	jsr	_Refresh_Define_Numeric_String
.inc_end
	rts

_Decrease_Work_Define_Value:	; a0 -> pdv
	push	d0
	move.l	_Wk_RastPort-PC(gl),_Global_RastPort-PC(gl)
	move.w	pdv_value(a0),d0
	move.w	pdv_min(a0),d2
	jsr	_Re_Eval_d1
	sub.w	d1,d0
	cmp.w	d2,d0
	bge.s	.value_ok
	move.w	d2,d0
.value_ok
	move.w	d0,pdv_value(a0)
	pop	d0
	jsr	_Refresh_Define_Numeric_String
.dec_end
	rts


_Map_Values:
_Map_Width_Value:	DC.W	0,20,1024,0
_Map_Height_Value:	DC.W	0,12,1024,0
_Map_Format_Value:	DC.W	0,$0000,$FFFF,0




_Map_Work_Define_Width_Dec:
	move.w	#STRING_ID_DEFINE1STR,d0
	lea	_Map_Width_Value,a0
	bra.s	_Map_Decrease_Define
_Map_Work_Define_Height_Dec:
	move.w	#STRING_ID_DEFINE2STR,d0
	lea	_Map_Height_Value,a0

_Map_Decrease_Define:
	jsr	_Decrease_Work_Define_Value
	rts

_Map_Work_Define_Width_Inc:
	move.w	#STRING_ID_DEFINE1STR,d0
	lea	_Map_Width_Value,a0
	bra.s	_Map_Increase_Define
_Map_Work_Define_Height_Inc:
	move.w	#STRING_ID_DEFINE2STR,d0
	lea	_Map_Height_Value,a0
_Map_Increase_Define:
	jsr	_Increase_Work_Define_Value
	rts

dbgm1:
_Map_Work_Define_Width_SetFromString:
	move.w	#STRING_ID_DEFINE1STR,d0
	lea	_Map_Width_Value,a0
	bra.s	_Map_SetFromString_Define
_Map_Work_Define_Height_SetFromString:
	move.w	#STRING_ID_DEFINE2STR,d0
	lea	_Map_Height_Value,a0
_Map_SetFromString_Define:	
	jsr	_SetFromString_Define
	rts




_Map_Work_Define_Retain_Setup:
	jsr	_Tile_Work_Define_Set_Retain
	bra	_Map_Work_Define_Bit_Manip_Set
_Map_Work_Define_Retain:
	jsr	_Tile_Work_Define_Set_Retain
	bra	_Map_Work_Define_Bit_Manip_Get

_Map_Work_Define_Bit_Manip_Get:
	jsr	_Work_Window_Gadgets_Ptr
	lea	_Map_Format_Value,a1
	bra	_Check_Out_Bits_And_Get_A1_Accordingly

_Map_Work_Define_Bit_Manip_Set:
	jsr	_Work_Window_Gadgets_Ptr
	lea	_Map_Format_Value,a1
	bra	_Check_Out_Bits_And_Set_A1_Accordingly


_Map_Work_Define_MX_Setup:
;	move.w	#BUTTON_ID_DEFINE1MX,d1
	move.w	_Map_Format_Value,d1
	andi.w	#FLGF_UNITB0|FLGF_UNITB1,d1
	asr.w	#1,d1
	add.w	#BUTTON_ID_DEFINE1MX,d1
	bra	_Map_Work_Define_MX_Do
_Map_Work_Define_MX1:
	move.w	#BUTTON_ID_DEFINE1MX,d1
	bra	_Map_Work_Define_MX_Do
_Map_Work_Define_MX2:
	move.w	#BUTTON_ID_DEFINE2MX,d1
	bra	_Map_Work_Define_MX_Do
_Map_Work_Define_MX3:
	move.w	#BUTTON_ID_DEFINE3MX,d1
	bra	_Map_Work_Define_MX_Do

_Map_Work_Define_MX_Do:
	push	d1
	sub.w	#BUTTON_ID_DEFINE1MX,d1
	move.w	_Map_Format_Value,d0		; get current flags
	andi.w	#~(FLGF_UNITB0|FLGF_UNITB1),d0	; cut out not format bits
	or.w	d1,d0
	move.w	d0,_Map_Format_Value
	pop	d1	
	move.w	#BUTTON_ID_DEFINE1MX,d0
	move.w	#3,d2
	jsr	_Tile_Work_Define_MX_Control
	rts


_Map_Work_Define_Cancel:
	jsr	_Map_Work_Define_ShutDown
	rts
dbg06:
_Map_Work_Define_Apply:
	lea	_Map_Values,a0
	
	move.w	_Map_Set,d0
	lea	_Map_Width_Value,a0
	move.w	pdv_value(a0),d1
	lea	_Map_Height_Value,a0
	move.w	pdv_value(a0),d2
	move.w	_Map_Format_Value,d3
	jsr	_Replace_Map_Node

	jsr	_Check_Map_Edit_Screen

	
	rts

_Map_Work_Define_Ok:
	jsr	_Map_Work_Define_Apply
	jsr	_Map_Work_Define_ShutDown
	rts

_Map_Work_Define_ShutDown:
	jsr	_Work_Global_ShutDown
	jsr	_Map_Work_Display
	rts


;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
;****************************************************************
dbg04:
_Display_Formated_Field:	; d0 - x, d1 - y, d2 - col, d3 - number, d4 - field width
	push	d0-d4
	push	d3
	pea	_Define_Work_Format
	pea	_Define_Work_String
	jsr	_SPrintf
	lea	3*4(sp),sp
	lea	_Define_Work_String,a0
	jsr	_TextLength
	move.w	d0,d5
	pull	d0-d4
	sub.w	d5,d4
	lsr.w	#1,d4
	add.w	d4,d0
	jsr	_Display_String
	pop	d0-d4
	rts

_Define_Work_String:	DC.B	"00000000",0
_Define_Work_Format:	DC.B	"%ld",0
 EVEN


Refresh_Work_Gadgets:
;	move.l	_Wk_Gadgets-PC(gl),a0
	jsr	_Count_Gadgets
	move.l	_Wk_Window-PC(gl),a1
	jsr	_RefreshGList
	rts

_Map_Work_Shape_Setup:
	tst.l	_Active_Gadgets-PC(gl)
	bne	.end_shape_setup

	move.l	_Wk_RastPort-PC(gl),_Global_RastPort-PC(gl)

	coord.w	254,000,194,53
	jsr	_Draw_Raised_Hires_Box		; draw box

	coord.w	448,000,158,53
	jsr	_Clear_Raised_Hires_Box		; draw box

	move.w	#448+040,d0			; shapes text
	move.w	#000+004,d1
	move.w	#2,d2
	move.w	#1,d3
	lea	_Text_Edit_Shapes,a0
	jsr	_Display_Outline_Text

	
	move.w	#BUTTON_ID_SHAPES,d0		; disable activate button
	move.l	_Wk_Gadgets-PC(gl),a0
	jsr	_Find_GadgetID
	jsr	_Disable_Gadget

	lea	_Active_Gadgets-PC(gl),a0
	move.l	a0,d0
	lea	_Map_Work_Shape_Gadget_List,a0
	jsr	_Create_Work_Gadgets		; create shape control gadgets/buttons

	move.l	_Active_Gadgets-PC(gl),a0
	jsr	_Count_Gadgets
	move.l	d0,d1			; # to add
	move.l	_Wk_Gadgets-PC(gl),a0
	jsr	_Count_Gadgets		; to end of list
	move.l	_Wk_Window-PC(gl),a0
	move.l	_Active_Gadgets-PC(gl),a1
	jsr	_AddGList

	move.l	_Wk_Gadgets-PC(gl),a0
	jsr	Refresh_Work_Gadgets

	bclr	#SHPB_GET,_Shape_Ed	; change shape get flag to off
	bset	#SHPB_PUT,_Shape_Ed	; change shape put flag to on
	move.b	#1,_Object_Type-PC(gl)

	or.w	#CHGF_SHAPE,_Something_Changed-PC(gl)

.end_shape_setup
	rts


BLOCK_OBJECT		EQU	0
SHAPE_OBJECT		EQU	1
SHAPE_COUNT_SIZE	EQU	512

;;- paint shape on screen by selecting the blocks to include in shape

dbg34:
_Map_Work_Shape_Paint:

;	move.w	_Shape_Set,d0
;	move.l	#SHAPE_MEM_SIZE,d3
;	move.w	#0,d4			; not cut
;	jsr	_Remove_Shape_Node

	move.w	_Shape_Edit-PC(gl),d0
	moveq.l	#0,d1			; width
	moveq.l	#0,d2			; height
	move.l	#SHAPE_COUNT_SIZE,d3	; count
	move.w	#0,d4			; flags	(not cut)
	jsr	_Replace_Shape_Node

	jsr	_Calculate_Shape_Node
	move.l	shape_Location(a0),a1
	move.w	#$FFFF,(a1)

	bset	#SHPB_GET,_Shape_Ed-PC(gl)	; change shape get flag to on
	bclr	#SHPB_PUT,_Shape_Ed-PC(gl)	; change shape put flag to off
	move.b	#SHAPE_OBJECT,_Object_Type-PC(gl)

	rts

_Map_Work_Shape_Pickup:

	clr.l	d0
	clr.l	d1
	clr.l	d2
	move.w	_Map_Edit_X-PC(gl),d0
	move.w	_Map_Edit_Y-PC(gl),d1

	btst	#SHPB_GET,_Shape_Ed-PC(gl)
	beq	.not_get_shape

	push	d0-d1
	jsr	_Calculate_Shape
	pop	d0-d1
	bclr	#SHPB_GET,_Shape_Ed-PC(gl)	; change shape get flag to off
	bset	#SHPB_PUT,_Shape_Ed-PC(gl)	; change shape flag to put
	jsr	_Restore_Shape		; inverted screen shape to normal

	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure

.not_get_shape

	rts

_Map_Work_Shape_ShutDown:

	move.w	#BUTTON_ID_SHAPES,d0		; enable activate button
	move.l	_Wk_Gadgets-PC(gl),a0
	jsr	_Find_GadgetID
	jsr	_Enable_Gadget

	move.l	_Active_Gadgets-PC(gl),a0
	jsr	_Count_Gadgets
	move.l	a0,a1
	move.l	_Wk_Window-PC(gl),a0
	jsr	_RemoveGList			; remove shape control gadgets/buttons

;	move.l	_Wk_Window-PC(gl),a0
;	move.l	_Shape_Gadgets,a1
;	move.l	#-1,d0
;	jsr	_RemoveGList			; remove shape control gadgets/buttons

	move.l	_Active_Gadgets-PC(gl),a0
	jsr	_Remove_Work_Gadgets

	move.l	_Wk_RastPort-PC(gl),_Global_RastPort-PC(gl)

	coord.w	446,000,160,53
	jsr	_Clear_Box		; draw box

	coord.w	254,000,352,53
	jsr	_Draw_Raised_Hires_Box		; draw box

;	coord.w	606,000,034,53
;	jsr	_Draw_Raised_Hires_Box		; draw box

	move.l	_Wk_Gadgets,a0
	jsr	Refresh_Work_Gadgets


	bclr	#SHPB_GET,_Shape_Ed-PC(gl)	; change shape get flag to off
	bclr	#SHPB_PUT,_Shape_Ed-PC(gl)	; change shape put flag to off
	move.b	#BLOCK_OBJECT,_Object_Type-PC(gl)

	or.w	#CHGF_TILE,_Something_Changed-PC(gl)

	move.l	#0,_Active_Gadgets-PC(gl)
	
	rts
;
;;- goto functions for jumping to another editor eg from map to tile editor
;

_Work_Goto_Map_To_Map:
	move.w	#SECTION_MAP,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
_Work_Goto_Map_To_Tile:
	move.w	#SECTION_TILE,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
_Work_Goto_Map_To_Palette:
	move.w	#SECTION_PALETTE,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
_Work_Goto_Map_To_Shape:
	move.w	#SECTION_SHAPE,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
_Work_Goto_Map_To_Anim:
	move.w	#SECTION_ANIM,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
_Work_Goto_Map_To_Copper:
	move.w	#SECTION_COPPER,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
_Work_Goto_Map_To_Prefs:
	move.w	#SECTION_PREFS,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
_Work_Goto_Map_To_File:
	move.w	#SECTION_FILE,Run_Prog_Section-PC(gl)
	bra.s	_Work_Goto_Map_To_Section
	nop
_Work_Goto_Map_To_Section:
	jsr	Write_Map_Info
	jsr	Write_Tile_Info
	move.w	#1,_Quit-PC(gl)
	rts

;        *************************************************
;    *********************************************************
;*****************************************************************
;    *********************************************************
;        *************************************************

_Map_Edit_Message_List:
	DC.L	IDCMP_REFRESHWINDOW,_Handle_Map_Edit_RefreshWindow
	DC.L	IDCMP_MOUSEBUTTONS,_Handle_Map_Edit_MouseButtons
	DC.L	IDCMP_MOUSEMOVE,_Handle_Map_Edit_MouseMove
	DC.L	IDCMP_GADGETDOWN,_Handle_Map_Edit_GadgetDown
	DC.L	IDCMP_GADGETUP,_Handle_Map_Edit_GadgetUp
	DC.L	IDCMP_RAWKEY,_Handle_Map_Edit_RawKey
	DC.L	IDCMP_VANILLAKEY,_Handle_Map_Edit_VanillaKey
	DC.L	IDCMP_INTUITICKS,_Handle_Map_Edit_IntuiTicks
	DC.L	-1

_Handle_Map_Edit_RefreshWindow:

	move.l	_Ed_Window-PC(gl),a0
	jsr	_GT_BeginRefresh
	move.l	#1,d0
	jsr	_GT_EndRefresh
	rts

;_GT_BeginRefresh:
;	push	a0/a6
;	base	GadTools
;	call	GT_BeginRefresh
;	pop	a0/a6
;	rts
;
;_GT_EndRefresh:
;	push	a0/a6
;	base	GadTools
;	call	GT_EndRefresh
;	pop	a0/a6
;	rts
dbg33:
_Handle_Map_Edit_MouseButtons:

;	move.w	#0,_Select_Button-PC(gl)
	move.w	#0,_Menu_Button-PC(gl)


	move.w	im_Code(a1),d0
;	move.w	im_Qualifier(a1),d0
	cmp.b	#$68,d0
	bne.s	.not_select_down
	move.w	_Region_Run_ID,_Select_Button-PC(gl)
	move.w	#TOOL_BUTTONDOWN_FLAG,d7
	jsr	Execute_Tool_Procedure
	bra.s	.select_end
.not_select_down
	cmp.b	#$e8,d0
	bne.s	.not_select_up
	move.w	#TOOL_BUTTONUP_FLAG,d7
	jsr	Execute_Tool_Procedure
	move.w	#0,_Select_Button

.not_select_up

.select_end
	move.w	im_Qualifier(a1),d0

	btst	#13,d0
	beq.s	.not_menu
	move.w	_Region_Run_ID,_Menu_Button-PC(gl)
.not_menu

	jsr	Check_Select_Button
	jsr	Check_Menu_Button

	jsr	_Handle_Map_Edit_MouseMove


	rts

_Handle_Map_Edit_MouseMove:
	move.l	_Ed_Window-PC(gl),a1
	move.w	wd_MouseX(a1),d0
	move.w	wd_MouseY(a1),d1
	lea	_Map_Region_Coordinates,a0
	jsr	_Check_Regions

	jsr	_Handle_Map_Scroller

	rts

_Handle_Map_Scroller:
	lea	_Message,a1
	move.l	im_IAddress(a1),a0
	move.w	gg_GadgetID(a0),d0
	cmp.w	#BUTTON_ID_MAPSCROLLERY,d0
	bne.s	.not_mapscrollery_gadget
	move.w	im_Code(a1),d0
	cmp.w	_Map_Top-PC(gl),d0
	beq.s	.not_x_gadget
	move.w	d0,_Map_Top-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
;	jsr	Display_Map
	or.w	#CHGF_YCOORD,_Something_Changed-PC(gl)
.not_x_gadget
	bra.s	.no_gadget_found
.not_mapscrollery_gadget
	cmp.w	#BUTTON_ID_MAPSCROLLERX,d0
	bne.s	.not_mapscrollerx_gadget
	move.w	im_Code(a1),d0
	cmp.w	_Map_Left-PC(gl),d0
	beq.s	.not_y_gadget
	move.w	d0,_Map_Left-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
;	jsr	Display_Map
	or.w	#CHGF_XCOORD,_Something_Changed-PC(gl)
.not_y_gadget
	bra.s	.no_gadget_found
.not_mapscrollerx_gadget
	nop
.no_gadget_found
	rts

_Handle_Map_Edit_GadgetDown:
	jsr	_Handle_Map_Scroller
	rts

_Handle_Map_Edit_GadgetUp:
	jsr	_Handle_Map_Scroller
	rts

_Handle_Map_Edit_RawKey:
	lea	_Map_Edit_RawKey_List,a0
	jsr	_Execute_VanillaKey_List
	rts

_Handle_Map_Edit_VanillaKey:
	lea	_Map_Edit_VanillaKey_List,a0
	jsr	_Execute_VanillaKey_List
	rts


_Handle_Map_Edit_IntuiTicks:
	jsr	_Handle_IntuiTicks_Text
	jsr	_Handle_Map_Edit_MouseMove
	rts


_Handle_IntuiTicks_Text:
	jsr	_Handle_IntuiTicks_GadgetDown

	move.w	_Something_Changed-PC(gl),d0
	and.w	_Something_Mask-PC(gl),d0

	cmp.w	#SECTION_MAP,Run_Prog_Section-PC(gl)
	bne.s	.not_working_with_map

	moveq.l	#gcWinMapMain,d0
	call	_Set_Current_WorkWindow
	tst.l	d0
	beq.s	.no_map_work_window
	
	btst	#CHGB_SHELL_XY,d0
	beq.s	.no_change_in_shellm_xy
	push	d0
	jsr	Display_Text_Shell_XY
	pop	d0
.no_change_in_shellm_xy
	btst	#CHGB_XCOORD,d0
	beq.s	.no_change_in_map_x
	push	d0
	jsr	Display_Text_Map_X
	pop	d0
.no_change_in_map_x
	btst	#CHGB_YCOORD,d0
	beq.s	.no_change_in_map_y
	push	d0
	jsr	Display_Text_Map_Y
	pop	d0
.no_change_in_map_y	
	btst	#CHGB_MAPSET,d0
	beq.s	.no_change_in_mapset
	push	d0
	jsr	Display_Text_Map_Set
	pop	d0
.no_change_in_mapset

.no_map_work_window

.not_working_with_map

	cmp.w	#SECTION_TILE,Run_Prog_Section-PC(gl)
	bne	.not_working_with_tiles

	moveq.l	#gcWinTileMain,d0
	call	_Set_Current_WorkWindow
	tst.l	d0
	beq.s	.no_tile_work_window

	btst	#CHGB_SHELL_XY,d0
	beq.s	.no_change_in_shellt_xy
	push	d0
	jsr	Display_Text_Shell_XY
	pop	d0
.no_change_in_shellt_xy
	btst	#CHGB_XCOORD,d0
	beq.s	.no_change_in_tile_x
	push	d0
	jsr	Display_Text_Tile_X
	pop	d0
.no_change_in_tile_x
	btst	#CHGB_YCOORD,d0
	beq.s	.no_change_in_tile_y
	push	d0
	jsr	Display_Text_Tile_Y
	pop	d0
.no_change_in_tile_y	
	btst	#CHGB_TILESET,d0
	beq.s	.no_change_in_tileset
	push	d0
	jsr	Display_Text_Tile_Set
	pop	d0
.no_change_in_tileset
	btst	#CHGB_PALETTESET,d0
	beq.s	.no_change_in_paletteset
	push	d0
	jsr	Display_Text_Palette_Set
	pop	d0
.no_change_in_paletteset
	btst	#CHGB_TILE,d0
	beq.s	.no_change_in_tile
	push	d0
	jsr	Display_Text_Tile
	pop	d0
.no_change_in_tile

.not_working_with_tiles
.no_tile_work_window

;	btst	#CHGB_SHAPE,d0
;	beq.s	.no_change_in_shape
;	push	d0
;;	jsr	Display_Text_Shape
;	pop	d0
;.no_change_in_shape

	rts


_Show_Debug_Line_Info:
	clr.l	d0
	move.w	_Region_Run_ID,d0
	moveq.l	#0,d0
	push	d0
;	move.l	LL4,d0
	push	d0
;	move.l	LL3,d0
	push	d0
	move.l	LL4,d0
	push	d0
	move.l	LL3,d0
	push	d0
	move.l	LL2,d0
	push	d0
	move.l	LL1,d0
;	clr.l	d0
;	jsr	_Calculate_Shape_Pointer
;	move.w	shape_Count(a0),d0
	push	d0

	pea	Coord_Format	; format
	pea	_StringBuffer	; buffer
	jsr	_SPrintf
	lea	9*4(sp),sp

	move.l	_Ed_RastPort,_Global_RastPort
	move.l	#1,d0
	jsr	_SetAPen
	lea	_StringBuffer,a0
	jsr	_StrLen
	move.l	d0,d2
	move.l	#8,d0
	move.l	#180,d1
	jsr	_DisplayText

	rts



 EVEN

_Map_Edit_VanillaKey_List:
	SetVanilla	$1b,0,_Map_Edit_Escape
	SetVanilla	$0d,0,_Map_Edit_Enter
	SetVanilla	$2C,-1,_Map_Edit_Prev_Tile
	SetVanilla	".",-1,_Map_Edit_Next_Tile
	SetVanilla	$20,0,_Map_Edit_Space
	SetVanilla	"z",0,_Map_Edit_Shape_HotSpot
	DC.W	-1

_Map_Edit_Escape:
	move.w	#1,_Quit-PC(gl)
	move.w	#-1,Run_Prog_Section-PC(gl)
	rts

_Map_Edit_Enter:
	move.l	_Ed_RastPort-PC(gl),_Global_RastPort-PC(gl)
	jsr	Display_Map
	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure
	rts

_Map_Edit_FromStringSet_Tile_OR_Shape:

	move.w	#STRING_ID_CURRTILE,d0
	jsr	_Get_WorkGadgetStringInteger	; get value from string longint gad
	push	d0
	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure
	pop	d0
	btst	#0,_Object_Type-PC(gl)
	beq.s	.not_shape
	move.w	d0,_Shape_Edit-PC(gl)
	bra.s	.new_object_display
.not_shape
	move.w	_Tile_Amount-PC(gl),d1
	subq.w	#1,d1
	cmp.w	d1,d0
	bls.s	.tile_ok
	move.w	d1,d0
.tile_ok
	move.w	d0,_Tile_Edit-PC(gl)

.new_object_display

	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	rts

_Map_Edit_Prev_Tile:
	btst	#0,_Object_Type-PC(gl)
	beq.s	.not_shape
	move.w	#0,d1
	move.w	_Shape_Edit-PC(gl),d0
	sub.w	#1,d0
	cmp.w	d1,d0
	bpl.s	.shape_not_min
	move.w	d1,d0
.shape_not_min
	push	d0
	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure
	pop	d0
	move.w	d0,_Shape_Edit-PC(gl)

	bra.s	.new_object_display
.not_shape
	move.w	_Tile_Edit-PC(gl),d0
	move.w	#0,d1
	sub.w	#1,d0
	cmp.w	d1,d0
	bpl.s	.tile_not_min
	move.w	d1,d0
.tile_not_min
	move.w	d0,_Tile_Edit-PC(gl)

	lea	Region_Map_Choice,a1

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
	move.w	_Tile_Top-PC(gl),d4
;	mulu	d2,d4
	divu	d2,d0
	move.w	d0,d1
	clr.w	d0
	swap	d0
	cmp.w	d4,d1
	bge.s	.new_object_display
	
	subq.w	#1,_Tile_Top-PC(gl)
	jsr	_Display_Tile_List_Map
.new_object_display
	move.w	_Map_Edit_X-PC(gl),d0
	move.w	_Map_Edit_Y-PC(gl),d1
	jsr	Check_Select_Button
	jsr	Check_Menu_Button
	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure
	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	rts

dbgm4:
_Map_Edit_Next_Tile:
	btst	#0,_Object_Type-PC(gl)
	beq.s	.not_shape
	move.l	#256,d1
	jsr	_Count_Shape_Nodes
	jsr	_Find_Greater
	move.w	_Shape_Edit-PC(gl),d0	
	add.w	#1,d0
	cmp.w	d1,d0
	blo.s	.shape_not_max
	move.w	d1,d0
.shape_not_max
	push	d0
	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure
	pop	d0
	move.w	d0,_Shape_Edit-PC(gl)
	bra.s	.new_object_display
.not_shape

	move.w	_Tile_Edit-PC(gl),d0
	move.w	_Tile_Amount-PC(gl),d1
	subq.w	#1,d1
	add.w	#1,d0
	cmp.w	d1,d0
	blo.s	.tile_not_max
	move.w	d1,d0
.tile_not_max
	move.w	d0,_Tile_Edit-PC(gl)

	lea	Region_Map_Choice,a1

	ext.l	d0
	
	cmp.w	_Tile_Amount-PC(gl),d0
	bge.s	.new_object_display
	
	move.w	rg_Width(a1),d2
	move.w	rg_Height(a1),d3
	ext.l	d2
	ext.l	d3
	divu	_Tile_Width-PC(gl),d2		; now # of tiles wide select rg is
	divu	_Tile_Height-PC(gl),d3
	move.w	_Tile_Top-PC(gl),d4
	mulu	d2,d4
	sub.w	d4,d0
	divu	d2,d0
	move.w	d0,d1
	clr.w	d0
	swap	d0
	cmp.w	d3,d1
	blt.s	.new_object_display
	
	addq.w	#1,_Tile_Top-PC(gl)

	jsr	_Display_Tile_List_Map

.new_object_display
	move.w	_Map_Edit_X-PC(gl),d0
	move.w	_Map_Edit_Y-PC(gl),d1
	jsr	Check_Select_Button
	jsr	Check_Menu_Button
	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure
	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	rts


_Map_Edit_Space:
	tst.b	_Screen_Toggle-PC(gl)
	bne.s	.restore_screen
	move.w	#0,d0
	move.w	#260,d1
	move.l	_Wk_Screen-PC(gl),a0
	jsr	_MoveScreenTo
	move.w	d1,_Screen_Top-PC(gl)
	not.b	_Screen_Toggle-PC(gl)
	bra.s	.end
.restore_screen
	move.w	#0,d0
	move.w	_Screen_Top-PC(gl),d1
	move.l	_Wk_Screen-PC(gl),a0
	jsr	_MoveScreenTo
	not.b	_Screen_Toggle-PC(gl)

.end
	rts

_Map_Edit_Shape_HotSpot:

	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure

	jsr	_Calculate_Shape_Node
	move.w	shape_Flags(a0),d0
	move.w	d0,d1
	andi.w	#HOTSPOT_MASKBITS,d0
	asr.w	#HOTSPOT_SHIFTBITS,d0
	addq.w	#1,d0
	cmp.w	#5,d0
	blt.s	.hs_ok
	move.w	#0,d0
.hs_ok	
	asl.w	#HOTSPOT_SHIFTBITS,d0
	andi.w	#~HOTSPOT_MASKBITS,d1
	or.w	d1,d0
	move.w	d0,shape_Flags(a0)
	asr.w	#HOTSPOT_SHIFTBITS,d0
	andi.w	#%0000000000000111,d0
	bsr	_Set_HotSpot	
	move.w	_Map_Edit_X-PC(gl),d0
	move.w	_Map_Edit_Y-PC(gl),d1
	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure

	rts

_Set_HotSpot:	; d0 - hotspot pos, a0 - shape
;	move.w	shape_Flags(a0),d0
	tst.b	d0
	beq.s	.hotspot_center
	subq.w	#1,d0
	beq.s	.hotspot_tl
	subq.w	#1,d0
	beq.s	.hotspot_tr
	subq.w	#1,d0
	beq.s	.hotspot_br
	subq.w	#1,d0
	beq.s	.hotspot_bl
	subq.w	#1,d0
	beq.s	.hotspot_pick
	bra.s	.hotspot_write
.hotspot_center
	move.w	shape_Width(a0),d0
	move.w	shape_Height(a0),d1
	asr.w	#1,d0
	asr.w	#1,d1
	bra.s	.hotspot_write
.hotspot_tl
	moveq.l	#0,d0
	moveq.l	#0,d1	
	bra.s	.hotspot_write
.hotspot_tr
	move.w	shape_Width(a0),d0
	subq.w	#1,d0
	moveq.l	#0,d1	
	bra.s	.hotspot_write
.hotspot_br
	move.w	shape_Width(a0),d0
	subq.w	#1,d0
	move.w	shape_Height(a0),d1
	subq.w	#1,d1
	bra.s	.hotspot_write
.hotspot_bl
	moveq.l	#0,d0
	move.w	shape_Height(a0),d1
	subq.w	#1,d1
	bra.s	.hotspot_write
.hotspot_pick
	move.w	shape_HotOrigX(a0),d0
	move.w	shape_HotOrigY(a0),d1	
.hotspot_write
	neg.w	d0
	move.w	d0,shape_HotX(a0)
	neg.w	d1
	move.w	d1,shape_HotY(a0)
	rts

QUAL_NONE	EQU	0
QUAL_SHIFT	EQU	IEQUALIFIER_LSHIFT!IEQUALIFIER_RSHIFT
QUAL_LSHIFT	EQU	IEQUALIFIER_LSHIFT
QUAL_RSHIFT	EQU	IEQUALIFIER_RSHIFT
QUAL_ALT	EQU	IEQUALIFIER_LALT!IEQUALIFIER_RALT
QUAL_LALT	EQU	IEQUALIFIER_LALT
QUAL_RALT	EQU	IEQUALIFIER_RALT
QUAL_CTRL	EQU	IEQUALIFIER_CONTROL
QUAL_KEYPAD	EQU	IEQUALIFIER_NUMERICPAD
QUAL_IGNORE	EQU	$FF

_Map_Edit_RawKey_List:
	SetVanilla	$4c,QUAL_NONE,_Map_Edit_Move_Map_Up
	SetVanilla	$4d,QUAL_NONE,_Map_Edit_Move_Map_Down
	SetVanilla	$4e,QUAL_NONE,_Map_Edit_Move_Map_Right
	SetVanilla	$4f,QUAL_NONE,_Map_Edit_Move_Map_Left

	SetVanilla	$4c,QUAL_LSHIFT,_Map_Edit_Move_Map_Up_Pg
	SetVanilla	$4c,QUAL_RSHIFT,_Map_Edit_Move_Map_Up_Pg
	SetVanilla	$4d,QUAL_LSHIFT,_Map_Edit_Move_Map_Down_Pg
	SetVanilla	$4d,QUAL_RSHIFT,_Map_Edit_Move_Map_Down_Pg
	SetVanilla	$4e,QUAL_LSHIFT,_Map_Edit_Move_Map_Right_Pg
	SetVanilla	$4e,QUAL_RSHIFT,_Map_Edit_Move_Map_Right_Pg
	SetVanilla	$4f,QUAL_LSHIFT,_Map_Edit_Move_Map_Left_Pg
	SetVanilla	$4f,QUAL_RSHIFT,_Map_Edit_Move_Map_Left_Pg

	DC.W	-1

_Map_Edit_Move_Map_Up:
	move.w	_Map_Top-PC(gl),d0
	cmp.w	#0,d0
	bls.s	.move_map_end
	subq.w	#1,d0
	move.w	d0,_Map_Top-PC(gl)

	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerY
	or.w	#CHGF_YCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts
dbg52:
Alter_Work_Map_ScrollerY:
	btst	#FLAG0B_SLIDER_Y_ON,_Preference_Flags0-PC(gl)
	beq.s	.slider_for_y_not_on
	lea	_Work_MapScrollerY,a1
	move.l	gtg_TheGadget(a1),a0
	move.l	_Ed_Window-PC(gl),a1
	suba.l	a2,a2
	pea	TAG_DONE
	moveq.l	#0,d0
	move.w	_Map_Top-PC(gl),d0
	push	d0
	pea	GTSC_Top
	move.l	sp,a3
	jsr	_GT_SetGadgetAttrs
	add.l	#3*4,sp
.slider_for_y_not_on
	rts

Alter_Work_Map_ScrollerX:
	btst	#FLAG0B_SLIDER_X_ON,_Preference_Flags0-PC(gl)
	beq.s	.slider_for_x_not_on
	lea	_Work_MapScrollerX,a1
	move.l	gtg_TheGadget(a1),a0
	move.l	_Ed_Window-PC(gl),a1
	suba.l	a2,a2
	pea	TAG_DONE
	moveq.l	#0,d0
	move.w	_Map_Left-PC(gl),d0
	push	d0
	pea	GTSC_Top
	move.l	sp,a3
	jsr	_GT_SetGadgetAttrs
	add.l	#3*4,sp
.slider_for_x_not_on
	rts

_Map_Edit_Move_Map_Up_Pg:
	move.w	_Map_Top-PC(gl),d0
	move.w	#0,d1
	cmp.w	d1,d0
	beq.s	.move_map_end
	sub.w	_Map_Edit_Height-PC(gl),d0
	cmp.w	d1,d0
	bge.s	.not_min_y_map
	move.w	d1,d0
.not_min_y_map
	move.w	d0,_Map_Top-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerY
	or.w	#CHGF_YCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts

_Map_Edit_Move_Map_Down:
	move.w	_Map_Top-PC(gl),d0
	move.w	_Map_Height-PC(gl),d1
	sub.w	_Map_Edit_Height-PC(gl),d1
	cmp.w	d1,d0
	bhs.s	.move_map_end
	addq.w	#1,d0
	move.w	d0,_Map_Top-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerY
	or.w	#CHGF_YCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts

_Map_Edit_Move_Map_Down_Pg:
	move.w	_Map_Top-PC(gl),d0		; x pos
	move.w	_Map_Height-PC(gl),d1
	sub.w	_Map_Edit_Height-PC(gl),d1	; max x pos
	cmp.w	d1,d0
	beq.s	.move_map_end
	add.w	_Map_Edit_Height-PC(gl),d0	; add increment
	cmp.w	d1,d0
	ble.s	.not_max_y_map
	move.w	d1,d0
.not_max_y_map
	move.w	d0,_Map_Top-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerY
	or.w	#CHGF_YCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts

_Map_Edit_Move_Map_Right:
	move.w	_Map_Left-PC(gl),d0
	move.w	_Map_Width-PC(gl),d1
	sub.w	_Map_Edit_Width-PC(gl),d1
	cmp.w	d1,d0
	bhs.s	.move_map_end
	addq.w	#1,d0
	move.w	d0,_Map_Left-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerX
	or.w	#CHGF_XCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts

_Map_Edit_Move_Map_Right_Pg:
	move.w	_Map_Left-PC(gl),d0		; x pos
	move.w	_Map_Width-PC(gl),d1
	sub.w	_Map_Edit_Width-PC(gl),d1	; max x pos
	cmp.w	d1,d0
	beq.s	.move_map_end
	add.w	_Map_Edit_Width-PC(gl),d0	; add increment
	cmp.w	d1,d0
	ble.s	.not_max_x_map
	move.w	d1,d0
.not_max_x_map
	move.w	d0,_Map_Left-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerX
	or.w	#CHGF_XCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts

_Map_Edit_Move_Map_Left:
	move.w	_Map_Left-PC(gl),d0
	cmp.w	#0,d0
	bls.s	.move_map_end
	subq.w	#1,d0
	move.w	d0,_Map_Left-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerX
	or.w	#CHGF_XCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts

_Map_Edit_Move_Map_Left_Pg:
	move.w	_Map_Left-PC(gl),d0
	move.w	#0,d1
	cmp.w	d1,d0
	beq.s	.move_map_end
	sub.w	_Map_Edit_Width-PC(gl),d0	; sub increment
	cmp.w	d1,d0
	bge.s	.not_min_x_map
	move.w	d1,d0
.not_min_x_map
	move.w	d0,_Map_Left-PC(gl)
	jsr	ReCalc_Boundries_Map_Coords_Object
	jsr	Alter_Work_Map_ScrollerX
	or.w	#CHGF_XCOORD,_Something_Changed-PC(gl)
.move_map_end
	rts


Window_Calculate_Mouse_Coordinates:
	move.l	_Ed_Window-PC(gl),a1
	clr.l	d0
	move.w	wd_MouseX(a1),d0
	sub.w	Region_Map_Edit+rg_LeftEdge,d0	; left offset in window
	clr.l	d1
	move.w	wd_MouseY(a1),d1
	sub.w	Region_Map_Edit+rg_TopEdge,d1	; top offset in window
Calculate_Mouse_Coordinates:	; d0 - map x, d1 - map y
	divu	_Tile_Width-PC(gl),d0
	add.w	_Map_Left-PC(gl),d0
	move.w	d0,_Map_Edit_X-PC(gl)
	move.w	d0,_Tile_Edit_X-PC(gl)

	divu	_Tile_Height-PC(gl),d1
	add.w	_Map_Top-PC(gl),d1
	move.w	d1,_Map_Edit_Y-PC(gl)
	move.w	d1,_Tile_Edit_Y-PC(gl)

	rts

ReCalc_Boundries_Map_Coords_Object:
	jsr	Calculate_Map_Edit_Boundries
	jsr	Calculate_Tile_Win_Boundries


	jsr	Display_Map
;	jsr	Restore_Object
;	move.w	#-1,_Map_Last_X
ReCalc_Coords_Object:
	jsr	Window_Calculate_Mouse_Coordinates
	move.w	d0,_Map_Last_X-PC(gl)
	move.w	d1,_Map_Last_Y-PC(gl)
	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure
;	jsr	Display_Object
	rts


;***********************************************
;******************************************************
;***********************************************
;***********************************************
;******************************************************
;***********************************************
;***********************************************
;******************************************************
;***********************************************

_Map_Region_Coordinates:
Region_Map_Edit:	DC.W	MAP_EDIT_REGION_ID,000,000,320,12*16
			DC.L	Map_Edit_Region
Region_Map_Choice:	DC.W	MAP_SELECT_REGION_ID,008,192,320-16,16
			DC.L	Map_Choice_Region
			DC.W	-1

;Map_Left_Region:
;	tst.b	d0
;	beq.s	.map_left_execute
;	bmi	.map_left_shutdown
;
;.map_left_setup		; d0 > 0
;;	cmp.w	#MAP_LEFT_REGION_ID,_Select_Button
;;	bne.s	.map_left_end
;
;;	move.l	_Ed_Window,a0
;;	lea	_Sprite_Pointer_Sleep,a1
;;	jsr	_SetPointer
;	move.b	#0,_Region_Status
;
;.map_left_execute	; d0 = 0
;;	move.w	#$0F00,$DFF180
;	cmp.w	#MAP_LEFT_REGION_ID,_Select_Button
;	bne.s	.map_left_end
;	jsr	_Map_Edit_Prev_Tile
;	bra.s	.map_left_end
;.map_left_shutdown	; d0 < 0
;	nop
;;	cmp.w	#MAP_LEFT_REGION_ID,_Select_Button
;;	bne.s	.map_left_end
;
;;	move.l	_Ed_Window,a0
;;	jsr	_ClearPointer
;
;.map_left_end
;	rts

;Map_Right_Region:
;	tst.b	d0
;	beq.s	.map_right_execute
;	bmi	.map_right_shutdown
;
;.map_right_setup		; d0 > 0
;;	move.l	_Ed_Window,a0
;;	lea	_Sprite_Pointer_Sleep,a1
;;	jsr	_SetPointer
;	move.b	#0,_Region_Status
;
;.map_right_execute	; d0 = 0
;;	move.w	#$00F0,$DFF180
;	cmp.w	#MAP_RIGHT_REGION_ID,_Select_Button
;	bne.s	.map_right_end
;	jsr	_Map_Edit_Next_Tile
;	bra.s	.map_right_end
;
;.map_right_shutdown	; d0 < 0
;	nop
;;	move.l	_Ed_Window,a0
;;	jsr	_ClearPointer
;
;.map_right_end
;	rts

Map_Edit_Region:	*********************************
* d0 > 0 : setup region					*
* d0 = 0 : execute region				*
* d0 < 0 : shutdown/cleanup region			*
* d2     : x coord from left of region			*
* d3     : y coord from top of region			*
*********************************************************
	tst.b	d0
	beq.s	.map_edit_execute
	bmi	.map_edit_shutdown
.map_edit_setup		; d0 > 0
	move.l	_Ed_Window-PC(gl),a0
	lea	_Sprite_Pointer_Cross,a1
	jsr	_SetPointer
	move.b	#0,_Region_Status
.map_edit_execute		; d0 = 0
	exg.l	d0,d2
	exg.l	d1,d3
	ext.l	d0
	ext.l	d1
	jsr	Calculate_Mouse_Coordinates
	lea	_Message-PC(gl),a1
	cmp.w	_Map_Last_X-PC(gl),d0
	bne.s	.edit_xy_changed
	cmp.w	_Map_Last_Y-PC(gl),d1
	beq	.edit_xy_end
.edit_xy_changed

	jsr	Check_Select_Button
	jsr	Check_Menu_Button

	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure	

	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure

	or.w	#CHGF_XCOORD!CHGF_YCOORD,_Something_Changed-PC(gl)	; signal x & y coord changed

	move.w	_Map_Edit_X-PC(gl),_Map_Last_X-PC(gl)
	move.w	_Map_Edit_Y-PC(gl),_Map_Last_Y-PC(gl)
.edit_xy_end
	bra.s	.map_edit_end
.map_edit_shutdown		; d0 < 0

	move.w	#TOOL_RESTORE_FLAG,d7
	jsr	Execute_Tool_Procedure
	move.w	#-1,_Map_Last_X-PC(gl)
	move.l	_Ed_Window-PC(gl),a0
	jsr	_ClearPointer

.map_edit_end
	rts



Execute_Tool_Procedure:
	tst.b	_Tools_On-PC(gl)
	beq.s	.no_procedure_to_run
	move.l	_Tool_Procedure,a0
	cmp.l	#0,a0
	beq.s	.no_procedure_to_run
	push	d0-d7/a0-a6
	jsr	(a0)
	pop	d0-d7/a0-a6	
.no_procedure_to_run
	rts

Check_Menu_Button:
	cmp.w	#MAP_EDIT_REGION_ID,_Menu_Button-PC(gl)
	bne	.menu_button_end
	clr.l	d0
	clr.l	d1
	clr.l	d2
	move.w	_Map_Edit_X-PC(gl),d0
	move.w	_Map_Edit_Y-PC(gl),d1
	
;	btst	#SHPB_GET,_Shape_Ed
;	beq	.not_get_shape

;	push	d0-d1
;	jsr	_Calculate_Shape
;	pop	d0-d1
;	bclr	#SHPB_GET,_Shape_Ed	; change shape get flag to off
;	bset	#SHPB_PUT,_Shape_Ed	; change shape flag to put
;	jsr	_Restore_Shape		; inverted screen shape to normal
;	bra.s	.menu_display_object
;.not_get_shape
	jsr	_Read_Map_Tile
	move.w	d2,_Tile_Edit-PC(gl)
	push	d0-d1
	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	jsr	_Display_Tile_List_Map
	pop	d0-d1
.menu_display_object
	move.w	#TOOL_DISPLAY_FLAG,d7
	jsr	Execute_Tool_Procedure
.menu_button_end

	rts


Check_Select_Button:
	cmp.w	#MAP_EDIT_REGION_ID,_Select_Button-PC(gl)
	bne.s	.select_button_end
	clr.l	d0
	clr.l	d1
	move.w	_Map_Edit_X-PC(gl),d0
	move.w	_Map_Edit_Y-PC(gl),d1

	move.w	#TOOL_WRITE_FLAG,d7
	jsr	Execute_Tool_Procedure	

;	jsr	Write_Object

.select_button_end
	rts


Map_Choice_Region:	; d0 status, d2 - x in box, d3 - y in box
	tst.b	d0
	beq.s	.map_choice_execute
	bmi.s	.map_choice_shutdown
.map_choice_setup		; d0 > 0
	move.l	_Ed_Window-PC(gl),a0
	lea	_Sprite_Pointer_Q,a1
	jsr	_SetPointer
;	tst.b	_Screen_Toggle
;	bne.s	.map_choice_end
;	moveq.l	#0,d0
;	move.w	#260,d1
;	move.l	_Wk_Screen-PC(gl),a0
;	jsr	_MoveScreenTo
;	move.w	d1,_Screen_TopEdge-PC(gl)
	move.b	#0,_Region_Status
.map_choice_execute		; d0 = 0
;	move.w	#$033F,$DFF180
	cmp.w	#MAP_SELECT_REGION_ID,_Select_Button-PC(gl)
	bne.s	.no_select_button
	lea	Region_Map_Choice,a0
	move.w	rg_Width(a0),d0
	ext.l	d0
	move.w	_Tile_Width-PC(gl),d1
	ext.l	d2
	divu	d1,d2			; get x coord
	divu	d1,d0
	divu	_Tile_Height-PC(gl),d3		; get y coord
	mulu	d0,d3
	add.w	d3,d2
	move.w	_Tile_Top-PC(gl),d3
	mulu	d3,d0
	add.w	d0,d2
	move.w	_Tile_Amount-PC(gl),d0
	subq.w	#1,d0
	ext.l	d2
	ext.l	d0
	move.w	d2,d1
	call	_Find_Greater
	move.w	d1,_Tile_Edit-PC(gl)

	or.w	#CHGF_TILE,_Something_Changed-PC(gl)
	
.no_select_button
	bra.s	.map_choice_end
.map_choice_shutdown		; d0 < 0
	
	move.l	_Ed_Window-PC(gl),a0
	jsr	_ClearPointer
;	clr.l	d0
;	move.w	_Screen_TopEdge,d1
;	move.l	_Wk_Screen-PC(gl),a0
;	jsr	_MoveScreenTo
	nop
.map_choice_end
	rts

;      *****************************************************
;  ****                                                     ****
;**                                                             **
;          Map Editor Screen, Window, Gadget Definitions
;**                                                             **
;  ****                                                     ****
;      *****************************************************






Work_Gadget_Down_Intuitick:
			DC.L	0,0


_Map_Work_Gadget_List:
;;		SetGadget	000,02,13,11,BUTTON_ID_CLOSE,IMAGE_CLOSE
;		SetGadget	610,02,26,11,BUTTON_ID_BEHIND,IMAGE_BEHIND
;		SetGadget	610,14,26,11,BUTTON_ID_ICONIZE,IMAGE_ICONIZE
;
;		SetGadget	008+(00*34),05+(0*17),32,16,BUTTON_ID_TILE,IMAGE_TILE
;		SetGadget	008+(01*34),05+(0*17),32,16,BUTTON_ID_ANIM,IMAGE_ANIM
;		SetGadget	008+(02*34),05+(0*17),32,16,BUTTON_ID_COPPER,IMAGE_COPPER
;		SetGadget	008+(03*34),05+(0*17),32,16,BUTTON_ID_FILE,IMAGE_FILE
;		SetGadget	008+(00*34),05+(1*17),32,16,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	008+(01*34),05+(1*17),32,16,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	008+(02*34),05+(1*17),32,16,BUTTON_ID_CONFIGURATION,IMAGE_CONFIGURATION
;		SetGadget	008+(03*34),05+(1*17),32,16,BUTTON_ID_PREFERENCES,IMAGE_PREFERENCES
;
;		SetGadget	160+(00*30),25+(0*15),28,14,BUTTON_ID_TILECHG,IMAGE_INCDEC
;		SetGadget	160+(01*30),25+(0*15),28,14,BUTTON_ID_PALETTECHG,IMAGE_INCDEC
;		SetGadget	160+(02*30),25+(0*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;
;		SetGadget	176,014,16,09,BUTTON_ID_TILEPREV,IMAGE_NEWARROWLEFT
;		SetGadget	232,014,16,09,BUTTON_ID_TILENEXT,IMAGE_NEWARROWRIGHT
;
;		SetGadget	194,013,036,11,STRING_ID_CURRTILE,GAD_STRING
;
;		SetGadget	008,041,16,09,BUTTON_ID_MAPSETPREV,IMAGE_NEWARROWLEFT
;		SetGadget	026,041,16,09,BUTTON_ID_MAPSETNEXT,IMAGE_NEWARROWRIGHT
;
;		SetGadget	044,040,204,11,STRING_ID_MAPNAME,GAD_STRING
;
;
;
;
;		SetGadget	260+(00*30),05+(0*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	260+(00*30),05+(1*15),28,14,BUTTON_ID_NULL,IMAGE_BLANK
;		SetGadget	260+(00*30),05+(2*15),28,14,BUTTON_ID_ZOOM,IMAGE_ZOOM
;		SetGadget	260+(01*30),05+(0*15),28,14,BUTTON_ID_NULL,IMAGE_CLEAR
;		SetGadget	260+(01*30),05+(1*15),28,14,BUTTON_ID_NULL,IMAGE_UNDO
;		SetGadget	260+(01*30),05+(2*15),28,14,BUTTON_ID_SHAPES,IMAGE_SHAPES
;
;
;		SetGadget	324+(00*30),05+(0*15),28,14,BUTTON_ID_SCRIBBLE,IMAGE_SCRIBBLE
;		SetGadget	324+(01*30),05+(0*15),28,14,BUTTON_ID_LINE,IMAGE_LINE
;		SetGadget	324+(02*30),05+(0*15),28,14,BUTTON_ID_RECTANGLE,IMAGE_RECTANGLE
;		SetGadget	324+(03*30),05+(0*15),28,14,BUTTON_ID_CUT,IMAGE_CUT
;
;
;;		SetGadget	008,041,07,07,BUTTON_ID_TILEPREV,IMAGE_DECREASE
;;		SetGadget	011,041,07,07,BUTTON_ID_TILENEXT,IMAGE_INCREASE
;

		DC.L		-1

_Map_Work_Define_Gadget_List
;
;		SetGadget	048+009,003,18,009,BUTTON_ID_DEFINE1TICK,TEXT_RMAP|GAD_TICKON	; retain
;
;
;		SetGadget	048+118,026,14,009,BUTTON_ID_DEFINE1DEC,IMAGE_POINTLEFT		; height
;		SetGadget	048+180,026,14,009,BUTTON_ID_DEFINE1INC,IMAGE_POINTRIGHT	
;		SetGadget	048+134,025,44,011,STRING_ID_DEFINE1STR,GAD_STRING
;
;		SetGadget	048+206,026,14,009,BUTTON_ID_DEFINE2DEC,IMAGE_POINTLEFT		; width
;		SetGadget	048+268,026,14,009,BUTTON_ID_DEFINE2INC,IMAGE_POINTRIGHT	; 
;		SetGadget	048+222,025,44,011,STRING_ID_DEFINE2STR,GAD_STRING
;
;
;		SetGadget	048+301,016,018,009,BUTTON_ID_NULL,GAD_MXOFF
;		SetGadget	048+343,016,018,009,BUTTON_ID_NULL,GAD_MXOFF
;
;		SetGadget	048+301,027,018,009,BUTTON_ID_DEFINE1MX,GAD_MXOFF
;		SetGadget	048+322,027,018,009,BUTTON_ID_DEFINE2MX,GAD_MXOFF
;		SetGadget	048+343,027,018,009,BUTTON_ID_DEFINE3MX,GAD_MXOFF
;
;		SetGadget	048+008,041,016,009,BUTTON_ID_DEFINEPREV,IMAGE_NEWARROWLEFT
;		SetGadget	048+026,041,016,009,BUTTON_ID_DEFINENEXT,IMAGE_NEWARROWRIGHT
;		SetGadget	048+044,040,204,011,STRING_ID_MAPNAME,GAD_STRING
;
;		SetGadget	048+358,040,064,011,BUTTON_ID_DEFINEOK,GAD_TEXT|TEXT_OK
;		SetGadget	048+424,040,064,011,BUTTON_ID_DEFINEAPPLY,GAD_TEXT|TEXT_APPLY
;		SetGadget	048+490,040,064,011,BUTTON_ID_DEFINECANCEL,GAD_TEXT|TEXT_CANCEL
;
		DC.L		-1

_Map_Work_Shape_Gadget_List:
;;;		SetGadget	448+003,000+002,23,9,BUTTON_ID_SHAPEPREV,GAD_TEXT|TEXT_PREV
;;;		SetGadget	448+091,000+002,23,9,BUTTON_ID_SHAPENEXT,GAD_TEXT|TEXT_NEXT
;
;		SetGadget	448+004,000+015,64,11,BUTTON_ID_NULL,GAD_TEXT
;		SetGadget	448+090,000+015,64,11,BUTTON_ID_SHAPEPAINT,GAD_TEXT|TEXT_PAINT
;		SetGadget	448+090,000+027,64,11,BUTTON_ID_SHAPEERASE,GAD_TEXT|TEXT_ERASE
;		SetGadget	448+004,000+027,64,11,BUTTON_ID_SHAPEPICKUP,GAD_TEXT|TEXT_PICKUP
;
;		SetGadget	448+048,000+040,64,11,BUTTON_ID_SHAPEOK,GAD_TEXT|TEXT_OK
;;		SetGadget	448+081,000+042,64,11,BUTTON_ID_SHAPECANCEL,GAD_TEXT|TEXT_CANCEL
		DC.L		-1


 ENDC

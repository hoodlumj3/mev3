 IFND	MEV3_MAIN_S
MEV3_MAIN_S SET 1

*
**
*** $VER:mev3.0.s 39.01  © (28/Mar/94) M.J.Edwards
**
*

;	OPT O+
;	OPT O1+			; Tells when a branch could be optimised to short
;	OPT i+			; Tells when '#' is probably missing

gcFileNameSize		equ	32
gcPathNameSize		equ	512
gcFullNameSize		equ	gcPathNameSize+gcFileNameSize

gcDiskBufferSize	equ	512

gcAppPathNameSize	=	128

gcDosCmdBufferSize	=	256

ARGS_ALLOC
CLI_ARGS
WB_ARGS
MAX_ARGC	EQU	3


	Section Code,Code_C

	include	"mev3_macros.s"
	include "mev3.i"

VersionString	macro
		dc.b	"3.0a"
		endm

_main:
	push	d0-d7/a0-a6

	lea	_Initial_SP(pc),a5
	move.l	sp,(a5)

	lea	PC,gl

	move.l	$4.w,_SysBase

	INIT_AMIGA

	call	_Open_Libraries

	call	_Create_All_Image_Info_Bytes


_main_running_loop:

	btst	#7,$BFE001
	beq.s	_main_shut_down
	bra	_main_running_loop

_main_shut_down:

	call	_Close_Libraries	

	call	_Free_All_Mem

	EXIT_AMIGA

	move.l	_Initial_SP(pc),sp
	pop	d0-d7/a0-a6

	rts

;
;;
;;; CLIP
;;
;


_WBenchMsg:	DC.L	0
_ThisTask:	DC.L	0
_Initial_SP:	DC.L	0


_Exit:
	call	_Shutdown_Exit_Routine
	bra.s	_main_shut_down

_Set_Exit_Jump:		; a0 - jump for close down, (if error)
	move.l	a0,_Routine_To_Shutdown_If_Error
	rts

_Clear_Exit_Jump:
	move.l	#0,_Routine_To_Shutdown_If_Error
	rts

_Shutdown_Exit_Routine:
	lea	_Routine_To_Shutdown_If_Error,a0
	moveq.l	#1,d0
	bra.s	.1
.0
	tst.l	(a0)+
	beq.s	.no_jump_required
	push	d0/a0
	move.l	-4(a0),a0
	jsr	(a0)
	pop	d0/a0
.no_jump_required
.1
	dbra	d0,.0
	rts

_Routine_To_Shutdown_If_Error:	DC.L	0,0


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

;SECTION_PROJECT	EQU	$0000
;SECTION_MAP		EQU	$0001
;SECTION_TILE		EQU	$0002
;SECTION_PALETTE	EQU	$0003
;SECTION_SHAPE		EQU	$0004
;SECTION_ANIM		EQU	$0005
;SECTION_COPPER		EQU	$0006
;SECTION_PREFS		EQU	$0007
;SECTION_FILE		EQU	$0008


;****************************************************
;               Library Opens & Closes
;****************************************************

_Open_Libraries:
	lea	_Close_Libraries,a0
	move.l	a0,_Routine_To_Shutdown_If_Error+4

	move.l	$4.w,_SysBase

	moveq.l	#0,d0			; version ?? dos
	lea	_DOSName,a1
	jsr	_Open_Library
	move.l	d0,_DOSBase

	call	_OutPut
	move.l	d0,_stdout

	moveq.l	#0,d0			; version ?? intuition
	lea	_IntuitionName,a1
	jsr	_Open_Library
	move.l	d0,_IntuitionBase

	moveq.l	#0,d0			; version ?? graphics
	lea	_GraphicsName,a1
	jsr	_Open_Library
	move.l	d0,_GraphicsBase

	moveq.l	#0,d0			; version ?? graphics
	lea	_AslName,a1
	jsr	_Open_Library
	move.l	d0,_AslBase

	moveq.l	#0,d0			; version ?? gadtools
	lea	_GadToolsName,a1
	jsr	_Open_Library
	move.l	d0,_GadToolsBase

	moveq.l	#0,d0			; version ?? utility
	lea	_UtilityName,a1
	jsr	_Open_Library
	move.l	d0,_UtilityBase

	moveq.l	#0,d0			; version ?? diskfont
	lea	_DiskFontName,a1
	jsr	_Open_Library
	move.l	d0,_DiskFontBase

	moveq.l	#0,d0			; version ?? layers
	lea	_LayersName,a1
	jsr	_Open_Library
	move.l	d0,_LayersBase

;	lea	_System80,a0
;	jsr	_Open_DiskFont
;	move.l	d0,_SystemFont

;	lea	_DPaint50,a0
;	jsr	_Open_DiskFont
;	move.l	d0,_DPaintFont

;	move.l	_SystemFont,a1
;	jsr	_AddFont

;	move.l	_DPaintFont,a1
;	jsr	_AddFont

	call	_Get_Application_Path
	move.l	d0,_Application_Path


GetArgv	macro	; argument number
	move.l	_Argv+(\1*4),d0
	endm	
dbgmn1:
;	lea	_Argv,a0
;	move.l	(2*4)(a0),d1
	GetArgv	1
	move.l	d0,d1
	move.l	#256,d0
	call	_Get_FullPath_From_Name
	move.l	d0,_Project_FullName
	move.l	d0,a0
	call	_Print
	rts

_OutPut:
	push	a6
	base	DOS
	call	Output
	pop	a6
	rts


_Close_Libraries:
	move.l	_Project_FullName,a0
	call	_Free
	
	move.l	_Application_Path,a0
	call	_Free


;	move.l	_DPaintFont,a1
;	jsr	_RemFont

;	move.l	_SystemFont,a1
;	jsr	_RemFont

	move.l	_DPaintFont,a1
	jsr	_Close_Font
	
	move.l	_SystemFont,a1
	jsr	_Close_Font

	move.l	_DiskFontBase,a1
	jsr	_Close_Library

	move.l	_UtilityBase,a1
	jsr	_Close_Library

	move.l	_GadToolsBase,a1
	jsr	_Close_Library

	move.l	_AslBase,a1
	jsr	_Close_Library

	move.l	_GraphicsBase,a1
	jsr	_Close_Library

	move.l	_IntuitionBase,a1
	jsr	_Close_Library

	move.l	_stdin,d1
	call	_Close_Output_Window

	move.l	_DOSBase,a1
	jsr	_Close_Library

	move.l	#0,_Routine_To_Shutdown_If_Error+4

	rts


_Get_Application_Path:
	move.l	#gcAppPathNameSize,d0
	clr.l	d1
	call	_Get_FullPath_From_Name
	rts

;_Free_Application_Path:	; a0 -> app path
;	call	_Free
;	rts

_Get_FullPath_From_Name:	; d0 - size of buffer, d1 - filename
	push	d0
	push	d1
	call	_Malloc
	pop	d1
	pop	d3
	push	d0
;	clr.l	d1
	move.l	d0,d2
;	move.l	#gcAppPathNameSize,d3
	call	_Get_File_Lock
	pop	d0
	rts	; d0 -> app path


_Lock:		; d1 - filename
	push	d2/a6
	move.l	#-2,d2			; shared
	base	DOS
	call	Lock			; lock filename
	pop	d2/a6
	rts	; d0 - lock

_UnLock:	; d1 - lock
	push	d1/a6
	base	DOS
	call	UnLock			; lock filename
	pop	d1/a6
	rts

_Examine:		; d1 - lock, d2 - fileinfoblock
	push	d1-d2/a6
	base	DOS
	call	Examine
	pop	d1-d2/a6
	rts

_NameFromLock:		; d1 - lock, d2 - dest_str, d3 - size of dest_str
	push	d1-d3/a6
	base	DOS
	call	NameFromLock
	pop	d1-d3/a6
	rts

_Get_Name_From_Lock:	; d1 - lock, d2 - dest_str, d3 - size of dest_str
	push	a2
	call	_NameFromLock
	lea	-fib_SIZEOF(sp),sp
	move.l	sp,a2
	move.l	a2,d2
	call	_Examine
	move.l	$78(a2),d0
	lea	fib_SIZEOF(sp),sp
	pop	a2
	rts


_Get_File_Lock:	; d1 - filename, d2 - name_buffer, d3 - size of buffer
	call	_Lock
	tst.l	d0
	beq.s	.end_get_lock
	push	d0
	move.l	d0,d1
	bsr	_Get_Name_From_Lock
	pop	d1
	push	d0
	call	_UnLock
	pop	d0
.end_get_lock
	rts


 ifd	dugbarry

	tst.l	_WBenchMsg(gl)
	bne.s	WorkBench_Start

CLI_Start:

	bsr	_Display_Info


	
	lea	_Argv(gl),a0		; args list
	move.l	4(a0),a1
	move.b	(a1),d0
	cmp.b	#'?',d0
	bne.s	.no_help_needed
	bsr	_Display_Help
	moveq.l	#0,d0
	bra	_Exit
.no_help_needed

	move.l	_Argv+(1*4)(gl),d1	; file or path

	bsr	_Get_File_Lock
	tst.l	d0
	bmi.s	.is_filename
	move.b	#1,_No_FileName(gl)	
	tst.l	d0
	beq.s	.is_filename
.directory

	move.l	_WholeName(gl),a0	; copy directory path to dirpath
	move.l	_DirPath(gl),a1
	bsr	_StrCpy
	bra.s	.end_cli
.is_filename

	lea	_Argv(gl),a3		; args list
	move.l	4(a3),d1
	base	DOS,(gl)
	call	FilePart
	move.l	d0,a0
	move.l	_FileName(gl),a1
	bsr	_StrCpy
	move.l	4(a3),a2
	sub.l	a2,a0
	move.l	a0,d0
	move.l	a2,a0
	move.l	_DirPath(gl),a1
	bsr	_StrnCpy
.end_cli
	rts

;
;; code if run from workbench
;

WorkBench_Start:

	lea	_ArgLocks(gl),a0
	move.l	4(a0),d1
	move.l	_DirPath(gl),d2
	bsr	_Get_Name_Examine	; convert wblock to full dirpath
	move.l	_WholeName(gl),a0
	move.l	_DirPath(gl),a1
	move.l	_Argv+1*4(gl),a2
	bsr	_Join_Path_FileName	; join full dirpath and filename (if one present)

	move.l	_WholeName(gl),d1
	bsr	_Get_File_Lock		; now get lock on joined name to see if it is a filename or just a directory
	tst.l	d0
	bmi.s	.is_filename
.directory

	move.b	#1,_No_FileName(gl)

.is_filename	
;	move.l	_WholeName(gl),d0
;	push	d0
;	bsr	_Printf
;	pop	d0

	rts


_Get_File_Lock:	; d1 - filename

;	move.l	#-2,d2			; shared
;	base	DOS,(gl)
;	call	Lock			; lock filename
;	move.l	d0,d7			; save lock
;	tst.l	d0			; is the filename there?
;	beq	.end_get_lock
;	move.l	d7,d1			; lock
	move.l	_WholeName(gl),d2	; destin str buffer
	bsr	_Get_Name_Examine
.do_unlock
	push	d0
	move.l	d7,d1
	base	DOS,(gl)
	call	UnLock
	pop	d0
.end_get_lock
	rts

_Display_Help:
;	pea	_Help_String(pc)
;	bsr	_Printf
;	pop	d0
	rts

_Display_Info:
;	pea	_Info_String(pc)
;	bsr	_Printf
;	pop	d0
	rts

_Get_Name_Examine:	; d1 - lock, d2 - dest_str
	push	a6
	push	d1
;	move.l	_WholeName(gl),d2
	move.l	#256,d3
	base	DOS,(gl)
	call	NameFromLock
	pop	d1
	lea	-fib_SIZEOF(sp),sp
	move.l	sp,a2
	move.l	a2,d2
	base	DOS,(gl)
	call	Examine
	move.l	$78(a2),d0
	lea	fib_SIZEOF(sp),sp
	pop	a6
	rts

_Join_Path_FileName:	; a0 - destination, a1 - dirpath, a2 - filename
	push	a0
	exg.l	a0,a1
	bsr	_StrCpy			; copy dirpath to destin
	exg.l	a0,a1
	
	move.l	a0,d1			; move destin to d1
	move.l	a2,d2			; move filename to d2
	move.l	#256+32,d3		; size of buffer
	push	a6
	base	DOS,(gl)		; (dest,filename,sizedest) (d1/d2/d3)
	call	AddPart			; connect the two
	pop	a6
	pop	a0
	rts

	rts
 endc


_DosCmdBuffer:		DS.L	0
_Argc:			DS.L	1
_Argv:			DS.L	MAX_ARGC
_ArgLocks:		DS.L	MAX_ARGC


*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****			      Variables For All				*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************

PCA:
_Something_Changed:	DC.W	0
_Something_Mask:	DC.W	0
;	ifd dugbarry
;	endc
_Zoom_Ed:		DC.W	0
_Max_Depth:		DC.W	8
_Min_Depth:		DC.W	1

_Blank_BitMap:		DC.W	8,64,8,0
			DC.L	Plane0_Blank,Plane1_Blank,Plane2_Blank,Plane3_Blank,Plane4_Blank,Plane5_Blank,Plane6_Blank,Plane7_Blank

Plane0_Blank:
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
			DC.L	$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA,$55555555,$55555555,$AAAAAAAA,$AAAAAAAA
Plane1_Blank:		;DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Plane2_Blank:		;DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Plane3_Blank:		;DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Plane4_Blank:		;DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Plane5_Blank:		;DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Plane6_Blank:		;DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Plane7_Blank:		DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

 EVEN


_Map_Count:		DC.W	0	; at the moment 1 map max
_Map_Width:		DC.W	0
_Map_Height:		DC.W	0
_Map_Location:		DC.L	0
_Map_Left:		DC.W	0
_Map_Top:		DC.W	0
_Map_Flags:		DC.W	0

_Tile_Count:		DC.W	0	; at the moment 1 set of tiles max
_Tile_Amount:		DC.W	0
_Tile_Width:		DC.W	0
_Tile_Height:		DC.W	0
_Tile_Depth:		DC.W	0
_Tile_Flags:		DC.W	0
_Tile_Palette:		DC.W	0
_Tile_Colours:		DC.L	0
_Tile_Edit:		DC.W	0
_Tile_Left:		DC.W	0
_Tile_Top:		DC.W	0

_Tile_BitMap:		DS.B	bm_SIZEOF
_Mask_BitMap:		DS.B	bm_SIZEOF

_Shape_Count:		DC.W	0
_Shape_Width:		DC.W	0
_Shape_Height:		DC.W	0
_Shape_HotX:		DC.W	0
_Shape_HotY:		DC.W	0
_Shape_Flags:		DC.W	0
_Shape_Edit:		DC.W	0



_Tile_Edit_X:
_Map_Edit_X:		DC.W	0
_Tile_Edit_Y:
_Map_Edit_Y:		DC.W	0
_Tile_Last_X:
_Map_Last_X:		DC.W	-1
_Tile_Last_Y:
_Map_Last_Y:		DC.W	-1

_Map_Edit_Width:	DC.W	0
_Map_Edit_Height:	DC.W	0

_Screen_Min_X:		DC.W	0
_Screen_Max_X:		DC.W	0
_Screen_Min_Y:		DC.W	0
_Screen_Max_Y:		DC.W	0

_In_Region:		DC.W	0
_Select_Button:		DC.W	0
_Menu_Button:		DC.W	0

_Actual_Sets:
_Project_Set:		DC.W	0
_Map_Set:		DC.W	0
_Tile_Set:		DC.W	0
_Palette_Set:		DC.W	0
_Shape_Set:		DC.W	0
_Copper_Set:		DC.W	0
_Anim_Set:		DC.W	0

_Load_Sets:
_Load_Project_Set:	DC.W	0
_Load_Map_Set:		DC.W	0
_Load_Tile_Set:		DC.W	0
_Load_Palette_Set:	DC.W	0
_Load_Shape_Set:	DC.W	0
_Load_Copper_Set:	DC.W	0
_Load_Anim_Set:		DC.W	0

_Old_Sets:
_Old_Project_Set:	DC.W	0
_Old_Map_Set:		DC.W	0
_Old_Tile_Set:		DC.W	0
_Old_Palette_Set:	DC.W	0
_Old_Shape_Set:		DC.W	0
_Old_Copper_Set:	DC.W	0
_Old_Anim_Set:		DC.W	0

_Project_Node:		DC.L	0
_Map_Node:		DC.L	0
_Tile_Node:		DC.L	0
_Palette_Node:		DC.L	0
_ShpHdr_Node:		DC.L	0
_Shape_Node:		DC.L	0
_Copper_Node:		DC.L	0
_Animation_Node:	DC.L	0


 EVEN
 

_TitleString:		DC.B	"MapEditor Version 3.00 Copyright © 1994 Matthew J.Edwards (17.07.94)",0
_VersionString:		DC.B	"$VER: MapEditor 3.00 (17.07.94)",0

 EVEN

_Preference_Flags0:	DC.B	%00001111
_Preference_Flags1:	DC.B	%00000000
_Preference_Flags2:	DC.B	%00000000
_Preference_Flags3:	DC.B	%00000000

_Tool_Procedure:	DC.L	0
LL1:			DC.L	0
LL2:			DC.L	0
LL3:			DC.L	0
LL4:			DC.L	0
_Tile_Win_Width:	DC.W	0
_Tile_Win_Height:	DC.W	0
_Screen_Toggle:		DC.B	0,0
_Screen_Top:		DC.W	0
_Object_Type:		DC.B	0,0
_Screen_TopEdge:	DC.W	0




;				       .--- put shape
;				       |.-- Paint shape
_Shape_Ed:		DC.B	%00000000
 EVEN

_ReActive_Gadgets:	DC.L	0
_Active_Gadgets:	DC.L	0

Coord_Format:		DC.B	"x1:%3ld y1:%3ld x2:%3ld y2:%3ld S:%ld M:%ld R:%ld ",0
Button_Format:		DC.B	"L:%4lx R:%4lx",0

_Buffer256:
_StringBuffer:		DS.B	96
_StringBuffer2:		DS.B	64
_StringBuffer3:		DS.B	160

_Text_Define_Map:	DC.B	"- Define Map -",0

 EVEN

_Line_X1:		DC.W	0
_Line_Y1:		DC.W	0
_Line_X2:		DC.W	0
_Line_Y2:		DC.W	0
_Rectangle_Filled:	DC.W	0
_Cut_On:
_Rectangle_On:
_Line_On:		DC.B	0,0
_Control:		DC.W	0

_Tile_Format:		DC.B	"%ld",0
;_Hex_Map_Tile_Buffer:	DC.B	"0000",0,0,0
;_Hex_Tile_Format:	DC.B	"%04lx",0
;_Map_Old_Top:		DC.W	0
;_Map_Old_Left:		DC.W	0

_Brightest_Pen:		DC.W	1
_Backup_RastPort:	DC.L	0
_Backup_BitMap:		DC.L	0
_Use_RastPort:		DC.L	0
_Use_BitMap:		DC.L	0
_Temp_RastPort:		DC.L	0
_Temp_BitMap:		DC.L	0

_Wait_On_Signal:	DC.W	0
_Wait_Routine:		DC.L	0
_Wait_Routine_Old:	DC.L	0

_Backup_Palette:	DC.L	0
_Undo_Palette:		DC.L	0
_Temp_Palette:		DC.L	0
_First_Colour:		DC.W	0
_Second_Colour:		DC.W	0
_Palette_Display:	DC.B	0
_Tools_On:		DC.B	0
_Regions_On:		DC.B	0
_Mask_On:		DC.B	0

 EVEN

_Tile_Edit_Left:	DC.W	0
_Tile_Edit_Top:		DC.W	0

_Colour_Edit:		DC.W	0
_Colour_Edit_0:		DC.W	0
_Colour_Last_1:		DC.W	0
_Colour_Edit_1:		DC.W	1

_Tile_Select_First:	DC.W	0
_Tile_Select_Second:	DC.W	0
 
 EVEN

PC:

_Preferences_Backup:	DC.L	0

_Default_Preferences:
			DC.L	LORES_KEY
			DC.W	-1,-1
			DC.L	HIRESLACE_KEY
			DC.W	-1,-1
			DC.W	16,16,4,1,$0000
			DC.W	20,12,$0000

_Preferences:		DC.B	prefs_SIZEOF


_Sprite_Pointer_Cross:	DC.W	15,15,-8,-7,0,0
			DC.W	%0000000100000000,%0000000000000000
			DC.W	%0000000000000000,%0000000100000000
			DC.W	%0000000100000000,%0000000000000000
			DC.W	%0000000000000000,%0000000100000000
			DC.W	%0000000100000000,%0000000000000000
			DC.W	%0000000000000000,%0000000100000000
			DC.W	%0000000000000000,%0000000000000000
			DC.W	%1101100000110110,%0010010001001000
			DC.W	%0000000000000000,%0000000000000000
			DC.W	%0000000000000000,%0000000100000000
			DC.W	%0000000100000000,%0000000000000000
			DC.W	%0000000000000000,%0000000100000000
			DC.W	%0000000100000000,%0000000000000000
			DC.W	%0000000000000000,%0000000100000000
			DC.W	%0000000100000000,%0000000000000000
			DC.W	%0000000000000000,%0000000000000000
			DC.W	0,0

_Sprite_Pointer_Sleep:	DC.W	16,16,-6,0,0,0
			DC.W	%0000010000000000,%0000011111000000
			DC.W	%0000000000000000,%0000011111000000
			DC.W	%0000000100000000,%0000001110000000
			DC.W	%0000000000000000,%0000011111100000
			DC.W	%0000011111000000,%0001111111111000
			DC.W	%0001111111110000,%0011111111101100
			DC.W	%0011111111111000,%0111111111011110
			DC.W	%0011111111111000,%0111111110111110
			DC.W	%0111111111111100,%1111111101111111
			DC.W	%0111111011111100,%1111111111111111
			DC.W	%0111111111111100,%1111111111111111
			DC.W	%0011111111111000,%0111111111111110
			DC.W	%0011111111111000,%0111111111111110
			DC.W	%0001111111110000,%0011111111111100
			DC.W	%0000011111000000,%0001111111111000
			DC.W	%0000000000000000,%0000011111100000
			DC.W	0,0

_Sprite_Pointer_Sleep_Old:	
			DC.W	22,16,-8,-8,0,0
			DC.W	%0000011000000000,%1100011000000000
			DC.W	%0000111101000000,%1000111101000000
			DC.W	%0011111111100000,%0011111111100000
			DC.W	%0111111111100000,%0111111111100000
			DC.W	%0110000111110000,%0111111111110000
			DC.W	%0111101111111000,%0111111111111000
			DC.W	%1111011111111000,%1111111111111000
			DC.W	%0110000111111100,%0111111111111100
			DC.W	%0111111100001100,%0111111111111100
			DC.W	%0011111111011110,%0011111111111110
			DC.W	%0111111110111100,%0111111111111100
			DC.W	%0011111100001100,%0011111111111100
			DC.W	%0001111111111000,%0001111111111000
			DC.W	%0000011111110000,%0000011111110000
			DC.W	%0000000111000000,%0000000111000000
			DC.W	%0000011100000000,%0000011100000000
			DC.W	%0000111111000000,%0000111111000000
			DC.W	%0000011010000000,%0000011010000000
			DC.W	%0000000000000000,%0000000000000000
			DC.W	%0000000011000000,%0000000011000000
			DC.W	%0000000011100000,%0000000011100000
			DC.W	%0000000001000000,%0000000001000000
			DC.W	0,0
			
_Sprite_Pointer_Q:	DC.W	12,16,-1,0,0,0
			DC.W	%1111110000000000,%0000000000000000
			DC.W	%1111111000000000,%0000000000000000
			DC.W	%1111111000000000,%0000000000000000
			DC.W	%1111100000000000,%0000000000000000
			DC.W	%1111110000000000,%0000000000000000
			DC.W	%1110111000000000,%0000000000000000
			DC.W	%0110011100000000,%0000000000000000
			DC.W	%0000001110000000,%0000000000000000
			DC.W	%0000000111000000,%0000000000000000
			DC.W	%0000000010000000,%0000000000000000
			DC.W	%0000000000000000,%0000000000000000
			DC.W	%0000000000000000,%0000000000000000
			DC.W	0,0

_SysBase:		DC.L	0
_DOSBase:		DC.L	0
_IntuitionBase:		DC.L	0
_GraphicsBase:		DC.L	0
_GadToolsBase:		DC.L	0
_AslBase:		DC.L	0
_UtilityBase:		DC.L	0
_DiskFontBase:		DC.L	0
_LayersBase:		DC.L	0
_Project_FullName:	DC.L	0
_stdout:		DC.L	0
_stdin:			DC.L	0

_Application_Path:	DC.L	0
_Init_Path:		DC.L	0

_File_Handle:		DC.L	0

_SystemFont:		DC.L	0
_DPaintFont:		DC.L	0

 EVEN

_Wk_Screen:		DC.L	0
_Wk_Window:		DC.L	0
_Wk_UserPort:		DC.L	0
_Wk_RastPort:		DC.L	0
_Wk_ViewPort:		DC.L	0
_Wk_Gadgets:		DC.L	0
_Wk_VisualInfo:		DC.L	0

_Ed_Screen:		DC.L	0
_Ed_Window:		DC.L	0
_Ed_UserPort:		DC.L	0
_Ed_RastPort:		DC.L	0
_Ed_ViewPort:		DC.L	0
_Ed_Gadgets:		DC.L	0
_Ed_VisualInfo:		DC.L	0

_Gl_VisualInfo:		DC.L	0
_Global_RastPort:	DC.L	0


_Raised_Box_Colour:	DC.W	0,2,3
_Lowered_Box_Colour:	DC.W	0,3,2

;_System_Colours:	DC.W	$0468,$0024,$0FFF,$079B ;,$0024,$0999,$0000,$0EEE

_Work_Screen_Colours:	; $AAA $000 $FFF $555
		DC.W     0,$AA,$AA,$AA
		DC.W     1,$00,$00,$00
		DC.W     2,$FF,$FF,$FF
		DC.W     3,$55,$55,$55
		DC.W	 4,$FF,$FF,$00
		DC.W	 5,$00,$55,$99
		DC.W	 6,$CC,$00,$00
		DC.W	 7,$00,$88,$00
		DC.W    -1,$00,$00,$00

_Default_Colours:	incbin	"palette.bin"
;			DC.B	$00,$00,$00,$E0,$C0,$A0,$E0,$00,$00,$A0,$00,$00,$D0,$80,$00,$F0,$E0,$00,$80,$F0,$00,$00,$80,$00,$00,$B0,$60,$00,$D0,$D0,$00,$A0,$F0,$00,$70,$C0,$00,$00,$F0,$70,$00,$F0,$C0,$00,$E0,$C0,$00,$80
;			DC.B	$60,$20,$00,$E0,$50,$20,$A0,$50,$20,$F0,$C0,$A0,$30,$30,$30,$40,$40,$40,$50,$50,$50,$60,$60,$60,$70,$70,$70,$80,$80,$80,$90,$90,$90,$A0,$A0,$A0,$C0,$C0,$C0,$D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0
;;			DC.B	$00,$00,$00,$A0,$A0,$A0,$50,$50,$F0,$F0,$80,$00,$80,$00,$80,$F0,$40,$A0,$E0,$00,$00,$60,$20,$00,$F0,$60,$00,$F0,$A0,$80,$F0,$E0,$00,$00,$80,$00,$00,$D0,$00,$00,$C0,$C0,$00,$60,$F0,$00,$00,$A0
;;			DC.B	$E0,$E0,$E0,$D0,$D0,$D0,$D0,$D0,$D0,$C0,$C0,$C0,$B0,$B0,$B0,$A0,$A0,$A0,$90,$90,$90,$80,$80,$80,$70,$70,$70,$70,$70,$70,$60,$60,$60,$50,$50,$50,$40,$40,$40,$30,$30,$30,$20,$20,$20,$20,$20,$20
;			DC.B	$F0,$00,$00,$E0,$00,$00,$E0,$00,$00,$D0,$00,$00,$C0,$00,$00,$B0,$00,$00,$B0,$00,$00,$A0,$00,$00,$90,$00,$00,$80,$00,$00,$70,$00,$00,$70,$00,$00,$60,$00,$00,$50,$00,$00,$40,$00,$00,$40,$00,$00
;			DC.B	$F0,$D0,$D0,$F0,$B0,$B0,$F0,$90,$90,$F0,$70,$70,$F0,$50,$50,$F0,$40,$40,$F0,$20,$20,$F0,$00,$00,$F0,$A0,$50,$F0,$90,$40,$F0,$80,$20,$F0,$70,$00,$E0,$60,$00,$C0,$60,$00,$B0,$50,$00,$90,$40,$00
;			DC.B	$F0,$F0,$D0,$F0,$F0,$B0,$F0,$F0,$90,$F0,$F0,$70,$F0,$F0,$50,$F0,$F0,$40,$F0,$F0,$20,$F0,$F0,$00,$E0,$D0,$00,$C0,$C0,$00,$B0,$A0,$00,$90,$90,$00,$80,$80,$00,$70,$60,$00,$50,$50,$00,$40,$40,$00
;			DC.B	$D0,$F0,$50,$C0,$F0,$40,$B0,$F0,$20,$A0,$F0,$00,$90,$E0,$00,$80,$C0,$00,$70,$B0,$00,$60,$90,$00,$D0,$F0,$D0,$B0,$F0,$B0,$90,$F0,$90,$80,$F0,$70,$60,$F0,$50,$40,$F0,$40,$20,$F0,$20,$00,$F0,$00
;			DC.B	$00,$F0,$00,$00,$E0,$00,$00,$E0,$00,$00,$D0,$00,$00,$C0,$00,$00,$B0,$00,$00,$B0,$00,$00,$A0,$00,$00,$90,$00,$00,$80,$00,$00,$70,$00,$00,$70,$00,$00,$60,$00,$00,$50,$00,$00,$40,$00,$00,$40,$00
;			DC.B	$D0,$F0,$F0,$B0,$F0,$F0,$90,$F0,$F0,$70,$F0,$F0,$50,$F0,$F0,$40,$F0,$F0,$20,$F0,$F0,$00,$F0,$F0,$00,$E0,$E0,$00,$C0,$C0,$00,$B0,$B0,$00,$90,$90,$00,$80,$80,$00,$70,$70,$00,$50,$50,$00,$40,$40
;			DC.B	$50,$B0,$F0,$40,$B0,$F0,$20,$A0,$F0,$00,$90,$F0,$00,$80,$E0,$00,$70,$C0,$00,$60,$B0,$00,$50,$90,$D0,$D0,$F0,$B0,$B0,$F0,$90,$90,$F0,$70,$80,$F0,$50,$60,$F0,$40,$40,$F0,$20,$20,$F0,$00,$00,$F0
;			DC.B	$00,$00,$F0,$00,$00,$E0,$00,$00,$E0,$00,$00,$D0,$00,$00,$C0,$00,$00,$B0,$00,$00,$B0,$00,$00,$A0,$00,$00,$90,$00,$00,$80,$00,$00,$70,$00,$00,$70,$00,$00,$60,$00,$00,$50,$00,$00,$40,$00,$00,$40
;			DC.B	$F0,$D0,$F0,$E0,$B0,$F0,$D0,$90,$F0,$D0,$70,$F0,$C0,$50,$F0,$B0,$40,$F0,$B0,$20,$F0,$A0,$00,$F0,$90,$00,$E0,$80,$00,$C0,$70,$00,$B0,$60,$00,$90,$50,$00,$80,$40,$00,$70,$30,$00,$50,$20,$00,$40
;			DC.B	$F0,$D0,$F0,$F0,$B0,$F0,$F0,$90,$F0,$F0,$70,$F0,$F0,$50,$F0,$F0,$40,$F0,$F0,$20,$F0,$F0,$00,$F0,$E0,$00,$E0,$C0,$00,$C0,$B0,$00,$B0,$90,$00,$90,$80,$00,$80,$60,$00,$70,$50,$00,$50,$40,$00,$40
;			DC.B	$F0,$E0,$D0,$F0,$D0,$D0,$F0,$D0,$C0,$E0,$C0,$B0,$E0,$B0,$A0,$D0,$B0,$90,$D0,$A0,$90,$C0,$90,$80,$C0,$90,$80,$B0,$80,$70,$B0,$60,$C0,$A0,$70,$60,$A0,$60,$50,$A0,$60,$50,$90,$50,$40,$90,$50,$40
;			DC.B	$80,$40,$30,$80,$30,$30,$70,$30,$20,$70,$30,$20,$70,$20,$20,$60,$20,$10,$60,$10,$10,$50,$10,$10,$50,$10,$10,$40,$10,$00,$40,$00,$00,$30,$00,$00,$30,$00,$00,$20,$00,$00,$20,$00,$00,$20,$00,$00
;			DC.B	$F0,$50,$50,$F0,$B0,$80,$F0,$F0,$80,$80,$F0,$80,$80,$F0,$F0,$80,$80,$F0,$B0,$80,$F0,$F0,$80,$F0,$C0,$20,$20,$C0,$40,$20,$C0,$70,$20,$C0,$90,$20,$C0,$C0,$20,$90,$C0,$20,$70,$C0,$20,$40,$C0,$20
;			DC.B	$20,$C0,$30,$20,$C0,$50,$20,$C0,$80,$20,$C0,$B0,$20,$A0,$C0,$20,$70,$C0,$20,$50,$C0,$20,$20,$C0,$50,$20,$C0,$80,$20,$C0,$B0,$20,$C0,$C0,$20,$A0,$C0,$20,$80,$C0,$20,$50,$C0,$20,$20,$F0,$F0,$F0

_Message:		DS.L	im_SIZEOF/4
_Quit:			DC.W	0


Minus_1:		DC.L	-1

File_Gadget_Count:	DC.L	0
Image_Gadget_Count:	DC.L	0


_System80:		;DC.L	_SystemName,$00080000
			DC.L	_Mev3Name,$00080000
_DPaint50:		;DC.L	_DpaintName,$00050042
			DC.L	_Mev3Name,$00050042


_Text_OK:		DC.B	"_OK",0
_Text_Cancel:		DC.B	"_Cancel",0
_Text_Load:		DC.B	"_Load",0
_Text_Save:		DC.B	"_Save",0
_Text_SaveAs:		DC.B	"Sa_ve As",0
_Text_Delete:		DC.B	"_Delete",0
_Text_Insert:		DC.B	"_Insert",0
_Text_Remove:		DC.B	"_Remove",0
_Text_Quit:		DC.B	"_Quit",0
_Text_Add:		DC.B	"_Add",0
_Text_Use:		DC.B	"_Use",0

_Text_FileType_Project:	DC.B	"Project",0
_Text_FileType_Map:	DC.B	"Map",0
_Text_FileType_Tile:	DC.B	"Tile",0
_Text_FileType_Palette:	DC.B	"Palette",0
_Text_FileType_Shape:	DC.B	"Shape",0
_Text_FileType_Anim:	DC.B	"Animation",0
_Text_FileType_Copper:	DC.B	"Copper",0
_Text_FileType_Prefs:	DC.B	"Preferences",0
_Text_FileType_File:	DC.B	"File",0

_Text_File_Extensions:
_Text_FileExt_Project:	DC.B	".prj",0
_Text_FileExt_Map:	DC.B	".map",0
_Text_FileExt_Tile:	DC.B	".img",0
_Text_FileExt_Palette:	DC.B	".pal",0
_Text_FileExt_Shape:	DC.B	".shp",0
_Text_FileExt_Anim:	DC.B	".anm",0
_Text_FileExt_Copper:	DC.B	".cop",0
_Text_FileExt_Prefs:	DC.B	".prefs",0
_Text_FileExt_File:	DC.B	".fil",0

			DC.B	0

_Text_ImageType_Image:	DC.B	"Image",0
_Text_ImageType_Raw:	DC.B	"Raw",0
_Text_ImageType_Bitmap:	DC.B	"Bitmap",0
_Text_ImageType_IFF:	DC.B	"IFF-ILBM",0

_Text_Image_Format:	DC.B	"Format : %-4ld",0
_Text_Image_Amount:	DC.B	"Amount : %-4ld",0
_Text_Image_Width:	DC.B	"Width : %-4ld",0
_Text_Image_Height:	DC.B	"Height : %-4ld",0
_Text_Image_Depth:	DC.B	"Depth : %-4ld",0

;Text_StoreType_Blank:	DC.B	"",0
;Text_StoreType_NoCols:	DC.B	"- Cols",0
;Text_StoreType_Sprite:	DC.B	"Sprite",0
;Text_StoreType_16Bit:	DC.B	"16 Bit",0
;Text_StoreType_Mask:	DC.B	"Mask",0

;Text_Buttongclass:	DC.B	"buttongclass",0

_Text_Req_Yes_No:	DC.B	"Yes|No",0
_Text_Req_DoItForgetIt:	DC.B	"Do It|Forget It",0

_Text_Mev3_Title:	DC.B	"Mev3.0 © 1994 M.J.Edwards",0

_Text_Mev3_Confirm:	DC.B	"Mev3.0 : Confirm...",0
_Text_Mev3_Query:	DC.B	"Mev3.0 : Query...",0
_Text_Mev3_Inform:	DC.B	"Mev3.0 : Information...",0

_Text_No_Mem:		DC.B	"Not enough memory",10
			DC.B	"for requested %s size"
			DC.B	0

_Text_File_Not_Found:	DC.B	"File not found",0

_Text_Are_You_Sure:	DC.B	"Delete : ",34,"%s",34,"!",10
			DC.B	"Are you sure?",0

_Text_File_Exists:	DC.B	34,"%s",34
			DC.B	" already exists !",10
			DC.B	"Overwrite?",0

_Text_Create_New:	DC.B	"This will create a new %s",10
			DC.B	"is this what you want?"
			DC.B	0

_Text_Map:		DC.B	"MAP",0
_Text_Tile:		DC.B	"TILE",0
_Text_Palette:		DC.B	"PALETTE",0
_Text_Shape:		DC.B	"SHAPE",0
;Text_Copper:		DC.B	"COPPER",0
;Text_Anim:		DC.B	"ANIM",0
;Text_Project:		DC.B	"PROJECT",0

_Text_Edit_XY_ShellT:	DC.B	"(    ,    )",0
_Text_Edit_XY_ShellM:	DC.B	"(    ,    )",0
_Text_Edit_Tile:		DC.B	"%04ld",0
_Text_Edit_Shape:	DC.B	"%03ld",0
_Text_Edit_Tile_Name:	DC.B	"TILE:%s",0
_Text_Edit_Map_Name:	DC.B	"MAP:%s",0
_Text_Edit_Shape_Name:	DC.B	"SHAPE:%s",0
_Text_Edit_Name:		DC.B	"%-25s",0
_Text_Edit_Map_X:	DC.B	"%03ld",0
_Text_Edit_Map_Y:	DC.B	"%03ld",0
_Text_Edit_Tile_X:	DC.B	"%03ld",0
_Text_Edit_Tile_Y:	DC.B	"%03ld",0
_Text_Edit_Shapes:	DC.B	"SHAPES",0
_Text_Edit_Define:	DC.B	"DEFINE %s",0
_Text_Edit_Width:	DC.B	"WIDTH",0
_Text_Edit_Height:	DC.B	"HEIGHT",0
_Text_Edit_Depth:	DC.B	"DEPTH",0
_Text_Edit_Amount:	DC.B	"AMOUNT",0

_Text_PrefsScreenTitle:	DC.B	"Mev"
				VersionString
			DC.B	" Preferences",0
_Text_FileScreenTitle:	DC.B	"Mev"
				VersionString
			DC.B	" File",0

_DefaultName:		DC.B	"Default",0
_SystemName:		DC.B	"System.font",0
_DpaintName:		DC.B	"dpaint.font",0
_Mev3Name:		DC.B	"mev3.font",0
_DOSName:		DC.B	"dos.library",0
_IntuitionName:		DC.B	"intuition.library",0
_GraphicsName:		DC.B	"graphics.library",0
_GadToolsName:		DC.B	"gadtools.library",0
_AslName:		DC.B	"asl.library",0
_UtilityName:		DC.B	"utility.library",0
_DiskFontName:		DC.B	"diskfont.library",0
_LayersName:		DC.B	"layers.library",0

_Work_Text:		DC.B	0
			DC.B	"OK",0
			DC.B	"Cancel",0
			DC.B	"Paint",0
			DC.B	"PickUp",0
			DC.B	"Erase",0
			DC.B	"Next",0
			DC.B	"Prev",0
			DC.B	"Apply",0
			DC.B	"@",0
			DC.B	"Retain Map",0
			DC.B	"Retain Tiles",0
			DC.B	" ",0
			DC.B	" ",0
			DC.B	"Mask",0
			DC.B	"NoCols",0
			DC.B	"16Bit",0
			DC.B	"Sprite",0
			DC.B	"24BitCol",0
			DC.B	"Format",0
			DC.B	"ZOOM",0
			DC.B	"Copy",0
			DC.B	"Exg",0
			DC.B	"Spread",0
			DC.B	"Pick",0
			DC.B	"Revert",0
			DC.B	"Undo",0
;			DC.B	"HEX DISPLAY",0
						
;			DC.B	"0",0
;			DC.B	"1",0
;			DC.B	"2",0
;			DC.B	"3",0
;			DC.B	"CLEAR",0
;			DC.B	"SPREAD",0			
			DC.B	-1
 EVEN
_Work_Image:		incbin	"mev3_icons3.img"
PCB:

 EVEN

*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****				Procedures				*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************

;	include	"mev3_file.s"
;	include	"mev3_forms.s"
	include	"mev3_gadget.s"
;	include	"mev3_none.s"
;	include	"mev3_map_edit.s"
;	include	"mev3_map_funcs.s"
;	include	"mev3_tile_edit.s"
;	include	"mev3_tile_funcs.s"
	include	"mev3_utility_A.s"
	include	"mev3_utility_B.s"
	include	"mev3_utility_C.s"
;	include	"mev3_preferences.s"

	include	"mev3_strings.s"

	INSTALL_Memory_Funcs
	INSTALL_Library_Funcs
	INSTALL_Font_Funcs
;	INSTALL_DiskFont_Funcs
	INSTALL_ScreenLock_Funcs
	INSTALL_Screen_Funcs	TagList
	INSTALL_Window_Funcs	TagList
	INSTALL_Visual_Funcs

_Rectangle_Tile:
	rts

 ENDC



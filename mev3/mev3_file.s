 IFND	MEV3_FILE_MAIN_S
MEV3_FILE_MAIN_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
**
*** $VER:mev3_file.s v3.0a (39.01)  © (10/January/95) M.J.Edwards
**
*


_Setup_File:
	lea	PC,gl

	move.w	_Project_Set,d0
	move.w	d0,_Load_Project_Set
	move.w	d0,_Old_Project_Set
	move.w	_Tile_Set,d0
	move.w	d0,_Load_Tile_Set
	move.w	d0,_Old_Tile_Set
	move.w	_Map_Set,d0
	move.w	d0,_Load_Map_Set
	move.w	d0,_Old_Map_Set
	move.w	_Palette_Set,d0
	move.w	d0,_Load_Palette_Set
	move.w	d0,_Old_Palette_Set
	move.w	_Shape_Set,d0
	move.w	d0,_Load_Shape_Set
	move.w	d0,_Old_Shape_Set
	move.w	_Copper_Set,d0
	move.w	d0,_Load_Copper_Set
	move.w	d0,_Old_Copper_Set
	move.w	_Anim_Set,d0
	move.w	d0,_Load_Anim_Set
	move.w	d0,_Old_Anim_Set

	lea	_Shutdown_File,a0
	call	_Set_Exit_Jump

	move.w	Prev_Prog_Section,d0
	ext.l	d0
	move.l	d0,_Tags_Cycle_Active+4
	
	call	_Open_File_Screen_Window	


	call	_Link_Wk_Gadgets

	rts

_Shutdown_File:
	lea	PC,gl
; remove all gadgets from file window

	call	_UnLink_Wk_Gadgets

	call	_Close_File_Screen_Window

	move.w	_Old_Project_Set,d0
	move.w	d0,_Project_Set
	move.w	_Old_Tile_Set,d0
	move.w	d0,_Tile_Set
	move.w	_Old_Map_Set,d0
	move.w	d0,_Map_Set
	move.w	_Old_Palette_Set,d0
	move.w	d0,_Palette_Set
	move.w	_Old_Shape_Set,d0
	move.w	d0,_Shape_Set
	move.w	_Old_Copper_Set,d0
	move.w	d0,_Copper_Set
	move.w	_Old_Anim_Set,d0
	move.w	d0,_Anim_Set


	call	_Clear_Exit_Jump
	rts


_Create_File_Gadgets:

	lea	_Tags_ListView,a0
	move.l	#0,4(a0)	; reset lv header to no list

	lea	_Wk_Gadgets,a0
	call	_CreateContext		; -> d0 = gad(get) pointer


	lea	_File_String_Gad,a0
	call	_Create_Gadgets_List
	lea	_Tags_ListView_Show,a1
	move.l	gtg_TheGadget(a0),4(a1)

	lea	_File_NewGadget_List,a0
	call	_Create_Gadgets_List


	rts

dbgf3:
_Link_String_Gad_To_ListView:
				; clear nodes of header
	lea	_List_View_Header,a0
	call	_NewList

	lea	_Tags_ListView_Show,a0
	move.l	_File_String_Gad+gtg_TheGadget,4(a0)

	lea	_File_ListView_Gad,a0
	move.l	gtg_TheGadget(a0),a0
	move.l	_Wk_Window,a1
	lea	_Tags_ListView,a2
;	move.l	#_List_View_Header,4(a2)	; reset lv header to new list
	call	_SetGadgetAttrs
	rts

_NewList:	; a0 - list ptr
	NEWLIST	a0
	rts

_SetGadgetAttrs:	; a0 - gtgadget, a1 - window, a2 - tags
	push	a1-a3/a6
	move.l	a2,a3
	sub.l	a2,a2
	base	GadTools
	call	GT_SetGadgetAttrsA
	pop	a1-a3/a6	
	rts

_Link_Wk_Gadgets:
	move.l	_Tags_Cycle_Active+4,d0
	call	_Create_Type_ListView_List

	call	_Link_String_Gad_To_ListView


;	move.l	_Tags_Cycle_Active+4,d0
;	call	_Create_Type_ListView_List
;
;	move.l	_Wk_Window,a0
;	call	_Refresh_Window

	call	_Update_ListView
	rts

_UnLink_Wk_Gadgets:
	move.l	_Wk_Window,a0
	call	_Remove_All_Window_Gadgets

	call	_Remove_Type_ListView_List

	rts

_Remove_Wk_Gadgets:
	lea	_Wk_Gadgets,a0
	call	_FreeGadgets
	rts

_Open_File_Screen_Window:
	sub.l	a0,a0
	lea	_File_Screen_TagList,a1
	call	_Open_Screen
	move.l	d0,_Wk_Screen

	move.l	_Wk_Screen,a0
	jsr	_GetVisualInfo
	move.l	d0,_Wk_VisualInfo
	move.l	d0,_Gl_VisualInfo

	call	_Create_File_Gadgets
	
	sub.l	a0,a0
	lea	_File_Window_TagList,a1
	move.l	_Wk_Screen,(_File_CustomScreen-_File_Window_TagList)+4(a1)
	move.l	_Wk_Gadgets,(_File_Gadgets-_File_Window_TagList)+4(a1)
	call	_Open_Window
	move.l	d0,_Wk_Window
	move.l	d1,_Wk_RastPort
;	move.l	d2,_Wk_ViewPort
	move.l	d3,_Wk_UserPort
	rts

_Close_File_Screen_Window:
; close window	
	move.l	_Wk_Window,a0
	call	_Close_Window
	move.l	#0,_Wk_Window

	call	_Remove_Wk_Gadgets

; remove visual info
	move.l	_Wk_VisualInfo,a0
	call	_RemoveVisualInfo
	move.l	#0,_Wk_VisualInfo
; close screen
	move.l	_Wk_Screen,a0
	call	_Close_Screen
	move.l	#0,_Wk_Screen
	rts


_Handle_File_Messages:
	lea	PC,gl

	move.w	#0,_Quit
.wait_for_message

	moveq.l	#0,d0
	move.l	d0,d1
	move.l	_Wk_UserPort,a0
	call	_Get_Window_SigBit
	call	_Wait_Sig

.next_message
	move.l	_Wk_UserPort,a0
	call	_GT_GetIMsg
	
	move.l	d0,a1
	tst.l	d0
	beq.s	.wait_for_message
	call	_Copy_Intuition_Message
	move.l	d0,a1
	call	_GT_ReplyIMsg		; reply as quickley as possible
	lea	_File_Message_List,a0
	call	_Execute_Intuition_Message
.not_file_message
	btst	#7,$BFE001
	beq.s	.handle_end
	tst.w	_Quit
	beq	.next_message
.handle_end

	rts

_File_Message_List:				; list of IDCMP's &  routines
	DC.L	IDCMP_REFRESHWINDOW,_Handle_File_RefreshWindow
	DC.L	IDCMP_MOUSEMOVE,_Handle_File_MouseMove
	DC.L	IDCMP_GADGETDOWN,_Handle_File_GadgetDown
	DC.L	IDCMP_GADGETUP,_Handle_File_GadgetUp
	DC.L	IDCMP_INTUITICKS,_Handle_File_IntuiTicks
	DC.L	-1

_File_Button_OK:
	move.w	#1,_Quit
	bra.s	_File_EndIt

_File_Button_Cancel:
	move.w	#-1,_Quit
_File_EndIt:
	move.w	Prev_Prog_Section,Run_Prog_Section
	move.w	#-1,Last_Prog_Section
	rts

dbgf2:
_File_Cycle_Change_Type:
	lea	_Message,a1
	move.w	im_Code(a1),d0
	ext.l	d0
	move.l	d0,_Tags_Cycle_Active+4

	move.l	_Tags_Cycle_Active+4,d0
	call	_Get_Type_Setting
	ext.l	d0
	move.l	d0,_Tags_ListView_Selected+4

	call	_Update_ListView
	
;	move.w	#0,_ListView_Set

;	call	_Remove_Type_ListView_List
;	move.l	_Tags_Cycle_Active+4,d0
;	call	_Create_Type_ListView_List
;
;	move.l	_Wk_Window,a0
;	call	_Refresh_Window

	rts

_Set_Type_Setting:	; d0 - type to set, d1 - value to set it to 
	push	d0/a0
	lea	_Actual_Sets,a0
	add.w	d0,d0
	move.w	d1,(a0,d0.w)
	pop	d0/a0
	rts

_Get_Type_Setting:	; d0 - type to get
	push	a0
	lea	_Actual_Sets,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	pop	a0
	rts		; d0 - value of type

dbgf4:
_File_ListView_Change_Type:
	lea	_Message,a1
	clr.l	d1
	move.w	im_Code(a1),d1
	move.l	_Tags_Cycle_Active+4,d0
	call	_Set_Type_Setting
;	move.w	d0,_ListView_Set


	call	_Display_Set_Details

;	move.w	#$F0F,$DFF180
	rts

;	BITDEF	gcBev,Normal,0
;	BITDEF	gcBev,Recess,1
;	BITDEF	gcBev,Text,2

dbgf5:
_Display_Set_Details:
	move.l	#320,d0
	move.l	#4,d1
	move.l	#300,d2
	move.l	#100,d3
	push	d0-d3
;	move.l	#gcBevF_Normal!gcBevF_Recess,d4
;	move.l	_Wk_Window,a0
;	call	_Draw_BevelBox
	pop	d0-d3
	add.l	d0,d2
	add.l	d1,d3
	addq.w	#4,d0
	addq.w	#2,d1
	subq.w	#8,d2
	subq.w	#4,d3
	move.l	_Wk_RastPort,_Global_RastPort
	call	_Clear_Box

	move.l	_Tags_Cycle_Active+4,d0
	call	_Find_Section_Type_Entry

	move.l	d0,a2
	move.l	a2,d0
	beq.s	.no_entry

	move.l	fet_CalcNodeProc(a2),d0
	move.l	d0,a0
	move.l	a0,d0
	beq.s	.no_entry
	clr.l	d0

	move.l	_Tags_Cycle_Active+4,d0
	call	_Get_Type_Setting

	push	a2
	jsr	(a0)
	pop	a2
	move.l	fet_DisplaySetDetails(a2),d0
	move.l	d0,a1
	move.l	a1,d0
	beq.s	.no_entry
	clr.l	d0

	jsr	(a1)

.no_entry


	rts




;_ListView_Set:		DC.W	0
;_ListView_Set:		DC.W	0

_File_String_Change_Type:
	move.w	#$FF0,$DFF180
;	lea	_File_String_Gad,a0
;	move.l	gtg_TheGadget(a0),a0
;	move.l	gg_SpecialInfo(a0),a0
;	move.l	si_Buffer(a0),a0

	move.l	_Tags_Cycle_Active+4,d0
	call	_Find_Section_Type_Entry

	move.l	d0,a2
	move.l	a2,d0
	beq.s	.no_entry

	move.l	fet_CalcNodeProc(a2),d0
	move.l	d0,a0
	move.l	a0,d0
	beq.s	.no_entry
	clr.l	d0
	move.l	_Tags_Cycle_Active+4,d0
	call	_Get_Type_Setting
;	move.w	_ListView_Set,d0

	jsr	(a0)
	move.l	map_Name(a0),a1

	lea	_File_String_Gad,a0
	move.l	gtg_TheGadget(a0),a0
	move.l	gg_SpecialInfo(a0),a0
	move.l	si_Buffer(a0),a0
	call	_StrCpy

	call	_Update_ListView

.no_entry
	
	rts

_Handle_File_RefreshWindow:
	move.l	_Wk_Window,a0
	call	_GT_BeginRefresh
	moveq.l	#TRUE,d0
	move.l	_Wk_Window,a0
	call	_GT_EndRefresh
	rts

_Handle_File_MouseMove:	
	rts

_Handle_File_GadgetDown:
	move.w	#$0F0,$DFF180
	rts

_Handle_File_GadgetUp:
;	move.w	#$0FF,$DFF180

	lea	_File_GadgetUp_List,a0
	jsr	_Execute_Gadget_List
	rts

_Handle_File_IntuiTicks:
	rts


_GT_BeginRefresh:	; a0 - window
	push	a0/a6
	base	GadTools
	call	GT_BeginRefresh
	pop	a0/a6
	rts

_GT_EndRefresh:	; a0 - window, d0 - complete?
	push	a0/a6
	base	GadTools
	call	GT_EndRefresh
	pop	a0/a6
	rts

_Create_ListView_Nodes:	; d0 - number of nodes, a0 - list header

	push	d0/a0			; alloc dummy header
	mulu	#LN_SIZE,d0
	call	_Malloc
	pull	d7/a0
	subq.w	#1,d7
	move.l	d0,LH_HEAD(a0)
	move.l	d0,a1
	clr.l	d0
	bra.s	.1
.0
	push	d0-d1/a0-a1
	move.l	d0,d1
	move.l	a1,a0
	addq.l	#1,d1
	mulu	#LN_SIZE,d0
	mulu	#LN_SIZE,d1
	push	a0
	add.l	d1,a0
	move.l	a0,LN_SUCC(a1,d0.w)
	pop	a0
	add.l	d0,a1
	move.l	a1,LN_PRED(a0,d1.w)	
	pop	d0-d1/a0-a1
	addq.l	#1,d0
.1
	dbra	d7,.0
	pull	d7/a0
	move.l	LH_HEAD(a0),a1
	mulu	#LN_SIZE,d0
	add.l	d0,a1
	move.l	a1,LH_TAILPRED(a0)		; point listview last pointer to last node
	push	a0
	addq.l	#4,a0
	move.l	a0,LN_SUCC(a1)		; point last node->next to listview mid pointer
	pop	a0
	pull	d7/a0
	move.l	LH_HEAD(a0),a1
	move.l	a0,LN_PRED(a1)		; point first node->prev to listview first pointer
	pop	d0/a0

	rts

_Remove_ListView_List:
	lea	_List_View_Header,a1
	move.l	LH_HEAD(a1),a0
	cmpa.l	a1,a0
	beq.s	.no_list
	call	_Free
.no_list
	lea	_List_View_Header,a0
	call	_NewList
	rts


_Create_Type_ListView_List:	; d0 - type from cycle_active
	call	_Find_Section_Type_Entry
	move.l	d0,a0
	move.l	a0,d0
	beq.s	.no_type_entry
	move.l	fet_GenNodeProc(a0),d0
	move.l	d0,a0
	move.l	a0,d0
	beq.s	.no_sub_to_execute
	jsr	(a0)
.no_sub_to_execute	
.no_type_entry
	rts

_Remove_Type_ListView_List:
	call	_Remove_ListView_List
	rts

_Update_ListView:
	lea	_File_ListView_Gad,a0
	move.l	gtg_TheGadget(a0),a0	; get the gadget pointer
	move.l	_Wk_Window,a1
	push	a0-a1
	lea	_Tags_ListView,a2
	move.l	#-1,4(a2)		; set lv header to -1 for listview
	call	_SetGadgetAttrs

	call	_Remove_Type_ListView_List
	move.l	_Tags_Cycle_Active+4,d0
	call	_Create_Type_ListView_List


	move.l	_Tags_Cycle_Active+4,d0
	call	_Get_Type_Setting
	move.l	d0,_Tags_ListView_Selected+4
	pop	a0-a1

	move.l	_Wk_Window,a1
	lea	_Tags_ListView,a2
	move.l	#_List_View_Header,4(a2)	; reset lv header to new list
	jsr	_SetGadgetAttrs

	move.l	_Wk_Window,a0
	jsr	_Refresh_Window
	rts


_Work_Out_Which_Set_To_Display:

	rts

*****************************************************************************
*									    *
**									   **
*									    *
*****************************************************************************

*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****			File Load & Save Routines			*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************

*****************************************************************************
*									    *
**									   **
*									    *
*****************************************************************************

    STRUCTURE	FileRequesterNames,0
	APTR	frn_Next
	APTR	frn_FullName
	APTR	frn_FileName
	APTR	frn_PathName
	LABEL	frn_SIZEOF
	
_FileReqStruc:	DC.L	0

_File_Requester:	; sp - (08)window - (12)hail - (16)ok_button_text - (20)init_file - (24)init_path - (28)pattern
	push	a0
	lea	(4*2)(sp),a0
	call	_Setup_ASL_Requester
	tst.l	d0
	beq.s	.no_setup_avail

	call	_ASL_Requester
	tst.l	d0
	beq.s	.no_asl_requester

.return_pathname
	move.l	(4*6)(sp),a1
	move.l	a1,d0
	move.l	d0,a1
	beq.s	.no_dir_passed
	move.l	_FileReq,a0
	move.l	rf_Dir(a0),a0
	call	_StrCpy
.no_dir_passed	
	
	move.l	_FileReq,d0
	call	_Create_FRN

.no_asl_requester
	push	d0
	call	_ShutDown_ASL_Requester
	pop	d0
.no_setup_avail	
	pop	a0
	rts

*****************************************************************************
*									    *
**									   **
*									    *
*****************************************************************************

_Create_1_FRN:	; a0 - dir, a1 - filename
	push	a2
	push	a0-a1
	move.l	#frn_SIZEOF,d0
	call	_Malloc
	push	d0
	moveq.l	#gcFileNameSize,d0	; getmem & copy filename into struct
	call	_Malloc
	pull	a0
	move.l	d0,frn_FileName(a0)

	move.l	#gcPathNameSize,d0	; getmem & copy pathname into struct
	call	_Malloc
	pull	a0
	move.l	d0,frn_PathName(a0)

	pop	a2

	pull	a0-a1
	move.l	frn_PathName(a2),a1
	call	_StrCpy
	pull	a0-a1
	move.l	a1,a0
	move.l	frn_FileName(a2),a1
	call	_StrCpy
	
	move.l	frn_PathName(a2),a0
	move.l	frn_FileName(a2),a1
	push	a2
	call	_Join_Path_And_FileName
	pop	a2
	move.l	d0,frn_FullName(a2)
	move.l	a2,d0
	pop	a0-a1
	pop	a2
	rts	; d0 - frn


_Create_FRN:	; d0 - asl_struct (FileReq)
	push	a1-a2
	move.l	d0,a0
	tst.l	rf_NumArgs(a0)
	bne.s	.lots_of_files
.only_one_file
	move.l	d0,a2
	move.l	rf_Dir(a2),a0
	move.l	rf_File(a2),a1
	call	_Create_1_FRN

;	move.l	#frn_SIZEOF,d0
;	call	_Malloc
;	push	d0
;	moveq.l	#gcFileNameSize,d0	; getmem & copy filename into struct
;	call	_Malloc
;	pull	a0
;	move.l	d0,frn_FileName(a0)
;	move.l	rf_File(a2),a0
;	move.l	d0,a1
;	call	_StrCpy
;
;	move.l	#gcPathNameSize,d0	; getmem & copy pathname into struct
;	call	_Malloc
;	pull	a0
;	move.l	d0,frn_PathName(a0)
;	move.l	rf_Dir(a2),a0
;	move.l	d0,a1
;	call	_StrCpy
;	
;	move.l	rf_Dir(a2),a0
;	move.l	rf_File(a2),a1
;	call	_Join_Path_And_FileName
;	pull	a0
;	move.l	d0,frn_FullName(a0)
;	pop	d0

	bra	.no_more_files

.lots_of_files

; a0 - Filereq
; a1 - frn_
; a2 - arglist

	push	a0
	move.l	d0,a0
	move.l	sp,a1
	move.l	rf_ArgList(a0),a2
	move.l	rf_NumArgs(a0),d7
	bra.s	.next_file_pass
.next_file

	move.l	#frn_SIZEOF,d0
	call	_Malloc
	move.l	d0,frn_Next(a1)
	move.l	d0,a1
	push	a0-a1
	moveq.l	#gcFileNameSize,d0	; getmem & copy filename into struct
	call	_Malloc
	pull	a0-a1
	move.l	d0,frn_FileName(a1)
	move.l	d0,a1
	move.l	wa_Name(a2),a0
	call	_StrCpy
	move.l	#gcPathNameSize,d0	; getmem & copy pathname into struct
	call	_Malloc
	pull	a0-a1
	move.l	d0,frn_PathName(a1)
	move.l	d0,a1
	move.l	rf_Dir(a0),a0
	call	_StrCpy
	pull	a0-a1
	move.l	rf_Dir(a0),a0
	move.l	wa_Name(a2),a1
	call	_Join_Path_And_FileName
	pop	a0-a1
	move.l	d0,frn_FullName(a1)

	add.l	#wa_SIZEOF,a2	
.next_file_pass
	dbra	d7,.next_file
	pop	d0
.no_more_files
	pop	a1-a2
	rts


_Free_FRN:	; d0 - frn_struct
	push	a0-a1
	move.l	d0,a0
.next_struct
	move.l	frn_Next(a0),a1
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.no_more
	push	a0
	move.l	frn_FullName(a0),a0
	call	_Free
	pull	a0
	move.l	frn_FileName(a0),a0
	call	_Free
	pull	a0
	move.l	frn_PathName(a0),a0
	call	_Free
	pop	a0
	call	_Free
	move.l	a1,a0
	bra.s	.next_struct
.no_more
	pop	a0-a1
	rts


GetNextFRN	macro	; An,An
	move.l	frn_Next(\1),\2
	endm

GetFRNFullname	macro	; An,An
	move.l	frn_FullName(\1),\2
	endm

_FRN:			DC.L	0
_Init_File:		DC.L	0
_FileRequester_Title:	DC.B	"Load",0

	EVEN

dbgf1:
_File_Button_ListView_Add:
	pea	FILF_MULTISELECT ;|FILF_PATGAD
	call	_Create_File_Pattern
	push	d0
	move.l	_Init_Path,d0
	push	d0
	move.l	_Init_File,d0
	push	d0
	pea	_Text_OK+1
	pea	_FileRequester_Title
	move.l	_Wk_Window,d0
	push	d0
	call	_File_Requester
	lea	(7*4)(sp),sp
	move.l	d0,_FRN

	move.l	d0,a0
.next_file
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.no_more_files
	push	a0
	st	_File_Add
;	GetFRNFullname	a0,a0
	call	_Load_A_File
	pop	a0
	GetNextFRN	a0,a0
	bra.s	.next_file
.no_more_files
	move.l	_FRN,d0
	call	_Free_FRN
	call	_Remove_File_Pattern
	call	_Update_ListView
	rts


;_File_Button_ListView_Remove:
;	rts


_File_Button_ListView_Save:
	rts

_File_Button_Load:

	call	_Calculate_Node_From_Cycle_ListView

	beq.s	.no_entry

	move.l	map_Name(a0),d0

	pea	FILF_MULTISELECT ; |FILF_PATGAD
;	pea	0.w
;	call	_Create_File_Pattern
;	push	d0
	pea	0.w
	move.l	_Init_Path,d0
	push	d0	
	move.l	map_Name(a0),d0
;	move.l	_Init_File,d0
	push	d0
	pea	_Text_OK+1
	pea	_FileRequester_Title
	move.l	_Wk_Window,d0
	push	d0
	call	_File_Requester
	lea	(7*4)(sp),sp
	move.l	d0,_FRN

	move.l	d0,a0
.next_file
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.no_more_files
	push	a0
;	GetFRNFullname	a0,a0
	sf	_File_Add
	call	_Load_A_File
	pop	a0
	GetNextFRN	a0,a0
	bra.s	.next_file
.no_more_files
	move.l	_FRN,d0
	call	_Free_FRN
	call	_Update_ListView
;	call	_Remove_File_Pattern
.no_entry
	rts


_Calculate_Node_From_Cycle_ListView:
	move.l	_Tags_Cycle_Active+4,d0
	call	_Find_Section_Type_Entry

	move.l	d0,a2
	move.l	a2,d0
	beq.s	.no_entry

	move.l	fet_CalcNodeProc(a2),d0
	move.l	d0,a0
	move.l	a0,d0
	beq.s	.no_entry
	clr.l	d0

	move.l	_Tags_Cycle_Active+4,d0
	call	_Get_Type_Setting

	push	a2
	jsr	(a0)
	pop	a2

	move.l	a0,d0
	move.l	d0,a0

.no_entry
	rts
dbgf6:
_File_Button_Save:

	call	_Calculate_Node_From_Cycle_ListView

;	move.l	_Tags_Cycle_Active+4,d0
;	call	_Find_Section_Type_Entry
;
;	move.l	d0,a2
;	move.l	a2,d0
;	beq.s	.no_entry
;
;	move.l	fet_CalcNodeProc(a2),d0
;	move.l	d0,a0
;	move.l	a0,d0
;	beq.s	.no_entry
;	clr.l	d0
;
;	move.l	_Tags_Cycle_Active+4,d0
;	call	_Get_Type_Setting
;
;	push	a2
;	jsr	(a0)
;	pop	a2
;
;	move.l	a0,d0
;	move.l	d0,a0

	beq.s	.no_entry
	
	move.l	map_Name(a0),a1
	move.l	_Init_Path,a0
	call	_Create_1_FRN

;	push	d0
;	move.l	_Tags_Cycle_Active+4,d0
;	call	_Get_Type_Setting
;	pop	a0
	
	push	d0
	move.l	d0,a0
	call	_Save_A_File
	pop	d0

	call	_Free_FRN
.no_entry

	rts

_File_Pattern_Ptr:	DC.L	0
_File_Pattern_Part0:	DC.B	"(#?%s)",0

 EVEN

_Create_File_Pattern:
	move.l	#64,d0
	call	_Malloc
	move.l	d0,_File_Pattern_Ptr
	move.l	d0,a1
	move.l	_Tags_Cycle_Active+4,d0
	call	_Find_Section_Type_Entry
	tst.l	d0
	beq.s	.no_type_avail

	move.l	d0,a2
	move.l	fet_Extension(a2),d0

	push	d0			; args
	pea	_File_Pattern_Part0	; format
	push	a1			; buffer
	call	_SPrintf
	lea	(3*4)(sp),sp
	move.l	_File_Pattern_Ptr,d0
.no_type_avail
	rts



_Remove_File_Pattern:
	move.l	_File_Pattern_Ptr,a0
	call	_Free
	rts


_Check_If_File_Exists:	; a0 - filename
	push	d1-d7/a0-a6
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	base	DOS
	call	Open
	tst.l	d0
	beq.s	.not_exist
	move.l	d0,d1
	base	DOS
	call	Close
	moveq.l	#1,d0
.not_exist
	pop	d1-d7/a0-a6	
	rts		; d0 = 1 - if exists ; d0 = 0 - if not present


_Load_A_File:	; a0 - frn
	push	a0
	move.l	frn_FullName(a0),a0
	call	_Find_Extension_Type_Entry
	tst.l	d0
	beq.s	.not_of_desired_type
	move.l	d0,a1
	call	_Check_If_File_Exists
	tst.l	d0
	beq.s	.no_file_exists
	move.l	fet_CountNodeProc(a1),a2
	move.l	a2,d0
	move.l	d0,a2
	beq.s	.no_jump
	jsr	(a2)		; count number of nodes
	tst.b	_File_Add
	beq.s	.not_file_add
	push	a0
;	addq.w	#1,d0		; increase count
	move.w	fet_Type(a1),d1
	add.l	d1,d1
	lea	_Actual_Sets,a0
	move.w	d0,(a0,d1.w)
	pop	a0
.not_file_add	
	move.l	fet_LoadProc(a1),a2
	move.l	a2,d0
	move.l	d0,a2
	beq.s	.no_jump
	pull	a0
	jsr	(a2)
.no_jump

.no_file_exists
.not_of_desired_type
	pop	a0
	rts


_Save_As_A_File:
	rts

_Save_A_File:	; a0 - frn
	push	a0
	move.l	frn_FullName(a0),a0
	call	_Find_Extension_Type_Entry

	tst.l	d0
	beq.s	.not_of_desired_type
	move.l	d0,a1
	call	_Check_If_File_Exists
	tst.l	d0
	beq.s	.no_file_exists
	pull	a0
	move.l	frn_FileName(a0),d0
	push	d0
	pea	_Text_Req_Yes_No	; gadget
	pea	_Text_File_Exists	; body
	pea	_Text_Mev3_Confirm	; title
	move.l	_Wk_Window,-(sp)	; window
	call	_EasyRequestArgs
	lea	5*4(sp),sp
	tst.l	d0
	beq.s	.file_save_end

.no_file_exists
	move.l	fet_SaveProc(a1),a2
	move.l	a2,d0
	move.l	d0,a2
	beq.s	.no_jump
	pull	a0
	jsr	(a2)
.no_jump
.file_save_end
.not_of_desired_type
	pop	a0
	rts


_StrRevSrch:	; a0 - str1, a1 - str2 
	push	d1/a0-a1
	call	_StrLen
	move.l	d0,d1
	bra.s	.next_char_pass
.next_char
	push	d1/a0
	add.l	d1,a0
	call	_StrCmp
	pop	d1/a0
	tst.b	d0
	beq.s	.found_extension
.next_char_pass
	dbra	d1,.next_char
	moveq.l	#0,d1
.found_extension
	move.l	d1,d0
	pop	d1/a0-a1
	rts


_Find_Extension_Type_Entry:	; a0 - filename
	push	a0-a3
	move.l	a0,a3	
	lea	_FileExtensionList,a2
	pea	$2E000000
	move.l	sp,a1
	call	_StrRevSrch
	lea	4(sp),sp
	tst.w	d0
	beq.s	.type_not_found
	add.l	d0,a0
.check_next_type
	move.w	fet_Type(a2),d0
	tst.w	d0
	bmi.s	.type_not_found
	move.l	fet_Extension(a2),a1
	call	_StrCmp
	tst.b	d0
	beq.s	.type_found
	add.l	#fet_SIZEOF,a2
	bra.s	.check_next_type
.type_found
	move.l	a2,d0
	bra.s	.end_find_type
.type_not_found
	moveq.l	#0,d0
.end_find_type
	pop	a0-a3
	rts


_Find_Section_Type_Entry:	; d0 - type (from cycle gad)
	push	a1-a2
	lea	_FileExtensionList,a2

.check_next_type
	tst.w	fet_Type(a2)
	bmi.s	.type_not_found
	cmp.w	fet_Type(a2),d0
	beq.s	.type_found
	
	add.l	#fet_SIZEOF,a2
	bra.s	.check_next_type
.type_not_found
	sub.l	a2,a2
.type_found
	move.l	a2,d0
	pop	a1-a2
	rts	;	d0 - fet_type entry ptr


_FillIn_Nodes_For_ListView:	; a0 - first_node_ptr, a1 - Listview_node_header
	move.l	LH_HEAD(a1),a1	
	move.l	map_Next(a0),a0
	
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.end_while
	move.l	map_Name(a0),LN_NAME(a1)
	move.l	map_Next(a0),a0
	move.l	LN_SUCC(a1),a1
	bra.s	.while
.end_while
	rts


_Generate_Project_Node_List:
	call	_Count_Project_Nodes
	tst.l	d0
	beq.s	.end_create_project_list
	lea	_List_View_Header,a0
	call	_Create_ListView_Nodes

	move.l	_Project_Node,a0
	lea	_List_View_Header,a1
	call	_FillIn_Nodes_For_ListView

.end_create_project_list
	rts

_Generate_Map_Node_List:
	call	_Count_Map_Nodes
	tst.l	d0
	beq.s	.end_create_map_list	
	lea	_List_View_Header,a0
	call	_Create_ListView_Nodes

	move.l	_Map_Node,a0
	lea	_List_View_Header,a1
	call	_FillIn_Nodes_For_ListView

.end_create_map_list
	rts

_Generate_Tile_Node_List:
	call	_Count_Tile_Nodes
	tst.l	d0
	beq.s	.end_create_tile_list	
	lea	_List_View_Header,a0
	call	_Create_ListView_Nodes

	move.l	_Tile_Node,a0
	lea	_List_View_Header,a1
	call	_FillIn_Nodes_For_ListView
.end_create_tile_list
	rts

_Generate_Palette_Node_List:
	call	_Count_Palette_Nodes
	tst.l	d0
	beq.s	.end_create_palette_list	
	lea	_List_View_Header,a0
	call	_Create_ListView_Nodes

	move.l	_Palette_Node,a0
	lea	_List_View_Header,a1
	call	_FillIn_Nodes_For_ListView

.end_create_palette_list
	rts

_Generate_Shape_Node_List:
	rts
_Generate_Anim_Node_List:
	rts
_Generate_Copper_Node_List:
	rts
_Generate_Prefs_Node_List:
	rts

_Calc_Tile_File_Size:
	move.w	tile_Width(a5),d0
	jsr	_Tile_Width_Convert
	move.l	d0,d1
	mulu	tile_Height(a5),d1
	move.w	tile_Depth(a5),d0
	call	_Check_For_Tile_Mask	
	mulu	d1,d0
	mulu	tile_Amount(a5),d0
	rts


_Tile_Width_Convert:	; d0 - tile width
	btst	#3,_File_Format
	beq.s	.not_16_bits
	add.w	#$F,d0
	asr.w	#4,d0
	add.w	d0,d0
	bra.s	.tile_width_ok
.not_16_bits
	add.w	#$7,d0
	asr.w	#3,d0	; # bytes wide
.tile_width_ok
	rts

_Make_Even:	; d0 - number
	btst	#0,d0
	beq.s	.even
	addq.w	#1,d0
.even
	rts

_Inverse_Power_Of_2:
	push	d1-d2
	moveq.l	#8,d1
	moveq.l	#0,d2
	bra.s	.con_1
.con
	btst	#0,d0
	bne.s	.con_end
	asr.l	#1,d0
	addq.l	#1,d2
.con_1
	dbra	d1,.con
.con_end
	move.w	d2,d0
	pop	d1-d2
	rts

_Read_Tile_Colours:	; d0 - # cols, a0 - location to copy to
	push	a0
	push	d0
	add.l	d0,d0
	move.l	d0,_File_Length
	jsr	_Read_File
	pop	d0
	pull	a0
	move.l	_Disk_Buffer,a1
	exg.l	a0,a1

	move.l	d0,d4
	move.l	d0,d5	
	moveq.l	#0,d0
.next_colour
	cmp.w	d5,d0
	beq.s	.no_more_colours
	move.w	(a0)+,d3
	move.w	d3,d2
	lsr.w	#4,d2
	move.w	d2,d1
	lsr.w	#4,d1
	move.b	#$F,d4
	and.w	d4,d1
	and.w	d4,d2
	and.w	d4,d3

	move.w	d1,d4
	lsl.w	#4,d4
	or.w	d4,d1

	move.w	d2,d4
	lsl.w	#4,d4
	or.w	d4,d2

	move.w	d3,d4
	lsl.w	#4,d4
	or.w	d4,d3

	move.l	d0,d4
	add.l	d4,d4
	add.l	d0,d4
	move.b	d1,0(a1,d4.l)
	move.b	d2,1(a1,d4.l)
	move.b	d3,2(a1,d4.l)

	addq.w	#1,d0

	bra.s	.next_colour
.no_more_colours	

	pop	a0
	rts

_Map_Format_Routine_0:
	move.l	#0,d0
	addq.l	#1,d6
	move.w	map_Width(a5),d0
	cmp.l	d6,d0
	bne.s	50$
	moveq.l	#0,d6

	move.l	#0,d0
	addq.l	#1,d7
	move.w	map_Height(a5),d0
	cmp.l	d7,d0
	bne.s	50$
	moveq.l	#0,d7
50$		
	rts

_Map_Format_Routine_1:
	move.l	#0,d0
	addq.l	#1,d7
	move.w	map_Height(a5),d0
	cmp.l	d7,d0
	bne.s	50$
	moveq.l	#0,d7

	move.l	#0,d0
	addq.l	#1,d6
	move.w	map_Width(a5),d0
	cmp.l	d6,d0
	bne.s	50$
	moveq.l	#0,d6
50$
	rts

_Check_For_Tile_Mask:
	push	d1
	move.w	tile_Flags(a5),d1
	btst	#FLGB_MASK,d1
	beq.s	.no_mask_present
	addq.w	#1,d0
.no_mask_present
	pop	d1
	rts

_Tile_Format_Routine_0:		; width,height,depth,amount

	move.l	#0,d0
	addq.l	#1,d4
	move.w	tile_Width(a5),d0
	add.w	#7,d0
	asr.w	#3,d0
	cmp.l	d4,d0
	bne.s	50$
	moveq.l	#0,d4

	move.l	#0,d0
	addq.l	#1,d5
	move.w	tile_Height(a5),d0
	cmp.l	d5,d0
	bne.s	50$
	moveq.l	#0,d5

	move.l	#0,d0
	addq.l	#1,d7
	move.w	tile_Depth(a5),d0
	call	_Check_For_Tile_Mask
	cmp.l	d7,d0
	bne.s	50$
	moveq.l	#0,d7

	moveq.l	#0,d0
	addq.l	#1,d6
	move.w	tile_Amount(a5),d0
	cmp.l	d6,d0
	bne.s	50$
	moveq.l	#0,d6
50$
	rts

	
_Tile_Format_Routine_1:		; width,depth,height,amount
	move.l	#0,d0
	addq.l	#1,d4
	move.w	tile_Width(a5),d0
	add.w	#7,d0
	asr.w	#3,d0
	cmp.l	d4,d0
	bne.s	50$
	moveq.l	#0,d4

	move.l	#0,d0
	addq.l	#1,d7
	move.w	tile_Depth(a5),d0
	call	_Check_For_Tile_Mask
	cmp.l	d7,d0
	bne.s	50$
	moveq.l	#0,d7

	move.l	#0,d0
	addq.l	#1,d5
	move.w	tile_Height(a5),d0
	cmp.l	d5,d0
	bne.s	50$
	moveq.l	#0,d5

	moveq.l	#0,d0
	addq.l	#1,d6
	move.w	tile_Amount(a5),d0
	cmp.l	d6,d0
	bne.s	50$
	moveq.l	#0,d6
50$
	rts

_Tile_Format_Routine_2:		; width,amount,depth,height
	move.l	#0,d0
	addq.l	#1,d4
	move.w	tile_Width(a5),d0
	add.w	#7,d0
	asr.w	#3,d0
	cmp.l	d4,d0
	bne.s	50$
	moveq.l	#0,d4
	
	moveq.l	#0,d0
	addq.l	#1,d6
	move.w	tile_Amount(a5),d0
	cmp.l	d6,d0
	bne.s	50$
	moveq.l	#0,d6

	move.l	#0,d0
	addq.l	#1,d7
	move.w	tile_Depth(a5),d0
	call	_Check_For_Tile_Mask
	cmp.l	d7,d0
	bne.s	50$
	moveq.l	#0,d7

	move.l	#0,d0
	addq.l	#1,d5
	move.w	tile_Height(a5),d0
	cmp.l	d5,d0
	bne.s	50$
	moveq.l	#0,d5
50$
	rts

_Tile_Format_Routine_3:		; width,amount,height,depth
	move.l	#0,d0
	addq.l	#1,d4
	move.w	tile_Width(a5),d0
	add.w	#7,d0
	asr.w	#3,d0
	cmp.l	d4,d0
	bne.s	50$
	moveq.l	#0,d4

	moveq.l	#0,d0
	addq.l	#1,d6
	move.w	tile_Amount(a5),d0
	cmp.l	d6,d0
	bne.s	50$
	moveq.l	#0,d6

	move.l	#0,d0
	addq.l	#1,d5
	move.w	tile_Height(a5),d0
	cmp.l	d5,d0
	bne.s	50$
	moveq.l	#0,d5

	move.l	#0,d0
	addq.l	#1,d7
	move.w	tile_Depth(a5),d0
	call	_Check_For_Tile_Mask
	cmp.l	d7,d0
	bne.s	50$
	moveq.l	#0,d7
50$
	rts


_Read_Buffer:
	push	d0-d7/a0-a6
	move.l	#gcDiskBufferSize,_File_Length
	move.l	_Disk_Buffer,_File_Buffer
	jsr	_Read_File
	pop	d0-d7/a0-a6
	rts

_Write_Buffer:
	push	d0-d7/a0-a6
	move.l	d2,_File_Length
	move.l	_Disk_Buffer,_File_Buffer
	jsr	_Write_File
	pop	d0-d7/a0-a6
	rts


_Read_File:
	move.l	_File_Handle,d1
	move.l	_File_Buffer,d2
	move.l	_File_Length,d3
	jsr	_Read
	move.l	d0,_Bytes_Read
	rts

_Write_File:
	move.l	_File_Handle,d1
	move.l	_File_Buffer,d2
	move.l	_File_Length,d3
	jsr	_Write
	move.l	d0,_Bytes_Read
	rts

_Read:		; d1 - handle, d2 - buffer, d3 - length
	push	a6
	move.l	_DOSBase,a6
	jsr	_LVORead(a6)
	pop	a6
	rts	; d0 - bytes read in

_Write:		; d1 - handle, d2 - buffer, d3 - length
	push	a6
	move.l	_DOSBase,a6
	jsr	_LVOWrite(a6)
	pop	a6
	rts	; d0 - bytes read in



;	move.l	_File_Name_Ptr,d1
;	move.l	#MODE_OLDFILE,d2
;	jsr	Open_File
;	tst.l	d0
;	bne.s	.file_open_ok
;				; error file did not open
;	bra.s	.file_load_end
;.file_open_ok
;	move.l	d0,_File_Handle
;
;				; do loading of data here
;
;	jsr	Load_Chosen_Data
;
;	move.l	_File_Handle,d1
;	jsr	Close_File
;.file_load_end
;	rts
;
;Load_Chosen_Data:
;	move.l	_Ed_Screen,a0
;	lea	sc_BitMap(a0),a0
;	move.l	bm_Planes(a0),a0
;	move.l	a0,_Disk_Buffer		; point to buffer
;	move.l	a0,_File_Buffer
;	move.l	Gad_Tags_Cycle_Active+4,d0
;	call	_Cycle_To_ProgSec
;	cmp.l	#SECTION_TILE,d0
;	bne.s	.not_tile_load
;	jsr	_Load_Tiles
;	bra	.load_data_end
;.not_tile_load
;	cmp.l	#SECTION_MAP,d0
;	bne.s	.not_map_load
;	jsr	_Load_Map
;	bra	.load_data_end
;.not_map_load
;	cmp.l	#SECTION_PALETTE,d0
;	bne.s	.not_palette_load
;	jsr	_Load_Palette
;	bra	.load_data_end
;.not_palette_load
;	nop
;.load_data_end
;	rts

;Save_Chosen_Data:
;	move.l	_Ed_Screen,a0
;	lea	sc_BitMap(a0),a0
;	move.l	bm_Planes(a0),a0
;	move.l	a0,_Disk_Buffer		; point to buffer
;	move.l	a0,_File_Buffer
;	move.l	Gad_Tags_Cycle_Active+4,d0
;	call	_Cycle_To_ProgSec
;	cmp.l	#SECTION_TILE,d0
;	bne.s	.not_tile_load
;	jsr	_Save_Tiles
;	bra	.load_data_end
;.not_tile_load
;	cmp.l	#SECTION_MAP,d0
;	bne.s	.not_map_load
;	jsr	_Save_Map
;	bra	.load_data_end
;.not_map_load
;	cmp.l	#SECTION_PALETTE,d0
;	bne.s	.not_palette_load
;	jsr	_Save_Palette
;	bra	.load_data_end
;.not_palette_load
;	nop
;.load_data_end
;	rts

_Open_File:	; d1 - name, d2 - accessmode
	push	a6
	base	DOS
	call	Open
	pop	a6
	rts

_Close_File:	; d1 - file handle
	push	a6
	base	DOS
	call	Close
	pop	a6
	rts



_File_Length:		DC.L	0
_File_Buffer:		DC.L	0
_File_Size:		DC.L	0
_File_Format:		DC.B	0
_File_Add:		DC.B	0
_Disk_Buffer:		DC.L	0
_Bytes_Read:		DC.L	0


;_Calculate_Tile_Node:
;	move.w	_Tile_Set,d0
;	subq.w	#1,d0
;	mulu	#tile_SIZEOF,d0
;	lea	_Tile_Info,a0
;	add.l	d0,a0
;	rts

;_Calculate_Map_Node:
;	move.w	_Map_Set,d0
;	subq.w	#1,d0
;	mulu	#map_SIZEOF,d0
;	lea	_Map_Info,a0
;	add.l	d0,a0
;	rts

;_Inverse_Power_Of_2:
;	push	d1-d2
;	moveq.l	#8,d1
;	moveq.l	#0,d2
;	bra.s	.con_1
;.con
;	btst	#0,d0
;	bne.s	.con_end
;	asr.l	#1,d0
;	addq.l	#1,d2
;.con_1
;	dbra	d1,.con
;.con_end
;	move.w	d2,d0
;	pop	d1-d2
;	rts

;_Load_Palette:
;	move.l	#2,_File_Length
;	jsr	Read_File
;;	jsr	_Calculate_Tile_Node
;;	moveq.l	#0,d0
;;	move.w	tile_Palette(a0),d0
;	move.l	_Disk_Buffer,a2
;	clr.l	d0
;	move.w	(a2),d0		; #of colours
;	jsr	_Inverse_Power_Of_2	;depth
;	move.l	d0,d1
;	move.w	#0,d2		; flags
;	move.w	_Palette_Set,d0
;	jsr	_Replace_Palette_Node
;
;	jsr	_Calculate_Palette_Node
;	move.w	palette_Depth(a0),d0
;	move.l	palette_Location(a0),a0
;	jsr	_Power_Of_2
;	jsr	Read_Tile_Colours
;	jsr	_Calculate_Palette_Node
;	move.l	palette_Name(a0),a0
;	jsr	Save_Name_To_Structure
;
;;dbgf3:
;;	jsr	_Calculate_Palette_Node
;;	jsr	_Create_Form_Palette
;;	jsr	_Free_Form_Palette
;
;	rts

_SeekToPosInFile:	; d0 - pos
	push	d1-d3/a6
	move.l	d0,d2	
	move.l	_File_Handle,d1
	move.l	#OFFSET_BEGINNING,d3
	base	DOS
	call	Seek
	pop	d1-d3/a6
	rts

***********************************************************

*							  *
**							 **
***			Load Routines			***
**							 **
*							  *

***********************************************************


_Load_Project:
	rts

*******************
* i love you babe *
*******************

_Load_Map:	*****************************************
* a0 -> frn						*
*********************************************************
	push	a0
	move.l	frn_FullName(a0),d1
	move.l	#MODE_OLDFILE,d2
	call	_Open_File
	tst.l	d0
	bne.s	.file_open_ok
	pop	a0
	rts
.file_open_ok
	move.l	d0,_File_Handle
	move.l	_Wk_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	8(a0),a0
	move.l	a0,_Disk_Buffer
	move.l	a0,_File_Buffer

	move.l	#6,_File_Length
	jsr	_Read_File

	move.l	_Disk_Buffer,a2
;	move.b	fm_Format(a2),_Map_Format
	clr.l	d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.w	_Map_Set,d0
	move.w	fm_Width(a2),d1
	move.w	fm_Height(a2),d2
	move.b	fm_Format(a2),d3

	push	a2
.add_map_if
	tst.b	_File_Add
	bne.s	.add_map_else
	call	_Replace_Map_Node
	bra.s	.add_map_endif
.add_map_else
	call	_Add_Map_Node
.add_map_endif
	pop	a2
	call	_Calculate_Map_Node
	move.l	a0,a5
	move.b	fm_Unit(a2),map_UnitSize(a5)
	move.b	fm_Format(a2),map_Format(a5)
	
	move.w	map_Width(a5),d0
	mulu	map_Height(a5),d0
	clr.l	d1
	move.b	map_UnitSize(a5),d1
	push	a0
	move.l	_UtilityBase,a0
	jsr	_LVOUmult32(a0)
	pop	a0
	move.l	d0,_File_Size
	move.l	map_Location(a5),a1	; load data address to
	move.l	_Disk_Buffer,a0		; load buffer address from
	moveq.l	#0,d0
	moveq.l	#0,d1			; 
	moveq.l	#0,d2			; 
	moveq.l	#0,d3			; 
	moveq.l	#0,d4			; 
	moveq.l	#0,d5			; 
	moveq.l	#0,d6			; 
	moveq.l	#0,d7			; 
.map_load_loop
	move.l	_File_Size,d0
	cmp.l	d0,d1
	bhs	.map_load_complete

	cmpi.l	#0,d2
	bhi.s	.not_finished_with_data
	jsr	_Read_Buffer	
	move.l	#gcDiskBufferSize,d2
	move.l	_Disk_Buffer,a0		; load from buffer address
.not_finished_with_data
	move.l	map_Location(a5),a1	; load to data address
	push	d0/a1
	add.l	d4,a1
	moveq.l	#0,d0
	move.b	map_UnitSize(a5),d0
	cmpi.w	#1,d0
	bne.s	.not_unit_size_1
	moveq.l	#0,d0
	move.b	(a0)+,d0
	move.w	d0,(a1)
	bra.s	.not_unit_size_2
.not_unit_size_1
	cmpi.w	#2,d0
	bne.s	.not_unit_size_2
	move.w	(a0)+,d0
	move.w	d0,(a1)
.not_unit_size_2
	pop	d0/a1
	
	push	d0-d4
	move.b	map_Format(a5),d0
	andi.b	#$01,d0
	cmpi.b	#0,d0
	bne.s	.not_stored_0
	call	_Map_Format_Routine_0
	bra.s	.not_stored_1
.not_stored_0
	cmpi.b	#1,d0
	bne.s	.not_stored_1
	call	_Map_Format_Routine_1
.not_stored_1
	pop	d0-d4

	moveq.l	#0,d4
	move.l	d7,d4
	mulu	map_Width(a5),d4
	add.l	d6,d4
	add.l	d4,d4
	
	moveq.l	#0,d0
	move.b	map_UnitSize(a5),d0
	add.l	d0,d1
	sub.l	d0,d2

	btst	#$A,$DFF016
	beq.s	.map_load_complete
	bra	.map_load_loop

.map_load_complete

	move.l	_File_Handle,d1
	call	_Close_File

	call	_Calculate_Map_Node
	move.l	map_Name(a0),a0
	pull	a1
	move.l	frn_FileName(a1),a1
	call	_Save_Name_To_Structure
	pop	a0
	rts


_Load_Tiles:	*****************************************
* a0 -> frn						*
*********************************************************
	push	a0
	move.l	frn_FullName(a0),d1
	move.l	#MODE_OLDFILE,d2
	call	_Open_File
	tst.l	d0
	bne.s	.file_open_ok
	pop	a0
	rts
;	bra	.load_tiles_end
.file_open_ok
	move.l	d0,_File_Handle
	move.l	_Wk_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	8(a0),a0
	move.l	a0,_Disk_Buffer
	move.l	a0,_File_Buffer
				; do loading of data here

;**** Future File Information - TO BE implemented ****
	move.l	#12,_File_Length		; read in "FORM"
	call	_Read_File
	move.l	_Disk_Buffer,a0
	move.l	(a0),d0
	cmp.l	#ID_FORM,d0
	bne.s	.load_old_2_0		; not a form file so load the onld type files

	move.l	8(a0),d0
	cmp.l	#ID_TILE,d0		; check if tile form
	beq.s	.load_form_tiles
	cmp.l	#ID_ILBM,d0		; check if iff ilbm (pic) file
	beq.s	.load_ilbm_file

;							  ;
;;							 ;;
;;;		Unknown tile file format.....		;;;
;;							 ;;
;							  ;

	pop	a0
	rts

.load_ilbm_file
	pop	a0
	rts

.load_form_tiles			; load the all new v3.0 form tiles
	moveq.l	#0,d0
	call	_SeekToPosInFile
	pop	a0
	
	rts

.load_old_2_0				; load the old type v2.0 of tiles
	moveq.l	#0,d0
	call	_SeekToPosInFile

	move.l	#6,_File_Length
	jsr	_Read_File
	move.l	_Disk_Buffer,a2
	move.b	ft_Format(a2),_File_Format
	clr.l	d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.w	_Tile_Set,d0
	move.b	ft_Width(a2),d1
	move.b	ft_Height(a2),d2
	move.b	ft_Depth(a2),d3
	move.w	ft_Amount(a2),d4
	addq.w	#1,d4
	move.b	ft_Format(a2),d5


	push	d0-d7/a0
	btst	#FLGB_NOCOLS,d5
	bne.s	.tile_no_colours
	push	d3
;	call	_Count_Palette_Nodes
;	move.w	d0,_Palette_Set
	pop	d1
	moveq.l	#FLGF_INCLD,d2
;
;;
;;; select which pallette to do , replace the current one or add a new one
;;
;
.add_pale_if
	tst.b	_File_Add
	bne.s	.add_pale_else
	call	_Replace_Palette_Node
	bra.s	.add_pale_endif
.add_pale_else
	call	_Add_Palette_Node
.add_pale_endif

	call	_Calculate_Palette_Node
	moveq.l	#0,d0
	move.w	palette_Depth(a0),d0
	call	_Power_Of_2
	move.l	palette_Location(a0),a0
	call	_Read_Tile_Colours
;	move.l	palette_Name(a0),a1
;	pull	a0
;	move.l	tile_Name(a0),a0
;	bsr	_StrCpy
;	pop	a0
.tile_no_colours	
	pop	d0-d7/a0

	ori.w	#FLGF_FORGETCOLS,d5

	tst.b	_File_Add
	beq.s	.not_add_tile
	call	_Add_Tile_Node
	bra.s	.end_add_tile
.not_add_tile
	call	_Replace_Tile_Node
.end_add_tile

	call	_Calculate_Tile_Node

	move.l	a0,a5
	
	jsr	_Calc_Tile_File_Size
	move.l	d0,_File_Size
	move.l	tile_Location(a5),a1	; load data address	to
	move.l	_Disk_Buffer,a0		; load data address	from

	moveq.l	#0,d0
	moveq.l	#0,d1			; count number bytes converted
	moveq.l	#0,d2			; count number buffer bytes
	moveq.l	#0,d3			; memory location tab
	moveq.l	#0,d4			; width count (in bytes)
	moveq.l	#0,d5			; line count
	moveq.l	#0,d6			; num count
	moveq.l	#0,d7			; plane count

.tile_load_loop:

	move.l	_File_Size,d0		; check total bytes read in
	cmp.l	d0,d1
	bhs	.tile_load_complete	; leave if greater of equal to total bytes

	bhi	.tile_load_complete
	cmpi.l	#0,d2
	bhi.s	.not_ready_to_read_buffer
	jsr	_Read_Buffer	
	move.l	#gcDiskBufferSize,d2			; buffer size
	move.l	_Disk_Buffer,a0		; load from buffer address
.not_ready_to_read_buffer

	move.l	tile_Location(a5),a1	; load to data address

	push	d0/a1
	add.l	d3,a1
	move.b	(a0),(a1)
	adda.l	#1,a0
	pop	d0/a1
	
	push	d0-d3

	move.b	_File_Format,d0
	andi.b	#$03,d0
	cmpi.b	#0,d0
	bne.s	.not_format_0
	jsr	_Tile_Format_Routine_0
	bra.s	.not_format_end
.not_format_0
	cmpi.b	#1,d0
	bne.s	.not_format_1
	jsr	_Tile_Format_Routine_1
	bra.s	.not_format_end
.not_format_1
	cmpi.b	#2,d0
	bne.s	.not_format_2
	jsr	_Tile_Format_Routine_2
	bra.s	.not_format_end
.not_format_2
;	cmpi.b	#3,d0
;	bne.s	.not_format_3
	jsr	_Tile_Format_Routine_3
	bra.s	.not_format_end
.not_format_3
	nop
.not_format_end

	pop	d0-d3


	moveq.l	#0,d3
	move.l	d4,d3		; width
		
	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	jsr	_Tile_Width_Convert
	jsr	_Make_Even
;	move.l	NumWriteBytes,d0
;	jsr	Make_Even
	mulu	d5,d0		; height
	add.l	d0,d3

	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	jsr	_Tile_Width_Convert
	jsr	_Make_Even
;	move.l	NumWriteBytes,d0
;	jsr	Make_Even
	mulu	tile_Height(a5),d0
	mulu	d6,d0		; number
	add.l	d0,d3

	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	jsr	_Tile_Width_Convert
	jsr	_Make_Even
;	move.l	NumWriteBytes,d0
;	jsr	Make_Even
	mulu	tile_Height(a5),d0
	mulu	tile_Amount(a5),d0
	mulu	d7,d0		; depth
	add.l	d0,d3

	addq.l	#1,d1		; increase byte converted
	subq.l	#1,d2		; decrease bytes left in buffer
	btst	#$A,$DFF016
	beq.s	.tile_load_complete
	bra	.tile_load_loop
.tile_load_complete

	move.l	_File_Handle,d1
	call	_Close_File


;	move.w	_Tile_Set,d0
	jsr	_Calculate_Tile_Node
	move.l	tile_Name(a0),a0
	pull	a1
	move.l	frn_FileName(a1),a1
	jsr	_Save_Name_To_Structure

	btst	#FLGB_NOCOLS,_File_Format	; #5
	bne.s	.tile_no_colours_name
	
;	move.w	_Palette_Set,d0
	jsr	_Calculate_Palette_Node
	pull	a1
	move.l	frn_FileName(a1),a1
	move.l	palette_Name(a0),a0
	jsr	_Save_Name_To_Structure

	jsr	_Calculate_Palette_Node
	move.l	palette_Name(a0),a0
	move.b	#$2e,d0		; '.'
	jsr	_Find_Last_Char
	move.b	#0,(a0,d0.w)
	lea	_Text_FileExt_Palette,a1
	exg.l	a0,a1
	jsr	_StrCat
.tile_no_colours_name

;dbgf1:
;	jsr	_Calculate_Tile_Node
;	jsr	_Create_Form_Tile
;	jsr	_Free_Form_Tile


.load_tiles_end
	pop	a0
	rts


_Load_Palette:	*****************************************
* a0 -> frn						*
*********************************************************

	push	a0
	move.l	frn_FullName(a0),d1
	move.l	#MODE_OLDFILE,d2
	call	_Open_File
	tst.l	d0
	bne.s	.file_open_ok
	pop	a0
	rts
.file_open_ok
	move.l	d0,_File_Handle
	move.l	_Wk_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	8(a0),a0
	move.l	a0,_Disk_Buffer
	move.l	a0,_File_Buffer

	move.l	#2,_File_Length
	jsr	_Read_File

	move.l	_Disk_Buffer,a2
	clr.l	d0
	move.w	(a2),d0		; #of colours
	jsr	_Inverse_Power_Of_2	;depth
	move.l	d0,d1
	move.w	#0,d2		; flags
	move.w	_Palette_Set,d0

	tst.b	_File_Add
	beq.s	.not_add_palette
	call	_Add_Palette_Node
	bra.s	.end_add_palette
.not_add_palette
	call	_Replace_Palette_Node
.end_add_palette

	jsr	_Calculate_Palette_Node
	move.w	palette_Depth(a0),d0
	move.l	palette_Location(a0),a0
	jsr	_Power_Of_2
	jsr	_Read_Tile_Colours

	move.l	_File_Handle,d1
	call	_Close_File

;	move.w	_Tile_Set,d0
	jsr	_Calculate_Palette_Node
	move.l	palette_Name(a0),a0
	pull	a1
	move.l	frn_FileName(a1),a1
	jsr	_Save_Name_To_Structure

	pop	a0
	rts

_Load_Shapes:
	rts
_Load_Copper:
	rts
_Load_Anim:
	rts
_Load_Prefs:
	rts

***********************************************************

*							  *
**							 **
***			Save Routines			***
**							 **
*							  *

***********************************************************

_Save_Project:
	rts

_Save_Map:	*****************************************
* a0 -> frn						*
*********************************************************
	push	a0
	move.l	frn_FullName(a0),d1
	move.l	#MODE_NEWFILE,d2
	call	_Open_File
	tst.l	d0
	bne.s	.file_open_ok
	pop	a0
	rts
.file_open_ok
	move.l	d0,_File_Handle

	move.l	_Wk_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	8(a0),a0
	move.l	a0,_Disk_Buffer
	move.l	a0,_File_Buffer

	jsr	_Calculate_Map_Node
	move.l	a0,a5

	move.l	_Disk_Buffer,a2

	move.w	map_Width(a5),fm_Width(a2)
	move.w	map_Height(a5),fm_Height(a2)
	move.b	map_Format(a5),fm_Format(a2)
;	move.b	map_UnitSize(a5),fm_Unit(a2)

	move.w	map_Flags(a5),d0
;	btst	#FLGB_AUTOUNIT,d0
;	beq.s	.not_auto_set
	
	move.b	#2,map_UnitSize(a5)		; premature set unit size to word size

	move.w	map_Tiles(a5),d0
	call	_Calc_Tile_Node
;	move.l	_Tile_Node,a0
;	jsr	_Get_Node_Ptr	; get node of tiles for this map
	move.w	tile_Amount(a0),d0
	cmp.w	#255,d0
	bhi.s	.not_unit_1
	move.b	#1,map_UnitSize(a5)		; if total tile < 255 then set map unitsize to 1 for byte size
.not_unit_1

.not_auto_set
	move.b	map_UnitSize(a5),fm_Unit(a2)

	move.l	#6,_File_Length
	bsr	_Write_File

	move.w	map_Width(a5),d0
	mulu	map_Height(a5),d0
	clr.l	d1
	move.b	fm_Unit(a2),d1
	push	a0
	move.l	_UtilityBase,a0
	jsr	_LVOUmult32(a0)
	pop	a0
;	mulu	d1,d0
	move.l	d0,_File_Size

	move.l	map_Location(a5),a0	; load data from address
	move.l	_Disk_Buffer,a1		; load data to address
	moveq.l	#0,d0
	moveq.l	#0,d1			; 
	moveq.l	#0,d2			; 
	moveq.l	#0,d3			; 
	moveq.l	#0,d4			; 
	moveq.l	#0,d5			; 
	moveq.l	#0,d6			; 
	moveq.l	#0,d7			; 

.map_save_loop


	move.l	_File_Size,d0
	cmp.l	d0,d1
	beq	.map_save_complete

	cmpi.l	#gcDiskBufferSize,d2
	blo.s	.save_buffer_not_full
	bsr	_Write_Buffer
	moveq.l	#0,d2
	move.l	_Disk_Buffer,a1		; load data to address
.save_buffer_not_full
	move.l	map_Location(a5),a0	; load data from address
	push	d0/a0
	add.l	d4,a0

	moveq.l	#0,d0
	move.b	map_UnitSize(a5),d0
	cmpi.w	#1,d0
	bne.s	15$
	moveq.l	#0,d0
	move.w	(a0),d0
	move.b	d0,(a1)+
	bra.s	20$
15$
	cmpi.w	#2,d0
	bne.s	20$
	move.w	(a0),d0
	move.w	d0,(a1)+
20$
	pop	d0/a0

	push	d0-d4

	move.b	map_Format(a5),d0
	andi.b	#$01,d0
	cmpi.b	#0,d0
	bne.s	50$
	bsr	_Map_Format_Routine_0
	bra.s	51$
50$
	cmpi.b	#1,d0
	bne.s	51$
	bsr	_Map_Format_Routine_1
51$
	pop	d0-d4

;	moveq.l	#0,d4
	move.l	d7,d4
	mulu	map_Width(a5),d4
	add.l	d6,d4
	add.l	d4,d4
	
	moveq.l	#0,d0
	move.b	map_UnitSize(a5),d0
	add.l	d0,d1
	add.l	d0,d2

	btst	#$A,$DFF016
	beq.s	.map_save_finish
	bra	.map_save_loop

.map_save_complete
	bsr	_Write_Buffer


.map_save_finish
	move.l	_File_Handle,d1
	call	_Close_File
	pop	a0
	rts	

_Save_Tiles:	*****************************************
* a0 -> frn						*
*********************************************************
	push	a0
	move.l	frn_FullName(a0),d1
	move.l	#MODE_NEWFILE,d2
	call	_Open_File
	tst.l	d0
	bne.s	.file_open_ok
	pop	a0
	rts
.file_open_ok
	move.l	d0,_File_Handle

	move.l	_Wk_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	8(a0),a0
	move.l	a0,_Disk_Buffer
	move.l	a0,_File_Buffer

	jsr	_Calculate_Tile_Node
	move.l	a0,a5

	move.l	_Disk_Buffer,a2
	move.w	tile_Amount(a5),d0
	subq.w	#1,d0
	move.w	d0,ft_Amount(a2)
	move.w	tile_Width(a5),d0
	move.b	d0,ft_Width(a2)
	move.w	tile_Height(a5),d0
	move.b	d0,ft_Height(a2)
	move.w	tile_Depth(a5),d0
	move.b	d0,ft_Depth(a2)
	move.w	tile_Flags(a5),d0
	move.b	d0,ft_Format(a2)

	move.l	#6,_File_Length
	bsr	_Write_File

	move.w	tile_Flags(a5),d5


	btst	#FLGB_NOCOLS,d5
	bne.s	.no_palette_include
	push	a0-a2/a5
	moveq.l	#0,d0
	move.w	tile_Depth(a5),d0
	call	_Power_Of_2
	move.l	d0,d7
	move.l	d0,d6
	move.w	tile_Palette(a5),d0
	move.l	_Palette_Node,a0
	call	_Get_Node_Ptr
	move.l	palette_Location(a0),a0
	move.l	a2,a1
	bra.s	.next_palette_pass
.next_palette
	
	moveq.l	#0,d3
	move.w	#$00F0,d4
	move.b	(a0)+,d0
	and.w	d4,d0
	lsl.w	#4,d0
	or.w	d0,d3
	move.b	(a0)+,d0
	and.w	d4,d0
	or.w	d0,d3
	move.b	(a0)+,d0
	and.w	d4,d0
	lsr.w	#4,d0
	or.w	d0,d3
	move.w	d3,(a1)+
.next_palette_pass
	dbra	d7,.next_palette
	move.l	d6,d0
	add.l	d0,d0
	move.l	d0,_File_Length
	bsr	_Write_File		; write # of Colors into file
	pop	a0-a2/a5
.no_palette_include

	bsr	_Calc_Tile_File_Size
	move.l	d0,_File_Size

	move.l	tile_Location(a5),a0	; load data address	from
	move.l	_Disk_Buffer,a1		; load data address	to

	moveq.l	#0,d0
	moveq.l	#0,d1			; count number bytes converted
	moveq.l	#0,d2			; count number buffer bytes
	moveq.l	#0,d3			; 
	moveq.l	#0,d4			; memory location tab
	moveq.l	#0,d5			; tile count
	moveq.l	#0,d6			; line count (height)
	moveq.l	#0,d7			; plane count

.tile_save_loop
	move.l	_File_Size,d0
	cmp.l	d0,d1
	bhs	.tile_save_complete

	cmpi.l	#gcDiskBufferSize,d2
	blo.s	.save_buffer_not_full
	bsr	_Write_Buffer
	moveq.l	#0,d2
	move.l	_Disk_Buffer,a1		; load to buffer address
.save_buffer_not_full
	move.l	tile_Location(a5),a0	; load from data address
	push	d0/a0
	add.l	d3,a0
	move.b	(a0),(a1)
	addq.l	#1,a1
	pop	d0/a0
	
	push	d0-d3

	move.w	tile_Flags(a5),d0
	andi.b	#FLGF_STB0!FLGF_STB1,d0
	cmpi.b	#0,d0
	bne.s	.not_store_0
	bsr	_Tile_Format_Routine_0
	bra.s	.end_find_store
.not_store_0
	cmpi.b	#1,d0
	bne.s	.not_store_1
	bsr	_Tile_Format_Routine_1
	bra.s	.end_find_store
.not_store_1
	cmpi.b	#2,d0
	bne.s	.not_store_2
	bsr	_Tile_Format_Routine_2
	bra.s	.end_find_store
.not_store_2
	bsr	_Tile_Format_Routine_3

.end_find_store

	pop	d0-d3

	moveq.l	#0,d3
	move.l	d4,d3		; width
		

	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	call	_Tile_Width_Convert
	call	_Make_Even
	mulu	d5,d0		; height
	add.l	d0,d3

	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	call	_Tile_Width_Convert
	call	_Make_Even
	mulu	tile_Height(a5),d0
	mulu	d6,d0		; number
	add.l	d0,d3

	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	call	_Tile_Width_Convert
	call	_Make_Even
	mulu	tile_Height(a5),d0
	mulu	tile_Amount(a5),d0
	mulu	d7,d0		; depth
	add.l	d0,d3

	addq.l	#1,d1
	addq.l	#1,d2
	btst	#$A,$DFF016
	beq.s	.tile_save_finish
	bra	.tile_save_loop
.tile_save_complete

	bsr	_Write_Buffer

	move.l	_File_Handle,d1
	call	_Close_File

.tile_save_finish
	pop	a0
	rts

_Save_Palette:	*****************************************
* a0 -> frn						*
*********************************************************
	push	a0
	move.l	frn_FullName(a0),d1
	move.l	#MODE_NEWFILE,d2
	call	_Open_File
	tst.l	d0
	bne.s	.file_open_ok
	pop	a0
	rts
.file_open_ok
	move.l	d0,_File_Handle

	move.l	_Wk_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	8(a0),a0
	move.l	a0,_Disk_Buffer
	move.l	a0,_File_Buffer

	jsr	_Calculate_Palette_Node
	move.l	a0,a5

	move.l	_Disk_Buffer,a2

	move.w	palette_Depth(a5),d0
	call	_Power_Of_2
	move.w	d0,fp_NumColours(a2)
	
	move.w	palette_Flags(a5),d0
;	btst	#FLGB_AUTOUNIT,d0
;	beq.s	.not_auto_set	
;.not_auto_set

	move.l	#2,_File_Length
	bsr	_Write_File

	move.w	palette_Depth(a5),d0
	call	_Power_Of_2
	add.l	d0,d0
	move.l	d0,_File_Size

	move.l	palette_Location(a5),a0	; load data from address
	move.l	_Disk_Buffer,a1		; load data to address
	moveq.l	#0,d0
	moveq.l	#0,d1			; 
	moveq.l	#0,d2			; file buffer counter
	moveq.l	#0,d3			; 
	moveq.l	#0,d4			; pointer into node mem
	moveq.l	#0,d5			; colour #
	moveq.l	#0,d6			; 
	moveq.l	#0,d7			; 

.palette_save_loop


	move.l	_File_Size,d0
	cmp.l	d0,d1
	bhs	.palette_save_complete

	cmpi.l	#gcDiskBufferSize,d2
	blo.s	.save_buffer_not_full
	bsr	_Write_Buffer
	moveq.l	#0,d2
	move.l	_Disk_Buffer,a1		; load data to address
.save_buffer_not_full
	move.l	palette_Location(a5),a0	; load data from address
	push	d0/a0
	add.l	d4,a0

	moveq.l	#0,d3
	move.b	(a0)+,d0
	andi.w	#$00F0,d0
	lsl.w	#4,d0
	or.w	d0,d3
	move.b	(a0)+,d0
	andi.w	#$00F0,d0
	or.w	d0,d3
	move.b	(a0)+,d0
	andi.w	#$00F0,d0
	lsr.w	#4,d0
	or.w	d0,d3
	andi.w	#$0FFF,d3
	move.w	d3,(a1)+
	pop	d0/a0
	addq.l	#1,d5	; next colour

	moveq.l	#0,d4
	move.l	d5,d4
	add.l	d4,d4
	add.l	d5,d4	; calc colour offset

	addq.l	#2,d1	; num bytes per RGB comp
	addq.l	#2,d2	; num bytes per RGB comp
	
	btst	#$A,$DFF016
	beq.s	.palette_save_finish
	bra	.palette_save_loop

.palette_save_complete
	bsr	_Write_Buffer

	move.l	_File_Handle,d1
	call	_Close_File

.palette_save_finish
	pop	a0
	rts

_Save_Shapes:
	rts
_Save_Copper:
	rts
_Save_Anim:
	rts
_Save_Prefs:
	rts

_Text_Formatting_Buffer:	DS.L	(256/4)

_Text_Project_Details:	DC.B	"Name        : %s",10
			DC.B	0

_Text_Map_Details:	DC.B	"Name        : %s",10
			DC.B	"Width       : %ld",10
			DC.B	"Height      : %ld",10
			DC.B	"Tiles Set   : %s",10
			DC.B	"Shape Set   : %s",10
			DC.B	"Copper Set  : %s"
			DC.B	0

_Text_Tile_Details:	DC.B	"Name        : %s",10
			DC.B	"Width       : %ld",10
			DC.B	"Height      : %ld",10
			DC.B	"Depth       : %ld",10
			DC.B	"Amount      : %ld",10
			DC.B	"Palette Set : %s",10
			DC.B	"Anim Set    : %s"
			DC.B	0
			
  EVEN

_Display_Project_Set_Details:
	push	a0
	moveq.l	#1,d0
	call	_SetAPen
	pop	a0

	move.l	proj_Name(a0),d0
	push	d0			;*

	pea	_Text_Project_Details	;*
	pea	_Text_Formatting_Buffer	;*

	move.l	_Wk_RastPort,d0
	push	d0			;*

	pea	20.w			;*
	pea	340.w			;*
	call	_TextPrintf
	lea	(6*4)(sp),sp
	rts

_Display_Map_Set_Details:	; a0 -> node
	push	a0
	moveq.l	#1,d0
	call	_SetAPen
	pop	a0

	push	a0
	clr.l	d0
;	move.w	map_Copper(a0),d0
;	call	_Calc_Copper_Node
;	move.l	copper_Name(a0),d0
	pop	a0
	push	d0			;*

	push	a0
	clr.l	d0
	move.w	map_Tiles(a0),d0
	call	_Calc_Shape_Header_Node
	move.l	shphdr_Name(a0),d0
	pop	a0
	push	d0			;*

	push	a0
	clr.l	d0
	move.w	map_Tiles(a0),d0
	call	_Calc_Tile_Node
	move.l	tile_Name(a0),d0
	pop	a0
	push	d0			;*

	clr.l	d0
	move.w	map_Height(a0),d0
	push	d0			;*
	clr.l	d0
	move.w	map_Width(a0),d0
	push	d0			;*
	move.l	map_Name(a0),d0
	push	d0			;*

	pea	_Text_Map_Details	;*
	pea	_Text_Formatting_Buffer	;*

	move.l	_Wk_RastPort,d0
	push	d0			;*

	pea	20.w			;*
	pea	340.w			;*
	call	_TextPrintf
	lea	(11*4)(sp),sp

	rts

_Display_Tile_Set_Details:
	push	a0
	moveq.l	#1,d0
	call	_SetAPen
	pop	a0

	push	a0
	clr.l	d0
;	move.w	tile_Animations(a0),d0
;	call	_Calc_Anim_Node
;	move.l	anim_Name(a0),d0
	pop	a0
	push	d0			;*

	push	a0
	clr.l	d0
	move.w	tile_Palette(a0),d0
	call	_Calc_Palette_Node
	move.l	palette_Name(a0),d0
	pop	a0
	push	d0			;*

	clr.l	d0
	move.w	tile_Amount(a0),d0
	push	d0			;*
	clr.l	d0
	move.w	tile_Depth(a0),d0
	push	d0			;*
	clr.l	d0
	move.w	tile_Height(a0),d0
	push	d0			;*
	clr.l	d0
	move.w	tile_Width(a0),d0
	push	d0			;*
	move.l	tile_Name(a0),d0
	push	d0			;*

	pea	_Text_Tile_Details	;*
	pea	_Text_Formatting_Buffer	;*

	move.l	_Wk_RastPort,d0
	push	d0			;*

	pea	20.w			;*
	pea	340.w			;*
	call	_TextPrintf
	lea	(12*4)(sp),sp
	rts
_Display_Palette_Set_Details:
	color	$0F0
	rts
_Display_Shape_Set_Details:
	rts
_Display_Anim_Set_Details:
	rts
_Display_Copper_Set_Details:
	rts
_Display_Prefs_Set_Details:
	rts




_Find_Last_Char:	; d0 - char to find, a0 - string
	push	d1-d2/a0
	push	d0
	jsr	_StrLen
	pop	d2
	moveq.l	#0,d1
	bra.s	.next_char_p
.next_char
	cmp.b	(a0,d0.w),d2
	beq.s	.found_char
.next_char_p
	dbra	d0,.next_char
.found_char	
	pop	d1-d2/a0
	rts

_Save_Name_To_Structure:	; a0 - string buffer, a1 - filename
	push	a0-a1
	exg.l	a0,a1
	push	a0-a1
	move.b	#$2e,d0		; '.'
	jsr	_Find_Last_Char
	pop	a0-a1
;
	bra.s	.no_extension_found
;
	tst.w	d0
	bmi.s	.no_extension_found
	jsr	_StrnCpy
	move.b	#0,(a1,d0.w)
	bra.s	.save_name_ok
.no_extension_found
	jsr	_StrCpy
.save_name_ok
	pop	a0-a1
	rts




    STRUCTURE	FileExtensionType,0
	UWORD	fet_Type		; 0-8
	UWORD	fet_Section		; SECTION_?????
	APTR	fet_Extension		; _Text_FileType_????
	APTR	fet_LoadProc		; _Load_????
	APTR	fet_SaveProc		; _Save_????
	APTR	fet_GenNodeProc		; _Generate_????_Node_List
	APTR	fet_CountNodeProc	; _Count_????_Nodes
	APTR	fet_CalcNodeProc	; _Calc_????_Node
	APTR	fet_DisplaySetDetails	; _Calc_????_Node
;	APTR	fet_ConvSection2Type	; 0
;	APTR	fet_ConvType2Section	; 0
	LABEL	fet_SIZEOF

SetFileExtType	macro	; type,section,extension,Load,Save,NodeCalc
	DC.W	\1,\2
	DC.L	\3,\4,\5,\6,\7,\8,\9
	endm

_FileExtensionList:
	SetFileExtType	0,SECTION_PROJECT,_Text_FileExt_Project,_Load_Project,_Save_Project,_Generate_Project_Node_List,_Count_Project_Nodes,_Calc_Project_Node,_Display_Project_Set_Details
	SetFileExtType	1,SECTION_MAP,_Text_FileExt_Map,_Load_Map,_Save_Map,_Generate_Map_Node_List,_Count_Map_Nodes,_Calc_Map_Node,_Display_Map_Set_Details
	SetFileExtType	2,SECTION_TILE,_Text_FileExt_Tile,_Load_Tiles,_Save_Tiles,_Generate_Tile_Node_List,_Count_Tile_Nodes,_Calc_Tile_Node,_Display_Tile_Set_Details
	SetFileExtType	3,SECTION_PALETTE,_Text_FileExt_Palette,_Load_Palette,_Save_Palette,_Generate_Palette_Node_List,_Count_Palette_Nodes,_Calc_Palette_Node,_Display_Palette_Set_Details
	SetFileExtType	4,SECTION_SHAPE,_Text_FileExt_Shape,_Load_Shapes,_Save_Shapes,_Generate_Shape_Node_List,_Count_Shape_Nodes,_Calc_Shape_Node,_Display_Shape_Set_Details
	SetFileExtType	5,SECTION_ANIM,_Text_FileExt_Anim,_Load_Anim,_Save_Anim,_Generate_Anim_Node_List,_Count_Anim_Nodes,_Calc_Anim_Node,_Display_Anim_Set_Details
	SetFileExtType	6,SECTION_COPPER,_Text_FileExt_Copper,_Load_Copper,_Save_Copper,_Generate_Copper_Node_List,_Count_Copper_Nodes,_Calc_Copper_Node,_Display_Copper_Set_Details
	SetFileExtType	7,SECTION_PREFS,_Text_FileExt_Prefs,_Load_Prefs,_Save_Prefs,_Generate_Prefs_Node_List,_Count_Prefs_Nodes,_Calc_Prefs_Node,_Display_Prefs_Set_Details
;	SetFileExtType	8,SECTION_FILE,_Text_FileExt_File,_Load_File,_Save_File,_Generate_File_Node_List,_Count_File_Nodes,0,_Display_File_Set_Details
	DC.W	-1


_Join_Path_And_FileName:	; a0 - dir name, a1 - filename
	push	a2
	push	a0-a1
	move.l	#gcFullNameSize,d0
	jsr	_Malloc
	move.l	d0,a2
	pull	a0-a1

	move.l	a2,a1
	call	_StrCpy
	
	move.l	a2,d1			; move buffer to d1
	pull	a0-a1
	move.l	a1,d2			; move filename to d2
	move.l	#gcFullNameSize,d3	; size of buffer
	push	a2
	call	_AddPart
	pop	a2

	pop	a0-a1
	move.l	a2,d0
	pop	a2	
	rts	;	d0 - filename & path

_AddPart:	; d1 - buffer, d2 - filename, d3 - sizeofbuffer
	push	d1-d3/a6
	move.l	_DOSBase,a6
	jsr	_LVOAddPart(a6)		; connect the two
	pop	d1-d3/a6
	rts

;Split_Dir_File_Names:	; a0 - filebuffer
;	jsr	_Free
;	rts




*****************************************************************************
*****************************************************************************

*									    *
**									   **
***									  ***
****									 ****
*****			     File Tags & Lists				*****
****									 ****
***									  ***
**									   **
*									    *

*****************************************************************************
*****************************************************************************

_File_Screen_TagList:
	Tag	SA_Width,640
	Tag	SA_Height,200
	Tag	SA_Depth,3
	Tag	SA_DisplayID,HIRES_KEY
	Tag	SA_Title,_GraphicsName
	Tag	SA_AutoScroll,TRUE
;	Tag	SA_Pens,Minus_1
	Tag	SA_Pens,Screen_DriPens
;	Tag	SA_Colors,Screen_Colours
	Tag_End

;			DC.L	SA_Width,640
;			DC.L	SA_Height,200
;			DC.L	SA_Depth,3
;			DC.L	SA_DisplayID,HIRES_KEY
;			DC.L	SA_Title,Text_Mev3_Title
;			DC.L	SA_AutoScroll,TRUE
;;			DC.L	SA_Pens,Screen_DriPens
;;			DC.L    SA_Colors,Screen_Colours
;			DC.L	SA_Pens,Minus_1
;			DC.L	TAG_DONE

Screen_Colours:
			DC.W     0,$04,$06,$08
			DC.W     1,$00,$02,$04
			DC.W     2,$0F,$0F,$0F
			DC.W     3,$07,$09,$0B
			DC.W	 4,$05,$07,$09
			DC.W    -1,$00,$00,$00

Screen_DriPens:		DC.W    -1 ;,0,1,2,3,1,4,2,0,3,1,2,1,-1

_File_Window_TagList:
;	Tag	WA_IDCMP,IDCMP_GADGETUP!IDCMP_RAWKEY!CYCLEIDCMP!BUTTONIDCMP!IDCMP_REFRESHWINDOW!LISTVIEWIDCMP!SLIDERIDCMP
	Tag	WA_IDCMP,CYCLEIDCMP!BUTTONIDCMP!SLIDERIDCMP!TEXTIDCMP!IDCMP_INTUITICKS!IDCMP_MOUSEBUTTONS!IDCMP_DISKINSERTED!IDCMP_DISKREMOVED!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW!LISTVIEWIDCMP
_File_CustomScreen:
	Tag	WA_CustomScreen,0
_File_Gadgets:
	Tag	WA_Gadgets,0
;	Tag	WA_Backdrop,0
	Tag	WA_Top,11
	Tag	WA_Height,200-11
;	Tag	WA_BlockPen,1
;	Tag	WA_DetailPen,2
	Tag	WA_AutoAdjust,TRUE
	Tag	WA_ScreenTitle,_Text_FileScreenTitle
	Tag	WA_Flags,WFLG_SMART_REFRESH|WFLG_BACKDROP|WFLG_ACTIVATE
	Tag_End

;DC.L    WA_IDCMP,CYCLEIDCMP!BUTTONIDCMP!SLIDERIDCMP!TEXTIDCMP!IDCMP_INTUITICKS!IDCMP_MOUSEBUTTONS!IDCMP_DISKINSERTED!IDCMP_DISKREMOVED!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW!LISTVIEWIDCMP
;DC.L    WA_Flags,WFLG_SMART_REFRESH|WFLG_BACKDROP|WFLG_ACTIVATE

_List_View_Header:	DS.B	LH_SIZE


_Tags_Disabled:	
	Tag	GA_Disabled,TRUE
_Tags_UnderScore:
	Tag	GT_Underscore,'_'
_Tags_None:
	Tag_End

_Tags_Toggle:
	Tag	GA_ToggleSelect,TRUE
	Tag_End

_Tags_Cycle_Label:
	Tag	GTCY_Labels,_Cycle_FileType
_Tags_Cycle_Active:
	Tag	GTCY_Active,0
	Tag_End

_Tags_ListView:
	Tag	GTLV_Labels,-1
_Tags_ListView_Show:
	Tag	GTLV_ShowSelected,0
_Tags_ListView_Selected:
	Tag	GTLV_Selected,0
	Tag_End

_Tags_String:
_Tags_String_Ptr:
	Tag	GTST_String,_FString_Buffer
	Tag	GTST_MaxChars,31
	Tag_End

_FString_Buffer:	DS.B	40
 EVEN

_Cycle_FileType:
	DC.L	_Text_FileType_Project
	DC.L	_Text_FileType_Map
	DC.L	_Text_FileType_Tile
	DC.L	_Text_FileType_Palette
	DC.L	_Text_FileType_Shape
	DC.L	_Text_FileType_Anim
	DC.L	_Text_FileType_Copper
	DC.L	_Text_FileType_Prefs
	DC.L	0


_File_GadgetDown_List:
	DC.W		-1

_File_GadgetUp_List:
	SetGadgetID	BUTTON_ID_OK,_File_Button_OK
	SetGadgetID	BUTTON_ID_CANCEL,_File_Button_Cancel
	SetGadgetID	BUTTON_ID_LVADD,_File_Button_ListView_Add
;	SetGadgetID	BUTTON_ID_LVREMOVE,_File_Button_ListView_Remove
	SetGadgetID	BUTTON_ID_LVSAVE,_File_Button_ListView_Save
	SetGadgetID	BUTTON_ID_LOAD,_File_Button_Load
	SetGadgetID	BUTTON_ID_SAVE,_File_Button_Save
	SetGadgetID	CYCLE_ID_TYPE,_File_Cycle_Change_Type
	SetGadgetID	LISTVIEW_ID_TYPE,_File_ListView_Change_Type
	SetGadgetID	STRING_ID_TYPE,_File_String_Change_Type
	DC.L	-1


_File_String_Gad:
	NewGadget	STRING_KIND,_Tags_String,016,066,288,014,NULL,NULL,STRING_ID_TYPE,0,NULL,NULL
	DC.L		-1


_File_NewGadget_List:
	NewGadget	BUTTON_KIND,_Tags_UnderScore,016,170,072,014,_Text_OK,NULL,BUTTON_ID_OK,PLACETEXT_IN,NULL,NULL
	NewGadget	BUTTON_KIND,_Tags_UnderScore,552,170,072,014,_Text_Cancel,NULL,BUTTON_ID_CANCEL,PLACETEXT_IN,NULL,NULL


	NewGadget	BUTTON_KIND,_Tags_UnderScore,016,006,072,014,_Text_Load,NULL,BUTTON_ID_LOAD,PLACETEXT_IN,NULL,NULL
	NewGadget	CYCLE_KIND,_Tags_Cycle_Label,092,006,134,014,NULL,NULL,CYCLE_ID_TYPE,0,NULL,NULL
	NewGadget	BUTTON_KIND,_Tags_UnderScore,232,006,072,014,_Text_Save,NULL,BUTTON_ID_SAVE,PLACETEXT_IN,NULL,NULL

_File_ListView_Gad:
	NewGadget	LISTVIEW_KIND,_Tags_ListView,016,022,288,062,NULL,NULL,LISTVIEW_ID_TYPE,PLACETEXT_IN,NULL,NULL
	NewGadget	BUTTON_KIND,_Tags_UnderScore,016,082,072,014,_Text_Add,NULL,BUTTON_ID_LVADD,PLACETEXT_IN,NULL,NULL
	NewGadget	BUTTON_KIND,_Tags_UnderScore,088,082,072,014,_Text_Remove,NULL,BUTTON_ID_LVREMOVE,PLACETEXT_IN,NULL,NULL
	NewGadget	BUTTON_KIND,_Tags_UnderScore,160,082,072,014,_Text_OK,NULL,BUTTON_ID_NULL,PLACETEXT_IN,NULL,NULL
	NewGadget	BUTTON_KIND,_Tags_UnderScore,232,082,072,014,_Text_SaveAs,NULL,BUTTON_ID_LVSAVE,PLACETEXT_IN,NULL,NULL



	DC.L		-1


 ENDC


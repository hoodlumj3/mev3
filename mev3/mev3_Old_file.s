
 IFND	MEV3_FILE_S
MEV3_FILE_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

DISK_BUFFER_SIZE	EQU	 1024

*
*
* $VER:mev3_file.s 39.01  © (00/April/94) M.J.Edwards
*
*

;****************************************************
;          File Screen & Asl FileRequester
;****************************************************
	
Setup_File:
	lea	Shutdown_File,a0
	jsr	_Set_Exit_Jump

; open asl library
	moveq.l	#39,d0
	lea	_AslName,a1
	jsr	_Open_Library
	move.l	d0,_AslBase
; open screen
	sub.l	a0,a0
	lea	File_Screen_TagList,a1
	jsr	_Open_Screen
	move.l	d0,_Ed_Screen
; get visual info
	move.l	_Ed_Screen,a0
	jsr	_GetVisualInfo
	move.l	d0,_Ed_VisualInfo
	move.l	d0,_Gl_VisualInfo
; create listview list

	clr.l	d0
	move.w	Prev_Prog_Section,d0
	call	_ProgSec_To_Cycle
	move.l	d0,Gad_Tags_Cycle_Active+4

	jsr	Create_File_ListView_List

	jsr	File_Get_Section_Set

; create gadgets

	lea	_Ed_Gadgets,a0
	jsr	_CreateContext		; -> d0 = gad(get) pointer

	lea	File_Gadget_List,a0
	jsr	_Create_Gadgets_List


; open window
	sub.l	a0,a0
	lea	File_Window_TagList,a1
	move.l	_Ed_Screen,File_Window_Screen+4		; write screen pointer into window structure
	move.l	_Ed_Gadgets,File_Window_Gadgets+4	; write gadget pointer into window structure
	jsr	_Open_Window
	move.l	d0,_Ed_Window
	move.l	d1,_Ed_RastPort
;	move.l	d2,_Ed_ViewPort
	move.l	d3,_Ed_UserPort
	move.l	_Ed_Window,a0
	call	_Refresh_Window
	rts

;Refresh_File_Window:
;	move.l	_Ed_Window,a0
;	sub.l	a1,a1
;	move.l	_GadToolsBase,a6
;	jsr	_LVOGT_RefreshWindow(a6)
;	rts

_ProgSec_To_Cycle:	; prog section
	cmp.w	#SECTION_PROJECT,d0
	bne.s	.not_project
	move.w	#0,d0
	bra.s	.end_sec
.not_project
	cmp.w	#SECTION_MAP,d0
	bne.s	.not_map
	move.w	#1,d0
	bra.s	.end_sec
.not_map
	cmp.w	#SECTION_TILE,d0
	bne.s	.not_tile
	move.w	#2,d0
	bra.s	.end_sec
.not_tile
	cmp.w	#SECTION_PALETTE,d0
	bne.s	.not_palette
	move.w	#3,d0
	bra.s	.end_sec
.not_palette
	cmp.w	#SECTION_SHAPE,d0
	bne.s	.not_shape
	move.w	#4,d0
	bra.s	.end_sec
.not_shape
	cmp.w	#SECTION_ANIM,d0
	bne.s	.not_anim
	move.w	#5,d0
	bra.s	.end_sec
.not_anim
	cmp.w	#SECTION_COPPER,d0
	bne.s	.not_copper
	move.w	#6,d0
	bra.s	.end_sec
.not_copper
	cmp.w	#SECTION_PREFS,d0
	bne.s	.not_prefs
	move.w	#7,d0
.not_prefs
.end_sec	
	rts	; d0 - cycle active

_Cycle_To_ProgSec:	; d0 - from cycle_active
	cmp.w	#0,d0
	bne.s	.not_project
	move.w	#SECTION_PROJECT,d0
	bra.s	.end_sec
.not_project
	cmp.w	#1,d0
	bne.s	.not_map
	move.w	#SECTION_MAP,d0
	bra.s	.end_sec
.not_map
	cmp.w	#2,d0
	bne.s	.not_tile
	move.w	#SECTION_TILE,d0
	bra.s	.end_sec
.not_tile
	cmp.w	#3,d0
	bne.s	.not_palette
	move.w	#SECTION_PALETTE,d0
	bra.s	.end_sec
.not_palette
	cmp.w	#4,d0
	bne.s	.not_shape
	move.w	#SECTION_SHAPE,d0
	bra.s	.end_sec
.not_shape
	cmp.w	#5,d0
	bne.s	.not_anim
	move.w	#SECTION_ANIM,d0
	bra.s	.end_sec
.not_anim
	cmp.w	#6,d0
	bne.s	.not_copper
	move.w	#SECTION_COPPER,d0
	bra.s	.end_sec
.not_copper
	cmp.w	#7,d0
	bne.s	.not_prefs
	move.w	#SECTION_COPPER,d0
.not_prefs
.end_sec
	rts		; d0 - section #

Shutdown_File:
; close window	
	move.l	_Ed_Window,a0
	jsr	_Close_Window
; close gadgets
	move.l	_Ed_Gadgets,a0
	jsr	_FreeGadgets
; remove listview
	jsr	Remove_ListView_List	
; remove visual info
	move.l	_Ed_VisualInfo,a0
	jsr	_RemoveVisualInfo
; close screen
	move.l	_Ed_Screen,a0
	jsr	_Close_Screen
; close asl library
	move.l	_AslBase,a1
	jsr	_Close_Library	

	jsr	_Clear_Exit_Jump
	rts

;File_Second_Gads:
;	move.l	Gad_Tags_Cycle_Active+4,d1
;	cmp.w	#SECTION_TILE,d1
;	bne.s	.not_tile_set
;	lea	File_Gad_Test_1,a0
;	bra.s	.end_set
;.not_tile_set
;	cmp.w	#SECTION_MAP,d1
;	bne.s	.not_map_set
;	lea	File_Gad_Test_2,a0
;	bra.s	.end_set
;.not_map_set
;	nop
;.end_set
;	rts

File_Get_Section_Set:
	move.w	#0,d0
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	move.l	d0,d1
	move.w	#0,d0
	cmp.w	#SECTION_TILE,d1
	bne.s	.not_tile_set
	move.w	_Tile_Set,d0
	bra.s	.end_set
.not_tile_set
	cmp.w	#SECTION_MAP,d1
	bne.s	.not_map_set
	move.w	_Map_Set,d0
	bra.s	.end_set
.not_map_set
	cmp.w	#SECTION_PALETTE,d1
	bne.s	.not_palette_set
	move.w	_Palette_Set,d0
	bra.s	.end_set
.not_palette_set
	nop
.end_set
	ext.l	d0
	move.l	d0,Gad_Tags_ListView_Selected+4
	rts

File_Set_Section_Set:	; d0 - "set" as per section
	push	d0
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	move.l	d0,d1
	pop	d0
	cmp.w	#SECTION_TILE,d1
	bne.s	.not_tile_set
	move.w	d0,_Tile_Set
	bra.s	.end_set
.not_tile_set
	cmp.w	#SECTION_MAP,d1
	bne.s	.not_map_set
	move.w	d0,_Map_Set
	bra.s	.end_set
.not_map_set
	cmp.w	#SECTION_PALETTE,d1
	bne.s	.not_palette_set
	move.w	d0,_Palette_Set
	bra.s	.end_set
.not_palette_set
	nop
.end_set
	rts

;_File_Scroller_Map:
;	move.w	im_Code(a1),d0
;	ext.l	d0
;	move.l	d0,Gad_Tags_ListView_Selected+4
;	
;	rts

dbg1:
Handle_File_Messages:
	move.w	#0,_Quit
.wait_for_message
	move.l	_Ed_UserPort,a0
	jsr	_Wait
.next_message
	move.l	_Ed_UserPort,a0
	jsr	_GT_GetIMsg
	
	move.l	d0,a1
	tst.l	d0
	beq.s	.wait_for_message
	jsr	Copy_Intuition_Message
	move.l	d0,a1
	jsr	_GT_ReplyIMsg		; reply as quickley as possible
	lea	_File_Message_List,a0
	jsr	_Execute_Intuition_Message
.not_file_message
	btst	#7,$BFE001
	beq.s	.handle_end
	tst.w	_Quit
	beq	.next_message
.handle_end
	rts


_File_Message_List:
			DC.L	IDCMP_GADGETUP,_Handle_File_GadgetUp
			DC.L	IDCMP_VANILLAKEY,_Handle_File_VanillaKey
			DC.L	-1

_Handle_File_VanillaKey:
			lea	_File_VanillaKey_List,a0
			jsr	_Execute_VanillaKey_List
			rts

_File_VanillaKey_List:
			SetVanilla	$1b,0,_File_Escape
			DC.W	-1

_Handle_File_GadgetUp:
			lea	_File_GadgetUp_List,a0
			jsr	_Execute_Gadget_List
			rts


_File_GadgetUp_List:
			SetGadgetID	CYCLE_ID_TYPE,_File_Cycle_Gadget
			SetGadgetID	LISTVIEW_ID_TYPE,_File_ListView_Gadget


			SetGadgetID	BUTTON_ID_LOAD,_File_Button_Load
			SetGadgetID	BUTTON_ID_DELETE,_File_Button_Delete
			SetGadgetID	BUTTON_ID_SAVE,_File_Button_Save

			SetGadgetID	BUTTON_ID_LVLOAD,_File_Button_LV_Load
			SetGadgetID	BUTTON_ID_LVREMOVE,_File_Button_LV_Remove
			SetGadgetID	BUTTON_ID_LVSAVE,_File_Button_LV_Save

			SetGadgetID	BUTTON_ID_OK,_File_Button_OK
			SetGadgetID	BUTTON_ID_CANCEL,_File_Button_Cancel
;			SetGadgetID	BUTTON_ID_MAPSCROLLER,_File_Scroller_Map
			DC.L	-1

Update_ListView:
	lea	File_Gadget_ListView,a0
	move.l	gng_SIZEOF+6(a0),a0	; get the gadget pointer
	move.l	_Ed_Window,a1
	push	a0-a1
	lea	Gad_Tags_ListView,a3
	move.l	#-1,4(a3)		; set lv header to -1 for listview
;	lea	Gad_Tags_ListView_Selected,a3
	jsr	_GT_SetGadgetAttrs

	jsr	Remove_ListView_List		; free all listview nodes
	jsr	Create_File_ListView_List	; re-create them all
	pop	a0-a1

	move.l	_Ed_Window,a1
	lea	Gad_Tags_ListView,a3
	move.l	#_List_View_Header,4(a3)	; reset lv header to new list
	jsr	_GT_SetGadgetAttrs
	move.l	_Wk_Window,a0
	jsr	_Refresh_Window
	rts

_File_Cycle_Gadget:
	move.w	im_Code(a1),d0
	ext.l	d0
	move.l	d0,Gad_Tags_Cycle_Active+4
	jsr	File_Get_Section_Set		
	jsr	Update_ListView
	rts

_File_ListView_Gadget:
	move.w	im_Code(a1),d0
	ext.l	d0
	move.l	d0,Gad_Tags_ListView_Selected+4
	jsr	File_Set_Section_Set
	rts

Set_Cycle_Extension_Pattern:
	lea	Text_File_Extensions,a0
	move.l	Gad_Tags_Cycle_Active+4,d1
	bra.s	.next_extension_pass
.next_extension
	jsr	_StrLen
	add.l	d0,a0
	addq.l	#1,a0
.next_extension_pass	
	dbra	d1,.next_extension
	push	a0			; %s
	pea	Asl_Req_Pat_Format		; format
	pea	Asl_Req_Pattern		; buffer
	jsr	_SPrintf
	lea	3*4(sp),sp
	rts

_Add_Load:	DC.B	0
		DC.B	0

dbg2:
_File_Button_LV_Load:
	st	_Add_Load
	jsr	Set_Cycle_Extension_Pattern
	lea	Text_Load+1,a0	; ok text
	jsr	Setup_Asl_Requester
	tst.l	d0
	beq.s	.no_load_asl
	jsr	Asl_Requester
	tst.l	d0
	beq.s	.dont_load
	jsr	Read_LV_Set
	push	d0
	jsr	Calculate_LV_Nodes
	addq.w	#1,d0
	jsr	Write_LV_Set
	lea	LV_Load_Files,a0
	jsr	Do_All_Selected_Files
	pop	d0
	jsr	Write_LV_Set
	
.dont_load
	jsr	ShutDown_Asl_Requester
.no_load_asl

	jsr	File_Set_Section_Set

	jsr	Update_ListView

;	jsr	Remove_ListView_List	
;	jsr	Create_File_ListView_List

;	jsr	Refresh_File_Window

	rts

Calculate_LV_Nodes:
	move.w	#0,d0
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	move.l	d0,d1
	move.w	#0,d0
	cmp.w	#SECTION_TILE,d1
	bne.s	.not_tile_set
	jsr	_Calculate_Tile_Node
	bra.s	.end_set
.not_tile_set
	cmp.w	#SECTION_MAP,d1
	bne.s	.not_map_set
	jsr	_Calculate_Map_Node
	bra.s	.end_set
.not_map_set
	cmp.w	#SECTION_PALETTE,d1
	bne.s	.not_palette_set
	jsr	_Calculate_Palette_Node
	bra.s	.end_set
.not_palette_set
	nop
.end_set
	rts

Read_LV_Set:
	move.w	#0,d0
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	move.l	d0,d1
	moveq.l	#0,d0
	cmp.w	#SECTION_TILE,d1
	bne.s	.not_tile_set
	jsr	_Calculate_Tile_Node
	move.l	d0,d1
	move.w	_Tile_Set,d0
	bra.s	.end_set
.not_tile_set
	cmp.w	#SECTION_MAP,d1
	bne.s	.not_map_set
	jsr	_Calculate_Map_Node
	move.l	d0,d1
	move.w	_Map_Set,d0
	bra.s	.end_set
.not_map_set
	cmp.w	#SECTION_PALETTE,d1
	bne.s	.not_palette_set
	jsr	_Calculate_Palette_Node
	move.l	d0,d1
	move.w	_Palette_Set,d0
	bra.s	.end_set
.not_palette_set
	nop
.end_set
	rts	; d0 - set #


Write_LV_Set:	; d0 - set #
	push	d0
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	move.l	d0,d1
	pop	d0
	cmp.w	#SECTION_TILE,d1
	bne.s	.not_tile_set
	move.w	d0,_Tile_Set
	bra.s	.end_set
.not_tile_set
	cmp.w	#SECTION_MAP,d1
	bne.s	.not_map_set
	move.w	d0,_Map_Set
	bra.s	.end_set
.not_map_set
	cmp.w	#SECTION_PALETTE,d1
	bne.s	.not_palette_set
	move.w	d0,_Palette_Set
	bra.s	.end_set
.not_palette_set
	nop
.end_set
	rts

LV_Load_Files:		; listed as "add" on listview
	jsr	File_Load
	jsr	Read_LV_Set
	addq.w	#1,d0
	jsr	Write_LV_Set
	rts	

_File_Button_LV_Remove:

	rts

_File_Button_LV_Save:
	rts

_File_Button_Load:
	sf	_Add_Load
	move.l	Gad_Tags_Cycle_Active+4,d7

	move.b	#0,Asl_Req_Pattern

	push	d7
	lea	Text_Load+1,a0	; ok text
	jsr	Setup_Asl_Requester
	tst.l	d0
	beq.s	.no_load_asl
	jsr	Asl_Requester
	tst.l	d0
	beq.s	.dont_load
	lea	Load_A_File,a0
	jsr	Do_All_Selected_Files
.dont_load
	jsr	ShutDown_Asl_Requester
.no_load_asl
	pop	d7
	move.l	d7,Gad_Tags_Cycle_Active+4

;	jsr	Remove_ListView_List	
;	jsr	Create_File_ListView_List
	jsr	Update_ListView
	move.l	_Wk_Window,a0
	jsr	_Refresh_Window
	rts

_File_Button_Delete:
	rts
dbg61:
_File_Button_Save:

	bsr	_Save_Selected_File


	rts

_Save_Selected_File:
	bsr	Read_LV_Set
	bsr	Calculate_LV_Nodes
	bsr	Get_Set_Name
	lea	Asl_Req_Dir,a1
	exg.l	a0,a1
	jsr	Join_Dir_File_Names
; jump to file save routine here
	bsr	_Save_A_File
	jsr	Split_Dir_File_Names
	
	rts

Get_Set_Name:	; d0 - set #, a0 - node_ptr
	push	d0
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	move.l	d0,d1
	pop	d0
	cmp.w	#SECTION_TILE,d1
	bne.s	.not_tile_set
	move.l	tile_Name(a0),a0
	bra.s	.end_set
.not_tile_set
	cmp.w	#SECTION_MAP,d1
	bne.s	.not_map_set
	move.l	map_Name(a0),a0
	bra.s	.end_set
.not_map_set
	cmp.w	#SECTION_PALETTE,d1
	bne.s	.not_palette_set
	move.l	palette_Name(a0),a0
	bra.s	.end_set
.not_palette_set
	nop
.end_set
	rts

_File_Button_OK:
	move.w	#1,_Quit
	move.w	Prev_Prog_Section,Run_Prog_Section
	move.w	#-1,Last_Prog_Section
	rts

_File_Escape:
_File_Button_Cancel:
	move.w	#-1,_Quit
	move.w	Prev_Prog_Section,Run_Prog_Section
	move.w	#-1,Last_Prog_Section
	rts


Do_All_Selected_Files:		; a0 - routine to execute
	move.l	_FileReq,a5
	move.l	a0,a2
	tst.l	rf_NumArgs(a5)
	bne	.lots_of_files
.only_one_file
	push	a0-a1
	move.l	rf_Dir(a5),a0
	move.l	rf_File(a5),a1
	push	a2
	jsr	Join_Dir_File_Names
	pop	a2
	jsr	(a2)
	jsr	Split_Dir_File_Names
	pop	a0-a1
	bra	.no_more_files
.lots_of_files
	move.l	rf_ArgList(a5),a4
	move.l	rf_NumArgs(a5),d7
	bra.s	.1
.0
;	move.l	d7,d0					;
;	ext.l	d0					;
;	mulu	#wa_SIZEOF,d0				;
	move.l	rf_Dir(a5),a0				;
	move.l	wa_Name(a4),a1			;	;,d0.l
	push	d7/a0-a5
	push	a2
	jsr	Join_Dir_File_Names
	pop	a2
	jsr	(a2)
	jsr	Split_Dir_File_Names
	pop	d7/a0-a5
	add.l	#wa_SIZEOF,a4			;

.1
	dbra	d7,.0
.no_more_files
	rts


Join_Dir_File_Names:	; a0 - dir name, a1 - filename
	push	a0-a1
	move.l	a1,a0
	lea	Asl_Req_File,a1
	jsr	_StrCpy
	pull	a0-a1
	move.l	#512,d0
	jsr	_Malloc
	move.l	d0,_File_Name_Ptr
	pull	a0-a1

	move.l	_File_Name_Ptr,a1
	jsr	_StrCpy			; copy dirpath to buffer
	
	move.l	a1,d1			; move buffer to d1
	pull	a0-a1
	move.l	a1,d2			; move filename to d2
	move.l	#512,d3			; size of buffer
	push	a6
	move.l	_DOSBase,a6
	jsr	_LVOAddPart(a6)		; connect the two
	pop	a6
	pop	a0-a1
	rts

Split_Dir_File_Names:
	move.l	#512,d0
	move.l	_File_Name_Ptr,a0
	jsr	_Free
	move.l	#0,_File_Name_Ptr
	rts

;***********
; ilovematt
;***********

Load_A_File:
;	move.l	FileType_Gadget_Tags_Cycle_Active+4,d0
	move.l	_File_Name_Ptr,a0
	jsr	_StrLen
	bra.s	.next_char_pass
.next_char
	cmp.b	#'.',(a0,d0.w)
	beq.s	.found_ext
.next_char_pass
	dbra	d0,.next_char

.found_ext
	tst.w	d0
	bmi.s	.ext_not_found
	lea	Text_File_Extensions,a1
	moveq.l	#0,d1			; type counter
	add.l	d0,a0
.next_extension
	jsr	_StrCmp
	tst.b	d0
	beq.s	.extension_found
	exg.l	a0,a1
	jsr	_StrLen
	exg.l	a0,a1
	add.l	d0,a1
	addq.l	#1,a1
	addq.l	#1,d1
	cmp.b	#'.',(a1)
	beq.s	.next_extension
.ext_not_found
	move.w	#-1,d1
.extension_found
	move.w	d1,d0

	tst.w	d0
	bmi.s	.unknown_file_ext
	ext.l	d0
	move.l	d0,Gad_Tags_Cycle_Active+4
	jsr	File_Load
.unknown_file_ext
	rts

_Save_A_File:
;	move.l	FileType_Gadget_Tags_Cycle_Active+4,d0
	move.l	_File_Name_Ptr,a0
	jsr	_StrLen
	bra.s	.next_char_pass
.next_char
	cmp.b	#'.',(a0,d0.w)
	beq.s	.found_ext
.next_char_pass
	dbra	d0,.next_char

.found_ext
	tst.w	d0
	bmi.s	.ext_not_found
	lea	Text_File_Extensions,a1	; check all extensions
	moveq.l	#0,d1			; type counter
	add.l	d0,a0
.next_extension
	jsr	_StrCmp			; is it this one ?
	tst.b	d0
	beq.s	.extension_found	; yep found already
	exg.l	a0,a1
	jsr	_StrLen
	exg.l	a0,a1
	add.l	d0,a1
	addq.l	#1,a1
	addq.l	#1,d1
	cmp.b	#'.',(a1)
	beq.s	.next_extension
.ext_not_found
	move.w	#-1,d1
.extension_found
	move.w	d1,d0

	tst.w	d0
	bmi.s	.unknown_file_ext
	ext.l	d0
	move.l	d0,Gad_Tags_Cycle_Active+4
	jsr	File_Save
.unknown_file_ext
	rts


;****************
; File Functions
;****************

File_Delete:
	move.l	_File_Name_Ptr,d1
	jsr	Check_If_Exists
	tst.l	d0
	bne.s	.file_exists

	pea	Text_OK+1		; gadget
	pea	Text_File_Not_Found	; body
	pea	Text_Mev3_Inform	; title
	move.l	_Ed_Window,-(sp)	; window
	jsr	_EasyRequestArgs
	lea	4*4(sp),sp
	bra.s	.file_delete_end
.file_exists
	pea	Asl_Req_File	; arg list
	pea	Text_Req_Yes_No	; gadget
	pea	Text_Are_You_Sure	; body
	pea	Text_Mev3_Confirm	; title
	move.l	_Ed_Window,-(sp)	; window
	jsr	_EasyRequestArgs
	lea	5*4(sp),sp
	
.file_delete_end

	rts

File_Save:
	move.l	_File_Name_Ptr,d1
	jsr	Check_If_Exists
	tst.l	d0
	beq.s	.not_file_exists

	pea	Asl_Req_File	; arg list
	pea	Text_Req_Yes_No	; gadget
	pea	Text_File_Exists	; body
	pea	Text_Mev3_Confirm	; title
	move.l	_Ed_Window,-(sp)	; window
	jsr	_EasyRequestArgs
	lea	5*4(sp),sp
	tst.l	d0
	beq.s	.file_save_end

.not_file_exists
	move.l	_File_Name_Ptr,d1
	move.l	#MODE_NEWFILE,d2
	jsr	Open_File
	tst.l	d0
	bne.s	.file_open_ok
				; error file did not open
	bra.s	.file_save_end
.file_open_ok
	move.l	d0,_File_Handle

				; do saveing of data here

	jsr	Save_Chosen_Data

	move.l	_File_Handle,d1
	jsr	Close_File
.file_save_end
	rts

File_Load:
	move.l	_File_Name_Ptr,d1
	jsr	Check_If_Exists
	tst.l	d0
	bne.s	.file_exists

	pea	Text_OK+1		; gadget
	pea	Text_File_Not_Found	; body
	pea	Text_Mev3_Inform	; title
	move.l	_Ed_Window,-(sp)	; window
	jsr	_EasyRequestArgs
	lea	4*4(sp),sp

				; error file doesn't exist
	bra.s	.file_load_end
.file_exists
	move.l	_File_Name_Ptr,d1
	move.l	#MODE_OLDFILE,d2
	jsr	Open_File
	tst.l	d0
	bne.s	.file_open_ok
				; error file did not open
	bra.s	.file_load_end
.file_open_ok
	move.l	d0,_File_Handle

				; do loading of data here

	jsr	Load_Chosen_Data

	move.l	_File_Handle,d1
	jsr	Close_File
.file_load_end
	rts

Load_Chosen_Data:
	move.l	_Ed_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	bm_Planes(a0),a0
	move.l	a0,_Disk_Buffer		; point to buffer
	move.l	a0,_File_Buffer
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	cmp.l	#SECTION_TILE,d0
	bne.s	.not_tile_load
	jsr	_Load_Tiles
	bra	.load_data_end
.not_tile_load
	cmp.l	#SECTION_MAP,d0
	bne.s	.not_map_load
	jsr	_Load_Map
	bra	.load_data_end
.not_map_load
	cmp.l	#SECTION_PALETTE,d0
	bne.s	.not_palette_load
	jsr	_Load_Palette
	bra	.load_data_end
.not_palette_load
	nop
.load_data_end
	rts

Save_Chosen_Data:
	move.l	_Ed_Screen,a0
	lea	sc_BitMap(a0),a0
	move.l	bm_Planes(a0),a0
	move.l	a0,_Disk_Buffer		; point to buffer
	move.l	a0,_File_Buffer
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	cmp.l	#SECTION_TILE,d0
	bne.s	.not_tile_load
	jsr	_Save_Tiles
	bra	.load_data_end
.not_tile_load
	cmp.l	#SECTION_MAP,d0
	bne.s	.not_map_load
	jsr	_Save_Map
	bra	.load_data_end
.not_map_load
	cmp.l	#SECTION_PALETTE,d0
	bne.s	.not_palette_load
	jsr	_Save_Palette
	bra	.load_data_end
.not_palette_load
	nop
.load_data_end
	rts

Open_File:	; d1 - name, d2 - accessmode
	push	a6
	move.l	_DOSBase,a6
	jsr	_LVOOpen(a6)
	pop	a6
	rts

Close_File:	; d1 - file handle
	push	a6
	move.l	_DOSBase,a6
	jsr	_LVOClose(a6)
	pop	a6
	rts

Check_If_Exists:
	push	d1-d2/a6
	move.l	#MODE_OLDFILE,d2
	move.l	_DOSBase,a6
	jsr	_LVOOpen(a6)
	tst.l	d0
	beq.s	.not_exist
	move.l	d0,d1
	move.l	_DOSBase,a6
	jsr	_LVOClose(a6)	
	moveq.l	#1,d0
.not_exist
	pop	d1-d2/a6
	
	rts

;Text__Form:	DC.B	"FORM",0
;Text__Tile:	DC.B	"TILE",0
;Text__Tlhd:	DC.B	"TLHD",0

 EVEN

_File_Length:		DC.L	0
_File_Buffer:		DC.L	0
_File_Size:		DC.L	0
_File_Format:		DC.B	0
			DC.B	0
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

_Load_Palette:
	move.l	#2,_File_Length
	jsr	Read_File
;	jsr	_Calculate_Tile_Node
;	moveq.l	#0,d0
;	move.w	tile_Palette(a0),d0
	move.l	_Disk_Buffer,a2
	clr.l	d0
	move.w	(a2),d0		; #of colours
	jsr	_Inverse_Power_Of_2	;depth
	move.l	d0,d1
	move.w	#0,d2		; flags
	move.w	_Palette_Set,d0
	jsr	_Replace_Palette_Node

	jsr	_Calculate_Palette_Node
	move.w	palette_Depth(a0),d0
	move.l	palette_Location(a0),a0
	jsr	_Power_Of_2
	jsr	Read_Tile_Colours
	jsr	_Calculate_Palette_Node
	move.l	palette_Name(a0),a0
	jsr	Save_Name_To_Structure

;dbgf3:
;	jsr	_Calculate_Palette_Node
;	jsr	_Create_Form_Palette
;	jsr	_Free_Form_Palette

	rts

_SeekToPosInFile:	; d0 - pos
	push	d1-d3/a6
	move.l	d0,d2	
	move.l	_File_Handle,d1
	move.l	#OFFSET_BEGINNING,d3
	base	DOS
	call	Seek
	pop	d1-d3/a6
	rts

_Load_Tiles:

;**** Future File Information - TO BE implemented ****
	move.l	#12,_File_Length		; read in "FORM"
	jsr	Read_File
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

		rts

.load_ilbm_file
	rts

.load_form_tiles			; load the all new v3.0 form tiles
	moveq.l	#0,d0
	call	_SeekToPosInFile
	
	rts

.load_old_2_0				; load the old type v2.0 of tiles
	moveq.l	#0,d0
	call	_SeekToPosInFile

	move.l	#6,_File_Length
	jsr	Read_File
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
	jsr	_Replace_Tile_Node

	jsr	_Calculate_Tile_Node
	move.l	a0,a5
	btst	#FLGB_NOCOLS,_File_Format	; #5
	bne.s	.tile_no_colours
	push	a0
	move.w	tile_Palette(a0),d0
	move.w	tile_Depth(a0),d1
	moveq.l	#FLGF_INCLD,d2
;
;;
;;; select which pallette to do , replace th ecurrent one or add a new one
;;
;
.add_pale_if
	tst.b	_Add_Load
	bne.s	.add_pale_else
	jsr	_Replace_Palette_Node
	bra.s	.add_pale_endif
.add_pale_else
	jsr	_Add_Palette_Node
.add_pale_endif

	jsr	_Calculate_Palette_Node
	push	a0
	call.l	_Count_Palette_Nodes
	subq.w	#1,d0
	move.w	d0,_Palette_Set
	pop	a0
	jsr	_Calculate_Palette_Node
	moveq.l	#0,d0
	move.w	palette_Depth(a0),d0
	jsr	_Power_Of_2
	move.l	palette_Location(a0),a0
	jsr	Read_Tile_Colours
;	move.l	palette_Name(a0),a1
;	pull	a0
;	move.l	tile_Name(a0),a0
;	bsr	_StrCpy
	pop	a0
.tile_no_colours	

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
	jsr	Read_Buffer	
	move.l	#DISK_BUFFER_SIZE,d2			; buffer size
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
	jsr	Tile_Format_Routine_0
	bra.s	.not_format_end
.not_format_0
	cmpi.b	#1,d0
	bne.s	.not_format_1
	jsr	Tile_Format_Routine_1
	bra.s	.not_format_end
.not_format_1
	cmpi.b	#2,d0
	bne.s	.not_format_2
	jsr	Tile_Format_Routine_2
	bra.s	.not_format_end
.not_format_2
;	cmpi.b	#3,d0
;	bne.s	.not_format_3
	jsr	Tile_Format_Routine_3
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
;	move.l	NumWriteBytes-PC(a5),d0
;	jsr	Make_Even
	mulu	d5,d0		; height
	add.l	d0,d3

	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	jsr	_Tile_Width_Convert
	jsr	_Make_Even
;	move.l	NumWriteBytes-PC(a5),d0
;	jsr	Make_Even
	mulu	tile_Height(a5),d0
	mulu	d6,d0		; number
	add.l	d0,d3

	moveq.l	#0,d0
	move.w	tile_Width(a5),d0
	jsr	_Tile_Width_Convert
	jsr	_Make_Even
;	move.l	NumWriteBytes-PC(a5),d0
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

dbg98:
	jsr	_Calculate_Tile_Node
	move.l	tile_Name(a0),a0
	jsr	Save_Name_To_Structure

	btst	#FLGB_NOCOLS,_File_Format	; #5
	bne.s	.tile_no_colours_name

	jsr	_Calculate_Palette_Node
	move.l	palette_Name(a0),a0
	jsr	Save_Name_To_Structure

	jsr	_Calculate_Palette_Node
	move.l	palette_Name(a0),a0
	move.b	#$2e,d0		; '.'
	jsr	_Find_Last_Char
	move.b	#0,(a0,d0.w)
	lea	Text_FileExt_Palette,a1
	exg.l	a0,a1
	jsr	_StrCat
.tile_no_colours_name

;dbgf1:
;	jsr	_Calculate_Tile_Node
;	jsr	_Create_Form_Tile
;	jsr	_Free_Form_Tile

	rts

_Save_Tiles:
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
	bsr	Write_File

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
	bsr	Write_File		; write # of Colors into file
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

	cmpi.l	#DISK_BUFFER_SIZE,d2
	blo.s	.save_buffer_not_full
	bsr	Write_Buffer
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
	bsr	Tile_Format_Routine_0
	bra.s	.end_find_store
.not_store_0
	cmpi.b	#1,d0
	bne.s	.not_store_1
	bsr	Tile_Format_Routine_1
	bra.s	.end_find_store
.not_store_1
	cmpi.b	#2,d0
	bne.s	.not_store_2
	bsr	Tile_Format_Routine_2
	bra.s	.end_find_store
.not_store_2
	bsr	Tile_Format_Routine_3

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

	bsr	Write_Buffer
.tile_save_finish
	rts


_Load_Map:
	move.l	#6,_File_Length
	jsr	Read_File

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
	jsr	_Replace_Map_Node

	jsr	_Calculate_Map_Node
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
;	mulu	d1,d0
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
	jsr	Read_Buffer	
	move.l	#DISK_BUFFER_SIZE,d2
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
	jsr	Map_Format_Routine_0
	bra.s	.not_stored_1
.not_stored_0
	cmpi.b	#1,d0
	bne.s	.not_stored_1
	jsr	Map_Format_Routine_1
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

	jsr	_Calculate_Map_Node
	move.l	map_Name(a0),a0
	jsr	Save_Name_To_Structure
;dbgf2:
;	jsr	_Calculate_Map_Node
;	jsr	_Create_Form_Map
;	jsr	_Free_Form_Map
	rts

_Save_Map:

;	rts

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
	
	move.b	#2,map_UnitSize(a2)		; premature set unit size to word size

	move.w	map_Tiles(a5),d0
	move.l	_Tile_Node,a0
	jsr	_Get_Node_Ptr	; get node of tiles for this map
	move.w	tile_Amount(a0),d0
	cmp.w	#255,d0
	bhi.s	.not_unit_1
	move.b	#1,map_UnitSize(a2)		; if total tile < 255 then set map unitsize to 1 for byte size
.not_unit_1

.not_auto_set
	move.b	map_UnitSize(a5),fm_Unit(a2)

	move.l	#6,_File_Length
	bsr	Write_File

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

	cmpi.l	#DISK_BUFFER_SIZE,d2
	blo.s	.save_buffer_not_full
	bsr	Write_Buffer
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
	bsr	Map_Format_Routine_0
	bra.s	51$
50$
	cmpi.b	#1,d0
	bne.s	51$
	bsr	Map_Format_Routine_1
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
	bsr	Write_Buffer

.map_save_finish

	rts



;Save_Tiles:
;	bsr	Setup_FileName
;	move.l	a0,FileName-PC(a5)
;	bsr	Check_If_File_Exists
;	move.l	#1006,FileMode-PC(a5)			; New File Mode
;	bsr	Open_File
;	tst.l	d0
;	bne.s	Save_Tile_Open_OK
;	move.l	#445,d7
;	bsr	Dos_Error
;	bra	Save_Tile_Finish
;Save_Tile_Open_OK:

;	move.l	Planes0-PC(a5),a0
;	lea	FileInfoBlock-PC(a5),a0
;	move.l	a0,FileBuffer-PC(a5)
;	move.l	a0,Disk_Buffer-PC(a5)

;;	move.l	Disk_Buffer-PC(a5),a0
;;	move.l	#"TILE",(a0)
;;	move.l	#4,FileLength-PC(a5)
;;	bsr	Write_File

;	moveq.l	#0,d0
;	move.w	Var_TileAmount-PC(a5),d0
;	subq.w	#1,d0
;	move.w	d0,0(a0)
;	moveq.l	#0,d0
;	move.w	Var_TileWidth-PC(a5),d0
;	move.b	d0,2(a0)
;	move.w	Var_TileHeight-PC(a5),d0
;	move.b	d0,3(a0)
;	move.w	Var_TileDepth-PC(a5),d0
;	move.b	d0,4(a0)
;	move.b	Tile_Format-PC(a5),5(a0)
;	move.l	#6,FileLength-PC(a5)
;	bsr	Write_File		; write 6 bytes for what type of blocks these are.

;	btst	#$5,Tile_Format-PC(a5)
;	bne.s	20$
;
;	moveq.l	#0,d0
;	move.w	Var_TileDepth-PC(a5),d0
;	bsr	Calc_Power_of_2
;	lea	Var_TileColors-PC(a5),a0
;	move.l	Disk_Buffer-PC(a5),a1
;	bsr	Copy_Words
;	lsl.l	#1,d0
;	move.l	d0,FileLength-PC(a5)
;	bsr	Write_File		; write # of Colors into file
;20$

;	bsr	Calc_Tile_FileSize

;	bsr	Stats_Display

;	move.l	Disk_Buffer-PC(a5),a1	; Save buffer address	to
;	move.l	TilePlanes-PC(a5),a0	; Save data address	from
;	moveq.l	#0,d0
;	moveq.l	#0,d1			; count number bytes converted
;	moveq.l	#0,d2			; count number buffer bytes
;	moveq.l	#0,d3			; 
;	moveq.l	#0,d4			; memory location tab
;	moveq.l	#0,d5			; tile count
;	moveq.l	#0,d6			; line count (height)
;	moveq.l	#0,d7			; plane count
;Save_Tile_Loop:
;	move.l	FileSize-PC(a5),d0
;	cmp.l	d0,d1
;	beq	100$
;
;	cmpi.l	#512,d2
;	blo.s	40$	
;	bsr	Write_Buffer
;	moveq.l	#0,d2
;	move.l	Disk_Buffer-PC(a5),a1	; load to buffer address
;40$
;	move.l	TilePlanes-PC(a5),a0	; load from data address
;	movem.l	d0/a0,-(sp)
;	add.l	d3,a0
;	move.b	(a0),(a1)
;;	move.l	NumWriteBytes-PC(a5),d0
;;	bsr	Copy_Bytes
;;	move.l	NumWriteBytes-PC(a5),d0
;	addq.l	#1,a1
;	movem.l	(sp)+,d0/a0
;	
;	movem.l	d0-d3,-(sp)
;
;	move.b	Tile_Format-PC(a5),d0
;	andi.b	#$03,d0
;	cmpi.b	#0,d0
;	bne.s	20$
;	bsr	Load_Save_Rt_0
;	bra.s	30$
;20$
;	cmpi.b	#1,d0
;	bne.s	21$
;	bsr	Load_Save_Rt_1
;	bra.s	30$
;21$
;	cmpi.b	#2,d0
;	bne.s	22$
;	bsr	Load_Save_Rt_2
;	bra.s	30$
;22$
;	bsr	Load_Save_Rt_3
;23$
;30$
;
;	movem.l	(sp)+,d0-d3
;
;	moveq.l	#0,d3
;	move.l	d4,d3		; width
;		
;	moveq.l	#0,d0
;	move.l	NumWriteBytes-PC(a5),d0
;	bsr	Make_Even
;	mulu	d5,d0		; height
;	add.l	d0,d3
;
;	move.l	NumWriteBytes-PC(a5),d0
;	bsr	Make_Even
;	mulu	Var_TileHeight-PC(a5),d0
;	mulu	d6,d0		; number
;	add.l	d0,d3
;
;	move.l	NumWriteBytes-PC(a5),d0
;	bsr	Make_Even
;	mulu	Var_TileHeight-PC(a5),d0
;	mulu	Var_TileAmount-PC(a5),d0
;	mulu	d7,d0		; depth
;	add.l	d0,d3
;
;;	move.l	NumWriteBytes-PC(a5),d0
;	addq.l	#1,d1
;	addq.l	#1,d2
;	btst	#$A,$DFF016
;	beq.s	Save_Tile_Close
;	bra	Save_Tile_Loop
;100$
;
;	bsr	Write_Buffer
;
;Save_Tile_Close:
;	bsr	Close_File
;
;Save_Tile_Finish:
;	rts



dbgf4:
_Save_Palette:
;	rts

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
	bsr	Write_File

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
	bhs	100$

	cmpi.l	#DISK_BUFFER_SIZE,d2
	blo.s	.save_buffer_not_full
	bsr	Write_Buffer
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
	beq.s	.palette_save_complete
	bra	.palette_save_loop
100$
	bsr	Write_Buffer

.palette_save_complete
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

Save_Name_To_Structure:		; a0 - string buffer
	push	a0
	lea	Asl_Req_File,a0
	move.b	#$2e,d0		; '.'
	jsr	_Find_Last_Char
	pop	a1
	bra.s	.no_extension_found
	tst.w	d0
	bmi.s	.no_extension_found
	jsr	_StrnCpy
	move.b	#0,(a1,d0.w)
	bra.s	.save_name_ok
.no_extension_found
	lea	Asl_Req_File,a0
	jsr	_StrCpy
.save_name_ok
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
dbgd1:
Read_Tile_Colours:	; d0 - # cols, a0 - location to copy to
	push	a0
	push	d0
	add.l	d0,d0
	move.l	d0,_File_Length
	jsr	Read_File
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

Map_Format_Routine_0:
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

Map_Format_Routine_1:
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

Tile_Format_Routine_0:		; width,height,depth,amount

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

	
Tile_Format_Routine_1:		; width,depth,height,amount
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

Tile_Format_Routine_2:		; width,amount,depth,height
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

Tile_Format_Routine_3:		; width,amount,height,depth
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


Read_Buffer:
	push	d0-d7/a0-a6
	move.l	#DISK_BUFFER_SIZE,_File_Length
	move.l	_Disk_Buffer,_File_Buffer
	jsr	Read_File
	pop	d0-d7/a0-a6
	rts

Write_Buffer:
	push	d0-d7/a0-a6
	move.l	d2,_File_Length
	move.l	_Disk_Buffer,_File_Buffer
	jsr	Write_File
	pop	d0-d7/a0-a6
	rts


Read_File:
	move.l	_File_Handle,d1
	move.l	_File_Buffer,d2
	move.l	_File_Length,d3
	jsr	_Read
	move.l	d0,_Bytes_Read
	rts

Write_File:
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



    STRUCTURE	LISTVIEW_HEADER,0
	APTR	lh_first
	APTR	lh_mid
	APTR	lh_last
	ULONG	lh_size
	LABEL	lh_SIZEOF

    STRUCTURE	LISTVIEW_NODE,0
	APTR	lv_next
	APTR	lv_prev
	UBYTE	lv_dunno1
	UBYTE	lv_dunno2
	APTR	lv_text
	LABEL	lv_SIZEOF

dbg62:
Create_File_ListView_List:
	move.l	Gad_Tags_Cycle_Active+4,d0
	call	_Cycle_To_ProgSec
	cmp.l	#SECTION_TILE,d0
	bne.s	.not_tile_list
	jsr	Create_Tile_List
	bra.s	.end_list
.not_tile_list
	cmp.l	#SECTION_MAP,d0
	bne.s	.not_map_list
	jsr	Create_Map_List
	bra.s	.end_list
.not_map_list
	cmp.l	#SECTION_PALETTE,d0
	bne.s	.not_palette_list
	jsr	Create_Palette_List
	bra.s	.end_list
.not_palette_list
	nop
.end_list
	rts

Create_Tile_List:
	jsr	_Count_Tile_Nodes
	tst.l	d0
	beq.s	.end_create_tile_list
	lea	_List_View_Header,a0
	jsr	Create_Listview_Nodes
	move.l	lh_first(a0),a1
	
	move.l	_Tile_Node,a0
	move.l	tile_Next(a0),a0
	
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.end_while
	move.l	tile_Name(a0),lv_text(a1)
	move.l	tile_Next(a0),a0
	move.l	lv_next(a1),a1
	bra.s	.while
.end_while

.end_create_tile_list
	rts

Create_Map_List:
	jsr	_Count_Map_Nodes
	tst.l	d0
	beq.s	.end_create_map_list
	lea	_List_View_Header,a0
	jsr	Create_Listview_Nodes
	move.l	lh_first(a0),a1
	
	move.l	_Map_Node,a0
	move.l	map_Next(a0),a0
	
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.end_while
	move.l	map_Name(a0),lv_text(a1)
	move.l	map_Next(a0),a0
	move.l	lv_next(a1),a1
	bra.s	.while
.end_while

.end_create_map_list
	rts

Create_Palette_List:
	jsr	_Count_Palette_Nodes
	tst.l	d0
	beq.s	.end_create_palette_list
	lea	_List_View_Header,a0
	jsr	Create_Listview_Nodes
	move.l	lh_first(a0),a1
	
	move.l	_Palette_Node,a0
	move.l	palette_Next(a0),a0
	
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.end_while
	move.l	palette_Name(a0),lv_text(a1)
	move.l	palette_Next(a0),a0
	move.l	lv_next(a1),a1
	bra.s	.while
.end_while

.end_create_palette_list
	rts

Remove_ListView_List:
	lea	_List_View_Header,a0
	jsr	Remove_Listview_Nodes
	rts

_List_View_Header:	DS.B	lh_SIZEOF

Remove_Listview_Nodes:	; a0 - list header
	push	a0
	move.l	lh_size(a0),d0
	move.l	lh_first(a0),a0
	jsr	_Free
	pop	a0
	moveq.l	#0,d0
	move.l	d0,lh_first(a0)
	move.l	d0,lh_mid(a0)
	move.l	d0,lh_last(a0)
	move.l	d0,lh_size(a0)
	rts

Create_Listview_Nodes:	; d0 - number of nodes, a0 - list header

	push	d0/a0			; alloc dummy header
	mulu	#lv_SIZEOF,d0
	move.l	d0,lh_size(a0)
	jsr	_Malloc
	pull	d7/a0
	subq.w	#1,d7
	move.l	d0,lh_first(a0)
	move.l	d0,a1
	clr.l	d0
	bra.s	.1
.0
	push	d0-d1/a0-a1
	move.l	d0,d1
	move.l	a1,a0
	addq.l	#1,d1
	mulu	#lv_SIZEOF,d0
	mulu	#lv_SIZEOF,d1
	push	a0
	add.l	d1,a0
	move.l	a0,lv_next(a1,d0.w)
	pop	a0
	add.l	d0,a1
	move.l	a1,lv_prev(a0,d1.w)	
	pop	d0-d1/a0-a1
	addq.l	#1,d0
.1
	dbra	d7,.0
	pull	d7/a0
	move.l	lh_first(a0),a1
	mulu	#lv_SIZEOF,d0
	add.l	d0,a1
	move.l	a1,lh_last(a0)		; point listview last pointer to last node
	push	a0
	addq.l	#4,a0
	move.l	a0,lv_next(a1)		; point last node->next to listview mid pointer
	pop	a0
	pull	d7/a0
	move.l	lh_first(a0),a1
	move.l	a0,lv_prev(a1)		; point first node->prev to listview first pointer
	pop	d0/a0
;	mulu	#lv_SIZEOF,d0
;	move.l	d0,lh_size(a0)

	rts

File_Screen_TagList:
			DC.L	SA_Width,640
			DC.L	SA_Height,200
			DC.L	SA_Depth,3
			DC.L	SA_DisplayID,HIRES_KEY
			DC.L	SA_Title,Text_Mev3_Title
			DC.L	SA_AutoScroll,TRUE
;			DC.L	SA_Pens,Screen_DriPens
;			DC.L    SA_Colors,Screen_Colours
			DC.L	SA_Pens,Minus_1
			DC.L	TAG_DONE

Screen_Colours:
			DC.W     0,$04,$06,$08
			DC.W     1,$00,$02,$04
			DC.W     2,$0F,$0F,$0F
			DC.W     3,$07,$09,$0B
			DC.W	 4,$05,$07,$09
			DC.W    -1,$00,$00,$00

Screen_DriPens:		DC.W    0,1,2,3,1,4,2,0,3,1,2,1,-1


File_Window_TagList:
File_Window_Screen:	DC.L	WA_CustomScreen,0
File_Window_Gadgets:	DC.L	WA_Gadgets,0
;			DC.L	WA_Title,_DosName
			DC.L	WA_Left,0
			DC.L	WA_Top,11
			DC.L	WA_Width,640
			DC.L	WA_Height,200-11
;			DC.L	WA_BackFill,0
			DC.L    WA_AutoAdjust,1
			DC.L    WA_IDCMP,CYCLEIDCMP!BUTTONIDCMP!SLIDERIDCMP!TEXTIDCMP!IDCMP_INTUITICKS!IDCMP_MOUSEBUTTONS!IDCMP_DISKINSERTED!IDCMP_DISKREMOVED!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW!LISTVIEWIDCMP
			DC.L    WA_Flags,WFLG_SMART_REFRESH|WFLG_BACKDROP|WFLG_ACTIVATE
			DC.L	TAG_DONE

File_Gadget_List:	NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,008,165,(7*8)+(2*8),14,Text_OK,NULL,BUTTON_ID_OK,PLACETEXT_IN,NULL,NULL
			NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,560,165,(7*8)+(2*8),14,Text_Cancel,NULL,BUTTON_ID_CANCEL,PLACETEXT_IN,NULL,NULL

			NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,008,140,(6*8)+(2*8),14,Text_Load,NULL,BUTTON_ID_LOAD,PLACETEXT_IN,NULL,NULL
			NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,284,140,(7*8)+(2*8),14,Text_Delete,NULL,BUTTON_ID_DELETE,PLACETEXT_IN,NULL,NULL
			NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,568,140,(6*8)+(2*8),14,Text_Save,NULL,BUTTON_ID_SAVE,PLACETEXT_IN,NULL,NULL

			NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,200,082,(6*8)+(2*8),14,Text_Add,NULL,BUTTON_ID_LVLOAD,PLACETEXT_IN,NULL,NULL
			NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,264,082,(6*8)+(2*8),14,Text_Remove,NULL,BUTTON_ID_LVREMOVE,PLACETEXT_IN,NULL,NULL
			NewGadget	BUTTON_KIND,Gad_Tags_UnderScore,328,082,(6*8)+(2*8),14,Text_Save,NULL,BUTTON_ID_LVSAVE,PLACETEXT_IN,NULL,NULL


File_Gadget_String:	NewGadget	STRING_KIND,Gad_Tags_String,200,68,256,14,NULL,NULL,STRING_ID_TYPE,0,NULL,NULL

			NewGadget	CYCLE_KIND,Gad_Tags_Cycle_Label,254,6,133,14,NULL,NULL,CYCLE_ID_TYPE,0,NULL,NULL
File_Gadget_ListView:	NewGadget	LISTVIEW_KIND,Gad_Tags_ListView,200,24,256,48,NULL,NULL,LISTVIEW_ID_TYPE,PLACETEXT_IN,NULL,NULL
			DC.L		-1

Gad_Tags_Disabled:	DC.L	GA_Disabled,1
Gad_Tags_UnderScore:	DC.L	GT_Underscore,'_'
Gad_Tags_None:		DC.L	TAG_DONE

Gad_Tags_Toggle:	DC.L	GA_ToggleSelect,TRUE
			DC.L	TAG_DONE

Gad_Tags_Cycle_Label:	DC.L	GTCY_Labels,Cycle_FileType
Gad_Tags_Cycle_Active:	DC.L	GTCY_Active,0
			DC.L	TAG_DONE

Cycle_FileType:
			DC.L	Text_FileType_Project
			DC.L	Text_FileType_Map
			DC.L	Text_FileType_Tile
			DC.L	Text_FileType_Palette
			DC.L	Text_FileType_Shape
			DC.L	Text_FileType_Anim
			DC.L	Text_FileType_Copper
			DC.L	Text_FileType_Prefs
			DC.L	0

Gad_Tags_ListView:	DC.L	GTLV_Labels,_List_View_Header
Gad_Tags_ListView_Show:	DC.L    GTLV_ShowSelected,0
Gad_Tags_ListView_Selected:
			DC.L    GTLV_Selected,0
			DC.L	TAG_DONE

Gad_Tags_String:
Gad_Tags_String_String:	DC.L    GTST_String,0
			DC.L    GTST_MaxChars,32
			DC.L	TAG_DONE
 EVEN

					; GadgetType,GadTagList,LeftEdge,TopEdge,Width,Height,GadgetText,TextAttr,GadgetId,Flags,VisualInfo,UserData
	
 ENDC


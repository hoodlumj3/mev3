 IFND	MEV3_PREFS_MAIN_S
MEV3_PREFS_MAIN_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
**
*** $VER:mev3_prefs.s v3.0a (39.01)  © (05/January/95) M.J.Edwards
**
*

_Setup_Preferences:
	lea	PC,gl

	lea	_Shutdown_Preferences,a0
	call	_Set_Exit_Jump

	call	_Obtain_Preferences_Backup
	
	call	_Create_Preferences_Gadgets

	call	_Open_Preferences_Screen_Window	

	call	_Link_Prefs_Gadgets

	rts

_Shutdown_Preferences:
	lea	PC,gl
; remove all gadgets from prefs window

	call	_UnLink_Prefs_Gadgets

	call	_Close_Preferences_Screen_Window

	call	_Remove_Preferences_Gadgets

	call	_Release_Preferences_Backup

	call	_Clear_Exit_Jump
	rts


_Obtain_Preferences_Backup:
	move.l	#prefs_SIZEOF,d0
	call	_Malloc
	move.l	d0,_Preferences_Backup-PC(gl)

	move.l	#prefs_SIZEOF,d0
	lea	_Preferences-PC(gl),a0
	move.l	_Preferences_Backup-PC(gl),a1
	call	_Copy_Bytes
	rts

_Release_Preferences_Backup:
	tst.w	_Quit-PC(gl)
	bpl.s	.do_not_restore		; if we "save" or "use" then no restore
	move.l	#prefs_SIZEOF,d0
	move.l	_Preferences_Backup-PC(gl),a0
	lea	_Preferences-PC(gl),a1
	call	_Copy_Bytes
.do_not_restore
	move.l	_Preferences_Backup-PC(gl),a0
	call	_Free
	rts

_Create_Preferences_Gadgets:
	lea	_Wk_Gadgets-PC(gl),a0
	call	_CreateContext		; -> d0 = gad(get) pointer

	lea	_Preferences_Gadget_List,a0
	call	_Create_Gadgets_List

	rts

_Link_Prefs_Gadgets:
	
	move.l	_Wk_Window-PC(gl),a0
	call	_Refresh_Window
	rts

_UnLink_Prefs_Gadgets:
	move.l	_Wk_Window-PC(gl),a0
	call	_Remove_All_Window_Gadgets
	rts

_Remove_Preferences_Gadgets:

	lea	_Wk_Gadgets,a0
	call	_FreeGadgets


	rts

_Refresh_Window:	; a0 - window
;	move.l	_Ed_Window,a0
	push	a6
	sub.l	a1,a1
	base	GadTools
	call	GT_RefreshWindow
	pop	a6
	rts

_Open_Preferences_Screen_Window:
	sub.l	a0,a0
	lea	_Preferences_Screen_TagList,a1
	call	_Open_Screen
	move.l	d0,_Wk_Screen

	move.l	_Wk_Screen,a0
	jsr	_GetVisualInfo
	move.l	d0,_Wk_VisualInfo
	move.l	d0,_Gl_VisualInfo
	sub.l	a0,a0
	lea	_Preferences_Window_TagList,a1
	move.l	_Wk_Screen,(_Preferences_CustomScreen-_Preferences_Window_TagList)+4(a1)
	move.l	_Wk_Gadgets,(_Preferences_Gadgets-_Preferences_Window_TagList)+4(a1)
	call	_Open_Window
	move.l	d0,_Wk_Window
	move.l	d1,_Wk_RastPort
;	move.l	d2,_Wk_ViewPort
	move.l	d3,_Wk_UserPort
	rts

_Close_Preferences_Screen_Window:
; close window	
	move.l	_Wk_Window,a0
	call	_Close_Window
; remove visual info
	move.l	_Wk_VisualInfo,a0
	call	_RemoveVisualInfo
; close screen
	move.l	_Wk_Screen,a0
	call	_Close_Screen
	rts


_Handle_Preferences_Messages:
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
	lea	_Preferences_Message_List,a0
	call	_Execute_Intuition_Message
.not_file_message
	btst	#7,$BFE001
	beq.s	.handle_end
	tst.w	_Quit
	beq	.next_message
.handle_end

	rts

_Preferences_Message_List:				; list of IDCMP's &  routines
	DC.L	IDCMP_MOUSEMOVE,_Handle_Prefs_MouseMove
	DC.L	IDCMP_GADGETDOWN,_Handle_Prefs_GadgetDown
	DC.L	IDCMP_GADGETUP,_Handle_Prefs_GadgetUp
	DC.L	IDCMP_INTUITICKS,_Handle_Prefs_IntuiTicks
	DC.L	-1

_Save_Preferences_File:
	rts
_Load_Preferences_File:
	rts

_Preferences_Button_Save:
	call	_Save_Preferences_File
	move.w	#1,_Quit
	bra.s	_Preferences_EndIt

_Preferences_Button_Use:
	move.w	#1,_Quit
	bra.s	_Preferences_EndIt

_Preferences_Button_Cancel:
	move.w	#-1,_Quit
_Preferences_EndIt:
	move.w	Prev_Prog_Section,Run_Prog_Section
	move.w	#-1,Last_Prog_Section
	rts


_Prefs_GadgetUp_List:			; list of GADGETUP ID's & routines
	DC.W		-1

_Prefs_GadgetDown_List:
	DC.W		-1

_Handle_Prefs_MouseMove:	
	rts
_Handle_Prefs_GadgetDown:
	rts

_Handle_Prefs_GadgetUp:
	lea	_Preferences_GadgetUp_List,a0
	jsr	_Execute_Gadget_List
	rts

_Handle_Prefs_IntuiTicks:
	rts


_Preferences_GadgetUp_List:
			SetGadgetID	BUTTON_ID_SAVE,_Preferences_Button_Save
			SetGadgetID	BUTTON_ID_USE,_Preferences_Button_Use
			SetGadgetID	BUTTON_ID_CANCEL,_Preferences_Button_Cancel
			DC.L	-1

_Prefs_Button_OK:
	rts

_Prefs_Button_Cancel:
	rts


_Preferences_Screen_TagList:
	Tag	SA_DisplayID,HIRES_KEY
	Tag	SA_Width,640
	Tag	SA_Height,200
	Tag	SA_Depth,2
	Tag	SA_Pens,Minus_1
	Tag_End

_Preferences_Window_TagList:
	Tag	WA_IDCMP,IDCMP_GADGETUP!IDCMP_RAWKEY
_Preferences_CustomScreen:
	Tag	WA_CustomScreen,0
_Preferences_Gadgets:
	Tag	WA_Gadgets,0
	Tag	WA_Backdrop,0
	Tag	WA_Top,11
	Tag	WA_Height,200-11
	Tag	WA_ScreenTitle,_Text_PrefsScreenTitle
	Tag_End


_Preferences_Gadget_List:
			NewGadget	BUTTON_KIND,_Tags_UnderScore,016,170,(7*8)+(2*8),14,_Text_Save,NULL,BUTTON_ID_SAVE,PLACETEXT_IN,NULL,NULL
			NewGadget	BUTTON_KIND,_Tags_UnderScore,284,170,(7*8)+(2*8),14,_Text_Use,NULL,BUTTON_ID_USE,PLACETEXT_IN,NULL,NULL
			NewGadget	BUTTON_KIND,_Tags_UnderScore,552,170,(7*8)+(2*8),14,_Text_Cancel,NULL,BUTTON_ID_CANCEL,PLACETEXT_IN,NULL,NULL

			NewGadget	CYCLE_KIND,_Tags_Cycle_Label,20,6,133,14,NULL,NULL,CYCLE_ID_TYPE,0,NULL,NULL

;			NewGadget	BUTTON_KIND,_Tags_UnderScore,008,140,(6*8)+(2*8),14,_Text_Load,NULL,BUTTON_ID_LOAD,PLACETEXT_IN,NULL,NULL
;			NewGadget	BUTTON_KIND,_Tags_UnderScore,284,140,(7*8)+(2*8),14,_Text_Delete,NULL,BUTTON_ID_DELETE,PLACETEXT_IN,NULL,NULL
;			NewGadget	BUTTON_KIND,_Tags_UnderScore,568,140,(6*8)+(2*8),14,_Text_Save,NULL,BUTTON_ID_SAVE,PLACETEXT_IN,NULL,NULL
;
;			NewGadget	BUTTON_KIND,_Tags_UnderScore,200,082,(6*8)+(2*8),14,_Text_Add,NULL,BUTTON_ID_LVLOAD,PLACETEXT_IN,NULL,NULL
;			NewGadget	BUTTON_KIND,_Tags_UnderScore,264,082,(6*8)+(2*8),14,_Text_Remove,NULL,BUTTON_ID_LVREMOVE,PLACETEXT_IN,NULL,NULL
;			NewGadget	BUTTON_KIND,_Tags_UnderScore,328,082,(6*8)+(2*8),14,_Text_Save,NULL,BUTTON_ID_LVSAVE,PLACETEXT_IN,NULL,NULL
;
;
;File_Gadget_String:	NewGadget	STRING_KIND,_Tags_String,200,68,256,14,NULL,NULL,STRING_ID_TYPE,0,NULL,NULL
;
;			NewGadget	CYCLE_KIND,_Tags_Cycle_Label,254,6,133,14,NULL,NULL,CYCLE_ID_TYPE,0,NULL,NULL
;File_Gadget_ListView:	NewGadget	LISTVIEW_KIND,Gad_Tags_ListView,200,24,256,48,NULL,NULL,LISTVIEW_ID_TYPE,PLACETEXT_IN,NULL,NULL
			DC.L		-1


 ENDC


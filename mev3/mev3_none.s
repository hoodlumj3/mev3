 IFND	MEV3_NONE_S
MEV3_NONE_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
**
*** $VER:mev3_none.s 39.01  © (28/Mar/94) M.J.Edwards
**
*

;***********************************************************
;      Nothing Screen For The Selection Of The Section
;***********************************************************

Setup_None:
	lea	Shutdown_None,a0
	jsr	_Set_Exit_Jump

; lock public screen
	sub.l	a0,a0
	jsr	_LockPublicScreen
	move.l	d0,_Ed_Screen
; get visual info
	move.l	_Ed_Screen,a0
	jsr	_GetVisualInfo
	move.l	d0,_Ed_VisualInfo
	move.l	d0,_Gl_VisualInfo
; create gadgets
	lea	_Ed_Gadgets,a0
	jsr	_CreateContext		; -> d0 = gad(get) pointer

	lea	None_Gadget_List,a0
	push	d0
	moveq.l	#0,d0
	move.w	Run_Prog_Section,d0
	mulu	#gng_SIZEOF+6+4,d0
	move.l	#_Tags_Disabled,2(a0,d0.l)
	pop	d0
	jsr	_Create_Gadgets_List
	
; open window
	sub.l	a0,a0
	lea	None_Window_TagList,a1
	move.l	_Ed_Screen,(0*8)+4(a1)
	move.l	_Ed_Gadgets,(1*8)+4(a1)
	jsr	_Open_Window
	move.l	d0,_Ed_Window
	rts

Shutdown_None:

; close window	
	move.l	_Ed_Window,a0
	clr.l	d0
	move.w	wd_LeftEdge(a0),d0
	move.l	d0,None_Window_Left+4
	clr.l	d0
	move.w	wd_TopEdge(a0),d0
	move.l	d0,None_Window_Top+4
	jsr	_Close_Window
; free gadgets
	move.l	_Ed_Gadgets,a0
	jsr	_FreeGadgets
; remove visual info
	move.l	_Ed_VisualInfo,a0
	jsr	_RemoveVisualInfo
; unlock public screen
	move.l	_Ed_Screen,a0
	jsr	_UnLockPublicScreen
	jsr	_Clear_Exit_Jump
	rts


Handle_None_Messages:
	push	a6
	move.l	_Ed_Window,a3
	moveq.l	#0,d7
.1
	tst.l	d7
	bne	.handle_end
	move.l	wd_UserPort(a3),a0
	moveq.l	#0,d1
	move.b	$f(a0),d1		; mp_SigBit
	move.l	#$1,d0
	asl.l	d1,d0
	move.l	_SysBase,a6
	jsr	_LVOWait(a6)	
.2
	move.l	wd_UserPort(a3),a0
	move.l	_GadToolsBase,a6
	jsr	_LVOGT_GetIMsg(a6)
	tst.l	d0
	beq.s	.1
	move.l	d0,a1

	move.l	im_Class(a1),d0
	cmp.l	#IDCMP_CLOSEWINDOW,d0
	bne.s	.not_close_window
	moveq.l	#1,d7
	move.w	#-1,Run_Prog_Section
	bra.s	.idcmp_not_known
.not_close_window
	cmp.l	#IDCMP_GADGETUP,d0
	bne.s	.not_gadget_up

	move.l	im_IAddress(a1),a2
	move.w	gg_GadgetID(a2),d0
	cmp.w	#BUTTON_ID_QUIT,d0
	bne.s	.not_button_quit
	moveq.l	#1,d7
	move.w	#-1,Run_Prog_Section
	bra.s	.idcmp_not_known	
.not_button_quit
	push	d0/a0
	lea	None_Gadget_List,a0
	moveq.l	#0,d0
	move.w	Run_Prog_Section,d0
	mulu	#gng_SIZEOF+6+4,d0
	move.l	#_Tags_None,2(a0,d0.l)
	pop	d0/a0

	move.w	d0,Run_Prog_Section
	moveq.l	#1,d7
	bra.s	.idcmp_not_known	
.not_gadget_up
	nop
.idcmp_not_known

	move.l	_GadToolsBase,a6
	jsr	_LVOGT_ReplyIMsg(a6)

	btst	#7,$BFE001
	beq.s	.handle_end
	bra	.2	
.handle_end
	pop	a6
	rts


None_Window_TagList:
		DC.L	WA_PubScreen,0
		DC.L	WA_Gadgets,0
		DC.L	WA_Title,_Text_Mev3_Title
None_Window_Left:
		DC.L	WA_Left,160
None_Window_Top
		DC.L	WA_Top,50+25+3
		DC.L	WA_Width,320
		DC.L	WA_Height,63
		DC.L    WA_IDCMP,BUTTONIDCMP!IDCMP_VANILLAKEY!IDCMP_REFRESHWINDOW!IDCMP_CLOSEWINDOW
		DC.L    WA_Flags,WFLG_SMART_REFRESH|WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE
		DC.L	TAG_DONE

None_Gadget_List:
		NewGadget	BUTTON_KIND,_Tags_None,008+(000*8),013,(05*8),14,_Text_FileType_Map,NULL,SECTION_MAP,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_None,008+(006*8),013,(06*8),14,_Text_FileType_Tile,NULL,SECTION_TILE,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_None,008+(013*8),013,(09*8),14,_Text_FileType_Palette,NULL,SECTION_PALETTE,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_None,008+(023*8),013,(07*8),14,_Text_FileType_Shape,NULL,SECTION_SHAPE,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_None,008+(000*8),029,(11*8),14,_Text_FileType_Anim,NULL,SECTION_ANIM,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_None,008+(012*8),029,(08*8),14,_Text_FileType_Copper,NULL,SECTION_COPPER,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_None,008+(021*8),029,(07*8),14,_Text_FileType_Prefs,NULL,SECTION_PREFS,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_None,008+(029*8),029,(06*8),14,_Text_FileType_File,NULL,SECTION_FILE,PLACETEXT_IN,NULL,NULL
		NewGadget	BUTTON_KIND,_Tags_UnderScore,136,45,(4*8)+(2*8),14,_Text_Quit,NULL,BUTTON_ID_QUIT,PLACETEXT_IN,NULL,NULL
		DC.L		-1

 ENDC

	IFND	MATTS_FUNCS_S
MATTS_FUNCS_S SET	1



INSTALL_Memory_Funcs	macro
	include	"assem:matts/matts_memory_funcs.s"
			endm


INSTALL_Library_Funcs	macro

_Open_Library:			; d0 - library version, a1 - library name
	push	a6
	move.l	_SysBase,a6
	jsr	_LVOOpenLibrary(a6)
	pop	a6
	tst.l	d0
	bne.s	Open_Library_OK
 IFD	debug_info
	movem.l	a1,-(sp)			; push lib name
	pea	_Text_Couldnt_Open		; push format
	jsr	_Printf				; display error
	adda.l	#8,sp				; get back to orig stack
 ENDC
	moveq.l	#10,d0				; set error code
	jmp	_Exit
Open_Library_OK:
	rts

_Close_Library:			; a1 - library offset
	cmp.l	#0,a1				; is lib not open?
	beq.s	0001$				; yes - skip close
	push	a6
	move.l	_SysBase,a6			; no then close
	jsr	_LVOCloseLibrary(a6)
	pop	a6
0001$
	rts

 IFD	debug_info
_Text_Couldnt_Open:		DC.B	"Couldn't open %s",0
 ENDC
	EVEN
			endm

;*********************

INSTALL_DiskFont_Funcs	macro
_Open_DiskFont:		; a0 - textattr
	push	a0/a6
	move.l	_DiskFontBase,a6
	jsr	_LVOOpenDiskFont(a6)
	pop	a0/a6
	tst.l	d0
	bne.s	.open_diskfont_ok
 IFD	debug_info
	move.l	4(a0),d0
	movem.l	d0,-(sp)			; push font name
	pea	_Text_Couldnt_Open		; push format
	jsr	_Printf
	adda.l	#8,sp
 ENDC
	moveq.l	#10,d0				; error code
	jmp	_Exit
.open_diskfont_ok:
	rts
		endm

;*********************

INSTALL_Font_Funcs	macro
_Open_Font:
	push	a0/a6
	move.l	_GraphicsBase,a6
	jsr	_LVOOpenFont(a6)
	pop	a0/a6
	tst.l	d0
	bne.s	.open_font_ok
 IFD	debug_info
	move.l	4(a0),d0
	movem.l	d0,-(sp)			; push font name
	pea	_Text_Couldnt_Open		; push format
	jsr	_Printf
	adda.l	#8,sp
 ENDC
	moveq.l	#10,d0				; error code
	jmp	_Exit
.open_font_ok:
	rts

_Close_Font:
	cmpa.l	#0,a1
	beq.s	0001$
	push	a6
	move.l	_GraphicsBase,a6
	jsr	_LVOCloseFont(a6)
	pop	a6
0001$
	rts
		endm

;*********************

INSTALL_Screen_Funcs	macro ; TagList

_Open_Screen:			; a0 - new screen struct, (a1 - taglist)
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOOpenScreen\1(a6)
	pop	a6
	tst.l	d0
	bne.s	.opened_screen_ok
 IFD	debug_info
	pea	_Text_Screen		; push screen
	pea	_Text_Couldnt_Open		; push format
	jsr	_Printf				; display error
	adda.l	#8,sp				; get back to orig stack
 ENDC
	moveq.l	#10,d0				; set error code
	jmp	_Exit
.opened_screen_ok:
	move.l	d0,d1				; Screenhd
	addi.l	#sc_RastPort,d1			; RastPort
;	move.l	d0,d2
;	addi.l	#sc_ViewPort,d2			; ViewPort
	rts

_Close_Screen:		; a0 - screen
	cmp.l	#0,a0
	beq.s	.close_screen_ok
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOCloseScreen(a6)
	pop	a6
.close_screen_ok
	rts

 IFD	debug_info
_Text_Screen:	DC.B	"Screen",0
 ENDC
	EVEN
		endm

;*********************

INSTALL_ScreenLock_Funcs	macro

_LockPublicScreen:	; a0 - screenname
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOLockPubScreen(a6)
	pop	a6
	tst.l	d0
	bne.s	.locked_screen_ok
 IFD	debug_info
	pea	_Text_Screen		; push screen
	pea	_Text_Couldnt_Open		; push format
	jsr	_Printf				; display error
	adda.l	#8,sp				; get back to orig stack
 ENDC
	moveq.l	#10,d0				; set error code
	jmp	_Exit
.locked_screen_ok
	rts

_UnLockPublicScreen:	; a0 - screen
	cmp.l	#0,a0
	beq.s	.unlock_screen_ok
	move.l	a0,a1
	sub.l	a0,a0
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOUnlockPubScreen(a6)
	pop	a6
.unlock_screen_ok
	rts
		endm

;*********************

INSTALL_Window_Funcs	macro	; TagList
_Open_Window:			; a0 - new window struct, (a1 - taglist)
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOOpenWindow\1(a6)
	pop	a6
	tst.l	d0
	bne.s	.opened_window_ok
 IFD	debug_info
	pea	_Text_Window		; push screen
	pea	_Text_Couldnt_Open		; push format
	jsr	_Printf				; display error
	adda.l	#8,sp				; get back to orig stack
 ENDC
	moveq.l	#10,d0				; set error code
	jmp	_Exit
.opened_window_ok:
	push	a0
	move.l	d0,a0				; windowhandle
	move.l	wd_RPort(a0),d1			; rastport
	move.l	wd_UserPort(a0),d3		; userport
	push	d0-d1/d3/a6
	move.l	_IntuitionBase,a6
	jsr	_LVOViewPortAddress(a6)
	move.l	d0,d2				; viewport
	pop	d0-d1/d3/a6
	pop	a0

	rts

_Close_Window:
	cmp.l	#0,a0
	beq.s	.close_window_ok
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOCloseWindow(a6)
	pop	a6
.close_window_ok
	rts

 IFD	debug_info
_Text_Window:	DC.B	"Window",0
 ENDC
	EVEN

		endm

;*********************

INSTALL_Visual_Funcs	macro

_GetVisualInfo:		; a0 - screen
	sub.l	a1,a1	
	push	a6
	move.l	_GadToolsBase,a6
	jsr	_LVOGetVisualInfoA(a6)
	pop	a6
	tst.l	d0
	bne.s	0001$
	moveq.l	#10,d0
	jmp	_Exit
0001$
	rts

_RemoveVisualInfo:	; a0 - visual info
	cmpa.l	#0,a0
	beq.s	0001$
	push	a6
	move.l	_GadToolsBase,a6
	jsr	_LVOFreeVisualInfo(a6)
	pop	a6
0001$
	rts
		endm

;*********************

INSTALL_Menu_Funcs	macro
AddMenuStrip:
	push	a0-a1
	move.l	a1,a0
;	lea	My_Menu,a0
	move.l	#0,a1
	push	a6
	move.l	_GadToolsBase,a6
	jsr	_LVOCreateMenusA(a6)
	pop	a6
	pop	a0-a1
	tst.l	d0
	bne.s	CreateMenu_OK
	moveq.l	#10,d0
;	move.l	d0,a0
;	move.l	d0,a1
	jmp	_Exit
CreateMenu_OK:
	move.l	d0,My_MenuStrip

	movem.l	a0-a1,-(sp)
	move.l	My_MenuStrip,a0
	move.l	My_VisualInfo,a1
	move.l	#0,a2
	move.l	_GadToolsBase,a6
	jsr	_LVOLayoutMenusA(a6)
	movem.l	(sp)+,a0-a1
	tst.w	d0
	bne.s	LayoutMenus_OK
	moveq.l	#10,d0
;	move.l	d0,a0
;	move.l	d0,a1
	jmp	_Exit
LayoutMenus_OK:
	push	a0-a1
;	move.l	My_WindowHD,a0
	move.l	My_MenuStrip,a1
	move.l	_IntuitionBase,a6
	jsr	_LVOSetMenuStrip(a6)
	pop	a0-a1
	tst.l	d0
	bne.s	SetMenuStrip_OK
;	move.l	d0,a0
;	move.l	d0,a1
	moveq.l	#0,d0
	jmp	_Exit
SetMenuStrip_OK:
	rts

ClearMenuStrip:
	move.l	My_WindowHD,a0
	cmpa.l	#0,a0
	beq.s	0001$
	push	a6
	move.l	_IntuitionBase,a6
	jsr	_LVOClearMenuStrip(a6)
	pop	a6
0001$
	move.l	My_MenuStrip,a0
	cmpa.l	#0,a0
	beq.s	0002$
	push	a6
	move.l	_GadToolsBase,a6
	jsr	_LVOFreeMenus(a6)
	pop	a6
0002$
	rts
		endm

;*********************

INSTALL_Device_Funcs	macro

Open_Device:		; d0 - unit, d1 - flags, a0 - device name, a1 - ioRequest, a2 - diskrep
	push	d0-d1/a0-a2

	push	a0-a2
	suba.l	a1,a1
	move.l	_SysBase,a6
	jsr	_LVOFindTask(a6)
	pop	a0-a2

	move.l	d0,16(a2)		; created area for reporting

	push	a1-a2

	move.l	a2,a1
;	lea	Diskrep,a1
	move.l	_SysBase,a6
	jsr	_LVOAddPort(a6)		; add port

	pop	a1-a2
	
	pop	d0-d1/a0-a2

	move.l	a2,14(a1)
	move.l	_SysBase,a6
	jsr	_LVOOpenDevice(a6)	; Open The Device
;	tst.l	d0
;	bne.s	Open_TrackDisk_OK

;	movem.l	a0,-(sp)			; push lib name
;	pea	_Text_Couldnt_Open		; push format
;	jsr	_Printf				; display error
;	adda.l	#8,sp				; get back to orig stack
;	moveq.l	#10,d0				; set error code
;	jmp	_Exit
;Open_TrackDisk_OK:

	rts

Close_Device:		; a0 - ioRequest, a1 - Diskrep
	push	a1
	move.l	a0,a1
	cmp.l	#0,a1
	beq.s	.1
	move.l	_SysBase,a6
;	lea	ioRequest-PC(a5),a1
	jsr	_LVOCloseDevice(a6)
.1
	pop	a1
	cmp.l	#0,a1
	beq.s	.2
;	lea	Diskrep-PC(a5),a1
	move.l	_SysBase,a6
	jsr	_LVORemPort(a6)		; close up the device
.2
	rts
			endm

;*********************

INSTALL_HexDisplay_Funcs	macro

convert_display_chars:
	push	d7/a0-a1
	lea	_Char_Action-PC(a5),a1
	moveq.l	#16-1,d7
.next
	move.b	(a0)+,d0
	cmp.b	#' ',d0
	blo.s	.out_of_range
	cmp.b	#'~',d0
	bhi.s	.out_of_range
	bra.s	.range_ok
.out_of_range
	move.b	#".",d0
.range_ok
	move.b	d0,(a1)+
	dbra	d7,.next
	pop	d7/a0-a1
	rts

Display_Hex_Data:	; d0 - # bytes to display, a0 - buffer to be displayed
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a1
;	lea	_Block_Buff-PC(a5),a0
	move.l	d0,d7
	addi.l	#$f,d7
	lsr.l	#4,d7
;	moveq.l	#32-1,d7
	bra.s	.0
.next_line
	bsr	convert_display_chars
	push	a0/a1
	pea	_Char_Action
	moveq.l	#4-1,d6
.next_long
	move.l	d6,d0
	add.l	d0,d0
	add.l	d0,d0
	
	move.l	(a0,d0.l),d0
	push	d0
	dbra	d6,.next_long
	move.l	a0,d0
	sub.l	a1,d0
	push	d0
	pea	_Hex_Action
	bsr	_Printf
	adda.l	#(6+1)*4,sp
	pop	a0/a1
	adda.l	#16,a0
.0
	btst	#6,$BFE001
	beq.s	.1	
	dbra	d7,.next_line
.1	
	movem.l	(sp)+,d0-d7/a0-a6
	rts


_Hex_Action:		DC.B	"%04lx : $%08lx $%08lx $%08lx $%08lx : '%16s'",13,10,0
_Char_Action:		DC.B	"................",0

 EVEN
				endm

;*********************

	ENDC	; MATTS_FUNCS_S


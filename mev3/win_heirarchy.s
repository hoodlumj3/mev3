

;
;;
;;;
;;;;
;;;;;
;;;;
;;;
;;
;

;	incdir	"include:"

	include	"mev3_macros.s"
;	include	"mev3/mev3.i"

	

_main:
	push	d0-d7/a0-a6
	move.l	sp,_InitialSP
	move.l	$4.w,_SysBase
	INIT_AMIGA

	call	_Open_Libraries
	call	_Open_My_Screen

_Setup:
	move.l	#gcWinProject3,d0
	call	_AddWorkWindow
	move.l	#gcWinProject2,d0
	call	_AddWorkWindow
	move.l	#gcWinProject4,d0
	call	_AddWorkWindow
	move.l	#gcWinProject0,d0
	call	_AddWorkWindow
	move.l	#gcWinProject1,d0
	call	_AddWorkWindow

	move.l	#gcWinProject1,d0
	call	_RemoveWorkWindow
	move.l	#gcWinProject0,d0
	call	_RemoveWorkWindow
	move.l	#gcWinProject4,d0
	call	_RemoveWorkWindow
	move.l	#gcWinProject2,d0
	call	_RemoveWorkWindow
	move.l	#gcWinProject3,d0
	call	_RemoveWorkWindow
	
	
	
_ShutDown:
	call	_Close_My_Screen
	call	_Close_Libraries

	EXIT_AMIGA
	move.l	_InitialSP,sp

	pop	d0-d7/a0-a6
	move.l	_Exit_Code,d0
	rts

_Exit:
	move.l	#10,_Exit_Code
	bra.s	_ShutDown

_Open_Libraries:
	moveq.l	#39,d0
	lea	_DOSName,a1
	call	_Open_Library
	move.l	d0,_DOSBase

	moveq.l	#39,d0
	lea	_IntuitionName,a1
	call	_Open_Library
	move.l	d0,_IntuitionBase

	rts

_Close_Libraries:


	move.l	_IntuitionBase,a1
	call	_Close_Library
	
	move.l	_DOSBase,a1
	call	_Close_Library
	rts

_Open_My_Screen:
	sub.l	a0,a0
	sub.l	a1,a1
	pea	-1
	move.l	sp,d0
	pea	TAG_DONE
	push	d0
	pea	SA_Pens
	pea	200.w
	pea	SA_Height
	pea	320.w
	pea	SA_Width
	pea	3.w
	pea	SA_Depth
	pea	192.w
	pea	SA_Top

	move.l	sp,a1
	call	_Open_Screen
	lea	(12*4)(sp),sp
	move.l	d0,_Screen_Ptr
	rts

_Screen_Ptr:		DC.L	0
gcWinScreenToUse	SET	_Screen_Ptr

_Close_My_Screen:
	move.l	_Screen_Ptr,a0
	call	_Close_Screen
	rts

_MoveWindowTo:	; d0 - x, d1 - y, a0 - window
	push	d2-d3
	move.w	wd_LeftEdge(a0),d2
	move.w	wd_TopEdge(a0),d3
	push	d2-d3
	sub.w	d2,d0
	sub.w	d3,d1
	push	a6
	base	Intuition
	call	MoveWindow
	pop	a6
	pop	d0-d1
	pop	d2-d3
	rts

_MoveScreenTo:	; d0 - x, d1 - y, a0 - screen
	push	d2-d3
	move.w	sc_LeftEdge(a0),d2
	move.w	sc_TopEdge(a0),d3
	push	d2-d3
	sub.w	d2,d0
	sub.w	d3,d1
	push	a6
	base	Intuition
	call	MoveScreen
	pop	a6
	pop	d0-d1
	pop	d2-d3
	rts

	INSTALL_Library_Funcs
	INSTALL_Screen_Funcs	TagList
	INSTALL_Window_Funcs	TagList

	include	"mev3_windows.s"


_WorkWindow_List:
	NewWorkWindow	Project0,0,0,0,0,0,320,10
	NewWorkWindow	Project1,1,0,0,0,0,320,50
	NewWorkWindow	Project2,2,0,0,0,0,320,20
	NewWorkWindow	Project3,3,0,0,0,0,320,5
	NewWorkWindow	Project4,4,0,0,0,0,320,25
	DC.W	-1


_Get_Window_SigBit:	; a0 - userport
	push	d1
	moveq.l	#0,d1
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	pop	d1
	rts


 IFD dugbarry
    STRUCTURE	WorkWindow,0
	UWORD	ww_ID		;
	UWORD	ww_Position	;
	UWORD	ww_Left		;
	UWORD	ww_Top		;
	UWORD	ww_Width	;
	UWORD	ww_Height	;
	
	APTR	ww_Load		;
	APTR	ww_UnLoad	;
	APTR	ww_GadgetList	;

	APTR	ww_WindowHandle	;
	APTR	ww_ScreenHandle	;
	APTR	ww_RastPort	;
	APTR	ww_ViewPort	;
	APTR	ww_UserPort	;
	APTR	ww_SigBit	;	
	APTR	ww_Gadgets	;

	
	LABEL	ww_SIZEOF

NewWorkWindow	Macro	; name, id, setup_code, gadget_list, left, top, width, height
gcWin\1	equ	\2
	DC.W	\2,0,\5,\6,\7,\8
	DC.L	0,0,0
	DC.L	0,0,0,0,0,\3,\4
gcWinMaxID	set	\2
		Endm

;**
; Note: Make a routine which keeps track of what was opened,
;  eg a library/screen/window, and a routine to close them in reverse
; or patch the existing routines that set up a linked list of : next.l,type.w, ptr.l
; so we can close them in reverse.
;**



_Setup_AddWork_Window:
	pea	TAG_DONE
	push	d7
	pea	WA_Top
	clr.l	d1
	move.w	ww_Left(a4),d1
	push	d1
	pea	WA_Left
	move.w	ww_Width(a4),d1
	push	d1
	pea	WA_Width
	move.w	ww_Height(a4),d1
	push	d1
	pea	WA_Height
	pea	IDCMP_MOUSEBUTTONS!IDCMP_VANILLAKEY!IDCMP_RAWKEY!IDCMP_MOUSEMOVE!IDCMP_REFRESHWINDOW!IDCMP_GADGETDOWN!IDCMP_GADGETUP!IDCMP_INTUITICKS
	pea	WA_IDCMP

;	pea	WFLG_SMART_REFRESH!WFLG_BACKDROP!WFLG_BORDERLESS!WFLG_REPORTMOUSE
	pea	0.w
	pea	WA_Flags
	move.l	_Screen_Ptr,d0
	push	d0
	pea	WA_CustomScreen
	pea	TRUE
	pea	WA_AutoAdjust
	sub.l	a0,a0
	move.l	sp,a1
	call	_Open_Window
	lea	(17*4)(sp),sp
	move.l	d0,ww_WindowHandle(a4)
	move.l	d1,ww_RastPort(a4)
	move.l	d2,ww_ViewPort(a4)
	move.l	d3,ww_UserPort(a4)

	push	d7/a0
	move.l	d0,a0
	move.l	wd_WScreen(a0),ww_ScreenHandle(a4)

	move.l	ww_ScreenHandle(a4),a0
	move.w	sc_LeftEdge(a0),d0
	move.w	sc_TopEdge(a0),d1
	sub.w	ww_Height(a4),d1
	call	_MoveScreenTo
	
;*
;** create gadgets for this window
;*

	lea	ww_Gadgets(a4),a0
	move.l	a0,d0
	move.l	ww_GadgetList(a4),d7
	move.l	d7,a0
	move.l	a0,d7
	beq.s	.no_work_window_gadget_list
	push	d0-d7/a0-a6
	call	_Create_Work_Gadgets
	pop	d0-d7/a0-a6

	move.l	ww_Gadgets(a4),a0
	call	_Count_Gadgets
	move.l	a0,a1
	move.l	d0,d1
	moveq.l	#0,d0
	move.l	ww_WindowHandle(a4),a0
	call	_AddGList

.no_work_window_gadget_list


;*
;** execute the load procedure
;*
	move.l	ww_Load(a4),d7
	move.l	d7,a0
	move.l	a0,d7
	beq.s	.no_work_window_load_proc
	push	d0-d7/a0-a6
	call	(a0)
	pop	d0-d7/a0-a6
.no_work_window_load_proc
		
	pop	d7/a0
	rts


_ShutDown_RemoveWork_Window:

	push	d7/a0

;*
;** execute the unload procedure
;*
	move.l	ww_UnLoad(a4),d7
	move.l	d7,a0
	move.l	a0,d7
	beq.s	.no_work_window_load_proc
	push	d0-d7/a0-a6
	call	(a0)
	pop	d0-d7/a0-a6
.no_work_window_load_proc

;*
;** remove gadgets for this window
;*
	
	move.l	ww_WindowHandle(a4),a0
	call	_Remove_Windows_Gadget_List
	call	_Remove_All_Work_Gadget

	move.l	ww_ScreenHandle(a4),a0
	move.w	sc_LeftEdge(a0),d0
	move.w	sc_TopEdge(a0),d1
	add.w	ww_Height(a4),d1
	call	_MoveScreenTo

	move.l	ww_WindowHandle(a4),a0
	call	_Close_Window
	move.l	#0,ww_WindowHandle(a4)

	pop	d7/a0
	rts


_Minimise_Work_Window:
	rts

_Maximise_Work_Window:
	rts

;
;;
;
; AddWorkWindow :	Adds a Window to a Work screen at a specified position
;			or to the end of the list, and positions screen so that
;			the window is totally visible
;
;
;;
;

_AddWorkWindow:	*****************************************
* d0 = which window to open				*
* d1 = flags						*
*********************************************************
	push	a5
	lea	_WorkWindow_List,a5
	move.l	d0,d1
	mulu	#ww_SIZEOF,d1
	add.l	d1,a5
			;*
			;* if window is up already then exit
			;*
	tst.l	ww_WindowHandle(a5)
	bne	.add_win_finished
	
	moveq.l	#0,d7			; current id
	move.l	d7,d6
	move.l	d6,d5
	move.l	d5,d4
	
	lea	_WorkWindow_List,a4
.check_next_win_if_operating
	move.w	ww_ID(a4),d6
	tst.w	d6
	bmi	.add_win_finished
	cmp.w	d6,d0
	beq.s	.go_open_window

	tst.l	ww_WindowHandle(a4)
	beq	.not_in_operation

	tst.w	d5
	beq.s	.no_new_window_opened
	push	d0-d1/a0
	move.l	ww_WindowHandle(a4),a0
	move.w	ww_Left(a4),d0
	move.w	d7,d1
	call	_MoveWindowTo
	pop	d0-d1/a0
.no_new_window_opened
	add.w	ww_Height(a4),d7
	bra	.not_in_operation
.go_open_window

; d7 ::: holds the max window top position
	call	_Setup_AddWork_Window


	move.w	ww_Height(a4),d5
	add.w	d5,d7
.not_in_operation
	adda.l	#ww_SIZEOF,a4

	bra	.check_next_win_if_operating
.end_check_window

	
.add_win_finished
	pop	a5	
	rts

;
;;
;
; RemoveWorkWindow :	Removes a Window from a Work screen and positions
;			screen so that the window is totally visible
;
;
;
;;
;


_RemoveWorkWindow:
	push	a5
	lea	_WorkWindow_List,a5
	move.l	d0,d1
	mulu	#ww_SIZEOF,d1
	add.l	d1,a5
	tst.l	ww_WindowHandle(a5)
	beq	.remove_win_finish

	moveq.l	#0,d7			; current id
	move.l	d7,d6
	move.l	d6,d5
	
	lea	_WorkWindow_List,a4
.check_next_win_if_operating
	move.w	ww_ID(a4),d6
	tst.w	d6
	bmi	.remove_win_finish
	cmp.w	d6,d0
	beq.s	.go_close_window

	tst.l	ww_WindowHandle(a4)
	beq	.not_in_operation


	tst.w	d5
	beq.s	.no_new_window_opened
	push	d0-d1/a0


	move.l	ww_WindowHandle(a4),a0
	move.w	ww_Left(a4),d0
	move.w	d7,d1
	call	_MoveWindowTo

	
	pop	d0-d1/a0


.no_new_window_opened
	add.w	ww_Height(a4),d7

	bra	.not_in_operation
.go_close_window

	push	a0
	move.l	ww_ScreenHandle(a4),a0
	move.w	sc_LeftEdge(a0),d0
	move.w	sc_TopEdge(a0),d1
	add.w	ww_Height(a4),d1
	call	_MoveScreenTo
	pop	a0
	move.l	ww_WindowHandle(a4),a0
	call	_Close_Window
	move.l	#0,ww_WindowHandle(a4)

	move.w	ww_Height(a4),d5
.not_in_operation
	adda.l	#ww_SIZEOF,a4

	bra	.check_next_win_if_operating
.end_check_window


.remove_win_finish
	pop	a5	
	rts

 ENDC
	
_SysBase:		DC.L	0
_DOSBase:		DC.L	0
_IntuitionBase:		DC.L	0



_ThisTask:	DC.L	0
_WBenchMsg:	DC.L	0
_InitialSP:	DC.L	0
_Exit_Code:	DC.L	0


_DOSName:		DC.B	"dos.library",0
_IntuitionName:		DC.B	"intuition.library",0


 END

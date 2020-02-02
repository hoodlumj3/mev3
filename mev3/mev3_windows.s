 IFND	MEV3_WINDOWS_S
MEV3_WINDOWS_S SET 1


;**
; Note: Make a routine which keeps track of what was opened,
;  eg a library/screen/window, and a routine to close them in reverse
; or patch the existing routines that set up a linked list of : next.l,type.w, ptr.l
; so we can close them in reverse.
;**


;_WorkWindow_List:
;	NewWorkWindow	Project0,0,0,0,0,0,320,10
;	NewWorkWindow	Project1,1,0,0,0,0,320,50
;	NewWorkWindow	Project2,2,0,0,0,0,320,20
;	NewWorkWindow	Project3,3,0,0,0,0,320,5
;	NewWorkWindow	Project4,4,0,0,0,0,320,25
;	DC.W	-1


_Setup_AddWork_Window:	; d7 - wd_TopEdge
	push	d7/a0
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
;	pea	0.w

	pea	WFLG_SMART_REFRESH!WFLG_BORDERLESS!WFLG_REPORTMOUSE

	pea	WA_Flags
	move.l	gcWinScreenToUse,d0
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

	move.l	d3,a0
	moveq.l	#0,d0
	call	_Get_Window_SigBit
	move.l	d0,ww_SigBit(a4)

	move.l	ww_WindowHandle(a4),a0
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
	move.l	a0,a1
	move.l	ww_WindowHandle(a4),a0
	call	(a1)
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
	beq.s	.no_work_window_unload_proc
	push	d0-d7/a0-a6
	move.l	a0,a1
	move.l	ww_WindowHandle(a4),a0	
	call	(a1)
	pop	d0-d7/a0-a6
.no_work_window_unload_proc

;*
;** remove gadgets for this window
;*

	move.l	ww_Gadgets(a4),d7
	tst.l	d7
	beq.s	.no_work_gadgets_to_unload

	move.l	ww_WindowHandle(a4),a0
	call	_Remove_Windows_Gadget_List
	move.l	ww_Gadgets(a4),a0
	call	_Remove_Work_Gadgets
	move.l	#0,ww_Gadgets(a4)

.no_work_gadgets_to_unload

	move.l	ww_ScreenHandle(a4),a0
	move.w	sc_LeftEdge(a0),d0
	move.w	sc_TopEdge(a0),d1
	add.w	ww_Height(a4),d1
	call	_MoveScreenTo

	move.l	ww_WindowHandle(a4),a0
	call	_Close_Window
	moveq.l	#0,d0
	move.l	d0,ww_WindowHandle(a4)
	move.l	d0,ww_RastPort(a4)
	move.l	d0,ww_ViewPort(a4)
	move.l	d0,ww_UserPort(a4)
	move.l	d0,ww_SigBit(a4)

	pop	d7/a0
	rts

_GetWorkWindowHandle:
	push	a4
	lea	_WorkWindow_List,a4

	mulu	#ww_SIZEOF,d0
	add.l	d0,a4
	move.l	ww_WindowHandle(a4),d0
	move.l	ww_Gadgets(a4),d1
	move.l	ww_RastPort(a4),d2

	pop	a4	
	rts


_Minimise_Work_Window:
	rts

_Maximise_Work_Window:
	rts

_Retrieve_Ports_Using_SigBit:	*************************
*							*
* d0 = sigbit mask					*
*							*
*********************************************************

	push	a4
	
	lea	_WorkWindow_List,a4
.check_next_win_if_operating
	move.w	ww_ID(a4),d1
	tst.w	d1
	bmi	.add_win_finished

	tst.l	ww_WindowHandle(a4)
	beq	.not_in_operation

	move.l	ww_SigBit(a4),d1
	push	d0
	and.l	d1,d0
	cmp.l	d0,d1
	pop	d0
	bne.s	.not_this_sigbit
	move.l	ww_UserPort(a4),d0
	move.l	ww_RastPort(a4),d1
	move.l	ww_WindowHandle(a4),d2
	bra.s	.end_check_window
.not_this_sigbit
	
.not_in_operation
	adda.l	#ww_SIZEOF,a4

	bra	.check_next_win_if_operating
.end_check_window

	
.add_win_finished
	pop	a4
	rts

_Collect_WorkWindow_SigBits:	*************************
*							*
*********************************************************

	push	a4
	
	moveq.l	#0,d0			; current id
	
	lea	_WorkWindow_List,a4
.check_next_win_if_operating
	move.w	ww_ID(a4),d1
	tst.w	d1
	bmi	.add_win_finished

	tst.l	ww_WindowHandle(a4)
	beq	.not_in_operation

	move.l	ww_UserPort(a4),a0
	call	_Get_Window_SigBit

.not_in_operation
	adda.l	#ww_SIZEOF,a4

	bra	.check_next_win_if_operating
.end_check_window

	
.add_win_finished
	pop	a4

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
*							*
* d0 = gcWin<type> which window to open			*
* d1 = flags						*
*							*
*********************************************************
	call	_AddWorkWindow_NoArrange
	call	_ReArrangeWorkWindows
	rts

_AddWorkWindow_NoArrange:	*************************
*							*
* d0 = gcWin<type> which window to open			*
* d1 = flags						*
*							*
*********************************************************
	push	a4-a5
	lea	_WorkWindow_List,a4
	move.l	d0,d1
	mulu	#ww_SIZEOF,d1
	add.l	d1,a4
			;*
			;* if window is up already then exit
			;*


	tst.l	ww_WindowHandle(a4)
	bne.s	.add_win_finished

; d7 ::: holds the max window top position
	move.l	#0,d7
	call	_Setup_AddWork_Window

.add_win_finished
	pop	a4-a5	
	rts

;
;;
;
; RemoveWorkWindow :	Removes a Window from a Work screen and positions
;			the screen so that the window is totally visible
;
;
;
;;
;

_RemoveWorkWindow:	*********************************
*							*
* d0 = gcWin<type> to open on screen			*
*							*
*********************************************************
	call	_RemoveWorkWindow_NoArrange
	call	_ReArrangeWorkWindows
	rts

_RemoveWorkWindow_NoArrange:	*************************
*							*
* d0 = gcWin<type> to open on screen			*
*							*
*********************************************************
	push	a4-a5
	lea	_WorkWindow_List,a4
	move.l	d0,d1
	mulu	#ww_SIZEOF,d1
	add.l	d1,a4
	tst.l	ww_WindowHandle(a4)
	beq	.remove_win_finish

	call	_ShutDown_RemoveWork_Window

.remove_win_finish
	pop	a4-a5	
	rts

_ReArrangeWorkWindows:	*********************************
*							*
*********************************************************
	push	d1-d2/a4
	lea	_WorkWindow_List,a4

	moveq.l	#0,d2

.check_next_win_if_operating
	move.w	ww_ID(a4),d0
	tst.w	d0
	bmi.s	.check_these_wins_finish
	
	tst.l	ww_WindowHandle(a4)
	beq.s	.not_in_operation

	move.l	ww_WindowHandle(a4),a0
	push	d2/a0/a4
	moveq.l	#0,d0
	move.l	d2,d1
	call	_MoveWindowTo
	pop	d2/a0/a4
	add.w	wd_Height(a0),d2

.not_in_operation

	adda.l	#ww_SIZEOF,a4

	bra.s	.check_next_win_if_operating
.end_check_window

.check_these_wins_finish
	pop	d1-d2/a4	
	
	rts

	ifd	dugbarry

_AddWorkWindow:	*****************************************
*							*
* d0 = gcWin<type> which window to open			*
* d1 = flags						*
*							*
*********************************************************
	push	a4-a5
	lea	_WorkWindow_List,a5
	move.l	d0,d1
	mulu	#ww_SIZEOF,d1
	add.l	d1,a5
			;*
			;* if window is up already then exit
			;*


	tst.l	ww_WindowHandle(a5)
	bne.s	.add_win_finished

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
	pop	a4-a5	
	rts



_RemoveWorkWindow:	*********************************
*							*
* d0 = gcWin<type> to open on screen			*
*							*
*********************************************************
	push	a4-a5
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

	call	_ShutDown_RemoveWork_Window

	move.w	ww_Height(a4),d5
.not_in_operation
	adda.l	#ww_SIZEOF,a4

	bra	.check_next_win_if_operating
.end_check_window


.remove_win_finish
	pop	a4-a5	
	rts

	endc

_IsWindowOpen:	*****************************************
*							*
* d0 - window mask to check to see if they open		*
*							*
*********************************************************
	push	d1-d2/a4
	move.l	d0,d1
	moveq.l	#0,d2
	lea	_WorkWindow_List,a4

.check_next_win_if_operating
	move.w	ww_ID(a4),d0
	tst.w	d0
	bmi.s	.check_these_wins_finish
	
	btst	d0,d1
	beq.s	.dont_check_this_one
	
	tst.l	ww_WindowHandle(a4)
	beq.s	.not_in_operation

	bset	d0,d2			; set win bit (means it is open)

.not_in_operation

.dont_check_this_one
	adda.l	#ww_SIZEOF,a4

	bra.s	.check_next_win_if_operating
.end_check_window

.check_these_wins_finish
	move.l	d2,d0

	pop	d1-d2/a4	
	
	rts

_OpenTheseWindows:	*********************************
*							*
* d0 - window mask to open				*
*							*
*********************************************************
	push	d1/a4
	move.l	d0,d1
	lea	_WorkWindow_List,a4

.check_next_win_if_operating
	move.w	ww_ID(a4),d0
	tst.w	d0
	bmi.s	.open_these_wins_finish
	btst	d0,d1
	beq.s	.not_in_operation

	push	d1
	call	_AddWorkWindow_NoArrange
	pop	d1
.not_in_operation
	adda.l	#ww_SIZEOF,a4

	bra.s	.check_next_win_if_operating
.end_check_window

.open_these_wins_finish
	call	_ReArrangeWorkWindows

	pop	d1/a4	
	
	rts

_CloseTheseWindows:	*********************************
*							*
* d0 - window mask to close				*
*							*
*********************************************************
	push	d1-d2/a4
	move.l	d0,d1
	moveq.l	#0,d2
	lea	_WorkWindow_List,a4

.check_next_win_if_operating
	move.w	ww_ID(a4),d0
	tst.w	d0
	bmi.s	.close_these_wins_finish
	tst.l	ww_WindowHandle(a4)
	beq.s	.not_in_operation
	btst	d0,d1
	beq.s	.not_in_operation
	bset	d0,d2
	push	d1-d2
	call	_RemoveWorkWindow_NoArrange
	pop	d1-d2
.not_in_operation
	adda.l	#ww_SIZEOF,a4

	bra.s	.check_next_win_if_operating
.end_check_window

.close_these_wins_finish
	call	_ReArrangeWorkWindows
	move.l	d2,d0
	pop	d1-d2/a4	
	
	rts

_AddWorkScreen:

	pea	TAG_DONE
	pea	Minus_1
	pea	SA_Pens
	lea	_Work_Screen_Colours,a1
	push	a1
	pea	SA_Colors
	pea	200.w
	pea	SA_Height
	pea	640.w
	pea	SA_Width
	pea	3.w
	pea	SA_Depth
	pea	HIRES_KEY
	pea	SA_DisplayID
	pea	249.w
	pea	SA_Top

	move.l	sp,a1
	sub.l	a0,a0
	call	_Open_Screen
	lea	(15*4)(sp),sp
	move.l	d0,gcWinScreenToUse

	rts


_RemoveWorkScreen:
	moveq.l	#-1,d0
	call	_CloseTheseWindows
	move.l	gcWinScreenToUse,a0
	call	_Close_Screen
	rts



 ENDC

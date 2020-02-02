	IFND	MATTS_STACK_FUNCS
MATTS_STACK_FUNCS	SET	1

*
* Options are	WB_ARGS		- for checking of workbench startup args
*		CLI_ARGS	- for the checking of cli startup args
*		STACK_SIZE	- The optional stack size for this application
*		ARGS_ALLOC	- use _Malloc routine to get mem for buffer
*				- gcDosCmdBufferSize needs to be > 32
*

;
;;
;

*	INIT_AMIGA	; init startup code for running from WB of CLI
*			; Options to have WB args CLI args OR Both

INIT_AMIGA	macro	; base	; (a5)/(gl)
;		push	a6

;		movem.l	d0/a0,_DosCmdLength\1

		move.l	d0,d2
		move.l	a0,a2
		base	Sys,\1
		sub.l	a1,a1
		call	FindTask
		move.l	d0,_ThisTask\1
		move.l	d0,a3
		tst.l	pr_CLI(a3)
		bne.s	.init_started_from_cli
		lea	pr_MsgPort(a3),a0
		call	WaitPort
		lea	pr_MsgPort(a3),a0
		call	GetMsg
		move.l	d0,_WBenchMsg\1
.init_started_from_wb
	IFD	WB_ARGS
		move.l	d0,a0
		move.l	sm_NumArgs(a0),d0
		move.l	d0,_Argc\1
		move.l	sm_ArgList(a0),a0
		lea	_Argv\1,a1
		lea	_ArgLocks\1,a2
		cmp.w	#MAX_ARGC,d0
		blt.s	.wb_arg_count_ok
		move.w	#MAX_ARGC,d0
.wb_arg_count_ok
		bra.s	.next_wb_arg_pass
.next_wb_arg
		move.l	wa_Name(a0),(a1)+
		move.l	wa_Lock(a0),(a2)+
		addq.l	#wa_SIZEOF,a0
.next_wb_arg_pass
		dbra	d0,.next_wb_arg
	ENDC
		bra	.init_end
.init_started_from_cli
	IFD	BREAK_ENABLED
		moveq.l	#0,d0
		move.l	#SIGBREAKF_CTRL_C|SIGBREAKF_CTRL_D,d1
		base	Sys,\1
		call	SetSignal
	ENDC
	IFD	CLI_ARGS
		move.l	pr_CLI(a3),a0
		add.l	a0,a0
		add.l	a0,a0
		move.l	$10(a0),a1
		add.l	a1,a1
		add.l	a1,a1
		move.l	d2,d0
		moveq.l	#0,d1
		move.b	(a1)+,d1
		add.l	d1,d0
		addq.l	#7,d0
		andi.w	#$FFFC,d0
	IFD	ARGS_ALLOC
		push	d0/d2/a2
		move.l	#gcDosCmdBufferSize,d0
		call	_Malloc
		move.l	d0,_DosCmdBuffer\1
		move.l	d0,a0
		pop	d0/d2/a2
	ELSEIF
		lea	_DosCmdBuffer\1,a0
	ENDC
		move.l	d2,d0
		subq.l	#1,d0
		add.l	d1,d2
.1
		move.b	0(a2,d0.w),2(a0,d2.w)
		subq.l	#1,d2
		dbra	d0,.1
		move.b	#$20,2(a0,d2.w)
		subq.l	#1,d2
		move.b	#$22,2(a0,d2.w)
.2
		move.b	(a1,d2.w),1(a0,d2.w)
		dbf	d2,.2
		move.b	#$22,(a0)

		clr.l	_Argc\1		; arg count
		lea	_Argv\1,a1
.next_argv
		cmp.l	#MAX_ARGC,_Argc\1
		bhs.s	.end_cut_argv
		move.b	(a0),d0
		beq.s	.end_cut_argv
		cmp.b	#$22,d0
		bne.s	.not_quote
		addq.l	#1,a0
		addq.l	#1,_Argc\1
		move.l	a0,(a1)+
.next_in_quote
		move.b	(a0),d0
		beq.s	.end_cut_argv
		cmp.b	#'"',d0
		beq.s	.quote_complete
		addq.l	#1,a0
		bra.s	.next_in_quote
.quote_complete
		move.b	#0,(a0)
		bra.s	.next_to_argv
.not_quote
;		cmp.b	#' ',d0
;		bne.s	.not_space
;		addq.l	#1,a0
;		bra.s	.next_to_argv
.not_space
		cmp.b	#'!',d0
		blt.s	.next_to_argv
		cmp.b	#'~',d0
		bhi.s	.next_to_argv
		addq.l	#1,_Argc\1
		move.l	a0,(a1)+
.find_space
		move.b	(a0),d0
		beq.s	.end_cut_argv
		cmp.b	#' ',d0
		ble.s	.end_find_space
		addq.l	#1,a0
		bra.s	.find_space
.end_find_space
		move.b	#0,(a0)

.next_to_argv
		addq.l	#1,a0
		bra.s	.next_argv
.end_cut_argv
	ENDC
.init_end
;		pop	a6

		endm
;
;;
;

*	EXIT_AMIGA	; close down a task from WB OR CLI

EXIT_AMIGA	macro	; base ; (a5)/(gl)
;		push	a6
	IFD	ARGS_ALLOC
		move.l	_DosCmdBuffer\1,a0
		call	_Free
	ENDC
		base	Sys,\1
		move.l	_WBenchMsg\1,D3
		beq.s	.exit_started_from_cli
;		push	d3
		call	Forbid
;		pop	d3
		move.l	d3,a1
		call	ReplyMsg
.exit_started_from_cli
;		pop	a6

		endm
;
;;
;

*	create_stack		; creates an optional stack of size STACK_SIZE

create_stack	macro
    IFD	STACK_SIZE
	move.l	a0,a5
	move.l	d0,d5
	move.l	#STACK_SIZE+528,d0		; size of stack frame
	move.l	#MEMF_CLEAR|MEMF_ANY,d1		; any type & clear mem
	move.l	d0,d2
	move.l	4.w,a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	bne.s	.allocated_stack_ok
	moveq.l	#20,d0
	rts
.allocated_stack_ok
	add.l	d2,d0
	exg.l	d0,sp
	move.l	d0,-(sp)
	move.l	a5,a0
	move.l	d5,d0
    ENDC
	endm
;
;;
;

*	remove_stack		; removes the previously created stack

remove_stack	macro
    IFD	STACK_SIZE
	move.l	d0,d2
	move.l	#STACK_SIZE+528,d0
	move.l	(sp)+,a1
	exg.l	a1,sp
	suba.l	d0,a1
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)
	move.l	d2,d0
    ENDC
	endm

;
;;
;

*	linkstack	a5,50	; will create 50 bytes on stack which can be referenced by a5

linkstack	macro	; a reg, size
		move.l	#(\2/2)-1,d7
.\@
		clr.w	-(sp)
		dbra	d7,.\@
		move.l	sp,\1
		endm
;
;;
;

*	unlkstack	50	; will remove a stack of size 50 bytes

unlkstack	macro	; size
		lea	\1(sp),sp
		endm

;
;;
;

*	open_liby	; name,version,base,label

open_liby	macro	; name,version,base,label
	move.l	#\2,d0
	lea	_\1Name(pc),a1
	base	Sys,\3
	call	OpenLibrary
	move.l	d0,_\1Base\3
	beq	\4
;	bne.s	.\@
;	bra	\4
;.\@

		endm
;
;;
;

*	close_liby	; name,base

close_liby	macro	; name,base
	move.l	_\1Base\2,d0
	move.l	d0,a1
	beq.s	.\@
	base	Sys,\2
	call	CloseLibrary
.\@
		endm

;
;;
;
 IFD	EXTRA_FUNCS
INSTALL_Screen_Funcs	macro	; {TagList} {base {(gl)}}
_Open_Screen:	*****************************************
* a0 -> screen struct (null)				*
* a1 -> taglist (NULL)					*
*********************************************************
		push	a6
		base	Intuition,\2
		call	OpenScreen\1
		pop	a6
		tst.l	d0
		bne.s	.screen_opened_ok
		bra	_Exit
.screen_opened_ok
		move.l	d0,d1
		add.l	sc_RastPort,d1
;		move.l	d0,d2
;		add.l	sc_ViewPort,d2
		rts

_Close_Screen:	*****************************************
* a0 = screen handle					*
*********************************************************
		move.l	a0,d0
		beq.s	.close_screen_ok
		push	a6
		base	Intuition,\2
		call	CloseScreen
		pop	a6		
.close_screen_ok
		rts

		endm
;
;;
;

INSTALL_Window_Funcs	macro	; {TagList} {base {(gl)} }

_Open_Window:	*****************************************
*  a0 -> new window					*
*  a1 -> taglist					*
*********************************************************

		push	a6
		base	Intuition,\2
		call	OpenWindow\1
		pop	a6
		tst.l	d0
		bne.s	.window_opened_ok
		bra	_Exit
.window_opened_ok
		push	a0
		move.l	d0,a0
		move.l	wd_RPort(a0),d1
		move.l	wd_WScreen(a0),d2
		add.l	sc_ViewPort,d2
		move.l	wd_UserPort(a0),d3
		pop	a0
		rts

_Close_Window:	*****************************************
*  a0 =  window						*
*********************************************************
		move.l	a0,d0
		beq.s	.close_window_ok
		push	a6
		base	Intuition,\2
		call	CloseWindow
		pop	a6		
.close_window_ok
		rts

		endm
;
;;
;

INSTALL_Library_Funcs	macro	; {base (gl)}

_Open_Library:	*****************************************
*  d0 =  version					*
*  a1 -> name						*
*********************************************************
		push	a0/a6
		base	Sys,\1
		call	OpenLibrary
		pop	a0/a6
		tst.l	d0
		bne.s	.lib_opened_ok
		bra	_Exit
.lib_opened_ok
		rts


_Close_Library:	*****************************************
*  a1 - librarybase					*
*********************************************************
		move.l	a1,d0
		beq.s	.nothing_to_close
		push	a6
		base	Sys,\1
		call	CloseLibrary
		pop	a6
.nothing_to_close
		rts
		endm
;
;;
;

*	open_lib DOS,37,(a5)	; open dos.library ver 37

open_lib	macro	; lib name, version, base eg {(a5)}
		moveq.l	#\2,d0
		lea	_\1Name(pc),a1
		bsr	_Open_Library
		move.l	d0,_\1Base\3
	endm

;
;;
;

*	close_lib DOS,(a5)	; close dos.library

close_lib	macro	; "lib name",{base {(gl)}}
		move.l	_\1Base\2,a1
		bsr	_Close_Library		
		endm
 ENDC
	ENDC

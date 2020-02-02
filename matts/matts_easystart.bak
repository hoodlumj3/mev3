	IFND	MATTS_EASYSTART_S
MATTS_EASYSTART_S SET	1

;	SECTION	CODE,CODE_C

;	incdir	"include:"

;	include	"exec/funcdef.i"
;	include	"exec/exec.i"
;	include	"dos/dos.i"
	include	"include:dos/dosextens.i"

;	include	"exec/exec_lib.i"
;	include	"dos/dos_lib.i"


;	movem.l	d0-d7/a0-a6,-(sp)
;	move.l	sp,_Initial_SP

;	move.l	_Initial_SP,sp
;	movem.l	d0-d7/a0-a6,-(sp)

_Exit:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	_Shutdown_Exit_Routine
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	EXIT_AMIGA
	move.l	_Initial_SP,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

_Set_Exit_Jump:		; a0 - jump for close down, (if error)
	move.l	a0,_Routine_To_Shutdown_If_Error
	rts

_Clear_Exit_Jump:
	move.l	#0,_Routine_To_Shutdown_If_Error
	rts

_Shutdown_Exit_Routine:
	lea	_Routine_To_Shutdown_If_Error,a0
	moveq.l	#2,d0
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

_PError:
	move.l	a6,-(sp)
 IFD	debug_info
	lea	8(sp),a1
	move.l	(a1)+,a0
	movem.l	a1,-(sp)
	bsr	_Print_NNL
	movem.l	(sp)+,a1
	move.l	(a1)+,a0
	bsr	_Print
 ENDC
	move.l	(sp)+,a6
	rts

INIT_AMIGA:
;	movem.l	a5,-(sp)
;	lea	_Initial_SP,a5
;	move.l	$4,_SysBase
	move.l	_SysBase,a6
	suba.l	a1,a1
	jsr	_LVOFindTask(a6)
	lea	_Own_Task,a0
	move.l	d0,(a0)
	move.l	d0,a4
	tst.l	pr_CLI(a4)
	bne.s	.10
	lea	pr_MsgPort(a4),a0
	move.l	_SysBase,a6
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a4),a0
	jsr	_LVOGetMsg(a6)
	lea	_WorkBenchMessage,a0
	move.l	d0,(a0)
.10
;	moveq.l	#LIBRARY_MINIMUM,d0
;	lea	_DosName,a0
;	move.l	_SysBase,a6
;	jsr	_LVOOpenLibrary(a6)
;	bne.s	.20
;		
;.20
;	lea	_DosBase,a0
;	move.l	d0,(a0)
;	movem.l	(sp)+,a5
	rts


EXIT_AMIGA:
	move.l	_WorkBenchMessage,d0
	tst.l	d0
	beq.s	10$
	move.l	_SysBase,a6
	jsr	_LVOForbid(a6)
	move.l	_WorkBenchMessage,a1
	move.l	_SysBase,a6
	jsr	_LVOReplyMsg(a6)
10$
	moveq.l	#0,d0
	rts

_Initial_SP:		DC.L	0
_Own_Task:		DC.L	0
_WorkBenchMessage:	DC.L	0

	ENDC	; MATTS_EASYSTART_S


	IFND	MATTS_AGABEGIN_S
MATTS_AGABEGIN_S SET	1
;AGA_START_DEBUG	SET	1
;multitask
;debug
; exec lib
_Supervisor	EQU	-30
_Forbid		EQU	-132
_Permit		EQU	-138
_FindTask	EQU	-294
_SetTaskPri	EQU	-300
_CloseLibrary	EQU	-414
_OpenLibrary	EQU	-552

; graphics lib
_LoadView	EQU	-222
_WaitTOF	EQU	-270

aga_ActiView	EQU	$22
aga_CopInit	EQU	$26
aga_AttnFlags	EQU	$128
;	incdir	"include:"
;	include	"exec/execbase.i"
	

	rsreset
aga_wbview		rs.l	1
aga_graphicsbase	rs.l	1
aga_task		rs.l	1
aga_SIZEOF		rs.l	0

AGA_Startup:
	moveq.l	#(aga_SIZEOF/2)-1,d7
.clear_stack
	clr.w	-(sp)
	dbra	d7,.clear_stack
	move.l	sp,a5

	move.l	$4.w,a6
	sub.l   a1,a1			; Zero - Find current task
	jsr	_FindTask(a6)
	move.l	d0,aga_task(a5)

 IFND	debug
  IFND	multitask
	move.l	$4.w,a6
	jsr	_Forbid(a6)
  ELSEIF
	move.l	aga_task(a5),a1
	move.l	#0,d0			; task priority to very high...
	jsr	_SetTaskPri(a6)

  ENDC
 ENDC
	move.l	$4.w,a6
	btst	#0,aga_AttnFlags+1(a6)
					; check processor type
					; AttnFlags = 296
	beq.s	.aga_no_vbr
	movem.l	a5,-(sp)
	lea	.aga_vbr_exception(pc),a5
	move.l	$4.w,a6
	jsr	_Supervisor(a6)
	movem.l	(sp)+,a5
.aga_no_vbr
	move.l	a4,_VBR

	
	move.l	$4.w,a6			; get ExecBase
	lea	_GraphicsName,a1	; graphics name
	moveq.l	#0,d0			; any version
	jsr	_OpenLibrary(a6)
	tst.l	d0
	beq	.aga_end			; failed to open? Then quit
	move.l	d0,aga_graphicsbase(a5)
	move.l	d0,a6
	move.l	aga_ActiView(a6),aga_wbview(a5)
					; store current view address
					; gb_ActiView = 32
 IFND	debug
.aga_loop
 	sub.l	a1,a1			; clears full long-word
	jsr 	_LoadView(a6)		; Flush View to nothing
	jsr	_WaitTOF(a6)		; Wait once
	jsr	_WaitTOF(a6)		; Wait again.

        cmp.l	#0,aga_ActiView(a6)	; Any other view appeared?
	bne.s	.aga_loop		; If so wipe it.

 ENDC

;	move.w	$dff07c,d0
;	cmp.b	#$f8,d0
;	bne.s	.notaga
;	move.w	#0,$dff1fc		; reset sprites (fix V39 bug)
;.notaga


;	cmp.b	#50,VBlankFrequency(a6) ; Am I *running* PAL?
;	bne.s	.ntsc
;
;	move.l	#mycopper,$dff080 	; bang it straight in.
;	bra.s	.lp
;
;.ntsc	move.l	#mycopperntsc,$dff080
;.lp
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	_main
	movem.l	(sp)+,d0-d7/a0-a6


.aga_closedown:

	move.l	aga_wbview(a5),a1
	move.l	aga_graphicsbase(a5),a6
	jsr	_LoadView(a6)	; Fix view

	move.l	aga_CopInit(a6),$dff080	; Kick it into life
					; copinit = 38
	move.l	a6,a1
	move.l	4.w,a6
	jsr	_CloseLibrary(a6)

 IFND	debug
  IFND	multitask
	move.l	$4.w,a6
	jsr	_Permit(a6)
  ELSEIF
	move.l	aga_task(a5),a1
	move.l	#0,d0			; task priority to very high...
	jsr	_SetTaskPri(a6)
  ENDC
 ENDC

.aga_end
	lea	aga_SIZEOF(sp),sp
	moveq.l	#0,d0
	rts				; back to workbench/clc

.aga_vbr_exception
	DC.L	$4E7AC801		; movec	VBR,a4
	rte




 IFD	AGA_START_DEBUG
_main:
	rts
_VBR:		DC.L	0
_GraphicsName:	DC.B	"graphics.library",0
 EVEN
 ENDC
	ENDC	; MATTS_AGABEGIN_S

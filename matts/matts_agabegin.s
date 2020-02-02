
	IFND	MATTS_AGABEGIN_S
MATTS_AGABEGIN_S SET	1

AGA_Startup:
	move.l	$4.w,a6			; get ExecBase
	lea	GraphicsName,a1		; graphics name
	moveq	#0,d0			; any version
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq	AGA_End			; failed to open? Then quit
	move.l	d0,GraphicsBase
	move.l	d0,a6
	move.l	gb_ActiView(a6),wbview
					; store current view address
					; gb_ActiView = 32

 IFND	multitask
 IFND	debug
 	move.w	#0,a1			; clears full long-word
	jsr 	_LVOLoadView(a6)	; Flush View to nothing
	jsr	_LVOWaitTOF(a6)		; Wait once
	jsr	_LVOWaitTOF(a6)		; Wait again.
 ENDC
 ENDC
	move.w	$dff07c,d0
	cmp.b	#$f8,d0
	bne.s	.notaga

	move.w	#0,$dff1fc		; reset sprites (fix V39 bug)

.notaga

 IFND	multitask
 IFND	debug
	move.l	$4.w,a6
	jsr	_LVOForbid(a6)
 ENDC
 ENDC
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	_main
	movem.l	(sp)+,d0-d7/a0-a6

 IFND	multitask
 IFND	debug
	move.l	$4.w,a6
	jsr	_LVOPermit(a6)
 ENDC
 ENDC
AGA_CloseDown:

	move.l	wbview,a1
	move.l	GraphicsBase,a6
	jsr	_LVOLoadView(a6)	; Fix view

	move.l	gb_copinit(a6),$dff080	; Kick it into life
					; copinit = 36
	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)	; EVERYONE FORGETS THIS!!!!
AGA_End:

	rts				; back to workbench/clc

	ENDC	; MATTS_AGABEGIN_S

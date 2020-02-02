 IFND	MEV3_STRING_S
MEV3_STRING_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
*
* $VER:mev3_string.s 01.01a  © (28/Feburary/95) M.J.Edwards
*
*

;******************
; String Functions
;******************

_Print:			; a0 - string
	push	a0
	call	_Printf
	pop	a0
_Print_NL:		; a0 - string
	lea	_New_Line(pc),a0

_Print_NNL:		; a0 - string
	push	a0
	call	_Printf
	pop	a0
	rts
; EVEN


;	open_lib	DOS,33,(gl)
;	push	a6
;	base	DOS,(gl)
;	call	Output
;	pop	a6
;	move.l	d0,_Stdout(gl)


gcPrintfBufferSize	EQU	512

_Buffer_Printf	DC.L	0
;_stdout:	DC.L	0
;_stdin:		DC.L	0

_New_Line:		DC.B	10,0
_ConName:		DC.B	"CON:0/21/640/80/Mev3.0's Output/CLOSE",0
	EVEN

_Close_Output_Window:	; d1 - stdout
;	move.l	_stdin,d1
	tst.l	d1
	beq.s	.no_window_opened

	move.l	_DosCmdBuffer,a0
	move.l	a0,d2
	move.l	#gcDosCmdBufferSize,d3
	base	DOS
	call	Read

	move.l	_stdin,d1
	base	DOS
	call	Close
.no_window_opened
	rts

_Open_Output_Window:	; a0 - con_string

;	lea	_ConName(PC),a0
	move.l	a0,d1
	move.l	#MODE_NEWFILE,d2
	base	DOS
	call	Open
	move.l	d0,_stdin
	move.l	d0,_stdout
	tst.l	d0
	bne.s	.output
	moveq.l	#20,d0
	jmp	_Exit
.output
	rts


_Printf:	; sp -> format - args...
	push	a6
	tst.l	_stdout
	bne.s	.output

	lea	_ConName(PC),a0
	call	_Open_Output_Window

.output
	move.l	#gcPrintfBufferSize,d0
	call	_Malloc
	move.l	d0,_Buffer_Printf
	lea	2*4(sp),a1
	move.l	(a1)+,a0
	lea	_Printf_Char_Capture(pc),a2
	move.l	_Buffer_Printf(pc),a3
	move.l	a3,d2
	base	Sys
	call	RawDoFmt
	move.l	_stdout,D1
	move.l	d2,a0
.next_char
	tst.b	(a0)+
	bne.s	.next_char
	sub.l	d2,a0
	move.l	a0,d3
	subq.l	#1,D3
	base	DOS
	call	Write
	move.l	_Buffer_Printf(pc),a0
	call	_Free
	pop	a6
	rts

_SPrintf:		; sp - buffer - format - var,var,var
	push	a0-a3/a6
	lea	6*4(sp),a1	; vars ...
	move.l	(a1)+,a3	; buffer
	lea	_Printf_Char_Capture(pc),a2
	move.l	(a1)+,a0	; format
	base	Sys
	call	RawDoFmt
	pop	a0-a3/a6
	rts

_Printf_Char_Capture:
	move.b	d0,(a3)+
	rts

_StrLen:		; a0 - string
	movem.l	a0,-(sp)
	moveq.l	#0,d0
.10
	tst.b	(a0)+
	beq.s	.20
	addq.l	#1,d0
	cmp.l	#512,d0
	bge.s	.20
	bra.s	.10
.20	
	movem.l	(sp)+,a0
	rts

_StrCpy:		; a0 - source, a1 - destination
	bsr	_StrLen
	addq.l	#1,d0
	bsr	_StrnCpy
	subq.l	#1,d0
	rts	

_StrnCpy:		; a0 - source, a1 - destination, d0 - length
	push	d0-d1/a0-a1
	bra.s	.2
.1
	move.b	(a0)+,(a1)+
.2
	dbra	d0,.1
	pop	d0-d1/a0-a1
	rts

_StrCat:		; a0 - source, a1 - destination
	exg.l	a0,a1
	bsr	_StrLen
	exg.l	a0,a1
	add.l	d0,a1
	bsr	_StrCpy
	rts

_StrCmp:		; a0 - string1, a1 - string2
	push	d1/a0-a1
.strcmp_next
	move.b	(a0),d0		; get in char from each and
	cmp.b	#0,d0		; if this char is null then exit
	beq.s	.strcmp_end2
	or.b	#$20,d0		; convert to lower case
	move.b	(a1),d1
	cmp.b	#0,d1		; if this char is null then exit
	beq.s	.strcmp_end3

	or.b	#$20,d1
	cmp.b	d0,d1		; are they the same ?
	bne.s	.strcmp_end	;   -> nop end it all
	addq.w	#1,a0		; inc pointers
	addq.w	#1,a1
	cmp.b	#0,d0		; end of string1 -> a0
	bne.s	.strcmp_next	; nope keep going
.strcmp_end
	sub.b	d1,d0		; get difference
.strcmp_end2
	bra.s	.strcmp_end4
.strcmp_end3
	moveq.l	#0,d0
.strcmp_end4
	pop	d1/a0-a1	; d0 -> {-tve : < } OR { 0 : = } OR { +tve : > }
	rts

_ToUpper:
	cmp.b	#'a',d0
	blo.s	.not_in_range
	cmp.b	#'z',d0
	bhi.s	.not_in_range
	sub.b	#'a'-'A',d0
.not_in_range
	rts

_StrToUpper:	;a0 - source string, a1 - destin string
	push	d0-d1/a0-a1
	bsr	_StrLen
	addq.w	#1,d0
	move.w	d0,d1
	bra.s	.2
.1
	move.b	(a0)+,d0
	bsr	_ToUpper
	move.b	d0,(a1)+
.2
	dbra	d1,.1
	pop	d0-d1/a0-a1
	rts



 ENDC

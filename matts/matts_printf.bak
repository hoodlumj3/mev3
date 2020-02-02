	IFND	MATTS_PRINTF_S
MATTS_PRINTF_S	SET	1

;MATTS_PRINT_FUNC
;MATTS_STRLEN_FUNC
;MATTS_STRCPY_FUNC
;MATTS_STRCMP_FUNC
;MATTS_STRCAT_FUNC
;MATTS_PRINTF_FUNC
;MATTS_PRINTFCAP_FUNC
;MATTS_SPRINTF_FUNC


 IFD MATTS_PRINT_FUNC
MATTS_STRLEN_FUNC

_Print:
	bsr	_StrLen
	bsr	_Print_String
_Print_NL:
	lea	_New_Line,a0
_Print_NNL:
	bsr	_StrLen
	bsr	_Print_String
	rts


;_Calc_Length_Print:
;	clr.l	d3
;	movem.l	a0,-(sp)
;10$
;	tst.b	(a0)+
;	beq.s	20$
;	addq.l	#1,d3
;	bra.s	10$
;20$
;	movem.l	(sp)+,a0
;	rts
_Print_String:		; a0 - Start ; d0 - length
	movem.l	a0-a2,-(sp)
	move.l	a0,d2
	move.l	d0,d3
	move.l	_stdout,d1
	move.l	_DOSBase,a6
	jsr	_LVOWrite(a6)
	movem.l	(sp)+,a0-a2
	rts

_New_Line:		DC.B	10,0
_Buffer:		DS.B	128
 EVEN


 ENDC

;
;;
;

 IFD MATTS_STRCMP_FUNC

_StrCmp:
	move.l	#512,d0

_StrnCmp:		; d0 - strlen, a0 - string1, a1 - string2
	push	d1-d2/a0-a1
	move.l	d0,d2
.strcmp_next
	move.b	(a0),d0		; get in char from each and
	or.b	#$20,d0		; convert to lower case
;	and.b	#~($20),d0	; convert to upper case
	move.b	(a1),d1
	or.b	#$20,d1		; convert to lower case
;	and.b	#~($20),d1
	cmp.b	d0,d1		; are they the same ?
	bne.s	.strcmp_end	;   -> nop end it all
	addq.w	#1,a0		; inc pointers
	addq.w	#1,a1
	subq.w	#1,d2		; length of string exausted?
	beq.s	.strcmp_end	; yep
	cmp.b	#0,d0		; end of string1 -> a0
	bne.s	.strcmp_next	; nope keep going
.strcmp_end
	sub.b	d1,d0		; get difference
	pop	d1-d2/a0-a1	; d0 -> {-tve : < } OR { 0 : = } OR { +tve : > }
	rts
 ENDC

;
;;
;

 IFD MATTS_PRINTF_FUNC

_Printf:
	move.l	a6,-(sp)
	lea	8(sp),a1
	move.l	(a1)+,a0
	lea	Printf_Char_Capture(pc),a2
	lea	_Buffer,a3
	move.l	_SysBase,a6
	jsr	_LVORawDoFmt(a6)
	move.l	a3,a0
	bsr	_Print_NNL
	move.l	(sp)+,a6
	rts

MATTS_PRINTFCAP_FUNC
MATTS_PRINT_FUNC

 ENDC

;
;;
;

 IFD MATTS_SPRINTF_FUNC

_SPrintf:	; sp - buffer - format - var,var,var
	move.l	a6,-(sp)
	lea	2*4(sp),a1
	move.l	(a1)+,a3
	lea	Printf_Char_Capture(pc),a2
	move.l	(a1)+,a0

	move.l	_SysBase,a6
	jsr	_LVORawDoFmt(a6)
	move.l	(sp)+,a6
	rts

MATTS_PRINTFCAP_FUNC

 ENDC


;
;;
;

 IFD MATTS_PRINTFCAP_FUNC

Printf_Char_Capture:
	move.b	d0,(a3)+
	rts
 ENDC

;
;;
;

 IFD MATTS_STRCAT_FUNC
MATTS_STRLEN_FUNC
MATTS_STRCPY_FUNC

_StrCat:		; a0 - source, a1 - destination
	exg.l	a0,a1
	bsr	_StrLen
	exg.l	a0,a1
	add.l	d0,a1
	bsr	_StrCpy
	rts
 ENDC
;
;;
;

 IFD MATTS_STRCPY_FUNC
MATTS_STRLEN_FUNC
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
 ENDC


;
;;
;

 IFD MATTS_STRLEN_FUNC

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
 ENDC


 	ENDC	; MATTS_PRINTF_S


	IFND	MATTS_CMDCUT_S
MATTS_CMDCUT_S	SET	1


	xref	_SysBase
	xref	Cmd_String_Address
	xref	Cmd_String_Length
	xref	ARGC
	xref	ARGV

	xdef	ARGC_MAX

	xdef	Cut_CmdLine
 
Cut_CmdLine:
	movem.l	d0-d1/a0-a3/a6,-(sp)
	move.l	_SysBase(pc),a6
	move.l	$114(a6),a3
	tst.l	$ac(a3)
	beq	90$
	move.l	$ac(a3),a1
	adda.l	a1,a1
	adda.l	a1,a1
	move.l	$10(a1),a0
	adda.l	a0,a0
	adda.l	a0,a0
	moveq.l	#0,d1
	move.b	(a0)+,d1
	clr.b	0(a0,d1.w)
	lea	ARGV(pc),a1
	bsr	Save_Argv
	move.l	Cmd_String_Address(pc),a0
	move.l	Cmd_String_Length(pc),d0
	move.b	#0,(a0,d0.l)			; clear end of string
	cmpi.b	#10,-1(a0,d0.l)			; check end for CR
	bne.s	5$
	move.b	#0,-1(a0,d0.l)
	subq.l	#1,d0
	lea	Cmd_String_Length(pc),a2
	move.l	d0,(a2)
5$
	move.l	a0,a2
10$
	move.l	ARGC(pc),d0
	cmpi.l	#ARGC_MAX,d0
	beq.s	90$
	cmpi.b	#0,(a0)
	bne.s	20$
	bra	90$
20$
	cmpi.b	#'"',(a0)		; find quote
	bne.s	30$
	addq.l	#1,a0
	bsr	Save_Argv		; quote found
	bsr	Find_Quote
	move.b	#0,-1(a0)		; make space/NULL a quote
	bra.s	10$
30$
	cmpi.b	#' ',(a0)		; find space
	bne.s	40$
	bsr	Find_Space
	bra	10$
40$
	move.b	(a0),d0			; find chars
	cmpi.b	#'!',d0
	blo.s	50$
	cmpi.b	#'~',d0
	bhi.s	50$
	bsr	Save_Argv
	bsr	Find_Space
	move.b	#0,-1(a0)
	bra	10$	
50$

80$
	addq.l	#1,a0
	bra.s	10$
90$
	movem.l	(sp)+,d0-d1/a0-a3/a6
	rts

Find_Space:
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	10$
	cmpi.b	#' ',d0
	bne.s	Find_Space
10$
	rts

Find_Quote:
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	10$
	cmpi.b	#'"',d0
	bne.s	Find_Quote
10$
	rts

Save_Argv:
	move.l	a0,(a1)+
	addq.l	#1,ARGC-PC(a5)
	rts


Cmd_String_Address:	DC.L	0
Cmd_String_Length:	DC.L	0
ARGC:			DC.L	0
ARGV:			DS.L	ARGC_MAX
	ENDC	; MATTS_CMDCUT_S


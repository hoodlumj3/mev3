
_Malloc_CHIP:		; d0 - size
	moveq.l	#MEMF_CHIP,d1
	bra.s	_Malloc_Certain
_Malloc_FAST:
	moveq.l	#MEMF_FAST,d1
	bra.s	_Malloc_Certain
_Malloc_ANY:
	moveq.l	#MEMF_ANY,d1
	bra.s	_Malloc_Certain
_Malloc:		; d0 - size
	move.l	#MEMF_CLEAR,d1
_Malloc_Certain:
	push	d2/a6
	addq.l	#8,d0		; add 2 long for next node & size of this node
	move.l	d0,d2
	base	Sys,(gl)
	call	AllocMem
	tst.l	d0
	beq.s	.alloc_fail
	move.l	d0,a0
	move.l	_Mem_List(gl),0(a0)
	move.l	d2,4(a0)
	move.l	d0,_Mem_List(gl)
	addq.l	#8,d0
.alloc_fail
	pop	d2/a6
	rts

_Free:		; a0 - location of mem
	push	d1/a1-a2/a6
	base	Sys,(gl)
	move.l	a0,d0
	beq.s	.end_mem
	subq.l	#8,d0
	lea	_Mem_List(gl),a1
	move.l	a1,a2
	move.l	(a1),a1
.next_node
	move.l	a1,d1
	beq.s	.end_mem
	cmp.l	d1,d0
	beq.s	.free_mem
	move.l	a1,a2
	move.l	0(a1),a1
	bra.s	.next_node
.free_mem
	move.l	0(a1),0(a2)
	move.l	4(a1),d0
	base	Sys,(gl)
	call	FreeMem
.end_mem
	pop	d1/a1-a2/a6
	rts

_Free_All:
	push	a1-a2/a6
	base	Sys,(gl)
	move.l	_Mem_List(gl),a2
	move.l	a2,d0
	beq.s	.finished_all
.next_node
	move.l	a2,a1
	move.l	4(a2),d0
	move.l	(a2),a2
	call	FreeMem
	move.l	a2,d0
	bne.s	.next_node
.finished_all
	pop	a1-a2/a6
	rts


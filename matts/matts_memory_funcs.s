 IFND	MATTS_MEMORY_FUNCS_S
MATTS_MEMORY_FUNCS_S SET 1

*
**
*** $VER:matts_memory_funcs.s 01.1a  © (28/Febuary/95) M.J.Edwards
**
*

;mem_test
;	ifd	mem_test
;		incdir	"include:"
;		include	"exec/types.i"
;		include	"exec/memory.i"
;		include	"lib/exec_lib.i"
;		include	"/matts/matts_macros.i"
;
;_SysBase:
;_Exit:
;
;	endc 

    STRUCTURE	MemNode,0
	APTR	mn_Next
	APTR	mn_Size
	LABEL	mn_TheStartOfAllocatedMemory
	LABEL	mn_SIZEOF

_Memory_Node:	DC.L	0

_Malloc:			; d0 - bytes
_Malloc_ANY:			; d0 - bytes
	push	d1
	move.l	#MEMF_ANY,d1
	bsr	_Malloc_Choice
	pop	d1
	rts
_Malloc_CHIP:			; d0 - bytes
	push	d1
	move.l	#MEMF_CHIP,d1
	bsr	_Malloc_Choice
	pop	d1
	rts
_Malloc_FAST:			; d0 - bytes
	push	d1
	move.l	#MEMF_FAST,d1
	bsr	_Malloc_Choice
	pop	d1
	rts
_Malloc_Choice:			; d0 - bytes, d1 - MEMF_type
	or.l	#MEMF_CLEAR,d1
	bsr	_Allocate
	tst.l	d0
	bne.s	.alloc_end
	moveq.l	#12,d0
	jmp	_Exit
.alloc_end
	tst.l	d0
	rts




_AllocMem:		; d0 - # bytes
_AllocMem_ANY:		; d0 - # bytes
	push	d1
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	bsr.s	_Allocate
	pop	d1
	rts
_AllocMem_CHIP:		; d0 - # bytes
	push	d1
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	bsr.s	_Allocate
	pop	d1
	rts
_AllocMem_FAST:		; d0 - # bytes
	push	d1
	move.l	#MEMF_FAST!MEMF_CLEAR,d1
	bsr.s	_Allocate
	pop	d1
	rts
_Allocate:
	push	d2/a0-a2/a6
	tst.l	d0
	beq.s	.alloc_mem_end
	addq.l	#mn_SIZEOF,d0
	move.l	d0,d2
	base	Sys
	call	AllocMem
	tst.l	d0
	bne.s	.alloc_mem_ok
	bra.s	.alloc_mem_end
.alloc_mem_ok
	lea	_Memory_Node(pc),a2
	move.l	d0,a0
	move.l	d2,mn_Size(a0)
	move.l	mn_Next(a2),mn_Next(a0)
	move.l	a0,mn_Next(a2)
	addq.l	#mn_SIZEOF,d0
.alloc_mem_end
	pop	d2/a0-a2/a6
	tst.l	d0
	rts

_Free:	; a0 - location
	push	a0-a2/a6
	sub.l	#mn_SIZEOF,a0
	lea	_Memory_Node(pc),a2
	move.l	mn_Next(a2),a1
.next_mem_node
	move.l	a1,d0
	move.l	d0,a1
	beq.s	.no_more_nodes
	cmp.l	a0,a1
	beq.s	.mem_node_found
	move.l	a1,a2
	move.l	mn_Next(a1),a1
	bra.s	.next_mem_node	
.mem_node_found
	move.l	mn_Next(a1),mn_Next(a2)
	move.l	mn_Size(a1),d0
	base	Sys
	call	FreeMem
.no_more_nodes
	pop	a0-a2/a6	
	rts	

_Free_All_Mem:
	push	a0-a2/a6
	lea	_Memory_Node(pc),a2
.next_mem_node
	move.l	mn_Next(a2),a1
	move.l	a1,d0
	move.l	d0,a1
	beq.s	.no_more_nodes
	move.l	mn_Next(a1),mn_Next(a2)
	push	a1-a2
	move.l	mn_Size(a1),d0
	base	Sys
	call	FreeMem
	pop	a1-a2
	bra.s	.next_mem_node
.no_more_nodes
	pop	a0-a2/a6	
	rts	

 ENDC

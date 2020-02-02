 IFND	MEV3_UTILITY_C_S
MEV3_UTILITIY_C_S SET 1

TESTING

 ifd	TESTING


	incdir	"include:"
	include	"exec/memory.i"
	include	"exec/types.i"
	include	"lib/exec_lib.i"

	include	"/matts/matts_macros.i"
	include	"mev3.i"

_main:
	move.l	$4,_SysBase
	move.l	#52,d0
	bsr	_AllocMem
	move.l	d0,_Mem_1
	move.l	#50,d0
	bsr	_AllocMem
	move.l	d0,_Mem_2
	move.l	_Mem_1,a0
	bsr	_Free
	move.l	_Mem_2,a0
	bsr	_Free

	bsr	_Free_All_Mem

_Exit:

	rts
_Mem_1:		DC.L	0
_Mem_2:		DC.L	0

_SysBase:	DC.L	0

    STRUCTURE	MemNode,0
	APTR	mn_Next
	APTR	mn_Size
	LABEL	mn_TheStartOfAllocatedMemory
	LABEL	mn_SIZEOF

_Memory_Node:	DC.L	0

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
	lea	_Memory_Node,a2
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
	lea	_Memory_Node,a2
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
	lea	_Memory_Node,a2
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


 endc

 ENDC

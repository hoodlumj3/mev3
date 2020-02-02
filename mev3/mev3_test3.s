 IFND	MEV3_TEST3_S
MEV3_TEST3_S SET 1

	incdir	"include:"
	include	"exec/memory.i"
	include	"exec/types.i"
	include	"lib/exec_lib.i"

	include	"/matts/matts_macros.i"
	include	"mev3.i"

_main:
	move.l	$4,_SysBase

	move.l	#0,d0
	call	_Allocate_Shape_Header	; allocate shape header

	moveq.l	#6,d0
	move.l	#9,d1
	move.l	#0,d2
	move.l	#0,d3
	move.w	#0,d4
	bsr	Allocate_Shape_Mem	; add shape 1
	moveq.l	#0,d0
	move.l	#0,d1
	move.l	#8,d2
	move.l	#1,d3
	move.w	#0,d4
	bsr	Allocate_Shape_Mem	; add shape 2

	bsr	Calculate_Shape_Info	; calc shape ptr

_Exit:
	call	_DeAllocate_All_Shape_Mem	; remove all shape stuff
	rts

_Get_Node_Ptr:	*****************************************
* d0 == node number					*
* a0 -> header_node					*
*********************************************************
* d0 - node count					*
* a0 - actual node OR NULL				*
* a1 - previous node OR NULL				*
*********************************************************
	moveq.l	#0,d1		; counter
	move.l	(a0),a1		; head->next
	
.while
	cmp.l	d0,d1		; while (i!=node AND p != NULL) {
	beq.s	.while_end
	move.l	a1,d2
	move.l	d2,a1
	bne.s	.node_not_null
	bra.s	.while_end
.node_not_null
	addq.l	#1,d1		;   i ++
	move.l	a1,a0		;   old = p
	move.l	(a1),a1		;   p = p->next
	bra.s	.while
.while_end			; }
	rts

_Count_Nodes:	*****************************************
* a0 -> header_node					*
*********************************************************
* d0 - number of nodes in list				*
*********************************************************
	push	a0
	moveq.l	#0,d0
.while
	tst.l	(a0)
	beq.s	.while_end
		addq.l	#1,d0
		move.l	(a0),a0
		bra.s	.while
.while_end
	pop	a0
	rts

_Calculate_Node_Ptr:	*********************************
* a0 -> header_node					*
*********************************************************
* a0 - actual node ptr OR NULL				*
* a1 - previous node ptr OR NULL			*
*********************************************************

;;	lea	_Project_Node_Header,a0	; old = head
	move.l	(a0),a1			; p = head->next
.while
	move.l	a1,d1			; while (p) {
	move.l	d1,a1
	beq.s	.while_end
	move.l	a1,a0			;   old = p
	move.l	(a1),a1			;   p = p->next
	bra.s	.while			; }
.while_end
;;	move.l	d0,proj_Next(a0)	; old->next = i
;;	move.l	d0,a2
;;	move.l	a1,proj_Next(a2)	; i->next = p
	rts




_Allocate_Shape_Header:	*********************************
* d0 - node number					*
*	=  0		 - new/add node			*
*	=  1 to  MAX_MAP - replace node			*
*	= -1 to -MAX_MAP - remove node			*
*********************************************************
	push	a1-a2
	tst.w	d0
	beq	.shape_header_add
	bpl.s	.shape_header_replace

.shape_header_remove
	push	d0
	ext.l	d0
	neg.l	d0
	bsr	Calculate_Shape_Header_Node
;	push	a0-a1
;	bsr	_DeAllocate_Shape_Header		; kill all data
;	pop	a0-a1
						; unlink node
	move.l	shphdr_Next(a0),shphdr_Next(a1)	; previous->next = requested->next
	move.l	#0,shphdr_Next(a0)		; requested->next = NULL
	move.l	#shphdr_SIZEOF,d0
	jsr	_Free				; free node
	pop	d0
	bra	.shape_header_end

.shape_header_replace
	push	d0
	ext.l	d0
	bsr	Calculate_Shape_Header_Node
	pop	d0
	cmp.l	#0,a0			; if (requested) {
	beq.s	.shape_header_add
	bra.s	.shape_header_end	; }
					; else
.shape_header_add				
	ext.l	d0
	bsr	Calculate_Shape_Header_Node
	move.l	#shphdr_SIZEOF,d0
	jsr	_Malloc				; allocate node newnode
	move.l	d0,a0

						; link to list
	move.l	shphdr_Next(a1),shphdr_Next(a0)	; newnode->next = previous->next
	move.l	a0,shphdr_Next(a1)		; previous->next = newnode

.shape_header_end
	pop	a1-a2

	rts

;    STRUCTURE	SHAPE_HEADER,0
;	APTR	shphdr_Next
;	APTR	shphdr_Name
;	APTR	shphdr_First
;	LABEL	shphdr_SIZEOF

_DeAllocate_All_Shape_Mem:
	lea	_Shape_Header_Info_Header,a0
	move.l	shphdr_Next(a0),d0	; pointer from header
.while_shape_header
	tst.l	d0			; is it a null
	beq.s	.while_end		; yes, we have reached the end of the list
	move.l	d0,a0
	move.l	shphdr_First(a0),a1	; get the first shape node from header
	push	a0
.while_shape
		move.l	a1,d0
		move.l	shape_Next(a1),a1	; get pointer to next in list
		move.l	d0,a0			; is it null
		beq.s	.while_shape_end	; yes, end of shape list
		push	a1
		bsr	_DeAllocate_Shape	; no, then deallocate shape memory
		call	_Free			; free shape node
		pop	a1
		bra.s	.while_shape		; go around again
.while_shape_end
	pop	a0
	move.l	shphdr_Next(a0),d0		; save off next
	push	d0
	push	a0
	move.l	shphdr_Name(a0),a0		; free shape header name
	call	_Free
	pull	a0
	call	_Free				; free shape header node
	pop	a0
	pop	d0
	bra.s	.while_shape_header
.while_end
	rts

_AllocMem:		; d0 - bytes
_AllocMem_ANY:		; d0 - bytes
	push	d1-d2/a0-a1/a6
	move.l	#MEMF_ANY!MEMF_CLEAR,d1
	bra.s	_Allocate
_AllocMem_CHIP:		; d0 - bytes
	push	d1-d2/a0-a1/a6
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	bra.s	_Allocate
_AllocMem_FAST:		; d0 - bytes
	push	d1-d2/a0-a1/a6
	move.l	#MEMF_FAST!MEMF_CLEAR,d1
	bra.s	_Allocate
	nop
_Allocate:
	tst.l	d0
	beq.s	.alloc_end

	addq.l	#4,d0		; add 4 to size
	move.l	d0,d2
	base	Sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	bne.s	.alloc_ok
	bra.s	.alloc_end
.alloc_ok
	move.l	d0,a0
	move.l	d2,(a0)+
	move.l	a0,d0
.alloc_end
	pop	d1-d2/a0-a1/a6
	tst.l	d0
	rts

_Malloc:			; d0 - bytes
_Malloc_ANY:			; d0 - bytes
	push	d1-d2/a0-a1/a6
	move.l	#MEMF_ANY,d1
	bra.s	_Malloc_Choice
_Malloc_CHIP:			; d0 - bytes
	push	d1-d2/a0-a1/a6
	move.l	#MEMF_CHIP,d1
	bra.s	_Malloc_Choice
_Malloc_FAST:			; d0 - bytes
	push	d1-d2/a0-a1/a6
	move.l	#MEMF_FAST,d1
	bra.s	_Malloc_Choice
	nop
_Malloc_Choice:			; d0 - bytes, d1 - MEMF_type
	tst.l	d0
	beq.s	.alloc_end
	addq.l	#4,d0		; add 4 to size
	move.l	d0,d2
	or.l	#MEMF_CLEAR,d1
	base	Sys
	call	AllocMem
	tst.l	d0
	bne.s	.alloc_ok
	moveq.l	#12,d0
	jmp	_Exit
.alloc_ok
	move.l	d0,a0
	move.l	d2,(a0)+
	move.l	a0,d0
.alloc_end
	pop	d1-d2/a0-a1/a6
	tst.l	d0
	rts

_Free:			; a0 - location
	push	a0-a1/a6
	move.l	a0,d0
	move.l	d0,a1
	beq.s	.dealloc_end
	move.l	-(a1),d0
	base	Sys
	call	FreeMem
.dealloc_end	
	pop	a0-a1/a6
	rts

Calculate_Shape_Header_Info:
	move.w	_Shape_Set,d0
	bsr	Calculate_Shape_Header_Node
	rts

Calculate_Shape_Header_Node:	; d0 - node number
	push	d1-d2
	ext.l	d0
	subq.l	#1,d0
	lea	_Shape_Header_Info_Header,a0	; previous = header
	bsr	Calculate_Node_Number
	pop	d1-d2
	exg.l	a0,a1
	rts	; a0 - requested, a1 - previous


Calculate_Shape_Info:
	bsr	Calculate_Shape_Header_Info
	move.w	_Shape_Edit,d0
	lea	shphdr_First(a0),a0
	bsr	Calculate_Shape_Noder
	rts

Calculate_Shape_Node:	; d0 - node number

	push	d0
	bsr	Calculate_Shape_Header_Info
	pop	d0
	lea	shphdr_First(a0),a0

Calculate_Shape_Noder:	; d0 - node number, a0 - shape_info

	push	d1-d2
	ext.l	d0
;	subq.l	#1,d0
;	lea	_Shape_Info_Header,a0	; previous = header

	bsr	Calculate_Node_Number

	pop	d1-d2
	exg.l	a0,a1
	rts	; a0 - requested, a1 - previous

Calculate_Node_Number:	; d0 == number of node, a0 -> header node
	move.l	0(a0),a1		; requested = header->next
	moveq.l	#0,d1			; count = 0

.while					; while (requested && count != d4) {
	move.l	a1,d2
	move.l	d2,a1
	beq.s	.end_of_list
	cmp.l	d0,d1
	beq.s	.end_while
	move.l	a1,a0			;   previous = requested
	move.l	0(a1),a1		;   requested = requested->next
	addq.l	#1,d1			;   count++
	bra.s	.while
.end_while				; }
.end_of_list
	move.l	d1,d0
	rts

	BITDEF	FMT,CUT,0

Allocate_Shape_Mem:	*********************************
* d0 - width of cut					*
* d1 - height of cut					*
* d2 - count for shape					*
* d3 - Flags						*
*	= $0001 - cut(1)/coords(0)			*
*	= $8000 - Retain previous shape			*
* d4 - node number					*
*	=  0		 - add node			*
*	=  1 to  MAX_MAP - replace node			*
*	= -1 to -MAX_MAP - remove node			*
*********************************************************
	push	a1-a2
	lea	-shape_SIZEOF(sp),sp
	move.l	sp,a2
	tst.w	d4
	beq	.shape_add
	bpl.s	.shape_replace

.shape_remove
	push	d0-d4
	move.l	d4,d0
	ext.l	d0
	neg.l	d0
	bsr	Calculate_Shape_Node
	push	a0-a1
	bsr	_DeAllocate_Shape		; kill all data
	pop	a0-a1
						; unlink node
	move.l	shape_Next(a0),shape_Next(a1)	; previous->next = requested->next
	move.l	#0,shape_Next(a0)			; requested->next = NULL
	jsr	_Free				; free node
	pop	d0-d4
	bra	.shape_end

.shape_replace
	push	d0-d4
	move.l	d4,d0
	ext.l	d0
	bsr	Calculate_Shape_Node
	pop	d0-d4
	cmp.l	#0,a0			; if (requested) {
	beq.s	.shape_add
	push	d0-d4/a0
	move.l	a2,a1
	move.w	#shape_SIZEOF,d0
	bsr	_StrnCpy		; copy node

	pull	d0-d4/a0
	move.w	d0,shape_Width(a0)
	move.w	d1,shape_Height(a0)
	move.w	d2,shape_Count(a0)
	move.w	d3,shape_Flags(a0)
	jsr	_Allocate_Shape		; allocate tile
	pull	d0-d4/a0

	btst	#FMTB_RETAIN,d2
	beq.s	.shape_no_retain	; check if user wants to retain shape
	push	a0
	move.l	shape_Name(a0),a1	; from node name
	move.l	shape_Name(a2),a0	; temp name
	bsr	_StrCpy			; copy temp buffer to name
	pop	a0
.shape_no_retain
	move.l	a2,a0
	bsr	_DeAllocate_Shape

	pop	d0-d4/a0
	bra.s	.shape_do_rect		; }
					; else
.shape_add				
	push	d0-d4
	move.w	d4,d0			; node
	ext.l	d0
	bsr	Calculate_Shape_Node
	move.l	#shape_SIZEOF,d0
	call	_Malloc				; allocate node newnode
	move.l	d0,a0
	pop	d0-d4
						; link to list
	move.l	shape_Next(a1),shape_Next(a0)	; newnode->next = previous->next
	move.l	a0,shape_Next(a1)		; previous->next = newnode

	push	a0
	move.w	d0,shape_Width(a0)
	move.w	d1,shape_Height(a0)
	move.w	d2,shape_Count(a0)
	move.w	d3,shape_Flags(a0)
	jsr	_Allocate_Shape			; allocate
	pop	a0
.shape_do_rect
;	btst	#FMTB_RETAIN,d2
;	bne.s	.shape_alloc_end
;	push	a0
;;- set default shape
;	pop	a0
.shape_end
	lea	shape_SIZEOF(sp),sp
	pop	a1-a2

	rts

_Allocate_Shape:		; a0 - ptr to shape_info with flags & count | Width & Height initialized
	btst	#FMTB_CUT,shape_Flags(a0)
	beq.s	.not_cut
	move.w	shape_Width(a0),d0
	mulu	shape_Height(a0),d0
	add.l	d0,d0
	bra.s	.cut_ok
.not_cut
	move.w	shape_Count(a0),d0
	mulu	#3*2,d0
	add.l	d0,d0
.cut_ok
	move.l	d0,shape_Size(a0)
	jsr	_AllocMem_ANY	; alloc shape mem
	bne.s	.mem1_ok
;	lea	Text_FileType_Shape(pc),a0
;	lea	Text_No_Mem(pc),a1
;	jsr	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,shape_Size(a0)
.mem1_ok
	move.l	d0,shape_Location(a0)	; save location and init table
	push	d0
	moveq.l	#32,d0
	jsr	_AllocMem_ANY		; alloc name
	move.l	d0,shape_Name(a0)
	push	a0-a1
	move.l	d0,a1
	lea	_DefaultName,a0
	jsr	_StrCpy
;	lea	Text_FileExt_Shape,a0
;	jsr	_StrCat
	pop	a0-a1
	pop	d0
	rts

_DeAllocate_Shape:	; a0 - ptr to shape_info to deallocate
	push	a0
	move.l	shape_Location(a0),a0		; kill shape mem
	jsr	_Free
	pull	a0
	move.l	shape_Name(a0),a0		; kill shape name
	jsr	_Free
	pop	a0

	move.l	#0,d0				; clear node of all values
	move.l	d0,shape_Name(a0)
	move.w	d0,shape_Width(a0)
	move.w	d0,shape_Height(a0)
	move.w	d0,shape_HotX(a0)
	move.w	d0,shape_HotY(a0)
	move.w	d0,shape_Count(a0)
	move.w	d0,shape_Flags(a0)
	move.l	d0,shape_Location(a0)
	move.l	d0,shape_Size(a0)
	rts

*********************************************************
* Adding AND Replacing					*
*********************************************************
* d0 - node number					*
* d1 - width of cut					*
* d2 - height of cut					*
* d3 - count for shape					*
* d4 - Flags						*
*	= $0001 - cut(1)/coords(0)			*
*	= $8000 - Retain previous shape			*
*********************************************************

_Add_Shape_Header:
	bsr	_Allocate_Shape_Header_Node
	lea	_Shape_Header_Node_Header,a0
	bsr	_Calculate_Node_Ptr
	move.l	d0,a2
	move.l	shape_Next(a0),shape_Next(a2)
	move.l	a2,shape_Next(a0)
	rts

_Replace_Shape_Header_Node:
	rts

_Remove_All_Shape_Headers:
	lea	_Shape_Header_Node_Header,a0
	move.l	shape_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
	move.l	proj_Next(a0),a1
	bsr	_Free_Shape_Header_Node
	move.l	a1,a0
	bra.s	.while
.while_end
	rts

_Remove_Shape_Header_Node:	; d0 - node number to remove
	lea	_Shape_Header_Node_Header,a0
	bsr	_Get_Node_Ptr
	move.l	shape_Next(a1),shape_Next(a0)
	move.l	a1,a0
	bsr	_Free_Shape_Header_Node
	rts

_Allocate_Shape_Header_Node:
	move.l	#shape_SIZEOF,d0
	call	_Malloc
	move.l	d0,a0
	bsr	_Initialize_Shape_Header_Node
	move.l	a0,d0
	rts

_Free_Shape_Header_Node:	; a0 - project_mem_ptr
	call	_Free
	rts

_Initialize_Shape_Header_Node:
	moveq.l	#0,d0
	move.l	d0,shape_Next(a0)
	
	rts



_Initialize_Project_Node:	; a0 - project_node
	moveq.l	#0,d0
	move.l	d0,proj_Next(a0)
	subq.l	#1,d0
	move.w	d0,proj_Map(a0)
	move.w	d0,proj_Tile(a0)
	move.w	d0,proj_Palette(a0)
	move.w	d0,proj_Shape(a0)
	move.w	d0,proj_Copper(a0)
	move.w	d0,proj_Animation(a0)
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


_SysBase:			DC.L	0
_Shape_Set:			DC.W	1
_Shape_Edit:			DC.W	0
_Shape_Header_Info_Header:	DS.B	shphdr_SIZEOF
_DefaultName:			DC.B	"Default",0

 ENDC

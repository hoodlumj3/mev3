 IFND	MEV3_UTILITY_C_S
MEV3_UTILITIY_C_S SET 1

;TESTING

 ifd	TESTING


	incdir	"include:"
	include	"exec/memory.i"
	include	"exec/types.i"
	include	"lib/exec_lib.i"

	include	"/matts/matts_macros.i"
	include	"mev3.i"

_main:
	move.l	$4,_SysBase

	bsr	_Add_Project_Node
	moveq.l	#0,d0
	bsr	_Read_Project_Node

	move.l	#0,d0
	move.l	#100,d1
	move.l	#100,d2
	move.l	#0,d3
	bsr	_Add_Map_Node
	move.l	#0,d0
	move.l	#16,d1
	move.l	#16,d2
	move.l	#4,d3
	move.l	#80,d4
	move.l	#$8000,d5
	bsr	_Add_Tile_Node

	bsr	_Remove_All_Tile_Nodes
	bsr	_Remove_All_Map_Nodes
	bsr	_Remove_All_Project_Nodes
_Exit:

	rts

    STRUCTURE	Project_Node,0
	APTR	proj_Next
	APTR	proj_Name
	ULONG	proj_Flags
	STRUCT	proj_Map,map_SIZEOF
	STRUCT	proj_Tile,tile_SIZEOF
	STRUCT	proj_Palette,palette_SIZEOF
	STRUCT	proj_ShpHdr,shphdr_SIZEOF
	STRUCT	proj_Copper,copper_SIZEOF
	STRUCT	proj_Animation,animation_SIZEOF
	LABEL	proj_SIZEOF

	
	
_Project_Node_Header:		DS.B	proj_SIZEOF
_Map_Node:			DC.L	0
_Tile_Node:			DC.L	0
_Palette_Node:			DC.L	0
_ShpHdr_Node:			DC.L	0
_Shape_Node:			DC.L	0
_Copper_Node:			DC.L	0
_Animation_Node:		DC.L	0

	endc

_Get_Node_Ptr:	*****************************************
* d0 == node number					*
* a0 -> header_node					*
*********************************************************
* d0 - node count					*
* a0 - actual node OR NULL				*
* a1 - previous node OR NULL				*
*********************************************************
	push	d1
	moveq.l	#0,d1		; counter
	move.l	(a0),a1		; head->next
	
.while
	cmp.l	d0,d1		; while (i!=node AND p != NULL) {
	beq.s	.while_end
	move.l	a1,d2
	move.l	d2,a1
	bne.s	.node_not_null
	sub.l	a0,a0
	sub.l	a1,a1
	bra.s	.while_end
.node_not_null
	addq.l	#1,d1		;   i ++
	move.l	a1,a0		;   old = p
	move.l	(a1),a1		;   p = p->next
	bra.s	.while
.while_end			; }
	move.l	d1,d0
	pop	d1
	exg.l	a0,a1
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

_Calculate_Node_Ptr:	********************************* ; go to end of linked list
* a0 -> header_node					*
*********************************************************
* d1 - node number					*
* a0 - actual node ptr OR NULL				*
* a1 - previous node ptr OR NULL			*
*********************************************************

;;	lea	_Project_Node_Header,a0	; old = head
	push	d0
	moveq.l	#0,d0
	move.l	(a0),a1			; p = head->next
.while
	move.l	a1,d1			; while (p) {
	move.l	d1,a1
	beq.s	.while_end
	move.l	a1,a0			;   old = p
	move.l	(a1),a1			;   p = p->next
	addq.l	#1,d0
	bra.s	.while			; }
.while_end
	exg.l	a0,a1
	move.l	d0,d1
	pop	d0
;;	move.l	d0,proj_Next(a0)	; old->next = i
;;	move.l	d0,a2
;;	move.l	a1,proj_Next(a2)	; i->next = p
	rts

*********************************************************
* Adding (Projects)					*
*********************************************************
* d0 - node number					*
*********************************************************

_Read_Project_Node:	; d0 - node number
	lea	_Project_Node_Header,a0
	bsr	_Get_Node_Ptr
	lea	proj_Map(a0),a1
	move.l	a1,_Map_Node
	lea	proj_Tile(a0),a1
	move.l	a1,_Tile_Node
	lea	proj_Palette(a0),a1
	move.l	a1,_Palette_Node
	lea	proj_ShpHdr(a0),a1
	move.l	a1,_ShpHdr_Node
	lea	proj_Copper(a0),a1
	move.l	a1,_Copper_Node
	lea	proj_Animation(a0),a1
	move.l	a1,_Animation_Node
	rts

_Add_Project_Node:
	bsr	_Allocate_Project_Node
	lea	_Project_Node_Header,a0
	bsr	_Calculate_Node_Ptr
	move.l	d0,a2
	move.l	proj_Next(a1),proj_Next(a2)
	move.l	a2,proj_Next(a1)
	rts


_Remove_Project_Node:	; d0 - node number to remove
	lea	_Project_Node_Header,a0
	bsr	_Get_Node_Ptr
	move.l	proj_Next(a0),proj_Next(a1)
;	move.l	a0,a1
	bsr	_Free_Project_Node
	rts

_Allocate_Project_Node:
	move.l	#proj_SIZEOF,d0
	call	_Malloc
	move.l	d0,a0
	moveq.l	#32,d0
	bsr	_Malloc
	move.l	d0,proj_Name(a0)
	bsr	_Initialize_Project_Node
	move.l	a0,d0
	rts

_Free_Project_Node:	; a0 - project_mem_ptr
	push	a0
	move.l	proj_Name(a0),a0
	call	_Free
	pop	a0
	call	_Free
	rts

_Initialize_Project_Node:	; a0 - project_node
	push	a0
	moveq.l	#0,d0
	move.l	d0,proj_Next(a0)
	move.l	proj_Name(a0),a1	; get name from struct
	lea	_DefaultName,a0
	bsr	_StrCpy
	pop	a0
	rts

_DeInitialize_Project_Node:
	rts

_Replace_Project_Node:
	rts

_Remove_All_Project_Nodes:	; d0 - node number to replace
	lea	_Project_Node_Header,a0
	move.l	proj_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
	move.l	proj_Next(a0),a1
	bsr	_Free_Project_Node
	move.l	a1,a0
	bra.s	.while
.while_end
	rts

*********************************************************
* Adding AND Replacing (Map)				*
*********************************************************
* d0 - map node						*
* d1 - map width					*
* d2 - map height					*
* d3 - Flags						*
*	= $0001 - Stored				*
*	= $8000 - Retain previous map			*
*********************************************************


_Add_Map_Node:
	bsr	_Allocate_Map_Node
	move.l	_Map_Node,a0
	bsr	_Calculate_Node_Ptr	; throw node on end of list
	move.l	d0,a2
	move.l	map_Next(a1),map_Next(a2)
	move.l	a2,map_Next(a1)
	rts

_Remove_Map_Node:	; d0 - node number
	move.l	_Map_Node,a0
	bsr	_Get_Node_Ptr		; calc
	move.l	map_Next(a0),map_Next(a1)
	bsr	_Free_Map_Node
	rts

_Allocate_Map_Node:
	move.l	#map_SIZEOF,d0
	call	_Malloc				; get mem
	move.l	d0,a0
	moveq.l	#32,d0				; sizeof name 32 chars
	bsr	_Malloc
	move.l	d0,map_Name(a0)			; save nameptr in struct
	bsr	_Initialize_Map_Node		; initialize struct
	move.l	a0,d0
	rts

_Free_Map_Node:		; a0 - node_mem_ptr
	push	a0
	bsr	_DeInitialize_Map_Node		; kill all related mem
	pull	a0
	move.l	map_Name(a0),a0
	call	_Free				; free name
	pop	a0
	call	_Free				; and node
	rts

_Initialize_Map_Node:	; a0 - node_ptr
	push	a0

	move.w	d1,map_Width(a0)	; fill node with info
	move.w	d2,map_Height(a0)
	move.w	d3,map_Flags(a0)
	moveq.l	#0,d0
	move.w	d1,d0
	mulu	d2,d0
	add.l	d0,d0
	move.l	d0,map_Size(a0)
	call	_AllocMem_ANY	; alloc map mem
	bne.s	.map_allocated_ok
;	lea	Text_FileType_Map(pc),a0
;	lea	Text_No_Mem(pc),a1
;	call	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,map_Size(a0)
	bra	.init_end
.map_allocated_ok
	move.l	d0,map_Location(a0)	; save location and init map table
;	move.w	_Tile_Set,map_Tiles(a0)

	move.l	map_Name(a0),a1
	lea	_DefaultName,a0
	bsr	_StrCpy

	pull	a0

	moveq.l	#0,d0
	move.w	d0,map_Left(a0)
	move.w	d0,map_Top(a0)
	move.b	d0,map_Format(a0)
	move.b	#2,map_UnitSize(a0)

.map_alloc_do_rect
	btst	#FMTB_RETAIN,d3
	bne.s	.init_end

	pull	a0
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
;;	move.w	#0,d0
;;	move.w	#0,d1
	move.w	map_Width(a0),d2
	move.w	map_Height(a0),d3
	subq.w	#1,d2
	subq.w	#1,d3
;	lea	_Init_Write_Map_Tile,a0
;;	move.w	#0,_Rectangle_Filled
;	jsr	_Rectangle_Tile
.init_end
	pop	a0

	rts

_DeInitialize_Map_Node:		; a0 - node_ptr
	push	a0
	move.l	map_Location(a0),a0
	call	_Free
	pull	a0
	move.l	#0,d0
	move.w	d0,map_Width(a0)
	move.w	d0,map_Height(a0)
	move.w	d0,map_Flags(a0)
	move.l	d0,map_Location(a0)
	move.l	d0,map_Size(a0)
	move.w	d0,map_Left(a0)
	move.w	d0,map_Top(a0)
	move.w	d0,map_Tiles(a0)
	move.b	d0,map_UnitSize(a0)
	move.b	d0,map_Format(a0)
	move.w	d0,map_Shapes(a0)
	move.w	d0,map_Copper(a0)
	pop	a0
	rts

_Replace_Map_Node:	; d0 - node_number
	lea	-map_SIZEOF(sp),sp	
	move.l	sp,a2
	move.l	_Map_Node,a0
	bsr	_Get_Node_Ptr
	cmp.l	#0,a0			; if (requested) {
	beq.s	.replace_end
	push	a0
	move.l	a2,a1
	moveq.l	#map_SIZEOF,d0
	bsr	_StrnCpy		; copy old node
	bsr	_Initialize_Map_Node	; initialize new node
	btst	#FMTB_RETAIN,d3
	beq.s	.no_retain		; check if user wants to retain map
	pull	a0	
	move.w	#0,d0			; x source
	move.w	#0,d1			; y source
	move.w	map_Width(a2),d2	; w of source
	move.w	map_Height(a2),d3	; h of source
	move.w	map_Width(a0),d4	; w of destin
	move.w	map_Height(a0),d5	; h of destin
	move.l	map_Location(a0),a1	; destin
	move.l	map_Location(a2),a0	; source
;	bsr	_Transfer_Cut
.no_retain				; }
	move.l	a2,a0
	bsr	_DeInitialize_Map_Node
	pop	a0
.replace_end
	lea	map_SIZEOF(sp),sp
	rts

_Remove_All_Map_Nodes:
	move.l	_Map_Node,a0
	move.l	map_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
	move.l	map_Next(a0),a1
	bsr	_Free_Map_Node
	move.l	a1,a0
	bra.s	.while
.while_end

	rts

*********************************************************
* Adding AND Replacing (Tile)				*
*********************************************************
* d0 - tile node					*
* d1 - tile width					*
* d2 - tile height					*
* d3 - tile depth					*
* d4 - tile amount					*
* d5 - Flags						*
*	= $0001 - Mask Required	(FMTF_MASK)		*
*	= $0000 - Seperate WH List (FMTF_WHDIFF)	*
*	= $8000 - Retain previous tiles			*
*********************************************************

_Add_Tile_Node:
	bsr	_Allocate_Tile_Node
	move.l	_Tile_Node,a0
	bsr	_Calculate_Node_Ptr	; throw node on end of list
	move.l	d0,a2
	move.l	tile_Next(a1),tile_Next(a2)
	move.l	a2,tile_Next(a1)
	rts

_Remove_Tile_Node:	; d0 - node number
	move.l	_Tile_Node,a0
	bsr	_Get_Node_Ptr		; calc
	move.l	tile_Next(a0),tile_Next(a1)
	bsr	_Free_Tile_Node
	rts

_Allocate_Tile_Node:
	move.l	#tile_SIZEOF,d0
	call	_Malloc				; get mem
	move.l	d0,a0
	moveq.l	#32,d0				; sizeof name 32 chars
	bsr	_Malloc
	move.l	d0,tile_Name(a0)		; save nameptr in struct
	bsr	_Initialize_Tile_Node		; initialize struct
	move.l	a0,d0
	rts

_Free_Tile_Node:	; a0 - node_mem_ptr
	push	a0
	bsr	_DeInitialize_Tile_Node		; kill all related mem
	pull	a0
	move.l	tile_Name(a0),a0
	call	_Free				; free name
	pop	a0
	call	_Free				; and node
	rts

_Initialize_Tile_Node:
	push	a0

	move.w	d1,tile_Width(a0)	; fill node with info
	move.w	d2,tile_Height(a0)
	move.w	d3,tile_Depth(a0)
	move.w	d4,tile_Amount(a0)
	move.w	d5,tile_Flags(a0)
	
	move.w	d1,d0
	add.l	#$F,d0
	asr.w	#4,d0
	add.w	d0,d0	; num bytes wide
	mulu	d2,d0
	mulu	d4,d0
;	move.w	tile_Depth(a0),d1
;	move.w	tile_Flags(a0),d2
	btst	#FMTB_MASK,d5
	beq.s	.tile_no_mask
	addq.w	#1,d3		; add another plane for the mask
.tile_no_mask
	mulu	d3,d0
	move.l	d0,tile_Size(a0)

	call	_AllocMem_CHIP		; alloc image mem
	bne.s	.tile_allocated_ok
;	lea	Text_FileType_Tile(pc),a0
;	lea	Text_No_Mem(pc),a1
;	call	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,tile_Size(a0)
	bra	.init_end
.tile_allocated_ok
	move.l	d0,tile_Location(a0)	; save location and init map table

;	move.w	Palette_Set,tile_Palette(a0)

	move.l	tile_Name(a0),a1
	lea	_DefaultName,a0
	bsr	_StrCpy

	pull	a0

	moveq.l	#0,d0
	move.w	d0,tile_Edit(a0)
	move.w	d0,tile_Left(a0)
	move.w	d0,tile_Top(a0)

;.tile_alloc_do_rect
;	btst	#FMTB_RETAIN,d3
;	bne.s	.init_end
;
;	pull	a0
;	clr.l	d0
;	clr.l	d1
;	clr.l	d2
;	clr.l	d3
;;;	move.w	#0,d0
;;;	move.w	#0,d1
;	move.w	tile_Width(a0),d2
;	move.w	tile_Height(a0),d3
;	subq.w	#1,d2
;	subq.w	#1,d3
;;	lea	_Init_Write_Map_Tile,a0
;;;	move.w	#0,_Rectangle_Filled
;;	jsr	_Rectangle_Tile
.init_end
	pop	a0

	rts

_DeInitialize_Tile_Node:	; a0 - node_ptr
	push	a0
	move.l	tile_Location(a0),a0
	call	_Free
	pull	a0
	move.l	#0,d0
	move.w	d0,tile_Amount(a0)
	move.w	d0,tile_Width(a0)
	move.w	d0,tile_Height(a0)
	move.w	d0,tile_Depth(a0)	
	move.w	d0,tile_Flags(a0)
	move.l	d0,tile_Location(a0)
	move.l	d0,tile_Size(a0)
	move.w	d0,tile_Palette(a0)
	move.w	d0,tile_Edit(a0)
	move.w	d0,tile_Left(a0)
	move.w	d0,tile_Top(a0)
;	move.w	d0,tile_Animations(a0)
	pop	a0
	rts

_Replace_Tile_Node:
	lea	-tile_SIZEOF(sp),sp	
	move.l	sp,a2
	move.l	_Tile_Node,a0
	bsr	_Get_Node_Ptr
	cmp.l	#0,a0			; if (requested) {
	beq.s	.replace_end
	push	a0
	move.l	a2,a1
	moveq.l	#tile_SIZEOF,d0
	bsr	_StrnCpy		; copy old node
	bsr	_Initialize_Tile_Node	; initialize new node
	btst	#FMTB_RETAIN,d3
	beq.s	.no_retain		; check if user wants to retain tiles
	pull	a0	
.no_retain				; }
	move.l	a2,a0
	bsr	_DeInitialize_Tile_Node
	pop	a0
.replace_end
	lea	tile_SIZEOF(sp),sp
	rts

_Remove_All_Tile_Nodes:
	move.l	_Tile_Node,a0
	move.l	tile_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
	move.l	tile_Next(a0),a1
	bsr	_Free_Tile_Node
	move.l	a1,a0
	bra.s	.while
.while_end
	rts

*********************************************************
* Adding AND Replacing (Palette)			*
*********************************************************
* d0 - palette node					*
* d1 - depth of palette					*
* d2 - Flags						*
*	= $0001 - rgb4(0)/rgb32(1)			*
*	= $8000 - Retain previous palette		*
*********************************************************

_Add_Palette_Node:
	bsr	_Allocate_Palette_Node
	move.l	_Palette_Node,a0
	bsr	_Calculate_Node_Ptr	; throw node on end of list
	move.l	d0,a2
	move.l	palette_Next(a1),palette_Next(a2)
	move.l	a2,palette_Next(a1)
	rts

_Remove_Palette_Node:	; d0 - node number
	move.l	_Palette_Node,a0
	bsr	_Get_Node_Ptr		; calc
	move.l	palette_Next(a0),palette_Next(a1)
	bsr	_Free_Palette_Node
	rts

_Allocate_Palette_Node:
	move.l	#palette_SIZEOF,d0
	call	_Malloc				; get mem
	move.l	d0,a0
	moveq.l	#32,d0				; sizeof name 32 chars
	bsr	_Malloc
	move.l	d0,palette_Name(a0)		; save nameptr in struct
	bsr	_Initialize_Palette_Node	; initialize struct
	move.l	a0,d0
	rts

_Free_Palette_Node:	; a0 - node_mem_ptr
	push	a0
	bsr	_DeInitialize_Palette_Node	; kill all related mem
	pull	a0
	move.l	palette_Name(a0),a0
	call	_Free				; free name
	pop	a0
	call	_Free				; and node
	rts

_Initialize_Palette_Node:
	push	a0

	move.w	d1,palette_Depth(a0)	; fill node with info
	move.w	d2,tile_Flags(a0)

	move.w	d1,d0
	bsr	_Power_Of_2
;;	btst	#FMTB_RGB32,d2
;;	beq.s	.not_rgb32
;;	mulu	#3,d0
;;	bra.s	.rgb_ok
;;.not_rgb32
	add.l	d0,d0
.rgb_ok
	move.l	d0,palette_Size(a0)
	call	_AllocMem_ANY		; alloc image mem
	bne.s	.tile_allocated_ok
;;	lea	Text_FileType_Palette(pc),a0
;;	lea	Text_No_Mem(pc),a1
;;	call	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,palette_Size(a0)
	bra	.init_end
.tile_allocated_ok
	move.l	d0,palette_Location(a0)	; save location and init palette table
	pull	a0

	move.l	palette_Location(a0),a1	
	move.w	palette_Depth(a0),d0
	call	_Power_Of_2
	add.l	d0,d0
	lea	_Default_Colours,a0
	bsr	_StrnCpy
	pull	a0
	move.l	palette_Name(a0),a1
	lea	_DefaultName,a0
	bsr	_StrCpy

;	pull	a0

;	moveq.l	#0,d0

;.tile_alloc_do_rect
;	btst	#FMTB_RETAIN,d3
;	bne.s	.init_end
;
;	pull	a0
;	clr.l	d0
;	clr.l	d1
;	clr.l	d2
;	clr.l	d3
;;;	move.w	#0,d0
;;;	move.w	#0,d1
;	move.w	tile_Width(a0),d2
;	move.w	tile_Height(a0),d3
;	subq.w	#1,d2
;	subq.w	#1,d3
;;	lea	_Init_Write_Map_Tile,a0
;;;	move.w	#0,_Rectangle_Filled
;;	jsr	_Rectangle_Tile
.init_end
	pop	a0

	rts

_DeInitialize_Palette_Node:	; a0 - node_ptr
	push	a0
	move.l	palette_Location(a0),a0
	call	_Free
	pull	a0
	move.l	#0,d0
	move.w	d0,palette_Depth(a0)
	move.l	d0,palette_Location(a0)
	move.l	d0,palette_Size(a0)
	move.w	d0,palette_Flags(a0)
	pop	a0
	rts

_Replace_Palette_Node:
	lea	-palette_SIZEOF(sp),sp	
	move.l	sp,a2
	move.l	_Palette_Node,a0
	bsr	_Get_Node_Ptr
	cmp.l	#0,a0			; if (requested) {
	beq.s	.replace_end
	push	a0
	move.l	a2,a1
	moveq.l	#palette_SIZEOF,d0
	bsr	_StrnCpy		; copy old node
	bsr	_Initialize_Palette_Node	; initialize new node
	btst	#FMTB_RETAIN,d3
	beq.s	.no_retain		; check if user wants to retain tiles
	pull	a0	
.no_retain				; }
	move.l	a2,a0
	bsr	_DeInitialize_Palette_Node
	pop	a0
.replace_end
	lea	palette_SIZEOF(sp),sp
	rts

_Remove_All_Palette_Nodes:
	move.l	_Palette_Node,a0
	move.l	palette_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
	move.l	palette_Next(a0),a1
	bsr	_Free_Palette_Node
	move.l	a1,a0
	bra.s	.while
.while_end
	rts


;_Add_Copper_Node:
;_Remove_Copper_Node:
;_Allocate_Copper_Node:
;_Free_Copper_Node:
;_Initialize_Copper_Node:
;_DeInitialize_Copper_Node:
;_Replace_Copper_Node:
;_Remove_All_Copper_Nodes:

;_Add_Animation_Node:
;_Remove_Animation_Node:
;_Allocate_Animation_Node:
;_Free_Animation_Node:
;_Initialize_Animation_Node:
;_DeInitialize_Animation_Node:
;_Replace_Animation_Node:
;_Remove_All_Animation_Nodes:

*********************************************************
* Adding AND Replacing (Shape Header)			*
*********************************************************
* d0 - node number					*
*********************************************************

_Read_Shape_Header_Node:	; d0 - node number
	move.l	_ShpHdr_Node,a0
	bsr	_Get_Node_Ptr		; get node pointer
	tst.l	d0			; was it there?
	beq.s	.node_not_present
	lea	shphdr_First(a0),a1	; yep so get pointer
	move.l	a1,_Shape_Node	
.node_not_present
	rts

_Add_Shape_Header_Node:
	bsr	_Allocate_Shape_Header_Node	; alloc new node mem (d0)
	move.l	_ShpHdr_Node,a0
	bsr	_Calculate_Node_Ptr		; skip to end of list
	move.l	d0,a2
	move.l	shape_Next(a1),shape_Next(a2)	; link in new node
	move.l	a2,shape_Next(a1)
	rts


_Remove_Shape_Header_Node:	; d0 - node number to remove
	move.l	_ShpHdr_Node,a0
	bsr	_Get_Node_Ptr
	move.l	shphdr_Next(a0),shphdr_Next(a1)
	bsr	_Free_Shape_Header_Node
	rts

_Allocate_Shape_Header_Node:
	move.l	#shphdr_SIZEOF,d0
	call	_Malloc
	move.l	d0,a0
	moveq.l	#32,d0				; sizeof name 32 chars
	bsr	_Malloc
	move.l	d0,shphdr_Name(a0)		; save nameptr in struct
	bsr	_Initialize_Shape_Header_Node
	move.l	a0,d0
	rts

_Free_Shape_Header_Node:	; a0 - project_mem_ptr
	push	a0
	move.l	shphdr_Name(a0),a0
	call	_Free
	pull	a0	
	lea	shphdr_First(a0),a0
	move.l	a0,_Shape_Node
	bsr	_Remove_All_Shape_Nodes
	pop	a0
	call	_Free
	rts

_Initialize_Shape_Header_Node:
	push	a0
	moveq.l	#0,d0
	move.l	d0,shphdr_Next(a0)
	move.l	shphdr_Name(a0),a1
	lea	_DefaultName,a0
	bsr	_StrCpy
	pop	a0
	rts

_DeInitialize_Shape_Header_Node:
	rts

_Replace_Shape_Header_Node:
	rts

_Remove_All_Shape_Header_Nodes:
	move.l	_ShpHdr_Node,a0
	move.l	shphdr_Next(a0),a0
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

*********************************************************
* Adding AND Replacing (Shape)				*
*********************************************************
* d0 - node number					*
* d1 - width of cut					*
* d2 - height of cut					*
* d3 - count for shape					*
* d4 - Flags						*
*	= $0001 - cut(1)/coords(0)			*
*	= $8000 - Retain previous shape			*
*********************************************************

_Add_Shape_Node:
_Remove_Shape_Node:
_Allocate_Shape_Node:
_Free_Shape_Node:
_Initialize_Shape_Node:
_DeInitialize_Shape_Node:
_Replace_Shape_Node:
_Remove_All_Shape_Nodes:






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

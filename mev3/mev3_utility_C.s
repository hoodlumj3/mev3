 IFND	MEV3_UTILITY_C_S
MEV3_UTILITY_C_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

_Get_Node_Ptr:	*****************************************
* d0 == node number					*
* a0 -> header_node					*
*********************************************************
* d0 - node count					*
* a0 - actual node OR NULL				*
* a1 - previous node OR NULL				*
*********************************************************
	push	d1-d2
	ext.l	d0
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
	pop	d1-d2
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
	move.l	_Project_Node,a0
	move.w	_Project_Set,d0
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
	move.l	proj_Path(a0),_Init_Path

	rts

_Count_Project_Nodes:
	move.l	_Project_Node,a0
	bsr	_Count_Nodes
	rts

_Calculate_Project_Node:
	move.w	_Project_Set,d0
_Calc_Project_Node:
	move.l	_Project_Node,a0
	bsr	_Get_Node_Ptr
	rts

_Add_Project_Node:
	bsr	_Allocate_Project_Node
	move.l	_Project_Node,a0
	bsr	_Calculate_Node_Ptr
	move.l	d0,a2
	move.l	proj_Next(a1),proj_Next(a2)
	move.l	a2,proj_Next(a1)
	rts


_Remove_Project_Node:	; d0 - node number to remove
;	lea	_Project_Node_Header,a0
	move.l	_Project_Node,a0
	bsr	_Get_Node_Ptr
	move.l	proj_Next(a0),proj_Next(a1)
;	move.l	a0,a1
	bsr	_Free_Project_Node
	rts

_Allocate_Project_Node:
	move.l	#proj_SIZEOF,d0
	call	_Malloc
	move.l	d0,a0
	moveq.l	#gcFileNameSize,d0
	bsr	_Malloc
	move.l	d0,proj_Name(a0)
	move.l	#gcPathNameSize,d0
	bsr	_Malloc
	move.l	d0,proj_Path(a0)
	bsr	_Initialize_Project_Node
	move.l	a0,d0
	rts

_Free_Project_Node:	; a0 - project_mem_ptr
	push	a0
	move.l	proj_Name(a0),a0
	call	_Free
	pull	a0
	move.l	proj_Path(a0),a0
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
	lea	_Text_FileExt_Project,a0
	bsr	_StrCat	
	pull	a0
	move.l	proj_Path(a0),a1	; get name from struct
	move.l	_Application_Path,a0
	bsr	_StrCpy
	pop	a0
	rts

_DeInitialize_Project_Node:
	rts

_Replace_Project_Node:
	rts

_Remove_All_Project_Nodes:	; d0 - node number to replace
	move.l	_Project_Node,a0
;	lea	_Project_Node_Header,a0
	move.l	proj_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
	push	a0
	lea	proj_Map(a0),a0
	bsr	_Remove_All_Map_Node
	pull	a0
	lea	proj_Tile(a0),a0
	bsr	_Remove_All_Tile_Node
	pull	a0
	lea	proj_Palette(a0),a0
	bsr	_Remove_All_Palette_Node
	pull	a0
	lea	proj_ShpHdr(a0),a0
	bsr	_Remove_All_Shape_Header_Node
;	pull	a0
;	lea	proj_Copper(a0),a0
;	bsr	_Remove_All_Copper_Node
;	pull	a0
;	lea	proj_Animation(a0),a0
;	bsr	_Remove_All_Animation_Node
	pop	a0
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


_Count_Map_Nodes:
	move.l	_Map_Node,a0
	bsr	_Count_Nodes
	rts

_Calculate_Map_Node:
	move.w	_Map_Set,d0
_Calc_Map_Node:
	move.l	_Map_Node,a0
	bsr	_Get_Node_Ptr
	rts

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

Default_Map_Width	EQU	20
Default_Map_Height	EQU	12
dbgu3:
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
	push	d0-d3/a0-a6
	lea	_Text_FileType_Map,a0
	lea	_Text_No_Mem,a1
	call	_Inform_Request
	pop	d0-d3/a0-a6
	moveq.l	#0,d0
	move.l	d0,map_Size(a0)
	moveq.l	#Default_Map_Width,d1
	moveq.l	#Default_Map_Height,d2
	move.w	map_Flags(a0),d3
	bsr	_Initialize_Map_Node
	bra	.init_end
.map_allocated_ok
	move.l	d0,map_Location(a0)	; save location and init map table
	move.w	_Tile_Set,map_Tiles(a0)

	move.l	map_Name(a0),a1		; copy default name into map name
	lea	_DefaultName,a0
	bsr	_StrCpy
	lea	_Text_FileExt_Map,a0
	bsr	_StrCat
	
	pull	a0

	moveq.l	#0,d0
	move.w	d0,map_Left(a0)
	move.w	d0,map_Top(a0)
	move.b	d0,map_Format(a0)
	move.b	#2,map_UnitSize(a0)

.map_alloc_do_rect
	move.w	map_Flags(a0),d0
	btst	#FLGB_RETAIN,d0
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
	move.l	a0,a1
	lea	_Init_Write_Map_Tile,a0
;	move.w	#0,_Rectangle_Filled
	jsr	_Rectangle_Tile
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
	move.w	d0,map_Shape(a0)
	move.w	d0,map_Copper(a0)
	pop	a0
	rts

_Replace_Map_Node:	; d0 - node_number
	push	a2-a3
	lea	-map_SIZEOF(sp),sp
	move.l	sp,a2
	lea	-32(sp),sp
	move.l	sp,a3
	move.l	_Map_Node,a0
	bsr	_Get_Node_Ptr
	cmp.l	#0,a0			; if (requested) {
	bne.s	.node_present
	bsr	_Add_Map_Node
	bra.s	.replace_end
.node_present
;	cmp.l	#0,a0			; if (requested) {
;	beq.s	.replace_end
	push	a0			; map_node srce
	move.l	a2,a1			; temp to dest
	moveq.l	#map_SIZEOF,d0
	bsr	_StrnCpy		; copy old node
	move.l	map_Name(a0),a0
	move.l	a3,a1
	bsr	_StrCpy
	pull	a0
	bsr	_Initialize_Map_Node	; initialize new node
	move.l	map_Name(a0),a1		; map_name : destination
	move.l	a3,a0			; saved old map name source
	bsr	_StrCpy
	pull	a0
	btst	#FLGB_RETAIN,d3
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
	bsr	_Transfer_Cut
.no_retain				; }
	move.l	a2,a0
	bsr	_DeInitialize_Map_Node
	pop	a0
.replace_end
	lea	32(sp),sp
	lea	map_SIZEOF(sp),sp
	pop	a2-a3
	rts

_Remove_All_Map_Nodes:
	move.l	_Map_Node,a0
_Remove_All_Map_Node:		; a0 - map_node ptr
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
*	= $0001 - Mask Required	(FLGF_MASK)		*
*	= $0000 - Seperate WH List (FLGF_WHDIFF)	*
*	= $8000 - Retain previous tiles			*
*********************************************************

_Count_Tile_Nodes:
	move.l	_Tile_Node,a0
	bsr	_Count_Nodes
	rts

_Calculate_Tile_Node:
	move.w	_Tile_Set,d0
_Calc_Tile_Node:
	move.l	_Tile_Node,a0
	bsr	_Get_Node_Ptr
	rts

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

Default_Tile_Width	EQU	16
Default_Tile_Height	EQU	16
Default_Tile_Depth	EQU	4
Default_Tile_Amount	EQU	2

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
	btst	#FLGB_MASK,d5
	beq.s	.tile_no_mask
	addq.w	#1,d3		; add another plane for the mask
.tile_no_mask
	mulu	d3,d0
	move.l	d0,tile_Size(a0)

	call	_AllocMem_CHIP		; alloc image mem
	bne.s	.tile_allocated_ok
	push	d0-d5/a0-a6
	lea	_Text_FileType_Tile,a0
	lea	_Text_No_Mem,a1
	call	_Inform_Request
	pop	d0-d5/a0-a6
	moveq.l	#0,d0
	move.l	d0,tile_Size(a0)
	moveq.l	#Default_Tile_Width,d1
	moveq.l	#Default_Tile_Height,d2
	moveq.l	#Default_Tile_Depth,d3
	moveq.l	#Default_Tile_Amount,d4
	move.w	tile_Flags(a0),d5
	bsr	_Initialize_Tile_Node
	bra	.init_end
.tile_allocated_ok
	move.l	d0,tile_Location(a0)	; save location and init map table

	move.w	_Palette_Set,tile_Palette(a0)

	move.l	tile_Name(a0),a1
	lea	_DefaultName,a0
	bsr	_StrCpy
	lea	_Text_FileExt_Tile,a0
	bsr	_StrCat

	pull	a0

	moveq.l	#0,d0
	move.w	d0,tile_Edit(a0)
	move.w	d0,tile_Left(a0)
	move.w	d0,tile_Top(a0)

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
dbgu1:
_Replace_Tile_Node:
	push	a2
	lea	-tile_SIZEOF(sp),sp	
	move.l	sp,a2
	move.l	_Tile_Node,a0
	bsr	_Get_Node_Ptr
	cmp.l	#0,a0			; if (requested) {
	bne.s	.node_present
	bsr	_Add_Tile_Node
	bra	.replace_end
.node_present
;	cmp.l	#0,a0			; if (requested) {
;	beq.s	.replace_end
	push	a0
	move.l	a2,a1
	moveq.l	#tile_SIZEOF,d0
	bsr	_StrnCpy		; copy old node
	bsr	_Initialize_Tile_Node	; initialize new node

	move.w	tile_Flags(a0),d3
	btst	#FLGB_FORGETCOLS,d3
	bne.s	.end_no_cols
	move.w	tile_Palette(a0),d0
	move.w	tile_Depth(a0),d1
	move.w	tile_Flags(a0),d2
;	move.w	d3,d1
;	move.w	d5,d2

	move.w	tile_Flags(a0),d3
	btst	#FLGB_NOCOLS,d3
	bne.s	.end_no_cols
	push	a0/a2
	bsr	_Replace_Palette_Node
	pop	a0/a2
.end_no_cols
	move.w	tile_Flags(a0),d3
	btst	#FLGB_RETAIN,d3
	beq	.no_retain		; check if user wants to retain tiles
;	pull	a0	
	moveq.l	#0,d0
	move.l	d0,d1
	move.w	tile_Amount(a0),d0
	move.w	tile_Amount(a2),d1
	jsr	_Find_Greater
	move.l	d1,d7
	move.w	tile_Width(a0),d0
	move.w	tile_Width(a2),d1
	jsr	_Find_Greater
	move.l	d1,d6
	move.w	tile_Height(a0),d0
	move.w	tile_Height(a2),d1
	jsr	_Find_Greater
	move.l	d1,d5

	push	d5-d7

;
;;	do the masks first if we still want them
;
	move.w	tile_Flags(a0),d3
	btst	#FLGB_MASK,d3
	beq.s	.end_retain_masks
	nop
.end_retain_masks

;
;;	do the actual images next
;	

	push	a0/a2
	move.w	tile_Depth(a0),d0
	move.w	tile_Width(a0),d1
	move.w	tile_Height(a0),d2
	move.w	tile_Amount(a0),d3
	move.w	tile_Flags(a0),d4
	move.l	tile_Location(a0),a0
	bsr	_Calculate_From_Mask
	lea	_BitMap_To,a1
	bsr	_CreateBitMap
	pull	a0/a2
	move.l	a2,a0

	move.w	tile_Depth(a0),d0
	move.w	tile_Width(a0),d1
	move.w	tile_Height(a0),d2
	move.w	tile_Amount(a0),d3
	move.w	tile_Flags(a0),d4
	move.l	tile_Location(a0),a0
	bsr	_Calculate_From_Mask
	lea	_BitMap_From,a1
	bsr	_CreateBitMap
	
	pop	a0/a2
	pop	d5-d7
	moveq.l	#0,d0
	bra.s	.next_amount_pass
.next_amount
	push	d0-d7/a0-a2
	
	moveq.l	#0,d1
	move.w	tile_Height(a2),d1	; srce
	mulu	d0,d1

	moveq.l	#0,d3
	move.w	tile_Height(a0),d3	; dest
	mulu	d0,d3

	lea	_BitMap_From,a0
	lea	_BitMap_To,a1

;	move.l	d0,d1	; srcy
;	move.l	d0,d3	; dsty


	moveq.l	#0,d0	; srcx
	move.l	d0,d2	; dstx
	

	move.l	d6,d4	; width
	move.l	d5,d5	; height
	move.l	#$c0,d6
	move.l	#$FF,d7
	
	sub.l	a2,a2
	bsr	_BltBitMap
	pop	d0-d7/a0-a2
	addq.l	#1,d0
.next_amount_pass
	dbra	d7,.next_amount

.no_retain				; }
	move.l	a2,a0
	bsr	_DeInitialize_Tile_Node
	pop	a0
.replace_end
	lea	tile_SIZEOF(sp),sp
	pop	a2
	rts

_Remove_All_Tile_Nodes:
	move.l	_Tile_Node,a0
_Remove_All_Tile_Node:		; a0 - tile_node ptr
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

_Calculate_From_Mask:	; d0 - depth, d1 - width, d2 - height, d3 - amount, d4 - flags, a0 - Planes
	push	d0-d2

	btst	#FLGB_MASK,d4
	beq.s	.end_retain_masks
	move.w	d1,d0	; width -> tmp
	add.l	#$F,d0	; 
	asr.w	#4,d0
	add.w	d0,d0	; num bytes wide
	mulu	d2,d0	; * height
	mulu	d3,d0	; * amount
	add.l	d0,a0
.end_retain_masks
	pop	d0-d2
	rts

_CreateBitMap:	; d0 - depth, d1 - width, d2 - height, d3 - amount, a0 - planes, a1 - bm_struct
	push	d0-d2/a0-a1
	move.l	a1,a0
	bsr	_InitBitMap
	pop	d0-d2/a0-a1
	moveq.l	#0,d1
	move.w	bm_BytesPerRow(a1),d1
	mulu	bm_Rows(a1),d1
	mulu	d3,d1
	lea	bm_Planes(a1),a2
	bra.s	.next_depth_pass
.next_depth
	move.l	a0,(a2)+
	add.l	d1,a0
.next_depth_pass
	dbra	d0,.next_depth
	rts

_CreateRastPort:	; a0 - bitmap, a1 - rastport
	push	a6
	push	a0/a1
	base	Graphics
	call	InitRastPort
	pop	a0/a1
	move.l	a0,rp_BitMap(a1)
	pop	a6	
	rts

_RastPort_To:	DS.B	rp_SIZEOF
_RastPort_From:	DS.B	rp_SIZEOF
_BitMap_To:	DS.B	bm_SIZEOF
_BitMap_From:	DS.B	bm_SIZEOF

*********************************************************
* Adding AND Replacing (Palette)			*
*********************************************************
* d0 - palette node					*
* d1 - depth of palette					*
* d2 - Flags						*
*	= $0001 - rgb4(0)/rgb32(1)			*
*	= $8000 - Retain previous palette		*
*********************************************************

_Count_Palette_Nodes:
	move.l	_Palette_Node,a0
	bsr	_Count_Nodes
	rts

_Calculate_Palette_Node:
	move.w	_Palette_Set,d0
_Calc_Palette_Node:
	move.l	_Palette_Node,a0
	bsr	_Get_Node_Ptr
	rts

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

Default_Palette_Depth	EQU	4

_Initialize_Palette_Node:
;
;; The palette format is of a 24 bit store, eg each component (RGB) is 1 byte
;
	push	a0

	move.w	d1,palette_Depth(a0)	; fill node with info
	move.w	d2,palette_Flags(a0)

	move.w	d1,d0
	bsr	_Power_Of_2

	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0			; *3
	
	move.l	d0,palette_Size(a0)
	call	_AllocMem_ANY		; alloc image mem
	bne.s	.palette_allocated_ok
	push	d0-d2/a0-a6
	lea	_Text_FileType_Palette,a0
	lea	_Text_No_Mem,a1
	call	_Inform_Request
	pop	d0-d2/a0-a6
	moveq.l	#0,d0
	move.l	d0,palette_Size(a0)
	moveq.l	#Default_Palette_Depth,d1
	move.w	palette_Flags(a0),d2
	bsr	_Initialize_Palette_Node
	bra.s	.init_end
.palette_allocated_ok
	move.l	d0,palette_Location(a0)	; save location and init palette table
	pull	a0

	move.l	palette_Location(a0),a1	
	move.w	palette_Depth(a0),d0
	call	_Power_Of_2
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0			; *3
	lea	_Default_Colours,a0
	call	_Copy_Bytes
	pull	a0
	move.l	palette_Name(a0),a1
	lea	_DefaultName,a0
	bsr	_StrCpy
	lea	_Text_FileExt_Palette,a0
	bsr	_StrCat

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

dbg78:
_Replace_Palette_Node:
	push	d1/a2
	lea	-palette_SIZEOF(sp),sp	
	move.l	sp,a2
	move.l	_Palette_Node,a0
	bsr	_Get_Node_Ptr
	cmp.l	#0,a0			; if (requested) {
	bne.s	.node_present
	bsr	_Add_Palette_Node
	bra.s	.replace_end
.node_present
	
	push	a0
	move.l	a2,a1
	moveq.l	#palette_SIZEOF,d0
	bsr	_StrnCpy		; copy old node
	bsr	_Initialize_Palette_Node	; initialize new node

	btst	#FLGB_RETAIN,d2
	beq.s	.no_retain		; check if user wants to retain palette
	pull	a0
	push	a0/a2
	move.w	palette_Depth(a2),d0
	move.w	palette_Depth(a0),d1
	cmp.w	d0,d1
	bhs.s	.d1_higher
	move.w	d1,d0
.d1_higher
	move.l	palette_Location(a0),a1
	move.l	palette_Location(a2),a0	; copy from old to new
	bsr	_Power_Of_2
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0			; *3 (1 for R, G & B)
	call	_Copy_Bytes
	pop	a0/a2
.no_retain				; }
	move.l	a2,a0
	bsr	_DeInitialize_Palette_Node
	pop	a0
.replace_end
	lea	palette_SIZEOF(sp),sp
	pop	d1/a2
	rts

_Remove_All_Palette_Nodes:
	move.l	_Palette_Node,a0
_Remove_All_Palette_Node:		; a0 - palette_node ptr
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

_Count_Shape_Header_Nodes:
	move.l	_ShpHdr_Node,a0
	bsr	_Count_Nodes
	rts

_Calculate_Shape_Header_Node:
	move.w	_Shape_Set,d0
_Calc_Shape_Header_Node:
	move.l	_ShpHdr_Node,a0
	bsr	_Get_Node_Ptr
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
;	move.l	a0,_Shape_Node
	bsr	_Remove_All_Shape_Node
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
_Remove_All_Shape_Header_Node:		; a0 - shphdr_node ptr
	move.l	shphdr_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
;	push	a0
;	lea	shphdr_First(a0),a0
;	bsr	_Remove_All_Shape_Node
;	pop	a0
	move.l	shphdr_Next(a0),a1
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

_Count_Shape_Nodes:
	move.l	_Shape_Node,a0
	bsr	_Count_Nodes
	rts
	
_Calculate_Shape_Node:
	move.w	_Shape_Edit,d0
_Calc_Shape_Node:
	move.l	_Shape_Node,a0
	bsr	_Get_Node_Ptr
	rts

_Add_Shape_Node:
	bsr	_Allocate_Shape_Node
	move.l	_Shape_Node,a0
	bsr	_Calculate_Node_Ptr	; throw node on end of list
	move.l	d0,a2
	move.l	shape_Next(a1),shape_Next(a2)
	move.l	a2,shape_Next(a1)
	rts

_Remove_Shape_Node:	; d0 - node number
	move.l	_Shape_Node,a0
	bsr	_Get_Node_Ptr		; calc
	move.l	shape_Next(a0),shape_Next(a1)
	bsr	_Free_Shape_Node
	rts

_Allocate_Shape_Node:
	move.l	#shape_SIZEOF,d0
	call	_Malloc				; get mem
	move.l	d0,a0
	bsr	_Initialize_Shape_Node		; initialize struct
	move.l	a0,d0
	rts

_Free_Shape_Node:
	bsr	_DeInitialize_Shape_Node	; kill all related mem
	call	_Free				; and node
	rts

_Initialize_Shape_Node:
	push	a0

	move.w	d1,shape_Width(a0)	; fill node with info
	move.w	d2,shape_Height(a0)
	move.w	d3,shape_Total(a0)
	move.w	d4,shape_Flags(a0)
	
	btst	#FLGB_CUT,d4
	bne.s	.not_shape_cut
	moveq.l	#0,d0
	move.w	d3,d0
	add.l	d0,d0
	add.l	d3,d0		; equiv mulu #3,d0
;	mulu	#3,d0
	bra.s	.cut_ok
.not_shape_cut
	move.w	d1,d0
	mulu	d2,d0
.cut_ok
	add.l	d0,d0
	move.l	d0,shape_Size(a0)
	call	_AllocMem_ANY		; alloc shape mem
	bne.s	.shape_allocated_ok
	lea	_Text_FileType_Shape,a0
	lea	_Text_No_Mem,a1
	call	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,shape_Size(a0)
	bra	.init_end
.shape_allocated_ok
	move.l	d0,shape_Location(a0)	; save location and init shape table

	pull	a0

	moveq.l	#0,d0
	move.w	d0,shape_Count(a0)
.init_end
	pop	a0
	rts

_DeInitialize_Shape_Node:	; a0 - node_ptr
	push	a0
	move.l	shape_Location(a0),a0
	call	_Free
	pull	a0
	move.l	#0,d0
	move.w	d0,shape_Width(a0)
	move.w	d0,shape_Height(a0)
	move.w	d0,shape_HotX(a0)
	move.w	d0,shape_HotY(a0)
	move.w	d0,shape_Count(a0)
	move.w	d0,shape_Flags(a0)
	move.l	d0,shape_Location(a0)
	move.l	d0,shape_Size(a0)
	pop	a0
	rts

_Replace_Shape_Node:	; d0 - node_number
	push	a2
	lea	-shape_SIZEOF(sp),sp
	move.l	sp,a2
	move.l	_Shape_Node,a0
	bsr	_Get_Node_Ptr
	cmp.l	#0,a0			; if (requested) {
	bne.s	.node_present
	bsr	_Add_Shape_Node
	bra.s	.replace_end
.node_present
	push	a0			; shape_node srce
	move.l	#shape_SIZEOF,d0
	move.l	a2,a1			; stack ptr dest
	bsr	_StrnCpy
	pull	a0
	bsr	_Initialize_Shape_Node	; initialize new node
	move.l	a2,a0
	bsr	_DeInitialize_Shape_Node
	pop	a0
.replace_end
	lea	shape_SIZEOF(sp),sp
	pop	a2
	rts

_Remove_All_Shape_Nodes:
	move.l	_Shape_Node,a0
_Remove_All_Shape_Node:		; a0 - shape_node header
	move.l	shape_Next(a0),a0
.while
	move.l	a0,d0
	move.l	d0,a0
	beq.s	.while_end
	move.l	shape_Next(a0),a1
	bsr	_Free_Shape_Node
	move.l	a1,a0
	bra.s	.while
.while_end

	rts

_Count_Copper_Nodes:
_Calculate_Copper_Node:
_Calc_Copper_Node:
_Add_Copper_Node:
_Remove_Copper_Node:
_Allocate_Copper_Node:
_Free_Copper_Node:
_Initialize_Copper_Node:
_DeInitialize_Copper_Node:
_Replace_Copper_Node:
_Remove_All_Copper_Nodes:
	rts

_Count_Anim_Nodes:
_Calculate_Anim_Node:
_Calc_Anim_Node:
_Add_Anim_Node:
_Remove_Anim_Node:
_Allocate_Anim_Node:
_Free_Anim_Node:
_Initialize_Anim_Node:
_DeInitialize_Anim_Node:
_Replace_Anim_Node:
_Remove_All_Anim_Nodes:
	rts

_Count_Prefs_Nodes:
_Calculate_Prefs_Node:
_Calc_Prefs_Node:
	rts
 ENDC

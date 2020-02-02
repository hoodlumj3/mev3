
;
;;;
;;- De-Allocation of all memory grabbing functions eg map,tiles,shape,copper,palette etc
;;;
;

;DeAllocate_All_Map_Mem:
;	lea	_Map_Info_Header,a0
;	move.l	map_Next(a0),a1
;.while
;	move.l	a1,d0
;	move.l	d0,a0
;	beq.s	.while_end
;	move.l	map_Next(a0),a1
;	push	a0-a1
;	bsr	_DeAllocate_Map
;	move.l	#map_SIZEOF,d0
;	jsr	_Free
;	pop	a0-a1
;	bra.s	.while
;.while_end
;	rts

;;-

;DeAllocate_All_Tile_Mem:
;	lea	_Tile_Info_Header,a0
;	move.l	tile_Next(a0),a1
;.while
;	move.l	a1,d0
;	move.l	d0,a0
;	beq.s	.while_end
;	move.l	tile_Next(a0),a1
;	push	a0-a1
;	bsr	_DeAllocate_Tile
;	move.l	#tile_SIZEOF,d0
;	jsr	_Free
;	pop	a0-a1
;	bra.s	.while
;.while_end
;	rts

;;-

;DeAllocate_All_Palette_Mem:
;	lea	_Palette_Info_Header,a0
;	move.l	palette_Next(a0),a1
;.while
;	move.l	a1,d0
;	move.l	d0,a0
;	beq.s	.while_end
;	move.l	palette_Next(a0),a1
;	push	a0-a1
;	bsr	_DeAllocate_Palette
;	move.l	#palette_SIZEOF,d0
;	jsr	_Free
;	pop	a0-a1
;	bra.s	.while
;.while_end
;	rts

;DeAllocate_All_Shape_Mem:
;	moveq.l	#MAX_SHAPES-1,d7
;	lea	_Shape_Info,a0
;.next_shape
;	bsr	_DeAllocate_Shape
;	add.l	#shape_SIZEOF,a0
;	dbra	d7,.next_shape
;	rts

;    STRUCTURE	SHAPE_HEADER,0
;	APTR	shphdr_Next
;	APTR	shphdr_Name
;	APTR	shphdr_First
;	LABEL	shphdr_SIZEOF

;_Allocate_Shape_Header:	*********************************
;* d0 - node number					*
;*	=  0 to Add node to list			*
;*	=  1 to MAX_SHAPE_HEADER			*
;*	= -1 to -MAX_MAP - remove node			*
;*							*
;*********************************************************
;;	move.l	#shphdr_SIZEOF,d0
;;	call	_Malloc
;
;	push	a1-a2
;	lea	-shphdr_SIZEOF(sp),sp
;	move.l	sp,a2
;	tst.w	d0
;	beq	.shape_header_alloc_add
;	bpl.s	.shape_header_alloc_replace
;
;.shape_header_alloc_remove
;	
	rts

;_DeAllocate_Shape_Header:
;	rts

;DeAllocate_All_Shape_Mem_2:
;	lea	_Shape_Info_Header,a0
;	move.l	shphdr_Next(a0),d0	; pointer from header
;.while_shape_header
;	tst.l	d0			; is it a null
;	beq.s	.while_end		; yes, we have reached the end of the list
;	move.l	d0,a0
;	move.l	shphdr_First(a0),a1	; get the first shape node from header
;	push	a0
;.while_shape
;		move.l	a1,d0
;		move.l	shape_Next(a1),a1	; get pointer to next in list
;		move.l	d0,a0			; is it null
;		beq.s	.while_shape_end	; yes, end of shape list
;		push	a1
;		bsr	_DeAllocate_Shape	; no, then deallocate shape memory
;		move.l	#shape_SIZEOF,d0	; remove node mem
;		jsr	_Free
;		pop	a1
;		bra.s	.while_shape		; go around again
;.while_shape_end
;	pop	a0
;	move.l	shphdr_Next(a0),d0
;	bra.s	.while_shape_header
;.while_end
;	rts
;
;_Calc_Node:	; d0 - node, a0 - node header
;	push	d6-d7/a3
;	move.l	d0,d7
;	moveq.l	#0,d6
;	move.l	(a0),a3
;	bra.s	.l676
;.l674
;	cmp.l	d6,d7
;	bne.s	.l675
;	move.l	a3,d0
;	bra.s	.l677
;.l675
;	addq.l	#1,d6
;	move.l	(a3),a3
;	
;.l676
;	tst.l	(a3)
;	bne.s	.l674
;	moveq.l	#0,d0
;.l677
;	pop	d6-d7/a3
;	rts
;

;_Allocate_Shape_Header_2:	*************************
;* d0 - node number					*
;*	=  0		 - new/add node			*
;*	=  1 to  MAX_MAP - replace node			*
;*	= -1 to -MAX_MAP - remove node			*
;*********************************************************
;	push	a1-a2
;	tst.w	d0
;	beq	.shape_header_add
;	bpl.s	.shape_header_replace
;
;.shape_header_remove
;	push	d0
;	ext.l	d0
;	neg.l	d0
;	bsr	Calculate_Shape_Header_Node
;	push	a0-a1
;	bsr	_DeAllocate_Shape_Header		; kill all data
;	pop	a0-a1
;						; unlink node
;	move.l	shphdr_Next(a0),shphdr_Next(a1)	; previous->next = requested->next
;	move.l	#0,shphdr_Next(a0)		; requested->next = NULL
;	move.l	#shphdr_SIZEOF,d0
;	jsr	_Free				; free node
;	pop	d0
;	bra	.shape_header_end
;
;.shape_header_replace
;	push	d0
;	ext.l	d0
;	bsr	Calculate_Shape_Header_Node
;	pop	d0
;	cmp.l	#0,a0			; if (requested) {
;	beq.s	.shape_header_add
;	bra.s	.shape_header_end	; }
;					; else
;.shape_header_add				
;	ext.l	d0
;	bsr	Calculate_Shape_Header_Node
;	move.l	#shphdr_SIZEOF,d0
;	jsr	_Malloc				; allocate node newnode
;	move.l	d0,a0
;
;						; link to list
;	move.l	shphdr_Next(a1),shphdr_Next(a0)	; newnode->next = previous->next
;	move.l	a0,shphdr_Next(a1)		; previous->next = newnode
;
;.shape_header_end
;	pop	a1-a2
;
;	rts


;DeAllocate_All_Shape_Mem:
;	lea	_Shape_Info_Header,a0
;	move.l	shape_Next(a0),a1
;.while
;	move.l	a1,d0
;	move.l	d0,a0
;	beq.s	.while_end
;	move.l	shape_Next(a0),a1
;	push	a0-a1
;	bsr	_DeAllocate_Shape
;	move.l	#shape_SIZEOF,d0
;	jsr	_Free
;	pop	a0-a1
;	bra.s	.while
;.while_end
;	rts


;
;;;
;;- Calculation of all node bearing functions eg map,tiles,shape,copper,palette etc
;;;
;

;Calculate_Node_Number:	; d0 == number of node, a0 -> header node
;	move.l	0(a0),a1		; requested = header->next
;	moveq.l	#0,d1			; count = 0
;
;.while					; while (requested && count != d4) {
;	move.l	a1,d2
;	move.l	d2,a1
;	beq.s	.end_of_list
;	cmp.l	d0,d1
;	beq.s	.end_while
;	move.l	a1,a0			;   previous = requested
;	move.l	0(a1),a1		;   requested = requested->next
;	addq.l	#1,d1			;   count++
;	bra.s	.while
;.end_while				; }
;.end_of_list
;	move.l	d1,d0
;	rts

;Calculate_Map_Info:
;	move.w	_Map_Set,d0
;	bsr	Calculate_Map_Node
;	rts

;Calculate_Tile_Info:
;	move.w	_Tile_Set,d0
;	bsr	Calculate_Tile_Node
;	rts

;Calculate_Palette_Info:
;	move.w	_Palette_Set,d0
;	bsr	Calculate_Palette_Node
;	rts

;Calculate_Shape_Info:
;	move.w	_Shape_Set,d0
;	bsr	Calculate_Shape_Node
;	rts

;Calculate_Tile_Node:	; d0 - node number
;	push	d1-d2
;	ext.l	d0
;	subq.l	#1,d0
;	lea	_Tile_Info_Header,a0	; previous = header
;	bsr	Calculate_Node_Number
;	pop	d1-d2
;	exg.l	a0,a1
;	rts	; a0 - requested, a1 - previous

;Calculate_Map_Node:	; d0 - node number
;	push	d1-d2
;	ext.l	d0
;	subq.l	#1,d0
;	lea	_Map_Info_Header,a0	; previous = header
;	bsr	Calculate_Node_Number
;	pop	d1-d2
;	exg.l	a0,a1
;	rts	; a0 - requested, a1 - previous

;Calculate_Shape_Header_Node:	; d0 - node number
;	push	d1-d2
;	ext.l	d0
;	subq.l	#1,d0
;	lea	_Shape_Header_Info_Header,a0	; previous = header
;	bsr	Calculate_Node_Number
;	pop	d1-d2
;	exg.l	a0,a1
;	rts	; a0 - requested, a1 - previous

;Calculate_Palette_Node:	; d0 - node number
;	push	d1-d2
;	ext.l	d0
;	subq.l	#1,d0
;	lea	_Palette_Info_Header,a0	; previous = header
;
;	bsr	Calculate_Node_Number
;
;	pop	d1-d2
;	exg.l	a0,a1
;	rts	; a0 - requested, a1 - previous

;Calculate_Shape_Node:	; d0 - node number
;	push	d1-d2
;	ext.l	d0
;	subq.l	#1,d0
;	lea	_Shape_Info_Header,a0	; previous = header
;
;	bsr	Calculate_Node_Number
;
;	pop	d1-d2
;	exg.l	a0,a1
;	rts	; a0 - requested, a1 - previous

;
;;;
;;- Allocation of all memory grabbing functions eg map,tiles,shape,copper,palette etc
;;;
;

;Allocate_Map_Mem:	*********************************
;* d0 - width						*
;* d1 - height						*
;* d2 - Flags						*
;*	= $0001 - Stored				*
;*	= $8000 - Retain previous map			*
;* d3 - tile number					*
;*	=  0		 - add map node			*
;*	=  1 to  MAX_MAP - replace node			*
;*	= -1 to -MAX_MAP - remove node			*
;*********************************************************
;	push	a1-a2
;	lea	-map_SIZEOF(sp),sp
;	move.l	sp,a2
;	tst.w	d3
;	beq	.map_alloc_add
;	bpl.s	.map_alloc_replace
;
;.map_alloc_remove
;	push	d0-d3
;	move.l	d3,d0
;	ext.l	d0
;	neg.l	d0
;	bsr	Calculate_Map_Node
;	push	a0-a1
;	bsr	_DeAllocate_Map		; kill all data
;	pop	a0-a1
;						; unlink node
;	move.l	map_Next(a0),map_Next(a1)	; previous->next = requested->next
;	move.l	#0,map_Next(a0)			; requested->next = NULL
;	move.l	#map_SIZEOF,d0
;	jsr	_Free				; free node
;	pop	d0-d3
;	bra	.map_alloc_end
;
;.map_alloc_replace
;	push	d0-d3
;	move.l	d3,d0
;	ext.l	d0
;	bsr	Calculate_Map_Node
;	pop	d0-d3
;	cmp.l	#0,a0			; if (requested) {
;	beq.s	.map_alloc_add
;	push	d0-d3/a0
;	move.l	a2,a1
;	move.w	#map_SIZEOF,d0
;	bsr	_StrnCpy		; copy map_node
;;	move.l	map_Name(a0),a0		; copy name to temp buffer
;;	move.l	a2,a1
;;	bsr	_StrCpy
;;	pull	d0-d3/a0
;;	bsr	_DeAllocate_Map
;	pull	d0-d3/a0
;	move.w	d0,map_Width(a0)	; fill node with info
;	move.w	d1,map_Height(a0)
;	move.w	d2,map_Flags(a0)
;	jsr	_Allocate_Map		; allocate tile
;	pull	d0-d3/a0
;	btst	#FMTB_RETAIN,d2
;	beq.s	.map_alloc_no_retain	; check if user wants to retain map
;	push	a0	
;	move.l	map_Name(a0),a1		; from node name
;	move.l	map_Name(a2),a0		; temp name
;	bsr	_StrCpy			; copy temp buffer to name
;	pop	a0
;	move.w	#0,d0			; x source
;	move.w	#0,d1			; y source
;	move.w	map_Width(a2),d2	; w of source
;	move.w	map_Height(a2),d3	; h of source
;	move.w	map_Width(a0),d4	; w of destin
;	move.w	map_Height(a0),d5	; h of destin
;	move.l	map_Location(a0),a1	; destin
;	move.l	map_Location(a2),a0	; source
;	bsr	_Transfer_Cut
;.map_alloc_no_retain
;	move.l	a2,a0
;	bsr	_DeAllocate_Map
;
;
;	pop	d0-d3/a0
;	bra.s	.map_alloc_do_rect	; }
;					; else
;.map_alloc_add				
;	push	d0-d3
;	move.w	d3,d0
;	ext.l	d0
;	bsr	Calculate_Map_Node
;	move.l	#map_SIZEOF,d0
;	push	a1
;	jsr	_Malloc				; allocate node newnode
;	pop	a1
;	move.l	d0,a0
;	pop	d0-d3
;						; link to list
;	move.l	map_Next(a1),map_Next(a0)	; newnode->next = previous->next
;	move.l	a0,map_Next(a1)		; previous->next = newnode
;
;	move.w	d0,map_Width(a0)	; fill node with info
;	move.w	d1,map_Height(a0)
;	move.w	d2,map_Flags(a0)
;	push	a0
;	jsr	_Allocate_Map		; allocate map
;	pop	a0
;.map_alloc_do_rect
;	btst	#FMTB_RETAIN,d2
;	bne.s	.map_alloc_end
;
;	push	a0
;	clr.l	d0
;	clr.l	d1
;	clr.l	d2
;	clr.l	d3
;	move.w	#0,d0
;	move.w	#0,d1
;	move.w	map_Width(a0),d2
;	move.w	map_Height(a0),d3
;	subq.w	#1,d2
;	subq.w	#1,d3
;	lea	_Init_Write_Map_Tile,a0
;;	move.w	#0,_Rectangle_Filled
;	jsr	_Rectangle_Tile
;
;	pop	a0
;.map_alloc_end
;	lea	map_SIZEOF(sp),sp
;	pop	a1-a2
;
;	rts
;

dbg11:
Allocate_Tile_Mem:	*********************************
* d0 - tile width					*
* d1 - tile height					*
* d2 - tile depth					*
* d3 - tile amount					*
* d4 - Flags						*
*	= $0001 - Mask Required	(FMTF_MASK)		*
*	= $8000 - Retain previous tiles			*
* d5 - tile number =  0               - add tile node	*
*		   =  1 to  MAX_TILES - replace node	*
*		   = -1 to -MAX_TILES - remove node	*
*********************************************************
	tst.w	d5
	beq	.tile_alloc_add
	bpl.s	.tile_alloc_replace

.tile_alloc_remove
	push	d0-d5
	move.l	d5,d0
	ext.l	d0
	neg.l	d0
	bsr	Calculate_Tile_Node
	push	a0-a1
	bsr	_DeAllocate_Tile		; kill all data
	pop	a0-a1
						; unlink node
	move.l	tile_Next(a0),tile_Next(a1)	; previous->next = requested->next
	move.l	#0,tile_Next(a0)		; requested->next = NULL
	move.l	#tile_SIZEOF,d0
	jsr	_Free				; free node
	pop	d0-d5
	bra	.tile_alloc_end

.tile_alloc_replace
	push	d0-d5
	move.l	d5,d0
	ext.l	d0
	bsr	Calculate_Tile_Node
	pop	d0-d5
	cmp.l	#0,a0			; if (requested) {
	beq.s	.tile_alloc_add
	push	d0-d5/a0
	bsr	_DeAllocate_Tile
	pop	d0-d5/a0
	move.w	d0,tile_Width(a0)	; fill node with info
	move.w	d1,tile_Height(a0)
	move.w	d2,tile_Depth(a0)
	move.w	d3,tile_Amount(a0)
	move.w	d4,tile_Flags(a0)
	push	a0
	jsr	_Allocate_Tile		; allocate tile
	pop	a0	
	bra	.tile_alloc_end		; }
					; else
.tile_alloc_add				
	push	d0-d5
	move.w	d5,d0
	ext.l	d0
	bsr	Calculate_Tile_Node
	move.l	#tile_SIZEOF,d0
	push	a1
	jsr	_Malloc				; allocate node newnode
	pop	a1
	move.l	d0,a0
	pop	d0-d5
						; link to list
	move.l	tile_Next(a1),tile_Next(a0)	; newnode->next = previous->next
	move.l	a0,tile_Next(a1)		; previous->next = newnode

	move.w	d0,tile_Width(a0)	; fill node with info
	move.w	d1,tile_Height(a0)
	move.w	d2,tile_Depth(a0)
	move.w	d3,tile_Amount(a0)
	move.w	d4,tile_Flags(a0)
	push	a0
	jsr	_Allocate_Tile		; allocate tile
	pull	a0
	push	d0
	move.w	tile_Width(a0),d0
	add.w	#$F,d0
	asr.w	#4,d0
	add.w	d0,d0
	mulu	tile_Height(a0),d0
	mulu	tile_Amount(a0),d0
	move.w	tile_Flags(a0),d1
	move.l	tile_Location(a0),a0
	btst	#FMTB_MASK,d1
	beq.s	.no_tile_mask
	add.l	d0,a0
.no_tile_mask
	pop	d0
	pop	a0
.tile_alloc_end
	rts

Allocate_Palette_Mem:	*********************************
* d0 - depth of palette					*
* d1 - Flags						*
*	= $0001 - rgb4(0)/rgb32(1)			*
*	= $8000 - Retain previous palette		*
* d2 - node number					*
*	=  0		 - add node			*
*	=  1 to  MAX_MAP - replace node			*
*	= -1 to -MAX_MAP - remove node			*
*********************************************************
	push	a1-a2
	lea	-palette_SIZEOF(sp),sp
	move.l	sp,a2
	tst.w	d2
	beq	.palette_alloc_add
	bpl.s	.palette_alloc_replace

.palette_alloc_remove
	push	d0-d2
	move.l	d2,d0
	ext.l	d0
	neg.l	d0
	bsr	Calculate_Palette_Node
	push	a0-a1
	bsr	_DeAllocate_Palette		; kill all data
	pop	a0-a1
						; unlink node
	move.l	palette_Next(a0),palette_Next(a1)	; previous->next = requested->next
	move.l	#0,palette_Next(a0)			; requested->next = NULL
	move.l	#palette_SIZEOF,d0
	jsr	_Free				; free node
	pop	d0-d2
	bra	.palette_alloc_end

.palette_alloc_replace
	push	d0-d2
	move.l	d2,d0
	ext.l	d0
	bsr	Calculate_Palette_Node
	pop	d0-d2
	cmp.l	#0,a0			; if (requested) {
	beq.s	.palette_alloc_add
	push	d0-d2/a0
	move.l	a2,a1
	move.w	#palette_SIZEOF,d0
	bsr	_StrnCpy		; copy map_node
	pull	d0-d2/a0
	move.w	d0,palette_Depth(a0)	; fill node with info
	move.w	d1,palette_Flags(a0)
	jsr	_Allocate_Palette		; allocate tile
	pull	d0-d2/a0
	btst	#FMTB_RETAIN,d2
	beq.s	.palette_alloc_no_retain	; check if user wants to retain map
	push	a0	
	move.l	palette_Name(a0),a1	; from node name
	move.l	palette_Name(a2),a0	; temp name
	bsr	_StrCpy			; copy temp buffer to name
	pop	a0
.palette_alloc_no_retain
	move.l	a2,a0
	bsr	_DeAllocate_Palette


	pop	d0-d2/a0
	bra.s	.palette_alloc_do_rect	; }
					; else
.palette_alloc_add				
	push	d0-d2
	move.w	d2,d0			; node
	ext.l	d0
	bsr	Calculate_Palette_Node
	move.l	#palette_SIZEOF,d0
	push	a1
	jsr	_Malloc					; allocate node newnode
	pop	a1
	move.l	d0,a0
	pop	d0-d2
							; link to list
	move.l	palette_Next(a1),palette_Next(a0)	; newnode->next = previous->next
	move.l	a0,palette_Next(a1)			; previous->next = newnode

	move.w	d0,palette_Depth(a0)		; fill node with info
	move.w	d1,palette_Flags(a0)
	push	a0
	jsr	_Allocate_Palette			; allocate
	pop	a0
.palette_alloc_do_rect
	btst	#FMTB_RETAIN,d2
	bne.s	.palette_alloc_end

	push	a0
;;- set default palette
	pop	a0
.palette_alloc_end
	lea	palette_SIZEOF(sp),sp
	pop	a1-a2

	rts




;Allocate_Shape_Mem:	; d0 - size, d1 - shape number
;; d1 = 0 - gimme next avail shape if any
;; d1 = -1 to -MAX_MAPS - replace numbered shape with new info
;	
;	tst.w	d1
;	beq.s	.shape_alloc_any
;	bpl.s	.shape_alloc_end
;	ext.l	d1
;	neg.l	d1
;	cmp.l	#MAX_SHAPES,d1	; (d2 >= 1) AND (d2 <= MAX_SHAPES)
;	bhi.s	.shape_alloc_end
;	subq.w	#1,d1
;	mulu	#shape_SIZEOF,d1
;	lea	_Shape_Info,a0
;	add.l	d1,a0
;	tst.l	shape_Location(a0)	; if map present
;	beq.s	.shape_alloc_found
;	push	d0-d1			; deallocate it
;	bsr	_DeAllocate_Shape
;	pop	d0-d1
;	bra.s	.shape_alloc_found
;.shape_alloc_any
;	
;	lea	_Shape_Info,a0
;	moveq.l	#MAX_SHAPES-1,d7
;.shape_alloc_info_next
;	tst.l	shape_Location(a0)
;	beq.s	.shape_alloc_found
;	add.l	#shape_SIZEOF,a0
;	dbra	d7,.shape_alloc_info_next
;.shape_alloc_full
;	moveq.l	#0,d0
;	bra.s	.shape_alloc_end
;
;.shape_alloc_found
;	move.l	d0,shape_Size(a0)
;	jsr	_Allocate_Shape
;.shape_alloc_end
;	rts


_Allocate_Map:		; a0 - ptr to map_info with width, height initialized
	move.w	map_Width(a0),d0
	mulu	map_Height(a0),d0
	add.l	d0,d0
	move.l	d0,map_Size(a0)
	jsr	_AllocMem_ANY	; alloc map mem
	bne.s	.mem1_ok
	lea	Text_FileType_Map(pc),a0
	lea	Text_No_Mem(pc),a1
	jsr	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,map_Size(a0)
.mem1_ok
	move.l	d0,map_Location(a0)	; save location and init map table
	move.w	_Tile_Set,map_Tiles(a0)

	push	d0
	moveq.l	#32,d0
	jsr	_AllocMem_ANY		; alloc map name
	move.l	d0,map_Name(a0)
	push	a0-a1
	move.l	d0,a1
	lea	_DefaultName,a0
	jsr	_StrCpy
;	lea	Text_FileExt_Map,a0
;	jsr	_StrCat
	pop	a0-a1
	moveq.l	#0,d0
	move.w	d0,map_Left(a0)
	move.w	d0,map_Top(a0)
	move.w	d0,map_Format(a0)
	move.w	#2,map_UnitSize(a0)
	pop	d0
	rts

_DeAllocate_Map:	; a0 - ptr to map_info to deallocate
	push	a0
	move.l	map_Size(a0),d0
	move.l	map_Location(a0),a0	; kill map mem
	jsr	_Free
	pull	a0
	moveq.l	#32,d0
	move.l	map_Name(a0),a0		; kill map name
	jsr	_Free
	pop	a0

	move.l	#0,d0
	move.l	d0,map_Name(a0)
	move.w	d0,map_Width(a0)
	move.w	d0,map_Height(a0)
	move.w	d0,map_Flags(a0)
	move.l	d0,map_Location(a0)
	move.l	d0,map_Size(a0)
	move.w	d0,map_Left(a0)
	move.w	d0,map_Top(a0)
	move.b	d0,map_UnitSize(a0)
	move.b	d0,map_Format(a0)
	move.w	d0,map_Tiles(a0)
	rts


_Allocate_Tile:		; a0 - ptr to initialized tile_info
	move.w	tile_Width(a0),d0
	add.w	#$F,d0
	asr.w	#4,d0
	add.w	d0,d0	; num bytes wide
	mulu	tile_Height(a0),d0
	mulu	tile_Amount(a0),d0
	move.w	tile_Depth(a0),d1
	move.w	tile_Flags(a0),d2
	btst	#FMTB_MASK,d2
	beq.s	.tile_no_mask
	addq.w	#1,d1		; add another plane for the mask
.tile_no_mask
	mulu	d1,d0
	move.l	d0,tile_Size(a0)
	jsr	_AllocMem_CHIP	; alloc tile mem
	bne.s	.mem1_ok
	lea	Text_FileType_Tile(pc),a0
	lea	Text_No_Mem(pc),a1
	jsr	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,tile_Size(a0)
	bra	.alloc_tile_end
.mem1_ok	
	move.l	d0,tile_Location(a0)	; save location and init tile table
	move.w	_Palette_Set,tile_Palette(a0)

	push	d0

;	clr.l	d0
;	move.w	tile_Depth(a0),d0
;	jsr	_Power_Of_2
;	add.l	d0,d0
;	jsr	_AllocMem_ANY		; alloc tile colours
;	bne.s	.mem2_ok
;	lea	Text_FileType_Palette(pc),a0
;	lea	Text_No_Mem(pc),a1
;	jsr	_Inform_Request	
;	bra.s	.alloc_tile_end
;.mem2_ok
;	move.l	d0,tile_Colours(a0)
;	push	d0/a0-a1
;	move.l	d0,a1
;	clr.l	d0
;	move.w	tile_Depth(a0),d0
;	jsr	_Power_Of_2
;	add.l	d0,d0
;	lea	_Default_Colours,a0
;	jsr	_StrnCpy
;	pop	d0/a0-a1	

	moveq.l	#32,d0
	jsr	_AllocMem_ANY		; alloc tile name
	move.l	d0,tile_Name(a0)
	push	a0-a1
	move.l	d0,a1
	lea	_DefaultName,a0
	jsr	_StrCpy
;	lea	Text_FileExt_Tile,a0
;	jsr	_StrCat
	pop	a0-a1
	moveq.l	#0,d0
	move.w	d0,tile_Edit(a0)
	move.w	d0,tile_Top(a0)
	move.w	d0,tile_Left(a0)
	pop	d0
.alloc_tile_end
	rts

_DeAllocate_Tile:	; a0 - ptr to tile_info to deallocate
	push	a0
;	clr.l	d0
;	move.w	tile_Depth(a0),d0
;	jsr	_Power_Of_2
;	add.l	d0,d0
;	move.l	tile_Colours(a0),a0	; kill colours
;	jsr	_Free
;	pull	a0
	move.l	tile_Size(a0),d0
	move.l	tile_Location(a0),a0	; then tile mem
	jsr	_Free
	pull	a0
	moveq.l	#32,d0
	move.l	tile_Name(a0),a0	; kill tile name
	jsr	_Free
	pop	a0
	moveq.l	#0,d0
	move.l	d0,tile_Name(a0)
	move.w	d0,tile_Amount(a0)
	move.w	d0,tile_Width(a0)
	move.w	d0,tile_Height(a0)
	move.w	d0,tile_Depth(a0)
	move.w	d0,tile_Flags(a0)
	move.l	d0,tile_Location(a0)
	move.l	d0,tile_Size(a0)
	move.w	d0,tile_Palette(a0)
	move.w	d0,tile_Edit(a0)
	move.w	d0,tile_Top(a0)
	move.w	d0,tile_Left(a0)
	rts

_Allocate_Palette:		; a0 - ptr to palette_info with depth initialized
	move.w	palette_Depth(a0),d0
	bsr	_Power_Of_2
;	add.l	d0,d0
	btst	#FMTB_RGB32,palette_Flags(a0)
	beq.s	.not_rgb32
	mulu	#3,d0
	bra.s	.rgb_ok
.not_rgb32
	add.l	d0,d0
.rgb_ok
	move.l	d0,palette_Size(a0)
	jsr	_AllocMem_ANY	; alloc palette mem
	bne.s	.mem1_ok
	lea	Text_FileType_Palette(pc),a0
	lea	Text_No_Mem(pc),a1
	jsr	_Inform_Request
	moveq.l	#0,d0
	move.l	d0,palette_Size(a0)
.mem1_ok
	move.l	d0,palette_Location(a0)	; save location and init map table
	push	d0
	push	a0
	move.l	d0,a1
	move.w	palette_Depth(a0),d0
	jsr	_Power_Of_2
	add.l	d0,d0
	lea	_Default_Colours,a0
	jsr	_StrnCpy
	pop	a0
	moveq.l	#32,d0
	jsr	_AllocMem_ANY		; alloc map name
	move.l	d0,palette_Name(a0)
	push	a0-a1
	move.l	d0,a1
	lea	_DefaultName,a0
	jsr	_StrCpy
;	lea	Text_FileExt_Map,a0
;	jsr	_StrCat
	pop	a0-a1
	pop	d0
	rts

_DeAllocate_Palette:	; a0 - ptr to palette_info to deallocate
	push	a0
	move.l	palette_Size(a0),d0
	move.l	palette_Location(a0),a0	; kill map mem
	jsr	_Free
	pull	a0
	moveq.l	#32,d0
	move.l	palette_Name(a0),a0		; kill map name
	jsr	_Free
	pop	a0

	move.l	#0,d0
	move.l	d0,palette_Name(a0)
	move.w	d0,palette_Depth(a0)
	move.l	d0,palette_Location(a0)
	move.l	d0,palette_Size(a0)
	move.w	d0,palette_Flags(a0)
	rts




;_Allocate_Shape:		; a0 - ptr to shape_info with size initialized
;	move.l	shape_Size(a0),d0
;	jsr	_AllocMem_ANY
;	bne.s	.mem_ok
;	lea	Text_FileType_Shape(pc),a0
;	lea	Text_No_Mem(pc),a1
;	jsr	_Inform_Request
;	moveq.l	#0,d0
;	move.l	d0,shape_Size(a0)
;.mem_ok
;	move.l	d0,shape_Location(a0)	; save location and init shape table
;	move.w	_Map_Set,shape_MapSet(a0)
;	move.l	d0,a0
;	move.w	#$FFFF,(a0)
;	rts


;_DeAllocate_Shape:	; a0 - ptr to shape_info to deallocate
;	push	a0
;	move.l	shape_Size(a0),d0
;	move.l	shape_Location(a0),a0	; kill shape mem
;	jsr	_Free
;	pop	a0
;	move.l	#0,d0
;	move.l	d0,shape_Location(a0)
;	move.l	d0,shape_Size(a0)
;	move.w	d0,shape_Count(a0)
;	move.w	d0,shape_Width(a0)
;	move.w	d0,shape_Height(a0)
;	move.w	d0,shape_HotX(a0)
;	move.w	d0,shape_HotY(a0)
;	move.w	d0,shape_MapSet(a0)
;	rts

; new
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
	lea	Text_FileType_Shape(pc),a0
	lea	Text_No_Mem(pc),a1
	jsr	_Inform_Request
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
	move.l	shape_Size(a0),d0
	move.l	shape_Location(a0),a0		; kill shape mem
	jsr	_Free
	pull	a0
	moveq.l	#32,d0
	move.l	shape_Name(a0),a0		; kill shape name
	jsr	_Free
	pop	a0

	move.l	#0,d0
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
	beq	.shape_alloc_add
	bpl.s	.shape_alloc_replace

.shape_alloc_remove
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
	move.l	#shape_SIZEOF,d0
	jsr	_Free				; free node
	pop	d0-d4
	bra	.shape_alloc_end

.shape_alloc_replace
	push	d0-d4
	move.l	d4,d0
	ext.l	d0
	bsr	Calculate_Shape_Node
	pop	d0-d4
	cmp.l	#0,a0			; if (requested) {
	beq.s	.shape_alloc_add
	push	d0-d4/a0
	move.l	a2,a1
	move.w	#shape_SIZEOF,d0
	bsr	_StrnCpy		; copy map_node

	pull	d0-d4/a0
	move.w	d0,shape_Width(a0)
	move.w	d1,shape_Height(a0)
	move.w	d2,shape_Count(a0)
	move.w	d3,shape_Flags(a0)
	jsr	_Allocate_Shape		; allocate tile
	pull	d0-d4/a0

	btst	#FMTB_RETAIN,d2
	beq.s	.shape_alloc_no_retain	; check if user wants to retain shape
	push	a0
	move.l	shape_Name(a0),a1	; from node name
	move.l	shape_Name(a2),a0	; temp name
	bsr	_StrCpy			; copy temp buffer to name
	pop	a0
.shape_alloc_no_retain
	move.l	a2,a0
	bsr	_DeAllocate_Shape

	pop	d0-d4/a0
	bra.s	.shape_alloc_do_rect	; }
					; else
.shape_alloc_add				
	push	d0-d4
	move.w	d4,d0			; node
	ext.l	d0
	bsr	Calculate_Shape_Node
	move.l	#shape_SIZEOF,d0
	push	a1
	jsr	_Malloc					; allocate node newnode
	pop	a1
	move.l	d0,a0
	pop	d0-d4
							; link to list
	move.l	shape_Next(a1),shape_Next(a0)	; newnode->next = previous->next
	move.l	a0,shape_Next(a1)			; previous->next = newnode

	push	a0
	move.w	d0,shape_Width(a0)
	move.w	d1,shape_Height(a0)
	move.w	d2,shape_Count(a0)
	move.w	d3,shape_Flags(a0)
	jsr	_Allocate_Shape			; allocate
	pop	a0
.shape_alloc_do_rect
;	btst	#FMTB_RETAIN,d2
;	bne.s	.shape_alloc_end
;	push	a0
;;- set default shape
;	pop	a0
.shape_alloc_end
	lea	shape_SIZEOF(sp),sp
	pop	a1-a2

	rts


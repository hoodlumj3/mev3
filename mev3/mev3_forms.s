 IFND	MEV3_FORMS_S
MEV3_FORMS_S SET 1

  IFND	MEV3_MAIN_S
	include	"mev3_main.s"
  ENDC

*
**
*** $VER:mev3_forms.s 39.01  © (08/July/94) M.J.Edwards
**
*

ID_FORM	EQU	'FORM'
ID_BODY	EQU	'BODY'

ID_MEV3	EQU	'MEV3'
ID_PROJ	EQU	'PROJ'
ID_MAP	EQU	'MAP '
ID_TILE	EQU	'TILE'
ID_PALE	EQU	'PALE'		; just like a CMAP struct
ID_SHAP	EQU	'SHAP'
ID_SHDR	EQU	'SHDR'
ID_COPP	EQU	'COPP'
ID_ANIM	EQU	'ANIM'

ID_ILBM	EQU	'ILBM'

 EVEN

_ID_FORM	DC.L	ID_FORM
_ID_BODY	DC.L	ID_BODY

_ID_MEV3	DC.L	ID_MEV3
_ID_PROJ	DC.L	ID_PROJ
_ID_MAP		DC.L	ID_MAP 
_ID_TILE	DC.L	ID_TILE
_ID_PALE	DC.L	ID_PALE		; just like a CMAP struct
_ID_SHAP	DC.L	ID_SHAP
_ID_SHDR	DC.L	ID_SHDR
_ID_COPP	DC.L	ID_COPP
_ID_ANIM	DC.L	ID_ANIM

_ID_ILBM	DC.L	ID_ILBM

 EVEN



    STRUCTURE	Form_Project,0
	LABEL	fproject_SIZEOF

    STRUCTURE	Form_Map,0
	UWORD	fmap_Width
	UWORD	fmap_Height
	UBYTE	fmap_Flags
	UBYTE	fmap_Stored
	UWORD	fmap_Left
	UWORD	fmap_Top
	LABEL	fmap_SIZEOF

    STRUCTURE	Form_Tile,0
	UWORD	ftile_Amount
	UWORD	ftile_Width
	UWORD	ftile_Height
	UWORD	ftile_Depth
	UWORD	ftile_Flags
	LABEL	ftile_SIZEOF

    STRUCTURE	Form_Pallette,0
	UBYTE	fpalette_Depth
	UBYTE	fpalette_Flags	
	LABEL	fpalette_SIZEOF

;	UBYTE	fpallette_Red
;	UBYTE	fpallette_Green
;	UBYTE	fpallette_Blue	

    STRUCTURE	Form_ShapeHeader,0
	UWORD	fshapehdr_Amount
	UWORD	fshapehdr_Flags
	LABEL	fshapehdr_SIZEOF

    STRUCTURE	Form_Shape,0
	UWORD	fshape_Width
	UWORD	fshape_Height
	UWORD	fshape_HotX
	UWORD	fshape_HotY
	UWORD	fshape_Count
	UWORD	fshape_Flags
	LABEL	fshape_SIZEOF


    STRUCTURE	Form_Copper,0
	LABEL	fcopper_SIZEOF

    STRUCTURE	Form_Animation,0
	LABEL	fanimation_SIZEOF

	BITDEF	FORM,STOREWORD,14

;
;;;
;;
;
; TYPE SIZE  ID  FORM SIZE HEAD  BODY SIZE DATA
;-----------------------------------------
; FORM.xxxx.ILBM...BMHD.xxxx.xx.xx.BODY.xxxx.xx..	; Picture
;
; FORM.xxxx.MEV3...MAP .xxxx.xx.xx.BODY.xxxx.xx..	; Map
; FORM.xxxx.MEV3...TILE.xxxx.xx.xx.BODY.xxxx.xx..	; Tile
; FORM.xxxx.MEV3...PALE.xxxx.xx.xx.BODY.xxxx.xx..	; Palette
; FORM.xxxx.MEV3...SHAP.xxxx.xx.xx.BODY.xxxx.xx..	; Shape
; FORM.xxxx.MEV3...COPP.xxxx.xx.xx.BODY.xxxx.xx..	; Copper
; FORM.xxxx.MEV3...ANIM.xxxx.xx.xx.BODY.xxxx.xx..	; Anim
;;
;;;
;

_Free_Form_Project:
_Free_Form_Map:
_Free_Form_Tile:
_Free_Form_Palette:
_Free_Form_Shape:
_Free_Form_Copper:
_Free_Form_Anim:
*********************************************************
* d0 == form previously allocated by _Create_Form_Map	*
*********************************************************
	move.l	d0,a0
	move.l	a0,d0
	beq.s	.no_form_allocated

	call	_Free

.no_form_allocated
	rts


_Fill_In_Header_Info:	*********************************
* a0 -> palette_node					*
* a1 -> mem_for_form					*
* d0 -> size of section					*
*********************************************************
	push	a0/d0-d1
	move.l	a0,d1
	move.l	d1,a0
	beq	.no_node_present
	move.l	_ID_FORM(pc),(a1)+	; 'FORM'
	subq.l	#8,d2
	move.l	d2,(a1)+		; 'xxxx'
	move.l	_ID_MEV3(pc),(a1)+	; 'MEV3'
.no_node_present
	pop	a0/d0-d1
	rts

_Create_Form_Map:	*********************************
* a0 -> map_node					*
* a1 -> mem_for_form					*
*;							*
* d0 <- filled in form for map or NULL if no memory	*
* d1 <- size of total form				*
*********************************************************
	bsr	_SizeOf_Map_Form
	add.l	#4+4+4,d0
	push	d0
	call	_Malloc_CHIP
	move.l	d0,a1
	pop	d0
	push	d0
	push	a1
	bsr	_Fill_In_Header_Info
	bsr	_Fill_In_Form_Map
	pop	d0
	pop	d1
	rts

_SizeOf_Map_Form:	*********************************
* a0 -> map_node					*
*;							*
* d0 <- size of map form in bytes			*
*********************************************************
	push	a0-a1

	move.l	a0,d0
	move.l	d0,a0
	beq	.no_node_present
	moveq.l	#0,d0
	move.w	map_Width(a0),d0
	mulu	map_Height(a0),d0
	add.l	d0,d0
	addq.l	#1,d0
	andi.b	#$FE,d0

	add.l	#4+4+fmap_SIZEOF+4+4,d0
	
.no_node_present	
	pop	a0-a1
	rts

_Fill_In_Form_Map:	*********************************
* a0 -> map_node					*
* a1 -> mem_for_form					*
*;							*
* d0 <- filled in form for map or NULL if no memory	*
* d1 <- size of total form				*
*********************************************************
	push	a0-a3/d2
	move.l	a0,d0
	move.l	d0,a0
	beq	.no_node_present
	moveq.l	#0,d0

	move.l	a1,d0
	move.l	d0,a1
	beq	.no_mem_present
	
	bsr	_SizeOf_Map_Form
	add.l	#4+4+4,d0
	move.l	d0,d2
	
	push	a1/d2
;
;;	fill in format info for map
;
	move.l	_ID_FORM(pc),(a1)+	; 'FORM'
	subq.l	#8,d2
	move.l	d2,(a1)+		; 'xxxx'
	move.l	_ID_MEV3(pc),(a1)+	; 'MEV3'
	move.l	_ID_MAP(pc),(a1)+	; 'MAP '
	move.l	#fmap_SIZEOF,(a1)+	; 'xxxx'
	move.l	a1,a2
	lea	fmap_SIZEOF(a1),a1	; 'xx.xx'

	move.w	map_Width(a0),fmap_Width(a2)
	move.w	map_Height(a0),fmap_Height(a2)
	move.w	map_Left(a0),fmap_Left(a2)
	move.w	map_Top(a0),fmap_Top(a2)
	move.w	map_Flags(a0),d0
	move.w	d0,fmap_Flags(a2)
	move.w	#2,d0
	move.w	d0,fmap_Stored(a2)	; how data is stored as bytes or words
	
;;- right map header is finished now do the body
	
	move.l	_ID_BODY(pc),(a1)+	; 'BODY'
	move.l	map_Size(a0),d0
	move.l	d0,(a1)+		; 'xxxx'

	push	d0/a0-a1	
	moveq.l	#0,d0
	move.w	map_Width(a0),d0
	mulu	map_Height(a0),d0	
	move.l	map_Location(a0),a0
	call	_Copy_Words		; 'xx.xx'
	pop	d0/a0-a1	

	
	pop	a1/d1
	move.l	a1,d0

.no_mem_present	
.no_node_present
	pop	a0-a3/d2
	rts



_Create_Form_Palette:	*********************************
* a0 -> palette_node					*
* a1 -> mem_for_form					*
*;							*
* d0 <- filled in form for palette or NULL if no memory	*
* d1 <- size of total form				*
*********************************************************
	bsr	_SizeOf_Palette_Form
	add.l	#4+4+4,d0
	push	d0
	call	_Malloc_CHIP
	move.l	d0,a1
	pop	d0
	push	d0
	push	a1
	bsr	_Fill_In_Header_Info
	bsr	_Fill_In_Form_Palette
	pop	d0
	pop	d1
	rts

_SizeOf_Palette_Form:	*********************************
* a0 -> palette_node					*
*;							*
* d0 <- size of palette form in bytes			*
*********************************************************
	push	a0-a1

	move.l	a0,d0
	move.l	d0,a0
	beq	.no_node_present
	moveq.l	#0,d0
	move.w	palette_Depth(a0),d0
	call	_Power_Of_2
	move.l	d0,d1
	add.l	d0,d0		; *2
	add.l	d1,d0		; *3	one byte for each of R, G, B comp

	add.w	#$1,d0
	andi.b	#$FE,d0		; even of words

	add.l	#4+4+fpalette_SIZEOF+4+4,d0
	
.no_node_present	
	pop	a0-a1
	rts


_Fill_In_Form_Palette:	*********************************
* a0 -> palette_node					*
* a1 -> mem_for_form					*
*;							*
* d0 <- filled in form for palette or NULL if no memory	*
* d1 <- size of total form				*
*********************************************************
	push	a0/a2/d2
	move.l	a0,d0
	move.l	d0,a0
	beq	.no_node_present
	moveq.l	#0,d0

	move.l	a1,d0
	move.l	d0,a1
	beq	.no_mem_present
	
	bsr	_SizeOf_Palette_Form
	move.l	d0,d2
	
	push	a1/d2
;
;;	fill in format info for palette
;
;	move.l	_ID_FORM(pc),(a1)+	; 'FORM'
;	subq.l	#8,d2
;	move.l	d2,(a1)+		; 'xxxx'
;	move.l	_ID_MEV3(pc),(a1)+	; 'MEV3'
	move.l	_ID_PALE(pc),(a1)+	; 'PALE'
	move.l	#fpalette_SIZEOF,(a1)+	; 'xxxx'
	move.l	a1,a2
	lea	fpalette_SIZEOF(a1),a1	; 'xx.xx'

	move.w	palette_Depth(a0),fpalette_Depth(a2)
	move.w	palette_Flags(a0),fpalette_Flags(a2)
	
;
;;- right map header is finished now do the body & data
;
	
	move.l	_ID_BODY(pc),(a1)+	; 'BODY'
	move.l	palette_Size(a0),d0
	move.l	d0,(a1)+		; 'xxxx'

	push	d0/a0-a1	
	moveq.l	#0,d0
	move.w	palette_Depth(a0),d0
	call	_Power_Of_2
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	move.l	palette_Location(a0),a0
	call	_Copy_Bytes		; 'xx.xx'
	pop	d0/a0-a1	

	pop	a1/d1
	move.l	a1,d0

.no_mem_present	
.no_node_present
	pop	a0-a3/d2
	rts



_Create_Form_Tile:	*********************************
* a0 -> tile_node					*
* a1 -> mem_for_form					*
*;							*
* d0 <- filled in form for tile or NULL if no memory	*
* d1 <- size of total form				*
*********************************************************
	bsr	_SizeOf_Tile_Form
	add.l	#4+4+4,d0			; for header info
	push	d0
	call	_Malloc_CHIP
	move.l	d0,a1
	pop	d0
	push	d0
	push	a1
	bsr	_Fill_In_Header_Info
	bsr	_Fill_In_Form_Tile
	pop	d0
	pop	d1
	rts

_SizeOf_Tile_Form:	*********************************
* a0 -> tile_node					*
*;							*
* d0 <- size of tile form in bytes			*
*********************************************************
	push	a0-a1

	move.l	a0,d0
	move.l	d0,a0
	beq	.no_node_present

	move.w	tile_Flags(a0),d5
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.w	tile_Width(a0),d0

;	btst	#FLGB_16BIT,d5
;	beq.s	.no_16_bit
	add.w	#15,d0
	asr.w	#4,d0
	add.w	d0,d0
;	bra.s	.16_bit_ok
;.no_16_bit
;	divu	#8,d0
;	swap	d0
;	move.w	d0,d1
;	swap	d0
;	tst.w	d1
;	beq.s	.16_bit_ok
;	andi.l	#$FFFF,d0
;	addq.l	#1,d0
;.16_bit_ok
	mulu	tile_Height(a0),d0
	move.w	tile_Depth(a0),d1

	btst	#FLGB_MASK,d5
	beq.s	.no_mask
	addq.w	#1,d1
.no_mask	
	mulu	d1,d0
	mulu	tile_Amount(a0),d0
;
;; check palette is requested
;
	btst	#FLGB_NOCOLS,d5
	bne.s	.no_colours_included
	push	a0/d0
	move.w	tile_Palette(a0),d0
	move.l	_Palette_Node,a0
	jsr	_Get_Node_Ptr
	bsr	_SizeOf_Palette_Form
	move.l	d0,d1
	pop	a0/d0
	add.l	d1,d0
.no_colours_included
	addq.l	#1,d0
	andi.b	#$FE,d0

	add.l	#4+4+ftile_SIZEOF+4+4,d0
	
.no_node_present	
	pop	a0-a1
	rts

_Fill_In_Form_Tile:	*********************************
* a0 -> tile_node					*
* a1 -> mem_for_form					*
*;							*
* d0 <- filled in form for tile				*
* d1 <- size of total form				*
*********************************************************
	push	a0-a3/d2
	move.l	a0,d0
	move.l	d0,a0
	beq	.no_node_present
	moveq.l	#0,d0

	move.l	a1,d0
	move.l	d0,a1
	beq	.no_mem_present
	
	bsr	_SizeOf_Tile_Form
	move.l	d0,d2
	
	push	a1/d2
;
;;	fill in format info for palette
;
;	move.l	_ID_FORM(pc),(a1)+	; 'FORM'
;	subq.l	#8,d2
;	move.l	d2,(a1)+		; 'xxxx'
;	move.l	_ID_MEV3(pc),(a1)+	; 'MEV3'

	move.l	_ID_TILE(pc),(a1)+	; 'TILE'
	move.l	#ftile_SIZEOF,(a1)+	; 'xxxx'
	move.l	a1,a2
	lea	ftile_SIZEOF(a1),a1	; 'xx.xx'

	move.w	tile_Amount(a0),ftile_Amount(a2)
	move.w	tile_Width(a0),ftile_Width(a2)
	move.w	tile_Height(a0),ftile_Height(a2)
	move.w	tile_Depth(a0),ftile_Depth(a2)
	move.w	tile_Flags(a0),ftile_Flags(a2)

;
;;- right map header is finished now do the body & data
;


	move.l	_ID_BODY(pc),(a1)+	; 'BODY'

	move.w	tile_Flags(a0),d5
	move.w	tile_Width(a0),d0
	add.w	#15,d0
	asr.w	#4,d0
	add.w	d0,d0
	mulu	tile_Height(a0),d0

	move.w	tile_Depth(a0),d1
	btst	#FLGB_MASK,d5
	beq.s	.no_mask
	addq.w	#1,d1	
.no_mask	
	mulu	d1,d0

;
;; write size into body sizeof
;

	mulu	tile_Amount(a0),d0
	move.l	d0,(a1)+		; 'xxxx'

	push	d0/a0
	move.l	tile_Location(a0),a0
	call	_Copy_Bytes
	pop	d0/a0
;
;; skip to after tile body
;
	addq.l	#1,d0
	andi.b	#$FE,d0
	add.l	d0,a1

;
;; and decide whether or not to include the colours or not
;	

	move.w	tile_Flags(a0),d5
	btst	#FLGB_NOCOLS,d5
	bne.s	.no_colours_included	
	push	a0/d0
	move.w	tile_Palette(a0),d0
	move.l	_Palette_Node,a0
	jsr	_Get_Node_Ptr
	bsr	_SizeOf_Palette_Form
	move.l	d0,d1
	pop	a0/d0
	add.l	d1,d0
.no_colours_included	


	pop	a1/d1
	move.l	a1,d0
.no_mem_present	
.no_node_present
	pop	a0-a3/d2
	rts





 ENDC

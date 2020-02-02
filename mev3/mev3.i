	IFND	MEV3_I
MEV3_I SET 1

lo	EQUR	a4
gl	EQUR	a5
lb	EQUR	a6

    STRUCTURE MEV3Prefs,0
	ULONG	prefs_NormScrMode
	UWORD	prefs_NormScrWidth
	UWORD	prefs_NormScrHeight

	LABEL	prefs_NormSIZEOF

	ULONG	prefs_ZoomScrMode
	UWORD	prefs_ZoomScrWidth
	UWORD	prefs_ZoomScrHeight

	UWORD	prefs_TileWidth
	UWORD	prefs_TileHeight
	UWORD	prefs_TileDepth
	UWORD	prefs_TileAmount
	UWORD	prefs_TileFlags

	UWORD	prefs_MapWidth
	UWORD	prefs_MapHeight
	UWORD	prefs_MapFlags

	LABEL	prefs_SIZEOF	


    STRUCTURE REGION,0
	WORD	rg_Id
	UWORD	rg_LeftEdge
	UWORD	rg_TopEdge
	UWORD	rg_Width
	UWORD	rg_Height
	APTR	rg_Routine
	LABEL	rg_SIZEOF

    STRUCTURE	Border_Array,0
	APTR	ba_Raised
	APTR	ba_Lowered
	UWORD	ba_Width
	UWORD	ba_Height
	LABEL	ba_SIZEOF

    STRUCTURE	Image_Array,0
	APTR	ia_Image
	UWORD	ia_Width
	UWORD	ia_Height
	LABEL	ia_SIZEOF

; for all flags
	BITDEF	FLG,RETAIN,15

; tile flags
	BITDEF	FLG,STB0,0
	BITDEF	FLG,STB1,1
	BITDEF	FLG,MASK,2
	BITDEF	FLG,16BIT,3
	BITDEF	FLG,SPRITE,4
	BITDEF	FLG,NOCOLS,5
	BITDEF	FLG,WHDIFF,6
	BITDEF	FLG,FORGETCOLS,7

; palette flags
	BITDEF	FLG,RGB32,0
	BITDEF	FLG,INCLD,1



; shape flags
	BITDEF	FLG,CUT,0
	BITDEF	FLG,HOTB1,1
	BITDEF	FLG,HOTB2,2
	BITDEF	FLG,HOTB3,3
	BITDEF	FLG,USEMASK,4		; to mask out the shape on map

HOTSPOT_MASKBITS	EQU	$000E
HOTSPOT_SHIFTBITS	EQU	1
HOTSPOT_ORIGINAL	EQU	0
HOTSPOT_TOPLEFT		EQU	1
HOTSPOT_TOPRIGHT	EQU	2
HOTSPOT_BOTTOMRIGHT	EQU	3
HOTSPOT_BOTTOMLEFT	EQU	4
HOTSPOT_CENTER		EQU	5

	

    STRUCTURE	FILE_TILE,0
	UWORD	ft_Amount
	BYTE	ft_Width
	BYTE	ft_Height
	BYTE	ft_Depth
	BYTE	ft_Format
	LABEL	ft_SIZEOF

; map flags
	BITDEF	FLG,XYSTORE,0
	BITDEF	FLG,UNITB0,1
	BITDEF	FLG,UNITB1,2
	BITDEF	FLG,AUTOUNIT,8

    STRUCTURE	FILE_MAP,0
	UWORD	fm_Width
	UWORD	fm_Height
	BYTE	fm_Unit
	BYTE	fm_Format
	LABEL	fm_SIZEOF

    STRUCTURE	FILE_PALETTE,0
	UWORD	fp_NumColours
	LABEL	fp_SIZEOF

;;- Internal structures that are dynamically allocated and linked by pointers or index into linked lists

;    STRUCTURE	PROJECT,0
;	APTR	project_Next	
;	APTR	project_Name
;	LABEL	project_SIZEOF


    STRUCTURE	MAP,0
	APTR	map_Next
	APTR	map_Name
	UWORD	map_Width	; width of map in tiles
	UWORD	map_Height	; width of map in tiles
	UWORD	map_Flags
	APTR	map_Location
	LONG	map_Size
	UWORD	map_Left	; left of display map
	UWORD	map_Top		; top of display map
	UBYTE	map_UnitSize	; saved off as
	UBYTE	map_Format	; format of map row.col OR col.row order
	UWORD	map_Tiles	; tile set #
	UWORD	map_Shape	; shape set #
	UWORD	map_Copper	; copper set #
;	UBYTE	map_Changed	; -1 if map has been edited
;	UBYTE	map_KLUDGE01	; 
	LABEL	map_SIZEOF

    STRUCTURE	TILE,0
	APTR	tile_Next	;	
;	APTR	tile_Path	; usually held in project
	APTR	tile_Name	; filename
	UWORD	tile_Amount	; number in set
	UWORD	tile_Width	; width of edit tile
	UWORD	tile_Height	; height of edit tile
	UWORD	tile_Depth	; depth of whole set
	UWORD	tile_Flags	; copy from FILE_TILE
	APTR	tile_Location	; of alloced mem
	LONG	tile_Size	; of alloced mem
	UWORD	tile_Edit	; current edit tile
	UWORD	tile_Left	; for window on edit screen
	UWORD	tile_Top	;  ""
	APTR	tile_WHArray	; tile0(w.w, h.w),tile1(w.w, h.w),tile2(w....
	UWORD	tile_Palette	; the palette number
	UWORD	tile_Animations	; the anim number for this set
;	UBYTE	tile_Changed	; -1 if it has been edited
;	UBYTE	tile_KLUDGE01	; 
	LABEL	tile_SIZEOF

    STRUCTURE	PALETTE,0
 	APTR	palette_Next
 	APTR	palette_Name
 	UWORD	palette_Depth
 	UWORD	palette_Flags
 	APTR	palette_Location
 	LONG	palette_Size
;	UBYTE	palette_Changed		; -1 if map has been edited
;	UBYTE	palette_KLUDGE01	; 
 	LABEL	palette_SIZEOF

    STRUCTURE	SHAPE_HEADER,0
	APTR	shphdr_Next
	APTR	shphdr_Name
	APTR	shphdr_First
	UWORD	shphdr_Flags
	UWORD	shphdr_Edit
	LABEL	shphdr_SIZEOF
	
    STRUCTURE	SHAPE,0
	APTR	shape_Next
;	APTR	shape_Name
	UWORD	shape_Width
	UWORD	shape_Height
	UWORD	shape_HotX
	UWORD	shape_HotY
	UWORD	shape_HotOrigX
	UWORD	shape_HotOrigY
	UWORD	shape_Total
	UWORD	shape_Count
	UWORD	shape_Flags
	APTR	shape_Location
	LONG	shape_Size
	LABEL	shape_SIZEOF


    STRUCTURE	ANIMATION,0
	LABEL	animation_SIZEOF

    STRUCTURE	COPPER,0
	LABEL	copper_SIZEOF

    STRUCTURE	Project,0
	APTR	proj_Next
	APTR	proj_Name
	APTR	proj_Path
	ULONG	proj_Flags
	STRUCT	proj_Map,map_SIZEOF
	STRUCT	proj_Tile,tile_SIZEOF
	STRUCT	proj_Palette,palette_SIZEOF
	STRUCT	proj_ShpHdr,shphdr_SIZEOF
	STRUCT	proj_Copper,copper_SIZEOF
	STRUCT	proj_Animation,animation_SIZEOF
	LABEL	proj_SIZEOF


    STRUCTURE	PreDefinedValue,0
;	UWORD	pdv_x
;	UWORD	pdv_y
;	UWORD	pdv_w
;	UWORD	pdv_h
	UWORD	pdv_value	; current
	UWORD	pdv_min		; min value
	UWORD	pdv_max		; max value
	UWORD	pdv_flags1
;	APTR	pdv_title	; title to describe his pdv
	LABEL	pdv_SIZEOF 	

	ENDC

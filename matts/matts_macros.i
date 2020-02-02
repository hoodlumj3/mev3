	IFND	MATTS_MACROS_S
MATTS_MACROS_S SET	1
TRUE	EQU	1
FALSE	EQU	0
NULL	EQU	0

push		macro	; regs (d0-d1/d4/a0-a4)
		movem.l	\1,-(sp)
		endm

pop		macro	; regs (d0-d1/d4/a0-a4)
		movem.l	(sp)+,\1
		endm

pull		macro	; regs (d0-d1/d4/a0-a4)
		movem.l	(sp),\1
		endm

base		macro	; libname  (Sys,Graphics ...),base {(a5)}
		move.l	_\1Base\2,a6
		endm

call		macro	; libvector function (_LVO)
		ifd	_LVO\1
		jsr	_LVO\1(a6)
		elseif

			ifnc	'\0','.l'
				jsr	\1
			elseif
				bsr	\1
			endc

		endc
		endm


	ENDC	; MATTS_MACROS_S



IFNDEF BONUS_SYMBOL_INC
BONUS_SYMBOL_INC EQU 1

;-------------------------------------------------------------------------------

INCLUDE Structs.inc

;-------------------------------------------------------------------------------

BonusSymbol STRUCT
	mSprite Sprite <>
	mShowCounter SDWORD ?
	mTimer SDWORD ?
BonusSymbol ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

BonusSymbol_constructor PROTO
BonusSymbol_reset PROTO
BonusSymbol_setLevel PROTO
BonusSymbol_showSymbol PROTO
BonusSymbol_hideSymbol PROTO
BonusSymbol_hitTest PROTO
BonusSymbol_drawScreen PROTO

;-------------------------------------------------------------------------------

ENDIF ; BONUS_SYMBOL_INC

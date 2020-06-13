
INCLUDE Structs.inc

;-------------------------------------------------------------------------------

TOTAL_NUMBERS EQU 4

;-------------------------------------------------------------------------------

ScoreSprites STRUCT
	mSprites Sprite TOTAL_NUMBERS DUP(<>)
	mDuration SDWORD ?
	mTimer SDWORD ?
ScoreSprites ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

ScoreSprites_constructor PROTO
ScoreSprites_reset PROTO
ScoreSprites_setLocation PROTO
ScoreSprites_setValue PROTO
ScoreSprites_drawScreen PROTO

;-------------------------------------------------------------------------------

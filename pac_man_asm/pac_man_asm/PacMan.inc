
IFNDEF PAC_MAN_INC
PAC_MAN_INC EQU 1

;-------------------------------------------------------------------------------

INCLUDE Structs.inc
INCLUDE Speed.inc
INCLUDE Lives.inc
INCLUDE Level.inc
INCLUDE Score.inc
INCLUDE BonusSymbol.inc

;-------------------------------------------------------------------------------

PacMan STRUCT
	mSprite Sprite <>
	mDirection DWORD ?
	mKeys Keys <>
	mSpeed Speed <>
	mLives Lives <>
	mLevel Level <>
	mScore Score <>
	mBonusSymbol BonusSymbol <>
	mMoveCounter SDWORD ?
	mAwardedExtraGuy BOOL ?
PacMan ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

PacMan_constructor PROTO
PacMan_input PROTO
PacMan_move PROTO

PacMan_defaultPosition PROTO
PacMan_setVisible PROTO
PacMan_deadPacMan PROTO

PacMan_didEarnExtraGuy PROTO

PacMan_getPoint PROTO
PacMan_getLives PROTO
PacMan_getLevel PROTO
PacMan_getScore PROTO
PacMan_getDirection PROTO
PacMan_getBonusSymbol PROTO

;-------------------------------------------------------------------------------

ENDIF ; PAC_MAN_INC

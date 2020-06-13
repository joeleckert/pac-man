
IFNDEF GAME_INC
GAME_INC EQU 1

;-------------------------------------------------------------------------------

INCLUDE PacMan.inc
INCLUDE Ghost.inc
INCLUDE Windows.inc
INCLUDE GameMapFlash.inc
INCLUDE EnergizerFlash.inc
INCLUDE ScoreSprites.inc

;-------------------------------------------------------------------------------

TOTAL_GHOSTS EQU 4
TOTAL_BLANKS EQU 2

;-------------------------------------------------------------------------------

Game STRUCT
	mPlayer PacMan <>

	mGhosts Ghost TOTAL_GHOSTS DUP(<>)
	mBlank Sprite TOTAL_BLANKS DUP(<>)

	mEatenGhost DWORD ?

	mEnergizerFlash EnergizerFlash <>
	mGameMapFlash GameMapFlash <>
	mGameState DWORD ?
	mSoundTrack DWORD ?

	mBonusScore ScoreSprites <>
	mEnergizerScore ScoreSprites <>
	mHighScore Score <>

	mBlueTime BOOL ?
	mBlueScore SDWORD ?
	mTimer SDWORD ?
Game ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

Game_constructor PROTO
Game_processInput PROTO
Game_processDisplay PROTO

;-------------------------------------------------------------------------------

ENDIF ; GAME_INC

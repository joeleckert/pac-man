
IFNDEF GHOST_INC
GHOST_INC EQU 1

;-------------------------------------------------------------------------------

INCLUDE Structs.inc
INCLUDE Speed.inc
INCLUDE GhostMode.inc
INCLUDE GhostRelease.inc
INCLUDE GhostBlueTime.inc

;-------------------------------------------------------------------------------

TARGET_MODE_EXACT   EQU 0
TARGET_MODE_FRONT   EQU 1
TARGET_MODE_TIMID   EQU 2
TARGET_MODE_CHANGES EQU 3

;-------------------------------------------------------------------------------

Ghost STRUCT
	mSprite Sprite <>
	mAttributes WORD ?
	mMoveCounter SDWORD ?

	mDirection DWORD ?
	mTargetMode DWORD ?
	mMode GhostMode <>
	mGhostRelease GhostRelease <>
	mInterruptMode DWORD ?
	mBlueTime GhostBlueTime <>
	mSpeed Speed <>
	mScatterTarget Point <>
	mHomeTarget Point <>
	mIsFrightened BOOL ?
Ghost ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

Ghost_constructor PROTO
Ghost_defaultPosition PROTO
Ghost_move PROTO
Ghost_setVisible PROTO
Ghost_isEaten PROTO
Ghost_inGhostHouse PROTO
Ghost_ghostHouseTimer PROTO
Ghost_blueTimeStart PROTO
Ghost_blueTime PROTO
Ghost_blueTimeStop PROTO
Ghost_hitTest PROTO

;-------------------------------------------------------------------------------

ENDIF ; GHOST_INC

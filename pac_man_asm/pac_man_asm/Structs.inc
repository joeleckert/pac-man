
IFNDEF STRUCTS_INC
STRUCTS_INC EQU 1

;-------------------------------------------------------------------------------

INCLUDE Windows.inc

;-------------------------------------------------------------------------------

DIRECTION_NONE  EQU 0
DIRECTION_UP    EQU 1
DIRECTION_DOWN  EQU 2
DIRECTION_LEFT  EQU 3
DIRECTION_RIGHT EQU 4

;-------------------------------------------------------------------------------

PAC_MAN_MODE_PENDING          EQU 0
PAC_MAN_MODE_NOT_EATING       EQU 1
PAC_MAN_MODE_EATING_DOT       EQU 2
PAC_MAN_MODE_EATING_ENERGIZER EQU 3

;-------------------------------------------------------------------------------

GHOST_INTERRUPT_NONE    EQU 0
GHOST_INTERRUPT_PACING  EQU 1
GHOST_INTERRUPT_EXITING EQU 2
GHOST_INTERRUPT_EATEN   EQU 3

;-------------------------------------------------------------------------------

HIT_TEST_NONE           EQU 0
HIT_TEST_PAC_MAN_KILLED EQU 1
HIT_TEST_GHOST_KILLED   EQU 2

;-------------------------------------------------------------------------------

Keys STRUCT
	up BOOL ?
	down BOOL ?
	left BOOL ?
	right BOOL ?
	start BOOL ?
	startHeld BOOL ?
Keys ENDS

;-------------------------------------------------------------------------------

Point STRUCT
	x SDWORD ?
	y SDWORD ?
Point ENDS

;-------------------------------------------------------------------------------

Sprite STRUCT
	character WCHAR ?
	attributes WORD ?
	charPoint Point <>
	visible BOOL ?
Sprite ENDS

;-------------------------------------------------------------------------------

ENDIF ; STRUCTS_INC

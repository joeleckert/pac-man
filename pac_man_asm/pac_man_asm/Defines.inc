
IFNDEF DEFINES_INC
DEFINES_INC EQU 1

;-------------------------------------------------------------------------------

NULL EQU 0

;-------------------------------------------------------------------------------

MILLISECONDS_10 EQU 1
MILLISECONDS_70 EQU 7

MILLISECONDS_120 EQU 12
MILLISECONDS_130 EQU 13
MILLISECONDS_150 EQU 15
MILLISECONDS_170 EQU 17

MILLISECONDS_200 EQU 20
MILLISECONDS_230 EQU 23
MILLISECONDS_240 EQU 24

MILLISECONDS_300 EQU 30

;-------------------------------------------------------------------------------

SECONDS_1 EQU 100
SECONDS_2 EQU 200
SECONDS_3 EQU 300
SECONDS_4 EQU 400
SECONDS_5 EQU 500
SECONDS_6 EQU 600
SECONDS_7 EQU 700

SECONDS_20 EQU 2000

;-------------------------------------------------------------------------------

MINUTES_17 EQU 102000

;-------------------------------------------------------------------------------

MAX_TIME EQU 0FFFFFFFFh

;-------------------------------------------------------------------------------

BLACK        EQU 00h
DARK_BLUE    EQU 01h
DARK_GREEN   EQU 02h
DARK_CYAN    EQU 03h
DARK_RED     EQU 04h
DARK_MAGENTA EQU 05h
DARK_YELLOW  EQU 06h
DARK_WHITE   EQU 07h
GRAY         EQU 08h
BLUE         EQU 09h
GREEN        EQU 0Ah
CYAN         EQU 0Bh
RED          EQU 0Ch
MAGENTA      EQU 0Dh
YELLOW       EQU 0Eh
WHITE        EQU 0Fh

;-------------------------------------------------------------------------------

GHOST_BLUE   EQU DARK_CYAN
GHOST_WHITE  EQU WHITE

;-------------------------------------------------------------------------------

SPACE        EQU 0020h
DOT          EQU 2219h
ENERGIZER    EQU 002Ah
WARP_BORDER  EQU 0078h
GHOST_DOOR   EQU 2500h

PAC_MAN      EQU 263Bh
PAC_MAN_DEAD EQU 263Ch
GHOST_CHAR   EQU 263Ah
GHOST_EYES   EQU 221Eh

;-------------------------------------------------------------------------------

CHERRY       EQU 2663h
STRAWBERRY   EQU 2660h
PEACH        EQU 2666h
APPLE        EQU 2665h
GRAPE        EQU 266Ah
GALAXIAN     EQU 266Bh
BELL         EQU 03A9h
KEY          EQU 25B2h

;-------------------------------------------------------------------------------

ENDIF ; DEFINES_INC

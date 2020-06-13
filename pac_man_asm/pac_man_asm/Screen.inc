
;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

SCREEN_WIDTH  EQU 40
SCREEN_HEIGHT EQU 24
MAX_SPRITES   EQU 18

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

Screen_constructor PROTO
Screen_addSprite PROTO

Screen_getChar PROTO
Screen_getAttr PROTO

Screen_setChar PROTO
Screen_setAttr PROTO

Screen_setScreenText PROTO
Screen_clearScreenText PROTO
Screen_blitScreen PROTO

Screen_clearScreen PROTO
Screen_drawScreen PROTO

;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

SOUND_BEGINNING      EQU 0
SOUND_SIREN          EQU 1
SOUND_FLY_TO_PEN     EQU 2
SOUND_KILLED         EQU 3
SOUND_EAT_FRUIT      EQU 4
SOUND_EAT_GHOST      EQU 5
SOUND_EXTRA_GUY      EQU 6
SOUND_ENERGIZER_MODE EQU 7
SOUND_INTERMISSION   EQU 8
SOUND_PAUSE          EQU 9
SOUND_CHOMP          EQU 10

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

Sound_constructor PROTO
Sound_playSound PROTO
Sound_stopSound PROTO
Sound_stopAllSounds PROTO

;-------------------------------------------------------------------------------

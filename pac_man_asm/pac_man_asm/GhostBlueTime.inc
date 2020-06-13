
;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

BLUE_TIME_COLOR_NONE          EQU 0
BLUE_TIME_COLOR_DISPLAY_BLUE  EQU 1
BLUE_TIME_COLOR_DISPLAY_WHITE EQU 2

;-------------------------------------------------------------------------------

GhostBlueTime STRUCT
	mTimer SDWORD ?
	mTimerLimit SDWORD ?
	mColor DWORD ?
GhostBlueTime ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

GhostBlueTime_constructor PROTO
GhostBlueTime_start PROTO
GhostBlueTime_period PROTO
GhostBlueTime_cancel PROTO
GhostBlueTime_isOn PROTO

;-------------------------------------------------------------------------------

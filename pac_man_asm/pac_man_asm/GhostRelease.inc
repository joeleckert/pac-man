
;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

GhostRelease STRUCT
	mDotCounter SDWORD ?
	mDotLimit SDWORD ?
	mTimer SDWORD ?
	mTimerLimit SDWORD ?
GhostRelease ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

GhostRelease_constructor PROTO
GhostRelease_shouldReleaseGhost PROTO

;-------------------------------------------------------------------------------

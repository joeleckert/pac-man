
;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

Speed STRUCT
	mPacManNormal SDWORD ?

	mGhostNormal SDWORD ?
	mGhostTunnel SDWORD ?
	mGhostFrightened SDWORD ?
	mGhostEaten SDWORD ?
Speed ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

Speed_constructor PROTO
Speed_pacMan PROTO
Speed_ghost PROTO

;-------------------------------------------------------------------------------

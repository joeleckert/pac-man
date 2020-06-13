
INCLUDE Windows.inc

;-------------------------------------------------------------------------------

TITLE_SIZE EQU 10

;-------------------------------------------------------------------------------

Score STRUCT
	mScore SDWORD ?
	mScoreX SDWORD ?
	mScoreY SDWORD ?

	mTitle BYTE TITLE_SIZE + 1 DUP(0)
	
	mTitleX SDWORD ?
	mTitleY SDWORD ?
	mTitleAttributes WORD ?
	mFlashTitle BOOL ?
	mTimer SDWORD ?
Score ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

Score_constructor PROTO
Score_getScore PROTO
Score_reset PROTO
Score_add PROTO
Score_setHighScore PROTO
Score_setTitle PROTO
Score_shouldFlashTitle PROTO
Score_setLocation PROTO
Score_drawScreen PROTO

;-------------------------------------------------------------------------------

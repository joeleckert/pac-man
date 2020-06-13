; Include file for WinApi.asm

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

Win32_getHandle PROTO
Win32_hideCursor PROTO
Win32_writeBuffer PROTO
Win32_getEventCount PROTO
Win32_readInput PROTO
Win32_handleEvent PROTO

Win32_soundOutputOpen PROTO
Win32_soundOutputPrepare PROTO
Win32_soundOutputPlay PROTO
Win32_soundOutputStop PROTO

Win32_messageBox PROTO

InitTimer PROTO C
ResetTimer PROTO C
GetMicroseconds PROTO C

; FOR TESTING ONLY!
Win32_setCursor PROTO

;-------------------------------------------------------------------------------

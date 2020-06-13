
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE WinApi.inc
INCLUDE Game.inc
INCLUDE Screen.inc
INCLUDE Sound.inc
INCLUDE Utils.inc

;-------------------------------------------------------------------------------

TEN_MILLISECONDS EQU 10000

;-------------------------------------------------------------------------------

.data
inputHandle HANDLE 0
inputRecord INPUT_RECORD <>
inputKeys Keys <>
eventCount DWORD 0

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE main
; ______________________________________________________________________________
; Entry point for the program.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	None
;-------------------------------------------------------------------------------

main PROC

	call setup							; setup the game
	call runLoop						; run the infinite game loop

	INVOKE ExitProcess, 0				; ends the process and all its threads
main ENDP

;-------------------------------------------------------------------------------
; PROCEDURE setup
; ______________________________________________________________________________
; Initializes the core components for the game.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call setup
;-------------------------------------------------------------------------------

setup PROC

	INVOKE Sleep,						; Win32 function
		250								; time interval in milliseconds

	mov eax, STD_INPUT_HANDLE			; EAX = STD_INPUT_HANDLE
	call Win32_getHandle				; get console input handle
	mov inputHandle, eax				; save console input handle

	mov eax, OFFSET inputKeys			; EAX = pointer to keys struct
	call Utils_clearKeys				; clear all values in keys struct
	call Utils_seedRandom				; seed random number generator

	call Screen_constructor				; setup console output
	call Sound_constructor				; setup audio output

	mov eax, TRUE						; reset high score
	call Game_constructor				; setup game

	ret									; return from procedure
setup ENDP

;-------------------------------------------------------------------------------
; PROCEDURE runLoop
; ______________________________________________________________________________
; The run loop for the game.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call runLoop
;-------------------------------------------------------------------------------

runLoop PROC

	call InitTimer						; start the game timer

L1:
	call GetMicroseconds				; get the microseconds that have passed

	cmp eax, TEN_MILLISECONDS			; if (microseconds < TEN_MILLISECONDS)
	jb L1								; jump if below

	call ResetTimer						; reset the timer to 0

	mov eax, inputHandle				; EAX = handle to console input
	call Win32_getEventCount			; get the number of input events
	mov eventCount, eax					; save the event count

L2:
	cmp eventCount, 0					; while (eventCount > 0)
	jle Display							; jump if less than or equal

	mov eax, inputHandle				; EAX = handle to console input
	mov ebx, OFFSET inputRecord			; EBX = INPUT_RECORD*
	call Win32_readInput				; read console input

	mov eax, OFFSET inputRecord			; EAX = INPUT_RECORD*
	mov ebx, OFFSET inputKeys			; EBX = pointer to keys struct
	call Win32_handleEvent				; handle the console input

	cmp eax, TRUE						; was it a keyboard event?
	jne L2_Next							; jump if not equal

	mov eax, OFFSET inputKeys			; EBX = pointer to keys struct
	call Game_processInput				; process the keyboard event

L2_Next:
	dec eventCount						; eventCount--
	jmp L2								; unconditional jump

Display:
	call Game_processDisplay			; process a game frame
	call Screen_drawScreen				; render the screen
	jmp L1								; unconditional jump

	ret									; return from procedure
runLoop ENDP

;-------------------------------------------------------------------------------

END main

;-------------------------------------------------------------------------------

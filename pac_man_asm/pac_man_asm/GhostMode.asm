
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE GhostMode.inc
INCLUDE Defines.inc
INCLUDE Windows.inc

;-------------------------------------------------------------------------------

MOMENT EQU MILLISECONDS_10
SEC_05 EQU SECONDS_5
SEC_07 EQU SECONDS_7
SEC_20 EQU SECONDS_20
MIN_17 EQU MINUTES_17
FINAL  EQU MAX_TIME

INTERVALS_SIZE EQU 8

;-------------------------------------------------------------------------------

.data
returnValue DWORD 0

intervals1 DWORD SEC_07, SEC_20, SEC_07, SEC_20, SEC_05, SEC_20, SEC_05, FINAL
intervals2 DWORD SEC_07, SEC_20, SEC_07, SEC_20, SEC_05, MIN_17, MOMENT, FINAL
intervals3 DWORD SEC_05, SEC_20, SEC_05, SEC_20, SEC_05, MIN_17, MOMENT, FINAL

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE GhostMode_reset
; ______________________________________________________________________________
; Resets the ghost mode based on the current level.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Current level of game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostModeStruct
;	mov ebx, level
;	call GhostMode_reset
;-------------------------------------------------------------------------------

GhostMode_reset PROC

	cmp ebx, 5											; if (level >= 5)
	jl C1												; jump if less than

	mov [eax].GhostMode.mIntervals, OFFSET intervals3	; address of intervals3
	jmp C3												; unconditional jump

C1:
	cmp ebx, 2											; if (level >= 2)
	jl C2												; jump if less than

	mov [eax].GhostMode.mIntervals, OFFSET intervals2	; address of intervals2
	jmp C3												; unconditional jump

C2:
	mov [eax].GhostMode.mIntervals, OFFSET intervals1	; address of intervals1

C3:
	mov ebx, [eax].GhostMode.mIntervals					; get intervals pointer
	mov ebx, [ebx]										; dereference pointer

	mov [eax].GhostMode.mIndex, 0						; self->mIndex = 0
	mov [eax].GhostMode.mTimer, ebx						; setup timer
	mov [eax].GhostMode.mState, GHOST_STATE_SCATTER		; scatter ghost state

	ret													; return from procedure
GhostMode_reset ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostMode_tick
; ______________________________________________________________________________
; Tick the ghost mode timer and adjust the ghost state.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = TRUE if the ghost state changed, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET ghostModeStruct
;	call GhostMode_tick
;-------------------------------------------------------------------------------

GhostMode_tick PROC

	pushad								; save registers

	dec [eax].GhostMode.mTimer			; self->mTimer--
	cmp [eax].GhostMode.mTimer, 0		; if (self->mTimer > 0)
	jle C1								; jump if less than or equal

	mov eax, FALSE						; return FALSE
	jmp Return							; unconditional jump

C1:
	mov esi, [eax].GhostMode.mIndex		; ESI = self->mIndex
	inc esi								; ESI++

	cmp esi, INTERVALS_SIZE				; if (ESI >= INTERVALS_SIZE)
	jl C2								; jump if less than

	mov eax, FALSE						; return FALSE
	jmp Return							; unconditional jump

C2:
	mov [eax].GhostMode.mIndex, esi		; self->mIndex = ESI

	push eax							; push class struct on stack

	mov eax, esi						; EAX = self->mIndex
	mov ebx, TYPE DWORD					; EBX = sizeof(DWORD)
	mul ebx								; EAX *= EBX

	mov ebx, eax						; store result in EBX
	pop eax								; pop class struct off stack

	add ebx, [eax].GhostMode.mIntervals	; add the index to intervals pointer
	mov ebx, [ebx]						; dereference pointer
	mov [eax].GhostMode.mTimer, ebx		; set timer to next time in array

	cmp [eax].GhostMode.mState, GHOST_STATE_SCATTER	; if (state == SCATTER)
	jne C3											; jump if not equal

	mov [eax].GhostMode.mState, GHOST_STATE_CHASE	; chase ghost state
	jmp C4											; unconditional jump

C3:
	mov [eax].GhostMode.mState, GHOST_STATE_SCATTER	; scatter ghost state

C4:
	mov eax, TRUE						; return TRUE

Return:
	mov returnValue, eax				; save boolean
	popad								; restore registers

	mov eax, returnValue				; return boolean
	ret									; return from procedure
GhostMode_tick ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostMode_state
; ______________________________________________________________________________
; Returns the current Ghost State.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = Ghost State constant
;
; EXAMPLE
;	mov eax, OFFSET ghostModeStruct
;	call GhostMode_state
;-------------------------------------------------------------------------------

GhostMode_state PROC

	mov eax, [eax].GhostMode.mState		; EAX = Ghost State constant
	ret									; return from procedure
GhostMode_state ENDP

;-------------------------------------------------------------------------------

end

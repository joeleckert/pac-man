
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE GhostRelease.inc
INCLUDE Defines.inc
INCLUDE Windows.inc

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE inkyCounter
; ______________________________________________________________________________
; The dot limit for Inky.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Current level of game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostReleaseStruct
;	mov ebx, level
;	call inkyCounter
;-------------------------------------------------------------------------------

inkyCounter PROC

	cmp ebx, 1								; if (level == 1)
	jne C1									; jump if not equal

	mov [eax].GhostRelease.mDotLimit, 30	; self->mDotLimit = 30
	jmp Return								; unconditional jump

C1:
	mov [eax].GhostRelease.mDotLimit, 0		; self->mDotLimit = 0

Return:
	ret										; return from procedure
inkyCounter ENDP

;-------------------------------------------------------------------------------
; PROCEDURE clydeCounter
; ______________________________________________________________________________
; The dot limit for Clyde.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Current level of game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostReleaseStruct
;	mov ebx, level
;	call clydeCounter
;-------------------------------------------------------------------------------

clydeCounter PROC

	cmp ebx, 1								; if (level == 1)
	jne C1									; jump if not equal

	mov [eax].GhostRelease.mDotLimit, 60	; self->mDotLimit = 60
	jmp Return								; unconditional jump

C1:
	cmp ebx, 2								; if (level == 2)
	jne C2									; jump if not equal

	mov [eax].GhostRelease.mDotLimit, 50	; self->mDotLimit = 50
	jmp Return								; unconditional jump

C2:
	mov [eax].GhostRelease.mDotLimit, 0		; self->mDotLimit = 0

Return:
	ret										; return from procedure
clydeCounter ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostRelease_constructor
; ______________________________________________________________________________
; Initializes the Ghost Release class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Ghost attributes
;	ECX = Current level of game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostReleaseStruct
;	mov ebx, attributes
;	mov ecx, level
;	call GhostRelease_constructor
;-------------------------------------------------------------------------------

GhostRelease_constructor PROC

	xchg ebx, ecx								; EBX = level / ECX = attributes

	cmp ebx, 5									; if (level >= 5)
	jl C1										; jump if less than

	mov [eax].GhostRelease.mTimerLimit, 300		; self->mTimerLimit = 300
	jmp C2										; unconditional jump

C1:
	mov [eax].GhostRelease.mTimerLimit, 400		; self->mTimerLimit = 400

C2:
	cmp ecx, CYAN								; case CYAN:
	je S1										; jump if equal

	cmp ecx, YELLOW								; case YELLOW:
	je S2										; jump if equal

	jmp S3										; default: unconditional jump

S1:
	call inkyCounter							; set Inky dot limit
	jmp Done									; unconditional jump

S2:
	call clydeCounter							; set Clyde dot limit
	jmp Done									; unconditional jump

S3:
	mov [eax].GhostRelease.mDotLimit, 0			; self->mDotLimit = 0

Done:
	mov [eax].GhostRelease.mDotCounter, 0		; self->mDotCounter = 0
	mov [eax].GhostRelease.mTimer, 0			; self->mTimer = 0
	ret											; return from procedure
GhostRelease_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostRelease_shouldReleaseGhost
; ______________________________________________________________________________
; Determines whether a ghost should be released from the ghost house or not.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Boolean if Pac-Man ate a dot
;
; RETURNS
;	EAX = TRUE if should release the ghost, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET ghostReleaseStruct
;	mov ebx, ateDot
;	call GhostRelease_shouldReleaseGhost
;-------------------------------------------------------------------------------

GhostRelease_shouldReleaseGhost PROC

	cmp ebx, TRUE								; if (ateDot == TRUE)
	jne C1										; jump if not equal

	inc [eax].GhostRelease.mDotCounter			; self->mDotCounter++
	mov [eax].GhostRelease.mTimer, 0			; self->mTimer = 0
	jmp C2										; unconditional jump

C1:
	inc [eax].GhostRelease.mTimer				; self->mTimer++

C2:
	mov ecx, [eax].GhostRelease.mDotLimit		; ECX = dotLimit
	cmp [eax].GhostRelease.mDotCounter, ecx		; if (dotCounter >= dotLimit)
	jl C3										; jump if less than

	mov eax, TRUE								; return TRUE
	jmp Return									; unconditional jump

C3:
	mov ecx, [eax].GhostRelease.mTimerLimit		; ECX = timerLimit
	cmp [eax].GhostRelease.mTimer, ecx			; if (timer >= timerLimit)
	jl C4										; jump if less than

	mov [eax].GhostRelease.mTimer, 0			; self->mTimer = 0
	mov eax, TRUE								; return TRUE
	jmp Return									; unconditional jump

C4:
	mov eax, FALSE								; return FALSE

Return:
	ret											; return from procedure
GhostRelease_shouldReleaseGhost ENDP

;-------------------------------------------------------------------------------

end

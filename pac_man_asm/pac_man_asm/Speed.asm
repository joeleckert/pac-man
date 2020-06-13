
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Speed.inc
INCLUDE Defines.inc
INCLUDE Structs.inc
INCLUDE Windows.inc

;-------------------------------------------------------------------------------

SPEED_40  EQU MILLISECONDS_300
SPEED_50  EQU MILLISECONDS_240
SPEED_60  EQU MILLISECONDS_200

SPEED_70  EQU MILLISECONDS_170
SPEED_80  EQU MILLISECONDS_150
SPEED_90  EQU MILLISECONDS_130
SPEED_100 EQU MILLISECONDS_120

SPEED_ULTRA EQU MILLISECONDS_70

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE setupPacMan
; ______________________________________________________________________________
; Initializes the speed of Pac-Man for the various levels.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The current level of the game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET speedStruct
;	mov ebx, level
;	call setupPacMan
;-------------------------------------------------------------------------------

setupPacMan PROC

	cmp ebx, 21									; if (level >= 21)
	jl L1										; jump if less than

	mov [eax].Speed.mPacManNormal, SPEED_90		; speed for level 21 and up
	jmp Return									; unconditional jump

L1:
	cmp ebx, 5									; else if (level >= 5)
	jl L2										; jump if less than

	mov [eax].Speed.mPacManNormal, SPEED_100	; speed for level 5 and up
	jmp Return									; unconditional jump

L2:
	cmp ebx, 2									; else if (level >= 2)
	jl L3										; jump if less than

	mov [eax].Speed.mPacManNormal, SPEED_90		; speed for level 2 and up
	jmp Return									; unconditional jump

L3:
	mov [eax].Speed.mPacManNormal, SPEED_80		; default speed

Return:
	ret											; return from procedure
setupPacMan ENDP

;-------------------------------------------------------------------------------
; PROCEDURE setupGhost
; ______________________________________________________________________________
; Initializes the speed of the ghosts for the various levels.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The current level of the game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET speedStruct
;	mov ebx, level
;	call setupGhost
;-------------------------------------------------------------------------------

setupGhost PROC

	cmp ebx, 21									; if (level >= 21)
	jl L1										; jump if less than

	mov [eax].Speed.mGhostNormal, SPEED_90		; normal speed
	mov [eax].Speed.mGhostTunnel, SPEED_50		; tunnel speed
	mov [eax].Speed.mGhostFrightened, SPEED_60	; frightened speed
	jmp Return									; unconditional jump

L1:
	cmp ebx, 5									; else if (level >= 5)
	jl L2										; jump if less than

	mov [eax].Speed.mGhostNormal, SPEED_90		; normal speed
	mov [eax].Speed.mGhostTunnel, SPEED_50		; tunnel speed
	mov [eax].Speed.mGhostFrightened, SPEED_60	; frightened speed
	jmp Return									; unconditional jump

L2:
	cmp ebx, 2									; else if (level >= 2)
	jl L3										; jump if less than

	mov [eax].Speed.mGhostNormal, SPEED_80		; normal speed
	mov [eax].Speed.mGhostTunnel, SPEED_40		; tunnel speed
	mov [eax].Speed.mGhostFrightened, SPEED_50	; frightened speed
	jmp Return									; unconditional jump

L3:
	mov [eax].Speed.mGhostNormal, SPEED_70		; default normal speed
	mov [eax].Speed.mGhostTunnel, SPEED_40		; default tunnel speed
	mov [eax].Speed.mGhostFrightened, SPEED_50	; default frightened speed

Return:
	mov [eax].Speed.mGhostEaten, SPEED_ULTRA	; ghost eaten speed
	ret											; return from procedure
setupGhost ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Speed_constructor
; ______________________________________________________________________________
; Initializes the Speed class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The current level of the game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET speedStruct
;	mov ebx, level
;	call Speed_constructor
;-------------------------------------------------------------------------------

Speed_constructor PROC

	call setupPacMan					; setup Pac-Man speeds
	call setupGhost						; setup ghost speeds
	ret									; return from procedure
Speed_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Speed_pacMan
; ______________________________________________________________________________
; Returns the speed for Pac-Man based on blue time.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Boolean with state of blue time, TRUE if on, FALSE otherwise
;
; RETURNS
;	EAX = Speed for Pac-Man
;
; EXAMPLE
;	mov eax, OFFSET speedStruct
;	mov ebx, blueTime
;	call Speed_pacMan
;-------------------------------------------------------------------------------

Speed_pacMan PROC

	cmp ebx, TRUE						; if (blueTime == TRUE)
	jne L1								; jump if not equal

	mov eax, SPEED_100					; return top speed
	jmp Return							; unconditional jump

L1:
	mov eax, [eax].Speed.mPacManNormal	; return normal speed

Return:
	ret									; return from procedure
Speed_pacMan ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Speed_ghost
; ______________________________________________________________________________
; Returns the speed for the ghosts based on location, interrupt mode, and if the
; ghost is frightened.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to a point struct that holds position of ghost
;	ECX = GhostInterrupt mode
;	EDX = Boolean value, TRUE if Frightened, FALSE otherwise
;
; RETURNS
;	EAX = Speed for ghost
;
; EXAMPLE
;	mov eax, OFFSET speedStruct
;	mov ebx, OFFSET point
;	mov ecx, interruptMode
;	mov edx, isFrightened
;	call Speed_ghost
;-------------------------------------------------------------------------------

Speed_ghost PROC

	cmp ecx, GHOST_INTERRUPT_EATEN			; if (mode == GhostInterrupt::EATEN)
	jne PointYIf							; jump if not equal

	mov eax, [eax].Speed.mGhostEaten		; return self->mGhostEaten
	jmp Return								; unconditional jump

PointYIf:
	cmp [ebx].Point.y, 9					; if (point.y == 9
	je PointXIfAnd							; jump if equal

	cmp [ebx].Point.y, 11					; || point.y == 11)
	jne ElseFrightened						; jump if not equal

PointXIfAnd:
	cmp [ebx].Point.x, 0					; (point.x >= 0
	jl DefaultSpeed							; jump if less than

	cmp [ebx].Point.x, 5					; && point.x <= 5)
	jg PointXIfOr							; jump if greater than

	jmp PointPassed							; unconditional jump

PointXIfOr:
	cmp [ebx].Point.x, 22					; (point.x >= 22)
	jl DefaultSpeed							; jump if less than

PointPassed:
	mov eax, [eax].Speed.mGhostTunnel		; return self->mGhostTunnel
	jmp Return								; unconditional jump

ElseFrightened:
	cmp edx, TRUE							; else if (isFrightened)
	jne DefaultSpeed						; jump if not equal

	mov eax, [eax].Speed.mGhostFrightened	; return self->mGhostFrightened
	jmp Return								; unconditional jump

DefaultSpeed:
	mov eax, [eax].Speed.mGhostNormal		; return self->mGhostNormal

Return:
	ret										; return from procedure
Speed_ghost ENDP

;-------------------------------------------------------------------------------

end

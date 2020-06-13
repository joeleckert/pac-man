
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Defines.inc
INCLUDE Structs.inc
INCLUDE Windows.inc

;-------------------------------------------------------------------------------

.data
randomSeed DWORD 428
time SYSTEMTIME <>

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Utils_digitToChar
; ______________________________________________________________________________
; Converts an integer to its character value.
;
; PARAMETERS
;	EAX = Integer to convert
;
; RETURNS
;	EAX = The character value of the integer
;
; EXAMPLE
;	mov eax, 7
;	call Utils_digitToChar
;-------------------------------------------------------------------------------

Utils_digitToChar PROC

	cmp eax, 0							; if (EAX < 0)
	jl L1								; jump if less than (signed)

	cmp eax, 9							; if (EAX > 9)
	jg L1								; jump if greater than (signed)

	add eax, "0"						; add the integer to ASCII '0'
	jmp L2								; unconditional jump

L1:
	mov eax, "?"						; if integer is not 0-9 then return '?'

L2:
	ret									; return from procedure
Utils_digitToChar ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_bonusSymbolForLevel
; ______________________________________________________________________________
; Returns the symbol for the level.
;
; PARAMETERS
;	EAX = Level integer value
;
; RETURNS
;	EAX = The symbol for the level
;
; EXAMPLE
;	mov eax, level
;	call Utils_bonusSymbolForLevel
;-------------------------------------------------------------------------------

Utils_bonusSymbolForLevel PROC

	cmp eax, 1							; case 1:
	je L1								; jump if equal

	cmp eax, 2							; case 2:
	je L2								; jump if equal

	cmp eax, 3							; case 3:
	je L3_4								; jump if equal

	cmp eax, 4							; case 4:
	je L3_4								; jump if equal

	cmp eax, 5							; case 5:
	je L5_6								; jump if equal

	cmp eax, 6							; case 6:
	je L5_6								; jump if equal

	cmp eax, 7							; case 7:
	je L7_8								; jump if equal

	cmp eax, 8							; case 8:
	je L7_8								; jump if equal

	cmp eax, 9							; case 9:
	je L9_10							; jump if equal

	cmp eax, 10							; case 10:
	je L9_10							; jump if equal

	cmp eax, 11							; case 11:
	je L11_12							; jump if equal

	cmp eax, 12							; case 12:
	je L11_12							; jump if equal

	jmp Default							; default: unconditional jump

L1:
	mov eax, CHERRY						; EAX = bonus symbol level 1
	jmp Return							; unconditional jump to Return

L2:
	mov eax, STRAWBERRY					; EAX = bonus symbol level 2
	jmp Return							; unconditional jump to Return

L3_4:
	mov eax, PEACH						; EAX = bonus symbol level 3/4
	jmp Return							; unconditional jump to Return

L5_6:
	mov eax, APPLE						; EAX = bonus symbol level 5/6
	jmp Return							; unconditional jump to Return

L7_8:
	mov eax, GRAPE						; EAX = bonus symbol level 7/8
	jmp Return							; unconditional jump to Return

L9_10:
	mov eax, GALAXIAN					; EAX = bonus symbol level 9/10
	jmp Return							; unconditional jump to Return

L11_12:
	mov eax, BELL						; EAX = bonus symbol level 11/12
	jmp Return							; unconditional jump to Return

Default:
	mov eax, KEY						; EAX = bonus symbol level 13+

Return:
	ret									; return from procedure
Utils_bonusSymbolForLevel ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_seedRandom
; ______________________________________________________________________________
; Seeds the random number generator with the current time.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Utils_seedRandom
;-------------------------------------------------------------------------------

Utils_seedRandom PROC

	pushad								; Save registers

	INVOKE GetSystemTime,				; Win32 function
		OFFSET time						; SYSTEMTIME*

	movzx eax, time.wMilliseconds		; use milliseconds as the new seed
	mov randomSeed, eax					; save into randomSeed variable

	popad								; Restore registers
	ret									; return from procedure
Utils_seedRandom ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_random
; ______________________________________________________________________________
; Generates an unsigned pseudo-random 32-bit integer.
;
; PARAMETERS
;	None
;
; RETURNS
;	EAX = The random integer
;
; EXAMPLE
;	call Utils_random
;-------------------------------------------------------------------------------

Utils_random PROC

	push edx							; save EDX because of imul instruction

	mov eax, 343FDh						; EAX = 214013
	imul randomSeed						; multiply the EAX with the randomSeed
	add eax, 269EC3h					; EAX += 2531011

	mov randomSeed, eax					; save into randomSeed for the next call
	ror eax, 8							; rotate out the lowest digit

	pop edx								; restore EDX
	ret									; return from procedure
Utils_random ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_randomValue
; ______________________________________________________________________________
; Returns an unsigned pseudo-random 32-bit integer in EAX, between 0 and
; limit - 1.
;
; PARAMETERS
;	EAX = The limit of the range 
;
; RETURNS
;	EAX = The random integer
;
; EXAMPLE
;	mov eax, limit
;	call Utils_randomValue
;-------------------------------------------------------------------------------

Utils_randomValue PROC

	push ebx							; push EBX on the stack
	push edx							; push EDX on the stack

	mov ebx, eax						; save limit into EBX
	call Utils_random					; EAX = random number

	mov edx, 0							; clear EDX for division
	div ebx								; divide by limit
	mov eax, edx						; return remainder in EAX

	pop edx								; pop EDX off the stack
	pop ebx								; pop EBX off the stack

	ret									; return from procedure
Utils_randomValue ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_copyPoint
; ______________________________________________________________________________
; Makes a copy of a Point struct.
;
; PARAMETERS
;	EAX = Pointer to destination point
;	EBX = Pointer to source point
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pointA
;	mov ebx, OFFSET pointB
;	call Utils_copyPoint
;-------------------------------------------------------------------------------

Utils_copyPoint PROC

	mov edx, [ebx].Point.x				; EDX = source.x
	mov [eax].Point.x, edx				; destination.x = EDX

	mov edx, [ebx].Point.y				; EDX = source.y
	mov [eax].Point.y, edx				; destination.y = EDX

	ret									; return from procedure
Utils_copyPoint ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_pointsEqual
; ______________________________________________________________________________
; Checks if two point structs are equal.
;
; PARAMETERS
;	EAX = Pointer to first point
;	EBX = Pointer to second point
;
; RETURNS
;	EAX = TRUE if equal, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET pointA
;	mov ebx, OFFSET pointB
;	call Utils_pointsEqual
;-------------------------------------------------------------------------------

Utils_pointsEqual PROC

	mov edx, [eax].Point.x				; EDX = point1.x
	cmp edx, [ebx].Point.x				; if (point1.x == point2.x)
	jne L1								; jump if not equal

	mov edx, [eax].Point.y				; EDX = point1.y
	cmp edx, [ebx].Point.y				; if (point1.y == point2.y)
	jne L1								; jump if not equal

	mov eax, TRUE						; return TRUE
	jmp Return							; unconditional jump to Return

L1:
	mov eax, FALSE						; return FALSE

Return:
	ret									; return from procedure
Utils_pointsEqual ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_clearKeys
; ______________________________________________________________________________
; Sets all the fields in the struct to FALSE.
;
; PARAMETERS
;	EAX = Pointer to a Keys struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET inputKeys
;	call Utils_clearKeys
;-------------------------------------------------------------------------------

Utils_clearKeys PROC

	mov [eax].Keys.up, FALSE			; keys->up = false;
	mov [eax].Keys.down, FALSE			; keys->down = false;
	mov [eax].Keys.left, FALSE			; keys->left = false;
	mov [eax].Keys.right, FALSE			; keys->right = false;
	mov [eax].Keys.start, FALSE			; keys->start = false;
	mov [eax].Keys.startHeld, FALSE		; keys->startHeld = false;

	ret									; return from procedure
Utils_clearKeys ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Utils_reverseDirection
; ______________________________________________________________________________
; Takes in a direction and returns the reverse direction.
;
; PARAMETERS
;	EAX = Direction constant
;
; RETURNS
;	EAX = Reverse direction constant
;
; EXAMPLE
;	mov eax, direction
;	call Utils_reverseDirection
;-------------------------------------------------------------------------------

Utils_reverseDirection PROC

	cmp eax, DIRECTION_UP				; case DIRECTION_UP:
	je L1								; jump if equal

	cmp eax, DIRECTION_DOWN				; case DIRECTION_DOWN:
	je L2								; jump if equal

	cmp eax, DIRECTION_LEFT				; case DIRECTION_LEFT:
	je L3								; jump if equal

	cmp eax, DIRECTION_RIGHT			; case DIRECTION_RIGHT:
	je L4								; jump if equal

	jmp Return							; default: unconditional jump

L1:
	mov eax, DIRECTION_DOWN				; EAX = DIRECTION_DOWN
	jmp Return							; unconditional jump to Return

L2:
	mov eax, DIRECTION_UP				; EAX = DIRECTION_UP
	jmp Return							; unconditional jump to Return

L3:
	mov eax, DIRECTION_RIGHT			; EAX = DIRECTION_RIGHT
	jmp Return							; unconditional jump to Return

L4:
	mov eax, DIRECTION_LEFT				; EAX = DIRECTION_LEFT

Return:
	ret									; return from procedure
Utils_reverseDirection ENDP

;-------------------------------------------------------------------------------

end

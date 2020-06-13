
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Structs.inc
INCLUDE GameMap.inc
INCLUDE Utils.inc
INCLUDE Screen.inc

;-------------------------------------------------------------------------------

.data
pointCopy Point <>

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Position_validPosition
; ______________________________________________________________________________
; Checks to see if the point is a valid position on the game map.
;
; PARAMETERS
;	EAX = Contains a pointer to a Point struct.
;
; RETURNS
;	EAX = Returns a boolean. TRUE if valid position, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET myPoint
;	call Position_validPosition
;-------------------------------------------------------------------------------

Position_validPosition PROC

	cmp [eax].Point.x, 0				; if (point.x < 0
	jl Invalid							; jump if less than

	cmp [eax].Point.x, GAME_MAP_WIDTH	; || point.x >= GAME_MAP_WIDTH)
	jge Invalid							; jump if greater than or equal

	cmp [eax].Point.y, 0				; else if (point.y < 0
	jl Invalid							; jump if less than

	cmp [eax].Point.y, GAME_MAP_HEIGHT	; || point.y >= GAME_MAP_HEIGHT)
	jge Invalid							; jump if greater than or equal

	mov eax, TRUE						; return TRUE
	jmp Return							; unconditional jump

Invalid:
	mov eax, FALSE						; return FALSE
	
Return:
	ret									; return from procedure
Position_validPosition ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Position_movePoint
; ______________________________________________________________________________
; Moves a point on the game map in the direction specified by the Direction
; constant.
;
; PARAMETERS
;	EAX = Contains a pointer to a Point struct.
;	EBX = Direction constant
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET myPoint
;	mov ebx, direction
;	call Position_movePoint
;-------------------------------------------------------------------------------

Position_movePoint PROC

	cmp ebx, DIRECTION_UP				; case DIRECTION_UP:
	je Up								; jump if equal

	cmp ebx, DIRECTION_DOWN				; case DIRECTION_DOWN:
	je Down								; jump if equal

	cmp ebx, DIRECTION_LEFT				; case DIRECTION_LEFT:
	je Left								; jump if equal
	
	cmp ebx, DIRECTION_RIGHT			; case DIRECTION_RIGHT:
	je Right							; jump if equal

	jmp Default							; default: unconditional jump

Up:
	dec [eax].Point.y					; point->y--
	jmp LeftWarpEnter					; unconditional jump

Down:
	inc [eax].Point.y					; point->y++
	jmp LeftWarpEnter					; unconditional jump

Left:
	dec [eax].Point.x					; point->x--
	jmp LeftWarpEnter					; unconditional jump

Right:
	inc [eax].Point.x					; point->x++
	jmp LeftWarpEnter					; unconditional jump

Default:
	mov [eax].Point.x, -1				; Set invalid x-position
	mov [eax].Point.y, -1				; Set invalid y-position

LeftWarpEnter:
	cmp [eax].Point.x, -1				; if (point->x == -1
	jne LeftWarpExit					; jump if not equal

	cmp [eax].Point.y, 11				; && point->y == 11)
	jne LeftWarpExit					; jump if not equal

	mov [eax].Point.x, 3				; Left Warp Enter: x-position
	mov [eax].Point.y, 9				; Left Warp Enter: y-position
	jmp Return							; unconditional jump

LeftWarpExit:
	cmp [eax].Point.x, 1				; if (point->x == 1
	jne RightWarpEnter					; jump if not equal

	cmp [eax].Point.y, 9				; && point->y == 9)
	jne RightWarpEnter					; jump if not equal

	mov [eax].Point.x, 27				; Left Warp Exit: x-position
	mov [eax].Point.y, 11				; Left Warp Exit: y-position
	jmp Return							; unconditional jump

RightWarpEnter:
	cmp [eax].Point.x, 28				; if (point->x == 28
	jne RightWarpExit					; jump if not equal

	cmp [eax].Point.y, 11				; && point->y == 11)
	jne RightWarpExit					; jump if not equal

	mov [eax].Point.x, 2				; Right Warp Enter: x-position
	mov [eax].Point.y, 9				; Right Warp Enter: y-position
	jmp Return							; unconditional jump

RightWarpExit:
	cmp [eax].Point.x, 4				; if (point->x == 4
	jne Return							; jump if not equal

	cmp [eax].Point.y, 9				; && point->y == 9)
	jne Return							; jump if not equal

	mov [eax].Point.x, 0				; Right Warp Exit: x-position
	mov [eax].Point.y, 11				; Right Warp Exit: y-position

Return:
	ret									; return from procedure
Position_movePoint ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Position_validMove
; ______________________________________________________________________________
; Checks to see if the move is valid in the direction specified by the Direction
; constant.
;
; PARAMETERS
;	EAX = Contains a pointer to a Point struct.
;	EBX = Direction constant
;	ECX = Contains a pointer the allowed character array
;
; RETURNS
;	EAX = Returns a boolean. TRUE if valid move, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET myPoint
;	mov ebx, direction
;	mov ecx, OFFSET defaultSpots
;	call Position_validMove
;-------------------------------------------------------------------------------

Position_validMove PROC

	push ebx							; save Direction constant on stack

	mov ebx, eax						; EBX = pointer to source point
	mov eax, OFFSET pointCopy			; EAX = pointer to destination point
	call Utils_copyPoint				; Copy point into pointCopy variable

	pop ebx								; restore Direction constant off stack
	call Position_movePoint				; move the pointCopy
	call Position_validPosition			; check if move is valid

	cmp eax, TRUE						; if (validPosition(pointCopy) == TRUE)
	jne Return							; jump if not equal
	
	mov eax, pointCopy.x				; EAX = x-position of character
	mov ebx, pointCopy.y				; EBX = y-position of character
	call Screen_getChar					; get character from screen buffer

	mov ebx, ecx						; EBX = pointer to allowed array
	call Position_validChar				; check if moving to a valid character
	
Return:
	ret									; return from procedure
Position_validMove ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Position_validChar
; ______________________________________________________________________________
; Checks to see if the character is in the allowed character array.
;
; PARAMETERS
;	AX = The character to check
;	EBX = Contains a pointer the allowed character array
;
; RETURNS
;	EAX = Returns a boolean. TRUE if in array, FALSE otherwise
;
; EXAMPLE
;	mov ax, character
;	mov ebx, OFFSET defaultSpots
;	call Position_validChar
;-------------------------------------------------------------------------------

Position_validChar PROC

L1:
	mov cx, [ebx]						; CX = *allowed
	cmp cx, NULL						; while (CX != NULL)
	je Invalid							; jump if equal

	cmp cx, ax							; if (CX == character)
	jne Next							; jump if not equal

	mov eax, TRUE						; return TRUE
	jmp Return							; unconditional jump

Next:
	add bx, TYPE WORD					; allowed++
	jmp L1								; unconditional jump

Invalid:
	mov eax, FALSE						; return FALSE

Return:
	ret									; return from procedure
Position_validChar ENDP

;-------------------------------------------------------------------------------

end

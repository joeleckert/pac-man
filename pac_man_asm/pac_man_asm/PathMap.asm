
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE PathMap.inc
INCLUDE Structs.inc
INCLUDE Defines.inc
INCLUDE GameMap.inc
INCLUDE Position.inc
INCLUDE Screen.inc
INCLUDE Utils.inc

;-------------------------------------------------------------------------------

.data
positionWidth DWORD 0
distance SWORD 0
mapPoint Point <>

mapPtr DWORD 0
pointPtr DWORD 0

currBegPtr DWORD 0
currEndPtr DWORD 0

nextBegPtr DWORD 0
nextEndPtr DWORD 0

currentPositions Point PATH_MAP_SIZE DUP(<>)
nextPositions Point PATH_MAP_SIZE DUP(<>)

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE arrayPosition
; ______________________________________________________________________________
; Converts a valid point to a buffer index offset for the entire screen.
; (Note: make sure to set the variable -- positionWidth -- before call)
;
; PARAMETERS
;	EAX = Contains a pointer to a point struct
;
; RETURNS
;	EAX = Returns a SDWORD offset to the location in the screen
;
; EXAMPLE
;	mov eax, OFFSET point
;	call arrayPosition
;-------------------------------------------------------------------------------

arrayPosition PROC

	mov esi, eax						; copy point struct pointer to ESI
	call Position_validPosition			; check if position is valid

	cmp eax, FALSE						; if (validPosition(point) == FALSE)
	je Return							; jump if equal

	mov eax, [esi].Point.y				; EAX = y-coordinate
	mov ecx, TYPE WORD					; ECX = sizeof(WORD)
	imul ecx							; EAX = y * sizeof(WORD)

	mov ecx, positionWidth				; ECX = positionWidth
	imul ecx							; EAX *= positionWidth

	mov edi, eax						; save result into EDI

	mov eax, [esi].Point.x				; EAX = x-coordinate
	mov ecx, TYPE WORD					; ECX = sizeof(WORD)
	imul ecx							; EAX = x * sizeof(buffer)

	add eax, edi						; add EDI to EAX

Return:
	ret									; return from procedure
arrayPosition ENDP

;-------------------------------------------------------------------------------
; PROCEDURE findNextPath
; ______________________________________________________________________________
; Find the next path based on the Direction constant.
;
; PARAMETERS
;	EAX = Contains a pointer to the destination point
;	EBX = Contains a pointer to the source point
;	ECX = Direction constant
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pointA
;	mov ebx, OFFSET pointB
;	mov ecx, direction
;	call findNextPath
;-------------------------------------------------------------------------------

findNextPath PROC

	call Utils_copyPoint				; copy point in EBX to point in EAX

	mov ebx, ecx						; EBX = Direction constant
	call Position_movePoint				; move to the next point on path

	ret									; return from procedure
findNextPath ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PathMap_position
; ______________________________________________________________________________
; Converts a valid point to a buffer index offset inside the game map.
;
; PARAMETERS
;	EAX = Contains a pointer to a point struct
;
; RETURNS
;	EAX = Returns a SDWORD offset to the location in the game map
;
; EXAMPLE
;	mov eax, OFFSET point
;	call PathMap_position
;-------------------------------------------------------------------------------

PathMap_position PROC

	mov positionWidth, GAME_MAP_WIDTH		; using game map width for array
	call arrayPosition						; get offset in array

	ret										; return from procedure
PathMap_position ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PathMap_finder
; ______________________________________________________________________________
; Creates the path map route finder with numerical distances.
;
; PARAMETERS
;	EAX = Contains a pointer to a path map array
;	EBX = Contains a pointer to the target point
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pathMap
;	mov ebx, OFFSET targetPoint
;	call PathMap_finder
;-------------------------------------------------------------------------------

PathMap_finder PROC

	mov positionWidth, GAME_MAP_WIDTH		; using game map width for array
	mov mapPtr, eax							; save the map array pointer	

	mov currBegPtr, OFFSET currentPositions	; &currentPositions[0]
	mov currEndPtr, OFFSET currentPositions	; &currentPositions[0]

	mov nextBegPtr, OFFSET nextPositions	; &nextPositions[0]
	mov nextEndPtr, OFFSET nextPositions	; &nextPositions[0]

	mov eax, currEndPtr						; get pointer to last point
	call Utils_copyPoint					; copy point in EBX to currEndPtr
	add currEndPtr, TYPE Point				; currEndPtr++

	mov distance, 0							; distance from target point

L1:
	mov ebx, currBegPtr						; EBX = pointer to first point
	mov pointPtr, ebx						; store pointer in pointPtr

L2:
	mov ebx, currEndPtr						; EBX = pointer to last point
	cmp pointPtr, ebx						; while (pointPtr < currEndPtr)
	jae Next								; jump if above or equal

	mov eax, OFFSET mapPoint				; EAX = points to mapPoint
	mov ebx, pointPtr						; EBX = points to current point
	call Utils_copyPoint					; copy EBX into mapPoint

	add pointPtr, TYPE Point				; pointPtr++

	call Position_validPosition				; check if mapPoint is valid

	cmp eax, TRUE							; if (validPosition(point) == TRUE)
	jne L2									; jump if not equal

	mov eax, OFFSET mapPoint				; EAX = points to mapPoint
	call arrayPosition						; get offset for mapPtr

	add eax, mapPtr							; add offset to mapPtr address
	mov bx, [eax]							; BX = value at mapPoint

	cmp bx, PATH_EMPTY						; if (value == PATH_EMPTY)
	jne L2									; jump if not equal

	mov bx, distance						; BX = distance from target 
	mov [eax], bx							; store BX into path map

	mov eax, nextEndPtr						; EAX = pointer to last point
	mov ebx, OFFSET mapPoint				; EBX = pointer to current point
	mov ecx, DIRECTION_UP					; ECX = move up from location
	call findNextPath						; save next point into nextEndPtr

	add nextEndPtr, TYPE Point				; nextEndPtr++

	mov eax, nextEndPtr						; EAX = pointer to last point
	mov ebx, OFFSET mapPoint				; EBX = pointer to current point
	mov ecx, DIRECTION_DOWN					; ECX = move down from location
	call findNextPath						; save next point into nextEndPtr

	add nextEndPtr, TYPE Point				; nextEndPtr++

	mov eax, nextEndPtr						; EAX = pointer to last point
	mov ebx, OFFSET mapPoint				; EBX = pointer to current point
	mov ecx, DIRECTION_LEFT					; ECX = move left from location
	call findNextPath						; save next point into nextEndPtr

	add nextEndPtr, TYPE Point				; nextEndPtr++

	mov eax, nextEndPtr						; EAX = pointer to last point
	mov ebx, OFFSET mapPoint				; EBX = pointer to current point
	mov ecx, DIRECTION_RIGHT				; ECX = move right from location
	call findNextPath						; save next point into nextEndPtr

	add nextEndPtr, TYPE Point				; nextEndPtr++
	jmp L2									; unconditional jump

Next:
	mov ebx, currBegPtr						; EBX = curr beg pointer
	mov pointPtr, ebx						; store into pointPtr

	mov ebx, nextBegPtr						; EBX = next beg pointer
	mov currBegPtr, ebx						; store into curr beg pointer

	mov ebx, nextEndPtr						; EBX = next end pointer
	mov currEndPtr, ebx						; store into curr end pointer

	mov ebx, pointPtr						; EBX = pointPtr
	mov nextBegPtr, ebx						; store into next beg pointer
	mov nextEndPtr, ebx						; store into next end pointer
	inc distance							; add one to target distance

	mov ebx, currEndPtr						; EBX = curr end pointer
	cmp currBegPtr, ebx						; while (currBegPtr < currEndPtr)
	jb L1									; jump if below

	ret										; return from procedure
PathMap_finder ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PathMap_buildPathMap
; ______________________________________________________________________________
; Creates an empty path map based off the game map array.
;
; PARAMETERS
;	EAX = Contains a pointer to a path map array
;	EBX = Contains a pointer to the allowed character array
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pathMap
;	mov ebx, OFFSET defaultSpots
;	call PathMap_buildPathMap
;-------------------------------------------------------------------------------

PathMap_buildPathMap PROC

	mov positionWidth, SCREEN_WIDTH		; using screen width for array
	mov esi, 0							; y index

L1:
	cmp esi, GAME_MAP_HEIGHT			; (ESI < GAME_MAP_HEIGHT)
	jge Return							; jump if greater than or equal

	mov edi, 0							; x index
	
L2:
	cmp edi, GAME_MAP_WIDTH				; (EDI < GAME_MAP_WIDTH)
	jge Next							; jump if greater than or equal

	push esi							; push y index to stack
	push edi							; push x index to stack
	push eax							; push path map pointer to stack
	push ebx							; push allowed array to stack

	mov mapPoint.x, edi					; set x value to point
	mov mapPoint.y, esi					; set y value to point
	mov eax, OFFSET mapPoint			; EAX = pointer to mapPoint struct
	call arrayPosition					; get array position in game map

	mov ax, gameMap[eax]				; read character from game map
	call Position_validChar				; check if character is allowed

	pop ebx								; restore allowed array off stack

	cmp eax, TRUE						; if (validChar(AX) == TRUE)
	pop eax								; restore path map pointer off stack
	jne J1								; jump if not equal

	mov cx, PATH_EMPTY					; CX = PATH_EMPTY character
	jmp J2								; unconditional jump

J1:
	mov cx, PATH_WALL					; CX = PATH_WALL character
	
J2:
	mov [eax], cx						; save CX to path map array
	add eax, TYPE WORD					; map++

	pop edi								; restore x index off stack
	pop esi								; restore y index off stack

	inc edi								; x++
	jmp L2								; unconditional jump

Next:
	inc esi								; y++
	jmp L1								; unconditional jump

Return:
	ret									; return from procedure
PathMap_buildPathMap ENDP

;-------------------------------------------------------------------------------

end

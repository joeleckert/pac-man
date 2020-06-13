
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Defines.inc
INCLUDE Position.inc
INCLUDE Structs.inc
INCLUDE PathMap.inc
INCLUDE Utils.inc
INCLUDE GameMap.inc

;-------------------------------------------------------------------------------

TOTAL_DIRECTIONS EQU 4
TOTAL_POINTS EQU 10

FRONT_DISTANCE EQU 4
TIMID_DISTANCE EQU 8

;-------------------------------------------------------------------------------

DistanceValues STRUCT
	up SWORD ?
	down SWORD ?
	left SWORD ?
	right SWORD ?
DistanceValues ENDS

;-------------------------------------------------------------------------------

.data
returnValue DWORD 0
sourcePtr DWORD 0
targetPtr DWORD 0
validSpotsPtr DWORD 0
sourceDirection DWORD 0

minXPtr DWORD 0
maxXPtr DWORD 0
minYPtr DWORD 0
maxYPtr DWORD 0

source Point <>
target Point <>
values DistanceValues <>

matches Point TOTAL_POINTS DUP(<>)
directions DWORD TOTAL_DIRECTIONS DUP(0)

pathMap WORD PATH_MAP_SIZE DUP(0)

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE getDirectionDistance
; ______________________________________________________________________________
; Get the numerical distance from the target moving in the direction of the
; Direction constant.
;
; PARAMETERS
;	EAX = Direction constant
;
; RETURNS
;	AX = Numerical distance from target point
;
; EXAMPLE
;	mov eax, direction
;	call getDirectionDistance
;-------------------------------------------------------------------------------

getDirectionDistance PROC

	mov ecx, eax						; ECX = Direction constant

	mov eax, OFFSET source				; EAX = destination point
	mov ebx, sourcePtr					; EBX = source point
	call Utils_copyPoint				; copy point in EBX to source point

	mov eax, OFFSET source				; point to move
	mov ebx, ecx						; direction to move
	call Position_movePoint				; move the point

	mov eax, OFFSET source				; point to find index on pathMap
	call PathMap_position				; find index position on pathMap

	mov ax, pathMap[eax]				; return distance
	ret									; return from procedure
getDirectionDistance ENDP

;-------------------------------------------------------------------------------
; PROCEDURE getDistanceValues
; ______________________________________________________________________________
; Gets all the numerical distances from the target moving in all directions.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call getDistanceValues
;-------------------------------------------------------------------------------

getDistanceValues PROC

	mov eax, DIRECTION_UP				; EAX = DIRECTION_UP
	call getDirectionDistance			; get distance
	mov values.up, ax					; store distance

	mov eax, DIRECTION_DOWN				; EAX = DIRECTION_DOWN
	call getDirectionDistance			; get distance
	mov values.down, ax					; store distance

	mov eax, DIRECTION_LEFT				; EAX = DIRECTION_LEFT
	call getDirectionDistance			; get distance
	mov values.left, ax					; store distance

	mov eax, DIRECTION_RIGHT			; EAX = DIRECTION_RIGHT
	call getDirectionDistance			; get distance
	mov values.right, ax				; store distance

	ret									; return from procedure
getDistanceValues ENDP

;-------------------------------------------------------------------------------
; PROCEDURE removeReverseDirection
; ______________________________________________________________________________
; Removes the opposite direction from the list of possible moves.
;
; PARAMETERS
;	EAX = Direction constant
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, direction
;	call removeReverseDirection
;-------------------------------------------------------------------------------

removeReverseDirection PROC

	cmp eax, DIRECTION_UP				; case DIRECTION_UP:
	je S1								; jump if equal

	cmp eax, DIRECTION_DOWN				; case DIRECTION_DOWN:
	je S2								; jump if equal

	cmp eax, DIRECTION_LEFT				; case DIRECTION_LEFT:
	je S3								; jump if equal

	cmp eax, DIRECTION_RIGHT			; case DIRECTION_RIGHT:
	je S4								; jump if equal

	jmp Return							; default: unconditional jump

S1:
	mov values.down, PATH_WALL			; remove down direction
	jmp Return							; unconditional jump

S2:
	mov values.up, PATH_WALL			; remove up direction
	jmp Return							; unconditional jump

S3:
	mov values.right, PATH_WALL			; remove right direction
	jmp Return							; unconditional jump

S4:
	mov values.left, PATH_WALL			; remove left direction

Return:
	ret									; return from procedure
removeReverseDirection ENDP

;-------------------------------------------------------------------------------
; PROCEDURE restrictedZones
; ______________________________________________________________________________
; Removes the moves that a ghost is not allowed to do.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call restrictedZones
;-------------------------------------------------------------------------------

restrictedZones PROC

	mov eax, sourcePtr					; EAX = pointer to source point

	cmp [eax].Point.x, 12				; if (EAX->x == 12
	je C1								; jump if equal

	cmp [eax].Point.x, 15				; || EAX->x == 15)
	jne Return							; jump if not equal

C1:
	cmp [eax].Point.y, 8				; if (EAX->y == 8
	je C2								; jump if equal

	cmp [eax].Point.y, 18				; || EAX->y == 18)
	jne Return							; jump if not equal

C2:
	mov values.up, PATH_WALL			; remove moving up from values

Return:
	ret									; return from procedure
restrictedZones ENDP

;-------------------------------------------------------------------------------
; PROCEDURE preferredDirection
; ______________________________________________________________________________
; If there are multiple directions that are the same distance from the target,
; then break the tie with the preferred direction.
;
; PARAMETERS
;	None
;
; RETURNS
;	EAX = Direction constant
;
; EXAMPLE
;	call preferredDirection
;-------------------------------------------------------------------------------

preferredDirection PROC

	mov eax, DIRECTION_RIGHT			; direction = DIRECTION_RIGHT
	mov bx, values.right				; distance = values.right

	cmp values.down, bx					; if (values.down <= distance)
	jg C1								; jump if greater than

	mov eax, DIRECTION_DOWN				; direction = DIRECTION_DOWN
	mov bx, values.down					; distance = values.down

C1:
	cmp values.left, bx					; if (values.left <= distance)
	jg C2								; jump if greater than

	mov eax, DIRECTION_LEFT				; direction = DIRECTION_LEFT
	mov bx, values.left					; distance = values.left

C2:
	cmp values.up, bx					; if (values.up <= distance)
	jg Return							; jump if greater than

	mov eax, DIRECTION_UP				; direction = DIRECTION_UP

Return:
	ret									; return from procedure
preferredDirection ENDP

;-------------------------------------------------------------------------------
; PROCEDURE getPointsAtDistance
; ______________________________________________________________________________
; Gets all the points that have the exact numerical distance from the target
; using the argument passed in the EAX to match.
;
; PARAMETERS
;	AX = The numerical distance to match
;
; RETURNS
;	EAX = Total number of matches
;
; EXAMPLE
;	mov eax, targetDistance
;	call getPointsAtDistance
;-------------------------------------------------------------------------------

getPointsAtDistance PROC

	mov ebx, 0								; match count = 0
	mov cx, ax								; CX = targetDistance
	mov esi, 0								; loop index

L1:
	cmp esi, PATH_MAP_SIZE					; (ESI < PATH_MAP_SIZE)
	jge Return								; jump if greater than or equal

	mov ax, pathMap[esi * TYPE pathMap]		; AX = pathMap value
	cmp ax, cx								; if (value == targetDistance)
	jne Next								; jump if not equal

	mov eax, esi							; EAX = loop index
	mov edx, 0								; Clear remainder
	mov edi, GAME_MAP_WIDTH					; Set the divisor
	idiv edi								; Divide by GAME_MAP_WIDTH

	mov matches[ebx * TYPE matches].x, edx	; ESI % GAME_MAP_WIDTH
	mov matches[ebx * TYPE matches].y, eax	; ESI / GAME_MAP_WIDTH
	inc ebx									; match count++

	cmp ebx, TOTAL_POINTS					; if (count >= TOTAL_POINTS)
	jge Return								; jump if greater than or equal

Next:
	inc esi									; loop index++
	jmp L1									; unconditional jump

Return:
	mov eax, ebx							; return match count
	ret										; return from procedure
getPointsAtDistance ENDP

;-------------------------------------------------------------------------------
; PROCEDURE getNewTarget
; ______________________________________________________________________________
; Get a target in front of Pac-Man in the direction he is moving.
;
; PARAMETERS
;	EAX = Total number of matches
;	EBX = The direction that Pac-Man is moving
;
; RETURNS
;	EAX = Pointer to the new target point
;
; EXAMPLE
;	mov eax, count
;	mov ebx, direction
;	call getNewTarget
;-------------------------------------------------------------------------------

getNewTarget PROC

	mov minXPtr, OFFSET matches			; minXPtr = &matches[0]
	mov maxXPtr, OFFSET matches			; maxXPtr = &matches[0]
	mov minYPtr, OFFSET matches			; minYPtr = &matches[0]
	mov maxYPtr, OFFSET matches			; maxYPtr = &matches[0]

	mov edi, eax						; EDI = count
	mov esi, 0							; loop index

L1:
	cmp esi, edi						; (ESI < count)
	jge Done							; jump if greater than or equal

	mov eax, TYPE matches				; EAX = sizeof(matches)
	imul esi							; EAX *= loop index
	add eax, OFFSET matches				; EAX += pointer to matches address

	mov ecx, minXPtr					; ECX = minXPtr pointer
	mov ecx, [ecx].Point.x				; ECX = minXPtr->x

	cmp [eax].Point.x, ecx				; if (EAX->x < minXPtr->x)
	jge C1								; jump if greater than or equal

	mov minXPtr, eax					; minXPtr = point

C1:
	mov ecx, minYPtr					; ECX = minYPtr pointer
	mov ecx, [ecx].Point.y				; ECX = minYPtr->y

	cmp [eax].Point.y, ecx				; if (EAX->y < minYPtr->y)
	jge C2								; jump if greater than or equal

	mov minYPtr, eax					; minYPtr = point

C2:
	mov ecx, maxXPtr					; ECX = maxXPtr pointer
	mov ecx, [ecx].Point.x				; ECX = maxXPtr->x

	cmp [eax].Point.x, ecx				; if (EAX->x > maxXPtr->x)
	jle C3								; jump if less than or equal

	mov maxXPtr, eax					; maxXPtr = point

C3:
	mov ecx, maxYPtr					; ECX = maxYPtr pointer
	mov ecx, [ecx].Point.y				; ECX = maxYPtr->y

	cmp [eax].Point.y, ecx				; if (EAX->y > maxYPtr->y)
	jle Next							; jump if less than or equal

	mov maxYPtr, eax					; maxYPtr = point

Next:
	inc esi								; loop index++
	jmp L1								; unconditional jump

Done:
	mov eax, OFFSET matches				; EAX = &matches[0]

	cmp ebx, DIRECTION_UP				; case DIRECTION_UP:
	je S1								; jump if equal

	cmp ebx, DIRECTION_DOWN				; case DIRECTION_DOWN:
	je S2								; jump if equal

	cmp ebx, DIRECTION_LEFT				; case DIRECTION_LEFT:
	je s3								; jump if equal

	cmp ebx, DIRECTION_RIGHT			; case DIRECTION_RIGHT:
	je s4								; jump if equal

	jmp Return							; default: unconditional jump

S1:
	mov eax, minYPtr					; return minYPtr
	jmp Return							; unconditional jump

S2:
	mov eax, maxYPtr					; return maxYPtr
	jmp Return							; unconditional jump

S3:
	mov eax, minXPtr					; return minXPtr
	jmp Return							; unconditional jump

S4:
	mov eax, maxXPtr					; return maxXPtr

Return:
	ret									; return from procedure
getNewTarget ENDP

;-------------------------------------------------------------------------------
; PROCEDURE totalValidDirections
; ______________________________________________________________________________
; Returns the number of valid directions in the directions array.
;
; PARAMETERS
;	None
;
; RETURNS
;	EAX = The number of valid directions
;
; EXAMPLE
;	call totalValidDirections
;-------------------------------------------------------------------------------

totalValidDirections PROC

	mov eax, 0							; total = 0

	cmp values.up, PATH_WALL			; if (nalues.up != PATH_WALL)
	je C1								; jump if equal

	mov directions[eax * TYPE directions], DIRECTION_UP		; save direction
	inc eax													; total++

C1:
	cmp values.down, PATH_WALL			; if (values.down != PATH_WALL)
	je C2								; jump if equal

	mov directions[eax * TYPE directions], DIRECTION_DOWN	; save direction
	inc eax													; total++

C2:
	cmp values.left, PATH_WALL			; if (values.left != PATH_WALL)
	je C3								; jump if equal

	mov directions[eax * TYPE directions], DIRECTION_LEFT	; save direction
	inc eax													; total++

C3:
	cmp values.right, PATH_WALL			; if (values.right != PATH_WALL)
	je Return							; jump if equal

	mov directions[eax * TYPE directions], DIRECTION_RIGHT	; save direction
	inc eax													; total++

Return:
	ret									; return from procedure
totalValidDirections ENDP

;-------------------------------------------------------------------------------
; PROCEDURE createPathMap
; ______________________________________________________________________________
; Creates the path map.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET targetPoint
;	call createPathMap
;-------------------------------------------------------------------------------

createPathMap PROC

	mov eax, OFFSET pathMap				; EAX = pointer to pathMap
	mov ebx, validSpotsPtr				; EBX = pointer to allowed array
	call PathMap_buildPathMap			; create the empty path map

	mov eax, OFFSET pathMap				; EAX = pointer to pathMap
	mov ebx, targetPtr					; EBX = target point
	call PathMap_finder					; build path map to target point

	ret									; return from procedure
createPathMap ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostMazeLogic_moveToTarget
; ______________________________________________________________________________
; Has the ghost move to target in the fastest way possible.
;
; PARAMETERS
;	EAX = Contains a pointer to the source point
;	EBX = Direction constant
;	ECX = Contains a pointer to the target point
;	EDX = Contains a pointer to the validSpots character array
;
; RETURNS
;	EAX = Direction constant
;
; EXAMPLE
;	mov eax, OFFSET sourcePoint
;	mov ebx, direction
;	mov ecx, OFFSET targetPoint
;	mov edx, OFFSET defaultSpots
;	call GhostMazeLogic_moveToTarget
;-------------------------------------------------------------------------------

GhostMazeLogic_moveToTarget PROC

	pushad								; save registers
	mov sourcePtr, eax					; save pointer to source point
	mov sourceDirection, ebx			; save direction constant
	mov targetPtr, ecx					; save pointer to target point
	mov validSpotsPtr, edx				; save pointer to valid spots array
	
	call createPathMap					; build the path map
	call getDistanceValues				; get distances from target

	mov eax, sourceDirection			; EAX = source target direction
	call removeReverseDirection			; remove opposite direction from moves
	call restrictedZones				; remove forbidden moves
	call preferredDirection				; move ghost in preferred direction

	mov returnValue, eax				; save Direction constant
	popad								; restore registers

	mov eax, returnValue				; return Direction constant
	ret									; return from procedure
GhostMazeLogic_moveToTarget ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostMazeLogic_moveInFrontOfTarget
; ______________________________________________________________________________
; Has the ghost try to get in front of Pac-Man, not chase him.
;
; PARAMETERS
;	EAX = Contains a pointer to the source point
;	EBX = Source direction constant
;	ECX = Contains a pointer to the target point
;	EDX = Target direction constant
;
; RETURNS
;	EAX = Direction constant
;
; EXAMPLE
;	mov eax, OFFSET sourcePoint
;	mov ebx, sourceDirection
;	mov ecx, OFFSET targetPoint
;	mov edx, targetDirection
;	call GhostMazeLogic_moveInFrontOfTarget
;-------------------------------------------------------------------------------

GhostMazeLogic_moveInFrontOfTarget PROC

	pushad									; save registers
	mov sourcePtr, eax						; save pointer to source point
	mov sourceDirection, ebx				; save source direction constant
	mov targetPtr, ecx						; save pointer to target point
	mov validSpotsPtr, OFFSET defaultSpots	; save pointer to valid spots array

	push edx								; push target direction on stack
	call createPathMap						; build the path map

	mov eax, FRONT_DISTANCE					; distance from target
	call getPointsAtDistance				; get all points with that distance

	pop edx									; pop target direction off stack
	mov ebx, edx							; EBX = target direction
	call getNewTarget						; get new target in front of target

	mov targetPtr, eax						; save pointer to new target point
	call createPathMap						; build the new path map
	call getDistanceValues					; get distances from new target
	
	mov eax, sourceDirection				; EAX = source target direction
	call removeReverseDirection				; remove opposite direction
	call restrictedZones					; remove forbidden moves
	call preferredDirection					; move ghost in preferred direction

	mov returnValue, eax					; save Direction constant
	popad									; restore registers

	mov eax, returnValue					; return Direction constant
	ret										; return from procedure
GhostMazeLogic_moveInFrontOfTarget ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostMazeLogic_moveTimidly
; ______________________________________________________________________________
; If the ghost gets too close to Pac-Man he runs back to his home target.
;
; PARAMETERS
;	EAX = Contains a pointer to the source point
;	EBX = Source direction constant
;	ECX = Contains a pointer to the target point
;	EDX = Contains a pointer to the home point
;
; RETURNS
;	EAX = Direction constant
;
; EXAMPLE
;	mov eax, OFFSET sourcePoint
;	mov ebx, sourceDirection
;	mov ecx, OFFSET targetPoint
;	mov edx, OFFSET homePoint
;	call GhostMazeLogic_moveTimidly
;-------------------------------------------------------------------------------

GhostMazeLogic_moveTimidly PROC

	pushad									; save registers
	mov sourcePtr, eax						; save pointer to source point
	mov sourceDirection, ebx				; save source direction constant
	mov targetPtr, ecx						; save pointer to target point
	mov validSpotsPtr, OFFSET defaultSpots	; save pointer to valid spots array

	push edx								; push home point on stack

	call createPathMap						; build the path map
	call getDistanceValues					; get distances from target
	
	mov eax, sourceDirection				; EAX = source target direction
	call removeReverseDirection				; remove opposite direction
	call restrictedZones					; remove forbidden moves

	call preferredDirection					; get preferred direction
	mov ebx, 0								; EBX = distance to target

	cmp eax, DIRECTION_UP					; case DIRECTION_UP:
	je S1									; jump if equal

	cmp eax, DIRECTION_DOWN					; case DIRECTION_DOWN:
	je S2									; jump if equal

	cmp eax, DIRECTION_LEFT					; case DIRECTION_LEFT:
	je s3									; jump if equal

	cmp eax, DIRECTION_RIGHT				; case DIRECTION_RIGHT:
	je s4									; jump if equal

	jmp Done								; default: unconditional jump

S1:
	mov bx, values.up						; distance = values.up
	jmp Done								; unconditional jump

S2:
	mov bx, values.down						; distance = values.down
	jmp Done								; unconditional jump

S3:
	mov bx, values.left						; distance = values.left
	jmp Done								; unconditional jump

S4:
	mov bx, values.right					; distance = values.right

Done:
	pop edx									; pop home point on stack

	cmp bx, TIMID_DISTANCE					; if (distance <= TIMID_DISTANCE)
	jg Return								; jump if greater than

	mov eax, sourcePtr						; pointer to the source point
	mov ebx, sourceDirection				; source direction constant
	mov ecx, edx							; target point is now home target
	mov edx, OFFSET defaultSpots			; valid spots are default spots
	call GhostMazeLogic_moveToTarget		; move to home target

Return:
	mov returnValue, eax					; save Direction constant
	popad									; restore registers

	mov eax, returnValue					; return Direction constant
	ret										; return from procedure
GhostMazeLogic_moveTimidly ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostMazeLogic_moveRandomly
; ______________________________________________________________________________
; The ghost moves in a random way.
;
; PARAMETERS
;	EAX = Contains a pointer to the source point
;	EBX = Source direction constant
;
; RETURNS
;	EAX = Direction constant
;
; EXAMPLE
;	mov eax, OFFSET sourcePoint
;	mov ebx, sourceDirection
;	call GhostMazeLogic_moveRandomly
;-------------------------------------------------------------------------------

GhostMazeLogic_moveRandomly PROC

	pushad									; save registers
	mov sourcePtr, eax						; save pointer to source point
	mov sourceDirection, ebx				; save source direction constant
	mov targetPtr, OFFSET target			; save pointer to target point
	mov validSpotsPtr, OFFSET defaultSpots	; save pointer to valid spots array

	mov target.x, 14						; arbitrary x-position for pathMap
	mov target.y, 14						; arbitrary y-position for pathMap

	call createPathMap						; build the path map
	call getDistanceValues					; get distances from target

	mov eax, sourceDirection				; EAX = source target direction
	call removeReverseDirection				; remove opposite direction

	call totalValidDirections					; count of valid moves
	call Utils_randomValue						; random array index
	mov eax, directions[eax * TYPE directions]	; return random direction

	mov returnValue, eax						; save Direction constant
	popad										; restore registers

	mov eax, returnValue						; return Direction constant
	ret											; return from procedure
GhostMazeLogic_moveRandomly ENDP

;-------------------------------------------------------------------------------

end


.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Ghost.inc
INCLUDE Defines.inc
INCLUDE Screen.inc
INCLUDE Utils.inc
INCLUDE Position.inc
INCLUDE GhostMazeLogic.inc
INCLUDE PacMan.inc

;-------------------------------------------------------------------------------

.data
returnValue DWORD 0
targetPoint Point <>

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE moveToTarget
; ______________________________________________________________________________
; Move the ghost toward the point passed to the procedure.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to a Point struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov ebx, OFFSET targetPoint
;	call moveToTarget
;-------------------------------------------------------------------------------

moveToTarget PROC

	pushad								; save registers
	mov edx, OFFSET defaultSpots		; default spots for ghost to move

	cmp [eax].Ghost.mInterruptMode, GHOST_INTERRUPT_EXITING	; if (ghostExiting)
	je C1													; jump if equal

	cmp [eax].Ghost.mInterruptMode, GHOST_INTERRUPT_EATEN	; if (ghostEaten)
	jne C2													; jump if not equal

C1:
	mov edx, OFFSET ghostSpots			; spots that only a ghost can move to

C2:
	push eax								; push class struct on stack

	mov ecx, ebx							; ECX = target point
	mov ebx, [eax].Ghost.mDirection			; EBX = ghost move direction
	lea eax, [eax].Ghost.mSprite.charPoint	; EAX = ghost position
	call GhostMazeLogic_moveToTarget		; get direction to target point

	pop edx									; pop class struct off stack
	mov [edx].Ghost.mDirection, eax			; save new move direction

	mov ebx, eax							; EBX = ghost move direction
	lea eax, [edx].Ghost.mSprite.charPoint	; EAX = ghost position
	call Position_movePoint					; move ghost to target point

	popad									; restore registers
	ret										; return from procedure
moveToTarget ENDP

;-------------------------------------------------------------------------------
; PROCEDURE modePacing
; ______________________________________________________________________________
; How the ghost behaves when pacing.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call modePacing
;-------------------------------------------------------------------------------

modePacing PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	mov ecx, OFFSET defaultSpots			; valid spots to move to
	call Position_validMove					; check if move is valid

	cmp eax, FALSE							; if (validMove == FALSE)
	jne C1									; jump if not equal

	mov eax, [edi].Ghost.mDirection			; EAX = ghost direction
	call Utils_reverseDirection				; reverse that direction
	mov [edi].Ghost.mDirection, eax			; save the reverse direction

C1:
	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	mov ecx, OFFSET defaultSpots			; valid spots to move to
	call Position_validMove					; check if move is valid

	cmp eax, TRUE							; if (validMove == TRUE)
	jne Return								; jump if not equal

	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	call Position_movePoint					; move ghost to new point

Return:
	popad									; restore registers
	ret										; return from procedure
modePacing ENDP

;-------------------------------------------------------------------------------
; PROCEDURE modeExiting
; ______________________________________________________________________________
; How the ghost behaves when exiting the ghost house.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call modeExiting
;-------------------------------------------------------------------------------

modeExiting PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	mov targetPoint.x, 14					; exit point x-position
	mov targetPoint.y, 8					; exit point y-position

	mov ebx, OFFSET targetPoint				; EBX = pointer to targetPoint
	call moveToTarget						; move ghost to target point

	lea eax, [edi].Ghost.mSprite.charPoint	; EAX = pointer to ghost position
	mov ebx, OFFSET targetPoint				; EBX = pointer to targetPoint
	call Utils_pointsEqual					; check if position matches target
	jne Return								; jump if not equal

	mov [edi].Ghost.mDirection, DIRECTION_UP				; exit direction
	mov [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_NONE	; exit mode

Return:
	popad									; restore registers
	ret										; return from procedure
modeExiting ENDP

;-------------------------------------------------------------------------------
; PROCEDURE modeChase
; ______________________________________________________________________________
; How the ghost behaves when chasing Pac-Man.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to a Pac-Man class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov ebx, OFFSET pacManStruct
;	call modeChase
;-------------------------------------------------------------------------------

modeChase PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	mov eax, ebx							; EAX = Pac-Man*
	call PacMan_getDirection				; get Pac-Man direction
	mov edx, eax							; EDX = Pac-Man direction

	mov eax, ebx							; EAX = Pac-Man*
	call PacMan_getPoint					; get Pac-Man position

	mov ebx, eax							; source point
	mov eax, OFFSET targetPoint				; destination point
	call Utils_copyPoint					; copy into targetPoint

	mov eax, [edi].Ghost.mTargetMode		; EAX = self->mTargetMode
	cmp eax, TARGET_MODE_CHANGES			; if (mode == CHANGES)
	jne C1									; jump if not equal

	mov eax, 3								; maximum random range
	call Utils_randomValue					; generate random value [0, 3)

C1:
	cmp eax, TARGET_MODE_FRONT				; case FRONT:
	je S1									; jump if equal

	cmp eax, TARGET_MODE_TIMID				; case TIMID:
	je S2									; jump if equal

	jmp Default								; default - unconditional jump

S1:
	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	mov ecx, OFFSET targetPoint				; Pac-Man position
	call GhostMazeLogic_moveInFrontOfTarget	; mode in front of target

	mov [edi].Ghost.mDirection, eax			; save the direction

	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	call Position_movePoint					; move ghost to new point
	jmp Return								; unconditional jump

S2:
	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	mov ecx, OFFSET targetPoint				; Pac-Man position
	lea edx, [edi].Ghost.mScatterTarget		; timid target
	call GhostMazeLogic_moveTimidly			; move ghost timidly
	
	mov [edi].Ghost.mDirection, eax			; save the direction

	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	call Position_movePoint					; move ghost to new point
	jmp Return								; unconditional jump

Default:
	mov eax, edi							; EAX = class struct
	mov ebx, OFFSET targetPoint				; EBX = Pac-Man position
	call moveToTarget						; move ghost to target

Return:
	popad									; restore registers
	ret										; return from procedure
modeChase ENDP

;-------------------------------------------------------------------------------
; PROCEDURE modeScatter
; ______________________________________________________________________________
; How the ghost behaves when in scatter mode.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call modeScatter
;-------------------------------------------------------------------------------

modeScatter PROC

	pushad								; save registers

	lea ebx, [eax].Ghost.mScatterTarget	; go to home corner target
	call moveToTarget					; move ghost to target

	popad								; restore registers
	ret									; return from procedure
modeScatter ENDP

;-------------------------------------------------------------------------------
; PROCEDURE modeFrightened
; ______________________________________________________________________________
; How the ghost behaves when in frightened mode.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call modeFrightened
;-------------------------------------------------------------------------------

modeFrightened PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	call GhostMazeLogic_moveRandomly		; move ghost randomly
	
	mov [edi].Ghost.mDirection, eax			; save the direction

	lea eax, [edi].Ghost.mSprite.charPoint	; position of the ghost
	mov ebx, [edi].Ghost.mDirection			; direction of the ghost
	call Position_movePoint					; move ghost to new point

	popad									; restore registers
	ret										; return from procedure
modeFrightened ENDP

;-------------------------------------------------------------------------------
; PROCEDURE modeEaten
; ______________________________________________________________________________
; How the ghost behaves when eaten.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call modeEaten
;-------------------------------------------------------------------------------

modeEaten PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	lea ebx, [edi].Ghost.mHomeTarget		; go to starting level position
	call moveToTarget						; move ghost to target

	lea eax, [edi].Ghost.mSprite.charPoint	; EAX = pointer to ghost position
	lea ebx, [edi].Ghost.mHomeTarget		; go to starting level position
	call Utils_pointsEqual					; check if position matches target

	cmp eax, TRUE							; if (pointsEqual == TRUE)
	jne Return								; jump if not equal

	mov dx, [edi].Ghost.mAttributes			; DX = self->mAttributes

	mov [edi].Ghost.mSprite.character, GHOST_CHAR			; ghost character
	mov [edi].Ghost.mSprite.attributes, dx					; default color
	mov [edi].Ghost.mDirection, DIRECTION_UP				; default direction
	mov [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_PACING	; start by pacing

Return:
	popad									; restore registers
	ret										; return from procedure
modeEaten ENDP

;-------------------------------------------------------------------------------
; PROCEDURE setSpeed
; ______________________________________________________________________________
; Sets how fast the ghost moves.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call setSpeed
;-------------------------------------------------------------------------------

setSpeed PROC

	pushad									; save registers
	push eax								; push class struct on stack

	mov edx, [eax].Ghost.mIsFrightened		; is ghost frightened
	mov ecx, [eax].Ghost.mInterruptMode		; interrupt mode
	lea ebx, [eax].Ghost.mSprite.charPoint	; position of ghost
	lea eax, [eax].Ghost.mSpeed				; Speed*
	call Speed_ghost						; get the speed for ghost

	pop ebx									; pop class struct off stack
	mov [ebx].Ghost.mMoveCounter, eax		; self->mMoveCounter = speed

	popad									; restore registers
	ret										; return from procedure
setSpeed ENDP

;-------------------------------------------------------------------------------
; PROCEDURE isGhostModeEnabled
; ______________________________________________________________________________
; Checks if the ghost is in scatter or chase pursuit mode.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = TRUE if in scatter or chase mode, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call isGhostModeEnabled
;-------------------------------------------------------------------------------

isGhostModeEnabled PROC

	cmp [eax].Ghost.mIsFrightened, TRUE	; if (self->mIsFrightened == TRUE
	je C1								; jump if equal

	cmp [eax].Ghost.mInterruptMode, GHOST_INTERRUPT_NONE	; || mode != NONE)
	je C2													; jump if equal

C1:
	mov eax, FALSE						; return FALSE
	jmp Return							; unconditional jump

C2:
	mov eax, TRUE						; return TRUE

Return:
	ret									; return from procedure
isGhostModeEnabled ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_constructor
; ______________________________________________________________________________
; Initializes the Ghost class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Ghost attributes
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov bx, attributes
;	call Ghost_constructor
;-------------------------------------------------------------------------------

Ghost_constructor PROC

	pushad											; save registers

	mov [eax].Ghost.mSprite.character, GHOST_CHAR	; sprite.character = GHOST
	mov [eax].Ghost.mSprite.attributes, bx			; sprite.attributes = attrib
	mov [eax].Ghost.mSprite.visible, FALSE			; sprite.visible = FALSE

	mov [eax].Ghost.mAttributes, bx							; save attributes
	mov [eax].Ghost.mDirection, DIRECTION_UP				; starting direction
	mov [eax].Ghost.mInterruptMode, GHOST_INTERRUPT_PACING	; start by pacing
	mov [eax].Ghost.mMoveCounter, 0							; reset move counter

	cmp bx, RED							; case RED: (Blinky)
	je S1								; jump if equal

	cmp bx, CYAN						; case CYAN: (Inky)
	je S2								; jump if equal

	cmp bx, MAGENTA						; case MAGENTA: (Pinky)
	je S3								; jump if equal

	cmp bx, YELLOW						; case YELLOW: (Clyde)
	je S4								; jump if equal

	jmp Done							; default: unconditional jump

S1:
	; Blinky
	mov [eax].Ghost.mScatterTarget.x, 26			; scatter corner x-position
	mov [eax].Ghost.mScatterTarget.y, 1				; scatter corner y-position

	mov [eax].Ghost.mHomeTarget.x, 14				; starting x-position
	mov [eax].Ghost.mHomeTarget.y, 11				; starting y-position
	mov [eax].Ghost.mTargetMode, TARGET_MODE_EXACT	; how ghost chases Pac-Man
	jmp Done										; unconditional jump

S2:
	; Inky
	mov [eax].Ghost.mScatterTarget.x, 26			; scatter corner x-position
	mov [eax].Ghost.mScatterTarget.y, 22			; scatter corner y-position

	mov [eax].Ghost.mHomeTarget.x, 12				; starting x-position
	mov [eax].Ghost.mHomeTarget.y, 11				; starting y-position
	mov [eax].Ghost.mTargetMode, TARGET_MODE_CHANGES ; how ghost chases Pac-Man
	jmp Done										; unconditional jump

S3:
	; Pinky
	mov [eax].Ghost.mScatterTarget.x, 6				; scatter corner x-position
	mov [eax].Ghost.mScatterTarget.y, 2				; scatter corner y-position

	mov [eax].Ghost.mHomeTarget.x, 14				; starting x-position
	mov [eax].Ghost.mHomeTarget.y, 11				; starting y-position
	mov [eax].Ghost.mTargetMode, TARGET_MODE_FRONT	; how ghost chases Pac-Man
	jmp Done										; unconditional jump

S4:
	; Clyde
	mov [eax].Ghost.mScatterTarget.x, 1				; scatter corner x-position
	mov [eax].Ghost.mScatterTarget.y, 22			; scatter corner y-position

	mov [eax].Ghost.mHomeTarget.x, 16				; starting x-position
	mov [eax].Ghost.mHomeTarget.y, 11				; starting y-position
	mov [eax].Ghost.mTargetMode, TARGET_MODE_TIMID	; how ghost chases Pac-Man

Done:
	push eax										; push class struct on stack

	lea ebx, [eax].Ghost.mHomeTarget				; source point
	lea eax, [eax].Ghost.mSprite.charPoint			; destination point
	call Utils_copyPoint							; sprite to starting point

	pop eax											; pop class struct off stack

	lea eax, [eax].Ghost.mSprite					; EAX = &self->mSprite
	call Screen_addSprite							; add sprite to screen

	popad											; restore registers
	ret												; return from procedure
Ghost_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_defaultPosition
; ______________________________________________________________________________
; Setup the defaults for the ghost before each level.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The current level
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov ebx, level
;	call Ghost_defaultPosition
;-------------------------------------------------------------------------------

Ghost_defaultPosition PROC

	pushad								; save registers

	mov edi, eax						; EDI = class struct
	mov esi, ebx						; ESI = current level
	mov dx, [edi].Ghost.mAttributes		; DX = self->mAttributes

	mov [edi].Ghost.mSprite.character, GHOST_CHAR			; ghost character
	mov [edi].Ghost.mSprite.attributes, dx					; default color
	mov [edi].Ghost.mDirection, DIRECTION_UP				; default direction
	mov [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_PACING	; start by pacing

	lea eax, [edi].Ghost.mMode			; EAX = &self->mMode
	call GhostMode_reset				; reset scatter/chase mode

	lea eax, [edi].Ghost.mGhostRelease	; EAX = &self->mGhostRelease
	mov bx, dx							; BX = self->mAttributes
	mov ecx, esi						; ECX = current level
	call GhostRelease_constructor		; call constructor
	
	lea eax, [edi].Ghost.mSpeed			; EAX = &self->mSpeed
	mov ebx, esi						; EBX = current level
	call Speed_constructor				; call constructor
	
	lea eax, [edi].Ghost.mBlueTime		; EAX = &self->mSpeed
	call GhostBlueTime_constructor		; call constructor

	mov eax, edi						; EAX = class struct
	call Ghost_blueTimeStop				; never start level in blue time

	cmp dx, RED							; if (self->mAttributes == RED)
	jne C1								; jump if not equal

	mov [edi].Ghost.mSprite.charPoint.x, 14					; x-position
	mov [edi].Ghost.mSprite.charPoint.y, 8					; y-position
	mov [edi].Ghost.mDirection, DIRECTION_LEFT				; defaul direction
	mov [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_NONE	; no interrupt
	jmp C2													; unconditional jump

C1:
	lea eax, [edi].Ghost.mSprite.charPoint	; destination point
	lea ebx, [edi].Ghost.mHomeTarget		; source point
	call Utils_copyPoint					; sprite to starting point

C2:
	mov eax, edi						; EAX = class struct
	call setSpeed						; set ghost speed

	popad								; restore registers
	ret									; return from procedure
Ghost_defaultPosition ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_move
; ______________________________________________________________________________
; The code that handles the movement of the ghost.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to a Pac-Man class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov ebx, OFFSET pacManStruct
;	call Ghost_move
;-------------------------------------------------------------------------------

Ghost_move PROC

	pushad								; save registers

	mov edi, eax						; EDI = class struct
	mov esi, ebx						; ESI = Pac-Man*

	call isGhostModeEnabled				; check if in scatter/chase mode
	cmp eax, TRUE						; if (enabled == TRUE)
	jne C1								; jump if not equal

	lea eax, [edi].Ghost.mMode			; EAX = &self->mMode
	call GhostMode_tick					; tick timer in scatter/chase mode

	cmp eax, TRUE						; if (ghostStateChanged == TRUE)
	jne C1								; jump if not equal

	mov eax, [edi].Ghost.mDirection		; EAX = ghost direction
	call Utils_reverseDirection			; reverse that direction
	mov [edi].Ghost.mDirection, eax		; save the reverse direction

C1:
	dec [edi].Ghost.mMoveCounter		; self->mMoveCounter--
	cmp [edi].Ghost.mMoveCounter, 0		; if (self->mMoveCounter > 0)
	jg Return							; jump if greater than

	mov eax, edi						; EAX = class struct
	call isGhostModeEnabled				; check if in scatter/chase mode

	cmp eax, TRUE						; if (enabled == TRUE)
	jne CElse							; jump if not equal

	lea eax, [edi].Ghost.mMode			; EAX = &self->mMode
	call GhostMode_state				; get ghost mode state

	cmp eax, GHOST_STATE_CHASE			; if (state == CHASE)
	jne C2								; jump if not equal

	mov eax, edi						; EAX = class struct
	mov ebx, esi						; EBX = Pac-Man*
	call modeChase						; chase mode
	jmp Done							; unconditional jump

C2:
	mov eax, edi						; EAX = class struct
	call modeScatter					; scatter mode
	jmp Done							; unconditional jump

CElse:
	cmp [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_PACING	; is pacing?
	je S1													; jump if equal

	cmp [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_EXITING	; is exiting?
	je S2													; jump if equal

	cmp [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_EATEN	; is eaten?
	je S3													; jump if equal

	jmp Default							; unconditional jump

S1:
	mov eax, edi						; EAX = class struct
	call modePacing						; pacing mode
	jmp Done							; unconditional jump

S2:
	mov eax, edi						; EAX = class struct
	call modeExiting					; exiting mode
	jmp Done							; unconditional jump

S3:
	mov eax, edi						; EAX = class struct
	call modeEaten						; eaten mode
	jmp Done							; unconditional jump

Default:
	mov eax, edi						; EAX = class struct
	call modeFrightened					; frightened mode

Done:
	mov eax, edi						; EAX = class struct
	call setSpeed						; set the ghost speed for next move

Return:
	popad								; restore registers
	ret									; return from procedure
Ghost_move ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_setVisible
; ______________________________________________________________________________
; Set the visibility for the ghost.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = TRUE if visible, FALSE otherwise
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov ebx, visible
;	call Ghost_setVisible
;-------------------------------------------------------------------------------

Ghost_setVisible PROC

	mov [eax].Ghost.mSprite.visible, ebx	; sprite.visible = EBX
	ret										; return from procedure
Ghost_setVisible ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_isEaten
; ______________________________________________________________________________
; Check to see if the ghost has been eaten.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = TRUE if eaten, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call Ghost_isEaten
;-------------------------------------------------------------------------------

Ghost_isEaten PROC

	cmp [eax].Ghost.mInterruptMode, GHOST_INTERRUPT_EATEN	; if (ghostEaten)
	jne C1													; jump if not equal

	mov eax, TRUE						; return TRUE
	jmp Return							; unconditional jump

C1:
	mov eax, FALSE						; return FALSE

Return:
	ret									; return from procedure
Ghost_isEaten ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_inGhostHouse
; ______________________________________________________________________________
; Check to see if the ghost is in the ghost house.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = TRUE if in ghost house, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call Ghost_inGhostHouse
;-------------------------------------------------------------------------------

Ghost_inGhostHouse PROC

	cmp [eax].Ghost.mInterruptMode, GHOST_INTERRUPT_PACING	; if (ghostPacing)
	jne C1													; jump if not equal

	mov eax, TRUE						; return TRUE
	jmp Return							; unconditional jump

C1:
	mov eax, FALSE						; return FALSE

Return:
	ret									; return from procedure
Ghost_inGhostHouse ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_ghostHouseTimer
; ______________________________________________________________________________
; Advance the timer to see if the ghost should leave the ghost house.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = TRUE if Pac-Man ate a dot, FALSE otherwise
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov ebx, ateDot
;	call Ghost_ghostHouseTimer
;-------------------------------------------------------------------------------

Ghost_ghostHouseTimer PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	lea eax, [edi].Ghost.mGhostRelease		; EAX = &self->mGhostRelease
	call GhostRelease_shouldReleaseGhost	; check if ghost should exit house

	cmp eax, TRUE							; if (shouldReleaseGhost == TRUE)
	jne Return								; jump if not equal

	mov [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_EXITING	; exit mode

Return:
	popad									; restore registers
	ret										; return from procedure
Ghost_ghostHouseTimer ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_blueTimeStart
; ______________________________________________________________________________
; Setup the ghost for blue time.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call Ghost_blueTimeStart
;-------------------------------------------------------------------------------

Ghost_blueTimeStart PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	lea eax, [edi].Ghost.mBlueTime			; EAX = &self->mBlueTime
	call GhostBlueTime_start				; start blue time

	mov [edi].Ghost.mIsFrightened, TRUE		; self->mIsFrightened = TRUE

	cmp [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_NONE	; in interrupt?
	jne Return												; jump if not equal

	mov eax, [edi].Ghost.mDirection			; EAX = ghost direction
	call Utils_reverseDirection				; reverse that direction
	mov [edi].Ghost.mDirection, eax			; save the reverse direction

Return:
	popad									; restore registers
	ret										; return from procedure
Ghost_blueTimeStart ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_blueTime
; ______________________________________________________________________________
; Process blue time for the ghost.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = TRUE if ghost is in blue time, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call Ghost_blueTime
;-------------------------------------------------------------------------------

Ghost_blueTime PROC

	pushad									; save registers
	mov edi, eax							; EDI = class struct

	lea eax, [edi].Ghost.mBlueTime			; EAX = &self->mBlueTime
	call GhostBlueTime_period				; process blue time
	push eax								; push blue time color on stack

	lea eax, [edi].Ghost.mBlueTime			; EAX = &self->mBlueTime
	call GhostBlueTime_isOn					; check if ghost in blue time

	mov returnValue, eax					; save isOn result in return value
	pop ebx									; pop blue time color off stack

	cmp eax, TRUE									; if (isOn == TRUE
	jne Return										; jump if not equal

	cmp [edi].Ghost.mSprite.character, GHOST_CHAR	; && character == GHOST)
	jne Return										; jump if not equal

	cmp ebx, BLUE_TIME_COLOR_DISPLAY_BLUE			; case DISPLAY_BLUE:
	je S1											; jump if equal

	cmp ebx, BLUE_TIME_COLOR_DISPLAY_WHITE			; case DISPLAY_WHITE:
	je S2											; jump if equal

	jmp Return										; unconditional jump

S1:
	mov [edi].Ghost.mSprite.attributes, GHOST_BLUE	; turn ghost blue
	jmp Return										; unconditional jump

S2:
	mov [edi].Ghost.mSprite.attributes, GHOST_WHITE	; turn ghost white

Return:
	popad											; restore registers

	mov eax, returnValue							; return isOn
	ret												; return from procedure
Ghost_blueTime ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_blueTimeStop
; ______________________________________________________________________________
; Stop blue time for the ghost.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	call Ghost_blueTimeStop
;-------------------------------------------------------------------------------

Ghost_blueTimeStop PROC

	pushad									; save registers

	cmp [eax].Ghost.mSprite.character, GHOST_CHAR	; if (character == GHOST)
	jne C1											; jump if not equal

	mov bx, [eax].Ghost.mAttributes			; BX = self->mAttributes
	mov [eax].Ghost.mSprite.attributes, bx	; restore original ghost color

C1:
	mov [eax].Ghost.mIsFrightened, FALSE	; self->mIsFrightened = FALSE

	lea eax, [eax].Ghost.mBlueTime			; EAX = &self->mBlueTime
	call GhostBlueTime_cancel				; cancel blue time for ghost

	popad									; restore registers
	ret										; return from procedure
Ghost_blueTimeStop ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Ghost_hitTest
; ______________________________________________________________________________
; Check to see if Pac-Man and ghost have collided.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to a Pac-Man class struct
;
; RETURNS
;	EAX = Hit Test constant
;
; EXAMPLE
;	mov eax, OFFSET ghostStruct
;	mov ebx, OFFSET pacManStruct
;	call Ghost_hitTest
;-------------------------------------------------------------------------------

Ghost_hitTest PROC

	pushad									; save registers

	cmp [eax].Ghost.mInterruptMode, GHOST_INTERRUPT_EATEN	; is ghost eaten?
	jne C1													; jump if not equal

	mov returnValue, HIT_TEST_NONE			; return NONE
	jmp Return								; unconditional jump

C1:
	mov edi, eax							; EDI = class struct
	mov eax, ebx							; EAX = Pac-Man*
	call PacMan_getPoint					; get Pac-Man position point

	lea ebx, [edi].Ghost.mSprite.charPoint	; EBX = &self->mSprite.point
	call Utils_pointsEqual					; check if points are equal

	mov returnValue, HIT_TEST_NONE			; return NONE

	cmp eax, TRUE							; if (pointsEqual == TRUE)
	jne Return								; jump if not equal

	cmp [edi].Ghost.mIsFrightened, TRUE		; if (self->mIsFrightened == TRUE)
	jne C2									; jump if not equal
	
	mov [edi].Ghost.mSprite.character, GHOST_EYES	; sprite.character = EYES
	mov [edi].Ghost.mSprite.attributes, WHITE		; sprite.attributes = WHITE
	mov [edi].Ghost.mInterruptMode, GHOST_INTERRUPT_EATEN	; start by pacing

	mov eax, [edi].Ghost.mDirection		; EAX = ghost direction
	call Utils_reverseDirection			; reverse that direction
	mov [edi].Ghost.mDirection, eax		; save the reverse direction

	mov eax, edi						; EAX = class struct
	call setSpeed						; set ghost speed

	mov eax, edi						; EAX = class struct
	call Ghost_blueTimeStop				; stop ghost blue time

	mov returnValue, HIT_TEST_GHOST_KILLED		; return GHOST_KILLED
	jmp Return									; unconditional jump

C2:
	mov returnValue, HIT_TEST_PAC_MAN_KILLED	; return PAC_MAN_KILLED

Return:
	popad								; restore registers

	mov eax, returnValue				; return Hit Test constant
	ret									; return from procedure
Ghost_hitTest ENDP

;-------------------------------------------------------------------------------

end

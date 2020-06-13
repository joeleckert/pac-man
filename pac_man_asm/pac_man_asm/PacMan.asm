
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE PacMan.inc
INCLUDE Defines.inc
INCLUDE Screen.inc
INCLUDE Utils.inc
INCLUDE Position.inc

;-------------------------------------------------------------------------------

TOTAL_DIRECTIONS EQU 4

;-------------------------------------------------------------------------------

.data
returnValue DWORD 0
index SDWORD 0
foundForward BOOL 0

directions DWORD DIRECTION_UP, DIRECTION_DOWN, DIRECTION_LEFT, DIRECTION_RIGHT
inputs DWORD TOTAL_DIRECTIONS DUP(0)

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_constructor
; ______________________________________________________________________________
; Initializes the Pac Man class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_constructor
;-------------------------------------------------------------------------------

PacMan_constructor PROC

	pushad											; save registers
	mov ebx, eax									; EBX = class struct

	mov [ebx].PacMan.mSprite.character, PAC_MAN		; character = PAC_MAN
	mov [ebx].PacMan.mSprite.attributes, YELLOW		; attributes = YELLOW
	mov [ebx].PacMan.mSprite.charPoint.x, 14		; starting x-position
	mov [ebx].PacMan.mSprite.charPoint.y, 18		; starting y-position
	mov [ebx].PacMan.mSprite.visible, FALSE			; don't display on screen

	mov [ebx].PacMan.mDirection, DIRECTION_LEFT		; default direction
	mov [ebx].PacMan.mMoveCounter, 0				; reset move counter
	mov [ebx].PacMan.mAwardedExtraGuy, FALSE		; didn't achieve extra guy

	lea eax, [ebx].PacMan.mKeys						; EAX = &self->mKeys
	call Utils_clearKeys							; clear keys

	lea eax, [ebx].PacMan.mLives					; EAX = &self->mLives
	call Lives_constructor							; call constructor

	lea eax, [ebx].PacMan.mLevel					; EAX = &self->mLevel
	call Level_constructor							; call constructor

	lea eax, [ebx].PacMan.mScore					; EAX = &self->mScore
	call Score_constructor							; call constructor

	lea eax, [ebx].PacMan.mBonusSymbol				; EAX = &self->mBonusSymbol
	call BonusSymbol_constructor					; call constructor

	lea eax, [ebx].PacMan.mSprite					; &self->mSprite
	call Screen_addSprite							; add sprite to screen

	popad											; restore registers
	ret												; return from procedure
PacMan_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_input
; ______________________________________________________________________________
; Processes the keyboard input for Pac-Man
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to a Keys struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	mov ebx, OFFSET keys
;	call PacMan_input
;-------------------------------------------------------------------------------

PacMan_input PROC

	pushad									; save registers

	mov ecx, [ebx].Keys.up					; ECX = source.up
	mov [eax].PacMan.mKeys.up, ecx			; destination.up = ECX

	mov ecx, [ebx].Keys.down				; ECX = source.down
	mov [eax].PacMan.mKeys.down, ecx		; destination.down = ECX

	mov ecx, [ebx].Keys.left				; ECX = source.left
	mov [eax].PacMan.mKeys.left, ecx		; destination.left = ECX

	mov ecx, [ebx].Keys.right				; ECX = source.right
	mov [eax].PacMan.mKeys.right, ecx		; destination.right = ECX

	mov ecx, [ebx].Keys.start				; ECX = source.start
	mov [eax].PacMan.mKeys.start, ecx		; destination.start = ECX

	call PacMan_processInput				; handle keyboard input

	popad									; restore registers
	ret										; return from procedure
PacMan_input ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_validMove
; ______________________________________________________________________________
; Checks if moving in the direction of the Direction constant is valid.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Direction constant
;
; RETURNS
;	EAX = TRUE if valid move, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	mov ebx, direction
;	call PacMan_validMove
;-------------------------------------------------------------------------------

PacMan_validMove PROC

	push eax								; push class struct on stack
	push ebx								; push Direction constant on stack

	lea eax, [eax].PacMan.mSprite.charPoint	; EAX = &self->mSprite.point
	mov ecx, OFFSET defaultSpots			; ECX = default valid move spots
	call Position_validMove					; check if move is valid

	cmp eax, TRUE							; if (Position_validMove() == TRUE)
	pop ebx									; pop Direction constant off stack
	pop eax									; pop class struct off stack
	jne C1									; jump if not equal

	mov [eax].PacMan.mDirection, ebx		; self->mDirection = direction
	mov eax, TRUE							; return TRUE
	jmp Return								; unconditional jump

C1:
	mov eax, FALSE							; return FALSE

Return:
	ret										; return from procedure
PacMan_validMove ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_keyDownInDirection
; ______________________________________________________________________________
; Checks if a keyboard button is down in the direction of the Direction
; constant.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Direction constant
;
; RETURNS
;	EAX = TRUE if key is down in the direction, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	mov ebx, direction
;	call PacMan_keyDownInDirection
;-------------------------------------------------------------------------------

PacMan_keyDownInDirection PROC

	cmp ebx, DIRECTION_UP				; if (direction == DIRECTION_UP)
	jne C1								; jump if not equal

	mov eax, [eax].PacMan.mKeys.up		; return self->mKeys.up
	jmp Return							; unconditional jump

C1:
	cmp ebx, DIRECTION_DOWN				; if (direction == DIRECTION_DOWN)
	jne C2								; jump if not equal

	mov eax, [eax].PacMan.mKeys.down	; return self->mKeys.down
	jmp Return							; unconditional jump

C2:
	cmp ebx, DIRECTION_LEFT				; if (direction == DIRECTION_LEFT)
	jne C3								; jump if not equal

	mov eax, [eax].PacMan.mKeys.left	; return self->mKeys.left
	jmp Return							; unconditional jump

C3:
	cmp ebx, DIRECTION_RIGHT			; if (direction == DIRECTION_RIGHT)
	jne C4								; jump if not equal

	mov eax, [eax].PacMan.mKeys.right	; return self->mKeys.right
	jmp Return							; unconditional jump

C4:
	mov eax, FALSE						; return FALSE

Return:
	ret									; return from procedure
PacMan_keyDownInDirection ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_processInput
; ______________________________________________________________________________
; Handle the keyboard input for Pac-Man.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_processInput
;-------------------------------------------------------------------------------

PacMan_processInput PROC
	
	pushad								; Save registers

	mov edi, eax						; EDI = class struct
	mov index, 0						; inputs array index
	mov foundForward, FALSE				; is keydown in direction moving?

	mov ebx, [edi].PacMan.mDirection	; EBX = current direction
	call PacMan_keyDownInDirection		; check if key down in direction in EBX

	cmp eax, TRUE						; if (keyDownInDirection() == TRUE)
	jne C1								; jump if not equal

	mov foundForward, TRUE				; key down in current direction

	mov eax, index						; EAX = inputs index 
	mov inputs[eax * TYPE inputs], ebx	; save current direction in inputs array
	inc index							; index++

C1:
	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_DIRECTIONS			; (ESI < TOTAL_DIRECTIONS)
	jge C2								; jump if greater than or equal

	mov eax, edi								; EAX = class struct
	mov ebx, directions[esi * TYPE directions]	; EBX = direction[ESI]
	call PacMan_keyDownInDirection				; check if key down in direction

	cmp eax, TRUE						; was key down in directions[ESI] ?
	jne L1_Next							; jump if not equal

	cmp [edi].PacMan.mDirection, ebx	; if (currentDirection != direction)
	je L1_Next							; jump if equal

	mov eax, index						; EAX = index
	mov inputs[eax * TYPE inputs], ebx	; inputs[index] = direction
	inc index							; index++

L1_Next:
	inc esi								; ESI++
	jmp L1								; unconditional jump

C2:
	cmp foundForward, TRUE				; if (foundForward == TRUE)
	jne C3								; jump if not equal

	mov eax, [edi].PacMan.mDirection	; EAX = currentDirection
	call Utils_reverseDirection			; EAX = reverseDirection

	mov esi, 0							; loop index

L2:
	cmp esi, index						; (ESI < index)
	jge C3								; jump if greater than or equal

	mov ebx, inputs[esi * TYPE inputs]	; EBX = inputs[ESI] 

	cmp eax, ebx						; if (reverse == inputs[ESI])
	jne L2_Next							; jump if not equal

	mov inputs[esi * TYPE inputs], DIRECTION_NONE	; remove reverse direction
	jmp C3											; unconditional jump
	
L2_Next:
	inc esi								; ESI++
	jmp L2								; unconditional jump

C3:
	mov esi, 0							; loop index

L3:
	cmp esi, index						; (ESI < index)
	jge Return							; jump if greater than or equal

	mov eax, edi						; EAX = class struct
	mov ebx, inputs[esi * TYPE inputs]	; EBX = inputs[ESI]
	call PacMan_validMove				; check if move is valid

	cmp eax, TRUE						; if (validMove() == TRUE)
	je Return							; jump if equal

L3_Next:
	inc esi								; ESI++
	jmp L3								; unconditional jump

Return:
	popad								; Restore registers
	ret									; return from procedure
PacMan_processInput ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_move
; ______________________________________________________________________________
; Controls how Pac-Man moves and at what speed.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = TRUE if blue time is on, FALSE otherwise
;
; RETURNS
;	EAX = Pac Man Mode constant
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	mov ebx, blueTime
;	call PacMan_move
;-------------------------------------------------------------------------------

PacMan_move PROC

	pushad									; save registers

	dec [eax].PacMan.mMoveCounter			; self->mMoveCounter--
	cmp [eax].PacMan.mMoveCounter, 0		; if (self->mMoveCounter > 0)
	jle C1									; jump if less than or equal

	mov eax, PAC_MAN_MODE_PENDING			; waiting to move
	jmp Return								; unconditional jump

C1:
	push ebx								; push blueTime on stack
	mov edi, eax							; EDI = class struct
	
	call PacMan_processInput				; handle keyboard input

	mov esi, PAC_MAN_MODE_NOT_EATING		; ESI = Pac Man Mode
	
	lea eax, [edi].PacMan.mSprite.charPoint	; EAX = &self->mSprite.point
	mov ebx, [edi].PacMan.mDirection		; EBX = direction constant
	mov ecx, OFFSET defaultSpots			; ECX = default valid move spots
	call Position_validMove					; check if move is valid

	cmp eax, TRUE							; if (Position_validMove() == TRUE)
	jne Done								; jump if not equal

	lea eax, [edi].PacMan.mSprite.charPoint	; EAX = &self->mSprite.point
	mov ebx, [edi].PacMan.mDirection		; EBX = direction constant
	call Position_movePoint					; move to that valid location

	mov eax, [edi].PacMan.mSprite.charPoint.x	; x-position of move
	mov ebx, [edi].PacMan.mSprite.charPoint.y	; y-position of move
	call Screen_getChar							; get the char at position

	cmp eax, DOT							; if (charValue == DOT)
	jne C2									; jump if not equal

	mov esi, PAC_MAN_MODE_EATING_DOT		; mode = EATING_DOT
	jmp C3									; unconditional jump

C2:
	cmp eax, ENERGIZER						; if (charValue == ENERGIZER)
	jne C3									; jump if not equal

	mov esi, PAC_MAN_MODE_EATING_ENERGIZER	; mode = EATING_ENERGIZER

C3:
	mov eax, [edi].PacMan.mSprite.charPoint.x	; x-position of move
	mov ebx, [edi].PacMan.mSprite.charPoint.y	; y-position of move
	mov cx, SPACE								; clear location
	call Screen_setChar							; set the char at position

Done:
	pop ebx									; pop blueTime off stack
	lea eax, [edi].PacMan.mSpeed			; EAX = &self->mSpeed
	call Speed_pacMan						; get Pac-Man speed

	mov [edi].PacMan.mMoveCounter, eax		; set move counter to speed
	mov eax, esi							; return mode

Return:
	mov returnValue, eax					; save Pac Man Mode constant
	popad									; restore registers

	mov eax, returnValue					; return Pac Man Mode constant
	ret										; return from procedure
PacMan_move ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_defaultPosition
; ______________________________________________________________________________
; The default setup for Pac-Man at the beginning of each level.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The current level
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	mov ebx, level
;	call PacMan_defaultPosition
;-------------------------------------------------------------------------------

PacMan_defaultPosition PROC

	pushad											; save registers
	mov ecx, eax									; ECX = class struct

	mov [ecx].PacMan.mSprite.character, PAC_MAN		; character = PAC_MAN
	mov [ecx].PacMan.mSprite.charPoint.x, 14		; starting x-position
	mov [ecx].PacMan.mSprite.charPoint.y, 18		; starting y-position

	lea eax, [ecx].PacMan.mSpeed					; EAX = &self->mSpeed
	call Speed_constructor							; call constructor

	mov [ecx].PacMan.mDirection, DIRECTION_LEFT		; default direction

	mov ebx, FALSE									; EBX = FALSE
	call Speed_pacMan								; get Pac-Man speed

	mov [ecx].PacMan.mMoveCounter, eax				; save Pac-Man speed

	lea eax, [ecx].PacMan.mKeys						; EAX = &self->mKeys
	call Utils_clearKeys							; clear keys
	
	popad											; restore registers
	ret												; return from procedure
PacMan_defaultPosition ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_deadPacMan
; ______________________________________________________________________________
; Set the character to be used when Pac-Man has died.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_deadPacMan
;-------------------------------------------------------------------------------

PacMan_deadPacMan PROC

	mov [eax].PacMan.mSprite.character, PAC_MAN_DEAD	; character = PAC_MAN
	ret													; return from procedure
PacMan_deadPacMan ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_setVisible
; ______________________________________________________________________________
; Set the visibility for Pac-Man.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = TRUE if visible, FALSE otherwise
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	mov ebx, visible
;	call PacMan_setVisible
;-------------------------------------------------------------------------------

PacMan_setVisible PROC

	mov [eax].PacMan.mSprite.visible, ebx	; show or hide Pac-Man
	ret										; return from procedure
PacMan_setVisible ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_didEarnExtraGuy
; ______________________________________________________________________________
; Check to see if an extra guy should be awarded to the player.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The required score for an extra guy
;
; RETURNS
;	EAX = TRUE if given an extra guy, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	mov ebx, requiredScore
;	call PacMan_didEarnExtraGuy
;-------------------------------------------------------------------------------

PacMan_didEarnExtraGuy PROC

	mov ecx, eax								; ECX = class struct

	cmp [ecx].PacMan.mAwardedExtraGuy, TRUE		; if (gotExtraGuy == TRUE)
	jne C1										; jump if not equal

	mov eax, FALSE								; return FALSE
	jmp Return									; unconditional jump

C1:
	lea eax, [ecx].PacMan.mScore				; EAX = &self->mScore
	call Score_getScore							; get score

	cmp eax, ebx								; if (score >= requiredScore)
	jl C2										; jump if less than

	mov [ecx].PacMan.mAwardedExtraGuy, TRUE		; gotExtraGuy = TRUE
	push ecx									; push class struct on stack

	lea eax, [ecx].PacMan.mLives				; EAX = &self->mLives
	call Lives_extraGuy							; award extra guy
	pop ecx										; pop class struct on stack

C2:
	mov eax, [ecx].PacMan.mAwardedExtraGuy		; return self->mAwardedExtraGuy

Return:
	ret											; return from procedure
PacMan_didEarnExtraGuy ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_getPoint
; ______________________________________________________________________________
; Get the point that has the location of Pac-Man on the game map.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = Pointer to the location point
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_getPoint
;-------------------------------------------------------------------------------

PacMan_getPoint PROC

	lea eax, [eax].PacMan.mSprite.charPoint		; EAX = &self->mSprite.point
	ret											; return from procedure
PacMan_getPoint ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_getLives
; ______________________________________________________________________________
; Get a pointer to the Lives class struct.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = Pointer to the Lives class struct
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_getLives
;-------------------------------------------------------------------------------

PacMan_getLives PROC

	lea eax, [eax].PacMan.mLives		; EAX = &self->mLives
	ret									; return from procedure
PacMan_getLives ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_getLevel
; ______________________________________________________________________________
; Get a pointer to the Level class struct.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = Pointer to the Level class struct
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_getLevel
;-------------------------------------------------------------------------------

PacMan_getLevel PROC

	lea eax, [eax].PacMan.mLevel		; EAX = &self->mLevel
	ret									; return from procedure
PacMan_getLevel ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_getScore
; ______________________________________________________________________________
; Get a pointer to the Score class struct.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = Pointer to the Score class struct
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_getScore
;-------------------------------------------------------------------------------

PacMan_getScore PROC

	lea eax, [eax].PacMan.mScore		; EAX = &self->mScore
	ret									; return from procedure
PacMan_getScore ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_getDirection
; ______________________________________________________________________________
; Get the direction that Pac-Man is moving in.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = Direction constant
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_getDirection
;-------------------------------------------------------------------------------

PacMan_getDirection PROC

	mov eax, [eax].PacMan.mDirection	; EAX = direction constant
	ret									; return from procedure
PacMan_getDirection ENDP

;-------------------------------------------------------------------------------
; PROCEDURE PacMan_getBonusSymbol
; ______________________________________________________________________________
; Get a pointer to the Bonus Symbol class struct.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = Pointer to the Bonus Symbol class struct
;
; EXAMPLE
;	mov eax, OFFSET pacManStruct
;	call PacMan_getBonusSymbol
;-------------------------------------------------------------------------------

PacMan_getBonusSymbol PROC

	lea eax, [eax].PacMan.mBonusSymbol	; EAX = &self->mBonusSymbol
	ret									; return from procedure
PacMan_getBonusSymbol ENDP

;-------------------------------------------------------------------------------

end

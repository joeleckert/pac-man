
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Score.inc
INCLUDE Defines.inc
INCLUDE Utils.inc
INCLUDE Screen.inc

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Score_constructor
; ______________________________________________________________________________
; Initializes the Score class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	call Score_constructor
;-------------------------------------------------------------------------------

Score_constructor PROC

	mov [eax].Score.mScore, 0				; Score value = 0
	mov [eax].Score.mScoreX, 0				; Score x-position = 0
	mov [eax].Score.mScoreY, 0				; Score y-position = 0

	mov [eax].Score.mTitle[0], 0			; Empty title string
	mov [eax].Score.mTitleX, 0				; Title x-position = 0
	mov [eax].Score.mTitleY, 0				; Title y-position = 0
	mov [eax].Score.mTitleAttributes, BLACK	; Title color = BLACK
	mov [eax].Score.mFlashTitle, FALSE		; Don't flash title

	mov [eax].Score.mTimer, 0				; Reset timer to 0

	ret										; return from procedure
Score_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_getScore
; ______________________________________________________________________________
; Gets the player's score.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = The player's score
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	call Score_getScore
;-------------------------------------------------------------------------------

Score_getScore PROC

	mov eax, [eax].Score.mScore			; EAX = player's score
	ret									; return from procedure
Score_getScore ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_reset
; ______________________________________________________________________________
; Resets the player's score.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	call Score_reset
;-------------------------------------------------------------------------------

Score_reset PROC

	mov [eax].Score.mScore, 0			; Reset player's score
	ret									; return from procedure
Score_reset ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_add
; ______________________________________________________________________________
; Adds to the player's score.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Points to add to the score
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	mov ebx, points
;	call Score_add
;-------------------------------------------------------------------------------

Score_add PROC

	cmp ebx, 0							; if (EBX < 0)
	jl L1								; jump if less than

	add [eax].Score.mScore, ebx			; self->mScore += points

L1:
	ret									; return from procedure
Score_add ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_setHighScore
; ______________________________________________________________________________
; Sets the high score for all players.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to the Score class of the player
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	mov ebx, OFFSET playerScoreStruct
;	call Score_setHighScore
;-------------------------------------------------------------------------------

Score_setHighScore PROC

	mov edx, [ebx].Score.mScore			; EDX = player->mScore

	cmp edx, [eax].Score.mScore			; if (player->mScore > self->mScore)
	jle L1								; jump if less than or equal

	mov [eax].Score.mScore, edx			; self->mScore = player->mScore

L1:
	ret									; return from procedure
Score_setHighScore ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_setTitle
; ______________________________________________________________________________
; Sets the ASCII title string for the score.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = x coordinate
;	ECX = y coordinate
;	DX = attributes for text
;	ESI = Pointer to ASCII text string
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	mov ebx, xPosition
;	mov ecx, yPosition
;	mov dx, attributes
;	mov esi, OFFSET text
;	call Score_setTitle
;-------------------------------------------------------------------------------

Score_setTitle PROC

	mov [eax].Score.mTitleX, ebx			; self->mTitleX = x
	mov [eax].Score.mTitleY, ecx			; self->mTitleY = y
	mov [eax].Score.mTitleAttributes, dx	; self->mTitleAttributes = attrib

	mov edx, 0								; loop index

BeginLoop:
	cmp edx, TITLE_SIZE						; EDX < TITLE_SIZE
	jge EndLoop								; jump if greater than or equal

	mov bl, [esi]							; BL = *title
	cmp bl, NULL							; if (character == NULL)
	je EndLoop								; jump if equal

	mov [eax].Score.mTitle[edx], bl			; self->mTitle[i] = character

	inc esi									; title++
	inc edx									; index++
	jmp BeginLoop							; unconditional jump

EndLoop:
	mov [eax].Score.mTitle[edx], NULL		; self->mTitle[i] = NULL
	ret										; return from procedure
Score_setTitle ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_shouldFlashTitle
; ______________________________________________________________________________
; Determines if the title will flash or not.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Boolean value, TRUE if you want the title to flash, FALSE otherwise
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	mov ebx, flashTitle
;	call Score_shouldFlashTitle
;-------------------------------------------------------------------------------

Score_shouldFlashTitle PROC

	mov [eax].Score.mFlashTitle, ebx	; self->mFlashTitle = flashTitle
	ret									; return from procedure
Score_shouldFlashTitle ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_setLocation
; ______________________________________________________________________________
; Determines the coordinates of the score text on screen.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = x coordinate
;	ECX = y coordinate
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	mov ebx, xPosition
;	mov ecx, yPosition
;	call Score_setLocation
;-------------------------------------------------------------------------------

Score_setLocation PROC

	mov [eax].Score.mScoreX, ebx		; self->mScoreX = x
	mov [eax].Score.mScoreY, ecx		; self->mScoreY = y
	ret									; return from procedure
Score_setLocation ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Score_drawScreen
; ______________________________________________________________________________
; Draws the title and score to the screen.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreStruct
;	call Score_drawScreen
;-------------------------------------------------------------------------------

Score_drawScreen PROC

	push eax								; push class struct on stack
	mov esi, [eax].Score.mScore				; ESI = score
	mov ebx, [eax].Score.mScoreY			; EBX = y-value
	mov eax, [eax].Score.mScoreX			; EAX = x-value
	mov edi, 2								; EDI = minimum_digits

BeginLoop:
	cmp esi, 0								; (ESI > 0)
	jg J1									; jump if greater than

	cmp edi, 0								; || (EDI > 0)
	jle EndLoop								; jump if less than or equal

J1:
	push eax								; push x-value on stack
	mov eax, esi							; EAX = score

	mov edx, 0								; Clear remainder
	mov ecx, 10								; Set the divisor
	idiv ecx								; Divide by 10

	mov esi, eax							; score /= 10 
	mov eax, edx							; score % 10
	call Utils_digitToChar					; EAX = character digit

	mov cx, ax								; CX = character digit
	pop eax									; pop x-value off stack
	call Screen_setChar						; draw character to screen

	mov cx, WHITE							; attribute to set
	call Screen_setAttr						; draw attribute to screen

	dec edi									; minimum_digits--
	dec eax									; x--
	jmp BeginLoop							; unconditional jump

EndLoop:
	pop edi									; pop class struct on stack
	dec [edi].Score.mTimer					; self->mTimer--

	cmp [edi].Score.mTimer, 0				; if (self->mTimer > 0)
	jg Return								; return

	mov [edi].Score.mTimer, 20				; self->mTimer = 20
	mov eax, [edi].Score.mTitleX			; x = self->mTitleX
	mov ebx, [edi].Score.mTitleY			; y = self->mTitleY
	mov dx, BLACK							; attributes = BLACK

	cmp [edi].Score.mFlashTitle, TRUE		; if (self->mFlashTitle)
	jne L1									; jump if not equal

	call Screen_getAttr						; get attributes at (x, y)
	cmp ax, dx								; if (AX == attributes)
	jne L2									; jump if not equal

L1:
	mov dx, [edi].Score.mTitleAttributes	; attributes = self->mTitleAttr

L2:
	mov eax, [edi].Score.mTitleX			; x = self->mTitleX
	mov ebx, [edi].Score.mTitleY			; y = self->mTitleY
	mov esi, 0								; loop index

BeginForLoop:
	cmp esi, TITLE_SIZE						; (ESI < TITLE_SIZE)
	jge Return								; jump if greater than or equal

	movzx ecx, [edi].Score.mTitle[esi]		; character = self->mTitle[i]
	cmp cl, NULL							; if (character == NULL)
	je Return								; jump if equal

	call Screen_setChar						; set character to screen

	mov cx, dx								; CX = attributes
	call Screen_setAttr						; set attributes to screen

	inc eax									; x++
	inc esi									; index++
	jmp BeginForLoop						; unconditional jump

Return:
	ret										; return from procedure
Score_drawScreen ENDP

;-------------------------------------------------------------------------------

end

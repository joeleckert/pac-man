
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Screen.inc
INCLUDE Structs.inc
INCLUDE Defines.inc
INCLUDE WinApi.inc

;-------------------------------------------------------------------------------

BUFFER_SIZE EQU SCREEN_WIDTH * SCREEN_HEIGHT

;-------------------------------------------------------------------------------

.data
screen HANDLE 0
screenRect SMALL_RECT <0, 0, SCREEN_WIDTH, SCREEN_HEIGHT>
buffer CHAR_INFO BUFFER_SIZE DUP(<>)
output CHAR_INFO BUFFER_SIZE DUP(<>)
sprites DWORD MAX_SPRITES DUP(0)
spritesSize DWORD 0
bufferValue WORD 0

bufferIndexError BYTE "buffer index not valid", 0

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE isValidScreenPosition
; ______________________________________________________________________________
; Checks to see if the x and y coordinates are valid screen positions.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;
; RETURNS
;	EAX = Returns a boolean. TRUE if valid position, FALSE otherwise
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	call isValidScreenPosition
;-------------------------------------------------------------------------------

isValidScreenPosition PROC

	cmp eax, 0							; if (EAX < 0)
	jl L1								; jump if less than
	
	cmp eax, SCREEN_WIDTH				; if (EAX >= SCREEN_WIDTH)
	jge L1								; jump if greater than or equal

	cmp ebx, 0							; if (EBX < 0)
	jl L1								; jump if less than
	
	cmp ebx, SCREEN_HEIGHT				; if (EBX >= SCREEN_HEIGHT)
	jge L1								; jump if greater than or equal

	mov eax, TRUE						; return TRUE
	jmp L2								; unconditional jump

L1:
	mov eax, FALSE						; return FALSE

L2:
	ret									; return from procedure
isValidScreenPosition ENDP

;-------------------------------------------------------------------------------
; PROCEDURE bufferIndex
; ______________________________________________________________________________
; Converts valid x and y coordinates to a buffer index offset.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;
; RETURNS
;	EDI = Returns a SDWORD offset to the location in the buffer
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	call bufferIndex
;-------------------------------------------------------------------------------

bufferIndex PROC

	push eax							; push x coordinate on stack
	push ebx							; push y coordinate on stack

	call isValidScreenPosition			; check if x and y are valid positions
	cmp eax, FALSE						; if (EAX == FALSE)
	jne L1								; jump if not equal

	mov eax, OFFSET bufferIndexError	; EAX = pointer to bufferIndexError
	call Win32_messageBox				; display error message

	pop eax								; pop bad y coordinate
	pop eax								; pop bad x coordinate
	mov edi, 0							; return 0
	jmp L2								; unconditional jump

L1:
	pop eax								; pop y coordinate
	mov ecx, TYPE buffer				; ECX = sizeof(buffer)
	imul ecx							; EAX = y * sizeof(buffer)

	mov ecx, SCREEN_WIDTH				; ECX = SCREEN_WIDTH
	imul ecx							; EAX *= SCREEN_WIDTH

	mov edi, eax						; save result into EDI

	pop eax								; pop x coordinate
	mov ecx, TYPE buffer				; ECX = sizeof(buffer)
	imul ecx							; EAX = x * sizeof(buffer)

	add edi, eax						; add result to EDI

L2:
	ret									; return from procedure
bufferIndex ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_constructor
; ______________________________________________________________________________
; Initializes the screen for output.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Screen_constructor
;-------------------------------------------------------------------------------

Screen_constructor PROC
	pushad								; save registers

	mov eax, STD_OUTPUT_HANDLE			; EAX = handle type
	call Win32_getHandle				; get handle to output
	mov screen, eax						; save handle to variable

	mov spritesSize, 0					; clear spritesSize

	popad								; restore registers
	ret									; return from procedure
Screen_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_addSprite
; ______________________________________________________________________________
; Adds a sprite to the screen.
;
; PARAMETERS
;	EAX = Pointer to a Sprite struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET sprite
;	call Screen_addSprite
;-------------------------------------------------------------------------------

Screen_addSprite PROC
	pushad								; save registers

	cmp spritesSize, MAX_SPRITES		; if (spritesSize >= MAX_SPRITES)
	jae Return							; jump if above or equal

L1:
	push eax							; push Sprite*

	mov eax, spritesSize				; EAX = spritesSize
	mov ecx, TYPE sprites				; ECX = sizeof(sprites)
	mul ecx								; EAX = index location

	mov esi, eax						; save index location to ESI
	pop eax								; pop Sprite*

	mov sprites[esi], eax				; save Sprite* to sprites array
	inc spritesSize						; spritesSize++

Return:
	popad								; restore registers
	ret									; return from procedure
Screen_addSprite ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_getChar
; ______________________________________________________________________________
; Gets a character from the background buffer at the x and y position.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;
; RETURNS
;	AX = The character at the x and y position
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	call Screen_getChar
;-------------------------------------------------------------------------------

Screen_getChar PROC
	pushad											; save registers
	
	call bufferIndex								; get index location
	mov ax, buffer[edi].CHAR_INFO.Char.UnicodeChar	; AX = character
	mov bufferValue, ax								; Save character

	popad											; restore registers
	mov ax, bufferValue								; return character in AX
	ret												; return from procedure
Screen_getChar ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_getAttr
; ______________________________________________________________________________
; Gets the attributes from the background buffer at the x and y position.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;
; RETURNS
;	AX = The attributes at the x and y position
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	call Screen_getAttr
;-------------------------------------------------------------------------------

Screen_getAttr PROC
	pushad											; save registers

	call bufferIndex								; get index location
	mov ax, buffer[edi].CHAR_INFO.Attributes		; AX = attributes
	mov bufferValue, ax								; Save attributes

	popad											; restore registers
	mov ax, bufferValue								; return attributes in AX
	ret												; return from procedure
Screen_getAttr ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_setChar
; ______________________________________________________________________________
; Sets a character to the background buffer at the x and y position.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;	CX = character to set to background buffer
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	mov cx, character
;	call Screen_setChar
;-------------------------------------------------------------------------------

Screen_setChar PROC
	pushad											; save registers

	push cx											; push character to stack
	call bufferIndex								; get index location

	pop cx											; pop character from stack
	mov buffer[edi].CHAR_INFO.Char.UnicodeChar, cx	; set character to buffer

	popad											; restore registers
	ret												; return from procedure
Screen_setChar ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_setAttr
; ______________________________________________________________________________
; Sets the attributes to the background buffer at the x and y position.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;	CX = attributes to set to background buffer
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	mov cx, attributes
;	call Screen_setAttr
;-------------------------------------------------------------------------------

Screen_setAttr PROC
	pushad											; save registers

	push cx											; push attributes to stack
	call bufferIndex								; get index location

	pop cx											; pop attributes from stack
	mov buffer[edi].CHAR_INFO.Attributes, cx		; set attributes to buffer

	popad											; restore registers
	ret												; return from procedure
Screen_setAttr ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_setScreenText
; ______________________________________________________________________________
; Sets the ASCII text string to the background buffer at the x and y position.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;	DX = attributes for text
;	ESI = Pointer to ASCII text string
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	mov dx, attributes
;	mov esi, OFFSET text
;	call Screen_setScreenText
;-------------------------------------------------------------------------------

Screen_setScreenText PROC
	pushad								; save registers

L1:
	mov cl, [esi]						; get a character from string in ESI
	cmp cl, NULL						; if (CL == NULL)
	je Return							; jump if equal

	push eax							; push x coordinate on stack
	push dx								; push attributes on stack

	mov ch, 0							; clear upper byte of unicode character
	call Screen_setChar					; set character to buffer

	pop dx								; pop attributes off stack
	pop eax								; pop x coordinate off stack

	push eax							; push x coordinate on stack
	push dx								; push attributes on stack

	mov cx, dx							; CX = attributes for text
	call Screen_setAttr					; set attributes to buffer

	pop dx								; pop attributes off stack
	pop eax								; pop x coordinate off stack

	inc eax								; x++
	inc esi								; move to next character offset
	jmp L1								; unconditional jump

Return:
	popad								; restore registers
	ret									; return from procedure
Screen_setScreenText ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_clearScreenText
; ______________________________________________________________________________
; Clears the background buffer at the x and y position.
;
; PARAMETERS
;	EAX = x coordinate
;	EBX = y coordinate
;	ESI = count of characters to clear
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, xPosition
;	mov ebx, yPosition
;	mov esi, count
;	call Screen_clearScreenText
;-------------------------------------------------------------------------------

Screen_clearScreenText PROC
	pushad								; save registers
	mov ecx, 0							; loop counter

L1:
	cmp ecx, esi						; if (ECX < ESI)
	jae Return							; jump if above or equal

	push eax							; push x coordinate on stack
	push ecx							; push loop counter on stack

	mov ecx, SPACE						; ECX = ' ' <-- space character
	call Screen_setChar					; set character to buffer

	pop ecx								; pop loop counter off stack
	pop eax								; pop x coordinate off stack

	push eax							; push x coordinate on stack
	push ecx							; push loop counter on stack

	mov ecx, BLACK						; ECX = BLACK color
	call Screen_setAttr					; set attributes to buffer

	pop ecx								; pop loop counter off stack
	pop eax								; pop x coordinate off stack

	inc eax								; x++
	inc ecx								; ECX++
	jmp L1								; unconditional jump

Return:
	popad								; restore registers
	ret									; return from procedure
Screen_clearScreenText ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_blitScreen
; ______________________________________________________________________________
; Copy character and attribute arrays to the output buffer.
;
; PARAMETERS
;	EAX = Pointer to a WORD array of characters
;	EBX = Pointer to a WORD array of attributes
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET gameMap
;	mov ebx, OFFSET gameMapColors
;	call Screen_blitScreen
;-------------------------------------------------------------------------------

Screen_blitScreen PROC
	pushad											; save registers
	mov ecx, 0										; loop counter
	mov esi, 0										; index register

L1:
	cmp ecx, BUFFER_SIZE							; (ECX < BUFFER_SIZE)
	jae Return										; jump if above or equal

	mov dx, [eax]									; get character from array
	mov buffer[esi].CHAR_INFO.Char.UnicodeChar, dx	; set character to buffer

	mov dx, [ebx]									; get attribute from array
	mov buffer[esi].CHAR_INFO.Attributes, dx		; set attribute to buffer

	add eax, TYPE WORD								; move to next character
	add ebx, TYPE WORD								; move to next attribute
	add esi, TYPE CHAR_INFO							; move to next CHAR_INFO
	inc ecx											; ECX++
	jmp L1											; unconditional jump

Return:
	popad											; restore registers
	ret												; return from procedure
Screen_blitScreen ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_clearScreen
; ______________________________________________________________________________
; Clears the screen buffer.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Screen_clearScreen
;-------------------------------------------------------------------------------

Screen_clearScreen PROC
	pushad											; save registers
	mov eax, 0										; loop counter
	mov esi, 0										; index register

L1:
	cmp eax, BUFFER_SIZE							; (EAX < BUFFER_SIZE)
	jae Return										; jump if above or equal

	mov buffer[esi].CHAR_INFO.Char.UnicodeChar, 0	; clear character
	mov buffer[esi].CHAR_INFO.Attributes, 0			; clear attributes

	add esi, TYPE CHAR_INFO							; move to next CHAR_INFO
	inc eax											; EAX++
	jmp L1											; unconditional jump

Return:
	popad											; restore registers
	ret												; return from procedure
Screen_clearScreen ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Screen_drawScreen
; ______________________________________________________________________________
; Draws the sprites and background characters to the screen.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Screen_drawScreen
;-------------------------------------------------------------------------------

Screen_drawScreen PROC
	pushad											; save registers
	mov eax, 0										; loop counter
	mov esi, 0										; index register

L1:
	cmp eax, BUFFER_SIZE							; (EAX < BUFFER_SIZE)
	jae L1_Exit										; jump if above or equal

	mov bx, buffer[esi].CHAR_INFO.Char.UnicodeChar	; get character from buffer
	mov cx, buffer[esi].CHAR_INFO.Attributes		; get attribute from buffer

	mov output[esi].CHAR_INFO.Char.UnicodeChar, bx 	; set character to output
	mov output[esi].CHAR_INFO.Attributes, cx 		; set attribute to output

	add esi, TYPE CHAR_INFO							; move to next CHAR_INFO
	inc eax											; EAX++
	jmp L1											; unconditional jump

L1_Exit:
	mov eax, 0										; loop counter
	mov esi, 0										; index register

L2:
	cmp eax, spritesSize							; (EAX < spritesSize)
	jae L2_Exit										; jump if above or equal

	mov ebx, sprites[esi]							; EBX = Sprite*
	cmp [ebx].Sprite.visible, TRUE					; if (sprite->visible)
	jne L2_Next										; jump if not equal

	push eax										; push loop counter
	push ebx										; push Sprite*
	push esi										; push index register

	mov eax, [ebx].Sprite.charPoint.x				; EAX = sprite->point.x
	mov ebx, [ebx].Sprite.charPoint.y				; EBX = sprite->point.y
	call bufferIndex								; EDI = buffer index offset

	pop esi											; pop index register
	pop ebx											; pop Sprite*
	pop eax											; pop loop counter

	mov cx, [ebx].Sprite.character					; CX = sprite->character
	mov dx, [ebx].Sprite.attributes					; DX = sprite->attributes

	mov output[edi].CHAR_INFO.Char.UnicodeChar, cx	; set character to output
	mov output[edi].CHAR_INFO.Attributes, dx		; set attribute to output

L2_Next:
	add esi, TYPE DWORD								; move to next Sprite*
	inc eax											; EAX++
	jmp L2											; unconditional jump

L2_Exit:
	mov eax, screen									; EAX = output handle
	mov ebx, OFFSET output							; EBX = output CHAR_INFO
	mov ecx, OFFSET screenRect						; ECX = output rectangle
	call Win32_writeBuffer							; write buffer to screen

	mov eax, screen									; EAX = output handle
	call Win32_hideCursor							; hide screen cursor

	popad											; restore registers
	ret												; return from procedure
Screen_drawScreen ENDP

;-------------------------------------------------------------------------------

end

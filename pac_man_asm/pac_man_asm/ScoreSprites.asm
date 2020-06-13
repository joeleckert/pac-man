
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE ScoreSprites.inc
INCLUDE Defines.inc
INCLUDE Screen.inc
INCLUDE Utils.inc

;-------------------------------------------------------------------------------

.data
basePoint Point <>
lastDigitIndex DWORD 0

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE ScoreSprites_constructor
; ______________________________________________________________________________
; Initializes the Score Sprites class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	BX = attributes for the sprites
;	ECX = On screen duration
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreSpritesStruct
;	mov bx, attributes
;	mov ecx, SECONDS_2
;	call ScoreSprites_constructor
;-------------------------------------------------------------------------------

ScoreSprites_constructor PROC

	mov [eax].ScoreSprites.mTimer, 0		; self->mTimer = 0
	mov [eax].ScoreSprites.mDuration, ecx	; self->mDuration = duration

	mov ecx, eax							; ECX = class struct
	mov esi, 0								; loop index

L1:
	cmp esi, TOTAL_NUMBERS					; (ESI < TOTAL_NUMBERS)
	jge Return								; jump if greater than or equal

	mov eax, TYPE Sprite					; EAX = sizeof(Sprite)
	imul esi								; EAX *= loop index
	lea edx, [ecx].ScoreSprites.mSprites	; EDX = address of sprites array
	add eax, edx							; add the offset to the address

	mov [eax].Sprite.character, SPACE		; blank symbol
	mov [eax].Sprite.attributes, bx			; BX = attributes
	mov [eax].Sprite.charPoint.x, 0			; default x-position
	mov [eax].Sprite.charPoint.y, 0			; default y-position
	mov [eax].Sprite.visible, FALSE			; don't display on screen

	call Screen_addSprite					; add to screen sprites

	inc esi									; loop index++
	jmp L1									; unconditional jump

Return:
	ret										; return from procedure
ScoreSprites_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE ScoreSprites_reset
; ______________________________________________________________________________
; Hide the score sprites from the game screen.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreSpritesStruct
;	call ScoreSprites_reset
;-------------------------------------------------------------------------------

ScoreSprites_reset PROC

	mov ecx, eax							; ECX = class struct
	mov esi, 0								; loop index

L1:
	cmp esi, TOTAL_NUMBERS					; (ESI < TOTAL_NUMBERS)
	jge Return								; jump if greater than or equal

	mov eax, TYPE Sprite					; EAX = sizeof(Sprite)
	imul esi								; EAX *= loop index
	lea edx, [ecx].ScoreSprites.mSprites	; EDX = address of sprites array
	add eax, edx							; add the offset to the address

	mov [eax].Sprite.visible, FALSE			; don't display on screen

	inc esi									; loop index++
	jmp L1									; unconditional jump

Return:
	ret										; return from procedure
ScoreSprites_reset ENDP

;-------------------------------------------------------------------------------
; PROCEDURE ScoreSprites_setLocation
; ______________________________________________________________________________
; Positions the score sprites on the game map.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer the starting location point
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreSpritesStruct
;	mov ebx, OFFSET point
;	call ScoreSprites_setLocation
;-------------------------------------------------------------------------------

ScoreSprites_setLocation PROC
	
	mov ecx, eax							; ECX = class struct

	mov eax, OFFSET basePoint				; destination point
	call Utils_copyPoint					; copy EBX point into basePoint

	cmp basePoint.x, 0						; if (basePoint.x < 0)
	jge C1									; jump if greater than or equal

	mov basePoint.x, 0						; basePoint.x = 0

C1:
	mov esi, 0								; loop index

L1:
	cmp esi, TOTAL_NUMBERS					; (ESI < TOTAL_NUMBERS)
	jge Return								; jump if greater than or equal

	mov eax, TYPE Sprite					; EAX = sizeof(Sprite)
	imul esi								; EAX *= loop index
	lea edx, [ecx].ScoreSprites.mSprites	; EDX = address of sprites array
	add eax, edx							; add the offset to the address

	lea eax, [eax].Sprite.charPoint			; destination point
	mov ebx, OFFSET basePoint				; source point
	call Utils_copyPoint					; copy basePoint into sprite point
	inc basePoint.x							; basePoint.x++

	inc esi									; loop index++
	jmp L1									; unconditional jump

Return:
	ret										; return from procedure
ScoreSprites_setLocation ENDP

;-------------------------------------------------------------------------------
; PROCEDURE ScoreSprites_setValue
; ______________________________________________________________________________
; The numerical value that the score sprites will display. (Range: 0 - 9999)
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The number for the score sprites to display
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreSpritesStruct
;	mov ebx, scoreNumber
;	call ScoreSprites_setValue
;-------------------------------------------------------------------------------

ScoreSprites_setValue PROC

	mov lastDigitIndex, 0					; index of last digit to display

	cmp ebx, 1000							; if (value < 1000)
	jge C1									; jump if greater than or equal

	mov lastDigitIndex, 1					; don't display digit at index 0

C1:
	mov ecx, eax							; ECX = class struct
	mov eax, ebx							; EAX = number to display
	mov ebx, 10								; Set the divisor to 10

	mov esi, TOTAL_NUMBERS					; loop index
	dec esi									; ESI = TOTAL_NUMBERS - 1

L1:
	cmp esi, 0								; (ESI >= 0)
	jl Done									; jump if less than

	push eax								; push number to display on stack

	mov eax, TYPE Sprite					; EAX = sizeof(Sprite)
	imul esi								; EAX *= loop index
	lea edi, [ecx].ScoreSprites.mSprites	; EDI = address of sprites array
	add edi, eax							; add the offset to the address

	pop eax									; pop number to display off stack

	mov edx, 0								; Clear remainder
	idiv ebx								; Divide number to display by 10

	xchg eax, edx							; EAX = num % 10 / EDX = num /= 10
	call Utils_digitToChar					; convert digit in EAX to char

	mov [edi].Sprite.character, ax			; set char digit to sprite
	mov eax, edx							; EAX = num / 10

	cmp esi, lastDigitIndex					; if (ESI < lastDigitIndex)
	jge C2									; jump if greater than or equal

	mov [edi].Sprite.visible, FALSE			; don't display this sprite
	jmp Next								; unconditional jump

C2:
	mov [edi].Sprite.visible, TRUE			; display this sprite

Next:
	dec esi									; loop index--
	jmp L1									; unconditional jump

Done:
	mov edi, [ecx].ScoreSprites.mDuration	; EDI = self->mDuration
	mov [ecx].ScoreSprites.mTimer, edi		; self->mTimer = EDI
	ret										; return from procedure
ScoreSprites_setValue ENDP

;-------------------------------------------------------------------------------
; PROCEDURE ScoreSprites_drawScreen
; ______________________________________________________________________________
; Draws the score sprites to the screen.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET scoreSpritesStruct
;	call ScoreSprites_drawScreen
;-------------------------------------------------------------------------------

ScoreSprites_drawScreen PROC

	mov ecx, eax							; ECX = class struct

	mov eax, TYPE Sprite					; EAX = sizeof(Sprite)
	mov esi, TOTAL_NUMBERS					; ESI = TOTAL_NUMBERS
	dec esi									; ESI--
	imul esi								; EAX *= TOTAL_NUMBERS - 1

	lea edx, [ecx].ScoreSprites.mSprites	; EDX = address of sprites array
	add eax, edx							; add the offset to the address

	cmp [eax].Sprite.visible, FALSE			; test if last sprite is visible
	je Return								; jump if equal
	
	dec [ecx].ScoreSprites.mTimer			; self->mTimer--
	cmp [ecx].ScoreSprites.mTimer, 0		; if (self->mTimer == 0)
	jne Return								; jump if not equal

	mov eax, ecx							; EAX = class struct
	call ScoreSprites_reset					; hide all the sprites

Return:
	ret										; return from procedure
ScoreSprites_drawScreen ENDP

;-------------------------------------------------------------------------------

end

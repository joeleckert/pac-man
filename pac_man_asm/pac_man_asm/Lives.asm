
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Lives.inc
INCLUDE Screen.inc
INCLUDE Defines.inc

;-------------------------------------------------------------------------------

TOTAL_ICONS EQU 8

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Lives_constructor
; ______________________________________________________________________________
; Initializes the Lives class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET livesStruct
;	call Lives_constructor
;-------------------------------------------------------------------------------

Lives_constructor PROC

	mov [eax].Lives.mValue, 3			; default number of lives is 3
	ret									; return from procedure
Lives_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Lives_drawScreen
; ______________________________________________________________________________
; Draws the number of lives to the screen using the Pac-Man character.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET livesStruct
;	call Lives_drawScreen
;-------------------------------------------------------------------------------

Lives_drawScreen PROC

	mov edx, [eax].Lives.mValue			; EDX = total number of lives
	dec edx								; EDX--

	cmp edx, 0							; if (lives < 0)
	jge L1								; jump if greater than or equal

	mov edx, 0							; lives = 0
	jmp L2								; unconditional jump

L1:
	cmp edx, TOTAL_ICONS				; else if (lives > 8)
	jle L2								; jump if less than or equal
	
	mov edx, TOTAL_ICONS				; lives = TOTAL_ICONS

L2:
	mov eax, 30							; x = 30
	mov ebx, 20							; y = 20
	mov esi, 0							; loop index

BeginLoop:
	cmp esi, TOTAL_ICONS				; ESI < TOTAL_ICONS
	jge EndLoop							; jump if greater than or equal

	cmp esi, edx						; if (i < lives)
	jge J1								; jump if greater than or equal

	mov cx, PAC_MAN						; character to set
	call Screen_setChar					; draw character to screen
	
	mov cx, YELLOW						; attribute to set
	call Screen_setAttr					; draw attribute to screen
	jmp J2								; unconditional jump

J1:
	mov cx, SPACE						; character to set
	call Screen_setChar					; draw character to screen

	mov cx, BLACK						; attribute to set
	call Screen_setAttr					; draw attribute to screen

J2:
	add eax, 2							; x += 2

	cmp eax, 38							; if (x == 38)
	jne IncLoop							; jump if not equal

	mov eax, 30							; x = 30
	mov ebx, 21							; y = 21

IncLoop:
	inc esi								; ESI++
	jmp BeginLoop						; unconditional jump

EndLoop:
	ret									; return from procedure
Lives_drawScreen ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Lives_extraGuy
; ______________________________________________________________________________
; Adds an extra guy to the current player.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET livesStruct
;	call Lives_extraGuy
;-------------------------------------------------------------------------------

Lives_extraGuy PROC

	inc [eax].Lives.mValue				; add one extra guy to player
	call Lives_drawScreen				; update the screen
	ret									; return from procedure
Lives_extraGuy ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Lives_lost
; ______________________________________________________________________________
; Take away one life from the current player.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = The total number of lives remaining
;
; EXAMPLE
;	mov eax, OFFSET livesStruct
;	call Lives_lost
;-------------------------------------------------------------------------------

Lives_lost PROC

	cmp [eax].Lives.mValue, 0			; if (self->mValue > 0)
	jle L1								; jump if less than or equal

	dec [eax].Lives.mValue				; take away one guy from player

L1:
	push eax							; push class struct on stack
	call Lives_drawScreen				; update the screen

	pop eax								; pop class struct off stack
	mov eax, [eax].Lives.mValue			; EAX = self->mValue
	ret									; return from procedure
Lives_lost ENDP

;-------------------------------------------------------------------------------

end

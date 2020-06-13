
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Level.inc
INCLUDE Utils.inc
INCLUDE Defines.inc
INCLUDE Screen.inc

;-------------------------------------------------------------------------------

TOTAL_ICONS EQU 8

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Level_constructor
; ______________________________________________________________________________
; Initializes the Level class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET levelStruct
;	call Level_constructor
;-------------------------------------------------------------------------------

Level_constructor PROC

	mov [eax].Level.mValue, 1			; start at level 1
	ret									; return from procedure
Level_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Level_drawScreen
; ______________________________________________________________________________
; Draws the level to the screen using the fruit symbols.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET livesStruct
;	call Level_drawScreen
;-------------------------------------------------------------------------------

Level_drawScreen PROC

	mov edx, [eax].Level.mValue			; EDX = start (first level to draw)
	sub edx, TOTAL_ICONS				; self->mValue - TOTAL_ICONS

	cmp edx, 0							; if (EDX < 0)
	jge L1								; jump if greater than or equal

	mov edx, 0							; start = 0

L1:
	mov edi, [eax].Level.mValue			; EDI = size
	sub edi, edx						; self->mValue - start

	mov eax, 30							; x = 30
	mov ebx, 17							; y = 17
	mov esi, 0							; loop index

BeginLoop:
	cmp esi, TOTAL_ICONS				; ESI < TOTAL_ICONS
	jge EndLoop							; jump if greater than or equal

	inc edx								; start++
	push eax							; push x-value to stack

	cmp esi, edi						; if (i < size)
	jge J1								; jump if greater than or equal

	mov eax, edx						; EAX = start
	call Utils_bonusSymbolForLevel		; EAX = bonus symbol for level
	jmp J2								; unconditional jump

J1:
	mov eax, SPACE						; EAX = blank bonus symbol

J2:
	mov cx, ax							; CX = bonus symbol character to set
	pop eax								; pop x-value off stack
	call Screen_setChar					; draw character to screen
	
	mov cx, RED							; attribute to set
	call Screen_setAttr					; draw attribute to screen

	add eax, 2							; x += 2
	cmp eax, 38							; if (x == 38)
	jne IncLoop							; jump if not equal

	mov eax, 30							; x = 30
	mov ebx, 18							; y = 18

IncLoop:
	inc esi								; ESI++
	jmp BeginLoop						; unconditional jump

EndLoop:
	ret									; return from procedure
Level_drawScreen ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Level_passed
; ______________________________________________________________________________
; Moves the player to the next level.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET levelStruct
;	call Level_passed
;-------------------------------------------------------------------------------

Level_passed PROC

	inc [eax].Level.mValue				; goto the next level
	ret									; return from procedure
Level_passed ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Level_getCurrent
; ______________________________________________________________________________
; Returns the value of the current level.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = The current level value
;
; EXAMPLE
;	mov eax, OFFSET levelStruct
;	call Level_getCurrent
;-------------------------------------------------------------------------------

Level_getCurrent PROC

	mov eax, [eax].Level.mValue			; EAX = level value
	ret									; return from procedure
Level_getCurrent ENDP

;-------------------------------------------------------------------------------

end

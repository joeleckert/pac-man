
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE BonusSymbol.inc
INCLUDE Defines.inc
INCLUDE Screen.inc
INCLUDE Utils.inc
INCLUDE PacMan.inc

;-------------------------------------------------------------------------------

FIRST_DOT_COUNT  EQU 152
SECOND_DOT_COUNT EQU 65

MIN_TIME EQU 933
RAND_TIME EQU 68

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE symbolToScore
; ______________________________________________________________________________
; Converts the bonus symbol character to its score value.
;
; PARAMETERS
;	AX = Bouns symbol character
;
; RETURNS
;	EAX = The score value for the bonus symbol
;
; EXAMPLE
;	mov ax, symbol
;	call symbolToScore
;-------------------------------------------------------------------------------

symbolToScore PROC

	cmp ax, CHERRY						; case CHERRY:
	je S1								; jump if equal

	cmp ax, STRAWBERRY					; case STRAWBERRY:
	je S2								; jump if equal

	cmp ax, PEACH						; case PEACH:
	je S3								; jump if equal

	cmp ax, APPLE						; case APPLE:
	je S4								; jump if equal

	cmp ax, GRAPE						; case GRAPE:
	je S5								; jump if equal

	cmp ax, GALAXIAN					; case GALAXIAN:
	je S6								; jump if equal

	cmp ax, BELL						; case BELL:
	je S7								; jump if equal

	cmp ax, KEY							; case KEY:
	je S8								; jump if equal

	jmp Default							; default: unconditional jump

S1:
	mov eax, 100						; return 100
	jmp Return							; unconditional jump

S2:
	mov eax, 300						; return 300
	jmp Return							; unconditional jump

S3:
	mov eax, 500						; return 500
	jmp Return							; unconditional jump

S4:
	mov eax, 700						; return 700
	jmp Return							; unconditional jump

S5:
	mov eax, 1000						; return 1000
	jmp Return							; unconditional jump

S6:
	mov eax, 2000						; return 2000
	jmp Return							; unconditional jump

S7:
	mov eax, 3000						; return 3000
	jmp Return							; unconditional jump

S8:
	mov eax, 5000						; return 5000
	jmp Return							; unconditional jump

Default:
	mov eax, 0							; return 0

Return:
	ret									; return from procedure
symbolToScore ENDP

;-------------------------------------------------------------------------------
; PROCEDURE BonusSymbol_constructor
; ______________________________________________________________________________
; Initializes the Bonus Symbol class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET bonusSymbolStruct
;	call BonusSymbol_constructor
;-------------------------------------------------------------------------------

BonusSymbol_constructor PROC

	mov [eax].BonusSymbol.mSprite.character, SPACE	; blank symbol
	mov [eax].BonusSymbol.mSprite.attributes, RED	; red color
	mov [eax].BonusSymbol.mSprite.charPoint.x, 14	; x-position of symbol
	mov [eax].BonusSymbol.mSprite.charPoint.y, 14	; y-position of symbol
	mov [eax].BonusSymbol.mSprite.visible, FALSE	; don't display on screen

	mov [eax].BonusSymbol.mShowCounter, 0			; self->mShowCounter = 0
	mov [eax].BonusSymbol.mTimer, 0					; self->mTimer = 0

	lea eax, [eax].BonusSymbol.mSprite				; EAX = &self->mSprite
	call Screen_addSprite							; add to screen sprites

	ret												; return from procedure
BonusSymbol_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE BonusSymbol_reset
; ______________________________________________________________________________
; Reset the timer and shut off visibility.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET bonusSymbolStruct
;	call BonusSymbol_reset
;-------------------------------------------------------------------------------

BonusSymbol_reset PROC

	mov [eax].BonusSymbol.mSprite.visible, FALSE	; don't display on screen
	mov [eax].BonusSymbol.mTimer, 0					; self->mTimer = 0
	ret												; return from procedure
BonusSymbol_reset ENDP

;-------------------------------------------------------------------------------
; PROCEDURE BonusSymbol_setLevel
; ______________________________________________________________________________
; Setup the bonus symbol for the current level.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The current level of the game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET bonusSymbolStruct
;	mov ebx, level
;	call BonusSymbol_setLevel
;-------------------------------------------------------------------------------

BonusSymbol_setLevel PROC

	xchg eax, ebx									; EAX = level / EBX = class
	call Utils_bonusSymbolForLevel					; get symbol for level

	xchg eax, ebx									; EAX = class / EBX = symbol
	mov [eax].BonusSymbol.mSprite.character, bx		; set symbol for level
	mov [eax].BonusSymbol.mSprite.visible, FALSE	; don't display on screen

	mov [eax].BonusSymbol.mShowCounter, 0			; self->mShowCounter = 0
	mov [eax].BonusSymbol.mTimer, 0					; self->mTimer = 0
	ret												; return from procedure
BonusSymbol_setLevel ENDP

;-------------------------------------------------------------------------------
; PROCEDURE BonusSymbol_showSymbol
; ______________________________________________________________________________
; Checks to see if the bonus symbol should appear on screen.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = The total number of dots Pac-Man has eaten
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET bonusSymbolStruct
;	mov ebx, dotCount
;	call BonusSymbol_showSymbol
;-------------------------------------------------------------------------------

BonusSymbol_showSymbol PROC

	cmp [eax].BonusSymbol.mShowCounter, 2		; show only twice per level
	jge Return									; jump if greater than or equal

	cmp ebx, FIRST_DOT_COUNT					; if (dotCount == 152)
	jne C1										; jump if not eqaul

	cmp [eax].BonusSymbol.mShowCounter, 0		; if (self->mShowCounter != 0)
	jne Return									; jump if not eqaul

	jmp Show									; unconditional jump

C1:
	cmp ebx, SECOND_DOT_COUNT					; if (dotCount == 65)
	jne Return									; jump if not eqaul

	cmp [eax].BonusSymbol.mShowCounter, 1		; if (self->mShowCounter != 1)
	jne Return									; jump if not eqaul

Show:
	inc [eax].BonusSymbol.mShowCounter			; self->mShowCounter++
	mov [eax].BonusSymbol.mTimer, MIN_TIME		; 9 seconds, 330 milliseconds

	mov ebx, eax								; EBX = class
	mov eax, RAND_TIME							; random up to 680 milliseconds
	call Utils_randomValue						; get random value

	xchg eax, ebx								; EAX = class / EBX = rand value
	add [eax].BonusSymbol.mTimer, ebx			; add random value to timer

	mov [eax].BonusSymbol.mSprite.visible, TRUE	; display on screen

Return:
	ret											; return from procedure
BonusSymbol_showSymbol ENDP

;-------------------------------------------------------------------------------
; PROCEDURE BonusSymbol_hideSymbol
; ______________________________________________________________________________
; Shuts the visibility of the symbol off.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET bonusSymbolStruct
;	call BonusSymbol_hideSymbol
;-------------------------------------------------------------------------------

BonusSymbol_hideSymbol PROC

	mov [eax].BonusSymbol.mSprite.visible, FALSE	; don't display on screen
	ret												; return from procedure
BonusSymbol_hideSymbol ENDP

;-------------------------------------------------------------------------------
; PROCEDURE BonusSymbol_hitTest
; ______________________________________________________________________________
; Checks to see if Pac Man has intersected with the bonus symbol.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Contains a pointer to a PacMan class struct
;
; RETURNS
;	EAX = Returns the bonus score if a hit test happened, 0 otherwise
;
; EXAMPLE
;	mov eax, OFFSET bonusSymbolStruct
;	mov ebx, OFFSET pacManStruct
;	call BonusSymbol_hitTest
;-------------------------------------------------------------------------------

BonusSymbol_hitTest PROC

	cmp [eax].BonusSymbol.mSprite.visible, FALSE	; if (visible == false)
	je NoHit										; jump if equal

	mov ecx, eax									; ECX = class struct
	mov eax, ebx									; EAX = PacMan class struct
	call PacMan_getPoint							; get location of Pac Man
	
	lea ebx, [ecx].BonusSymbol.mSprite.charPoint	; EBX = symbol location
	call Utils_pointsEqual							; perform hit test

	cmp eax, TRUE									; was there a hit?
	jne NoHit										; jump if not equal

	mov [ecx].BonusSymbol.mSprite.visible, FALSE	; hide bonus symbol

	mov ax, [ecx].BonusSymbol.mSprite.character		; get bonus symbol character
	call symbolToScore								; convert symbol to score
	jmp Return										; return score

NoHit:
	mov eax, 0										; return 0

Return:
	ret												; return from procedure
BonusSymbol_hitTest ENDP

;-------------------------------------------------------------------------------
; PROCEDURE BonusSymbol_drawScreen
; ______________________________________________________________________________
; Draws the bonus symbol on the game map.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET bonusSymbolStruct
;	call BonusSymbol_drawScreen
;-------------------------------------------------------------------------------

BonusSymbol_drawScreen PROC

	cmp [eax].BonusSymbol.mSprite.visible, FALSE	; if (visible == false)
	je Return										; jump if equal

	dec [eax].BonusSymbol.mTimer					; self->mTimer--
	cmp [eax].BonusSymbol.mTimer, 0					; if (self->mTimer == 0)
	jne Return										; jump if not equal

	mov [eax].BonusSymbol.mSprite.visible, FALSE	; don't display on screen

Return:
	ret												; return from procedure
BonusSymbol_drawScreen ENDP

;-------------------------------------------------------------------------------

end

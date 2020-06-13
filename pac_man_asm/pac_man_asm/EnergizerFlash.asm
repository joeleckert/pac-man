
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE EnergizerFlash.inc
INCLUDE Defines.inc
INCLUDE Screen.inc

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE setEnergizerColor
; ______________________________________________________________________________
; Sets the color of all energizers on the game map.
;
; PARAMETERS
;	AX = color to set energizers
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov ax, attributes
;	call setEnergizerColor
;-------------------------------------------------------------------------------

setEnergizerColor PROC

	mov cx, ax							; CX = color to set energizers

	mov eax, 1							; x-position
	mov ebx, 2							; y-position
	call Screen_setAttr					; set top left energizer color

	mov eax, 26							; x-position
	mov ebx, 2							; y-position
	call Screen_setAttr					; set top right energizer color

	mov eax, 1							; x-position
	mov ebx, 18							; y-position
	call Screen_setAttr					; set bottom left energizer color

	mov eax, 26							; x-position
	mov ebx, 18							; y-position
	call Screen_setAttr					; set bottom right energizer color

	ret									; return from procedure
setEnergizerColor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE EnergizerFlash_constructor
; ______________________________________________________________________________
; Initializes the Energizer Flash class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET energizerStruct
;	call EnergizerFlash_constructor
;-------------------------------------------------------------------------------

EnergizerFlash_constructor PROC

	mov [eax].EnergizerFlash.mTimer, MILLISECONDS_150	; set timer to 150ms

	mov ax, DARK_WHITE					; color to set energizers
	call setEnergizerColor				; set all energizers to color in AX

	ret									; return from procedure
EnergizerFlash_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE EnergizerFlash_hideEnergizers
; ______________________________________________________________________________
; Hides all the energizers on the game map.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call EnergizerFlash_hideEnergizers
;-------------------------------------------------------------------------------

EnergizerFlash_hideEnergizers PROC

	mov ax, BLACK						; color to set energizers
	call setEnergizerColor				; set all energizers to color in AX

	ret									; return from procedure
EnergizerFlash_hideEnergizers ENDP

;-------------------------------------------------------------------------------
; PROCEDURE EnergizerFlash_drawScreen
; ______________________________________________________________________________
; Updates all the energizers on the screen.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET energizerStruct
;	call EnergizerFlash_drawScreen
;-------------------------------------------------------------------------------

EnergizerFlash_drawScreen PROC

	dec [eax].EnergizerFlash.mTimer		; self->mTimer--

	cmp [eax].EnergizerFlash.mTimer, 0	; if (self->mTimer > 0)
	jg Return							; jump if greater than

	mov [eax].EnergizerFlash.mTimer, MILLISECONDS_150	; set timer to 150ms
	mov cx, BLACK										; CX = BLACK color

	mov eax, 1							; x-position
	mov ebx, 2							; y-position
	call Screen_getAttr					; get top left energizer color

	cmp ax, cx							; if (attribute == CX)
	jne L1								; jump if not equal

	mov cx, DARK_WHITE					; CX = DARK_WHITE color

L1:
	mov ax, cx							; AX = color to set energizers
	call setEnergizerColor				; set all energizers to color in AX

Return:
	ret									; return from procedure
EnergizerFlash_drawScreen ENDP

;-------------------------------------------------------------------------------

end

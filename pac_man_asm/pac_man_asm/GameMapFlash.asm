
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE GameMapFlash.inc
INCLUDE Defines.inc
INCLUDE Screen.inc
INCLUDE GameMap.inc

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE GameMapFlash_constructor
; ______________________________________________________________________________
; Initializes the Game Map Flash class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET gameMapFlashStruct
;	call GameMapFlash_constructor
;-------------------------------------------------------------------------------

GameMapFlash_constructor PROC

	mov [eax].GameMapFlash.mTimer, MILLISECONDS_10	; set timer to 10ms

	ret									; return from procedure
GameMapFlash_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GameMapFlash_drawScreen
; ______________________________________________________________________________
; Flashes the game map when the level has been won.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET gameMapFlashStruct
;	call GameMapFlash_drawScreen
;-------------------------------------------------------------------------------

GameMapFlash_drawScreen PROC

	dec [eax].GameMapFlash.mTimer		; self->mTimer--

	cmp [eax].GameMapFlash.mTimer, 0	; if (self->mTimer > 0)
	jg Return							; jump if greater than

	push eax							; push class struct to stack
	mov cx, WHITE						; CX = WHITE color

	mov eax, 0							; x-position
	mov ebx, 0							; y-position
	call Screen_getAttr					; get game border color

	cmp ax, cx							; if (attribute == CX)
	pop eax								; pop class struct off stack
	jne C1								; jump if not equal

	mov cx, BLUE									; CX = BLUE color
	mov [eax].GameMapFlash.mTimer, MILLISECONDS_170	; set timer to 170ms
	jmp C2											; unconditional jump

C1:
	mov [eax].GameMapFlash.mTimer, MILLISECONDS_230	; set timer to 230ms

C2:
	mov esi, 0							; y index

L1:
	cmp esi, GAME_MAP_HEIGHT			; (ESI < GAME_MAP_HEIGHT)
	jge Return							; jump if greater than or equal

	mov edi, 0							; x index
	
L2:
	cmp edi, GAME_MAP_WIDTH				; (EDI < GAME_MAP_WIDTH)
	jge L1_Next							; jump if greater than or equal

	mov eax, edi						; EAX = x value
	mov ebx, esi						; EBX = y value
	call Screen_getChar					; get game map character

	cmp ax, SPACE						; case SPACE:
	je L2_Next							; jump if equal

	cmp ax, DOT							; case DOT:
	je L2_Next							; jump if equal

	cmp ax, ENERGIZER					; case ENERGIZER:
	je L2_Next							; jump if equal

	cmp ax, WARP_BORDER					; case WARP_BORDER:
	je L2_Next							; jump if equal

	mov eax, edi						; EAX = x value
	mov ebx, esi						; EBX = y value
	call Screen_setAttr					; get game map color

L2_Next:
	inc edi								; x++
	jmp L2								; unconditional jump

L1_Next:
	inc esi								; y++
	jmp L1								; unconditional jump

Return:
	ret									; return from procedure
GameMapFlash_drawScreen ENDP

;-------------------------------------------------------------------------------

end

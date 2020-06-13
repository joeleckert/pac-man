
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE GhostBlueTime.inc
INCLUDE Defines.inc
INCLUDE Windows.inc

;-------------------------------------------------------------------------------

FLASH_START EQU 180

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE timerLimit
; ______________________________________________________________________________
; Sets how long blue time lasts for each level.
;
; PARAMETERS
;	EBX = Current level of game
;
; RETURNS
;	EBX = Time limit in seconds
;
; EXAMPLE
;	mov ebx, level
;	call timerLimit
;-------------------------------------------------------------------------------

timerLimit PROC

	cmp ebx, 1							; case 1:
	je S1								; jump if equal

	cmp ebx, 2							; case 2:
	je S2_6_10							; jump if equal

	cmp ebx, 6							; case 6:
	je S2_6_10							; jump if equal

	cmp ebx, 10							; case 10:
	je S2_6_10							; jump if equal

	cmp ebx, 3							; case 3:
	je S3								; jump if equal

	cmp ebx, 4							; case 4:
	je S4_14							; jump if equal

	cmp ebx, 14							; case 14:
	je S4_14							; jump if equal

	cmp ebx, 5							; case 5:
	je S5_7_8_11						; jump if equal
	
	cmp ebx, 7							; case 7:
	je S5_7_8_11						; jump if equal

	cmp ebx, 8							; case 8:
	je S5_7_8_11						; jump if equal

	cmp ebx, 11							; case 11:
	je S5_7_8_11						; jump if equal

	cmp ebx, 9							; case 9:
	je S9_12_13_15_16_18				; jump if equal

	cmp ebx, 12							; case 12:
	je S9_12_13_15_16_18				; jump if equal

	cmp ebx, 13							; case 13:
	je S9_12_13_15_16_18				; jump if equal

	cmp ebx, 15							; case 15:
	je S9_12_13_15_16_18				; jump if equal

	cmp ebx, 16							; case 16:
	je S9_12_13_15_16_18				; jump if equal

	cmp ebx, 18							; case 18:
	je S9_12_13_15_16_18				; jump if equal

	jmp Default							; default: unconditional jump

S1:
	mov ebx, SECONDS_6					; return SECONDS_6
	jmp Return							; unconditional jump

S2_6_10:
	mov ebx, SECONDS_5					; return SECONDS_5
	jmp Return							; unconditional jump

S3:
	mov ebx, SECONDS_4					; return SECONDS_4
	jmp Return							; unconditional jump

S4_14:
	mov ebx, SECONDS_3					; return SECONDS_3
	jmp Return							; unconditional jump

S5_7_8_11:
	mov ebx, SECONDS_2					; return SECONDS_2
	jmp Return							; unconditional jump

S9_12_13_15_16_18:
	mov ebx, SECONDS_1					; return SECONDS_1
	jmp Return							; unconditional jump

Default:
	mov ebx, MILLISECONDS_10			; return MILLISECONDS_10

Return:
	ret									; return from procedure
timerLimit ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostBlueTime_constructor
; ______________________________________________________________________________
; Initializes the Ghost Blue Time class.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;	EBX = Current level of game
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostBlueTimeStruct
;	mov ebx, level
;	call GhostBlueTime_constructor
;-------------------------------------------------------------------------------

GhostBlueTime_constructor PROC

	mov [eax].GhostBlueTime.mTimer, 0						; self->mTimer = 0
	mov [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_NONE	; default color

	call timerLimit											; get timer limit
	mov [eax].GhostBlueTime.mTimerLimit, ebx				; set timer limit

	ret									; return from procedure
GhostBlueTime_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostBlueTime_start
; ______________________________________________________________________________
; Start blue time.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostBlueTimeStruct
;	call GhostBlueTime_start
;-------------------------------------------------------------------------------

GhostBlueTime_start PROC

	mov ebx, [eax].GhostBlueTime.mTimerLimit	; EBX = timerLimit
	mov [eax].GhostBlueTime.mTimer, ebx			; timer = timerLimit
	mov [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_DISPLAY_BLUE ; ghost blue

	ret									; return from procedure
GhostBlueTime_start ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostBlueTime_period
; ______________________________________________________________________________
; Process blue time.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = The color of the ghost
;
; EXAMPLE
;	mov eax, OFFSET ghostBlueTimeStruct
;	call GhostBlueTime_period
;-------------------------------------------------------------------------------

GhostBlueTime_period PROC

	cmp [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_NONE ; if (color == NONE)
	je Return								; jump if equal

	dec [eax].GhostBlueTime.mTimer			; self->mTimer--
	cmp [eax].GhostBlueTime.mTimer, 0		; if (self->mTimer == 0)
	jne C1									; jump if not equal

	mov [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_NONE
	jmp Return								; unconditional jump

C1:
	cmp [eax].GhostBlueTime.mTimer, FLASH_START	; if (timer <= FLASH_START)
	jg Return								; jump if greater than

	push eax								; push class struct on stack

	mov eax, [eax].GhostBlueTime.mTimer		; EAX = self->mTimer
	mov edx, 0								; Clear remainder
	mov ecx, MILLISECONDS_200				; Set the divisor
	idiv ecx								; Divide by MILLISECONDS_200

	pop eax									; pop class struct off stack

	cmp edx, 0								; if ((timer % MILLISEC_200) == 0)
	jne Return								; jump if not equal

	cmp [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_DISPLAY_BLUE  ; are blue?
	jne C2									; jump if not equal

	mov [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_DISPLAY_WHITE ; turn white
	jmp Return								; unconditional jump

C2:
	mov [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_DISPLAY_BLUE  ; turn blue

Return:
	mov eax, [eax].GhostBlueTime.mColor		; return self->mColor
	ret										; return from procedure
GhostBlueTime_period ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostBlueTime_cancel
; ______________________________________________________________________________
; Cancel blue time.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghostBlueTimeStruct
;	call GhostBlueTime_cancel
;-------------------------------------------------------------------------------

GhostBlueTime_cancel PROC

	mov [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_NONE ; default color

	ret									; return from procedure
GhostBlueTime_cancel ENDP

;-------------------------------------------------------------------------------
; PROCEDURE GhostBlueTime_isOn
; ______________________________________________________________________________
; Check to see if the ghost is in blue time.
;
; PARAMETERS
;	EAX = Contains a pointer to the class struct
;
; RETURNS
;	EAX = TRUE if blue time is on, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET ghostBlueTimeStruct
;	call GhostBlueTime_isOn
;-------------------------------------------------------------------------------

GhostBlueTime_isOn PROC

	cmp [eax].GhostBlueTime.mColor, BLUE_TIME_COLOR_NONE	; if (color != NONE)
	je C1													; jump if equal

	mov eax, TRUE						; return TRUE
	jmp Return							; unconditional jump

C1:
	mov eax, FALSE						; return FALSE

Return:
	ret									; return from procedure
GhostBlueTime_isOn ENDP

;-------------------------------------------------------------------------------

end

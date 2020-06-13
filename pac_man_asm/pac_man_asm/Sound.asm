
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Sound.inc
INCLUDE Windows.inc
INCLUDE WinApi.inc
INCLUDE Snd1.inc
INCLUDE Snd2.inc
INCLUDE Snd3.inc
INCLUDE Snd4.inc
INCLUDE Snd5.inc
INCLUDE Snd6.inc
INCLUDE Snd7.inc
INCLUDE Snd8.inc
INCLUDE Snd9.inc
INCLUDE Snd10.inc
INCLUDE Snd11.inc

;-------------------------------------------------------------------------------

TOTAL_SOUNDS EQU 11

PLAY_ONCE EQU 1
TWO_LOOPS EQU 2
MAX_LOOPS EQU 0FFFFFFFFh

;-------------------------------------------------------------------------------

.data
waveOut HWAVEOUT TOTAL_SOUNDS DUP(0)
waveHeaders WAVEHDR TOTAL_SOUNDS DUP(<>)

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Sound_constructor
; ______________________________________________________________________________
; Initializes the sounds for the game.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Sound_constructor
;-------------------------------------------------------------------------------

Sound_constructor PROC

	pushad									; save registers
	mov esi, 0								; loop index

L1:
	cmp esi, TOTAL_SOUNDS					; (ESI < TOTAL_SOUNDS)
	jge C1									; jump if greater than or equal

	mov eax, 44100							; audio sample rate
	mov bx, 16								; audio bit depth
	mov cx, 1								; total audio channels
	call Win32_soundOutputOpen				; get handle to audio output

	mov waveOut[esi * TYPE HWAVEOUT], eax	; save handle to array

	inc esi									; i++
	jmp L1									; unconditional jump

C1:
	mov eax, waveOut[0 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[0 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, PLAY_ONCE								; loop count
	mov edx, snd1Size								; audio buffer size
	mov esi, OFFSET snd1							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[1 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[1 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, MAX_LOOPS								; loop count
	mov edx, snd2Size								; audio buffer size
	mov esi, OFFSET snd2							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[2 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[2 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, MAX_LOOPS								; loop count
	mov edx, snd3Size								; audio buffer size
	mov esi, OFFSET snd3							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[3 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[3 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, PLAY_ONCE								; loop count
	mov edx, snd4Size								; audio buffer size
	mov esi, OFFSET snd4							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[4 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[4 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, PLAY_ONCE								; loop count
	mov edx, snd5Size								; audio buffer size
	mov esi, OFFSET snd5							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[5 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[5 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, PLAY_ONCE								; loop count
	mov edx, snd6Size								; audio buffer size
	mov esi, OFFSET snd6							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[6 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[6 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, PLAY_ONCE								; loop count
	mov edx, snd7Size								; audio buffer size
	mov esi, OFFSET snd7							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[7 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[7 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, MAX_LOOPS								; loop count
	mov edx, snd8Size								; audio buffer size
	mov esi, OFFSET snd8							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[8 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[8 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, TWO_LOOPS								; loop count
	mov edx, snd9Size								; audio buffer size
	mov esi, OFFSET snd9							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[9 * TYPE HWAVEOUT]				; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[9 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, PLAY_ONCE								; loop count
	mov edx, snd10Size								; audio buffer size
	mov esi, OFFSET snd10							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	mov eax, waveOut[10 * TYPE HWAVEOUT]			; HWAVEOUT handle
	mov ebx, OFFSET waveHeaders[10 * TYPE WAVEHDR]	; WAVEHDR*
	mov ecx, MAX_LOOPS								; loop count
	mov edx, snd11Size								; audio buffer size
	mov esi, OFFSET snd11							; audio buffer data
	call Win32_soundOutputPrepare					; prepare sound for playback

	popad											; restore registers
	ret												; return from procedure
Sound_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Sound_playSound
; ______________________________________________________________________________
; Plays the sound specified by the sound constant.
;
; PARAMETERS
;	EAX = Sound constant
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, SOUND_CHOMP
;	call Sound_playSound
;-------------------------------------------------------------------------------

Sound_playSound PROC

	pushad									; save registers

	cmp eax, SOUND_BEGINNING				; if (EAX < SOUND_BEGINNING
	jl Return								; jump if less than
	
	cmp eax, SOUND_CHOMP					; || sound > SOUND_CHOMP)
	jg Return								; jump if greater than

	mov esi, eax							; ESI = Sound constant

	mov ebx, TYPE WAVEHDR					; EBX = sizeof(WAVEHDR)
	mul ebx									; EAX *= EBX

	mov ebx, OFFSET waveHeaders				; EBX = points to first waveHeader
	add ebx, eax							; add the array offset in EAX

	mov eax, waveOut[esi * TYPE HWAVEOUT]	; EAX = HWAVEOUT handle from array
	call Win32_soundOutputPlay				; play sound

Return:
	popad									; restore registers
	ret										; return from procedure
Sound_playSound ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Sound_stopSound
; ______________________________________________________________________________
; Stops the sound specified by the sound constant.
;
; PARAMETERS
;	EAX = Sound constant
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, SOUND_CHOMP
;	call Sound_stopSound
;-------------------------------------------------------------------------------

Sound_stopSound PROC

	pushad									; save registers

	cmp eax, SOUND_BEGINNING				; if (EAX < SOUND_BEGINNING
	jl Return								; jump if less than
	
	cmp eax, SOUND_CHOMP					; || sound > SOUND_CHOMP)
	jg Return								; jump if greater than

	mov eax, waveOut[eax * TYPE HWAVEOUT]	; EAX = HWAVEOUT handle from array
	call Win32_soundOutputStop				; stop sound

Return:
	popad									; restore registers
	ret										; return from procedure
Sound_stopSound ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Sound_stopAllSounds
; ______________________________________________________________________________
; Stops all the sounds that are playing.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Sound_stopAllSounds
;-------------------------------------------------------------------------------

Sound_stopAllSounds PROC

	pushad									; save registers
	mov esi, 0								; loop index

L1:
	cmp esi, TOTAL_SOUNDS					; (ESI < TOTAL_SOUNDS)
	jge Return								; jump if greater than or equal

	mov eax, waveOut[esi * TYPE HWAVEOUT]	; EAX = HWAVEOUT handle from array
	call Win32_soundOutputStop				; stop sound

	inc esi									; i++
	jmp L1									; unconditional jump

Return:
	popad									; restore registers
	ret										; return from procedure
Sound_stopAllSounds ENDP

;-------------------------------------------------------------------------------

end


.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE WinApi.inc
INCLUDE Structs.inc

;-------------------------------------------------------------------------------

mError MACRO text
	LOCAL errorString				; local label
	
	.data
	errorString BYTE text, 0		; define string with terminating null

	.code
	mov eax, OFFSET errorString		; EAX = address of errorString
	call Win32_error				; display the error
ENDM

;-------------------------------------------------------------------------------

.data
messageBoxCaption BYTE "Pac-Man Error", 0

count DWORD 0
cursorInfo CONSOLE_CURSOR_INFO <>
startPosition COORD <>
sizeDimensions COORD <>
bufferRect SMALL_RECT <>

wavOut HWAVEOUT 0
wavFormat WAVEFORMATEX <>

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Win32_error
; ______________________________________________________________________________
; Displays a graphical popup box with an error message and ends the program. The
; last error code is passed back to the OS.
;
; PARAMETERS
;	EAX = Contains a pointer to the message string
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET message
;	call Win32_error
;-------------------------------------------------------------------------------

Win32_error PROC
	push eax							; Save offset to the message string

	INVOKE GetLastError					; Win32 console function
	mov ecx, eax						; Copy error code into ECX

	pop eax								; Restore offset to the message string
	push ecx							; Save copy of last error code

	call Win32_messageBox				; display string in message box

	pop ecx								; Restore copy of last error code
	INVOKE ExitProcess, ecx				; Exit program with last error code
	ret									; return from procedure
Win32_error ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_getCursorInfo
; ______________________________________________________________________________
; Retrieves information about the size and visibility of the cursor for the
; specified console screen buffer.
;
; PARAMETERS
;	EAX = A handle to the console output buffer
;	EBX = Pointer to a CONSOLE_CURSOR_INFO struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, stdOutputHandle
;	mov ebx, OFFSET cursorInfo
;	call Win32_getCursorInfo
;-------------------------------------------------------------------------------

Win32_getCursorInfo PROC

	INVOKE GetConsoleCursorInfo,		; Win32 console function
		eax,							; STD_OUTPUT_HANDLE
		ebx								; CONSOLE_CURSOR_INFO*

	cmp eax, FALSE						; if (EAX == FALSE)
	jne L1								; jump if not equal

	mError "Unable to get cursor information."

L1:
	ret									; return from procedure
Win32_getCursorInfo ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_setCursorInfo
; ______________________________________________________________________________
; Sets the size and visibility of the cursor for the specified console screen
; buffer.
;
; PARAMETERS
;	EAX = A handle to the console output buffer
;	EBX = Pointer to a CONSOLE_CURSOR_INFO struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, stdOutputHandle
;	mov ebx, OFFSET cursorInfo
;	call Win32_setCursorInfo
;-------------------------------------------------------------------------------

Win32_setCursorInfo PROC

	INVOKE SetConsoleCursorInfo,		; Win32 console function
		eax,							; STD_OUTPUT_HANDLE
		ebx								; CONSOLE_CURSOR_INFO*

	cmp eax, FALSE						; if (EAX == FALSE)
	jne L1								; jump if not equal

	mError "Unable to set cursor information."

L1:
	ret									; return from procedure
Win32_setCursorInfo ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_getHandle
; ______________________________________________________________________________
; Retrieves a handle to the specified standard device (standard input, standard
; output, or standard error)
;
; PARAMETERS
;	EAX = Contains the standard device value - ex. STD_OUTPUT_HANDLE
;
; RETURNS
;	EAX = If successful, the handle to the specified device
;
; EXAMPLE
;	mov eax, STD_OUTPUT_HANDLE
;	call Win32_getHandle
;-------------------------------------------------------------------------------

Win32_getHandle PROC
	INVOKE GetStdHandle,				; Win32 console function
		eax								; standard device value

	cmp eax, NULL						; if (EAX == NULL)
	jne L1								; jump if not equal

	mError "Handle was not found."
	jmp L2								; unconditional jump to L2

L1:
	cmp eax, INVALID_HANDLE_VALUE		; else if (EAX == INVALID_HANDLE_VALUE)
	jne L2								; jump if not equal

	mError "Unable to get handle."

L2:
	ret									; return from procedure
Win32_getHandle ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_hideCursor
; ______________________________________________________________________________
; Hides the cursor for the specified console screen buffer.
;
; PARAMETERS
;	EAX = A handle to the console output buffer
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, stdOutputHandle
;	call Win32_hideCursor
;-------------------------------------------------------------------------------

Win32_hideCursor PROC
	push eax							; Save the output handle

	mov ebx, OFFSET cursorInfo			; EAX = address of cursorInfo
	call Win32_getCursorInfo			; Fill the cursorInfo struct

	pop eax								; Restore the output handle

	mov cursorInfo.bVisible, FALSE		; Set the cursor visibility to false
	mov ebx, OFFSET cursorInfo			; EAX = address of cursorInfo
	call Win32_setCursorInfo			; Apply the change 

	ret									; return from procedure
Win32_hideCursor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_writeBuffer
; ______________________________________________________________________________
; Writes character and color attribute data to a specified rectangular block of
; character cells in a console screen buffer. 
;
; PARAMETERS
;	EAX = A handle to the console output buffer
;	EBX = Pointer to CHAR_INFO buffer
;	ECX = Pointer to SMALL_RECT
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, stdOutputHandle
;	mov ebx, OFFSET buffer
;	mov ecx, OFFSET rect
;	call Win32_writeBuffer
;-------------------------------------------------------------------------------

Win32_writeBuffer PROC

	mov startPosition.X, 0				; X position of buffer start
	mov startPosition.Y, 0				; Y position of buffer start

	mov dx, [ecx].SMALL_RECT.Right		; Width of buffer
	mov sizeDimensions.X, dx			; Save width to sizeDimensions

	mov dx, [ecx].SMALL_RECT.Bottom		; Height of buffer
	mov sizeDimensions.Y, dx			; Save height to sizeDimensions

	mov dx, [ecx].SMALL_RECT.Left		; X position of buffer
	mov bufferRect.Left, dx				; Save x position to bufferRect
	mov bufferRect.Right, dx			; Save x position to bufferRect width

	mov dx, [ecx].SMALL_RECT.Top		; Y position of buffer
	mov bufferRect.Top, dx				; Save y position to bufferRect
	mov bufferRect.Bottom, dx			; Save y position to bufferRect height

	mov dx, [ecx].SMALL_RECT.Right		; Width of buffer
	dec dx								; Width - 1
	add bufferRect.Right, dx			; Add the width to the bufferRect width

	mov dx, [ecx].SMALL_RECT.Bottom		; Height of buffer
	dec dx								; Height - 1
	add bufferRect.Bottom, dx			; Add the height to the bufferRect height

	INVOKE WriteConsoleOutputW,			; Win32 console function
		eax,							; STD_OUTPUT_HANDLE
		ebx,							; CHAR_INFO*
		sizeDimensions,					; COORD
		startPosition,					; COORD
		ADDR bufferRect					; SMALL_RECT*

	cmp eax, FALSE						; if (EAX == FALSE)
	jne L1								; jump if not equal

	mError "Write to console output failed."

L1:
	ret									; return from procedure
Win32_writeBuffer ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_getEventCount
; ______________________________________________________________________________
; Retrieves the number of unread input records in the console's input buffer.
;
; PARAMETERS
;	EAX = A handle to the console input buffer
;
; RETURNS
;	EAX = The number of console input events
;
; EXAMPLE
;	mov eax, stdInputHandle
;	call Win32_getEventCount
;-------------------------------------------------------------------------------

Win32_getEventCount PROC

	INVOKE GetNumberOfConsoleInputEvents,	; Win32 console function
		eax,								; STD_INPUT_HANDLE
		ADDR count							; receives number of unread records

	cmp eax, FALSE							; if (EAX == FALSE)
	jne L1									; jump if not equal

	mError "Unable to get event count."

L1:
	mov eax, count							; EAX = number of input events
	ret										; return from procedure
Win32_getEventCount ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_readInput
; ______________________________________________________________________________
; Reads data from a console input buffer and removes it from the buffer.
;
; PARAMETERS
;	EAX = A handle to the console input buffer
;	EBX = Pointer to an INPUT_RECORD struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, stdInputHandle
;	mov ebx, OFFSET inputRecord
;	call Win32_readInput
;-------------------------------------------------------------------------------

Win32_readInput PROC

	INVOKE ReadConsoleInputW,			; Win32 console function
		eax,							; STD_INPUT_HANDLE
		ebx,							; INPUT_RECORD*
		1,								; Size of INPUT_RECORD array
		ADDR count						; receives number of input records read

	cmp eax, FALSE						; if (EAX == FALSE)
	jne L1								; jump if not equal

	mError "Read console input failed."
	jmp L2								; unconditional jump to L2

L1:
	cmp count, 1						; else if (count != 1)
	je L2								; jump if equal

	mError "Read console input had a bad read."

L2:
	ret									; return from procedure
Win32_readInput ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_handleEvent
; ______________________________________________________________________________
; Processes the keyboard event for the game.
;
; PARAMETERS
;	EAX = Pointer to an INPUT_RECORD struct
;	EBX = Pointer to a Keys struct
;
; RETURNS
;	EAX = Returns a boolean. TRUE if event was a KEY_EVENT, FALSE otherwise
;
; EXAMPLE
;	mov eax, OFFSET inputRecord
;	mov ebx, OFFSET keys
;	call Win32_handleEvent
;-------------------------------------------------------------------------------

Win32_handleEvent PROC
	; KeyEvent symbol in EAX
	LocalKeyEvent TEXTEQU <[eax].INPUT_RECORD.Event.KeyEvent>

	mov dx, [eax].INPUT_RECORD.EventType	; DX = type of input event

	cmp dx, KEY_EVENT						; if (DX != KEY_EVENT)
	je L1									; jump if equal

	mov eax, FALSE							; set return value to FALSE
	jmp Return								; unconditional jump to Return

L1:
	mov ecx, LocalKeyEvent.bKeyDown			; ECX = key down state
	mov dx, LocalKeyEvent.wVirtualKeyCode	; DX = input key value
	mov eax, TRUE							; set return value to TRUE

	cmp dx, VK_LEFT							; case VK_LEFT:
	je LeftArrow							; jump if equal

	cmp dx, VK_UP							; case VK_UP:
	je UpArrow								; jump if equal

	cmp dx, VK_RIGHT						; case VK_RIGHT:
	je RightArrow							; jump if equal

	cmp dx, VK_DOWN							; case VK_DOWN:
	je DownArrow							; jump if equal
	
	cmp dx, VK_RETURN						; case VK_RETURN:
	je ReturnKey							; jump if equal

	jmp Return								; default: unconditional jump

LeftArrow:
	mov [ebx].Keys.left, ecx				; keys->left = key down state
	jmp Return								; unconditional jump to Return

UpArrow:
	mov [ebx].Keys.up, ecx					; keys->up = key down state
	jmp Return								; unconditional jump to Return

RightArrow:
	mov [ebx].Keys.right, ecx				; keys->right = key down state
	jmp Return								; unconditional jump to Return

DownArrow:
	mov [ebx].Keys.down, ecx				; keys->down = key down state
	jmp Return								; unconditional jump to Return

ReturnKey:
	mov [ebx].Keys.start, ecx				; keys->start = key down state
	jmp Return								; unconditional jump to Return

Return:
	ret										; return from procedure
Win32_handleEvent ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_soundOutputOpen
; ______________________________________________________________________________
; Opens the given waveform-audio output device for playback.
;
; PARAMETERS
;	EAX = Sample rate - ex. 44100
;	BX  = Bit depth - ex. 16
;	CX  = Channels - ex. 2
;
; RETURNS
;	EAX = HWAVEOUT handle
;
; EXAMPLE
;	mov eax, 44100
;	mov bx, 16
;	mov cx, 1
;	call Win32_soundOutputOpen
;-------------------------------------------------------------------------------

Win32_soundOutputOpen PROC
	
	mov wavFormat.wFormatTag, WAVE_FORMAT_PCM ; audio format type
	mov wavFormat.nChannels, cx			; number of channels in audio data
	mov wavFormat.nSamplesPerSec, eax	; samples per second (hertz)
	mov wavFormat.nAvgBytesPerSec, eax	; average data-transfer rate
	mov wavFormat.wBitsPerSample, bx	; bit depth
	mov wavFormat.cbSize, 0				; extra format information

	movzx eax, cx						; AX = channels
	mul bx								; AX *= bit_depth
	shr ax, 3							; AX /= 8

	mov wavFormat.nBlockAlign, ax		; AX has the block align value

	mov ebx, wavFormat.nAvgBytesPerSec	; Load the sample_rate into EBX
	mul ebx								; EAX *= EBX
	mov wavFormat.nAvgBytesPerSec, eax	; EAX holds sample_rate * block_align

	INVOKE waveOutOpen,					; Win32 function
		ADDR wavOut,					; HWAVEOUT*
		WAVE_MAPPER,					; Audio output device to open
		ADDR wavFormat,					; WAVEFORMATEX*
		NULL,							; No callback
		0,								; No callback user data
		NULL							; CALLBACK_NULL

	cmp eax, MMSYSERR_NOERROR			; if (EAX != MMSYSERR_NOERROR)
	je L1								; jump if equal

	mError "Unable to open wave output."

L1:
	mov eax, wavOut						; set return value to HWAVEOUT
	ret									; return from procedure
Win32_soundOutputOpen ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_soundOutputPrepare
; ______________________________________________________________________________
; Prepares a waveform-audio data block for playback.
;
; PARAMETERS
;	EAX = HWAVEOUT handle 
;	EBX = Pointer to WAVEHDR struct
;	ECX = Number of times to play the loop
;	EDX = Audio buffer size
;	ESI = Audio buffer data
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, wavOut
;	mov ebx, OFFSET wavHeader
;	mov ecx, 1
;	mov edx, sndSize
;	mov esi, OFFSET snd
;	call Win32_soundOutputPrepare
;-------------------------------------------------------------------------------

Win32_soundOutputPrepare PROC
	
	mov [ebx].WAVEHDR.lpData, esi				; pointer to waveform buffer
	mov [ebx].WAVEHDR.dwBufferLength, edx		; buffer length in bytes
	mov [ebx].WAVEHDR.dwBytesRecorded, 0		; used for input, not output
	mov [ebx].WAVEHDR.dwUser, 0					; user data
	mov [ebx].WAVEHDR.dwFlags, WHDR_BEGINLOOP	; first buffer in a loop
	or [ebx].WAVEHDR.dwFlags, WHDR_ENDLOOP		; and last buffer in a loop
	mov [ebx].WAVEHDR.dwLoops, ecx				; number of times to loop
	mov [ebx].WAVEHDR.lpNext, 0					; reserved
	mov [ebx].WAVEHDR.reserved, 0				; reserved

	INVOKE waveOutPrepareHeader,		; Win32 function
		eax,							; HWAVEOUT handle
		ebx,							; WAVEHDR*
		TYPE WAVEHDR					; sizeof(WAVEHDR)

	cmp eax, MMSYSERR_NOERROR			; if (EAX != MMSYSERR_NOERROR)
	je L1								; jump if equal

	mError "Could not prepare header."

L1:
	ret									; return from procedure
Win32_soundOutputPrepare ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_soundOutputPlay
; ______________________________________________________________________________
; Sends a data block to the given waveform-audio output device.
;
; PARAMETERS
;	EAX = HWAVEOUT handle 
;	EBX = Pointer to WAVEHDR struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, wavOut
;	mov ebx, OFFSET wavHeader
;	call Win32_soundOutputPlay
;-------------------------------------------------------------------------------

Win32_soundOutputPlay PROC

	INVOKE waveOutWrite,				; Win32 function
		eax,							; HWAVEOUT handle
		ebx,							; WAVEHDR*
		TYPE WAVEHDR					; sizeof(WAVEHDR)

	cmp eax, MMSYSERR_NOERROR			; if (EAX != MMSYSERR_NOERROR)
	je L1								; jump if equal

	cmp eax, WAVERR_STILLPLAYING		; if (EAX == WAVERR_STILLPLAYING)
	je L1								; jump if equal -- return

	mError "Could not play sound."

L1:
	ret									; return from procedure
Win32_soundOutputPlay ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_soundOutputStop
; ______________________________________________________________________________
; Stops playback on the given waveform-audio output device.
;
; PARAMETERS
;	EAX = HWAVEOUT handle
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, wavOut
;	call Win32_soundOutputStop
;-------------------------------------------------------------------------------

Win32_soundOutputStop PROC

	INVOKE waveOutReset,				; Win32 function
		eax								; HWAVEOUT handle

	cmp eax, MMSYSERR_NOERROR			; if (EAX != MMSYSERR_NOERROR)
	je L1								; jump if equal

	mError "Could not reset sounds."

L1:
	ret									; return from procedure
Win32_soundOutputStop ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_messageBox
; ______________________________________________________________________________
; Displays a graphical popup box with a message
;
; PARAMETERS
;	EAX = contains a pointer to the message string
;
; RETURNS
;	EAX = The return value of the MessageBoxA call
;
; EXAMPLE
;	mov eax, OFFSET message
;	call Win32_messageBox
;-------------------------------------------------------------------------------

Win32_messageBox PROC

	INVOKE MessageBoxA,					; Win32 function
		NULL,							; A handle to the owner window
		eax,							; Pointer to message to be displayed
		ADDR messageBoxCaption,			; Pointer to dialog box title
		MB_OK							; OK push button

	ret									; return from procedure
Win32_messageBox ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Win32_setCursor
; ______________________________________________________________________________
; Sets the cursor position in the specified console screen buffer.
;
; PARAMETERS
;	EAX = A handle to the console output buffer
;	EBX = Pointer to COORD
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, stdOutputHandle
;	mov ebx, OFFSET position
;	call Win32_setCursor
;-------------------------------------------------------------------------------

Win32_setCursor PROC

	INVOKE SetConsoleCursorPosition,	; Win32 console function
		eax,							; STD_OUTPUT_HANDLE
		[ebx]							; dereference COORD*

	cmp eax, FALSE						; if (EAX == FALSE)
	jne L1								; jump if not equal

	mError "Unable to set cursor position."

L1:
	ret									; return from procedure
Win32_setCursor ENDP

;-------------------------------------------------------------------------------

end

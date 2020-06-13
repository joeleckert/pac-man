
IFNDEF WINDOWS_INC
WINDOWS_INC EQU 1

;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

NULL EQU 0

FALSE EQU 0
TRUE  EQU 1

STD_INPUT_HANDLE  EQU -10
STD_OUTPUT_HANDLE EQU -11

INVALID_HANDLE_VALUE EQU -1

KEY_EVENT EQU 1

MB_OK        EQU 0
MB_ICONERROR EQU 010h

VK_RETURN EQU 0Dh
VK_LEFT   EQU 25h
VK_UP     EQU 26h
VK_RIGHT  EQU 27h
VK_DOWN   EQU 28h

WAVE_FORMAT_PCM EQU 1
WAVE_MAPPER EQU -1

MMSYSERR_NOERROR EQU 0
WHDR_BEGINLOOP EQU 4
WHDR_ENDLOOP EQU 8
WAVERR_STILLPLAYING EQU 33

;-------------------------------------------------------------------------------
; Typedefs
;-------------------------------------------------------------------------------

CHAR TYPEDEF BYTE

WCHAR TYPEDEF WORD

HANDLE TYPEDEF DWORD
HWND TYPEDEF DWORD
HWAVEOUT TYPEDEF DWORD
MMRESULT TYPEDEF DWORD

BOOL TYPEDEF SDWORD
LONG TYPEDEF SDWORD

LONGLONG TYPEDEF SQWORD

;-------------------------------------------------------------------------------
; Structures
;-------------------------------------------------------------------------------

COORD STRUCT
	X SWORD ?
	Y SWORD ?
COORD ENDS

;-------------------------------------------------------------------------------

SMALL_RECT STRUCT
	Left SWORD ?
	Top SWORD ?
	Right SWORD ?
	Bottom SWORD ?
SMALL_RECT ENDS

;-------------------------------------------------------------------------------

CONSOLE_CURSOR_INFO STRUCT
	dwSize DWORD ?
	bVisible BOOL ?
CONSOLE_CURSOR_INFO ENDS

;-------------------------------------------------------------------------------

CHAR_INFO STRUCT
	UNION Char
		UnicodeChar WCHAR ?
		AsciiChar CHAR ?
	ENDS
	Attributes WORD ?
CHAR_INFO ENDS

;-------------------------------------------------------------------------------

KEY_EVENT_RECORD STRUCT
	bKeyDown BOOL ?
	wRepeatCount WORD ?
	wVirtualKeyCode WORD ?
	wVirtualScanCode WORD ?
	UNION uChar
		UnicodeChar WCHAR ?
		AsciiChar CHAR ?
	ENDS
	dwControlKeyState DWORD ?
KEY_EVENT_RECORD ENDS

;-------------------------------------------------------------------------------

MOUSE_EVENT_RECORD STRUCT
	dwMousePosition COORD <>
	dwButtonState DWORD ?
	dwControlKeyState DWORD ?
	dwEventFlags DWORD ?
MOUSE_EVENT_RECORD ENDS

;-------------------------------------------------------------------------------

WINDOW_BUFFER_SIZE_RECORD STRUCT
	dwSize COORD <>
WINDOW_BUFFER_SIZE_RECORD ENDS

;-------------------------------------------------------------------------------

MENU_EVENT_RECORD STRUCT
	dwCommandId DWORD ?
MENU_EVENT_RECORD ENDS

;-------------------------------------------------------------------------------

FOCUS_EVENT_RECORD STRUCT
	bSetFocus BOOL ?
FOCUS_EVENT_RECORD ENDS

;-------------------------------------------------------------------------------

INPUT_RECORD STRUCT
	EventType WORD ?
	ALIGN DWORD
	UNION Event
		KeyEvent KEY_EVENT_RECORD <>
		MouseEvent MOUSE_EVENT_RECORD <>
		WindowBufferSizeEvent WINDOW_BUFFER_SIZE_RECORD <>
		MenuEvent MENU_EVENT_RECORD <>
		FocusEvent FOCUS_EVENT_RECORD <>
	ENDS
INPUT_RECORD ENDS

;-------------------------------------------------------------------------------

WAVEFORMATEX STRUCT
	wFormatTag WORD ?
	nChannels WORD ?
	nSamplesPerSec DWORD ?
	nAvgBytesPerSec DWORD ?
	nBlockAlign WORD ?
	wBitsPerSample WORD ?
	cbSize WORD ?
WAVEFORMATEX ENDS

;-------------------------------------------------------------------------------

WAVEHDR STRUCT
	lpData DWORD ?
	dwBufferLength DWORD ?
	dwBytesRecorded DWORD ?
	dwUser DWORD ?
	dwFlags DWORD ?
	dwLoops DWORD ?
	lpNext DWORD ?
	reserved DWORD ?
WAVEHDR ENDS

;-------------------------------------------------------------------------------

SYSTEMTIME STRUCT
	wYear WORD ?
	wMonth WORD ?
	wDayOfWeek WORD ?
	wDay WORD ?
	wHour WORD ?
	wMinute WORD ?
	wSecond WORD ?
	wMilliseconds WORD ?
SYSTEMTIME ENDS

;-------------------------------------------------------------------------------

LARGE_INTEGER UNION
	STRUCT DUMMYSTRUCTNAME
		LowPart DWORD ?
		HighPart LONG ?
	ENDS
	STRUCT u
		LowPart DWORD ?
		HighPart LONG ?
	ENDS
	QuadPart LONGLONG ?
LARGE_INTEGER ENDS

;-------------------------------------------------------------------------------
; Prototypes
;-------------------------------------------------------------------------------

ExitProcess PROTO,
	uExitCode:DWORD

GetConsoleCursorInfo PROTO,
	hConsoleOutput:HANDLE,
	lpConsoleCursorInfo:PTR CONSOLE_CURSOR_INFO

GetLastError PROTO

GetNumberOfConsoleInputEvents PROTO,
	hConsoleInput:HANDLE,
	lpNumberOfEvents:PTR DWORD

GetStdHandle PROTO,
	nStdHandle:DWORD

GetSystemTime PROTO,
	lpSystemTime:PTR SYSTEMTIME

MessageBoxA PROTO,
	hWnd:HWND,
	lpText:PTR CHAR,
	lpCaption:PTR CHAR,
	uType:DWORD

QueryPerformanceCounter PROTO,
	lpPerformanceCount:PTR LARGE_INTEGER

QueryPerformanceFrequency PROTO,
	lpFrequency:PTR LARGE_INTEGER

ReadConsoleInputW PROTO,
	hConsoleInput:HANDLE,
	lpBuffer:PTR INPUT_RECORD,
	nLength:DWORD,
	lpNumberOfEventsRead:PTR DWORD

SetConsoleCursorInfo PROTO,
	hConsoleOutput:HANDLE,
	lpConsoleCursorInfo:PTR CONSOLE_CURSOR_INFO

SetConsoleCursorPosition PROTO,
	hConsoleOutput:HANDLE,
	dwCursorPosition:COORD

Sleep PROTO,
	dwMilliseconds:DWORD

WriteConsoleOutputW PROTO,
	hConsoleOutput:HANDLE,
	lpBuffer:PTR CHAR_INFO,
	dwBufferSize:COORD,
	dwBufferCoord:COORD,
	lpWriteRegion:PTR SMALL_RECT

waveOutOpen PROTO,
	phwo:PTR HWAVEOUT,
	uDeviceID:DWORD,
	pwfx:PTR WAVEFORMATEX,
	dwCallback:PTR DWORD,
	dwInstance:PTR DWORD,
	fdwOpen:DWORD

waveOutPrepareHeader PROTO,
	hwo:HWAVEOUT,
	pwh:PTR WAVEHDR,
	cbwh:DWORD

waveOutWrite PROTO,
	hwo:HWAVEOUT,
	pwh:PTR WAVEHDR,
	cbwh:DWORD

waveOutReset PROTO,
	hwo:HWAVEOUT

;-------------------------------------------------------------------------------

ENDIF ; WINDOWS_INC

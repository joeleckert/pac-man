
.386
.model flat, stdcall
.stack 4096

;-------------------------------------------------------------------------------

INCLUDE Game.inc
INCLUDE GameMap.inc
INCLUDE Screen.inc
INCLUDE Defines.inc
INCLUDE Sound.inc
INCLUDE Utils.inc

;-------------------------------------------------------------------------------

BEGINNING_MUSIC EQU 417

PASS_LEVEL_TIME EQU 383

;-------------------------------------------------------------------------------

GAME_STATE_PLAYER_INTRO   EQU 0
GAME_STATE_READY          EQU 1
GAME_STATE_PLAY           EQU 2
GAME_STATE_PAUSE          EQU 3
GAME_STATE_GHOST_KILLED   EQU 4
GAME_STATE_PAC_MAN_KILLED EQU 5
GAME_STATE_LEVEL_COMPLETE EQU 6
GAME_STATE_GAME_OVER      EQU 7

;-------------------------------------------------------------------------------

.data
highScoreTitle BYTE "HIGH SCORE", 0
oneUpTitle     BYTE "1UP", 0
playerOneText  BYTE "PLAYER ONE", 0
readyText      BYTE "READY!", 0
pauseText      BYTE "PAUSE", 0
gameOverText   BYTE "GAME  OVER", 0

gamePoint Point <>
gameBoard Game <>

;-------------------------------------------------------------------------------

.code

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToPlayerIntro
; ______________________________________________________________________________
; Sets up the PLAYER INTRO game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_switchModeToPlayerIntro
;-------------------------------------------------------------------------------

Game_switchModeToPlayerIntro PROC

	mov gameBoard.mGameState, GAME_STATE_PLAYER_INTRO	; state = PLAYER_INTRO
	mov gameBoard.mTimer, BEGINNING_MUSIC				; set timer duration

	mov eax, 9							; x-position
	mov ebx, 8							; y-position
	mov dx, CYAN						; text color
	mov esi, OFFSET playerOneText		; ESI = pointer to ASCII text
	call Screen_setScreenText			; show text

	call Game_showReadyText				; show "READY!" text

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	mov ebx, FALSE						; hide Pac-Man
	call PacMan_setVisible				; set visibility

	mov eax, FALSE						; hide all ghosts
	call Game_ghostsVisible				; set visibility

	mov eax, SOUND_BEGINNING			; EAX = sound to play
	call Sound_playSound				; play the sound
	ret									; return from procedure
Game_switchModeToPlayerIntro ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToReady
; ______________________________________________________________________________
; Sets up the READY game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_switchModeToReady
;-------------------------------------------------------------------------------

Game_switchModeToReady PROC

	mov gameBoard.mGameState, GAME_STATE_READY	; state = READY
	mov gameBoard.mSoundTrack, SOUND_SIREN		; soundTrack = SIREN

	call Game_clearPlayerText					; remove "PLAYER ONE" text
	call Game_showReadyText						; show "READY!" text

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	mov ebx, TRUE								; show Pac-Man
	call PacMan_setVisible						; set visibility

	mov eax, TRUE								; show all ghosts
	call Game_ghostsVisible						; set visibility

	mov eax, OFFSET gameBoard.mEnergizerFlash	; EAX = &self->mEnergizerFlash
	call EnergizerFlash_constructor				; call constructor

	mov eax, OFFSET gameBoard.mGameMapFlash		; EAX = &self->mGameMapFlash
	call GameMapFlash_constructor				; call constructor

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_getLevel						; EAX = Level*
	call Level_drawScreen						; draw the level symbols

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_getLives						; EAX = Lives*
	call Lives_drawScreen						; draw the lives on screen

	mov eax, OFFSET gameBoard.mBonusScore		; EAX = &self->mBonusScore
	call ScoreSprites_reset						; hide sprites from screen

	mov eax, OFFSET gameBoard.mEnergizerScore	; EAX = &self->mEnergizerScore
	call ScoreSprites_reset						; hide sprites from screen

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_getBonusSymbol					; EAX = BonusSymbol*
	call BonusSymbol_reset						; reset bonus symbol

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_getLevel						; EAX = Level*
	call Level_getCurrent						; EAX = the current level

	call Game_setupSprites						; setup sprites for level
	call Game_stopBlueTime						; reset blue time for level

	mov gameBoard.mTimer, SECONDS_2				; set timer duration
	ret
Game_switchModeToReady ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToPlay
; ______________________________________________________________________________
; Sets up the PLAY game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_switchModeToPlay
;-------------------------------------------------------------------------------

Game_switchModeToPlay PROC

	mov gameBoard.mGameState, GAME_STATE_PLAY	; state = PLAY
	mov gameBoard.mEatenGhost, NULL				; self->mEatenGhost = NULL

	call Game_clearReadyText			; clear "READY!" from game screen

	mov eax, TRUE						; EAX = TRUE
	call Game_ghostsVisible				; show all ghosts

	mov eax, 30							; x-position
	mov ebx, 14							; y-position
	mov esi, 5							; number of characters to clear
	call Screen_clearScreenText			; clear "PAUSE" from game screen

	mov eax, gameBoard.mSoundTrack		; EAX = main sound track loop
	call Sound_playSound				; play the sound
	ret									; return from procedure
Game_switchModeToPlay ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToPause
; ______________________________________________________________________________
; Sets up the PAUSE game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_switchModeToPause
;-------------------------------------------------------------------------------

Game_switchModeToPause PROC

	mov gameBoard.mGameState, GAME_STATE_PAUSE	; state = PAUSE

	mov eax, 30							; x-position
	mov ebx, 14							; y-position
	mov dx, CYAN						; text color
	mov esi, OFFSET pauseText			; ESI = pointer to ASCII text
	call Screen_setScreenText			; show text

	call Sound_stopAllSounds			; shut off all sounds

	mov eax, SOUND_PAUSE				; EAX = sound to play
	call Sound_playSound				; play sound
	ret									; return from procedure
Game_switchModeToPause ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToPacManKilled
; ______________________________________________________________________________
; Sets up the PAC_MAN_KILLED game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_switchModeToPacManKilled
;-------------------------------------------------------------------------------

Game_switchModeToPacManKilled PROC

	mov gameBoard.mGameState, GAME_STATE_PAC_MAN_KILLED	; state = PAC_MAN_KILLED
	mov gameBoard.mTimer, SECONDS_2						; set timer duration

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	mov ebx, FALSE						; hide Pac-Man
	call PacMan_setVisible				; set visibility

	call Sound_stopAllSounds			; shut off all sounds

	mov eax, SOUND_KILLED				; EAX = sound to play
	call Sound_playSound				; play sound
	ret									; return from procedure
Game_switchModeToPacManKilled ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToGhostKilled
; ______________________________________________________________________________
; Sets up the GHOST_KILLED game state.
;
; PARAMETERS
;	EAX = Contains a pointer to the ghost that was killed
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET ghost
;	call Game_switchModeToGhostKilled
;-------------------------------------------------------------------------------

Game_switchModeToGhostKilled PROC

	mov gameBoard.mGameState, GAME_STATE_GHOST_KILLED	; state = GHOST_KILLED
	mov gameBoard.mEatenGhost, eax						; save pointer of ghost
	mov gameBoard.mTimer, SECONDS_1						; set timer duration

	mov ebx, FALSE						; hide ghost
	call Ghost_setVisible				; set visibility
	
	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getPoint				; EAX = Point*

	mov ebx, eax						; EBX = source point
	mov eax, OFFSET gamePoint			; destination point
	call Utils_copyPoint				; copy Pac-Man point

	sub gamePoint.x, 2					; center score sprites

	mov ebx, gameBoard.mBlueScore		; gets the score for eating the ghost
	shl gameBoard.mBlueScore, 1			; self->mBlueScore <<= 1

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getScore				; EAX = Score*
	call Score_add						; add to Pac-Man's score in EBX

	mov eax, OFFSET gameBoard.mEnergizerScore	; EAX = &self->mEnergizerScore
	call ScoreSprites_setValue					; set score to sprites

	mov eax, OFFSET gameBoard.mEnergizerScore	; EAX = &self->mEnergizerScore
	mov ebx, OFFSET gamePoint					; starting point for sprites
	call ScoreSprites_setLocation				; set sprites at location

	mov eax, SOUND_CHOMP				; EAX = sound to stop
	call Sound_stopSound				; stop sound

	mov eax, SOUND_EAT_GHOST			; EAX = sound to play
	call Sound_playSound				; play sound
	ret									; return from procedure
Game_switchModeToGhostKilled ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToLevelComplete
; ______________________________________________________________________________
; Sets up the LEVEL_COMPLETE game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_switchModeToLevelComplete
;-------------------------------------------------------------------------------

Game_switchModeToLevelComplete PROC

	mov gameBoard.mGameState, GAME_STATE_LEVEL_COMPLETE	; state = LEVEL_COMPLETE
	mov gameBoard.mTimer, PASS_LEVEL_TIME				; set timer duration

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getLevel				; EAX = Level*
	call Level_passed					; advance to the next level

	call Sound_stopAllSounds			; stop all sounds
	ret									; return from procedure
Game_switchModeToLevelComplete ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_switchModeToGameOver
; ______________________________________________________________________________
; Sets up the GAME_OVER game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_switchModeToGameOver
;-------------------------------------------------------------------------------

Game_switchModeToGameOver PROC

	mov gameBoard.mGameState, GAME_STATE_GAME_OVER	; state = GAME_OVER
	mov gameBoard.mTimer, PASS_LEVEL_TIME			; set timer duration

	mov eax, 9							; x-position
	mov ebx, 14							; y-position
	mov dx, RED							; text color
	mov esi, OFFSET gameOverText		; ESI = pointer to ASCII text
	call Screen_setScreenText			; show text

	ret									; return from procedure
Game_switchModeToGameOver ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_startBlueTime
; ______________________________________________________________________________
; Starts the blue time session.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_startBlueTime
;-------------------------------------------------------------------------------

Game_startBlueTime PROC

	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Done							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	call Ghost_blueTimeStart			; start blue time

	inc esi								; index++
	jmp L1								; unconditional jump

Done:
	mov gameBoard.mBlueTime, TRUE		; start blue time
	mov gameBoard.mBlueScore, 200		; score of first eaten ghost

	mov eax, SOUND_SIREN				; EAX = sound to stop
	call Sound_stopSound				; stop playing sound

	cmp gameBoard.mSoundTrack, SOUND_FLY_TO_PEN		; if (sound != FLY_TO_PEN)
	je Return										; jump if equal

	mov gameBoard.mSoundTrack, SOUND_ENERGIZER_MODE	; ENERGIZER_MODE sound loop

Return:
	ret									; return from procedure
Game_startBlueTime ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_stopBlueTime
; ______________________________________________________________________________
; Stops the blue time session.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_stopBlueTime
;-------------------------------------------------------------------------------

Game_stopBlueTime PROC

	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Done							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	call Ghost_blueTimeStop				; stop blue time

	inc esi								; index++
	jmp L1								; unconditional jump

Done:
	mov gameBoard.mBlueTime, FALSE		; cancel blue time
	mov gameBoard.mBlueScore, 0			; reset blue time score

	mov eax, SOUND_ENERGIZER_MODE		; EAX = sound to stop
	call Sound_stopSound				; stop playing sound
	ret									; return from procedure
Game_stopBlueTime ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_blueTime
; ______________________________________________________________________________
; Processes the blue time session.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_blueTime
;-------------------------------------------------------------------------------

Game_blueTime PROC

	cmp gameBoard.mBlueTime, FALSE		; if (self->mBlueTime == FALSE)
	je Return							; jump if equal

	mov ecx, FALSE						; isGhostBlue = FALSE
	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Done							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	call Ghost_blueTime					; handle blue time

	cmp eax, TRUE						; is ghost in blue time state?
	jne Next							; jump if not equal

	mov ecx, TRUE						; isGhostBlue = TRUE

Next:
	inc esi								; index++
	jmp L1								; unconditional jump

Done:
	cmp ecx, FALSE						; if (isGhostBlue == FALSE)
	jne Return							; jump if not equal

	call Game_stopBlueTime				; stop blue time

Return:
	ret									; return from procedure
Game_blueTime ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_dotCount
; ______________________________________________________________________________
; Counts the total number of dots that are on the game map.
;
; PARAMETERS
;	None
;
; RETURNS
;	EAX = The dot count
;
; EXAMPLE
;	call Game_dotCount
;-------------------------------------------------------------------------------

Game_dotCount PROC

	mov ecx, 0							; total = 0
	mov esi, 0							; y index

L1:
	cmp esi, GAME_MAP_HEIGHT			; (ESI < GAME_MAP_HEIGHT)
	jge Return							; jump if greater than or equal

	mov edi, 0							; x index
	
L2:
	cmp edi, GAME_MAP_WIDTH				; (EDI < GAME_MAP_WIDTH)
	jge L1_Next							; jump if greater than or equal

	mov eax, edi						; x-position
	mov ebx, esi						; y-position
	call Screen_getChar					; get character at position

	cmp eax, DOT						; case DOT:
	je S1								; jump if equal

	cmp eax, ENERGIZER					; case ENERGIZER:
	je S1								; jump if equal

	jmp L2_Next							; default: unconditional jump

S1:
	inc ecx								; total++

L2_Next:
	inc edi								; x++
	jmp L2								; unconditional jump

L1_Next:
	inc esi								; y++
	jmp L1								; unconditional jump

Return:
	mov eax, ecx						; return total
	ret									; return from procedure
Game_dotCount ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_fruitHitTest
; ______________________________________________________________________________
; Checks to see if enough dots have been eaten so that a bonus symbol appears.
;
; PARAMETERS
;	EAX = The dot count
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, dotCount
;	call Game_fruitHitTest
;-------------------------------------------------------------------------------

Game_fruitHitTest PROC

	push eax							; push dotCount on stack

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getBonusSymbol			; EAX = BonusSymbol*

	push eax							; push BonusSymbol* on stack
	mov ebx, OFFSET gameBoard.mPlayer	; EBX = Pac-Man*
	call BonusSymbol_hitTest			; EAX = bonusPoints

	cmp eax, 0							; if (bonusPoints > 0)
	jle Done							; jump if less than or equal

	mov ebx, eax						; EBX = bonusPoints
	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getScore				; EAX = Score*
	call Score_add						; add bonus points in EBX to Pac-Man

	mov eax, OFFSET gameBoard.mBonusScore	; EAX = &self->mBonusScore
	call ScoreSprites_setValue				; set score to sprites

	mov eax, SOUND_EAT_FRUIT			; EAX = sound to play
	call Sound_playSound				; play sound

Done:
	pop eax								; pop BonusSymbol* off stack
	pop ebx								; pop dotCount on stack
	call BonusSymbol_showSymbol			; show bonus symbol if correct dot count
	call BonusSymbol_drawScreen			; draw bonus symbol on screen

	ret									; return from procedure
Game_fruitHitTest ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_hitTest
; ______________________________________________________________________________
; Test for collision between Pac-Man and the ghosts.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_hitTest
;-------------------------------------------------------------------------------

Game_hitTest PROC

	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Return							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	push eax							; push Ghost* on the stack

	mov ebx, OFFSET gameBoard.mPlayer	; EBX = Pac-Man*
	call Ghost_hitTest					; check for collision

	pop edx								; pop Ghost* off the stack

	cmp eax, HIT_TEST_PAC_MAN_KILLED	; if (state == PAC_MAN_KILLED)
	jne C1								; jump if not equal

	call Game_switchModeToPacManKilled	; change game mode
	jmp Return							; unconditional jump

C1:
	cmp eax, HIT_TEST_GHOST_KILLED		; if (state == GHOST_KILLED)
	jne Next							; jump if not equal

	mov eax, edx						; EAX = Ghost*
	call Game_switchModeToGhostKilled	; change game mode
	jmp Return							; unconditional jump

Next:
	inc esi								; index++
	jmp L1								; unconditional jump

Return:
	ret									; return from procedure
Game_hitTest ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_ghostsVisible
; ______________________________________________________________________________
; Controls the visibility of all the ghosts.
;
; PARAMETERS
;	EAX = Boolean that sets the visibility
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_ghostsVisible
;-------------------------------------------------------------------------------

Game_ghostsVisible PROC

	mov ebx, eax						; EBX = visibility
	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Return							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	call Ghost_setVisible				; set visibility in EBX

	inc esi								; index++
	jmp L1								; unconditional jump

Return:
	ret									; return from procedure
Game_ghostsVisible ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_ghostHouseTimer
; ______________________________________________________________________________
; Controls when the ghosts get released from the ghost house.
;
; PARAMETERS
;	EAX = TRUE if Pac-Man ate a dot, FALSE otherwise
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_ghostHouseTimer
;-------------------------------------------------------------------------------

Game_ghostHouseTimer PROC

	mov ebx, eax						; EBX = ateDot
	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Return							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	push eax							; push Ghost* on stack
	call Ghost_inGhostHouse				; is ghost in ghost house?

	cmp eax, TRUE						; if (inGhostHouse() == TRUE)
	pop eax								; pop Ghost* off stack
	jne Next							; jump if not equal

	call Ghost_ghostHouseTimer			; run ghost house timer for ghost
	jmp Return							; unconditional jump

Next:
	inc esi								; index++
	jmp L1								; unconditional jump

Return:
	ret									; return from procedure
Game_ghostHouseTimer ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_movePacMan
; ______________________________________________________________________________
; Handles moving Pac-Man around the game map.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_movePacMan
;-------------------------------------------------------------------------------

Game_movePacMan PROC

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	mov ebx, gameBoard.mBlueTime		; EBX = is blue time state
	call PacMan_move					; move Pac-Man

	mov ecx, FALSE						; ateDot = FALSE

	cmp eax, PAC_MAN_MODE_EATING_ENERGIZER	; if (EAX == EATING_ENERGIZER)
	jne C1									; jump if not equal

	mov ecx, TRUE						; ateDot = TRUE
	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getScore				; EAX = Score*

	mov ebx, 50							; 50 points
	call Score_add						; add to Pac-Man score
	call Game_startBlueTime				; start blue time

	mov eax, SOUND_CHOMP				; EAX = sound to play
	call Sound_playSound				; play sound
	jmp C3								; unconditional jump

C1:
	cmp eax, PAC_MAN_MODE_EATING_DOT	; if (EAX == EATING_DOT)
	jne C2								; jump if not equal

	mov ecx, TRUE						; ateDot = TRUE
	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getScore				; EAX = Score*

	mov ebx, 10							; 10 points
	call Score_add						; add to Pac-Man score

	mov eax, SOUND_CHOMP				; EAX = sound to play
	call Sound_playSound				; play sound
	jmp C3								; unconditional jump

C2:
	cmp eax, PAC_MAN_MODE_NOT_EATING	; if (EAX == NOT_EATING)
	jne C3								; jump if not equal

	mov eax, SOUND_CHOMP				; EAX = sound to stop
	call Sound_stopSound				; stop playing sound

C3:
	mov eax, ecx						; EAX = ateDot
	call Game_ghostHouseTimer			; run ghost house timer
	ret									; return from procedure
Game_movePacMan ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_moveGhosts
; ______________________________________________________________________________
; Handles moving ghosts around the game map.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_moveGhosts
;-------------------------------------------------------------------------------

Game_moveGhosts PROC

	mov ecx, FALSE						; isEaten = FALSE
	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge C1								; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	mov ebx, OFFSET gameBoard.mPlayer	; EBX = Pac-Man*
	call Ghost_move						; move ghost on game board

	call Ghost_isEaten					; check if ghost is eaten

	cmp eax, TRUE						; if (isEaten == TRUE)
	jne Next							; jump if not equal

	mov ecx, TRUE						; isEaten = TRUE

Next:
	inc esi								; index++
	jmp L1								; unconditional jump

C1:
	cmp ecx, FALSE						; if (isEaten == FALSE)
	jne Return							; jump if not equal

	mov eax, SOUND_FLY_TO_PEN			; EAX = sound to stop
	call Sound_stopSound				; stop playing sound

	cmp gameBoard.mBlueTime, TRUE		; if (self->mBlueTime == TRUE)
	jne C2								; jump if not equal

	mov gameBoard.mSoundTrack, SOUND_ENERGIZER_MODE	; soundTrack = ENERGIZER
	jmp C3

C2:
	mov gameBoard.mSoundTrack, SOUND_SIREN			; soundTrack = SIREN

C3:
	mov eax, gameBoard.mSoundTrack		; EAX = sound to play
	call Sound_playSound				; play sound

Return:
	ret									; return from procedure
Game_moveGhosts ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_showReadyText
; ______________________________________________________________________________
; Displays the text "READY!" on the game map.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_showReadyText
;-------------------------------------------------------------------------------

Game_showReadyText PROC

	mov eax, 11							; x-position
	mov ebx, 14							; y-position
	mov dx, YELLOW						; text color
	mov esi, OFFSET readyText			; ESI = pointer to ASCII text
	call Screen_setScreenText			; show text

	ret									; return from procedure
Game_showReadyText ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_clearPlayerText
; ______________________________________________________________________________
; Clears the text that says "PLAYER ONE" from the game map.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_clearPlayerText
;-------------------------------------------------------------------------------

Game_clearPlayerText PROC

	mov eax, 9							; x-position
	mov ebx, 8							; y-position
	mov esi, 10							; number of characters to clear
	call Screen_clearScreenText			; clear text

	ret									; return from procedure
Game_clearPlayerText ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_clearReadyText
; ______________________________________________________________________________
; Clears the text that says "READY!" from the game map.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_clearReadyText
;-------------------------------------------------------------------------------

Game_clearReadyText PROC

	mov eax, 11							; x-position
	mov ebx, 14							; y-position
	mov esi, 6							; number of characters to clear
	call Screen_clearScreenText			; clear text

	ret									; return from procedure
Game_clearReadyText ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_setupSprites
; ______________________________________________________________________________
; Setup Pac-Man and the ghost sprites for the start of a level.
;
; PARAMETERS
;	EAX = The current level
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, level
;	call Game_setupSprites
;-------------------------------------------------------------------------------

Game_setupSprites PROC

	push eax							; push current level on stack

	mov ebx, eax						; EBX = the current level
	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_defaultPosition			; set default position

	pop ebx								; pop current level off stack
	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Return							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	call Ghost_defaultPosition			; set default position

	inc esi								; index++
	jmp L1								; unconditional jump

Return:
	ret									; return from procedure
Game_setupSprites ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_newLevel
; ______________________________________________________________________________
; Set up the new level. The current level is stored in the Pac-Man class.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_newLevel
;-------------------------------------------------------------------------------

Game_newLevel PROC

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getLevel				; EAX = Level*

	call Level_getCurrent				; EAX = current level
	mov ebx, eax						; move result into EBX

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_getBonusSymbol			; EAX = BonusSymbol*

	call BonusSymbol_setLevel			; set bonus symbol based on level in EBX

	mov eax, OFFSET gameMap				; EAX = pointer to game map array
	mov ebx, OFFSET gameMapColors		; EBX = pointer to game map colors array
	call Screen_blitScreen				; blit the entire screen

	call Game_switchModeToReady			; switch game state
	ret									; return from procedure
Game_newLevel ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_nonStopAnimation
; ______________________________________________________________________________
; Animation that does not stop during a pause or game over.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_nonStopAnimation
;-------------------------------------------------------------------------------

Game_nonStopAnimation PROC

	mov eax, OFFSET gameBoard.mHighScore	; EAX = &self->mHighScore
	call Score_drawScreen					; draw score on screen

	mov eax, OFFSET gameBoard.mPlayer		; EAX = Pac-Man*
	call PacMan_getScore					; EAX = Score*
	call Score_drawScreen					; draw score on screen

	ret										; return from procedure
Game_nonStopAnimation ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_gameAnimation
; ______________________________________________________________________________
; Animation that runs during normal game play.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_gameAnimation
;-------------------------------------------------------------------------------

Game_gameAnimation PROC

	mov eax, OFFSET gameBoard.mBonusScore		; EAX = &self->mBonusScore
	call ScoreSprites_drawScreen				; draw sprites on screen

	mov eax, OFFSET gameBoard.mEnergizerScore	; EAX = &self->mEnergizerScore
	call ScoreSprites_drawScreen				; draw sprites on screen

	mov eax, OFFSET gameBoard.mEnergizerFlash	; EAX = &self->mEnergizerFlash
	call EnergizerFlash_drawScreen				; flash energizers

	ret											; return from procedure
Game_gameAnimation ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_modePlayerIntro
; ______________________________________________________________________________
; The code that runs the PLAYER_INTRO game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_modePlayerIntro
;-------------------------------------------------------------------------------

Game_modePlayerIntro PROC

	dec gameBoard.mTimer				; self->mTimer--
	cmp gameBoard.mTimer, SECONDS_2		; if (self->mTimer == SECONDS_2)
	jne Return							; jump if not equal

	call Game_switchModeToReady			; switch to READY game state

Return:
	ret									; return from procedure
Game_modePlayerIntro ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_modeReady
; ______________________________________________________________________________
; The code that runs the READY game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_modeReady
;-------------------------------------------------------------------------------

Game_modeReady PROC

	dec gameBoard.mTimer				; self->mTimer--
	cmp gameBoard.mTimer, 0				; if (self->mTimer == 0)
	jne Return							; jump if not equal

	call Game_switchModeToPlay			; switch to READY game state

Return:
	ret									; return from procedure
Game_modeReady ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_modePlay
; ______________________________________________________________________________
; The code that runs the PLAY game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_modePlay
;-------------------------------------------------------------------------------

Game_modePlay PROC

	call Game_blueTime							; handle blue time
	
	call Game_movePacMan						; move Pac-Man
	call Game_hitTest							; check for collisions

	cmp gameBoard.mGameState, GAME_STATE_PLAY	; if still in PLAY game mode
	jne C1										; jump if not equal

	call Game_moveGhosts						; move all ghosts
	call Game_hitTest							; check for collisions

C1:
	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	mov ebx, 10000								; score needed for extra guy
	call PacMan_didEarnExtraGuy					; check if earned extra guy

	cmp eax, TRUE								; if (didEarnExtraGuy == TRUE)
	jne C2										; jump if not equal

	mov eax, SOUND_EXTRA_GUY					; EAX = sound to play
	call Sound_playSound						; play sound

C2:
	call Game_dotCount							; get the total dots on board

	push eax									; push dotCount on stack
	call Game_fruitHitTest						; process Bonus Symbol

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_getScore						; get score class for Pac-Man

	mov ebx, eax								; EBX = Pac-Man Score*
	mov eax, OFFSET gameBoard.mHighScore		; EAX = &self->mHighScore
	call Score_setHighScore						; see if score is new high score
	call Game_gameAnimation						; do all game animations

	pop eax										; pop dotCount off stack

	cmp eax, 0									; if (dotCount == 0)
	jne Return									; jump if not equal

	call Game_switchModeToLevelComplete			; change game mode

Return:
	ret											; return from procedure
Game_modePlay ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_modeGhostKilled
; ______________________________________________________________________________
; The code that runs the GHOST_KILLED game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_modeGhostKilled
;-------------------------------------------------------------------------------

Game_modeGhostKilled PROC

	dec gameBoard.mTimer				; self->mTimer--

	cmp gameBoard.mTimer, 0				; if (self->mTimer == 0)
	jne SetupLoop						; jump if not equal

	mov gameBoard.mSoundTrack, SOUND_FLY_TO_PEN	; soundTrack = FLY_TO_PEN

	mov eax, SOUND_ENERGIZER_MODE		; EAX = sound to stop
	call Sound_stopSound				; stop sound
	call Game_switchModeToPlay			; change game state

SetupLoop:
	mov esi, 0							; loop index

L1:
	cmp esi, TOTAL_GHOSTS				; (ESI < TOTAL_GHOSTS)
	jge Done							; jump if greater than or equal

	mov eax, TYPE Ghost					; EAX = sizeof(Ghost)
	imul esi							; EAX *= loop index
	mov edx, OFFSET gameBoard.mGhosts	; EDX = address of ghosts array
	add eax, edx						; add the offset to the address

	cmp eax, gameBoard.mEatenGhost		; if (EAX == self->mEatenGhost
	jne C1								; jump if not equal

	cmp gameBoard.mTimer, 7				; && self->mTimer > 7)
	jg Next								; jump if greater than

C1:
	mov edx, eax						; EDX = Ghost*
	call Ghost_isEaten					; check if ghost has been eaten

	cmp eax, TRUE						; if (isEaten == TRUE)
	jne Next							; jump if not equal

	mov eax, edx						; EAX = Ghost*
	mov ebx, TRUE						; set visibility to TRUE
	call Ghost_setVisible				; show ghost

	mov ebx, OFFSET gameBoard.mPlayer	; EBX = Pac-Man*
	call Ghost_move						; move eaten ghost

Next:
	inc esi								; index++
	jmp L1								; unconditional jump

Done:
	call Game_gameAnimation				; do all game animations
	ret									; return from procedure
Game_modeGhostKilled ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_modePacManKilled
; ______________________________________________________________________________
; The code that runs the PAC_MAN_KILLED game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_modePacManKilled
;-------------------------------------------------------------------------------

Game_modePacManKilled PROC

	dec gameBoard.mTimer				; self->mTimer--

	cmp gameBoard.mTimer, 0				; if (self->mTimer == 0)
	jne C2								; jump if not equal

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	mov ebx, FALSE						; set visibility to FALSE
	call PacMan_setVisible				; hide Pac-Man

	call PacMan_getLives				; get Pac-Man's Lives class
	call Lives_lost						; take a life away

	cmp eax, 0							; if (totalLives == 0)
	jne C1								; jump if not equal

	call Game_switchModeToGameOver		; change game state
	jmp Done							; unconditional jump

C1:
	call Game_switchModeToReady			; change game state
	jmp Done							; unconditional jump

C2:
	cmp gameBoard.mTimer, 50			; if (self->mTimer == 50)
	jne Done							; jump if not equal

	mov eax, FALSE						; set visibility to FALSE
	call Game_ghostsVisible				; hide all ghosts

	mov eax, OFFSET gameBoard.mPlayer	; EAX = Pac-Man*
	call PacMan_deadPacMan				; show dead Pac-Man character

	mov ebx, TRUE						; set visibility to TRUE
	call PacMan_setVisible				; show Pac-Man

Done:
	call Game_gameAnimation				; do all game animations
	ret									; return from procedure
Game_modePacManKilled ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_modeLevelComplete
; ______________________________________________________________________________
; The code that runs the LEVEL_COMPLETE game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_modeLevelComplete
;-------------------------------------------------------------------------------

Game_modeLevelComplete PROC

	dec gameBoard.mTimer					; self->mTimer--

	cmp gameBoard.mTimer, 183				; if (self->mTimer > 183)
	jg Return								; jump if greater than

	cmp gameBoard.mTimer, 23				; compare timer
	jg C1									; if (self->mTimer > 23)
	je C2									; if (self->mTimer == 23)

	cmp gameBoard.mTimer, 0					; if (self->mTimer == 0)
	jne Return								; jump if not equal

	call Game_newLevel						; setup the next level
	jmp Return								; unconditional jump

C1:
	mov eax, OFFSET gameBoard.mGameMapFlash	; EAX = GameMapFlash* 
	call GameMapFlash_drawScreen			; flash the game board

	cmp gameBoard.mTimer, 183				; if (self->mTimer == 183)
	jne Return								; jump if not equal

	mov eax, FALSE							; set visibility to FALSE
	call Game_ghostsVisible					; hide all ghosts
	jmp Return								; unconditional jump

C2:
	mov eax, OFFSET gameBoard.mPlayer		; EAX = Pac-Man*
	mov ebx, FALSE							; set visibility to FALSE
	call PacMan_setVisible					; hide Pac-Man
	call Screen_clearScreen					; clear entire screen

Return:
	ret										; return from procedure
Game_modeLevelComplete ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_modeGameOver
; ______________________________________________________________________________
; The code that runs the GAME_OVER game state.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_modeGameOver
;-------------------------------------------------------------------------------

Game_modeGameOver PROC

	mov eax, OFFSET gameBoard.mEnergizerFlash	; EAX = &self->mEnergizerFlash
	call EnergizerFlash_hideEnergizers			; hide all energizers

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_getBonusSymbol					; get Bonus Symbol class
	call BonusSymbol_reset						; hide bonus symbol

	dec gameBoard.mTimer						; self->mTimer--

	cmp gameBoard.mTimer, 23					; if (self->mTimer == 23)
	jne C1										; jump if not equal

	call Screen_clearScreen						; clear entire screen
	jmp Return									; unconditional jump

C1:
	cmp gameBoard.mTimer, 0						; if (self->mTimer == 0)
	jne Return									; jump if not equal

	mov eax, FALSE								; do not reset high score
	call Game_constructor						; restart a new game

Return:
	ret											; return from procedure
Game_modeGameOver ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_constructor
; ______________________________________________________________________________
; Initializes the Game class.
;
; PARAMETERS
;	EAX = TRUE to reset high score, FALSE otherwise
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, TRUE
;	call Game_constructor
;-------------------------------------------------------------------------------

Game_constructor PROC

	push eax									; push initHighScore on stack

	mov eax, OFFSET gameBoard.mEnergizerFlash	; EAX = &self->mEnergizerFlash
	call EnergizerFlash_constructor				; call constructor

	mov eax, OFFSET gameBoard.mGameMapFlash		; EAX = &self->mGameMapFlash
	call GameMapFlash_constructor				; call constructor

	mov gamePoint.x, 12							; bonus score point.x
	mov gamePoint.y, 14							; bonus score point.y

	mov eax, OFFSET gameBoard.mBonusScore		; EAX = &self->mBonusScore
	mov bx, DARK_WHITE							; text color
	mov ecx, SECONDS_2							; duration on screen
	call ScoreSprites_constructor				; call constructor

	mov eax, OFFSET gameBoard.mBonusScore		; EAX = &self->mBonusScore
	mov ebx, OFFSET gamePoint					; location of score
	call ScoreSprites_setLocation				; set location of bonus score

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_constructor						; call constructor

	mov eax, OFFSET gameBoard.mGhosts[3 * TYPE Ghost]	; EAX = Clyde
	mov bx, YELLOW										; ghost color
	call Ghost_constructor								; call constructor

	mov eax, OFFSET gameBoard.mGhosts[2 * TYPE Ghost]	; EAX = Inky
	mov bx, CYAN										; ghost color
	call Ghost_constructor								; call constructor

	mov eax, OFFSET gameBoard.mGhosts[1 * TYPE Ghost]	; EAX = Pinky
	mov bx, MAGENTA										; ghost color
	call Ghost_constructor								; call constructor

	mov eax, OFFSET gameBoard.mGhosts[0 * TYPE Ghost]	; EAX = Blinky
	mov bx, RED											; ghost color
	call Ghost_constructor								; call constructor

	pop eax										; pop initHighScore off stack

	cmp eax, TRUE								; if (initHighScore == TRUE)
	jne C1										; jump if not equal

	mov eax, OFFSET gameBoard.mHighScore		; EAX = &self->mHighScore
	call Score_constructor						; call constructor

	mov eax, OFFSET gameBoard.mHighScore		; EAX = &self->mHighScore
	mov ebx, 29									; x-position for title
	mov ecx, 1									; y-position for title
	mov dx, RED									; color for title
	mov esi, OFFSET highScoreTitle				; ESI = pointer to ASCII text
	call Score_setTitle							; set the title

	mov eax, OFFSET gameBoard.mHighScore		; EAX = &self->mHighScore
	mov ebx, 37									; x-position for score
	mov ecx, 3									; y-position for score
	call Score_setLocation						; set the score position

C1:
	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	call PacMan_getScore						; EAX = Score*

	mov ebx, 30									; x-position for title
	mov ecx, 5									; y-position for title
	mov dx, RED									; color for title
	mov esi, OFFSET oneUpTitle					; ESI = pointer to ASCII text
	call Score_setTitle							; set the title

	mov ebx, 37									; x-position for score
	mov ecx, 7									; y-position for score
	call Score_setLocation						; set the score position

	mov ebx, TRUE								; EBX = TRUE
	call Score_shouldFlashTitle					; flash Pac-Man Score title

	mov edi, 2									; x = 2
	mov esi, 0									; loop index

L1:
	cmp esi, TOTAL_BLANKS						; (ESI < TOTAL_BLANKS)
	jge Done									; jump if greater than or equal

	mov eax, TYPE Sprite						; EAX = sizeof(Sprite)
	imul esi									; EAX *= loop index
	mov edx, OFFSET gameBoard.mBlank			; EDX = address of sprites array
	add eax, edx								; add the offset to the address

	mov [eax].Sprite.character, SPACE			; character = SPACE
	mov [eax].Sprite.attributes, BLACK			; attributes = BLACK
	mov [eax].Sprite.charPoint.x, edi			; x-position
	mov [eax].Sprite.charPoint.y, 9				; y-position
	mov [eax].Sprite.visible, TRUE				; display on screen

	call Screen_addSprite						; add sprite to screen

	inc edi										; x++
	inc esi										; loop index++
	jmp L1										; unconditional jump

Done:
	mov gameBoard.mEatenGhost, NULL				; self->mEatenGhost = NULL

	mov eax, OFFSET gameBoard.mEnergizerScore	; EAX = &self->mEnergizerScore
	mov bx, CYAN								; text color
	mov ecx, SECONDS_1							; duration on screen
	call ScoreSprites_constructor				; call constructor

	call Game_newLevel							; setup level 1
	call Game_switchModeToPlayerIntro			; switch game state
	ret											; return from procedure
Game_constructor ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_processInput
; ______________________________________________________________________________
; Handles the keyboard input for the game.
;
; PARAMETERS
;	EAX = Contains a pointer to the a keys struct
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	mov eax, OFFSET keysStruct
;	call Game_processInput
;-------------------------------------------------------------------------------

Game_processInput PROC

	mov edi, eax								; EDI = keys struct

	cmp [edi].Keys.start, TRUE					; if (keys->start == TRUE)
	jne CElse									; jump if not equal

	cmp [edi].Keys.startHeld, FALSE				; if (keys->startHeld == FALSE)
	jne CIf										; jump if not equal

	cmp gameBoard.mGameState, GAME_STATE_PLAY	; if (state == PLAY)
	jne C1										; jump if not equal

	call Game_switchModeToPause					; pause game
	jmp CIf										; unconditional jump

C1:
	cmp gameBoard.mGameState, GAME_STATE_PAUSE	; if (state == PAUSE)
	jne CIf										; jump if not equal

	call Game_switchModeToPlay					; resume game

CIf:
	mov [edi].Keys.startHeld, TRUE				; keys->startHeld = TRUE
	jmp Done									; unconditional jump

CElse:
	mov [edi].Keys.startHeld, FALSE				; keys->startHeld = FALSE

Done:
	cmp gameBoard.mGameState, GAME_STATE_PLAY	; if (state == PLAY)
	jne Return									; jump if not equal

	mov eax, OFFSET gameBoard.mPlayer			; EAX = Pac-Man*
	mov ebx, edi								; EBX = keys struct
	call PacMan_input							; Pac-Man handle keyboard input

Return:
	ret											; return from procedure
Game_processInput ENDP

;-------------------------------------------------------------------------------
; PROCEDURE Game_processDisplay
; ______________________________________________________________________________
; Renders the game to the screen. The game state controls which state to render.
;
; PARAMETERS
;	None
;
; RETURNS
;	Nothing
;
; EXAMPLE
;	call Game_processDisplay
;-------------------------------------------------------------------------------

Game_processDisplay PROC

	cmp gameBoard.mGameState, GAME_STATE_PLAYER_INTRO	; case PLAYER_INTRO:
	je S1												; jump if equal

	cmp gameBoard.mGameState, GAME_STATE_READY			; case READY:
	je S2												; jump if equal

	cmp gameBoard.mGameState, GAME_STATE_PLAY			; case PLAY:
	je S3												; jump if equal
	
	cmp gameBoard.mGameState, GAME_STATE_GHOST_KILLED	; case GHOST_KILLED:
	je S4												; jump if equal

	cmp gameBoard.mGameState, GAME_STATE_PAC_MAN_KILLED	; case PAC_MAN_KILLED:
	je S5												; jump if equal

	cmp gameBoard.mGameState, GAME_STATE_LEVEL_COMPLETE	; case LEVEL_COMPLETE:
	je S6												; jump if equal

	cmp gameBoard.mGameState, GAME_STATE_GAME_OVER		; case GAME_OVER:
	je S7												; jump if equal

	jmp Done											; unconditional jump
	
S1:
	call Game_modePlayerIntro			; player intro mode
	jmp Done							; unconditional jump

S2:
	call Game_modeReady					; ready mode
	jmp Done							; unconditional jump

S3:
	call Game_modePlay					; play mode
	jmp Done							; unconditional jump

S4:
	call Game_modeGhostKilled			; ghost killed mode
	jmp Done							; unconditional jump

S5:
	call Game_modePacManKilled			; Pac-Man killed mode
	jmp Done							; unconditional jump

S6:
	call Game_modeLevelComplete			; level complete mode
	jmp Done							; unconditional jump

S7:
	call Game_modeGameOver				; game over mode

Done:
	call Game_nonStopAnimation			; render animation that never stops
	ret									; return from procedure
Game_processDisplay ENDP

;-------------------------------------------------------------------------------

end

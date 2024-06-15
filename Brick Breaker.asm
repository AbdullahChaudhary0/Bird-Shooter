.model small
.stack 100h
.data

playerName db 20 dup('$')     ; User name
scoreLabel db 'Score: $'      ; Score Printout
totalScore dw 0               ; Score
fileName db 'Score.txt', 0    ; File object
fileHandle dw ?               ; File handle
colorValue db ?               ; Color variable
gameLevelName db ?
shotsLabel db 'Shots: $'
livesRemaining db 0
selectedLevel db ?            ; Selected level
nameLength dw 0               ; Length of name

beginFlag db 0                
maxShots db ?                 ; Maximum Shots
startX dw ?
startY dw ?
endX dw ?
endY dw ?
boundaryRightX dw 275
boundaryLeftX dw 30
boundaryTopY dw 10
boundaryBottomY dw 150
aimStartX dw 140              ; Starting position of the aim
aimStartY dw 120
bird1X dw 170
bird1Y dw 40
bird1Down db 0
currentStage db 0

reverseDirection db 0

round1Clear db 0
round2Clear db 0
NEWLINE DB 13, 10             ; Carriage return and newline characters
SPACE DB 32
score1 db 0
score2 db 0

bird2X dw 40
bird2Y dw 50
bird2Down db 0
reverse2 db 0

bird3X dw 260
bird3Y dw 80
bird3Down db 0
reverse3 db 0

.code
jmp main   
; Set video mode
setVideoMode proc
    mov ax, 0
    mov al, 13h
    int 10h
    ret
setVideoMode endp

; Write word Macro
letterGraphics macro row, col, letter, color
    push dx
    push ax
    push cx
    push bx

    mov dh, row       ; Set cursor position
    mov dl, col
    mov ah, 02h
    int 10h
    mov al, letter    ; Write at cursor position
    mov bl, color
    mov cx, 1
    mov ah, 09h
    int 10h

    pop bx
    pop cx
    pop ax
    pop dx
endm

; Menu function
menu proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bl, 26         ; Taking the name of the user
    mov si, offset playerName
    letterGraphics 10, 14, 'E', 6
    letterGraphics 10, 15, 'n', 6
    letterGraphics 10, 16, 't', 6
    letterGraphics 10, 17, 'e', 6
    letterGraphics 10, 18, 'r', 6
    letterGraphics 10, 19, ' ', 6
    letterGraphics 10, 20, 'n', 6
    letterGraphics 10, 21, 'a', 6
    letterGraphics 10, 22, 'm', 6
    letterGraphics 10, 23, 'e', 6
    letterGraphics 10, 24, ':', 6
    letterGraphics 10, 25, ' ', 6
takeName:

    mov ah, 0
    int 16h

    cmp ah, 01Ch 
    je nameEnd

    mov [si], al
    letterGraphics 10, bl, al, 6
    inc bl
    inc si

    jmp takeName
nameEnd:
    mov si, offset playerName
sizeCalc:
    mov al, [si]
    cmp al, '$'
    je nameSizeDone
    inc nameLength
    inc si
    jmp sizeCalc
nameSizeDone:

    jmp menuLoop

menuLoop:

    mov al, 0
    mov bh, 0
    mov cx, 0
    mov dh, 80
    mov dl, 80
    mov ah, 06h
    int 10h

    letterGraphics 5, 7, 'D', 3
    letterGraphics 5, 9, 'U', 3
    letterGraphics 5, 11, 'C', 3
    letterGraphics 5, 13, 'K', 3

    mov al, 7
    mov cx, 27
l1:
    letterGraphics 7, al, '_', 6
    inc al
    loop l1

    letterGraphics 9, 22, 'S', 3
    letterGraphics 9, 24, 'H', 3
    letterGraphics 9, 26, 'O', 3
    letterGraphics 9, 28, 'O', 3
    letterGraphics 9, 30, 'T', 3
    letterGraphics 9, 32, 'E', 3
    letterGraphics 9, 34, 'R', 3

    letterGraphics 14, 14, 'G', 6
    letterGraphics 14, 15, 'A', 6
    letterGraphics 14, 16, 'M', 6
    letterGraphics 14, 17, 'E', 6
    letterGraphics 14, 18, ' ', 6
    letterGraphics 14, 19, 'A', 6
    letterGraphics 14, 20, ' ', 6
    letterGraphics 14, 21, '1', 6
    letterGraphics 14, 22, ':', 6
    letterGraphics 14, 23, 'D', 6
    letterGraphics 14, 24, 'U', 6
    letterGraphics 14, 25, 'C', 6
    letterGraphics 14, 26, 'K', 6

    letterGraphics 16, 14, 'G', 6
    letterGraphics 16, 15, 'A', 6
    letterGraphics 16, 16, 'M', 6
    letterGraphics 16, 17, 'E', 6
    letterGraphics 16, 18, ' ', 6
    letterGraphics 16, 19, 'B', 6
    letterGraphics 16, 20, ' ', 6
    letterGraphics 16, 21, '2', 6
    letterGraphics 16, 22, ':', 6
    letterGraphics 16, 23, 'D', 6
    letterGraphics 16, 24, 'U', 6
    letterGraphics 16, 25, 'C', 6
    letterGraphics 16, 26, 'K', 6

    mov ah, 0
    int 16h

    cmp al, 31h
    mov gameLevelName, '1'
    je startGame

    cmp al, 32h
    mov gameLevelName, '2'
    je startGame2

    jmp menuLoop

startGame:
    mov al, 0
    mov bh, 0
    mov bh, 0
    mov cx, 0
    mov dh, 80
    mov dl, 80
    mov ah, 06h
    int 10h
    mov selectedLevel, 1
    jmp startGameLoop

startGame2:
    mov al, 0
    mov bh, 0
    mov bh, 0
    mov cx, 0
    mov dh, 80
    mov dl, 80
    mov ah, 06h
    int 10h
    mov selectedLevel, 2
    jmp startGameLoop

startGameLoop:

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
menu endp

printScore proc
    push ax
    push bx
    push cx
    push dx

    mov cx, 0

    mov ax, totalScore
ll:
    mov bx, 10
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne ll

l2:
    pop dx
    mov ah, 2
    add dl, '0'
    int 21h
    loop l2

    pop dx
    pop cx
    pop bx
    pop ax

    ret
printScore endp

drawScoreAndShots proc
    push dx
    push ax

    mov dh, 23 ; Row for scores and shots
    mov dl, 5  ; Start column for score
    mov ah, 2
    int 10h    ; Set cursor position
    mov cx, 20 ; Number of spaces to clear
clearScore:
    mov al, ' '
    mov ah, 0Ah
    int 10h    ; Write space character
    loop clearScore

    ; Print score
    mov dh, 23
    mov dl, 5
    mov ah, 2
    int 10h
    lea dx, scoreLabel
    mov ah, 9
    int 21h
    call printScore

    mov dh, 23
    mov dl, 28
    mov ah, 2
    int 10h
    lea dx, playerName
    mov ah, 9
    int 21h

    pop ax
    pop dx
    ret
drawScoreAndShots endp

drawScoreAndShotsExtended proc
    push dx
    push ax

    mov dh, 23 ; Row for scores and shots
    mov dl, 5  ; Start column for score
    mov ah, 2
    int 10h    ; Set cursor position
    mov cx, 20 ; Number of spaces to clear
clearScore:
    mov al, ' '
    mov ah, 0Ah
    int 10h    ; Write space character
    loop clearScore

    ; Print score
    mov dh, 23
    mov dl, 5
    mov ah, 2
    int 10h
    lea dx, scoreLabel
    mov ah, 9
    int 21h
    call printScore

    mov dh, 23
    mov dl, 28
    mov ah, 2
    int 10h
    lea dx, playerName
    mov ah, 9
    int 21h

    mov dh, 23
    mov dl, 15 ; Start column for lives
    mov ah, 2
    int 10h    ; Set cursor position
    mov cx, 5  ; Clear space for lives
clearLives:
    mov al, ' '
    mov ah, 0Ah
    int 10h    ; Write space character
    loop clearLives

    mov dh, 23
    mov dl, 15
    mov ah, 2
    int 10h
    lea dx, shotsLabel
    mov ah, 9
    int 21h

    mov dl, livesRemaining
    add dl, '0'
    mov ah, 02h
    int 21h

    pop ax
    pop dx
    ret
drawScoreAndShotsExtended endp

drawGameBorder proc
    mov colorValue, 7
    mov startX, 20
    mov endX, 300
    mov startY, 5
    mov endY, 8
    call drawRectangle

    mov startX, 297
    mov endX, 300
    mov startY, 7
    mov endY, 180
    call drawRectangle

    mov startX, 20
    mov endX, 23
    mov startY, 7
    mov endY, 180
    call drawRectangle

    mov startX, 20
    mov endX, 300
    mov startY, 177
    mov endY, 180
    call drawRectangle
    ret
drawGameBorder endp

drawRectangle proc
    push ax
    push cx
    push dx

    mov dx, startY
    mov cx, startX
    mov ah, 0ch
    mov al, colorValue
dr:
    inc cx
    int 10h
    cmp cx, endX
    jne dr

    mov cx, startX
    inc dx
    cmp dx, endY
    jne dr

    pop dx
    pop cx
    pop ax
    ret
drawRectangle endp

drawAimCursor proc
    push bx
    mov bx, aimStartX
    mov startX, bx
    add bx, 13
    mov endX, bx
    mov bx, aimStartY
    mov startY, bx
    add bx, 1
    mov endY, bx
    call drawRectangle

    mov bx, endX
    dec bx
    mov startX, bx
    add endY, 12
    call drawRectangle

    mov bx, endY
    dec bx
    mov startY, bx
    sub startX, 12
    call drawRectangle

    mov bx, aimStartX
    mov startX, bx
    add bx, 1
    mov endX, bx
    mov bx, aimStartY
    mov startY, bx
    add bx, 12
    mov endY, bx
    call drawRectangle

    mov bx, aimStartY
    add bx, 6
    mov startY, bx
    inc bx
    mov endY, bx
    mov bx, aimStartX
    add bx, 4
    mov startX, bx
    add bx, 5
    mov endX, bx
    call drawRectangle

    mov bx, aimStartX
    add bx, 6
    mov startX, bx
    inc bx
    mov endX, bx
    mov bx, aimStartY
    add bx, 4
    mov startY, bx
    add bx, 5
    mov endY, bx
    call drawRectangle

    pop bx
    ret
drawAimCursor endp

drawTree proc
    ; Draw the trunk (rectangle)
    mov colorValue, 6
    mov startX, 62
    mov endX, 82
    mov startY, 130
    mov endY, 177
    call drawRectangle

    ; Draw the crown (triangle)
    mov colorValue, 2
    mov startX, 60
    mov endX, 80
    mov startY, 90
    mov endY, 130
    mov cx, 20
l1:
    call drawRectangle
    dec startX
    inc startY
    loop l1

    mov startX, 80
    mov endX, 81
    mov startY, 90
    mov endY, 130
    mov cx, 20
l2:
    call drawRectangle
    inc endX
    inc startY
    loop l2

    ret
drawTree endp

drawGrass proc
    mov colorValue, 2
    mov startY, 170
    mov endY, 177
    mov startX, 75
    mov endX, 78
    mov cx, 43
    call drawRectangle
l1:

    add startX, 5
    add endX, 5
    call drawRectangle

    loop l1

    mov cx, 10
    mov startX, 24
    mov endX, 27
l2:
    call drawRectangle
    add startX, 5
    add endX, 5
    loop l2

    ret
drawGrass endp

drawGrassFullWidth proc
    mov colorValue, 2
    mov startY, 170
    mov endY, 180
    mov startX, 0
    mov endX, 3
    mov cx, 95
    call drawRectangle
l1:

    add startX, 5
    add endX, 5
    call drawRectangle

    loop l1

    ret
drawGrassFullWidth endp

checkKeyboardInput proc
    mov ah, 1h
    int 16h         ; check keypress
    jz noInput     ; no keypress

    mov ah, 0h
    int 16h
    cmp ax, 4D00h
    je rightKey
    cmp ax, 4B00h
    je leftKey
    cmp ax, 4800h
    je upKey      ; Jump if Up Arrow Key is pressed
    cmp ax, 5000h
    je downKey    ; Jump if Down Arrow Key is pressed
    cmp ax, 3920h  ; Compare AX with the Space key code
    je spaceKey          ; Jump if Space Key is pressed
    cmp ax, 1970h  ; Compare AX with the combined ASCII and scan code for 'P'
    je pKey       ; Jump if 'P' key is pressed
    je startFlag
    jne noInput

startFlag:
    mov beginFlag, 1

noInput:
    ret

pKey:
    mov ah, 1h
    int 16h
    mov ah, 0h
    int 16h
    cmp ax, 2368h
    je noInput
    jmp pKey

spaceKey:
    call playSound
    dec maxShots
    cmp selectedLevel, 2
    je multiLevel
    call checkCollision
    call drawScoreAndShots
    jmp noInput

multiLevel:
    call checkCollision1
    call checkCollision2
    call checkCollision3
    dec livesRemaining
    call drawScoreAndShotsExtended
    jmp noInput

rightKey:
    mov bx, boundaryRightX
    cmp aimStartX, bx ; max right limit
    jg noInput
    mov colorValue, 0
    call drawAimCursor
    add aimStartX, 5
    mov colorValue, 15
    call drawAimCursor
    jmp noInput

leftKey:
    mov bx, boundaryLeftX
    cmp aimStartX, bx ; max left limit
    jl noInput
    mov colorValue, 0
    call drawAimCursor
    sub aimStartX, 5
    mov colorValue, 15
    call drawAimCursor
    jmp noInput

upKey:
    mov bx, boundaryTopY
    cmp aimStartY, bx    ; Compare with top boundary
    jle noInput         ; If less than or equal, ignore input
    mov colorValue, 0
    call drawAimCursor
    sub aimStartY, 5     ; Move up by 5 units
    mov colorValue, 15
    call drawAimCursor
    jmp noInput         ; Otherwise, ignore

downKey:
    mov bx, boundaryBottomY
    cmp aimStartY, bx    ; Compare with bottom boundary
    jge noInput         ; If greater than or equal, ignore input
    mov colorValue, 0
    call drawAimCursor
    add aimStartY, 5     ; Move down by 5 units
    mov colorValue, 15
    call drawAimCursor
    jmp noInput         ; Otherwise, ignore

checkKeyboardInput endp

playSound proc
    push ax
    push bx
    push cx
    push dx
    mov al, 182         ; Prepare the speaker.
    out 43h, al
    mov ax, 200        ; Frequency number (in decimal)
                        ; for middle C.
    out 42h, al         ; Output low byte.
    mov al, ah          ; Output high byte.
    out 42h, al
    in al, 61h         ; Turn on note (get value from
                        ; port 61h).
    or al, 00000011b   ; Set bits 1 and 0.
    out 61h, al         ; Send new value.
    mov bx, 2          ; Pause for duration of note.
pause1:
    mov cx, 65535
pause2:
    dec cx
    jne pause2
    dec bx
    jne pause1
    in al, 61h         ; Turn off note (get value from
                        ; port 61h).
    and al, 11111100b   ; Reset bits 1 and 0.
    out 61h, al         ; Send new value.

    pop dx
    pop cx
    pop bx
    pop ax

    ret
playSound endp

checkCollision proc
    push ax
    push bx
    push cx
    push dx

    ; Load bird's coordinates and dimensions
    mov ax, bird1X
    mov bx, bird1Y
    mov cx, ax
    mov dx, bx
    add cx, 10
    add dx, 10

    ; Load aim's coordinates and dimensions
    mov si, aimStartX
    mov di, aimStartY
    push si
    add si, 6 
    push di
    add di, 6

    ; Check horizontal overlap
    cmp ax, si
    jg noCollision
    cmp cx, aimStartX
    jl noCollision

    ; Check vertical overlap
    cmp bx, di
    jg noCollision
    cmp dx, aimStartY
    jl noCollision

    ; If we reach here, there is a collision
    add totalScore, 10
    mov round1Clear, 1

postCheck:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

noCollision:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

checkCollision endp

checkCollision1 proc
    push ax
    push bx
    push cx
    push dx

    ; Load bird's coordinates and dimensions
    mov ax, bird1X
    mov bx, bird1Y
    mov cx, ax
    mov dx, bx
    add cx, 10
    add dx, 10

    ; Load aim's coordinates and dimensions
    mov si, aimStartX
    mov di, aimStartY
    push si
    add si, 6 
    push di
    add di, 6

    ; Check horizontal overlap
    cmp ax, si
    jg noCollision
    cmp cx, aimStartX
    jl noCollision

    ; Check vertical overlap
    cmp bx, di
    jg noCollision
    cmp dx, aimStartY
    jl noCollision

    ; If we reach here, there is a collision
    add totalScore, 20
    mov bird1Down, 1
    mov colorValue, 0
    call drawBird

postCheck:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

noCollision:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

checkCollision1 endp

checkCollision2 proc
    push ax
    push bx
    push cx
    push dx

    ; Load bird's coordinates and dimensions
    mov ax, bird2X
    mov bx, bird2Y
    mov cx, ax
    mov dx, bx
    add cx, 10
    add dx, 10

    ; Load aim's coordinates and dimensions
    mov si, aimStartX
    mov di, aimStartY
    push si
    add si, 6 
    push di
    add di, 6

    ; Check horizontal overlap
    cmp ax, si
    jg noCollision
    cmp cx, aimStartX
    jl noCollision

    ; Check vertical overlap
    cmp bx, di
    jg noCollision
    cmp dx, aimStartY
    jl noCollision

    ; If we reach here, there is a collision
    add totalScore, 20
    mov bird2Down, 1
    mov colorValue, 0
    call drawBird2

postCheck:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

noCollision:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

checkCollision2 endp

checkCollision3 proc
    push ax
    push bx
    push cx
    push dx

    ; Load bird's coordinates and dimensions
    mov ax, bird3X
    mov bx, bird3Y
    mov cx, ax
    mov dx, bx
    add cx, 10
    add dx, 10

    ; Load aim's coordinates and dimensions
    mov si, aimStartX
    mov di, aimStartY
    push si
    add si, 6 
    push di
    add di, 6

    ; Check horizontal overlap
    cmp ax, si
    jg noCollision
    cmp cx, aimStartX
    jl noCollision

    ; Check vertical overlap
    cmp bx, di
    jg noCollision
    cmp dx, aimStartY
    jl noCollision

    ; If we reach here, there is a collision
    add totalScore, 20
    mov bird3Down, 1
    mov colorValue, 0
    call drawBird3

postCheck:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

noCollision:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

checkCollision3 endp

drawBird proc
    push bx
    mov bx, bird1X
    mov startX, bx
    add bx, 7 
    mov endX, bx
    mov bx, bird1Y
    mov startY, bx
    add bx, 7
    mov endY, bx
    call drawRectangle
    pop bx
    ret

call drawRectangle
ret
drawBird endp

drawBird2 proc
    push bx
    mov bx, bird2X
    mov startX, bx
    add bx, 7 
    mov endX, bx
    mov bx, bird2Y
    mov startY, bx
    add bx, 7
    mov endY, bx
    call drawRectangle
    pop bx
    ret

call drawRectangle
ret
drawBird2 endp

drawBird3 proc
    push bx
    mov bx, bird3X
    mov startX, bx
    add bx, 7 
    mov endX, bx
    mov bx, bird3Y
    mov startY, bx
    add bx, 7
    mov endY, bx
    call drawRectangle
    pop bx
    ret

call drawRectangle
ret
drawBird3 endp

moveBird1 proc
straight: 
    cmp reverseDirection, 1
    je reverse1

    cmp bird1Y, 150
    je reverse1
    mov colorValue, 0
    call drawBird
    add bird1Y, 2
    mov colorValue, 6
    call drawBird
    ret

reverse1:
    mov reverseDirection, 1
    cmp bird1Y, 40
    je changeDirection
    mov colorValue, 0
    call drawBird
    sub bird1Y, 2
    mov colorValue, 6
    call drawBird
    ret

changeDirection:
    mov reverseDirection, 0
    jmp straight

    ret
moveBird1 endp

moveBird2 proc
straight: 
    cmp reverseDirection, 1
    je reverse1

    cmp bird1X, 260
    jg reverse1
    mov colorValue, 0
    call drawBird
    add bird1X, 3
    mov colorValue, 9
    call drawBird
    ret

reverse1:
    mov reverseDirection, 1
    cmp bird1X, 40
    jl changeDirection
    mov colorValue, 0
    call drawBird
    sub bird1X, 3
    mov colorValue, 9
    call drawBird
    ret

changeDirection:
    mov reverseDirection, 0
    jmp straight

    ret
moveBird2 endp

moveBird3 proc
straight: 
    cmp reverseDirection, 1
    je reverse1

    cmp bird1X, 45
    jl reverse1
    mov colorValue, 0
    call drawBird
    sub bird1X, 4
    mov colorValue, 11
    call drawBird
    ret

reverse1:
    mov reverseDirection, 1
    cmp bird1X, 270
    jg changeDirection
    mov colorValue, 0
    call drawBird
    add bird1X, 4
    mov colorValue, 11
    call drawBird
    ret

changeDirection:
    mov reverseDirection, 0
    jmp straight

    ret
moveBird3 endp

moveBirdMultiLevel proc
    mov cx, 0ffffffffH
l1:
    loop l1
straight: 
    cmp reverseDirection, 1
    je reverse1

    cmp bird1Y, 150
    je reverse1
    mov colorValue, 0
    call drawBird
    add bird1Y, 2
    mov colorValue, 3
    call drawBird
    ret

reverse1:
    mov reverseDirection, 1
    cmp bird1Y, 40
    je changeDirection
    mov colorValue, 0
    call drawBird
    sub bird1Y, 2
    mov colorValue, 3
    call drawBird
    ret

changeDirection:
    mov reverseDirection, 0
    jmp straight

    ret
moveBirdMultiLevel endp

moveBirdMultiLevel2 proc
    mov cx, 0fffffH
l1:
    loop l1
straight: 
    cmp reverse2, 1
    je reverse1

    cmp bird2X, 260
    je reverse1
    mov colorValue, 0
    call drawBird2
    add bird2X, 2
    mov colorValue, 9
    call drawBird2
    ret

reverse1:
    mov reverse2, 1
    cmp bird2X, 40
    je changeDirection
    mov colorValue, 0
    call drawBird2
    sub bird2X, 2
    mov colorValue, 9
    call drawBird2
    ret

changeDirection:
    mov reverse2, 0
    jmp straight

    ret
moveBirdMultiLevel2 endp

moveBirdMultiLevel3 proc
    mov cx, 0fffH    ; Delay Loop
l1:
    loop l1
straight: 
    cmp reverse3, 1
    je reverse1

    cmp bird3X, 40
    je reverse1
    mov colorValue, 0
    call drawBird3
    sub bird3X, 2
    mov colorValue, 12
    call drawBird3
    ret

reverse1:
    mov reverse3, 1
    cmp bird3X, 260
    je changeDirection
    mov colorValue, 0
    call drawBird3
    add bird3X, 2
    mov colorValue, 12
    call drawBird3
    ret

changeDirection:
    mov reverse3, 0
    jmp straight

    ret
moveBirdMultiLevel3 endp

main:
    mov ax, @data
    mov ds, ax

    call setVideoMode
restart:
    call menu
    mov al, selectedLevel
    cmp al, 1
    je level1

    cmp al, 2
    je level2

level2:
    call drawGrass
    call drawGameBorder

    mov aimStartX, 140             ; Starting position of the aim
    mov aimStartY, 120
    mov colorValue, 7
    call drawAimCursor
    call drawScoreAndShotsExtended
    mov colorValue, 3
    call drawBird
    mov colorValue, 9
    call drawBird2
    mov colorValue, 12
    call drawBird3
    mov livesRemaining, 6

multiLevelRound:
    cmp livesRemaining, 0
    je gameOverLose
    cmp totalScore, 60
    je roundWin2
    call checkKeyboardInput
    cmp bird1Down, 1
    je skipBird1
    call moveBirdMultiLevel
skipBird1:
    cmp bird2Down, 1
    je skipBird2
    call moveBirdMultiLevel2
skipBird2:
    cmp bird3Down, 1
    je multiLevelRound
    call moveBirdMultiLevel3

    jmp multiLevelRound

level1:
    call drawScoreAndShots
    call drawGrass
    call drawGameBorder

stage1:
    cmp totalScore, 10
    je roundClear
    call drawTree
    mov colorValue, 15
    call drawAimCursor
    mov colorValue, 6
    call drawBird
    call moveBird1
    call checkKeyboardInput
    jmp stage1

stage2:
    call setVideoMode
    call drawScoreAndShots
    call drawGrass
    call drawGameBorder

round2:
    cmp totalScore, 20
    je roundClear
    call drawTree
    mov colorValue, 15
    call drawAimCursor
    mov colorValue, 9
    call drawBird
    call moveBird2
    call checkKeyboardInput
    jmp round2

stage3:
    call setVideoMode
    call drawScoreAndShots
    call drawGrass
    call drawGameBorder
round3:
    cmp totalScore, 30
    je roundWin
    call drawTree
    mov colorValue, 15
    call drawAimCursor
    mov colorValue, 11
    call drawBird
    call moveBird3
    call checkKeyboardInput
    jmp round3

roundClear:
    mov al, 0
    mov bh, 0
    mov bh, 0
    mov cx, 0
    mov dh, 80
    mov dl, 80
    mov ah, 06h
    int 10h
    letterGraphics 10, 10, 'M', 3
    letterGraphics 10, 11, 'O', 3
    letterGraphics 10, 12, 'V', 3
    letterGraphics 10, 13, 'I', 3
    letterGraphics 10, 14, 'N', 3
    letterGraphics 10, 15, 'G', 3
    letterGraphics 10, 16, ' ', 3
    letterGraphics 10, 17, 'T', 3
    letterGraphics 10, 18, 'O', 3
    letterGraphics 10, 19, ' ', 3
    letterGraphics 10, 20, 'N', 3
    letterGraphics 10, 21, 'E', 3
    letterGraphics 10, 22, 'X', 3
    letterGraphics 10, 23, 'T', 3
    letterGraphics 10, 24, ' ', 3
    letterGraphics 10, 25, 'S', 3
    letterGraphics 10, 26, 'T', 3
    letterGraphics 10, 27, 'A', 3
    letterGraphics 10, 28, 'G', 3
    letterGraphics 10, 29, 'E', 3
    add currentStage, 1
    cmp currentStage, 1
    je loadStage2

    cmp currentStage, 2
    je loadStage3

loadStage2:
    mov ah, 00
    int 16h
    mov reverseDirection, 0
    mov bird1X, 40
    mov bird1Y, 40
    call drawBird
    jmp stage2

loadStage3:
    mov ah, 00
    int 16h
    mov reverseDirection, 0
    mov bird1X, 270
    mov bird1Y, 55
    call drawBird
    jmp stage3

roundWin:
    mov al, 0
    mov bh, 0
    mov bh, 0
    mov cx, 0
    mov dh, 80
    mov dl, 80
    mov ah, 06h
    int 10h
    letterGraphics 10, 6, 'Y', 3
    letterGraphics 10, 7, 'O', 3
    letterGraphics 10, 8, 'U', 3
    letterGraphics 10, 9, 'R', 3
    letterGraphics 10, 10, ' ', 3
    letterGraphics 10, 11, 'N', 3
    letterGraphics 10, 12, 'A', 3
    letterGraphics 10, 13, 'M', 3
    letterGraphics 10, 14, 'E', 3
    letterGraphics 10, 15, ' ', 3
    letterGraphics 10, 16, 'I', 3
    letterGraphics 10, 17, 'S', 3
    letterGraphics 10, 18, ' ', 3
    letterGraphics 10, 19, 'I', 3
    letterGraphics 10, 20, 'N', 3
    letterGraphics 10, 21, ' ', 3
    letterGraphics 10, 22, 'H', 3
    letterGraphics 10, 23, 'A', 3
    letterGraphics 10, 24, 'L', 3
    letterGraphics 10, 25, 'L', 3
    letterGraphics 10, 26, ' ', 3
    letterGraphics 10, 27, 'O', 3
    letterGraphics 10, 28, 'F', 3
    letterGraphics 10, 29, ' ', 3
    letterGraphics 10, 30, 'F', 3
    letterGraphics 10, 31, 'A', 3
    letterGraphics 10, 32, 'M', 3
    letterGraphics 10, 33, 'E', 3
    letterGraphics 12, 16, 'M', 3
    letterGraphics 12, 17, 'O', 3
    letterGraphics 12, 18, 'D', 3
    letterGraphics 12, 19, 'E', 3
    letterGraphics 12, 20, '-', 3
    letterGraphics 12, 21, '1', 3
    letterGraphics 12, 22, ' ', 3
    letterGraphics 12, 23, 'C', 3
    letterGraphics 12, 24, 'L', 3
    letterGraphics 12, 25, 'E', 3
    letterGraphics 12, 26, 'A', 3
    letterGraphics 12, 27, 'R', 3

    mov ah, 00
    int 16h
    jmp gameOver

gameOverLose:
    mov al, 0
    mov bh, 0
    mov bh, 0
    mov cx, 0
    mov dh, 80
    mov dl, 80
    mov ah, 06h
    int 10h

    letterGraphics 10, 15, 'Y', 3
    letterGraphics 10, 16, 'O', 3
    letterGraphics 10, 17, 'U', 3
    letterGraphics 10, 18, ' ', 3
    letterGraphics 10, 19, 'L', 3
    letterGraphics 10, 20, 'O', 3
    letterGraphics 10, 21, 'S', 3
    letterGraphics 10, 22, 'E', 3

    jmp gameOver

roundWin2:
    mov al, 0
    mov bh, 0
    mov bh, 0
    mov cx, 0
    mov dh, 80
    mov dl, 80
    mov ah, 06h
    int 10h
    letterGraphics 10, 6, 'Y', 3
    letterGraphics 10, 7, 'O', 3
    letterGraphics 10, 8, 'U', 3
    letterGraphics 10, 9, 'R', 3
    letterGraphics 10, 10, ' ', 3
    letterGraphics 10, 11, 'N', 3
    letterGraphics 10, 12, 'A', 3
    letterGraphics 10, 13, 'M', 3
    letterGraphics 10, 14, 'E', 3
    letterGraphics 10, 15, ' ', 3
    letterGraphics 10, 16, 'I', 3
    letterGraphics 10, 17, 'S', 3
    letterGraphics 10, 18, ' ', 3
    letterGraphics 10, 19, 'I', 3
    letterGraphics 10, 20, 'N', 3
    letterGraphics 10, 21, ' ', 3
    letterGraphics 10, 22, 'H', 3
    letterGraphics 10, 23, 'A', 3
    letterGraphics 10, 24, 'L', 3
    letterGraphics 10, 25, 'L', 3
    letterGraphics 10, 26, ' ', 3
    letterGraphics 10, 27, 'O', 3
    letterGraphics 10, 28, 'F', 3
    letterGraphics 10, 29, ' ', 3
    letterGraphics 10, 30, 'F', 3
    letterGraphics 10, 31, 'A', 3
    letterGraphics 10, 32, 'M', 3
    letterGraphics 10, 33, 'E', 3
    letterGraphics 12, 16, 'M', 3
    letterGraphics 12, 17, 'O', 3
    letterGraphics 12, 18, 'D', 3
    letterGraphics 12, 19, 'E', 3
    letterGraphics 12, 20, '-', 3
    letterGraphics 12, 21, '2', 3
    letterGraphics 12, 22, ' ', 3
    letterGraphics 12, 23, 'C', 3
    letterGraphics 12, 24, 'L', 3
    letterGraphics 12, 25, 'E', 3
    letterGraphics 12, 26, 'A', 3
    letterGraphics 12, 27, 'R', 3

    mov ah, 00
    int 16h
    jmp gameOver

gameOver:
    mov ax, totalScore
    mov bl, 10
    div bl
    add al, 30h
    mov score1, al
    add ah, 30h
    mov score2, ah

    ; Open a file
    mov ah, 3dh ; 3dh of DOS services opens a file.
    mov al, 2 ; 0 - for reading. 1 - for writing. 2 - both
    mov dx, offset fileName ; make a pointer to the filename
    int 21h ; call DOS
    mov fileHandle, ax

    ; Set File Pointer to End of File
    mov ah, 42h                 ; Function: Move file pointer
    mov al, 2                   ; Move pointer: End of file
    mov bx, fileHandle          ; File handle
    mov cx, 0                   ; High word of offset (not used)
    mov dx, 0                   ; Low word of offset
    int 21h                     ; DOS interrupt

    ; Write Newline to File
    mov ah, 40h                 ; Function: Write to file
    mov bx, fileHandle          ; File handle
    mov cx, 2                   ; Number of bytes to write (CR + LF)
    mov dx, offset NEWLINE      ; Data to write (newline characters)
    int 21h                     ; DOS interrupt

    ; Write Data to File (append data after newline)
    mov ah, 40h                 ; Function: Write to file
    mov bx, fileHandle          ; File handle
    mov cx, nameLength          ; Number of bytes to write
    mov dx, offset playerName   ; Data to write
    int 21h                     ; DOS interrupt

    ; Writing Level Name
    ; Space
    mov ah, 40h                 ; Function: Write to file
    mov bx, fileHandle          ; File handle
    mov cx, 1                   ; Number of bytes to write
    mov dx, offset SPACE        ; Data to write
    int 21h                     ; DOS interrupt
    ; Name
    mov ah, 40h                 ; Function: Write to file
    mov bx, fileHandle          ; File handle
    mov cx, 1                   ; Number of bytes to write
    mov dx, offset gameLevelName; Data to write
    int 21h                     ; DOS interrupt

    ; Writing Score
    ; Space
    mov ah, 40h                 ; Function: Write to file
    mov bx, fileHandle          ; File handle
    mov cx, 1                   ; Number of bytes to write
    mov dx, offset SPACE        ; Data to write
    int 21h                     ; DOS interrupt
    ; Score
    mov ah, 40h                 ; Function: Write to file
    mov bx, fileHandle          ; File handle
    mov cx, 1                   ; Number of bytes to write
    mov dx, offset score1       ; Data to write
    int 21h                     ; DOS interrupt
    mov ah, 40h                 ; Function: Write to file
    mov bx, fileHandle          ; File handle
    mov cx, 1                   ; Number of bytes to write
    mov dx, offset score2       ; Data to write
    int 21h                     ; DOS interrupt

    ; Close a File
    mov ah, 3eh ; Service to close file.
    mov bx, fileHandle
    int 21h

    mov ah, 4ch
    int 21h
end

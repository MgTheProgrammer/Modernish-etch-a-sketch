; I've been asked to add a massage at the top and change the code so the line won't be able to cover the text
; for that I changed the lines tagged with 'changed' or 'added'
INCLUDE shake.asm
INCLUDE 'adjust.asm'
INCLUDE 'gotos.asm'
JUMPS
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
welcomeMsg db 'hello there!',0ah,'you must be so existed to use this brilliant program' ,0ah, 'but before we start you should know that you can exit by pressing q or esc',0ah,'press any key to continue$'
gameTitle db 'My epic project$' ; added
state db 0
; defined in arduinoCom.ino in the map functions
xInMin dw 0             ; the minimum value that can be inputted for x
xInMax dw 127           ; the maximum value that can be inputted for x
yInMin dw 0             ;                   same
yInMax dw 127           ;                   same

sensorVal dw 255        ; the value that is sent only if the tilt sensor is activated

firstCounter dw 0       ; counts the number of runs since start
; --------------------------
CODESEG 
start:
    mov ax, @data
    mov ds, ax
; --------------------------
welcome:
    mov al, 03h         ; clear screen before displaying welcome msg
    mov ah, 0
    int 10h

    mov dx, offset welcomeMsg
    mov ah, 9
    int 21h             ; prints welcomeMsg

    mov ah,0h
    int 16h             ; wait for key press to let user read msg

    mov ax, 13h         ; turns to graphic mode
    int 10h
                        ; added until interrupt
    mov dx, offset gameTitle
    mov ah, 9
    int 21h             ; prints game title

serialBegin:
    mov al, 11100011b   ; baud 9600 parity none stops bits 1 word length 8 - learn more at INITIALIZE PORT in useful_links
    mov dx, 0h          ; COM1
    mov ah, 00h         ; Initialize com
    int 14h

isNewAvailable:
    mov dx, 3FDh        ; Line status register (LSR) address - learn more at UART REGISTERS in useful_links
    in  al, dx          ; read LSR 
    and al, 1           ; keep first bit only, xxxxxxxx AND 00000001 (1 decimal) = 0000000x 
    cmp al, 1           ; the first bit indicate if new data is available
    jne ending          ; if no new data jmp to ending

receiveVal:
    xor ax, ax
    mov dx, 03F8h       ; COM1, base I/O address (Receiver buffer register - RBR) - learn more at UART REGISTERS in useful_links
    in  al, dx          ; receive data from COM1 (RBR) to al

reset?:
    cmp ax,[sensorVal]  ; check if the input is equal to the sensorVal or in another words if the arduino was shaken
    je cls              ; if shaken clear screen

updateVariables:
    cmp [state],0       ; checks whose turn to get updated (x or y)
    jne updateY         ; if state is 0 continue to x otherwise jump to y

updateX:
    push 320            ; out_max - max window column
    push 0              ; out_min - min window column
    push [xInMax]       ; in_max
    push [xInMin]       ; in_min
    push ax             ; x value from arduino
    call map            ; correct our input to the dos dimensions

    mov ax, [result]    ; the new x value is stored in result
    mov [destX],ax      ; make the new x value the destination

    inc [state]         ; increase state so next read the received value would get to y
    jmp writeVal        ; skip updateY as the value received is the x value

updateY:
    push 200            ; out_max - max window row
    push 8              ; out_min - min window row - changed
    push [yInMax]       ; in_max
    push [yInMin]       ; in_min
    push ax             ; y value from arduino
    call map            ; correct our input to the dos dimensions

    mov ax, [result]    ; the new y value is stored in result
    mov [destY],ax      ; make the new y value the destination

    dec [state]         ; decrease state so next read the received value would get to x

writeVal:               ; print the value received from port
    call gotoX
    call gotoY
                        ; changed till ending
    ; mov ax, [firstCounter]
    ; cmp ax, 2           ; if lower than 2 will delete what it just printed (in order to get the updated last x and y from the potentiometers)
    ; jg ending
    ; mov ax, 13h         ; turns to graphic mode
    ; int 10h
    ; inc [firstCounter]
    
ending:                 ; decide if ending the program or continue reading
    mov ah, 01h         ; Checks to see if a character is available in the buffer
    int 16h             
    jz isNewAvailable   ; if there is no character repeat

    mov ah, 00h         ; get key from buffer and remove it 
    int 16h

    cmp al, 'q'         ; if the user pressed q the program will quit
    je exit
    cmp al, 'Q'         ; we gotta make these caps lock monsters are happy don't we
    je exit
    cmp al, 27          ; some people swore by this key (27 is escape)
    je exit

    jmp isNewAvailable  ; if the key isn't one of those 

cls:
    call shakeScreen    ; does a shaking effect that clear the screen
                        
                        ; added till int 21h
                        ; clear screen to paint gametitle correctly
    mov ax, 13h         ; turns to graphic mode
    int 10h

    mov dx, offset gameTitle
    mov ah, 9
    int 21h             ; reprints game title

    jmp isNewAvailable  ; here we go again
; --------------------------
exit:
    mov al, 03h         ; restores to the regular dos text mode before quitting
    mov ah, 0
    int 10h

    mov ax, 4c00h       ; stops program
    int 21h
END start
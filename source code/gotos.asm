IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
lastX dw 0              ; used by the gotoX proc represents the last x value that a pixel was drawn
destX dw 1              ; used by the gotoX proc represents the destination x value that we are trying to goto
lastY dw 10             ; same same
destY dw 11
; --------------------------
CODESEG
proc gotoX
    push ax 
    push bx 
    push cx 
    push dx
        mov ax,[destX]
        cmp ax,[lastX]
        je pops         ; if the destination and the current place are the same don't do anything
        jl goLeft       ; if the destination is lower (further left) jump to goLeft
    goRight:
        mov cx, [lastX] ; column of current place
        mov dx, [lastY] ; row of current place
        mov al, 6       ; pixel color
        mov ah,0ch
        int 10h         ; print pixel
            
        inc [lastX]     ; the last x is now one column further right

        mov ax,[destX]
        cmp ax,[lastX]  
        jne goRight     ; if the current place isn't the same as destination do the above again
        jmp pops        ; if they are equal end the procedure
    goLeft:
        mov cx, [lastX] ; column of current place
        mov dx, [lastY] ; row of current place
        mov al, 6       ; pixel color
        mov ah,0ch
        int 10h         ; print pixel
            
        dec [lastX]     ; the last x is now one column further left

        mov ax,[destX]
        cmp ax,[lastX]
        jne goLeft      ; if the current place isn't the same as destination do the above again
    pops:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

endp gotoX

proc gotoY
    push ax 
    push bx 
    push cx 
    push dx
        mov ax,[destY]
        cmp ax,[lastY]
        je popping      ; if the destination and the current place are the same end procedure
        jl goUp         ; if the destination has lower value (further up) jump to goUp
    goDown:
        mov cx, [lastX] ; column of current pixel
        mov dx, [lastY] ; row of current pixel
        mov al, 6       ; pixel color
        mov ah,0ch
        int 10h         ; print pixel
            
        inc [lastY]     ; the last y is now one row further down

        mov ax,[destY]
        cmp ax,[lastY]
        jne goDown      ; if the current place isn't the same as destination do the above again
        jmp popping     ; if they are equal end the procedure
    goUp:
        mov cx, [lastX] ; column of current pixel
        mov dx, [lastY] ; row of current pixel
        mov al, 6       ; pixel color
        mov ah,0ch
        int 10h         ; print
            
        dec [lastY]     ; the last y is now one row further up
        
        mov ax,[destY]
        cmp ax,[lastY]
        jne goUp        ; if the current place isn't the same as destination do the above again
    popping:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp gotoY
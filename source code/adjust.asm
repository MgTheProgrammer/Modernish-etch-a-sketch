IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
result dw 0             ; the map function stores the adjusted value in here
; --------------------------
CODESEG
; implementation of the Arduino map() function which takes a number within a range and returns the corresponding number in another range
; from the Arduino docs: return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
x      equ [bp+4]       ; the number we want to adjust
inMin  equ [bp+6]       ; the minimum value that can be inputted for x
inMax  equ [bp+8]       ; the maximum value that can be inputted for x
outMin equ [bp+10]      ; the minimum value that can be outputted for x
outMax equ [bp+12]      ; the maximum value that can be outputted for x
proc map
    push bp
    mov bp,sp

    push ax 
    push bx
    push dx
        mov ax,x        ; (x - in_min)
        sub ax,inMin

        mov bx,outMax   ; (out_max - out_min)
        sub bx,outMin

        mul bx          ; (x - in_min) * (out_max - out_min) => ax

        mov bx,inMax    ; (in_max - in_min)
        sub bx,inMin

        div bx          ; (x - in_min) * (out_max - out_min) / (in_max - in_min) => ax

        add ax,outMin
        mov [result],ax
    pop dx
    pop bx
    pop ax
    pop bp
    ret 10
endp map
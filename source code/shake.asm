IDEAL
MODEL small
STACK 100h
DATASEG

; --------------------------
winWidth dw 320
winHeight dw 200
column dw 0
row dw 0
; --------------------------
CODESEG
; used for debug
proc drawLine
	push ax 
	push bx 
	push cx 
	push dx
	mov [column],0
		line:
		mov ax, [column]
		mov bl, 2
		div bl
		cmp ah,0
		je red
		mov al, 0fh ; white
		jmp draw
		; AL = pixel color CX = column. DX = row.

		red:
		mov al, 04h ; white
		draw:
		mov cx, [column]
		mov dx, [row]
		mov ah,0ch
		int 10h

		inc [column]
		mov ax,[winWidth]
		cmp [column],ax
		jne line
	pop dx
	pop cx
	pop bx
	pop ax
	ret

endp drawLine
; used for debug
proc drawFrame
	push ax 
	push bx 
	push cx 
	push dx
		mov cx, [winHeight]
		create:
		call drawLine
		inc [row]
		loop create
	pop dx
	pop cx
	pop bx
	pop ax
	ret

endp drawFrame

; bp+4 - shiftFactor
proc shiftLineLeftFast
    push bp
    mov bp,sp

    push ax 
    push cx
        mov ax,0A000h		; 0A000h is the base video memory address
        mov es,ax

        mov ax,[bp+4]		
        mov si,di
        add si, ax			; si would be further left then di by the shift factor

        mov cx, 319
        shiftLine:
        cmp cx, [bp+4]
        jl black 			; if cx is less than the shift factor draw black pixels
        mov ax, [es:si]
        mov [es:di], ax		; copy the color from si to di (copy the color from the pixel which is left by the shift factor)
        jmp continue
        black:
        mov [es:di], 0		; 0 is black
        continue:
        inc si
        inc di
        loop shiftLine
    pop cx
    pop ax
    pop bp
    
    ret 2
endp shiftLineLeftFast

; bp+4 - shiftFactor
proc shiftLineRightFast
    push bp
    mov bp,sp

    push ax 
    push cx
    push si
        mov ax, 0A000h		; 0A000h is the base video memory address
        mov es,ax

        mov ax, [bp+4]
        mov si,di
        sub si, ax			; si would be further right then di by the shift factor
 
        mov cx, 320
        shiftLineRight:
        cmp cx, [bp+4]
        jl drawBlack		; if cx is less than the shift factor draw black pixels
        mov ax, [es:si]
        mov [es:di], ax		; copy the color from si to di (copy the color from the pixel which is right by the shift factor)
        jmp carryon
        drawBlack:
        mov [es:di], 0
        carryon:
        dec si
        dec di

        cmp cx, 0
        dec cx
        jge shiftLineRight

    pop si
    pop cx
    pop ax
    pop bp
    
    ret 2
endp shiftLineRightFast
; bp+4 - shiftFactor
proc shiftFrameLeftFast
    push bp
    mov bp,sp

    push ax  
    push cx

        mov di, 0			; start from (0,0) and si (shiftFactor,0)

        mov cx, 200			; every row
        shiftLines:
        push [bp+4]			; pass the same shift factor
        call shiftLineLeftFast
        inc di				; the next line would start in (0,1) si (shiftFactor,1) and so on
        loop shiftLines

    pop cx
    pop ax
    pop bp
    ret 2
endp shiftFrameLeftFast
; bp+4 - shiftFactor
proc shiftFrameRightFast
    push bp
    mov bp,sp

    push ax  
    push cx
        mov di, 320			; start from (320,0) and si (320 - shiftFactor,0)
        mov cx,	200			; every row
        shiftLinesRight:
        push [bp+4]			; pass the same shift factor
        call shiftLineRightFast
        add di,641			; the next line would start in (320,1) si (320 - shiftFactor,1) and so on
        loop shiftLinesRight

    pop cx
    pop ax
    pop bp
    ret 2
endp shiftFrameRightFast

proc shakeScreen
	push ax 
	push bx 
	push cx 
	push dx
		mov ax, 1			; ax stores the shift factor
		mov cx, 9			; the minimum number of iteration that guarantee to clear the entire screen
		clear:
		push ax				; ax shift factor
		call shiftFrameLeftFast
		shl ax,1			; double the shift factor
		push ax
		call shiftFrameRightFast
		loop clear
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp shakeScreen
; proc shiftFrameFastest
;     push ax 
;     push bx 
;     push cx 
;     push dx
;         mov di,0       
;         mov si,1
;         mov ax,0A000h
;         mov es,ax
;         mov cx,200
;         shiftFrameF:
;         push cx
;         mov cx, 319
;         shift:
;         mov ax, [es:si]
;         mov [es:di], ax
;         inc si
;         inc di
;         loop shift
;             inc di
;             inc si
;         pop cx
;         loop shiftFrameF
;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     ret
; endp shiftFrameFastest

; the original shift line procedure using interrupts that was too slow for my liking
; proc shiftLineLeft
; 	push ax 
; 	push bx 
; 	push cx 
; 	push dx
; 	mov [column],0
; 		shifting:
; 		; get (cx,dx) pixel color to al
; 		mov cx,[column]
; 		mov dx,[row]
; 		mov ah,0dh
; 		int 10h
; 		; to prevent first pixel to jump to the other side
; 		cmp [column],0
; 		je f
; 		; AL = pixel color CX = column. DX = row.
; 		mov dx,[column]
; 		dec dx
; 		mov cx, dx ; dx = column - 1 in other words last pixel
; 		mov dx, [row]
; 		mov ah,0ch
; 		int 10h

; 		mov al,0h
; 		mov cx, [column]
; 		mov dx, [row]
; 		mov ah,0ch
; 		int 10h
; 		f:
; 		inc [column]

; 		mov ax,[winWidth]
; 		cmp [column],ax
; 		jne shifting
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	ret
; endp shiftLineLeft
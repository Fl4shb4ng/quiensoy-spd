.8086
.MODEL small
.STACK 100h
.DATA


;================================
filename dw 0

filehandle dw ?

Header db 54 dup (0)

Palette db 256*4 dup (0)

ScrLine db 320 dup (0)

ErrorMsg db 'Error', 13, 10,'$'

ErrorFileNotFound db "Archivo no encontrado",0dh,0ah
                  db "Seguro te olvidaste del 0 al final",0dh,0ah
                  db "ej: archivo db 'test.bmp',0",0dh,0ah,24h

;================================
.CODE
;================================

public bmp

proc bmp 
;================================

    ; Graphic mode
    mov filename, bx
    xor bx, bx
    mov ax, 13h
    int 10h


    ; Process BMP file
    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap

    ;CLOSE FILE

    mov ah, 3eh
    mov bx, [filehandle]
    int 21h

    ; Wait for key press
    ;mov ah,1

    ;int 21h
    ; Back to text mode
    ;mov ah, 0
    ;mov al, 2
    ;int 10h
;================================
exit:
ret
bmp endp 

proc OpenFile

    ; Open file

    mov ah, 3Dh
    xor al, al
    mov dx, filename
    int 21h

    jc openerror
    mov [filehandle], ax
    ret

    openerror:

    cmp al, 2
    jne errorGenerico
    mov dx, offset ErrorFileNotFound
    mov ah, 9h
    int 21h
errorGenerico:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h

    ;mov dl, al 
    ;mov ah, 2
    ;int 21h

    ; Wait for key press
    ;mov ah,1

    ;int 21h
    ; Back to text mode
    ;mov ah, 0
    ;mov al, 2
    ;int 10h
    
    ret
endp OpenFile
proc ReadHeader

    ; Read BMP file header, 54 bytes

    mov ah,3fh
    mov bx, [filehandle]
    mov cx,54
    mov dx,offset Header
    int 21h
    ret
    endp ReadHeader
    proc ReadPalette

    ; Read BMP file color palette, 256 colors * 4 bytes (400h)

    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h
    ret
endp ReadPalette
proc CopyPal

    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h

    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0

    ; Copy starting color to port 3C8h

    out dx,al

    ; Copy palette itself to port 3C9h

    inc dx
    PalLoop:

    ; Note: Colors in a BMP file are saved as BGR values rather than RGB.

    mov al,[si+2] ; Get red value.
    shr al,2 ; Max. is 255, but video palette maximal

    ; value is 63. Therefore dividing by 4.

    out dx,al ; Send it.
    mov al,[si+1] ; Get green value.
    shr al,2
    out dx,al ; Send it.
    mov al,[si] ; Get blue value.
    shr al,2
    out dx,al ; Send it.
    add si,4 ; Point to next color.

    ; (There is a null chr. after every color.)

    loop PalLoop
    ret
endp CopyPal

proc CopyBitmap

    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.

    mov ax, 0A000h
    mov es, ax
    mov cx,200
    PrintBMPLoop:
    push cx

    ; di = cx*320, point to the correct screen line

    mov di,cx
    shl cx,6
    shl di,8
    add di,cx

    ; Read one line

    mov ah,3fh
    mov cx,320
    mov dx,offset ScrLine
    ;add dx,0
    int 21h

    ; Copy one line into video memory

    cld 

    ; Clear direction flag, for movsb

    mov cx,320
    mov si,offset ScrLine
    rep movsb 

    ; Copy line to the screen
    ;rep movsb is same as the following code:
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0

    pop cx
    loop PrintBMPLoop
    ret
endp CopyBitmap
proc CloseFile
  mov  ah, 3Eh
  mov  bx, [filehandle]
  int  21h
  ret
endp CloseFile
CLEAR_SCREEN PROC
        PUSH AX
        PUSH BX

        ;CONFIGURACIÓN DE VIDEO (HABRIA QUE ESPECIFICAR MÁS).
        MOV AH, 00H
        MOV AL, 13H
        INT 10H
        ;SETEO FONDO EN NEGRO:
        MOV AH, 0BH
        MOV BH, 00H
        MOV BL, 00H
        INT 10H
        ;...

        POP BX
        POP AX
        RET
CLEAR_SCREEN ENDP
;================================

end

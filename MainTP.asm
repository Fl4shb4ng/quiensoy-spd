.8086
.model small
.stack 100h
.data
	;INTERFACE
	menu            db "menu0.bmp",0
	creditos        db "creditos.bmp",0


	;LÓGICA

	;eleccion      db 0,0,0,0,0 ;LO QUE VAYA ELIGIENDO EL JUGADOR
	; eleccion      db 1,0,0,3,0
	; eleccionASCII db 255 dup (24h)
	; elec_name     db 255 dup (24h)

	; maquina    db 0,0,0,0,0 ;LO QUE LA MAQUINA ELIJA EN PRIMER INSTANCIA.
	; maq_name   db 255 dup (24h)
	; maq_img    db 255 dup (24h) ;acá va el .bmp

;posicion 0 sexo (2 MUJER, HOMBRE 1), posicion 1 pelo (2 CORTO, 1 LARGO),
;posicion 2 usa lentes (2 SI, 1 NO), posicion 3 color de pelo (3 RUBIO, 2 CASTAÑO, 1 BLANCO), 
;posicion 4 tiene vello facial (2 SÍ, 1 NO)


.code


	extrn bmp:proc ;Carga en BX el offset de la imagen.
	extrn newGame:proc ;Llama a los procedimientos para iniciar una nueva partida.

	main proc
		mov ax, @data
		mov ds, ax


;***********************************************
;INICIARÍA EL MAIN
;***********************************************

vuelveMenu:		
	lea bx, menu
     call bmp

     mov ah,8
     int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA DE OPCIÓN.
     cmp al, 31h
     je quiereInicio
     cmp al, 32h
     je quiereCreditos
     cmp al, 33h
     je quiereSalir
     jmp vuelveMenu

quiereInicio:
	call newGame
	jmp vuelveMenu
quiereCreditos:
	lea bx, creditos
	call bmp
	mov ah,8
     int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA X
     jmp vuelveMenu
quiereSalir:
	mov ah, 0 ;VUELVO AL MODO DE TEXTO ESTÁNDAR.
	mov al, 2
	int 10h
	jmp finProg

finProg:
	mov ax, 4c00h
	int 21h


	main endp

end
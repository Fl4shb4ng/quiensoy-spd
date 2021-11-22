.8086
.model small
.stack 100h

.data
	hombCart	db "- Seria hombre",24h
	mujCart	db "- Seria mujer",24h
	larCart db "- Tendria el pelo largo",24h
	corCart db "- Tendria el pelo corto",24h
	nolentCart db "- No tendria lentes",24h
	silentCart db "- Si tendria lentes",24h
	rubCart db "- Tendria el pelo rubio",24h
	castCart db "- Tendria el pelo castanio",24h ; No nos dejaba guardar en encoding DOS, así que improvisamos :c
	blanCart db "- Tendria el pelo canoso",24h
	noVelloCart db "- No tendria barba.",24h
	siVelloCart db "- Si tendria barba.",24h


	;INTERFACE
	pjs_img  		db "pjs.bmp",0  ; Te muestra los personajes posibles (SIN EL NÚMERO DE OPCIÓN)
	fnd_opt			db "fndr.bmp",0 ; Fondo del menú que te muestra las opciones que elegiste
	fnd_opt_N   db "sinopts.bmp",0 ; Fondo del menú que te muestra QUE AÚN NO ESCOGISTE NINGUNA RESPUESTA.
	pjs_pick		db "pjsPick.bmp",0  ; Te muestra los personajes posibles (CON EL NÚMERO DE OPCIÓN)

	ganaste		 db "win.bmp",0
	perdiste		 db "loose.bmp",0
	instrucciones	 db "instruc.bmp",0
	submenu			 db "submenu.bmp",0 ;SE REFIERE AL MENÚ DE JUEGO EN SI.

	;SUB-SUBMENU DE PREGUNTAS
	preguntasBMP	 db "pregs.bmp",0 ;SE REFIERE AL SUBMENU DE PREGUNTAS

	sexoBMP			 db "sexo.bmp",0
	peloBMP			 db "pelo.bmp",0
	lentesBMP	     db "lent.bmp",0
	peloColorBMP	 db "colorP.bmp",0
	velloBMP		 db "barba.bmp",0

	preguntaBien	 db "pregon.bmp",0
	preguntaMal		 db "pregoff.bmp",0

	sinVidasBMP		 db "noheal.bmp",0


	;CARTELERÍA DOS
    cartelvidas db "INTENTOS: ",24h

    ;VIDAS
	vidas		 				db 3 
	vidasASCII      			db "3",24h

	;CURSOR DE LOS BMP (USADO EN FUNCIONES DONDE SE SUPERPONE TEXTO SOBRE EL BMP)
	rowNumber  			db 10 				;Indica la mitad de la pantalla.


	;LÓGICA
	pj1_name   db "Ana",24h
  pj1_bmp    db "ana.bmp",0,24h ;El 24h es necesario para la parte de copiado.
  personaje1 db 2,2,1,2,1

  pj2_name   db "Carlos",24h
  pj2_bmp    db "carlos.bmp",0,24h
  personaje2 db 1,2,1,2,1

  pj3_name   db "Mica",24h
  pj3_bmp    db "mica.bmp",0,24h
  personaje3 db 2,1,2,2,1

  pj4_name   db "Julian",24h
  pj4_bmp    db "juli.bmp",0,24h
  personaje4 db 1,2,2,1,2

  pj5_name   db "Flor",24h
  pj5_bmp    db "flor.bmp",0,24h 
  personaje5 db 2,1,2,2,1

	eleccion      db 0,0,0,0,0
	eleccionASCII db 255 dup (24h)
	elec_name     db 255 dup (24h)

	validaciones  db 0 ;ESTO TAMBIEN HAY QUE PLANCHARLO EN LA INICIALIZACION

	maquina    db 0,0,0,0,0 ;LO QUE LA MAQUINA ELIJA EN PRIMER INSTANCIA.
	maq_name   db 255 dup (24h)
	maq_img    db 255 dup (24h) ;acá va el .bmp
;posicion 0 sexo (2 MUJER, HOMBRE 1), posicion 1 pelo (2 CORTO, 1 LARGO),
;posicion 2 usa lentes (2 SI, 1 NO), posicion 3 color de pelo (3 RUBIO, 2 CASTAÑO, 1 BLANCO), 
;posicion 4 tiene vello facial (2 SÍ, 1 NO)

;quiereVerPersonajes:
; 	lea bx, pjs_img
; 	call bmp
; 	mov ah,8
;      int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA X
;      jmp vuelveMenu
; quiereVerRespuestas:
; 	lea bx, fnd_opt
; 	call bmp

; 	lea si, eleccionASCII
;   lea bx, eleccion
;   call ConstruyeResp

; 	lea bx, eleccionASCII
; 	call VeResp
; 	mov ah,8
;      int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA X
;      jmp vuelveMenu


     ; lea bx, cartelvidas
     ; mov ax, 0
     ; call VeVida
     ; lea bx, vidasASCII
     ; mov ax, 1
     ; call VeVida

.code

public newGame

extrn bmp:proc


newGame proc
	push ax
	push bx
	push dx
	push si 

	call inicializa
returnMenu:
	lea bx, submenu
    call bmp

	lea bx, cartelvidas
    mov ax, 0
    call VeVida
    lea bx, vidasASCII
    mov ax, 1
    call VeVida

    mov ah,8
    int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA DE OPCIÓN.
    cmp al, 31h
    je quierePreguntar
    cmp al, 32h
    je quiereMisRespuestas
    cmp al, 33h
    je quiereVerPersonajes
    cmp al, 34h
    je quiereInstrucciones
    cmp al, 35h
    je quiereJugarsela
    cmp al, 36h
    je quiereRendirse
    jmp returnMenu

quierePreguntar:
	cmp vidas,0
	je  sinVidas
	call askGame
	jmp returnMenu
sinvidas:
	lea bx, sinVidasBMP
    call bmp
    mov ah,8
    int 21h
    jmp returnMenu
quiereMisRespuestas:
	cmp vidas, 3
	je noeligio

	lea bx, fnd_opt
	call bmp

	lea si, eleccionASCII
    lea bx, eleccion
    call ConstruyeResp

	lea bx, eleccionASCII
	call VeResp
	mov ah,8
    int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA X
    jmp returnMenu
noeligio:
	lea bx, fnd_opt_N
	call bmp
	mov ah,8
  int 21h
  jmp returnMenu

quiereVerPersonajes:
	lea bx, pjs_img
	call bmp
	mov ah,8
    int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA X
    jmp returnMenu
quiereInstrucciones:
	lea bx, instrucciones
	call bmp
	mov ah,8
    int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA X
	jmp returnMenu
quiereJugarsela:
	call allIn
	jmp fin_AskGame
quiereRendirse:
	call surrender
	jmp fin_AskGame
fin_AskGame:
	pop si
	pop dx
	pop bx
	pop ax
	ret
newGame endp

askGame proc
	push ax
	push bx
	push dx
	push si

askGameMenu:
	 lea bx, cartelvidas
     mov ax, 0
     call VeVida
     lea bx, vidasASCII
     mov ax, 1
     call VeVida


	lea bx, preguntasBMP
    call bmp

    lea bx, cartelvidas
    mov ax, 0
    call VeVida
    lea bx, vidasASCII
    mov ax, 1
    call VeVida

    cmp vidas, 0 ;SE FIJA QUE LAS VIDAS SEAN CERO.
    je saleVidas_JMP

	mov ah,8
    int 21h ;CORTA UN MOMENTO LA PROGRESIÓN HASTA QUE SE TOQUE UNA TECLA DE OPCIÓN.

    cmp al, 31h
    je sexoPreg
    cmp al, 32h
    je peloPreg
    cmp al, 33h
    je lentesPreg_JMP
    cmp al, 34h
    je colorpeloPreg_JMP
    cmp al, 35h
    je vellofacPreg_JMP
    cmp al, 36h
    je saleAskGame_JMP
    jmp askGameMenu
saleVidas_JMP:
	jmp fin_AskGame
saleAskGame_JMP:
	jmp saleAskGame
vellofacPreg_JMP:
	jmp vellofacPreg
colorpeloPreg_JMP:
	jmp colorpeloPreg
lentesPreg_JMP:
	jmp lentesPreg
sexoPreg:
	lea bx, sexoBMP
	call bmp

	mov ah,8
    int 21h
    cmp al, 33h
    je askGameMenu
    ;GUARDO EL CONTENIDO DE LA RESPUESTA EN LA VARIABLE
    lea di, eleccion
    sub al, 30h
	mov byte ptr[di], al
	add al, 30h

	lea si, maquina ; RECUPERA LOS DATOS DE LA ELECCIÓN DE LA MAQUINA
	mov bl, byte ptr[si]
	add bl, 30h
	cmp al, bl

	je respCorrecta_P
	
	dec vidas
	;LLAMO AL REGTOASCII
	xor ax,ax
	mov al, vidas
	lea bx, vidasASCII
	call regToAscii
	lea bx, preguntaMal
	call bmp

	mov ah,8
    int 21h

	jmp askGameMenu
peloPreg:
	lea bx, peloBMP
	call bmp

	mov ah,8
	int 21h
	cmp al, 33h
	je askGameMenu_P
	;GUARDO EL CONTENIDO DE LA RESPUESTA EN LA VARIABLE
	lea di, eleccion
	sub al, 30h
	add di, 1 ; AVANZO EN EL OFFSET HASTA LA POSICIÓN DESEADA
	mov byte ptr[di], al
	add al, 30h

	lea si, maquina ; RECUPERA LOS DATOS DE LA ELECCIÓN DE LA MAQUINA
	add si, 1       ; AVANZO EN EL OFFSET HASTA LA POSICIÓN DESEADA
	mov bl, byte ptr[si]
	add bl, 30h	
	cmp al, bl
	je respCorrecta_P
	
	dec vidas
	;LLAMO AL REGTOASCII
	xor ax,ax
	mov al, vidas
	lea bx, vidasASCII
	call regToAscii
	lea bx, preguntaMal
	call bmp
	mov ah,8
    int 21h

	jmp askGameMenu
askGameMenu_P:
	jmp askGameMenu
respCorrecta_P:
	jmp respCorrecta

lentesPreg:
	lea bx, lentesBMP
	call bmp

	mov ah,8
    int 21h
    cmp al, 33h
    je askGameMenu_L
    ;GUARDO EL CONTENIDO DE LA RESPUESTA EN LA VARIABLE
	lea di, eleccion
	add di, 2
	sub al, 30h
	mov byte ptr[di], al
	add al, 30h

	lea si, maquina ; RECUPERA LOS DATOS DE LA ELECCIÓN DE LA MAQUINA
	add si, 2       ; AVANZO EN EL OFFSET HASTA LA POSICIÓN DESEADA
	mov bl, byte ptr[si]

	add bl, 30h	
	cmp al, bl
	je respCorrecta_L

	dec vidas
	;LLAMO AL REGTOASCII
	xor ax,ax
	mov al, vidas
	lea bx, vidasASCII

	call regToAscii
	lea bx, preguntaMal
	call bmp

	mov ah,8
    int 21h

	jmp askGameMenu
askGameMenu_L:
	jmp askGameMenu
respCorrecta_L:
	jmp respCorrecta
colorpeloPreg:
	lea bx, peloColorBMP
	call bmp

	mov ah,8
    int 21h
    cmp al, 34h
    je askGameMenu_CP

    ;GUARDO EL CONTENIDO DE LA RESPUESTA EN LA VARIABLE
	lea di, eleccion
	add di, 3
	sub al, 30h
	mov byte ptr[di], al
	add al, 30h
	

	lea si, maquina ; RECUPERA LOS DATOS DE LA ELECCIÓN DE LA MAQUINA
	add si, 3       ; AVANZO EN EL OFFSET HASTA LA POSICIÓN DESEADA
	mov bl, byte ptr[si]

	add bl, 30h
	
	cmp al, bl
	je respCorrecta
	dec vidas
	;LLAMO AL REGTOASCII
	xor ax,ax
	mov al, vidas
	lea bx, vidasASCII
	call regToAscii
	lea bx, preguntaMal
	call bmp

	mov ah,8
    int 21h

	jmp askGameMenu
askGameMenu_CP:
	jmp askGameMenu
vellofacPreg:
	lea bx, velloBMP
	call bmp

	mov ah,8
    int 21h
    cmp al, 33h
    je askGameMenu_V

    ;GUARDO EL CONTENIDO DE LA RESPUESTA EN LA VARIABLE
	lea di, eleccion
	add di, 4
	sub al, 30h
	mov byte ptr[di], al
	add al, 30h
	

	lea si, maquina ; RECUPERA LOS DATOS DE LA ELECCIÓN DE LA MAQUINA
	add si, 4       ; AVANZO EN EL OFFSET HASTA LA POSICIÓN DESEADA
	mov bl, byte ptr[si]
	add bl, 30h	
	cmp al, bl

	je respCorrecta
	
	dec vidas
	; Recibe en AL el registro para pasar a ASCII, y recibe por BX el offset de la variable
	; ASCII a rellenar.
	;LLAMO AL REGTOASCII
	xor ax,ax
	mov al, vidas
	lea bx, vidasASCII
	call regToAscii
	lea bx, preguntaMal
	call bmp

	mov ah,8
    int 21h

	jmp askGameMenu
askGameMenu_V:
	jmp askGameMenu

respCorrecta:
	dec vidas
	xor ax,ax
	mov al, vidas
	lea bx, vidasASCII
	call regToAscii

	lea bx, preguntaBien
	call bmp
	mov ah,8
    int 21h
	jmp askGameMenu
saleAskGame:
	pop si
	pop dx
	pop bx
	pop ax
	ret
askgame endp

allIn proc
	push ax
	push bx
	push dx
	push si

	lea bx, pjs_pick
	call bmp
	mov ah,8
    int 21h
    cmp al,31h
    je eligePrimerPJ
    cmp al,32h
    je eligeSegundoPJ
    cmp al,33h
    je eligeTercerPJ
    cmp al,34h
    je eligeCuartoPJ_JMP
    cmp al,35h
    je eligeQuintoPJ_JMP
eligeQuintoPJ_JMP:
	jmp eligeQuintoPJ
eligeCuartoPJ_JMP:
	jmp eligeCuartoPJ


eligePrimerPJ:
	xor ax,ax
	lea si, personaje1
	lea di, maquina
	mov cx, 5
pj1_Pr:
	mov al, byte ptr[si]
	mov ah, byte ptr[di]
	cmp al, ah
	je esOkVal_PJ1 ;Si coinciden
	vuelveVal_PJ1:
	loop pj1_Pr
	cmp validaciones, 5
	je ganaste_Proc_pj1
	jmp perdiste_proc
	esOkVal_PJ1:
	inc validaciones
	jmp vuelveVal_PJ1
ganaste_Proc_pj1:
	jmp ganaste_Proc

eligeSegundoPJ:
	xor ax,ax
	lea si, personaje2
	lea di, maquina
	mov cx, 5
pj2_Pr:
	mov al, byte ptr[si]
	mov ah, byte ptr[di]
	cmp al, ah
	je esOkVal_PJ2
	vuelveVal_PJ2:
	loop pj2_Pr

	cmp validaciones, 5
	je ganaste_Proc
	jmp perdiste_proc
esOkVal_PJ2:
	inc validaciones
	jmp vuelveVal_PJ2


eligeTercerPJ:
	xor ax,ax
	lea si, personaje3
	lea di, maquina
	mov cx, 5
pj3_Pr:
	mov al, byte ptr[si]
	mov ah, byte ptr[di]
	cmp al, ah
	je esOkVal_PJ3
	vuelveVal_PJ3:
	loop pj3_Pr
	
	cmp validaciones, 5
	je ganaste_Proc
	jmp perdiste_proc
esOkVal_PJ3:
	inc validaciones
	jmp vuelveVal_PJ3

eligeCuartoPJ:
	xor ax,ax
	lea si, personaje4
	lea di, maquina
	mov cx, 5
pj4_Pr:
	mov al, byte ptr[si]
	mov ah, byte ptr[di]
	cmp al, ah
	je esOkVal_PJ4
	vuelveVal_PJ4:
	loop pj4_Pr
	
	cmp validaciones, 5
	je ganaste_Proc
	jmp perdiste_proc
esOkVal_PJ4:
	inc validaciones
	jmp vuelveVal_PJ4

eligeQuintoPJ:
	xor ax,ax
	lea si, personaje5
	lea di, maquina
	mov cx, 5
pj5_Pr:
	mov al, byte ptr[si]
	mov ah, byte ptr[di]
	cmp al, ah
	je esOkVal_PJ5
	vuelveVal_PJ5:
	inc validaciones
	loop pj5_Pr
	
	cmp validaciones, 5
	je ganaste_Proc
	jmp perdiste_proc
esOkVal_PJ5:
	inc validaciones
	jmp vuelveVal_PJ5

ganaste_Proc:
	lea bx, ganaste
	call bmp
	mov ah,8
  int 21h

  lea bx, maq_img
	call bmp
	mov ah,8
  int 21h

	jmp fin_AllIn
perdiste_proc:
	lea bx, perdiste
	call bmp
	mov ah,8
  int 21h

	lea bx, maq_img
	call bmp
	mov ah,8
  int 21h
fin_AllIn:
	pop si
	pop dx
	pop bx
	pop ax
	ret
allIn endp

surrender proc
	push ax
	push bx
	push dx
	push si 

	lea bx, perdiste
	call bmp
	mov ah,8
	int 21h

	lea bx, maq_img
	call bmp
	mov ah,8
	int 21h

	pop si
	pop dx
	pop bx
	pop ax
	ret
surrender endp

inicializa proc
	;RECORDAR PLANCHAR TODAS LAS VARIABLES, (ASCII, REG, RESPUESTAS DEL USUARIO REG)
	push ax
	push bx
	push dx
	push si

	mov validaciones, 0
	mov vidas, 3
	lea si, vidasASCII
	mov byte ptr[si], 33h

	mov cx,5
	lea bx, eleccion
	limpiaElecciones:
	mov byte ptr[bx],0
	inc bx
	loop limpiaElecciones

	aleatoriza:
		call random
		cmp al,0
		jae casiNroValido;0 o superior

	casiNroValido:
		cmp al,4 ;ES 1 MENOS DE LOS PERSONAJES A UTILIZAR, PORQUE CERO ES UNO DE LOS VÁLIDOS.
		jbe nroValido
		jmp aleatoriza

	nroValido:
		cmp al,0
		je pj1_elec
		cmp al,1
		je pj2_elec
		cmp al,2
		je pj3_elec
		cmp al,3
		je pj4_elec
		cmp al,4
		je pj5_elec


	pj1_elec:
	lea bx, pj1_name
	lea si, maq_name
	call pasa_nombre

	lea bx, pj1_bmp
	lea si, maq_img
	call pasa_img

	lea bx, personaje1
	lea si, maquina
	call pasa_datos


	jmp finINIT
	pj2_elec:
	lea bx, pj2_name
	lea si, maq_name
	call pasa_nombre

	lea bx, pj2_bmp
	lea si, maq_img
	call pasa_img

	lea bx, personaje2
	lea si, maquina
	call pasa_datos


	jmp finINIT
	pj3_elec:
	lea bx, pj3_name
	lea si, maq_name
	call pasa_nombre

	lea bx, pj3_bmp
	lea si, maq_img
	call pasa_img

	lea bx, personaje3
	lea si, maquina
	call pasa_datos

	jmp finINIT

	pj4_elec:
	lea bx, pj4_name
	lea si, maq_name
	call pasa_nombre

	lea bx, pj4_bmp
	lea si, maq_img
	call pasa_img

	lea bx, personaje4
	lea si, maquina
	call pasa_datos

	jmp finINIT
	pj5_elec:
	lea bx, pj5_name
	lea si, maq_name
	call pasa_nombre

	lea bx, pj5_bmp
	lea si, maq_img
	call pasa_img

	lea bx, personaje5
	lea si, maquina
	call pasa_datos

	jmp finINIT

finINIT:


	pop si
	pop dx
	pop bx
	pop ax
	ret
inicializa endp

;***********************************************
;**************INICIO DE LIBRERÍAS**************
;***********************************************
random proc
	push cx
	push dx
	mov ah, 2ch
	int 21h
	xor ax, ax
	mov al, dl
	mov cl, 0ah
	div cl
	xor ah, ah
	pop dx
	pop cx
	ret
random endp

pasa_nombre proc
;PASA POR BX EL OFFSET DEL NOMBRE DEL PERSONAJE ELEGIDO POR LA MÁQUINA, YA EN MEMORIA.
;PASA POR SI EL OFFSET A DONDE COPIAR.

push bx
push si
push ax
rep_nomb:
	mov al, byte ptr[bx]
	cmp al, 24h
	je finSelec
	mov byte ptr[si],al
	inc bx
	inc si
	jmp rep_nomb
finSelec:
pop ax
pop si
pop bx
ret
pasa_nombre endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pasa_datos proc
;PASA POR BX EL OFFSET DE LAS CARACTERISTICAS DEL PERSONAJE ELEGIDO POR LA MÁQUINA
;PASA POR SI EL OFFSET DE LA VARIABLE A RELLENAR, PARA RECORDARLA.

push bx
push si
push ax
push cx
mov cx, 5
rep_dat:
	mov al, byte ptr[bx]
	mov byte ptr[si],al
	inc bx
	inc si
	loop rep_dat
finDat:

pop cx
pop ax
pop si
pop bx
ret
pasa_datos endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pasa_img proc
;PASA POR BX EL OFFSET DEL BMP DEL PERSONAJE ELEGIDO POR LA MÁQUINA
;PASA POR SI EL OFFSET DE LA VARIABLE A RELLENAR, PARA RECORDARLA.

push bx
push si
push ax
push cx
rep_img:
	mov al, byte ptr[bx]
	cmp al, 24h
	je finIMG
	mov byte ptr[si],al
	inc bx
	inc si
	jmp rep_img
finIMG:

pop cx
pop ax
pop si
pop bx
ret
pasa_img endp

VeVida proc
;PASA POR BX EL OFFSET DEL CARTEL DE VIDA.
;PASA POR AX EL EXTRA SI ES NECESARIO PARA MOVER EL PUNTERO PARA QUE EL NÚMERO ENTRE
	push cx
	push dx
	push si
	push ax
	push bx
	push dx
	
  MOV SI, bx	   ; Offset
  xor bx, bx
  mov DI, 30      ; Initial column position
  cmp ax, 0
  je lop
  add di, 8 ; LA CANTIDAD APROX DE CARACTERES DEL "INTENTOS:" 
  inc di
lop:
  ; Set cursor position
  MOV AH, 02h
  MOV BH, 00h    ; Set page number
  MOV DX, DI     ; COLUMN number in low BYTE
  MOV DH, 1      ; ROW number in high BYTE
  INT 10h

  LODSB          ; load current character from DS:SI to AL and increment SI
  CMP AL, '$'    ; Is string-end reached?
  JE  fin        ; If yes, continue
  ; Print current char
  MOV AH,09H
  MOV BH, 0      ; Set page number
  MOV BL, 0Eh      ; Color
  MOV CX, 1      ; Character count
  INT 10h
  INC DI         ; Increase column position
  jmp lop
fin:


	pop dx
	pop bx
	pop ax
	pop si
	pop dx 
	pop cx 
	ret
VeVida endp
;Créditos a
;https://stackoverflow.com/questions/55778271/print-a-colored-string
VeResp proc
;PASA POR BX EL OFFSET DEL CARTEL DE VIDA.
	push cx
	push dx
	push si
	push ax
	push bx
	push dx
	
  MOV SI, offset eleccionASCII
  mov DI, 0      ; Initial column position
  mov rowNumber, 10
lop_Resp:
  ; Set cursor position
  MOV AH, 02h
  MOV BH, 00h    ; Set page number
  MOV DX, DI     ; COLUMN number in low BYTE
  MOV DH, rowNumber ; ROW number in high BYTE
  INT 10h
  LODSB          ; load current character from DS:SI to AL and increment SI
  CMP AL, '$'    ; Is string-end reached?
  JE  fin_Resp        ; If yes, continue
  ;EXPERIMENTAL
  cmp al, "-"
  je bajoRow
  ;FIN EXPERIMENTAL
  ; Print current char
  MOV AH,09H
  MOV BH, 0      ; Set page number
  MOV BL, 3      ; Color
  MOV CX, 1      ; Character count
  INT 10h
  cmp di, 35
  je bajoRow 
  INC DI         ; Increase column position
  jmp lop_Resp
bajoRow:
	;HAGO UNA ESPECIE DE SALTO DE LINEA.
	inc rowNumber
	mov di, 0
	jmp lop_Resp
fin_Resp:


	pop dx
	pop bx
	pop ax
	pop si
	pop dx 
	pop cx 
	ret
VeResp endp

ConstruyeResp proc
     ; PASO POR SI EL OFFSET DEL ASCII A CONSTRUIR
     ; PASO POR BX LOS REGISTROS QUE QUIERO INTERPRETAR.
	push cx
	push dx
	push si
	push ax
	push bx
	push dx

	; PLANCHO LA VARIABLE POR LAS DUDAS
	mov cx, 255
	push si
	limpiaConstResp:
		mov byte ptr [si], 24h
		loop limpiaConstResp
	pop si

		SEXO:
		cmp byte ptr [bx], 1
		je hombreConst
		cmp byte ptr [bx], 2
		je mujerConst
 		PELO:
 			inc bx
 		cmp byte ptr[bx], 1
 		je largoConst
 		cmp byte ptr[bx], 2
 		je cortoConst
 		LENTES:
	 		inc bx
 		cmp byte ptr[bx], 1
 		je noLentConst
 		cmp byte ptr[bx], 2
 		je siLentConst
 		COLOR_PELO:
 			inc bx
		cmp byte ptr[bx], 1
		je blancoConst
		cmp byte ptr[bx], 2
		;je castanioConst
		je castanioConst_JMP
		cmp byte ptr[bx], 3
 		;je rubioConst
 		je rubioConst_JMP
		VELLO_FACIAL:
			inc bx
		cmp byte ptr[bx], 1
		;je noVelloConst
		je noVelloConst_JMP

		cmp byte ptr[bx], 2
		;je siVelloConst
		je siVelloConst_JMP
		jmp finConst

castanioConst_JMP:
	jmp castanioConst
rubioConst_JMP:
	jmp rubioConst
noVelloConst_JMP:
	jmp noVelloConst
siVelloConst_JMP:
	jmp siVelloConst

;*****
;SEXO
;*****
hombreConst:
	lea di, hombCart
hombreConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je pelo
	mov byte ptr[si],al
	inc si
	inc di
	jmp hombreConst_1

mujerConst:
	lea di, mujCart
mujerConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je pelo
	mov byte ptr[si],al
	inc si
	inc di
	jmp mujerConst_1

;*****
;PELO
;*****

largoConst:
	lea di, larCart
largoConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je lentes
	mov byte ptr[si],al
	inc si
	inc di
	jmp largoConst_1

cortoConst:
	lea di, corCart
cortoConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je lentes
	mov byte ptr[si],al
	inc si
	inc di
	jmp cortoConst_1
;*****
;LENTES
;*****

noLentConst:
	lea di, nolentCart
noLentConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je COLOR_PELO
	mov byte ptr[si],al
	inc si
	inc di
	jmp noLentConst_1

siLentConst:
	lea di, silentCart
siLentConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je COLOR_PELO
	mov byte ptr[si],al
	inc si
	inc di
	jmp siLentConst_1
;*****
;COLOR PELO
;*****

blancoConst:
	lea di, blanCart
blancoConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je VELLO_FACIAL
	mov byte ptr[si],al
	inc si
	inc di
	jmp blancoConst_1

castanioConst:
	lea di, castCart
castanioConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	;je VELLO_FACIAL
	je castanioConst_1_JMP
	mov byte ptr[si],al
	inc si
	inc di
	jmp castanioConst_1
castanioConst_1_JMP:
	jmp VELLO_FACIAL

rubioConst:
	lea di, rubCart
rubioConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	;je VELLO_FACIAL
	je rubioConst_1_JMP
	mov byte ptr[si],al
	inc si
	inc di
	jmp rubioConst_1

rubioConst_1_JMP:
	jmp VELLO_FACIAL


noVelloConst:
	lea di, noVelloCart
noVelloConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je finConst
	mov byte ptr[si],al
	inc si
	inc di
	jmp noVelloConst_1

siVelloConst:
	lea di, siVelloCart
siVelloConst_1:
	mov al, byte ptr[di]
	cmp al, 24h
	je finConst
	mov byte ptr[si],al
	inc si
	inc di
	jmp siVelloConst_1

finConst:
	pop dx
	pop bx
	pop ax
	pop si
	pop dx 
	pop cx 
	ret

ConstruyeResp endp

regToAscii proc
; Recibe en AL el registro para pasar a ASCII, y recibe por BX el offset de la variable
; ASCII a rellenar.
	push ax
	push bx
	push dx
	push si
	push cx

	add al, 30h
	mov byte ptr [bx],al

	pop cx
	pop si
	pop dx
	pop bx
	pop ax
	ret
regToAscii endp

end
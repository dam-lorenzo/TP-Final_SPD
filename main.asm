.8086
.model small
.stack 100h

.data

menu db "Bienvenido al juego de los numeros!",0dh,0ah
     db 0dh,0ah
     db "Se generara un numero de 4 digitos sin repeticiones.",0dh,0ah
     db "Debe adivinar correctamente cada digito y su posicion.",0dh,0ah
     db "La dificultad que elija indicara la cantidad de intentos que tiene para lograrlo",0dh,0ah,24h

newLine db 0dh,0ah,24h

menu2 db "Ingrese un numero para seleccionar el nivel de dificultad: ",0dh,0ah
      db "1 - Facil - 8 intentos",0dh,0ah
      db "2 - Medio - 6 intentos",0dh,0ah
      db "3 - Dificil - 4 intentos ",0dh,0ah,24h

startGameText db "Ingrese 4 digitos:",0dh,0ah,24h

winText db "Felicitaciones! Adivino el numero.",0dh,0ah
      db "Desea jugar otra vez?",0dh,0ah
      db "-Si",0dh,0ah
      db "-No",0dh,0ah,24h

loseText db "El numero era: ",24h

loseText2 db "Ha perdido, desea volver a jugar?",0dh,0ah
       db "-Si",0dh,0ah
       db "-No",0dh,0ah,24h

GoodbyeText db "Gracias por jugar!",0dh,0ah,24h

difficultText          db "0",0dh,0ah,24h ;variable para almacenar la opcion de dificulad que ingresa el usuario
LivesNumber            db 0 ;variable para guardar la cantidad de vidas dependiendo la dificulad elegida
levelsOptions             db "123", 24h ; lista de niveles disponibles
validNumbers      db "0123456789", 24h ;lista de numeros permitidos para ingresar
validOptions     db "sSnN", 24h;respuestas validas para volver a jugar
userNumber       db "0000", 24h ; aca ingresara numeros el usuario
randomNumber        db "0000", 24h ;El numero que generara la funcion randomizadora
option              db "0",0dh,0ah,24h;variable que almacena respuesta de volver a jugar

.code

    extrn readKeyboard:proc
    extrn print:proc
    extrn getLifes:proc
    extrn getRandomNum:proc
    extrn compareNumbers:proc

    main proc
        mov ax, @data
        mov ds, ax

    StartTag:
        mov ah, 9     ;IMPRIMO UN CARACTER CON COLOR
        mov bh, 0     ;ELIJO EN QUE PAGINA IMPRIMIR
        mov bl, 0Ah   ;ELIJO EL COLOR (Verde)
        mov cx, 36    ;CANTIDAD DE VECES QUE IMPRIMO ESE CARACTER
        int 10h

        lea dx,menu
        call print

    reintentar:
        lea dx, menu2
        call print

        push offset difficultText
        push offset levelsOptions
        push 1
        call readKeyboard ; funcion de carga de texto
        
        lea dx, newLine
        call print

        push offset difficultText
        call getLifes
        mov LivesNumber,cl

        ; lea bx, randomNumber
        ; int 80h
        push offset randomNumber
        call getRandomNum

        lea dx, newLine
        call print

        mov cl, LivesNumber
        lea dx, startGameText
        call print
        jmp Game

    Game:
        push offset userNumber   ;Se envia el offset de la cadena de numeros que ingresara el usuario
        push offset validNumbers  ;Se envia la lista de caracteres que puede ingresar, de 0 a 9             
        push 4                      ;Se envia la cantidad caracteres que se pueden ingresar, en este caso 4
        call readKeyboard

        lea dx, newLine
        call print

        lea bx,userNumber
        push bx
        lea dx,randomNumber
        push dx
        mov dx, 0
        call compareNumbers
        jmp ContinueGame

    AuxStart:
        jmp StartTag
    ContinueGame:
        cmp dh, 4
        je WinTag

        lea dx, newLine
        call print

        loop Game              ;Vuelve a ejecutar el programa desde juego:

        lea dx, newLine
        call print

        lea dx, loseText
        call print

        lea dx,randomNumber
        call print

        lea dx, newLine
        call print

        lea dx, loseText2
        call print

        push offset option
        push offset validOptions
        push 1
        call readKeyboard

        lea dx, newLine
        call print

        mov dl, option
        cmp dl, 's'
        je AuxStart
        cmp dl, 'S'
        je AuxStart
        jmp EndTag

    AuxStart2:
        jmp AuxStart

    WinTag:
        lea dx, newLine
        call print

        lea dx, winText
        call print

        push offset option
        push offset validOptions
        push 1
        call readKeyboard

        lea dx, newLine
        call print

        lea dx, newLine
        call print

        mov dl, option
        cmp dl, 's'
        je AuxStart2
        cmp dl, 'S'
        je AuxStart2


    EndTag:
        lea dx, newLine
        call print

        lea dx, GoodbyeText
        call print

        mov ax, 4c00h
        int 21h

    main endp
end main
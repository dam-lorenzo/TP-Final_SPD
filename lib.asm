.8086
.model small
.stack 100h

.data

.code

  public readKeyboard 
  public print
  public getLifes
  public compareNumbers

    readKeyboard proc

        ;CAJA DE CARGA PERSONALIZABLE
        ;   Se pasan 3 variables por STACK
        ;   El primero es el puntero a la variable que va a guardar el texto en MAIN - PUSH offset <texto>
        ;   El segundo es un puntero hacia una lista de "caracteres permitidos"      - PUSH offset <lista>
        ;   Y el tercero es un numero indicando el tamaño de la entrada              - PUSH <numero>

        ;   La lista es una variable texto con los caracteres permitidos,
        ;   EJ: lista db "aeiouAEIOU1234", 024h
        ;   es una caja que guarda un texto que solo acepta vocales y numeros del 1 al 4.

        ;   El resultado de la funcion se va guardando directamente en la variable <texto>.

          push bp
          mov bp, sp

          push ax
          push bx
          push cx
          push dx
          push si
          push di
          pushf
          ; ----- guardamos todo (por las dudas)


        ; --------- <- nuevo BP
        ; | oldBP | +0
        ; --------- 
        ; |  IP   | +2
        ; --------- 
        ; | largo | +4
        ; --------- 
        ; | lista | +6
        ; --------- 
        ; | texto | +8
        ; --------- <- old BP

            mov bx, ss:[bp+8] ; apuntamos a <texto>
            mov cx, ss:[bp+4] ; largo del texto

            xor si, si ; index 0 de <texto>

        StartReadKeyboard:
            mov ah, 8 ; leo caracter (sin echo)
            int 21h

            cmp al, 0dh ; [ENTER] termina carga
            je EndReadKeyboard

            cmp al, 08h ; [BACKSPACE] va a borrado
            je Delete


            push si ; guardamos la posicion donde estabamos
            push bx ; guardamos <texto>

            xor si, si; limpiamos para loop y entramos

            jmp CompareList ; comparar con permitidos
        EndCompareList: ; si es permitido seguimos

            pop bx ; cargamos de nuevo <texto>
            pop si ; seguimos donde estabamos


            ; nos fijamos si estamos al final de la linea
            cmp si, cx
            jae EndLine

            ;sino guardo y continuo
            mov [bx+si], al
            jmp Continue


        EndLine:
            ; si estamos al final de la linea, se prepara para
            ; sobreescribir el ultimo caracter

            dec si ; volvemos 1 espacio
            mov [bx+si], al ; guardo caracter
            mov ah, 2
            mov dl, 08h ; movemos cursor uno para atras
            int 21h
          
        Continue:
            mov ah, 2
            mov dl, [bx+si] ; imprimo por pantalla
            int 21h 

            inc si
            jmp StartReadKeyboard ;vuelvo al inicio



        CompareList:
            mov bx, ss:[bp+6] ; cargamos la lista de caracteres

        LoopList:  
            cmp byte ptr[bx+si], 24h ; si encontramos un $ es que terminamos de recorrer la lista
            ; si llegamos al final, entonces no era ninguno de los permitidos
            ; saltamos al principio sin guardar
            je IgnoreCharacter

            cmp al, [bx+si]
            ; si lo que entro es igual quiere decir que es uno de los permitidos
            ; saltamos al guardado    
            je EndCompareList

            inc si
            jmp LoopList ; si no, aumentamos SI y seguimos comparando

        IgnoreCharacter:
            pop bx ; cargamos de nuevo <texto>
            pop si ; recuperamos el indice y volvemos al principio
            jmp StartReadKeyboard


        Delete:
            mov byte ptr[bx+si], 24h ; limpio el caracter en la variable

            mov ah, 2
            mov dl, 08h ; mueve el cursor hacia atras
            int 21h
            mov dl, " " ; limpia el caracter en pantalla
            int 21h
            mov dl, 08h ; mueve el cursor hacia atras
            int 21h

            cmp si, 0 ; nos fijamos si estabamos al principio
            je StartReadKeyboard ; Si esta en la 0, no hago nada (si no pisariamos algo atras!)

            dec si ; sino decremento el puntero para recargar la variable
            jmp StartReadKeyboard


        EndReadKeyboard:

        ; devolvemos todo como estaba
          popf
          pop di
          pop si
          pop dx
          pop cx
          pop bx
          pop ax

          pop bp ; vuelve al viejo BP 

        ; STACK
        ; |       |
        ; ---------  <- SP
        ; |  IP   | 
        ; --------- 
        ; | largo |
        ; --------- 
        ; | lista |
        ; --------- 
        ; | texto |
        ; --------- <- BP

          ret 6

    readKeyboard endp

    print proc ;Funcion para imprimir que trabaja con registros

            push ax
            mov ah,9
            int 21h
            pop ax
            ret

    print endp

    getLifes proc
        ; FUNCION DE CANTIDAD DE VIDAS
        ; Recibe el numero de dificultad
        ; Devuelve la cantidad de vidas segun la dificulad 5, 8, 11
        ; Que se almacenara en una variable para indicar el numero que se almacenara en cx cuando el usuario tenga que ingresar los 4 numeros

        push bp
        mov bp,sp

        push bx
        push si
        pushf

        mov bx, ss:[bp+4]       ;Se mueve el offset de la variable dificultad a bx
        mov si,0                ;El contador si se establece en 0 para recorrer la unica posicion del array

        cmp byte ptr[bx+si],31h
        je Easy
        cmp byte ptr[bx+si],32h
        je Normal
        cmp byte ptr[bx+si],33h
        je Hard

        Easy:
            mov cl,8
            jmp EndGetLifes

        Normal:
            mov cl,6
            jmp EndGetLifes

        Hard:
            mov cl,4
            jmp EndGetLifes

        EndGetLifes:
            popf
            pop si
            pop bx
            pop bp
            ret 2
    getLifes endp

    compareNumbers proc
        ;Esta funcion recibe desde main las variables del numero aleatorio y el numero que ingresa el usuario
        ;y compara posicion por posicion, otorgando bien si el numero y la posicion coinciden, regular si el numero coincide pero no asi la posicion
        ;y mal si no coincide ninguna de las dos cosas.
        push bp
        mov bp,sp
        push ax
        push bx
        push cx
        push si
        push di
        pushf
        mov si,0
        mov di,0
        
        Cycle:
            cmp si,4
            je EndCompareNumbers
            mov bx, ss:[bp+4]       ;se almacena en bx la variable numeroRandom
            mov cl, byte ptr[bx+di] ;este valor se pasa al registro cx para poder compararlo con la otra variable
            mov bx, ss:[bp+6]       ;se almacena en bx la variable numeroUsuario
            cmp byte ptr[bx+si],cl  ;se comparan el numero aleatorio con el numero ingresado por el usuario
            je CheckValue              ;si coincide el valor del aleatorio con el del ingreso se revisa si es un acierto
            cmp di,3                ;si di es 3, indicando que ya se recorrio al numero aleatorio por completo
            je BadNumber                  ;se salta a la etiqueta que imprime una M
            jmp LoopDi            ;si aun no se recorrio todo el numero aleatorio se incrementa el indice que lo recorre
        CheckValue:
            cmp si,di               ;si coinciden si y di es un acierto y se emite una B
            je GoodValue
            jmp RegularValue             ;caso contrario se emite una R
        GoodValue:
            mov ah, 9     ;IMPRIMO UN CARACTER CON COLOR
            mov bh, 0     ;ELIJO EN QUE PAGINA IMPRIMIR
            mov bl, 0Ah   ;ELIJO EL COLOR (Verde)
            mov cx, 1     ;CANTIDAD DE VECES QUE IMPRIMO ESE CARACTER
            int 10h
            
            inc dh
            mov ah,2
            mov dl,42h     ;emite por pantalla una B mayuscula color verde 
            int 21h
            jmp LoopSi
        RegularValue:
            mov ah, 9     ;IMPRIMO UN CARACTER CON COLOR
            mov bh, 0     ;ELIJO EN QUE PAGINA IMPRIMIR
            mov bl, 0Eh   ;ELIJO EL COLOR (Amarillo)
            mov cx, 1     ;CANTIDAD DE VECES QUE IMPRIMO ESE CARACTER
            int 10h
            mov ah,2
            mov dl,52h    ;emite por pantalla una R mayuscula color amarillo
            int 21h
            jmp LoopSi
        BadNumber:
            mov ah, 9     ;IMPRIMO UN CARACTER CON COLOR
            mov bh, 0     ;ELIJO EN QUE PAGINA IMPRIMIR
            mov bl, 04h   ;ELIJO EL COLOR (Rojo)
            mov cx, 1     ;CANTIDAD DE VECES QUE IMPRIMO ESE CARACTER
            int 10h
            mov ah,2
            mov dl,4dh    ;emite por pantalla una M mayuscula color rojo
            int 21h
            jmp LoopSi
        LoopDi:
            inc di
            jmp Cycle
        LoopSi:
            inc si
            mov di,0      ;di se vuelve a poner en cero para que el proximo valor a analizar del numero ingresado se compare con todas las posiciones del aleatorio, caso contrario se compara unicamente con el ultimo valor.
            jmp Cycle   
        EndCompareNumbers:
            popf
            pop di
            pop si
            pop cx
            pop bx
            pop ax
            pop bp
            ret 4
    compareNumbers endp

end
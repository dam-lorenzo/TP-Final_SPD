.8086
.model small
.stack 100h

.data

.code

    public getRandomNum

    getRandomNum proc

        push bp
        mov bp,sp
        
        push bx
        push ax
        push cx
        push dx
        push si
        push di
        pushf

        mov bx, ss:[bp+4]

        ReRand:
            call rand
            call RegToAscii
            mov di, 1        ;PASO UNO PORQUE COMPARO CON LA PRIMERA UNIDAD 
            mov dx, 0
            mov cx, 0
            mov ax, 1        ;USO COMO CONTADOR AX TAMBIEN POR EL MOV DE 16 BITS A DI
            mov si, 0
        DuplicateNumber:
            cmp cl, 3       ;marca la salida del total de comparaciones
            je EndGetRandomNum
            cmp dl, 3       ;marca las siguientes comparaciones
            je LoopGetRandomNum
            mov dh, byte ptr[bx+di]
            cmp byte ptr[bx+si], dh    ;comparo valor con los que le siguen
            je ReRand        ;si un valor es igual vuelvo a generar un RANDOM
            inc di
            inc dl  
            jmp DuplicateNumber

        LoopGetRandomNum:
            inc si
            xor dx, dx
            inc cl      ;para hacer menos comparaciones uso ch como contador de una comparacion
            mov dl, cl  ;y se lo paso a dl para que ya cuente una vuelta
            inc ax
            mov di, ax  ;PARA AVANZAR USO AX 
            jmp DuplicateNumber


        EndGetRandomNum:
            popf
            pop di
            pop si
            pop dx
            pop cx
            pop ax
            pop bx
            
            pop bp
            ret 2

    getRandomNum endp

    RegToAscii proc
        push ax
        push bx
        push dx
        push si
        push cx
        pushf

        mov dx, 0
        mov cx, ax; Valor a mostrar

        add bx,3
        xor ax,ax
        mov ax, cx
        mov cx, 10
        div cx
            mov byte ptr [bx],dl
            add byte ptr([bx]),30h

        xor dx,dx
        dec bx
            div cx
            mov byte ptr[bx],dl
            add byte ptr([bx]),30h
            
        xor dx,dx
        dec bx
            div cx
            mov byte ptr [bx],dl
            add byte ptr([bx]),30h
        xor dx,dx
        dec bx
            div cx
            mov byte ptr [bx],dl
            add byte ptr([bx]),30h     

        popf
        pop cx
        pop si
        pop dx
        pop bx
        pop ax
        ret
    RegToAscii endp

    rand proc
        push cx
        push dx
        pushf

        mov ah, 2ch ;devuelve la hora del sistema
        int 21h     ;ch -> horas
                    ;cl ->minutos
                    ;dh -> segundos
                    ;dl-> centesimas de segundo (max 99)
        xor ax,ax   ;limpia el registro
        mov al, dl  ;multiplico los segundos por las centesimas
        mul dh
        add ah,al   ;completo ax


        popf
        pop dx
        pop cx
        ret
    rand endp
end
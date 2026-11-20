.8086
.model tiny
.code
org 100h

start:
    jmp Install

;========================================
; INTERRUPT SERVICE ROUTINE - INT 80h
; Argumentos:
;   BX: Offset donde guardar el numero como ASCII
;========================================

GetRandomNum PROC FAR

    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push ds
    push es

    ; DS:BX points to the buffer

    GenerateAgain:
        push ds
        call Rand
        pop ds

        call RegToAscii

        mov di, 1
        xor dx, dx
        xor cx, cx
        mov ax, 1
        xor si, si

    CompareDigits:
        cmp cl, 3
        je FinishISR

        cmp dl, 3
        je NextPass

        mov dh, byte ptr [bx+di]

        cmp byte ptr [bx+si], dh
        je GenerateAgain

        inc di
        inc dl
        jmp CompareDigits

    NextPass:
        inc si
        xor dx, dx
        inc cl
        mov dl, cl
        inc ax
        mov di, ax
        jmp CompareDigits

    FinishISR:

        pop es
        pop ds
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax

        iret

GetRandomNum ENDP


;========================================
; REGISTER TO ASCII
; Argumentos:
;   AX = Numero a convertirn
;   BX = offset donde guardar
; Retorno:
;   Cuatro digitos ASCII en BX
;========================================

RegToAscii PROC NEAR

    push ax
    push bx
    push dx
    push si
    push cx
    pushf

    xor dx, dx
    mov si, ax

    add bx, 3
    xor ax, ax
    mov ax, si
    mov cx, 10
    div cx

    mov byte ptr [bx], dl
    add byte ptr [bx], 30h

    xor dx, dx
    dec bx
    div cx

    mov byte ptr [bx], dl
    add byte ptr [bx], 30h

    xor dx, dx
    dec bx
    div cx

    mov byte ptr [bx], dl
    add byte ptr [bx], 30h

    xor dx, dx
    dec bx
    div cx

    mov byte ptr [bx], dl
    add byte ptr [bx], 30h

    popf
    pop cx
    pop si
    pop dx
    pop bx
    pop ax

    ret

RegToAscii ENDP


;========================================
; Generador de numeros aleatoreo
; retorno:
;   AX = generated number
;========================================

Rand PROC NEAR

    push cx
    push dx
    pushf

    mov ah, 2Ch
    int 21h

    xor ax, ax
    mov al, dl
    mul dh
    add ah, al

    popf
    pop dx
    pop cx

    ret

Rand ENDP


;========================================
; Datos del residente
;========================================

OldInt80Offset dw 0
OldInt80Segment dw 0

ResidentEnd LABEL BYTE


;========================================
; Instalador IVT
;========================================

Install:

    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Obtener el vector de la int 80h anterior

    mov ax, 3580h
    int 21h

    mov OldInt80Offset, bx
    mov OldInt80Segment, es

    ; Instalar GetRandomNum como INT 80h

    mov ax, 2580h
    mov dx, OFFSET GetRandomNum
    int 21h

    ; Mantener el programa residente

    mov ax, (15 + OFFSET ResidentEnd)
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1

    mov dx, ax
    mov ax, 3100h
    int 21h

END start
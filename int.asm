.8086
.model tiny
.code
org 100h

start:
    jmp Install

; ------------------------------------------------------------
; Interrupcion 80h: genera un valor pseudoaleatorio en AX.
; Entrada: ninguna.
; Salida:   AX = valor generado.
; Preserva los demas registros.
; ------------------------------------------------------------
RandISR proc far
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push ds
    push es

    mov ah, 2Ch
    int 21h

    ; DOS devuelve:
    ; DH = segundos
    ; DL = centesimas de segundo
    ; Se multiplican ambos valores.
    xor ax, ax
    mov al, dl
    mul dh
    add ah, al

    pop es
    pop ds
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx

    iret
RandISR endp

; El vector anterior se guarda por si se necesita restaurarlo.
OldInt80Offset  dw 0
OldInt80Segment dw 0

ResidentEnd label byte

; ------------------------------------------------------------
; Instalador: registra RandISR en el vector 80h y queda
; residente en memoria.
; ------------------------------------------------------------
Install:
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Obtener y guardar el vector 80h anterior.
    mov ax, 3580h
    int 21h
    mov OldInt80Offset, bx
    mov OldInt80Segment, es

    ; Instalar nuestra rutina en el vector 80h.
    mov ax, 2580h
    mov dx, offset RandISR
    int 21h

    ; Calcular los parrafos que deben quedar residentes.
    mov ax, (15 + offset ResidentEnd)
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    mov dx, ax

    ; Terminar y dejar residente la parte anterior a ResidentEnd.
    mov ax, 3100h
    int 21h

end start

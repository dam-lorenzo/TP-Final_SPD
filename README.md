# Proyecto TP SPD

Programa escrito en ensamblador 8086.

## Introduccion

El proyecto consiste en un juego de adivinar un numero de 4 digitos. Al empezar se puede elegir la dificultad (de esto depende la cantidad de vidas) y luego se procedera a ingregar los numeros. El juego revisa los numeros ingresados y muestra un `B` (bien) cuando el numero coincide con el valor y posicion, un `R` (regular) cuando coincide el numero pero no la posicion, y un `M` (mal) cuando no coincide ni numero ni posicion. El juego termina cuando se adivina el numero, o se queda sin vidas.


## Consideraciones

El numero a adivinar no tiene digitos repetidos. Si se ingresa un digito varias veces, va a marcar R en las posiciones que no corresponda.

## Requisitos

- Turbo Assembler (`TASM`).
- Turbo Linker (`TLINK`).

## Compilar

Se puede usar el script `install.bat` para instalar la interrupcion, compilar el programa, y ejecutarlo.

```bat
install.bat
```

Compile los archivos fuente con el siguiente comando, indicando el nombre de cada archivo:

```bat
tasm random.asm
tasm lib.asm
tasm main.asm
```

Estos comandos generan los archivos objeto `random.obj`, `lib.obj` y `main.obj`.

## Enlazar

Ejecute:

```bat
tlink main.obj lib.obj random.obj
```

El resultado será un ejecutable generado por Turbo Linker.

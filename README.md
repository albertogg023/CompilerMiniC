# CompilerMiniC

Este proyecto es un compilador que transforma programas escritos en el lenguaje MiniC en código ensamblador MIPS. MiniC es un lenguaje de programación simple que permite a los programadores escribir código de bajo nivel similar al lenguaje C.

## Contenido del Repositorio

El repositorio tiene la siguiente estructura de directorios:
 - [code](code): La carpeta que contiene el código fuente de la aplicación.
 - [examplesminiC](examplesminiC): Carpeta que contiene ejemplos de código del lenguaje MiniC.
 - [memoria.pdf](memoria.pdf): Documento que proporciona documentación detallada sobre cómo funciona el compilador, la sintaxis de MiniC admitida y cómo usarlo.

## Compilación y Ejecución

Para compilar el programa ubícate en el directorio [code](code) y asegúrate de tener gcc, flex (para lex) y bison (para yacc) instalados en tu sistema. Una vez hecho esto, ejecuta el comando:
```bash
make MC_Compiler
```
Para ejecutar el programa, se debe ejecutar:
```bash
make run
```

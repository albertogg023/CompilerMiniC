void prueba() {
    var a, b, a;    // ERROR: redeclaramos 'a'
    const 1A = 23, ??=H, C = 5; // ERROR: no seguimos el formato para declarar las constantes
    read a, b, c;   // ERROR: usamos 'c' que no existe

    done {  // ERROR: está mal escrito
        a = a - b;
    } whiles(a) // ERROR: está mal escrito
    print "Hola, soy la salida del bucle do while\n";

    fi(c){ // ERROR: está mal escrito
        print "Hola, soy el cuerpo del segundo if\n";
    }esle { // ERROR: está mal escrito
        print "Hola, soy el else del segundo if\n";
    }
    printf "Hola, soy en la salida del segundo if\n";   // ERROR: está mal escrito
    
    C = b - 1;  // ERROR: intentamos cambiar el valor de una constante
    print "Hola, soy un simple print\n; // ERROR: no cerramos el string

    
    /*  // ERROR: no cerramos el comentario
    ESTO ES UN COMENTARIO MULTILÍNEA
    ESTO ES UN COMENTARIO EN LÍNEA  
}

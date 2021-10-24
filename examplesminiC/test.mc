void ejemploMiniC() {
    var a, b, c;
    const X = 3;

    print "Introduce el valor de 'a'\n";
    read  a;
    print "Introduce el valor de 'b'\n";
    read  b;
    print "Introduce el valor de 'c'\n";
    read  c;

    do {
        print a, "\n";
        a = a - 1;
    } while(a)

    if(b){
        print "Hola, soy el cuerpo del if\n";
    }
    print "Hola, soy la salida del if\n";

    if(c){
        print "Hola, soy el cuerpo del if-else\n";
    }else {
        print "Hola, soy el else del if-else\n";
    }
    print "Hola, soy la salida del if-else\n";
    
    print a*X;

    /*
     ESTO ES UN COMENTARIO MULTILÍNEA
    */
    // ESTO ES UN COMENTARIO EN LÍNEA  
}

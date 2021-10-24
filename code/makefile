MC_Compiler : analSintSemGenCodigo.tab.c lex.yy.c main.c listaSimbolos.h listaCodigo.h
	gcc main.c lex.yy.c analSintSemGenCodigo.tab.c listaSimbolos.c listaCodigo.c -o MC_Compiler
lex.yy.c : analizadorLexico.l analSintSemGenCodigo.tab.h listaSimbolos.h
	flex analizadorLexico.l
analSintSemGenCodigo.tab.h analSintSemGenCodigo.tab.c : analSintSemGenCodigo.y listaSimbolos.h listaCodigo.h
	bison -d -v analSintSemGenCodigo.y
clean :
	rm -f  MC_Compiler analSintSemGenCodigo analSintSemGenCodigo.output analSintSemGenCodigo.tab.*  lex.yy.c
run :
	./MC_Compiler ./test.mc > test.s

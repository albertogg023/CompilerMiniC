%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "listaSimbolos.h"
	#include "listaCodigo.h"
	#define NUM_REGISTROS 10

	
	extern int yylex();
	extern int yylineno;
	extern int numErroresLexicos;


	void yyerror(const char *msg);
	void inicializarRegistros();
	char * getReg();
	char * getEtiq();
	char * concatDosPuntos(char * etiq);
	char * getStr();
	char * anteponBarraBaja(char * var);
	

	int numErroresSintacticos = 0;
	int numErroresSemanticos = 0;

	Lista listaSimbolos;	// tabla de simbolos
	int contadorCadenas = 1;	// para los strings en la generacion de codigo 
	Tipo tipo;	// para insertar y consultar simbolos
	Simbolo simbolo;

	ListaC listaCodigo;	// lista del codigo MIPS generado por el compilador
	int registrosLibres[NUM_REGISTROS];
	int contadorEtiquetas = 1;
%}


%union{		// para indicarle a bison el tipo que puede tener '$'' 
	char * lexema;
	ListaC codigo;
}
%type <codigo> program declarations identifier_list asig statement_list statement print_list print_item read_list expression


%token BEGINN "{"                                        
%token END "}"                                        
%token MAIN "main"                                        
%token VOID "void"                                        
%token VAR "var"                                         
%token CONST "const"                                        
%token IF "if"                                          
%token ELSE "else"                                        
%token WHILE "while"
%token DO "do"                                       
%token READ "read"                                        
%token PRINT "print"                                      
%token <lexema> ID "id"          
%token <lexema> INTLITERAL "num"                                    
%token LPAREN "("                                         		
%token RPAREN ")"                                         
%token SEMICOLON ";"                                         
%token COMMA ","                                         
%token ASSIGNOP "="                                         
%token PLUSOP "+"                                         
%token MINUSOP "-"                                         
%token MULLOP "*"                                         
%token DIVOP "/" 
%token <lexema> STRING "string"                                         


%left MINUSOP PLUSOP	// para resolver precedencia entre operaciones
%left DIVOP MULLOP		// cuanto mas abajo, mas precedencia
%left UMENOS			// creamos este token para asignar maxima precedencia a resolver el signo menos de un numero


%define parse.error verbose	// para que bison proporcione mas informacion
%expect 1	// esperamos un conflicto desplazamineto/reducción por ambigüedad del if/else, bison por defecto desplaza (así reduciendo el else con el último if)


%%

program		:		{ 	listaSimbolos = creaLS(); listaCodigo = creaLC(); inicializarRegistros();} 
				"void" "id" "(" ")" "{" declarations statement_list "}" 
					{	$$ = $7; concatenaLC($$, $8);
						if(numErroresLexicos + numErroresSintacticos + numErroresSemanticos == 0){
							imprimirTablaLS(listaSimbolos);
							imprimeCodigo($$);
						}
						else{
							printf("-------------------------------------\n");
							printf("Errores léxicos: %d\n", numErroresLexicos);
							printf("Errores sintácticos: %d\n", numErroresSintacticos);
							printf("Errores semánticos: %d\n", numErroresSemanticos);		
						}
						liberaLS(listaSimbolos); liberaLC($$); 
					}
			;


declarations	:	declarations "var" { tipo = VARIABLE; } identifier_list ";"
						{	$$ = $1;
							concatenaLC($$, $4);
						}
				|	declarations "const" { tipo = CONSTANTE; } identifier_list ";"
						{	$$ = $1;
							concatenaLC($$, $4);
						}	
				|	/* empty */
						{ $$ = creaLC(); }
				;

identifier_list		:	asig
							{ $$ = $1; }
					|	identifier_list "," asig
							{	$$ = $1;
								concatenaLC($$, $3);
							}
					|	error ","
							{ printf("ERROR SINTÁCTICO en la linea %d\n", yylineno); ++numErroresSintacticos;
							  $$ = creaLC(); guardaResLC($$, "");
							}
					;

asig 	:	"id" 
				{	$$ = creaLC();
					
					simbolo.nombre = $1; simbolo.tipo = tipo; simbolo.valor = 0;
					if(perteneceTablaLS(listaSimbolos, simbolo) == -1)
						anadeEntradaLS(listaSimbolos, simbolo);
					else{
						printf("ERROR SEMÁNTICO en la línea %d: variable o constante %s ya declarada\n", yylineno, $1);
						++numErroresSemanticos;
					}
				}
		|	"id" "=" expression
				{	$$ = $3;
					Operacion op; op.op="sw"; op.res=recuperaResLC($$); op.arg1=anteponBarraBaja($1); op.arg2=NULL;
					insertaLC($$, finalLC($$), op);
					registrosLibres[(int)op.res[2]-'0'] = 1;

					simbolo.nombre = $1; simbolo.tipo = tipo; simbolo.valor = 0;
					if(perteneceTablaLS(listaSimbolos, simbolo) == -1)
						anadeEntradaLS(listaSimbolos, simbolo);
					else{
						printf("ERROR SEMÁNTICO en la línea %d: variable o constante %s ya declarada\n", yylineno, $1);
						++numErroresSemanticos;
					}
				}
		|	error ";"
				{ printf("ERROR SINTÁCTICO en la linea %d\n", yylineno); ++numErroresSintacticos;
				  $$ = creaLC(); guardaResLC($$, "");
				}
		;

statement_list		: 	 statement_list statement
							{	$$ = $1;
								concatenaLC($$, $2);
							}
					|	 /* empty */
							{ $$ = creaLC(); }
					;

statement 	:	"id" "=" expression ";"	
					{	$$ = $3;
						Operacion op; op.op="sw"; op.res=recuperaResLC($$); op.arg1=anteponBarraBaja($1); op.arg2=NULL;
						insertaLC($$, finalLC($$), op);
						registrosLibres[(int)op.res[2]-'0'] = 1;

						simbolo.nombre = $1; simbolo.tipo = VARIABLE; simbolo.valor = 0;
						int consulta = perteneceTablaLS(listaSimbolos, simbolo);
						if(consulta == -1){
							printf("ERROR SEMÁNTICO en la línea %d: variable %s no declarada\n", yylineno, $1);
							++numErroresSemanticos;
						}
						else if(consulta == 0){
							printf("ERROR SEMÁNTICO en la línea %d: asignación a constante: %s\n", yylineno, $1);
							++numErroresSemanticos;
						}
							
					}
			|	"{" statement_list "}"
					{ $$ = $2; }
			|	"if" "(" expression ")" statement "else" statement 
					{	$$ = $3;
						char * etCuerpoElse = getEtiq();
						char * etFinIf = getEtiq();

						Operacion op; op.op="beqz"; op.res=recuperaResLC($$); op.arg1=etCuerpoElse; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);
						registrosLibres[(int)op.res[2]-'0'] = 1;

						concatenaLC($$, $5);

						op.op="b"; op.res=etFinIf; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);

						op.op=concatDosPuntos(etCuerpoElse); op.res=NULL; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);

						concatenaLC($$, $7);

						op.op=concatDosPuntos(etFinIf); op.res=NULL; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);

						liberaLC($5);
						liberaLC($7);
					}
			|	"if" "(" expression ")" statement
					{	$$ = $3;
						char * etFinIf = getEtiq();

						Operacion op; op.op="beqz"; op.res=recuperaResLC($$); op.arg1=etFinIf; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);
						registrosLibres[(int)op.res[2]-'0'] = 1;

						concatenaLC($$, $5);

						op.op=concatDosPuntos(etFinIf); op.res=NULL; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);

						liberaLC($5);
					}
			|	"while" "(" expression ")" statement
					{	$$ = $3;
						char * etCuerpoBucle = getEtiq();
						char * etSalidaBucle = getEtiq();

						Operacion op; op.op=concatDosPuntos(etCuerpoBucle); op.res=NULL; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, inicioLC($$), op);

						op; op.op="beqz"; op.res=recuperaResLC($$); op.arg1=etSalidaBucle; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);
						registrosLibres[(int)op.res[2]-'0'] = 1;

						concatenaLC($$, $5);
						
						op.op="b"; op.res=etCuerpoBucle; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);

						op.op=concatDosPuntos(etSalidaBucle); op.res=NULL; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);

						liberaLC($5);
					}
			|	"do" statement "while" "(" expression ")"
					{	$$ = $2;
						char * etCuerpoBucle = getEtiq();

						Operacion op; op.op=concatDosPuntos(etCuerpoBucle); op.res=NULL; op.arg1=NULL; op.arg2=NULL;
						insertaLC($$, inicioLC($$), op);

						concatenaLC($$, $5);

						op.op="bnez"; op.res=recuperaResLC($5); op.arg1=etCuerpoBucle; op.arg2=NULL;
						insertaLC($$, finalLC($$), op);
						registrosLibres[(int)op.res[2]-'0'] = 1;

						liberaLC($5);
					}
			|	"print" print_list ";" 
					{ $$ = $2; }  
			|	"read" 	read_list ";" 
					{ $$ = $2; }  
			|	error ";"   
					{ printf("ERROR SINTÁCTICO en la linea %d\n", yylineno); ++numErroresSintacticos;
					  $$ = creaLC(); guardaResLC($$, "");
					}
			;

print_list		:	print_item
						{ $$ = $1; }
				|	print_list "," print_item
						{	$$ = $1;
							concatenaLC($$, $3);
						}
				|	error ","
						{ printf("ERROR SINTÁCTICO en la linea %d\n", yylineno); ++numErroresSintacticos;
						  $$ = creaLC(); guardaResLC($$, "");
						}
				;

print_item		:	expression
						{	$$ = $1; 
							Operacion op; op.op="move"; op.res="$a0"; op.arg1=recuperaResLC($$); op.arg2=NULL;
							insertaLC($$, finalLC($$), op);
							registrosLibres[(int)op.arg1[2]] = 1;

							op; op.op="li"; op.res="$v0"; op.arg1="1"; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);	

							op; op.op="syscall"; op.res=NULL; op.arg1=NULL; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);
						}		
				| 	"string"
						{	$$ = creaLC(); 
							Operacion op; op.op="la"; op.res="$a0"; op.arg1=getStr(); op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							op; op.op="li"; op.res="$v0"; op.arg1="4"; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);	

							op; op.op="syscall"; op.res=NULL; op.arg1=NULL; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							simbolo.nombre = $1; simbolo.tipo = CADENA; simbolo.valor = contadorCadenas;
							anadeEntradaLS(listaSimbolos, simbolo);
							++contadorCadenas;
						}
				;

read_list		:	"id"
						{	$$ = creaLC(); 
							Operacion op; op.op="li"; op.res="$v0"; op.arg1="5"; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							op; op.op="syscall"; op.res=NULL; op.arg1=NULL; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							op; op.op="sw"; op.res="$v0"; op.arg1=anteponBarraBaja($1); op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							simbolo.nombre = $1; simbolo.tipo = VARIABLE; simbolo.valor = 0;
							int consulta = perteneceTablaLS(listaSimbolos, simbolo);
							if(consulta == -1){
								printf("ERROR SEMÁNTICO en la línea %d: variable %s no declarada\n", yylineno, $1);
								++numErroresSemanticos;
							}
							else if(consulta == 0){
								printf("ERROR SEMÁNTICO en la línea %d: asignación a constante: %s\n", yylineno, $1);
								++numErroresSemanticos;
							}
						}
				|	read_list "," "id"
						{	$$ = $1;
							Operacion op; op.op="li"; op.res="$v0"; op.arg1="5"; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							op; op.op="syscall"; op.res=NULL; op.arg1=NULL; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							op; op.op="sw"; op.res="$v0"; op.arg1=anteponBarraBaja($3); op.arg2=NULL;
							insertaLC($$, finalLC($$), op);

							simbolo.nombre = $3; simbolo.tipo = VARIABLE; simbolo.valor = 0;
							int consulta = perteneceTablaLS(listaSimbolos, simbolo);
							if(consulta == -1){
								printf("ERROR SEMÁNTICO en la línea %d: variable %s no declarada\n", yylineno, $3);
								++numErroresSemanticos;
							}
							else if(consulta == 0){
								printf("ERROR SEMÁNTICO en la línea %d: asignación a constante: %s\n", yylineno, $3);
								++numErroresSemanticos;
							}
						}
				|	error ","
						{ printf("ERROR SINTÁCTICO en la linea %d\n", yylineno); ++numErroresSintacticos;
						  $$ = creaLC(); guardaResLC($$, "");
						}
				;

expression		: 	expression "+" expression 
						{	$$ = $1;
							Operacion op; op.op="add"; op.res=recuperaResLC($$); op.arg1=op.res; op.arg2=recuperaResLC($3);
							registrosLibres[(int)op.arg2[2]] = 1;
							concatenaLC($$, $3);
							insertaLC($$, finalLC($$), op);
							liberaLC($3);	
					}
				|	expression "-" expression 
						{	$$ = $1;
							Operacion op; op.op="sub"; op.res=recuperaResLC($$); op.arg1=op.res; op.arg2=recuperaResLC($3);
							registrosLibres[(int)op.arg2[2]] = 1;
							concatenaLC($$, $3);
							insertaLC($$, finalLC($$), op);
							liberaLC($3);
						}
				|	expression "*" expression
						{	$$ = $1;
							Operacion op; op.op="mul"; op.res=recuperaResLC($$); op.arg1=op.res; op.arg2=recuperaResLC($3);
							registrosLibres[(int)op.arg2[2]] = 1;
							concatenaLC($$, $3);
							insertaLC($$, finalLC($$), op);
							liberaLC($3);
						}
				|	expression "/" expression 
						{	$$ = $1;
							Operacion op; op.op="div"; op.res=recuperaResLC($$); op.arg1=op.res; op.arg2=recuperaResLC($3);
							registrosLibres[(int)op.arg2[2]] = 1;
							concatenaLC($$, $3);
							insertaLC($$, finalLC($$), op);
							liberaLC($3);
						}
				|	"-" expression %prec UMENOS 
						{
							$$ = $2;
							Operacion op; op.op="neg"; op.res=recuperaResLC($$); op.arg1=op.res; op.arg2=NULL;
							insertaLC($$, finalLC($$), op);
						}
				|	"(" expression ")"
						{
							$$ = $2;
						}
				|	"id"
						{	Operacion op; op.op="lw"; op.res=getReg(); op.arg1=anteponBarraBaja($1); op.arg2=NULL;
							$$ = creaLC(); insertaLC($$, finalLC($$), op); guardaResLC($$, op.res);	
							simbolo.nombre = $1; simbolo.tipo = VARIABLE; simbolo.valor = 0;
							if(perteneceTablaLS(listaSimbolos, simbolo) == -1){
								printf("ERROR SEMÁNTICO en la línea %d: variable %s no declarada\n", yylineno, $1);
								++numErroresSemanticos;
							}
						}
				|	"num"
						{   Operacion op; op.op="li"; op.res=getReg(); op.arg1=$1; op.arg2=NULL;
							$$ = creaLC(); insertaLC($$, finalLC($$), op); guardaResLC($$, op.res);						
						}
				|	error ";"
						{ printf("ERROR SINTÁCTICO en la linea %d\n", yylineno); ++numErroresSintacticos;
						  $$ = creaLC(); guardaResLC($$, "");
						}
				;



%%

void inicializarRegistros(){
	for(int i=0; i<NUM_REGISTROS; ++i)
		registrosLibres[i] = 1;
}

char * getReg(){	
	for(int i=0; i<NUM_REGISTROS; ++i)
		if(registrosLibres[i]==1){
			registrosLibres[i] = 0;
			char aux[32];
			sprintf(aux, "$t%d", i);
			return strdup(aux);
		}
	printf("ERROR DE RECURSOS: no hay registros suficientes para realizar la operación\n");
	exit(1);
}

char * getEtiq(){
	char aux[32];
	sprintf(aux, "$l%d", contadorEtiquetas);
	++contadorEtiquetas;
	return strdup(aux);
}

char * concatDosPuntos(char * etiq){
	char aux[32];
	sprintf(aux, "%s:", etiq);
	return strdup(aux);
}

char * getStr(){
	char aux[32];
	sprintf(aux, "$str%d", contadorCadenas);
	return strdup(aux);
}

char * anteponBarraBaja(char * var){
	char aux[32];
	sprintf(aux, "_%s", var);
	return strdup(aux);
}

void yyerror(const char *msg){
	printf("ERROR SINTÁCTICO en la linea %d: %s \n", yylineno, msg);
}

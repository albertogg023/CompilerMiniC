%option noyywrap
%option yylineno

%{
#include "listaCodigo.h"
#include "analSintSemGenCodigo.tab.h"
#include <limits.h>
#include <string.h>
int numErroresLexicos = 0;
%}

%x COMMENT
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+
inicio_id           {letra}|\$|_

%%
[ \n\t\r]+                                  ;
"//".*[\n]                                  ;
"/*"                                        BEGIN(COMMENT);
<COMMENT>(.|\n)
<COMMENT><<EOF>>							printf("ERROR LÉXICO en la línea %d: comentario sin cerrar\n", yylineno); BEGIN 0;                           ;
<COMMENT>"*/"                               BEGIN 0;
\{                                          return BEGINN;
\}                                          return END;
main                                        return MAIN;
void                                        return VOID;
var                                         return VAR;
const                                       return CONST;
if                                          return IF;
else                                        return ELSE;
while                                       return WHILE;
do 											return DO;
read                                        return READ;
print                                       return PRINT;
{inicio_id}({letra}|{digito}|\$|_)*         { if(strlen(yytext) > 16) printf("ERROR LÉXICO en la línea %d: identificador demasiado largo\n", yylineno); yylval.lexema = strdup(yytext); return ID; }
{entero}                                    { if( atoll(yytext) > INT_MAX ) printf("ERROR LÉXICO en la línea %d: desbordamiento de tipo integer\n", yylineno); yylval.lexema = strdup(yytext); return INTLITERAL; }
\"([^"\n]|\\.)*\"                           { yylval.lexema = strdup(yytext); return STRING; }
\"([^"\n]|\\.)*                             { printf("ERROR LÉXICO en la línea %d: cadena sin comillas de cierre\n", yylineno); return STRING; }
"("                                         return LPAREN;		
")"                                         return RPAREN;
";"                                         return SEMICOLON;
","                                         return COMMA;
"="                                         return ASSIGNOP;
"+"                                         return PLUSOP;
"-"                                         return MINUSOP;
"*"                                         return MULLOP;
"/"                                         return DIVOP;
[^a-zA-Z$0-9();,=+\-*/{}"_ \n]+             { printf("ERROR LÉXICO en la línea %d: carácter no válido en la cadena %s\n", yylineno, yytext); ++numErroresLexicos; }
%%

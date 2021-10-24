#include "listaSimbolos.h"
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>

struct PosicionListaRep {
  Simbolo dato;
  struct PosicionListaRep *sig;
};

struct ListaRep {
  PosicionLista cabecera;
  PosicionLista ultimo;
  int n;
};

typedef struct PosicionListaRep *NodoPtr;

Lista creaLS() {
  Lista nueva = malloc(sizeof(struct ListaRep));
  nueva->cabecera = malloc(sizeof(struct PosicionListaRep));
  nueva->cabecera->sig = NULL;
  nueva->ultimo = nueva->cabecera;
  nueva->n = 0;
  return nueva;
}

void liberaLS(Lista lista) {
  while (lista->cabecera != NULL) {
    NodoPtr borrar = lista->cabecera;
    lista->cabecera = borrar->sig;
    free(borrar);
  }
  free(lista);
}

void insertaLS(Lista lista, PosicionLista p, Simbolo s) {
  NodoPtr nuevo = malloc(sizeof(struct PosicionListaRep));
  nuevo->dato = s;
  nuevo->sig = p->sig;
  p->sig = nuevo;
  if (lista->ultimo == p) {
    lista->ultimo = nuevo;
  }
  (lista->n)++;
}

void suprimeLS(Lista lista, PosicionLista p) {
  assert(p != lista->ultimo);
  NodoPtr borrar = p->sig;
  p->sig = borrar->sig;
  if (lista->ultimo == borrar) {
    lista->ultimo = p;
  }
  free(borrar);
  (lista->n)--;
}

Simbolo recuperaLS(Lista lista, PosicionLista p) {
  assert(p != lista->ultimo);
  return p->sig->dato;
}

PosicionLista buscaLS(Lista lista, char *nombre) {
  NodoPtr aux = lista->cabecera;
  while(aux->sig != NULL && strcmp(aux->sig->dato.nombre,nombre) != 0) {
    aux = aux->sig;
  }
  if(aux->sig == NULL)
        return NULL;  // si no hemos encontrado el elementos devolvemos null
  else
    return aux;
}

void asignaLS(Lista lista, PosicionLista p, Simbolo s) {
  assert(p != lista->ultimo);
  p->sig->dato = s;
}

int longitudLS(Lista lista) {
  return lista->n;
}

PosicionLista inicioLS(Lista lista) {
  return lista->cabecera;
}

PosicionLista finalLS(Lista lista) {
  return lista->ultimo;
}

PosicionLista siguienteLS(Lista lista, PosicionLista p) {
  assert(p != lista->ultimo);
  return p->sig;
}

void anadeEntradaLS(Lista lista, Simbolo s){
    insertaLS(lista, lista->ultimo, s);
}

int perteneceTablaLS(Lista lista, Simbolo s){ 
    NodoPtr nodoAnterior = buscaLS(lista, s.nombre);
    if(nodoAnterior == NULL)  // si no existe devolvemos -1
      return -1;
    else if(s.tipo != nodoAnterior->sig->dato.tipo) // si existe, pero no coinciden los tipos devolvemos 0
      return 0;
    else
      return 1; // si existe y coinciden los tipos
}

void imprimirTablaLS(Lista lista){
    printf("###################\n # Seccion de datos\n \t.data\n\n");
    PosicionLista aux  = inicioLS(lista);
    Simbolo elem;
    while (aux != finalLS(lista)){
        elem = recuperaLS(lista, aux);
        if(elem.tipo == 3)  // si es un string
          printf("$str%d:\n\t.asciiz %s \n", elem.valor, elem.nombre);
        else  // si es constante o variable
          printf("_%s:\n\t.word 0\n", elem.nombre);
        aux = siguienteLS(lista, aux);
    }
} 
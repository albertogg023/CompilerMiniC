#include "listaCodigo.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

struct PosicionListaCRep {
  Operacion dato;
  struct PosicionListaCRep *sig;
};

struct ListaCRep {
  PosicionListaC cabecera;
  PosicionListaC ultimo;
  int n;
  char *res;
};

typedef struct PosicionListaCRep *NodoPtr;

ListaC creaLC() {
  ListaC nueva = malloc(sizeof(struct ListaCRep));
  nueva->cabecera = malloc(sizeof(struct PosicionListaCRep));
  nueva->cabecera->sig = NULL;
  nueva->ultimo = nueva->cabecera;
  nueva->n = 0;
  nueva->res = NULL;
  return nueva;
}

void liberaLC(ListaC codigo) {
  while (codigo->cabecera != NULL) {
    NodoPtr borrar = codigo->cabecera;
    codigo->cabecera = borrar->sig;
    free(borrar);
  }
  free(codigo);
}

void insertaLC(ListaC codigo, PosicionListaC p, Operacion o) {
  NodoPtr nuevo = malloc(sizeof(struct PosicionListaCRep));
  nuevo->dato = o;
  nuevo->sig = p->sig;
  p->sig = nuevo;
  if (codigo->ultimo == p) {
    codigo->ultimo = nuevo;
  }
  (codigo->n)++;
}

Operacion recuperaLC(ListaC codigo, PosicionListaC p) {
  assert(p != codigo->ultimo);
  return p->sig->dato;
}

PosicionListaC buscaLC(ListaC codigo, PosicionListaC p, char *clave, Campo campo) {
  NodoPtr aux = p;
  char *info;
  while (aux->sig != NULL) {
    switch (campo) {
      case OPERACION: 
        info = aux->sig->dato.op;
        break;
      case ARGUMENTO1:
        info = aux->sig->dato.arg1;
        break;
      case ARGUMENTO2:
        info = aux->sig->dato.arg2;
        break;
      case RESULTADO:
        info = aux->sig->dato.res;
        break;
    }
    if (info != NULL && !strcmp(info,clave)) break;
	  aux = aux->sig;
  }
  return aux;
}

void asignaLC(ListaC codigo, PosicionListaC p, Operacion o) {
  assert(p != codigo->ultimo);
  p->sig->dato = o;
}

int longitudLC(ListaC codigo) {
  return codigo->n;
}

PosicionListaC inicioLC(ListaC codigo) {
  return codigo->cabecera;
}

PosicionListaC finalLC(ListaC codigo) {
  return codigo->ultimo;
}

void concatenaLC(ListaC codigo1, ListaC codigo2) {
  NodoPtr aux = codigo2->cabecera;
  while (aux->sig != NULL) {
    insertaLC(codigo1,finalLC(codigo1),aux->sig->dato);
    aux = aux->sig;
  }
}

PosicionListaC siguienteLC(ListaC codigo, PosicionListaC p) {
  assert(p != codigo->ultimo);
  return p->sig;
}

void guardaResLC(ListaC codigo, char *res) {
  codigo->res = res;
}

/* Recupera el registro resultado de una lista de codigo */
char * recuperaResLC(ListaC codigo) {
  return codigo->res;
}

void imprimeCodigo(ListaC listaC){
  printf("\n\n###################\n# Sección de codigo\n\t.text\n\t.globl main\nmain:\n");
  PosicionListaC pos = inicioLC(listaC);
  PosicionListaC posFin = finalLC(listaC);
  Operacion op;
  while(pos != posFin){
    op = recuperaLC(listaC, pos);
    if(op.res != NULL && op.arg1 != NULL && op.arg2 != NULL)
      printf("%s %s %s %s\n", op.op, op.res, op.arg1, op.arg2);
    else if(op.arg1 != NULL && op.arg2 == NULL)
      printf("%s %s %s\n", op.op, op.res, op.arg1);
    else if(op.res != NULL)
      printf("%s %s\n", op.op, op.res);
    else
       printf("%s\n", op.op);
    pos = siguienteLC(listaC, pos);
  }
  printf("\n\n#################\n# Fin\nli $v0, 10\nsyscall");
}
#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include "turing.tab.h"
#include "ST.h"

tree buildTree (int kind, tree one, tree two, tree three)
{
	tree p = (tree)malloc(sizeof (node));
	p->kind = kind;
	p->first = one;
	p->second = two;
	p->third = three;
	p->next = NULL;
	return p;
}

tree buildIntTree (int kind, int val)
{
	tree p = (tree)malloc(sizeof (node));
	p->kind = kind;
	p->value = val;
	p->first = p->second = p->third = NULL;
	p->next = NULL;
	return p;
}

char TokName[][12] = 
	{"<eof>", 
	"Ident", "IntConst", "SciNot", "RealConst",
	 "Var", "Integer", "Real", "Boolean", "",
	 "Record","End", "Bind", "To","",
	 "Assert", "Begin", "Loop", "Exit", "",
	 "When", "Elsif", "Else", "Put", "",
	 "Or", "And", "Not", "NotEqual", "Equals",
	 "Div", "Mod", "If", "Then", "",
	 "+", "-", "*", "/", ".", 
	 "(", ")", "<", ">", "",
	 ">=", "<=", ",", ";", ":",
	":=", "<eoln>", "Prog", "NoType"};
static int indent = 0;
void printTree (tree p)
{
	if (p == NULL) return;
	for (; p != NULL; p = p->next) {
		printf ("%*s%s", indent, "", TokName[p->kind]);
		switch (p->kind) {
			case Ident: 
				printf ("  %s (%d)\n", id_name (p->value), p->value);
				break;
			case IntConst:
				printf ("  %d\n", p->value);
				break;
			default:
				printf ("\n");
				indent += 2;
				printTree (p->first);
				printTree (p->second);
				printTree (p->third);
				indent -= 2;
			}
		}
}

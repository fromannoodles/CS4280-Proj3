#include <stdio.h>
#include "tree.h"
#include "turing.tab.h"
#include "ST.h"

extern int top;
STentry ST[100] = {0, NoType}; 

void prST (void)
{
	int i;
	printf ("\n");
	printf ("SYMBOL TABLE\n");
	for (i = 0; i <= top; i++) {
		int	t = ST[i].type;
		printf ("%3d %-10s\t%s\n", i, id_name (i), 
				t == Integer ? "Integer" : t == Boolean ? "Boolean" : t == Ident ? "Ident" : "<none>");
		}
}

static int check_expr (tree t)
{
	if (t == NULL) { 
		fprintf (stderr, "You shouldn't be here; missing expression\n"); 
		return NoType; 
		}
	switch (t->kind) {
		/*case Eq : case Ne :
		case Lt : case Le :
		case Gt : case Ge : {
			int t1 = check_expr (t->first), t2 = check_expr (t->second);
			if (t1 != t2) {
				fprintf (stderr, "Type mismatch in comparison\n");
				return (t->value = NoType);
				}
			else 
				return (t->value = Boolean);
			}
			break;
*/
		case Plus : case Minus :
		case Star : case Slash : 
		case Div : case Mod: {
			int t1 = check_expr (t->first), t2 = check_expr (t->second);
			if (t1 != Integer || t2 != Integer) {
				fprintf (stderr, "Type mismatch in binary arithmetic expression\n");
				return (t->value = NoType);
				}
			else 
				return (t->value = Integer);
			}
			break;

		case Ident : {
			int pos = t->value;
			if (ST[pos].index == 0) {
				ST[pos].index = pos;
				ST[pos].type = Integer;
				}
			return ST[pos].type;
			break;
			}
		case IntConst :
			return (t->value = IntConst);	/* t->value contains other info */
		case RealConst :
			return (t->value = RealConst);

		default:
			fprintf (stderr, "You shouldn't be here; invalid expression operator\n");
	}
}

static void handle_decls (tree t)
{
	for (t; t!= NULL; t = t->next) {
		int	type = t->kind;
		tree	p;
		if (type != Integer && type != Boolean) {
			fprintf (stderr, "Bad type in decl\n"); return;
			}
		for (p = t->first; p != NULL; p = p->next) {
			int	pos = p->value;
			ST[pos].index = pos;
			ST[pos].type = type;
			}
		}
}

void check (tree t)
{
	for (t; t != NULL; t = t->next) 
		switch (t->kind) {
			case Prog:
				handle_decls (t->first);
				check (t->first);
				printf ("\n");
				prST ();
				break;
			case SemiColon:
				check (t->first);
				check (t->second);
				//printf ("Leaving SemiColon");
			//	prST();
				break;
			case Var:
				check (t->first);
				check (t->second);
				if (t->third != NULL)
					check (t->third);
				//printf ("Leaving Var");
			//	prST();
				break;
			case Record:
				check (t->first);
				break;
/*
			case Integer:
				check_expr();
				break;
			case Real:
				check_expr(t->kind);
				break;
			case Boolean:
				check_expr(t->kind);
				break;	
*/
			case Ident:
				check_expr (t->first);
				if (t->next != NULL)
					check (t->next);
				//printf("Leaving Ident");
				break;
			case Assignment :{
				int pos = t->first->value;
				if (ST[pos].index == 0) {
					ST[pos].index = pos;
					ST[pos].type = Integer;
					}
				if (check_expr (t->second) != ST[pos].type) 
					fprintf (stderr, "Type error in assignment to identifier %s\n", 
								id_name(t->first->value));
				break;
				}
			case Colon:
				check (t->first);
				check (t->second);
				//printf("Leaving Colon");
			//	prST();
				break;
			case Bind:
				check (t->first);
				check (t->second);
				//printf ("Leaving Bind");
			//	prST();
				break;
			case Assert:
				check (t->first);
				//printf("Leaving Assert");
			//	prST();
				break;
			case Begin:
				check (t->first);
				//printf("Leaving Begin");
				//prST();
				break;
			case Exit:
				check (t->first);
				//printf("Leaving Exit");
				//prST();
				break;
			case Dot:
				check (t->first);
				//check_expr?
				break;
			case If :
				if (check_expr (t->first) != Boolean)
					fprintf (stderr, "Non-boolean in condition to IF\n");
				check (t->second);
				check (t->third);
				break;
			case Else:
				check (t->first);
				//printf("Leaving Else");
				break;
			case Loop :
				if (check_expr (t->first) != Boolean)
					fprintf (stderr, "Non-boolean in condition to WHILE\n");
				check (t->second);
				break;
			case Elsif:
				if (check_expr (t->first) != Boolean)
					fprintf(stderr, "Non-Boolean in condition to Elsif\n");
				check (t->first);
				check (t->second);
				//printf("Leaving Elsif");
				break;
			case Or:
				check (t->first);
				check (t->second);
				//printf("Leaving Or");
				break;
			case And:
				check (t->first);
				check (t->second);
				//printf("Leaving And");
				break;
			case Not:
				check (t->first);
				//printf("Leaving Not");
				break;
			case Equals: case NotEqual:
			case LessThan: case LessEqual:
			case GreaterThan: case GreaterEqual:{
				check (t->first);
				check (t->second);
				//printf ("Leaving Equals");
			}
				break;
			case Plus: case Minus:
			case Star: case Slash:
			case Div: case Mod:{
				check(t->first);
				if (t->second != NULL)
					check(t->second);	
			}
				break;
			case LParen:
				check (t->first);
				break;
			case IntConst:
				check_expr(t->first);
				break;
			case RealConst:
				check_expr(t->first);
				break;
			default :
				fprintf (stderr, "You shouldn't be here; invalid statement\n");
			}
}

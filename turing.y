%{
#include "tree.h"
#include <stdlib.h>

extern tree root;
%}

%token <i>	Ident 1 IntConst 2 SciNot 3 RealConst 4
%token Var 5 Integer 6 Real 7 Boolean 8
%token Record 10 End 11 Bind 12 To 13
%token Assert 15 Begin 16 Loop 17 Exit 18
%token When 20 Elsif 21 Else 22 Put 23
%token Or 25 And 26 Not 27 NotEqual 28 Equals 29
%token Div 30 Mod 31 If 32 Then 33
%token Plus 35 Minus 36 Star 37 Slash 38 Dot 39
%token LParen 40 RParen 41 LessThan 42 GreaterThan 43
%token GreaterEqual 45 LessEqual 46 Comma 47 SemiColon 48 Colon 49
%token Assignment 50 Eoln 51 Prog 52 NoType 53


%start program

%union { tree p; int i; }

%type <p>	pStateDeclSeq idlist type field_list state_decls statement declaration ref end_if expr and_expr not_expr rel_expr sum prod factor basic

%%
program
	: pStateDeclSeq
		{root = buildTree (Prog, $1, NULL, NULL); }
	;
pStateDeclSeq
	: /*empty*/
		{ $$ = NULL; }
	| statement SemiColon pStateDeclSeq
		{ $$ = buildTree (SemiColon, $1, $3, NULL); }
	| Var idlist Colon type SemiColon pStateDeclSeq
		{ $$ = buildTree (Var, $2, $4, $6); }
	;
idlist
	: Ident
		{ $$ = buildIntTree (Ident, $1); }
	| Ident Comma idlist
		{ $$ = buildIntTree (Ident,$1); $$->next = $3;}
	;
type
	: Integer
		{ $$ = buildTree (Integer, NULL, NULL, NULL); }
	| Real
		{ $$ =buildTree (Real, NULL, NULL, NULL); }
	| Boolean
		{ $$ = buildTree (Boolean, NULL, NULL, NULL); }
	| Record field_list End Record
		{ $$ = buildTree (Record, $2, NULL, NULL); }
	;
field_list
	: idlist Colon type
		{ $$ = buildTree (Colon, $1, $3, NULL); }
	| idlist Colon type SemiColon field_list
		{ $$ = buildTree (Colon, $1, $3, NULL); $$->next = $5; }
	;
state_decls
	: /*empty*/
		{ $$ = NULL; }	
	| statement SemiColon state_decls
		{ $$ = buildTree (SemiColon, $1, $3, NULL); }
	| declaration SemiColon state_decls 
		{ $$ = buildTree (SemiColon, $1, $3, NULL); }
	;
declaration
	: Var idlist Colon type
		{ $$ = buildTree (Var, $2, $4, NULL); }
	| Bind idlist To ref
		{ $$ = buildTree (Bind, $2, $4, NULL); }
	| Bind Var idlist To ref
		{ $$ = buildTree (Bind, $3, $5, NULL); }
	;
statement
	: ref Assignment expr
		{ $$ = buildTree (Assignment, $1, $3, NULL); }
	| Assert expr
		{ $$ = buildTree (Assert, $2, NULL, NULL); }
	| Begin state_decls End
		{ $$ = buildTree (Begin, $2, NULL, NULL); }
	| Loop state_decls End Loop
		{ $$ = buildTree (Loop, $2, NULL, NULL); }
	| Exit
		{ $$ = buildTree (Exit, NULL, NULL, NULL); }
	| Exit When expr
		{ $$ = buildTree (Exit, $3, NULL, NULL); }
	| If expr Then state_decls end_if
		{ $$ = buildTree (If, $2, $4, $5); }
	;
ref
	: Ident
		{ $$ = buildIntTree (Ident, $1); }
	| Ident Dot Ident
		{ $$ = buildTree (Dot, buildIntTree(Ident, $1), buildIntTree(Ident, $3), NULL); }
	;
end_if
	: End If
		{ $$ = NULL; }
	| Else state_decls End If
		{$$ = buildTree (Else, $2, NULL, NULL); }
	| Elsif expr Then state_decls end_if
		{ $$ = buildTree (Elsif, $2, $4, NULL); $$ -> next = $5; }
	;
expr
	: expr Or and_expr
		{ $$ = buildTree (Or, $1, $3, NULL); }
	| and_expr
		{ $$ = $1; }
	;
and_expr
	: and_expr And not_expr
		{ $$ = buildTree (And, $1, $3, NULL); }
	| not_expr
		{ $$ = $1; }
	;
not_expr
	: Not not_expr
		{ $$ = buildTree (Not, NULL, NULL, NULL); $$->next = $2; }
	| rel_expr
		{ $$ = $1; }
	;
rel_expr
	: sum
		{ $$ = $1; }
	| rel_expr Equals sum
		{ $$ = buildTree (Equals, $1, $3, NULL); }
	| rel_expr NotEqual sum
		{ $$ = buildTree (NotEqual, $1, $3, NULL); }
	| rel_expr LessThan sum
		{ $$ = buildTree (LessThan, $1, $3, NULL); }
	| rel_expr LessEqual sum
		{ $$ = buildTree (LessEqual, $1, $3, NULL); }
	| rel_expr GreaterThan sum
		{ $$ = buildTree (GreaterThan, $1, $3, NULL); }
	| rel_expr GreaterEqual sum
		{ $$ = buildTree (GreaterEqual, $1, $3, NULL); }
	;
sum
	: prod
		{ $$ = $1; }
	| sum Plus prod
		{ $$ = buildTree (Plus, $1, $3, NULL); }
	| sum Minus prod
		{ $$ = buildTree (Minus, $1, $3, NULL); }
	;
prod
	: factor
		{ $$ = $1; }
	| prod Star factor
		{ $$ = buildTree (Star, $1, $3, NULL); }
	| prod Slash factor
		{ $$ = buildTree (Slash, $1, $3, NULL); }
	| prod Div factor
		{ $$ = buildTree (Div, $1, $3, NULL); }
	| prod Mod factor
		{ $$ = buildTree (Mod, $1, $3, NULL); }
	;
factor
	: Plus basic
		{ $$ = buildTree (Plus, $2, NULL, NULL); }
	| Minus basic
		{ $$ = buildTree (Minus, $2, NULL, NULL); }
	| basic
		{ $$ = $1; }
	;
basic
	: ref
		{ $$ = $1; }
	| LParen expr RParen 
		{ $$ = buildTree (LParen, $2, NULL, NULL); }
	| IntConst
		{ $$ = buildIntTree (IntConst, $1); }
	| RealConst
		{ $$ = buildIntTree (RealConst, $1); }
	;
%%

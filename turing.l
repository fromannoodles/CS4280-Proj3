%{
#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include "turing.tab.h"
void yyerror (char * s);
int line=1;
%}
L	[A-Za-z]
D	[0-9]
%%
[ \t]+		;
[ \n]+		;
","		{return Comma;}
";"		{return SemiColon;}
":"		{return Colon;}
var		{return Var;}
"."		{return Dot;}
int		{return Integer;}
real		{return Real;}
boolean		{return Boolean;}
record		{return Record;}
end		{return End;}
bind		{return Bind;}
to		{return To;}
assert		{return Assert;}
begin		{return Begin;}
loop		{return Loop;}
exit		{return Exit;}
when		{return When;}
elsif		{return Elsif;}
else		{return Else;}
put		{return Put;}
or		{return Or;}
and		{return And;}
not		{return Not;}
not=		{return NotEqual;}
div		{return Div;}
mod		{return Mod;}
if		{return If;}
then		{return Then;}
{L}({L}|{D})*	{yylval.i = lookup (yytext); return Ident;}
{D}+		{yylval.i = atoi (yytext); return IntConst;}
"="		{return Equals;}
({D}+\.?{D}*|{D}*\.?{D}+)([eE][\-\+]?{D}+)? {return RealConst;}
{D}*\.?{D}+([eE][-+]?{D}+)?	{return SciNot;}
{D}*\.?{D}*([eE][-+]?{D}+)?	{return RealConst;}
"+"		{return Plus;}
"-"		{return Minus;}
"*"		{return Star;}
"/"		{return Slash;}
"("		{return LParen;}
")"		{return RParen;}
"<"		{return LessThan;}
">"		{return GreaterThan;}
">="		{return GreaterEqual;}
"<="		{return LessEqual;}
":="		{return Assignment;}
%%
int yywrap (void) { return 1; }

void yyerror (char s[])
{
	printf ("Error: %s at token %s in line %d\n", s, yytext, line);
}

typedef char name[15];
static char Names[200][15] = {"<no name>"};
int top = 0;

int lookup (char s[])
{
	int i;
	for (i=1; i<= top; i++)
		if (strcmp(s,Names[i]) == 0) return i;
	strcpy (Names[++top], s);
	return top;
}

char *id_name (int i)
{
	return Names[i];
}


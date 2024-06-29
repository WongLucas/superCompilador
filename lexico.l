%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{return TK_TIPO_INT;}
"float"		{return TK_TIPO_FLOAT;}
"char"		{return TK_TIPO_CHAR;}
"bool"		{return TK_TIPO_BOOL;}

"print"     {return TK_PRINT;}
"scan"      {return TK_SCAN;}

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
{REAL}		{ yylval.label = yytext; return TK_REAL; }
{CHAR}		{ yylval.label = yytext; return TK_CHAR; }
"true"|"false"  { yylval.label = yytext; return TK_BOOL; }


{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%

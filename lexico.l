%{
#include <string>

%}

ESPACO [ \t]
FIM_LINHA [\n]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*
COMENT ("//"(.*))|("/\*"(.|{FIM_LINHA})*"*/")

%%

{FIM_LINHA}	{num_linha = yylineno;}

{DELIM} 	{}

{COMENT}    {num_linha = yylineno;}

"main"		{return TK_MAIN;}

"int"		{return TK_TIPO_INT;}
"float"		{return TK_TIPO_FLOAT;}
"char"		{return TK_TIPO_CHAR;}
"bool"		{return TK_TIPO_BOOL;}

"print"     {return TK_PRINT;}
"scan"      {return TK_SCAN;}

"if"        {return TK_IF;}
"else"      {return TK_ELSE;}
"while"     {return TK_WHILE;}
"do"        {return TK_DO;}
"for"        {return TK_FOR;}
"break"     {return TK_BREAK;}
"continue"  {return TK_CONTINUE;}
[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

">"         { return MAIOR; }
">="        { return MAIOR_IGUAL; }
"<"         { return MENOR; }
"<="        { return MENOR_IGUAL; }
"=="        { return IGUAL; }
"!="        { return NAO_IGUAL; }

"!"        { return NAO; }
"&&"        { return AND; }
"||"        { return OR; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
{REAL}		{ yylval.label = yytext; return TK_REAL; }
{CHAR}		{ yylval.label = yytext; return TK_CHAR; }
"true"|"false"  { yylval.label = yytext; return TK_BOOL; }


{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%

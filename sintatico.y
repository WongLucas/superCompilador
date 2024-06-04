%{
#include <iostream>
#include <string>
#include <sstream>
#include <list>
#include <stack>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;

struct atributos
{
	string tipo;
	string label;
	string traducao;
};

struct simbolos
{
	string tipo;
	string endereco;
	string nome;
};

// Pilha de tabelas de símbolos
stack<list<simbolos>> pilhaDeTabelas;

// Funções de manipulação de pilha
void entrarBloco();
void sairBloco();
bool declararVariavel(string tipo, string endereco, string nome);
bool variavelDeclarada(string nome);
void inserirSimboloEscopo(string tipo, string endereco, string nome);
string buscarEndereco(string nome);
string listarSimbolosDoEscopoAtual();


int yylex(void);
void yyerror(string);
string gentempcode();
%}

%token TK_NUM TK_REAL TK_CHAR TK_BOOL
%token TK_MAIN TK_ID
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
%token TK_FIM TK_ERROR

%start S

%left '+'

%%

S : DECLARACOES_GLOBAIS TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				string codigo = "/*Compilador FOCA*/\n"
								"#include <iostream>\n"
								"#include<string.h>\n"
								"#include<stdio.h>\n";
								"#define true 1\n";								
								"#define false 0\n";
								
				codigo += $1.traducao;
				codigo += "int main(void) {\n";
				codigo += $6.traducao;
				codigo += "\treturn 0;\n"
						"}\n";

				cout << codigo << endl;
			}
			;

DECLARACOES_GLOBAIS : DECLARACOES_GLOBAIS DECLARACAO_GLOBAL
			{
				$$.traducao = listarSimbolosDoEscopoAtual();
			}
			| 
			{
				$$.traducao = "";
			}
			;

DECLARACAO_GLOBAL : TIPO TK_ID ';'
			{
				if (!declararVariavel($1.tipo, gentempcode(), $2.label)) {
					yyerror("Variável global já declarada");
				}
			}
			;
			
BLOCO		: IB COMANDOS '}'
			{
				$$.traducao = listarSimbolosDoEscopoAtual() + $2.traducao;
				sairBloco();
			}
			;

IB			: '{'
			{
				entrarBloco();
			}

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			| BLOCO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';'
			{
				$$ = $1;
			}
			| DECLARACAO
			{
				if(!declararVariavel($1.tipo, gentempcode(), $1.label)){
					yyerror("Variavel já declarada neste escopo");
				}
			}
			;

DECLARACAO	: TIPO TK_ID ';'
			{
				$$.tipo = $1.tipo;
				$$.label = $2.label;
			}
			;

TIPO 		: TK_TIPO_INT
			{
				$$.tipo = "int"; 
			}
			| TK_TIPO_FLOAT
			{
				$$.tipo = "float"; 				
			}
			| TK_TIPO_CHAR
			{
				$$.tipo = "char"; 				
			}
			| TK_TIPO_BOOL
			{
				$$.tipo = "bool"; 				
			}
			;

E 			: E '+' E
			{
				$$.label = gentempcode();
				inserirSimboloEscopo("int", $$.label, $1.label + " + " + $3.label);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			| TK_ID '=' E
			{
				if(variavelDeclarada($1.label)){
					$$.traducao = $1.traducao + $3.traducao + "\t" + buscarEndereco($1.label) + " = " + $3.label + ";\n";
				}else{
					yyerror("Variavel '" + $1.label + "' nao declarada");
				}

			}
			| TK_NUM
			{
				$$.label = gentempcode();
				inserirSimboloEscopo("int", $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_REAL
			{
				$$.label = gentempcode();
				inserirSimboloEscopo("float", $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_CHAR
			{
				$$.label = gentempcode();
				inserirSimboloEscopo("char", $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_BOOL
			{
				$$.label = gentempcode();
				inserirSimboloEscopo("bool", $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				if(variavelDeclarada($1.label)){
					$$.label = buscarEndereco($1.label);
				}else{
					yyerror("Variavel '" + $1.label + "' nao declarada");
				}
			}
			| '(' E ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;
	entrarBloco();

	yyparse();

	return 0;
}

void entrarBloco()
{
	pilhaDeTabelas.push(list<simbolos>());
}

void sairBloco()
{
	if (!pilhaDeTabelas.empty()) {
        pilhaDeTabelas.pop();
    } else {
        yyerror("Erro: Tentativa de sair de um bloco vazio");
    }
}

bool declararVariavel(string tipo, string endereco, string nome) {
    if (!pilhaDeTabelas.empty()) {
        list<simbolos>& topo = pilhaDeTabelas.top();
        for (const auto& simbolos : topo) {
            if (simbolos.nome == nome) {
                return false;
            }
        }
        topo.push_back({tipo, endereco, nome});
        return true;
    }
    return false;
}

bool variavelDeclarada(string nome) {
    stack<list<simbolos>> copiaPilha = pilhaDeTabelas;
    while (!copiaPilha.empty()) {
        const list<simbolos>& topo = copiaPilha.top();
        for (const auto& simbolo : topo) {
            if (simbolo.nome == nome) {
                return true;
            }
        }
        copiaPilha.pop();
    }
    return false;
}

void inserirSimboloEscopo(string tipo, string endereco, string nome) {
	if (!pilhaDeTabelas.empty()) {
        pilhaDeTabelas.top().push_back({tipo, endereco, nome});
    } else {
        yyerror("Erro: Tentativa de inserir símbolo em uma pilha de tabelas vazia");
    }
}

string buscarEndereco(string nome) {
    stack<list<simbolos>> copiaPilha = pilhaDeTabelas;
    while (!copiaPilha.empty()) {
        const list<simbolos>& topo = copiaPilha.top();
        for (const auto& simbolo : topo) {
            if (simbolo.nome == nome) {
                return simbolo.endereco;
            }
        }
        copiaPilha.pop();
    }
    return ""; // Retorna uma string vazia se a variável não for encontrada
}

string listarSimbolosDoEscopoAtual() {
    if (pilhaDeTabelas.empty()) {
        return "Nenhum símbolo no escopo atual.";
    }

    const list<simbolos>& topo = pilhaDeTabelas.top();
    string resultado;

    for (const auto& simbolo : topo) {
        resultado += "\t" + simbolo.tipo + " " + simbolo.endereco + "; //" + simbolo.nome + "\n";
    }

    return resultado;
}

void yyerror(string MSG)
{
	cout << MSG << endl;
	exit (0);
}				

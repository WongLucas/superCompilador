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
string buscarEndereco(string nome);
string listarSimbolosDoEscopoAtual();


int yylex(void);
void yyerror(string);
string gentempcode();
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR

%start S

%left '+'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				string codigo = "/*Compilador FOCA*/\n"
								"#include <iostream>\n"
								"#include<string.h>\n"
								"#include<stdio.h>\n"
								"int main(void) {\n";
								
				codigo += $5.traducao;
								
				codigo += 	"\treturn 0;"
							"\n}";

				cout << codigo << endl;
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
			| TIPO TK_ID ';'
			{
				if(!declararVariavel($1.tipo, gentempcode(), $2.label)){
					yyerror("Variavel já declarada neste escopo");
				}
			}
			;

TIPO 		: TK_TIPO_INT
			{
				$$.tipo = "int"; 
			}
			;

E 			: E '+' E
			{
				$$.label = gentempcode();
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
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
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

bool variavelDeclarada(const string& nome) {
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

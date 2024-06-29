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
void inserirSimboloEscopo(string tipo, string endereco, string nome);
string listarSimbolosDoEscopoAtual();

// Funções de manipulação de variáveis
bool declararVariavel(string tipo, string endereco, string nome);
bool variavelDeclarada(string nome);
struct simbolos variavelParaConversao(string tipo, string endereco, string nome);
string buscarEndereco(string nome);
string buscarTipo(string nome);

// Funções de manipulação de operações
void resultadoEntreOperacao(atributos& atributo1, string operador, atributos& atributo2, atributos& resultado);
string tipoResultante(string tipo1, string tipo2);

int yylex(void);
void yyerror(string);
string gentempcode();
%}

%token TK_NUM TK_REAL TK_CHAR TK_BOOL
%token TK_MAIN TK_ID
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
%token TK_FIM TK_ERROR

%start S

%left '+' '-'
%left '*' '/'

%%

S : DECLARACOES_GLOBAIS TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				string codigo = "/*Compilador FOCA*/\n"
								"#include <iostream>\n"
								"#include<string.h>\n"
								"#include<stdio.h>\n"
								"#define bool int\n"
								"#define true 1\n"							
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
				resultadoEntreOperacao($1,"+",$3,$$);
			}
			| E '-' E
			{
				resultadoEntreOperacao($1,"-",$3,$$);
			}
			| E '*' E
			{
				resultadoEntreOperacao($1,"*",$3,$$);
			}
			| E '/' E
			{
				resultadoEntreOperacao($1,"/",$3,$$);
			}
			| TK_ID '=' E
			{
				if(variavelDeclarada($1.label)){
					if(buscarTipo($1.label) == $3.tipo){
						$$.traducao = $1.traducao + $3.traducao + "\t" + buscarEndereco($1.label) + " = " + $3.label + ";\n";
					}else{
						$$.traducao = $1.traducao + $3.traducao;
						$$.traducao += "\t" + buscarEndereco($1.label) + " = ";
						$$.traducao += "(" + buscarTipo($1.label) + ")" + $3.label + ";\n";
					}
				}else{
					yyerror("Variavel '" + $1.label + "' nao declarada");
				}

			}
			| TK_NUM
			{
				$$.label = gentempcode();
				$$.tipo = "int";
				inserirSimboloEscopo($$.tipo, $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_REAL
			{
				$$.label = gentempcode();
				$$.tipo = "float";
				inserirSimboloEscopo($$.tipo, $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_CHAR
			{
				$$.label = gentempcode();
				$$.tipo = "char";
				inserirSimboloEscopo($$.tipo, $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_BOOL
			{
				$$.label = gentempcode();
				$$.tipo = "bool";
				inserirSimboloEscopo($$.tipo, $$.label, $1.label);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID	//IMPLEMENTAR QUAL O TIPO AQUI!!!
			{
				if(variavelDeclarada($1.label)){
					$$.label = buscarEndereco($1.label);
					$$.tipo = buscarTipo($1.label);
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

struct simbolos variavelParaConversao(string tipo, string endereco, string nome){
	struct simbolos variavel = {tipo, endereco, nome};
	
	if (!pilhaDeTabelas.empty()) {
        pilhaDeTabelas.top().push_back({tipo, endereco, nome});
    } else {
        yyerror("Erro: Tentativa de inserir símbolo em uma pilha de tabelas vazia");
    }

	return variavel;
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

string buscarTipo(string nome) {
    stack<list<simbolos>> copiaPilha = pilhaDeTabelas;
    while (!copiaPilha.empty()) {
        const list<simbolos>& topo = copiaPilha.top();
        for (const auto& simbolo : topo) {
            if (simbolo.nome == nome) {
                return simbolo.tipo;
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

void resultadoEntreOperacao(atributos& atributo1, string operador, atributos& atributo2, atributos& resultado){
	string tipo_resultante = tipoResultante(atributo1.tipo, atributo2.tipo);

	if(atributo1.tipo == atributo2.tipo){ //OPERANDOS DE MESMO TIPO

		resultado.tipo = tipo_resultante;
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo2.label);

		resultado.traducao = atributo1.traducao + atributo2.traducao + "\t" + resultado.label + " = " +
		atributo1.label + operador + atributo2.label + ";\n";

	}else if(atributo1.tipo == "float" && atributo2.tipo == "int"){ //FLOAT E INT
		
		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "float " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";

	}else if(atributo1.tipo == "float" && atributo2.tipo == "char"){ //FLOAT E CHAR
		
		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "float " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "float" && atributo2.tipo == "bool"){ //FLOAT E BOOL
		
		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "float " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "int" && atributo2.tipo == "float"){

		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "float " + atributo1.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo2.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo1.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo2.label + operador + atributo3.endereco + ";\n";

}else if(atributo1.tipo == "int" && atributo2.tipo == "char"){		

		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "int " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "int" && atributo2.tipo == "bool"){		

		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "int " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "char" && atributo2.tipo == "float"){

		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "float " + atributo1.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo2.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo1.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo2.label + operador + atributo3.endereco + ";\n";

	}else if(atributo1.tipo == "char" && atributo2.tipo == "int"){

		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "int " + atributo1.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo2.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo1.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo2.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "char" && atributo2.tipo == "bool"){
		
		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "char " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "bool" && atributo2.tipo == "float"){
		
		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "float " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "bool" && atributo2.tipo == "int"){
		
		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "int " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}else if(atributo1.tipo == "bool" && atributo2.tipo == "char"){
		
		resultado.tipo = tipo_resultante;
		struct simbolos atributo3 = variavelParaConversao(resultado.tipo, gentempcode(), "char " + atributo2.label);
		resultado.label = gentempcode();

		inserirSimboloEscopo(resultado.tipo, resultado.label, atributo1.label + operador + atributo3.endereco);

		resultado.traducao = atributo1.traducao + atributo2.traducao;
		resultado.traducao += "\t" + atributo3.endereco + " = " + "(" + tipo_resultante + ")" + atributo2.label + ";\n";
		resultado.traducao += "\t" + resultado.label + " = " + atributo1.label + operador + atributo3.endereco + ";\n";
		
	}
}

string tipoResultante(string tipo1, string tipo2) {
	if (tipo1 == tipo2) {
		return tipo1;
	} else if (tipo1 == "float" && tipo2 == "int"){
		return "float";
	} else if (tipo1 == "float" && tipo2 == "char") {
		return "float";
	} else if (tipo1 == "float" && tipo2 == "bool") {
		return "float";
	} else if (tipo1 == "int" && tipo2 == "float") {
		return "float";
	} else if (tipo1 == "int" && tipo2 == "char") {
		return "int";
	} else if (tipo1 == "int" && tipo2 == "bool") {
		return "int";
	} else if (tipo1 == "char" && tipo2 == "float") {
		return "float";
	} else if (tipo1 == "char" && tipo2 == "int") {
		return "int";
	} else if (tipo1 == "char" && tipo2 == "bool") {
		return "char";
	} else if (tipo1 == "bool" && tipo2 == "float") {
		return "float";
	} else if (tipo1 == "bool" && tipo2 == "int") {
		return "int";
	} else if (tipo1 == "bool" && tipo2 == "char") {
		return "char";
	}
	return "";
}

void yyerror(string MSG)
{
	cout << MSG << endl;
	exit (0);
}				

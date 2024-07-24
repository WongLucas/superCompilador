SCANNER := lex
SCANNER_PARAMS := lexico.l
PARSER := yacc
PARSER_PARAMS := -d sintatico.y

all: compile translate test

test:
		g++ -o teste-compilador teste-compilador.cpp
		./teste-compilador

compile:
		$(SCANNER) $(SCANNER_PARAMS)
		$(PARSER) $(PARSER_PARAMS)
		g++ -o glf y.tab.c -ll

run: 	glf
		clear
		compile
		translate
		test
		

debug:	PARSER_PARAMS += -Wcounterexamples
debug: 	all

translate: glf
		#./glf < t1.foca				#declaracao_explicita
		#./glf < t2.foca				#escopo_estatico
		#./glf < t3.foca				#blocos
		#./glf < t4.foca				#escopo_global
		#./glf < t5.foca				#tipo_primitivos
		#./glf < t6.foca				#inicializacao_de_variavel
		#./glf < t7.foca				#expressoes
		#./glf < t8.foca				#expressoes_condicionais
		#./glf < t9.foca				#comando_entrada_saida
		#./glf < t10.foca				#comandos_laco
		#./glf < t11.foca				#comandos_decisao
		#./glf < t12.foca				#operadores
		#./glf < t13.foca				#conversoes
		./glf < t14.foca				#controles_de_laco

clean:
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c
	rm glf
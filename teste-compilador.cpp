/*Compilador FOCA*/
#include <iostream>
#include<string.h>
#include<stdio.h>
#define bool int
#define true 1
#define false 0
using namespace std;
int main(void) {
	int t1; //i
	int t2; //j
	int t3; //a
	int t4; //0
	int t5; //0
	int t6; //10
	int t7; //t1<t6
	int t8; //1
	int t9; //t1+t8
	t4 = 0;
	t3 = t4;
	t5 = 0;
	t1 = t5;
	WHILE_1:
	t6 = 10;
	t7 = t1<t6;
	if(!t7) goto FIM_1;
	int t10; //t1==t1
	int t11; //0
	int t12; //10
	int t13; //t2<t12
	int t14; //1
	int t15; //t2+t14
	t10 = t1==t1;
	cout << t10 << endl;
	t11 = 0;
	t2 = t11;
	WHILE_0:
	t12 = 10;
	t13 = t2<t12;
	if(!t13) goto FIM_0;
	int t16; //t2==t2
	t16 = t2==t2;
	cout << t16 << endl;
	goto FIM_0; 
	t14 = 1;
	t15 = t2+t14;
	t2 = t15;
	goto WHILE_0;
	FIM_0:
	t8 = 1;
	t9 = t1+t8;
	t1 = t9;
	goto WHILE_1;
	FIM_1:
	return 0;
}

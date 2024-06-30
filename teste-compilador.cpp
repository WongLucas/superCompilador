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
	int t2; //0
	int t3; //5
	int t4; //t1<t3
	t2 = 0;
	t1 = t2;
	WHILE_1:
	t3 = 5;
	t4 = t1<t3;
	if(!t4) goto FIM_2;
	int t5; //1
	int t6; //t1+t5
	int t7; //3
	int t8; //t1==t7
	cout << t1 << endl;
	t5 = 1;
	t6 = t1+t5;
	t1 = t6;
	t7 = 3;
	t8 = t1==t7;
	if(!t8) goto FIM_1;
	int t9; //100
	t9 = 100;
	cout << t9 << endl;
	FIM_1:
	goto WHILE_1;
	FIM_2:
	return 0;
}

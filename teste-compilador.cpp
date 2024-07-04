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
	int t3; //10
	int t4; //t1<t3
	int t5; //1
	int t6; //t1+t5
	t2 = 0;
	t1 = t2;
	WHILE_0:
	t3 = 10;
	t4 = t1<t3;
	if(!t4) goto FIM_1;
	int t7; //4
	int t8; //t1==t7
	int t9; //t1==t1
	t7 = 4;
	t8 = t1==t7;
	if(!t8) goto FIM_0;
	goto FIM_0; 
	FIM_0:
	t9 = t1==t1;
	cout << t9 << endl;
	t5 = 1;
	t6 = t1+t5;
	t1 = t6;
	goto WHILE_0;
	FIM_1:
	return 0;
}

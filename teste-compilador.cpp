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
	bool t3; //true
	int t4; //1
	int t5; //t1+t4
	t2 = 0;
	t1 = t2;
	WHILE_1:
	t3 = true;
	if(!t3) goto FIM_1;
	int t6; //t1==t1
	t6 = t1==t1;
	cout << t6 << endl;
	t4 = 1;
	t5 = t1+t4;
	t1 = t5;
	goto WHILE_1;
	FIM_1:
	return 0;
}

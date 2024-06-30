/*Compilador FOCA*/
#include <iostream>
#include<string.h>
#include<stdio.h>
#define bool int
#define true 1
#define false 0
using namespace std;
int main(void) {
	int t1; //a
	float t2; //b
	float t3; //10.1
	float t4; //float t1
	float t5; //t2+t4
	cin >> t1;
	t3 = 10.1;
	t2 = t3;
	t4 = (float)t1;
	t5 = t2+t4;
	cout << t5 << endl;
	return 0;
}

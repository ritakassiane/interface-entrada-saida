
#include <stdio.h>

extern void uartConfig(int, int, int);

int config;

void uartConfigC(int dataLeng,int stopBit, int typeParit, int enabelParity, int integerBRD, int fractionalBRD) {
	config = dataLeng;
	config = config * 4;
	config = (config + stopBit) * 2;
	config = config + typeParit;
	config = config * 2;
	config = config + enabelParity;
	config = config * 2;
	uartConfig(config, integerBRD, fractionalBRD);
	return;
}

#define BITS_5 		0
#define BITS_6 		1
#define BITS_7 		2
#define BITS_8 		3

#define STOPBIT_2 	1
#define STOPBIT_1 	0

#define PARI_PAR 	0
#define PARI_IMP 	1

#define ABILITADO 	1
#define DESABILI 	0

#define IBRD		212		
#define FBRD		63

int main()
{
	config = BITS_8;
	config = config * 4;
	config = (config + STOPBIT_2) * 2;
	config = config + PARI_IMP;
	config = config * 2;
	config = config + ABILITADO;
	config = config * 2;
	uartConfig(config, IBRD, FBRD);
	return 0;
}



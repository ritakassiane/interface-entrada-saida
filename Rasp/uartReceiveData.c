
#include <stdio.h>
#include <stdbool.h>

extern int uartReceiveData();
int receiveData;

int main(){
	receiveData = uartReceiveData();
	printf("Dado recebido: %d\n", receiveData);
	return 0;
}

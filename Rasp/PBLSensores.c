#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define UART_LCRH	112	//1110000
#define UART_IBRD	212
#define UART_FBRD	63


extern void uartConfig(int, int, int);
extern void uartSendData(int);
extern int uartReceiveData();

char answer;
char solicitationStr[30];
char unit[5];
int solicitation;
int sensorOffset;
int responseFPGA[2];
bool final;


void main(){
	uartConfig(UART_LCRH, UART_IBRD, UART_FBRD);
	system("clear");
	final = true;
	do{
		printf("Comunicação Com Sensores:\n");
		printf("\n1 - Solicitar a situação atual do sensor\n2 - Solicitar a medida de temperatura\n3 - Solicitar a medida de umidade\n0 - Sair\n\nR - ");
		scanf("%s", &answer);
		switch (answer){
			case '1':
				strcpy(solicitationStr, "Situação Atual");
				strcpy(unit, "");
				solicitation = 1; 
				break;
			case '2':
				strcpy(solicitationStr, "Medida de Temperatura");
				strcpy(unit, "°C");
				solicitation = 2;
				break;
			case '3':
				strcpy(solicitationStr, "Medida de Umiade");
				strcpy(unit, "%");
				solicitation = 3;
				break;
			case '0':
				strcpy(solicitationStr, "null");
				strcpy(unit, "");
				final = false;
				break;
			default:
				strcpy(solicitationStr, "null");
				strcpy(unit, "");
				solicitation = 0;
				printf("Opção invalida\n\n");
		}

		system("clear");
		if (solicitation != 0 && final){
			do{
				printf("Sensor a ser acessado: ");
				scanf("%d", &sensorOffset);
				system("clear");
				if (sensorOffset < 0 || sensorOffset > 31)
					printf("O valor informado não representa nenhum dos 32 sensores\n\n");
			}while(sensorOffset < 0 || sensorOffset > 31);
			
			printf("Enviando solicitação\n");
			uartSendData(sensorOffset);
			uartSendData(solicitation);
			system("clear");
			
			printf("Aguardando Retorno\n");
			responseFPGA[0] = uartReceiveData();	//bit erro mais parte inteira
			responseFPGA[1] = uartReceiveData(); 	//Parte fracionada
			system("clear");

			if (responseFPGA[0] < 256 && responseFPGA[1] < 256){
				if (responseFPGA[0] < 128){
					printf("%s sensor %d: ", solicitationStr, sensorOffset);
					if (solicitation == 1){ //analisar 
						if (responseFPGA[0] == 0) printf("Sensor Funcionando\n");
						else printf("Sensor Com Problema\n");
					}else{
						printf("%d,%d%s", responseFPGA[0], responseFPGA[1], unit);
					}
				} else {
					printf("Sensor %d com problema\n\nTente executar novamente a solicitação, caso o erro persista:\n- Verifique se o sensor esta conectado corretamente\n- Verifique se o sensor esta funcionando\n", sensorOffset); 
				}
			} else {
				printf("Erro na recepção do dado\n\n");
				if (responseFPGA[0] >= 256) printf("primeiro : %x\n", responseFPGA[0]);
				if (responseFPGA[1] >= 256) printf("segundo  : %x\n", responseFPGA[1]);
			}
			
			printf("\n\nContinuar [s/n]: ");
			scanf("%s", &answer);
			
			if (answer != 's') final = false;
		}
		
		system("clear");		
	}while (final);
}

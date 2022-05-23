#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define UART_LCRH	112	//0b1110000 Representa a configuração de 8-bits | Sem paridade | Um unico stop bit

#define UART_IBRD	212	// Valores para Boudrate 
#define UART_FBRD	63	// de 14400


extern void uartConfig(int, int, int);	// Configura a UART da Raspberry
extern void uartSendData(int);		// Solicita à UART o envio de um numero, limitado ao range de dado configurado
extern int uartReceiveData();			// Solicita à UART o valor no topo de sua FIFO de recepção

char answer;					// Resposta do usuario
char solicitationStr[30];			// String da Solicitação que o usuario pedio
char unit[5];					// Unidade de medida do dado solicitado
int solicitation;			 	// Valor da Solicitação para ser enviada para FPGA
int sensorOffset;				// Endereço do sensor a ser acessado
int responseFPGA;				// Retorno da FPGA
bool final;					// Controlador do termino do programa


void main(){
	// Inicialização
	uartConfig(UART_LCRH, UART_IBRD, UART_FBRD);		
	system("clear");
	final = true;
	
	// Inicio do loop
	do{
		// Pedido ao usuario qual informação deseja dos sensores
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
				printf("Opção invalida\n\nContinuar [s/n]: ");
				scanf("%s", &answer);
		}

		system("clear");
		
		// Solicita qual sensor sera acessado
		if (answer == '1'  || answer == '2' || answer == '3'){
			do{
				printf("Sensor a ser acessado: ");
				scanf("%d", &sensorOffset);
				system("clear");
				if (sensorOffset < 0 || sensorOffset > 31)	// Evita o usuario informar endereçoes maiores que o limite de 31
					printf("O valor informado não representa nenhum dos 32 sensores\n\n");
			} while(sensorOffset < 0 || sensorOffset > 31);
			
		// Enviando a solicitação para a FPGA atraves da UART da Raspberry
			printf("Enviando solicitação\n");
			uartSendData(sensorOffset);
			uartSendData(solicitation);
			system("clear");
			
		// Aguarda e lê o dado Recebido pela UART da Raspberry
			printf("Aguardando Retorno\n");
			responseFPGA = 25;//uartReceiveData();	//bit erro mais parte inteira
			system("clear");

		// Verifica o dado recebido e informa ao usuario
			if (responseFPGA < 256){			// Verifica se a comunicação teve problemas de sincronização ou configuração
				if (responseFPGA < 128){		// Verifica se o dado recebido tem o bit de erro 
					printf("%s sensor %d: ", solicitationStr, sensorOffset);
					// Mostra para o usuario o dado baseado no que foi pedido
					if (solicitation == 1){
						if (responseFPGA == 0) printf("Sensor Funcionando\n");
						else printf("Sensor Com Problema\n");
					}else{
						printf("%d%s", responseFPGA, unit);
					}
				} else {
					printf("Sensor %d com problema\n\nTente executar novamente a solicitação, caso o erro persista:\n- Verifique se o sensor esta conectado corretamente\n- Verifique se o sensor esta funcionando\n", sensorOffset); 
				}
			} else {
				printf("Erro na recepção do dado\n\n");
				printf("Dado recebido : 0x%x\n", responseFPGA);
			}
			
			printf("\n\nContinuar [s/n]: ");
			scanf("%s", &answer);
		}
		
		// Finaliza a requesição e termina o programa ou retoma ao inicio dependendo do que o usuario informar
		if (answer != 's') final = false;
		system("clear");		
	}while (final);
}

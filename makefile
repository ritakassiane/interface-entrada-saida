all: PBLSensores
	gcc -o PBLSensores PBLSensores.c libUART.a   

PBLSensores: pbl02
	ar -cvq libUART.a uartSendData.o uartReceiveData.o uartConfig.o 

pbl02: uartConfig.s uartReceiveData.s uartSendData.s
	as -o uartConfig.o uartConfig.s 
	as -o uartReceiveData.o uartReceiveData.s  
	as -o uartSendData.o uartSendData.s

clean:
	rm -rf *.o *~ uartConfig

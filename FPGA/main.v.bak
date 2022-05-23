/*
------------------------------------------------------------------------------------------------
Authors: Paulo Queiroz de Carvalho, Rita Kassiane Santos dos Santos e Rodrigo Damasceno Sampaio
Curricular component: MI-Sistemas Digitais (TEC499) 
Concluded in: 21/05/2022
We declare that this code has been prepared by us individually and does not contain any
Code snippet from another colleague or author, such as from books and
Handouts, and electronic pages or documents from the Internet. Any code snippet
By someone other than ours is highlighted with a citation to the author and source
Of the code, and I am aware that these snippets will not be considered for evaluation purposes.
------------------------------------------------------------------------------------------------
MOdulo principal que contém as principais entradas e saídas do sistema,
além de instanciar os outros modulos que serão necessários.
*/


module main(
   input        i_Clock,  // Entrada de clock (Interno da FPGA 50Mhz)
   input        i_Rx_Serial,  // Entrada do RX
	inout			 dht_data_int,// Pino de entrada e saída do sensor DHT11 
   output 	    o_Tx_Active, // Pino para informar se a transmissão está acorrendo
   output    	 o_Tx_Serial, // Saída do pino de transmissão
   output       o_Tx_Done,// Saída para indicar que a trasnmissão foi completa
	output [4:0] coluna,
	output [7:0] linhas	
);
	wire 			 o_Rx_DV;
   wire [7:0]   o_Rx_Byte;
	wire [7:0]   o_request;
	wire [31:0]  o_interface;
	wire [7:0]   o_data_int;
	wire [7:0] 	 o_data_float;
	wire  		 o_done_i1;
	reg [4:0]    r_coluna = 5'b00000;
	
	
	
uart_rx instrx(
	.i_Clock(i_Clock),
   .i_Rx_Serial(i_Rx_Serial),
   .o_Rx_DV(o_Rx_DV),
   .o_Rx_Byte(o_Rx_Byte)

);

selector inst_selec(
	.i_Clock(i_Clock),
	.i_Data(o_Rx_Byte),
	.i_Data_Done(o_Rx_DV),
	.o_request(o_request),
	.o_interface(o_interface)

);

interface2 i_dht11(
	.i_Clock(i_Clock),
	.i_En(o_interface[0]),
	.i_request(o_request),
	.dht_data_int(dht_data_int),
	.o_data_int(o_data_int),
	.o_data_float(o_data_float),
	.o_done_i1(o_done_i1),
	//.blue(blue),
	.inteiro(linhas)
);

uart_tx insttx(
	.i_Clock(i_Clock),
	.i_Tx_DV(o_done_i1),
	.i_Tx_Byte (o_data_int), 
   .o_Tx_Active(o_Tx_Active),
   .o_Tx_Serial(o_Tx_Serial),
   .o_Tx_Done(o_Tx_Done)
	
);

endmodule 
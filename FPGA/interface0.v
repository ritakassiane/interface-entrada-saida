/*
Modulo da interface do DHT11 e apenas desse sensor, caso seja inserido outros sensores seria necessário
implementar sua interface nos padrões do sistema para seu funcionamento, o sistema já está desenvolvido
para receber outras interfaces.
Esta interface instância o modulo do seu sensor (DHT11), pega suas saídas e a depender da requisição ou caso houver
algum erro ele retorna uma resposta equivalente (Um byte)

*/

module interface0(
	input i_Clock,
	input i_En,
	input [7:0] i_request, // Byte de requisição do dado
	inout	dht_data_int, // Entrada e saída do sensor DHT11
	output [7:0] o_data_int, // Saida do dado da interface
	output o_done_i1 // Bit para informar se o processo foi terminado
	//output [7:0]inteiro
	
);

	wire [7:0] 	w_Hum_Int, 
					w_Hum_Float, 
					w_Temp_Int, 
					w_Temp_Float,
					w_Crc;
	wire        w_done11;
					
	reg [7:0] 		r_data_int = 8'd0;
	reg 				r_done = 1'b0;
	reg 				r_Rst = 1'b0;
	reg [1:0] 		state = 2'b00;
	reg 				en_dht11;
	
	wire         wait_int;
	wire         error_int;
	wire			 debug_int;
	
	//assign inteiro = r_data_int;
	assign o_data_int = r_data_int;
	assign o_done_i1 = r_done;
	
//Definindo casos da máquina de estados
localparam idle =  2'b00, 
			  read  =  2'b01, 
			  send  =  2'b10,
			  finish  =  2'b11;
			  

DHT11 ints_dht11 (
	 .CLK(i_Clock),  //50 MHz CLOCK
    .EN(en_dht11),
    .RST(r_Rst),	 // RESET
    .DHT_DATA(dht_data_int),// DADOS DO SENSOR
	 .HUM_INT(w_Hum_Int), // PARTE INTEIRA DOS DADOS DE UMIDADE
	 .HUM_FLOAT(w_Hum_Float), // PARTE FRACIONADA DOS DADOS UMIDADE
    .TEMP_INT(w_Temp_Int), // PARTE INTEIRA DOS DADOS DE TEMPERATURA
	 .TEMP_FLOAT(w_Temp_Float), // PARTE FRACIONADA DOS DADOS DE TEMPERATURA
	 .CRC(w_Crc), // CheckSum
	 .WAIT(wait_int),
	 .DEBUG(debug_int),
	 .error(error_int),
	 .done(w_done11)
);


always @(posedge i_Clock) begin
			case(state)
			idle:  
				begin
					if (i_En == 1'b1) begin // Se o enable estiver ativado
						en_dht11 <= 1'b1; // Ativa o sensor
						r_Rst <= 1'b1; // Dar-se um sinal de rst para iniciar a obtenção de dados
						state <= read; // Muda-se de estado
					end
				end
			read:
				begin
					r_Rst <= 1'b0; // O resete deve ficar somente uma subida de clock para que não fique sempre no IDLE do DHT11
					if(w_done11 == 1'b1) begin	 // Se o DHT11 estiver terminado o processo, leremos os dados
						if(i_request == 8'b00000010)begin // Se for pedido temperatura
							r_data_int <= w_Temp_Int; 
						end
						else if (i_request == 8'b00000011)begin // Se for pedido Humidade
							r_data_int <= w_Hum_Int;
						end
						else if (i_request == 8'b00000001) begin// Se for estado do sensor
							if(error_int == 1'b0) begin
								r_data_int <= 8'b00000000;
							end
						end
						state <= send;
					end
					if(error_int == 1'b1) begin // Se houver error
						r_data_int <= 8'b10000000;
					end
				end
			send:
				begin
					r_done <= 1'b1; // Informa que o processo foi finalizado
					state <= finish;
				end
			finish:
				begin	
					r_done <= 1'b0; // Reseta os operadores
					en_dht11 <= 1'b0;
					state <= idle; // Retorna pro estado idle
				end
			endcase
end
	


endmodule
	
`timescale 1ns / 1ps

// Modulo do sensor DHT11

module DHT11(
	 input CLK,  //50 MHz CLOCK
    input EN,
    input RST,	 // RESET
    inout DHT_DATA,// DADOS DO SENSOR
	 output [7:0] HUM_INT, // PARTE INTEIRA DOS DADOS DE UMIDADE
	 output [7:0] HUM_FLOAT, // PARTE FRACIONADA DOS DADOS UMIDADE
    output [7:0] TEMP_INT, // PARTE INTEIRA DOS DADOS DE TEMPERATURA
	 output [7:0] TEMP_FLOAT, // PARTE FRACIONADA DOS DADOS DE TEMPERATURA
	 output [7:0] CRC,
	 output WAIT,
	 output DEBUG,
	 output error,
	 output done
    );


	reg DHT_OUT, DIR, WAIT_REG, DEBUG_REG;  //Registrador de saida	
	reg [25:0] COUNTER; //Contador de ciclos para gerar delays
	reg [5:0] index;
	reg [39:0] INTDATA; //Registrador de dados interno
	reg error_REG;
	wire [39:0] DHT_IN;
	reg  r_done = 1'b0;

	
	assign WAIT = WAIT_REG;
	assign DEBUG = DEBUG_REG;
	assign error = error_REG;
	assign done = r_done;
	
	//assign DHT_DATA = DIR ? DHT_OUT : 1'bZ; // Se DIR 1 -- copia DHT_OUT para saida, caso nao, deixa o pino indefinido para atuar como entrada
	//assign DHT_IN = DHT_DATA;


TRIS TRIS_DATA(
    .PORT(DHT_DATA),
    .DIR(DIR),
    .SEND(DHT_OUT),
    .READ(DHT_IN)
    );

	// SALVANDO TODOS OS DADOS DE ENTRADA NO REGISTRADOR DE DADOS DE 40 BITS
	assign HUM_INT[7] = INTDATA[0];
	assign HUM_INT[6] = INTDATA[1];
	assign HUM_INT[5] = INTDATA[2];
	assign HUM_INT[4] = INTDATA[3];
	assign HUM_INT[3] = INTDATA[4];
	assign HUM_INT[2] = INTDATA[5];
	assign HUM_INT[1] = INTDATA[6];
	assign HUM_INT[0] = INTDATA[7];
	
	assign HUM_FLOAT[7] = INTDATA[8];
	assign HUM_FLOAT[6] = INTDATA[9];
	assign HUM_FLOAT[5] = INTDATA[10];
	assign HUM_FLOAT[4] = INTDATA[11];
	assign HUM_FLOAT[3] = INTDATA[12];
	assign HUM_FLOAT[2] = INTDATA[13];
	assign HUM_FLOAT[1] = INTDATA[14];
	assign HUM_FLOAT[0] = INTDATA[15];
	
	assign TEMP_INT[7] = INTDATA[16];  
	assign TEMP_INT[6] = INTDATA[17];
	assign TEMP_INT[5] = INTDATA[18];
	assign TEMP_INT[4] = INTDATA[19];
	assign TEMP_INT[3] = INTDATA[20];
	assign TEMP_INT[2] = INTDATA[21];
	assign TEMP_INT[1] = INTDATA[22];
	assign TEMP_INT[0] = INTDATA[23]; 
	
	assign TEMP_FLOAT[7] = INTDATA[24];
	assign TEMP_FLOAT[6] = INTDATA[25];
	assign TEMP_FLOAT[5] = INTDATA[26];
	assign TEMP_FLOAT[4] = INTDATA[27];
	assign TEMP_FLOAT[3] = INTDATA[28];
	assign TEMP_FLOAT[2] = INTDATA[29];
	assign TEMP_FLOAT[1] = INTDATA[30];
	assign TEMP_FLOAT[0] = INTDATA[31];	
	
	assign CRC[7] =  INTDATA[32];
	assign CRC[6] =  INTDATA[33];
	assign CRC[5] =  INTDATA[34];
	assign CRC[4] =  INTDATA[35];
	assign CRC[3] =  INTDATA[36];
	assign CRC[2] =  INTDATA[37];
	assign CRC[1] =  INTDATA[38];
	assign CRC[0] =  INTDATA[39];

	 reg [3:0] STATE;
	 
	 //Definiçao de estados
	 parameter S0=1, S1=2, S2=3, S3=4, S4=5, S5=6, S6=7, S7=8, S8=9, S9=10, STOP=0, START=11;

	
	//Processo de FSM 
	always @(posedge CLK)
	begin: FSM
	  if (EN == 1'b1) // Se estiver ativado
	  begin
		 if ( RST == 1'b1) // E se tiver passado um resete
		 begin	// Reseta todos os operadores
			  DHT_OUT <= 1'b1;
			  WAIT_REG <= 1'b0;
			  COUNTER <= 26'b00000000000000000000000000;	
			  INTDATA <= 40'b0000000000000000000000000000000000000000;
			  DIR <= 1'b1;			   //Configura pino saida
			  error_REG <= 1'b0;
			  STATE <= START; // Vai para o estado de start
			  r_done <= 1'b0;
		 end else begin
		 
			 case (STATE)
				 START:
				     begin			
							
						   WAIT_REG <= 1'b1;
							DIR <= 1'b1;
							DHT_OUT <= 1'b1;	
							STATE <= S0;							 
					  end
			   
				 S0: // Envia para o DHT11 uma requisição de dados durante o tempo necessário
					 begin
					   DIR <= 1'b1;	
					   DHT_OUT <= 1'b1;
						WAIT_REG <= 1'b1;
						error_REG <= 1'b0;
						if (COUNTER < 900000)// -- b111001111110111100000 --100.000.000/2 = 50.000.000 -> 1/50.000.000 = 0,00002ms --> 18ms/0,00002 = 900000 ciclos)
						begin
							COUNTER <= COUNTER +1'b1;
						end else begin
							COUNTER <= 26'b00000000000000000000000000;
							STATE <= S1;
						end
					 end
				 
				 S1: // Depois coloca em valor logico baixo pela mesma quantidade de tempo
					 begin
					   DHT_OUT <= 1'b0;	
						WAIT_REG <= 1'b1;
						if (COUNTER < 900000)							// --b111001111110111100000 -- 100.000.000/2 = 50.000.000 -> 1/50.000.000 = 0,00000002s --> 18ms/0,00002 = 900000 ciclos)
						begin
							COUNTER <= COUNTER +1'b1;
						end else begin
							COUNTER <= 26'b00000000000000000000000000;
							STATE <= S2;
						end
					 end
				S2: // Espera a resposta do DHT11
					begin					   
						DHT_OUT <= 1'b1;			//Leva para 1 aguarda 20 uS (resposta do DHT ocorre entre 20 e 40 uS)						
						if (COUNTER < 1000)
						begin
						   COUNTER <= COUNTER +1'b1;
						end else begin						
							DIR <= 1'b0; // Muda o sentido de entrada e saida						
							STATE <= S3;									
						end						
					end
					
				S3:
					begin	 					
						if (COUNTER < 3000 && DHT_IN == 1'b1 )	// 60 (88) uS / 0,02uS = 2000 CICLOS DE 50MHZ
						begin		                     						
						 	COUNTER <= COUNTER +1'b1;
							STATE <= S3;
						end else begin
						  if ( DHT_IN == 1'b1 )  //Se ultrapassa o limite de 40uS -- erro de inicializacao do DHT11
						  begin						  																	
							   error_REG <= 1'b1;
								COUNTER <= 26'b00000000000000000000000000;
							   STATE <=STOP;
						  end else begin
						      COUNTER <= 26'b00000000000000000000000000;
						      STATE <=S4;											//Nao passou 40uS, entao DHT foi a 0, logo - OK
						  end
						end
					end
					
				S4:
					begin
					  //DETECTA PULSO DE SINCRONISMO - P1
						if ( DHT_IN == 1'b0  && COUNTER < 4400)// 0,00002 = 0,02 uS -> 80uS/0,02uS =  -> 25'b0000000000000111110100000
						begin
						   COUNTER <= COUNTER +1'b1;
							STATE <= S4;
						end else begin
					      if ( DHT_IN == 1'b0)
							begin
							   error_REG <= 1'b1;
								COUNTER <= 26'b00000000000000000000000000;	
							   STATE <=STOP;
							end else begin 
						   	STATE <= S5;
								COUNTER <= 26'b00000000000000000000000000;															
							end
						end
					end
			
				S5:
					begin
					  //DETECTA PULSO DE SINCRONISMO - P2
						if ( DHT_IN == 1'b1 && COUNTER < 4400)				// 0,00002 = 0,02 uS -> 80uS/0,02uS =  -> 25'b0000000000000111110100000
						begin
						   COUNTER <= COUNTER +1'b1;
							STATE <= S5;
						end else begin
						   if ( DHT_IN == 1'b1)
							begin
							   error_REG <= 1'b1;
								COUNTER <= 26'b00000000000000000000000000;	
							   STATE <=STOP;
							end else begin 
								STATE <= S6;  
								error_REG <= 1'b0;
								index <= 6'b000000; //reseta indexador
								COUNTER <= 26'b00000000000000000000000000;															
							end
						end
					end
				//Inicio da analise de dados	
				S6:						//Realiza Resets
					begin				
							 if ( DHT_IN == 1'b0 )
							 begin
								STATE <= S7;
							end else begin
							   error_REG <= 1'b1;
								COUNTER <= 26'b00000000000000000000000000;	
							   STATE <=STOP;							
							end
					end					
				
				S7:      //Chegou neste estado, o nivel logico zero, deve aguardar comutação para 1 de modo a avaliar tempos
					begin
					  if ( DHT_IN == 1'b1 )
					  begin
								COUNTER <= 26'b00000000000000000000000001;
								STATE <= S8;								
						end else begin
						   if ( COUNTER < 16000000)  // -- 60uS - - VERIFICA SE ESTOUROU TEMPO PARA IR A ZERO E INICIAR TRANSMISSAO DE DADOS
							begin								
								COUNTER <= COUNTER +1'b1;
								STATE <= S7;	
							end else begin
								COUNTER <=  26'b00000000000000000000000000;
								error_REG <= 1'b1;
								STATE <= STOP;
							end
						end
					end
					
				S8:   //Aguarda comutação para 0
				   begin
						if (  DHT_IN == 1'b0 ) /// 50MHz = 0,02 uS -> 60uS = 2500 ciclos
						begin
									
									if ( COUNTER > 2500) 
									begin
									   INTDATA[index] <= 1'b1;
										DEBUG_REG <= 1'b1;
										
									end else begin
		
										INTDATA[index] <= 1'b0;
										DEBUG_REG <= 1'b0;									   
									end																	

									if (index < 39 )
									begin										
										COUNTER <= 26'b00000000000000000000000000;
										STATE <= S9;
									end else begin		
										error_REG <= 1'b0;									
										STATE <= STOP;
									end										
									
									
								//	STATE <= S9;
									
						end else begin
									COUNTER <= COUNTER + 1'b1;
									
									if (COUNTER > 16000000) //Caso mais de 32mS de espera, aborta
									begin
									   error_REG <= 1'b1;
										STATE <= STOP;
									end
						end
					 end
					 
				 S9:
					begin
					    index <= index+1'b1;
						 STATE <= S6; // Se ocorreu tudo certo, volta para o estado 6 para pegar o proximo bit
					end	
				 
				 STOP:
					begin
					   STATE <= STOP;
					   if ( error_REG == 1'b0 ) 
						begin						
							DHT_OUT <= 1'b1;								
							WAIT_REG <= 1'b0;
							COUNTER <= 26'b00000000000000000000000000;	
							DIR <= 1'b1;	 //Configura pino saida	
							error_REG <= 1'b0;							
							index <= 6'b000000;
							r_done <= 1'b1;
						end else begin
						  if ( COUNTER < 16000000 )   //Se error_REG, mantem estrutura bloqueada por 3,2 ms até o DHT finalizar e sinaliza erro
						  begin
						      INTDATA <= 40'b0000000000000000000000000000000000000000;
								COUNTER <= COUNTER + 1'b1;
								error_REG <= 1'b1;
								WAIT_REG <= 1'b1;
								DIR <= 1'b0;
								r_done <= 1'b1;//Configura pino said
						  end else begin
								error_REG <= 1'b0;				//volta error_REG a 0 para resetar tudo
						  end
						end
					   	
					end
			 endcase
		end
	end
  end


endmodule

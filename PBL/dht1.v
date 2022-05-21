`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    DHT11 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module dht11(
	 input i_Clock,  //100 MHz
    input i_En,
    input i_Rst,	 
    inout i_Dht_Data,
	 output [7:0] o_Hum_Int,
	 output [7:0] o_Hum_Float,
    output [7:0] o_Temp_Int,
	 output [7:0] o_Temp_Float,
	 output [7:0] o_Crc,
	 output o_Wait,
	 output o_Error
    );


	reg DHT_OUT, DIR, WAIT_REG;  //Registrador de saida	
	reg [25:0] COUNTER; //Contador de ciclos para gerar delays
	reg [5:0] index;
	reg [39:0] INTDATA; //registrador de dados interno
	reg error_REG;
	wire [39:0] DHT_IN;
	
	//wire DHT_IN;
	
	assign o_Wait = WAIT_REG;
	assign o_Error = error_REG;
	
	//assign i_Dht_Data = DIR ? DHT_OUT : 1'bZ; // Se DIR 1 -- copia DHT_OUT para saida, caso nao, deixa o pino indefinido para atuar como entrada
	//assign DHT_IN = i_Dht_Data;


tris TRIS_DATA(
    .i_Port(i_Dht_Data),
    .i_Dir(DIR),
    .i_Send(DHT_OUT),
    .o_Read(DHT_IN)
    );

	
	assign o_Hum_Int[7] = INTDATA[0];
	assign o_Hum_Int[6] = INTDATA[1];
	assign o_Hum_Int[5] = INTDATA[2];
	assign o_Hum_Int[4] = INTDATA[3];
	assign o_Hum_Int[3] = INTDATA[4];
	assign o_Hum_Int[2] = INTDATA[5];
	assign o_Hum_Int[1] = INTDATA[6];
	assign o_Hum_Int[0] = INTDATA[7];
	
	assign o_Hum_Float[7] = INTDATA[8];
	assign o_Hum_Float[6] = INTDATA[9];
	assign o_Hum_Float[5] = INTDATA[10];
	assign o_Hum_Float[4] = INTDATA[11];
	assign o_Hum_Float[3] = INTDATA[12];
	assign o_Hum_Float[2] = INTDATA[13];
	assign o_Hum_Float[1] = INTDATA[14];
	assign o_Hum_Float[0] = INTDATA[15];
	
	assign o_Temp_Int[7] = INTDATA[16];  
	assign o_Temp_Int[6] = INTDATA[17];
	assign o_Temp_Int[5] = INTDATA[18];
	assign o_Temp_Int[4] = INTDATA[19];
	assign o_Temp_Int[3] = INTDATA[20];
	assign o_Temp_Int[2] = INTDATA[21];
	assign o_Temp_Int[1] = INTDATA[22];
	assign o_Temp_Int[0] = INTDATA[23]; 
	
	assign o_Temp_Float[7] = INTDATA[24];
	assign o_Temp_Float[6] = INTDATA[25];
	assign o_Temp_Float[5] = INTDATA[26];
	assign o_Temp_Float[4] = INTDATA[27];
	assign o_Temp_Float[3] = INTDATA[28];
	assign o_Temp_Float[2] = INTDATA[29];
	assign o_Temp_Float[1] = INTDATA[30];
	assign o_Temp_Float[0] = INTDATA[31];	
	
	assign o_Crc[7] =  INTDATA[32];
	assign o_Crc[6] =  INTDATA[33];
	assign o_Crc[5] =  INTDATA[34];
	assign o_Crc[4] =  INTDATA[35];
	assign o_Crc[3] =  INTDATA[36];
	assign o_Crc[2] =  INTDATA[37];
	assign o_Crc[1] =  INTDATA[38];
	assign o_Crc[0] =  INTDATA[39];


	 reg [3:0] STATE;
	 
	 //Definiï¿½ï¿½o de estados
	 parameter S0=1, S1=2, S2=3, S3=4, S4=5, S5=6, S6=7, S7=8, S8=9, S9=10, STOP=0, START=11;

 
	//Processo de FSM 
	always @(posedge i_Clock)
	begin: FSM
	  if (i_En == 1'b1)
	  begin
		 if ( i_Rst == 1'b1)
		 begin			  
			  DHT_OUT <= 1'b1;			  
			  WAIT_REG <= 1'b0;
			  COUNTER <= 26'b00000000000000000000000000;	
			  INTDATA <= 40'b0000000000000000000000000000000000000000;
			  DIR <= 1'b1;			   //Configura pino saida
			  error_REG <= 1'b0;
			  STATE <= START;
		 end else begin
		 
			 case (STATE)
				 START:
				     begin			
						   WAIT_REG <= 1'b1;
							DIR <= 1'b1;
							DHT_OUT <= 1'b1;	
							STATE <= S0;							 
					  end
			   
				 S0:
					 begin
					   DIR <= 1'b1;	
					   DHT_OUT <= 1'b1;
						WAIT_REG <= 1'b1;
						error_REG <= 1'b0;
						if (COUNTER < 900000)							// -- b111001111110111100000 --100.000.000/2 = 50.000.000 -> 1/50.000.000 = 0,00002ms --> 18ms/0,00002 = 900000 ciclos)
						begin
							COUNTER <= COUNTER +1'b1;
						end else begin
							COUNTER <= 26'b00000000000000000000000000;
							STATE <= S1;
						end
					 end
				 
				 S1:
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
				S2:
					begin					   
						DHT_OUT <= 1'b1;			//Leva para 1 aguarda 20 uS (resposta do DHT ocorre entre 20 e 40 uS)						
						if (COUNTER < 1000)
						begin
						   COUNTER <= COUNTER +1'b1;
						end else begin						
							DIR <= 1'b0;							
							STATE <= S3;									
						end						
					end
					
				S3:
					begin	 
               //   DIR <= 1'b0;					
						if (COUNTER < 3000 && DHT_IN == 1'b1 )							// 60 (88) uS / 0,02uS = 2000 CICLOS DE 50MHZ
						begin		                     						
						 	COUNTER <= COUNTER +1'b1;
							STATE <= S3;
						end else begin
						  if ( DHT_IN == 1'b1 )  											//Se ultrapassa o limite de 40uS -- erro de inicializacao do DHT11
						  begin						  																	
							   error_REG <= 1'b1;
								COUNTER <= 26'b00000000000000000000000000;
							   STATE <=STOP;
						  end else begin
						      COUNTER <= 26'b00000000000000000000000000;
						      STATE <=S4;														//Nao passou 40uS, entao DHT foi a 0, logo - OK
						  end
						end
					end
					
				S4:
					begin
					  //DETECTA PULSO DE SINCRONISMO - P1
						if ( DHT_IN == 1'b0  && COUNTER < 4400)												// 0,00002 = 0,02 uS -> 80uS/0,02uS = 10000 ciclos de 50MHz -> 25'b0000000000000111110100000
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
						if ( DHT_IN == 1'b1 && COUNTER < 4400)												// 0,00002 = 0,02 uS -> 80uS/0,02uS = 10000 ciclos de 50MHz -> 25'b0000000000000111110100000
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
				
				S7:      //Chegou neste estado, o nivel logico jï¿½ ï¿½ zero, deve aguardar comutaï¿½ï¿½o para 1 de modo a avaliar tempos
					begin
					  if ( DHT_IN == 1'b1 )
					  begin
								COUNTER <= 26'b00000000000000000000000001;
								STATE <= S8;								
						end else begin
						   if ( COUNTER < 16000000)  // -- 60uS - 3000 ciclos - VERIFICA SE ESTOUROU TEMPO PARA IR A ZERO E INICIAR TRANSMISSAO DE DADOS
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
					
				S8:   //Aguarda comutaï¿½ï¿½o para 0
				   begin
						if (  DHT_IN == 1'b0 ) /// 50MHz = 0,02 uS -> 60uS = 2500 ciclos
						begin
									
									if ( COUNTER > 2500) 
									begin
									   INTDATA[index] <= 1'b1;
										
									end else begin
		
										INTDATA[index] <= 1'b0;								   
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
						 STATE <= S6;
					end	
				 
				 STOP:
					begin
					   STATE <= STOP;
					   if ( error_REG == 1'b0 ) 
						begin						
							DHT_OUT <= 1'b1;								
							WAIT_REG <= 1'b0;
							COUNTER <= 26'b00000000000000000000000000;	
							DIR <= 1'b1;			   //Configura pino saida	
							error_REG <= 1'b0;							
							index <= 6'b000000;	
						end else begin
						  if ( COUNTER < 16000000 )   //Se error_REG, mantem estrutura bloqueada por 3,2 ms atï¿½ DHT finalizar e sinaliza erro
						  begin
						      INTDATA <= 40'b0000000000000000000000000000000000000000;
								COUNTER <= COUNTER + 1'b1;
								error_REG <= 1'b1;
								WAIT_REG <= 1'b1;
								DIR <= 1'b0;			   //Configura pino said
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

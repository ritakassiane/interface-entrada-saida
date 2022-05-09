`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:10:12 04/11/2017 
// Design Name: 
// Module Name:    Top_Proj 
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
module Top_Proj(
	GPIO_LED1,		//Sinaliza��o START
	GPIO_LED2,		//Sinaliza��o START
	PMOD1_P7,     //SCLK
	PMOD1_P8, 	  //MOSI
	PMOD1_P9, 	  //CS1
	PMOD1_P10,		//cs2
	PMOD2_P1,     //DHT
	PMOD2_P2,		//DHT ERROR
	PMOD2_P3,		//Debug
	CLK50MHZ		//Clock Principal
	);

	//Entradas
	input CLK50MHZ;
	
	//Saidas
	output PMOD1_P7,PMOD1_P8,PMOD1_P9, PMOD1_P10, PMOD2_P2, GPIO_LED1, GPIO_LED2, PMOD2_P3;      //Saida PMOD	
	inout PMOD2_P1;


	//Wires do PLL
	//wire CLK50MHZ, CLK50MHZ, BUFF25MHZ, BUFF8MHZ, CLK6M25HZ, PLLRST;
	//assign PLLRST = 0;
	
	//Wires do Divisor
	wire CLK6M25HZ, CLK48k9HZ, CLK2_98HZ;
	
	//Wires da 74HC595
	wire RST_74HC, EN_74HC595, SCLK_74HC, MOSI_74HC, CS_74HC, WAIT_74HC;
	wire [0:7] DATA_BUS;
	reg  EN_74HC595_REG, RST_74HC_REG;
   reg [0:7] DATA_BUS_REG, DATA1_REG, DATA2_REG; //Registradores adotados para manipula��o de dados
	reg CS_74HC_1, CS_74HC_2;
	
	//FSM START
	reg  EN_74HC595_REG_START, RST_74HC_REG_START;
	reg [0:7] DATA_BUS_REG_START;
	
	
	//assign DATA_BUS = DATA_BUS_REG;	
	assign PMOD1_P7 = SCLK_74HC;  //Conecta SCLK
	assign PMOD1_P8 = MOSI_74HC;   //Conecta MOSI/DATA
	assign PMOD1_P9 = CS_74HC_1;   //Conecta CS
	assign PMOD1_P10 = CS_74HC_2;   //Conecta CS
	
	
	
	
	//Multiplexa a saida entre FSM Start e FSM Principal
	//assign RST_74HC = RST_74HC_REG;	
	assign RST_74HC = STARTED ? RST_74HC_REG : RST_74HC_REG_START;	
	//assign EN_74HC595 = EN_74HC595_REG;
	assign EN_74HC595 = STARTED ? EN_74HC595_REG : EN_74HC595_REG_START;
	assign DATA_BUS = STARTED ? DATA_BUS_REG : DATA_BUS_REG_START;
	
	//Wires do conversor para Display
	wire EN_CD1, EN_CD2, RST_CD1, RST_CD2, WAIT_CD1, WAIT_CD2;
	wire [0:7] DATA_IN_CD1, DATA_IN_CD2, DATA_OUT_CD1, DATA_OUT_CD2;
	reg  [0:7] DATA_IN_CD1_REG, DATA_IN_CD2_REG;
	reg  EN_CD1_REG, EN_CD2_REG, RST_CD1_REG, RST_CD2_REG;
	
	//FSM START
	reg  EN_CD1_REG_START, EN_CD2_REG_START, RST_CD1_REG_START, RST_CD2_REG_START;
	
//	assign EN_CD1= EN_CD1_REG ;
//	assign EN_CD2 = EN_CD2_REG ;
//	assign RST_CD1 = RST_CD1_REG ;
//	assign RST_CD2 = RST_CD2_REG ;
	
	//Multiplexa a saida entre FSM Start e FSM Principal
	assign EN_CD1 = STARTED ? EN_CD1_REG : EN_CD1_REG_START;
	assign EN_CD2 = STARTED ? EN_CD2_REG : EN_CD2_REG_START;	
	assign RST_CD1 = STARTED ? RST_CD1_REG : RST_CD1_REG_START;
	assign RST_CD2 = STARTED ? RST_CD2_REG : RST_CD2_REG_START;
	
	assign DATA_IN_CD1 = DATA_IN_CD1_REG ;
	assign DATA_IN_CD2 = DATA_IN_CD2_REG ;
	
   //Wires para DHT11
	wire EN_DHT11, RST_DHT11, DHT_DATA, CRC_DHT, WAIT_DHT11, ERROR_DHT11;
	wire [0:7] HUM_INT, HUM_FLOAT, TEMP_INT, TEMP_FLOAT;
	reg EN_DHT11_REG, RST_DHT11_REG;
	
	//FSM Start
	reg EN_DHT11_REG_START, RST_DHT11_REG_START;
	
	//assign EN_DHT11 = EN_DHT11_REG;
	assign PMOD2_P2 = ERROR_DHT11;
	
	//Multiplexa a saida entre FSM Start e FSM Principal
	assign EN_DHT11 = STARTED ? EN_DHT11_REG : EN_DHT11_REG_START;	
   assign RST_DHT11 = STARTED ? RST_DHT11_REG : RST_DHT11_REG_START;			
		
	
	//assign PMOD2_P1 = DHT_DATA;
	
	//PLL Embarcado
	//PLL_100_25_8_3M125Hz PLL01 (CLK50MHZ, CLK50MHZ, BUFF25MHZ, BUFF8MHZ, CLK6M25HZ, PLLRST);
	
	//Multiplexador
	//mux2x1 mux1 (BUFF8MHZ, CLK6M25HZ, GPIO_DIP1, PMOD1_P1);

	//Divisor de clock
	clockDiv clkdv01 (CLK50MHZ, CLK6M25HZ, CLK48k9HZ, CLK2_98HZ);	
	
	//Modulo 74HC595
	SPI_Out CI74HC595(	
		.CLK(CLK6M25HZ),
		.EN(EN_74HC595),
		.DATA(DATA_BUS),
		.RST(RST_74HC),
		.SCLK(SCLK_74HC),
		.MOSI(MOSI_74HC),
		.CS(CS_74HC),
		.WAIT(WAIT_74HC)
		
	); 
	
	//Conversor 7Seg
  C7SEG DISPLAY1(
		.CLK(CLK50MHZ),
		.EN(EN_CD1),
		.RST(RST_CD1),
		.DATA_IN(DATA_IN_CD1),
		.DATA_OUT(DATA_OUT_CD1),
		.WAIT(WAIT_CD1)
		 );	

  C7SEG DISPLAY2(
		.CLK(CLK50MHZ),
		.EN(EN_CD2),
		.RST(RST_CD2),
		.DATA_IN(DATA_IN_CD2),
		.DATA_OUT(DATA_OUT_CD2),
		.WAIT(WAIT_CD2)
		 );	
		 
  DHT11 DHT11(
		 .CLK(CLK50MHZ),  //100 MHz
		 .EN(EN_DHT11),
		 .RST(RST_DHT11),
		 .DHT_DATA(PMOD2_P1),
		 .HUM_INT(HUM_INT),
		 .HUM_FLOAT(HUM_FLOAT),
		 .TEMP_INT(TEMP_INT),
		 .TEMP_FLOAT(TEMP_FLOAT),
		 .CRC(CRC_DHT),
		 .WAIT(WAIT_DHT11),
		 .error(ERROR_DHT11),
		 .DEBUG(PMOD2_P3)
		 );

	
	reg [1:0] FSMSTARTSTATE; //O tamanho do registrador deve garantir a quantidade de estados
	reg STARTED;
	reg LED;
	reg LED_START;
	
	//assign GPIO_LED1 = LED;
	assign GPIO_LED1 = STARTED ? LED : LED_START;
	
	parameter START0=0,START1=1, START2=2, START3=3;
	
	always @(posedge CLK50MHZ)
	begin: FSMSTART	
	  begin
			case (FSMSTARTSTATE)
			
				START0:
				  begin
				   
					 STARTED <= 1'b0;
					 LED_START <=1;
					  EN_DHT11_REG_START <= 1'b1;
					 RST_DHT11_REG_START <= 1'b1;
			      
					//RESET DO CONVERSOR BCD
						//dig1
					 EN_CD1_REG_START <= 1'b1;
					 RST_CD1_REG_START <= 1'b1;
						//dig2
					 EN_CD2_REG_START <= 1'b1;
					 RST_CD2_REG_START <= 1'b1;				
					 
						   //reset do SPI
					 DATA_BUS_REG_START <= 0;
					 RST_74HC_REG_START <= 1'b1;
					 EN_74HC595_REG_START  <= 1'b1;


					 
					 FSMSTARTSTATE <= START1;
				   end
									
				START1:
				  begin
				    LED_START <=0;
					
					EN_DHT11_REG_START <= 1'b0;
					RST_DHT11_REG_START <= 1'b0;

			      
					//RESET DO CONVERSOR BCD
						//dig1
					 EN_CD1_REG_START <= 1'b0;
					 RST_CD1_REG_START <= 1'b0;
						//dig2
					 EN_CD2_REG_START <= 1'b0;
					 RST_CD2_REG_START <= 1'b0;				
					 
						   //reset do SPI
					 DATA_BUS_REG_START <= 0;
					 RST_74HC_REG_START <= 1'b0;
					 EN_74HC595_REG_START  <= 1'b0;
					 
					 STARTED <= 1'b1;
					 
					 FSMSTARTSTATE <= START2;
				   end

				START2:
				  begin
				      												
						 
						 FSMSTARTSTATE <= START2;
				   end					
					

				default: 
					begin
					  FSMSTARTSTATE <= START0;
					end				
			endcase
 	  end
	end	
	
	
	//contador para testes
	reg [7:0] TEMPERATURE;
	reg LED2;
	
	assign GPIO_LED2 = LED2;
	
	
	reg [3:0] STATE; //O tamanho do registrador deve garantir a quantidade de estados
	
	parameter SDHT1=1,SDHT2=2, SDHT3=3, SD=4, CD1=5, CD2=6, CD3=7, S0=8, S1=9, S2=10, S3=11, S4=12, S5=13, WAIT1=14, WAIT2=15;
	
	
	always @(posedge CLK50MHZ)
	begin: FSM
	  if (STARTED == 1'b1)
	  begin
			case (STATE)				
			
				SDHT1:
				  begin				
		          LED2 <= 1'b1;		  
					 EN_DHT11_REG <= 1'b1;
					 RST_DHT11_REG <= 1'b1;
					 
					 
					 STATE <= SDHT2;
				   end
					
				 SDHT2:
				   begin
						LED2 <= 1'b0;
					  if (WAIT_DHT11 == 1'b1)
					  begin
							STATE <= SDHT3;
					  end else begin
						  RST_DHT11_REG <= 1'b0;
						  EN_DHT11_REG <= 1'b1;		
						end
				   end
					
				SDHT3:
					begin
					   LED2 <= 1'b1;
						if (WAIT_DHT11 == 1'b0)
						begin
						   TEMPERATURE <= TEMP_INT;
							EN_DHT11_REG <= 1'b0;
							STATE <= SD;
						end 					
					end
				
				SD:		//SEPARA DIGITOS PARA O DISPLAY 7SEG				   
					begin
							DATA_IN_CD2_REG <= TEMPERATURE/(8'b00001010);					
							DATA_IN_CD1_REG <= TEMPERATURE-((TEMPERATURE/8'b00001010)*8'b00001010);
							STATE <= CD1;								

													
					end
				
				CD1:											//Reset do conversor BCD
					begin
					   LED2 <= 1'b1;
						//dig1
						EN_CD1_REG <= 1'b1;
						RST_CD1_REG <= 1'b1;
						//dig2
						EN_CD2_REG <= 1'b1;
						RST_CD2_REG <= 1'b1;
						
						STATE <= CD2;
					end
				CD2:										   //Aguarda start
					begin
					   LED2 <= 1'b0;
						RST_CD1_REG <= 1'b0;
						RST_CD2_REG <= 1'b0;
						if (WAIT_CD1 == 1'b1 && WAIT_CD2 == 1'b1 )
						begin
							STATE <= CD3;
						end
					end
				CD3:											//Recebe dado e devolve ao registrador
					begin
					   LED2 <= 1'b1;
						if (WAIT_CD1 == 1'b0 && WAIT_CD2 == 1'b0)
						begin
							DATA1_REG <= DATA_OUT_CD1;
							DATA2_REG <= DATA_OUT_CD2;
							STATE <= S0;
						end else begin
							RST_CD1_REG <= 1'b0;	
							RST_CD2_REG <= 1'b0;							
							STATE <= CD3;												
						end
					end
				
				//Compartilha CS74HC -- Envia 1	
				S0:
					begin
					   LED2 <= 1'b0;
					   DATA_BUS_REG <= DATA1_REG;
						RST_74HC_REG <= 1'b1;
						EN_74HC595_REG  <= 1'b1;
						CS_74HC_1 <= CS_74HC;
						if ( WAIT_74HC == 1'b1)
						begin						
							STATE <= S1;
						end
					end							
				
				S1:
					begin					
					   LED2 <= 1'b1;
						RST_74HC_REG <= 1'b0;
						EN_74HC595_REG  <= 1'b1;
						CS_74HC_1 <= CS_74HC;
						STATE <= S2;						
					end

				S2:
					begin
					   LED2 <= 1'b0;
					   CS_74HC_1 <= CS_74HC;
						if ( WAIT_74HC == 1'b1)
						begin
							RST_74HC_REG <= 1'b0;
							EN_74HC595_REG  <= 1'b1;
							STATE <= S2;
						end else begin
							RST_74HC_REG <= 1'b0;
							EN_74HC595_REG  <= 1'b0;
							STATE <= S3;
						end
					end
				//Compartilha CS74HC -- Envia 2	
				S3:
					begin
					   LED2 <= 1'b1;
					   DATA_BUS_REG <= DATA2_REG;
						RST_74HC_REG <= 1'b1;
						EN_74HC595_REG  <= 1'b1;
						CS_74HC_2 <= CS_74HC;
						if ( WAIT_74HC == 1'b1)
						begin						
							STATE <= S4;
						end
					end							
				
				S4:
					begin		
                  LED2 <= 1'b0;					
						RST_74HC_REG <= 1'b0;
						EN_74HC595_REG  <= 1'b1;
						CS_74HC_2 <= CS_74HC;
						STATE <= S5;						
					end

				S5:
					begin
					   LED2 <= 1'b1;
						CS_74HC_2 <= CS_74HC;
						if ( WAIT_74HC == 1'b1)
						begin
							RST_74HC_REG <= 1'b0;
							EN_74HC595_REG  <= 1'b1;
							STATE <= S5;
						end else begin
							RST_74HC_REG <= 1'b0;
							EN_74HC595_REG  <= 1'b0;
							//STATE <= CD1;
							
							if (CLK2_98HZ == 1'b0 )
                     begin						
								STATE <= WAIT1;
							end 
						end
					end
				//Aguardar para proximo ciclo de aquisi��o de dados	
				WAIT1:
					begin
						if (CLK2_98HZ == 1)						
						begin
							STATE <= WAIT2;
						end
					end
				WAIT2:
					begin
						if (CLK2_98HZ == 0)
						begin
							STATE <= SDHT1;
						end	
					end					
									
					

				default: 
					begin
					  STATE <= SDHT1;
					end				
			endcase
 	  end else begin
		STATE <= SDHT1;
	  
	  end//if EN
	end	
	
	
endmodule



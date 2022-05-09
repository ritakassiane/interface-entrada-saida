`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:06:20 06/18/2017 
// Design Name: 
// Module Name:    SPI_Out 
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
module SPI_Out(
	CLK,
	EN,
	DATA,
	RST,
	SCLK,
	MOSI,
	CS,
	WAIT
);
	//entradas
	input [7:0] DATA;
	input CLK, EN, RST;
	//saidas
	output SCLK, MOSI, CS, WAIT;
	
	reg [3:0] STATE; //O tamanho do registrador deve garantir a quantidade de estados
   reg SCLK, MOSI, CS, WAIT, TRIG;
	//reg [0:7] DATA; //Informa que DATA é um banco de registradores de 8bits
	
	parameter START=0, S0=1, S1=2, S2=3, S3=4, S4=5, S5=6, S6=7, S7=8, STOP=9;
	
	
	always @(posedge CLK)
	begin: FSM
	  if (EN == 1'b1)
	  begin
		 if ( RST == 1'b1)
		 begin
			  STATE <= START;
			  SCLK <= 1'b0;
			  MOSI <= 1'b0;
			  WAIT <= 1'b1;
			  CS <= 1'b1;
		 end else begin
			case (STATE)
				START:
					begin
					   WAIT <= 1'b1;
						STATE <= S0;
						TRIG <= 1'b1;
						SCLK <= 1'b0;
						MOSI <=1'B0;
						CS <= 1'b0;
					end	
			
				S0:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[7];
							TRIG <= 1'b0;
						end else begin													
							STATE <= S1;
							SCLK <= 1'b0;
							TRIG <= 1'b1;							
						end
					end							
				
				S1:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[6];
							TRIG <= 1'b0;
						end else begin													
							STATE <= S2;
							SCLK <= 1'b0;
							TRIG <= 1'b1;	
						end
					end		
					
				S2:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[5];
							TRIG <= 1'b0;
						end else begin													
							STATE <= S3;
							SCLK <= 1'b0;
							TRIG <= 1'b1;
						end
					end		
								
				
				S3:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[4];
							TRIG <= 1'b0;
						end else begin													
							STATE <= S4;
							SCLK <= 1'b0;
							TRIG <= 1'b1;	
						end
					end		

				S4:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[3];
							TRIG <= 1'b0;
						end else begin													
							STATE <= S5;
							SCLK <= 1'b0;
							TRIG <= 1'b1;
						end
					end		
					
				S5:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[2];
							TRIG <= 1'b0;
						end else begin													
							STATE <= S6;
							SCLK <= 1'b0;
							TRIG <= 1'b1;
						end
					end		

				S6:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[1];
							TRIG <= 1'b0;
						end else begin													
							STATE <= S7;
							SCLK <= 1'b0;
							TRIG <= 1'b1;
						end
					end		

				S7:
					begin
						if ( TRIG == 1'b1)
						begin
							SCLK <= 1'b1;
							MOSI <=DATA[0];
							TRIG <= 1'b0;
						end else begin													
							STATE <= STOP;
							SCLK <= 1'b0;	
							TRIG <= 1'b1;
						end
					end	
				
				STOP:
					begin
					   WAIT <= 1'b0;
						STATE <= STOP;
						SCLK <= 1'b0;
						MOSI <=1'b0;
						CS <= 1'b1;
					end	

				default: //O DEFAULT DEVE SER PARADO - SEQUENCIA DE INICIALIZACAO - RST=1 + EN=1 --- RST=0 + RN0.
					begin
					  STATE <= STOP;
					end				
			endcase
		end  //if RST
 	  end //if EN
	end
endmodule
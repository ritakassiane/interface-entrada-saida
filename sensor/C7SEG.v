`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:05:59 07/03/2017 
// Design Name: 
// Module Name:    C7SEG 
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
module C7SEG(
	CLK,
	EN,
	RST,
	DATA_IN,
	DATA_OUT,
	WAIT
    );
	 
	 //Definição de IOs
	 input  CLK, EN, RST;
	 input [0:7] DATA_IN;	 
	 output WAIT;
	 output [0:7] DATA_OUT;
	 
	 //Definição de registradores
	 //reg [0:7]DATA_IN;
	 reg [0:7]DATA_OUT_REG;
	
	  assign DATA_OUT = DATA_OUT_REG;
	
	 reg WAIT_REG;
	 assign WAIT = WAIT_REG;
	 
	 //Definição para FSM
	 reg [1:0] STATE;
	 parameter S0=0, S1=1, S2=2;
	 
	//Processo de FSM 
	always @(posedge CLK)
	begin: FSM
	  if (EN == 1'b1)
	  begin
		 if ( RST == 1'b1)
		 begin
			  STATE <= S0;
			  DATA_OUT_REG <= 8'b00000000;
			  WAIT_REG <= 1'b1;
		 end else begin
		 
			 case (STATE)
				 S0:
					begin
						 WAIT_REG <= 1'b1;
						 STATE <= S1;
					 end
				 S1:
					 begin				 
							 case (DATA_IN)				 
									0:                             //abcdefg
									begin
										  DATA_OUT_REG <= ~8'b00111111;// 1111110;
									end	  

									1:
									begin
										  DATA_OUT_REG <= ~8'b00000110;// 0110000;
									end	  
										  
									2:
									begin
										  DATA_OUT_REG <= ~8'b01011011;// 1101101; //aqui
									end	  

									3:
									begin
										  DATA_OUT_REG <= ~8'b01001111;// 1111001;
									end	  

									4:
									begin
										  DATA_OUT_REG <= ~8'b01100110; //0110011;
									end	  

									5:
									begin
										  DATA_OUT_REG <= ~8'b01101101;//1011011;
									end	  

									6:
									begin
										  DATA_OUT_REG <= ~8'b01111101;//1011111;
									end	  

									7:
									begin
										  DATA_OUT_REG <= ~8'b00000111;//1110000;
									end	  
										  
									8:
									begin
										  DATA_OUT_REG <= ~8'b01111111;//1111111;
									end	  
										  
									9:
									begin
										  DATA_OUT_REG <= ~8'b01101111;//1111011;
									end	  
							endcase //Case DATA
							
							STATE <= S2;
						end //end estado S0
						
					S2:
						begin
							WAIT_REG <= 1'b0;
						end
						
				endcase //Case State
			end //end Reset
		 end //else begin
		//		WAIT_REG <= 1'b0;
		//		STATE <= S0;
		 //end
	  end //End Process/FSM
endmodule

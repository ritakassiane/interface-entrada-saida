`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:36:23 05/18/2017 
// Design Name: 
// Module Name:    clockDiv 
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
module clockDiv( 
	CLK, 
	OUT1, 
	OUT2, 
	OUT3
    );

   //entradas
	input CLK;
	
	//saidas
	output OUT1, OUT2, OUT3;
	
	//REGISTRADOR
	reg [25:0] COUNTER;
	initial COUNTER = 0;
	
	assign OUT1 = COUNTER[2];  //bit 3 do contador --- 6.25MHz
	assign OUT2 = COUNTER[9];  //bit 10 do contador --- 48.9KHz
	assign OUT3 = COUNTER[23]; //bit 24 do contador --- 2.98Hz
	
	always @(posedge CLK)
	begin
		//Soma para contador
		COUNTER <= COUNTER+1;
		//Controla o estouro
		if ( COUNTER == 26'h3FFFFFF )
		begin
			COUNTER <= 26'h0;
		end	
	end
endmodule

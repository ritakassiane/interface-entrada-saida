`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:13:47 04/11/2017
// Design Name:   Top_Proj
// Module Name:   C:/ProjetosXilinx/Exemplo01/Tb_Proj.v
// Project Name:  Exemplo01
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top_Proj
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Tb_Proj;

	// Inputs 
	reg CLK100MHZ;
	
	

	// Outputs
	wire PMOD1_P7;
	wire PMOD1_P8;
	wire PMOD1_P9;
	wire PMOD1_P10;	

	// Instantiate the Unit Under Test (UUT)
	Top_Proj uut (
		.PMOD1_P7(PMOD1_P7),
		.PMOD1_P8(PMOD1_P8),
		.PMOD1_P9(PMOD1_P9),	
		.PMOD1_P10(PMOD1_P10),		
		.CLK100MHZ(CLK100MHZ)
	);

	initial begin
		// Initialize Inputs
		CLK100MHZ = 0;		
	end
	
	//Sinais de clock
	always   #10 CLK100MHZ = !CLK100MHZ;   //  1/(100*10^-9)=10MHz	
  
	
	
		// Add stimulus here

	
      
endmodule


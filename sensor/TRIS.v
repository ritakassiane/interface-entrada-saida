`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:36:05 07/06/2017 
// Design Name: 
// Module Name:    TRIS 
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
module TRIS(
    inout PORT,
    input DIR,
    input SEND,
    output READ
    );

assign PORT = DIR ? SEND : 1'bZ; // Se DIR 1 -- copia DHT_OUT para saida, caso nao, deixa o pino indefinido para atuar como entrada
assign READ = DIR ?  1'bz : PORT;

endmodule

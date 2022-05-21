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
module tris(
    inout i_Port,
    input i_Dir,
    input i_Send,
    output o_Read
    );

assign i_Port = i_Dir ? i_Send : 1'bZ; // Se DIR 1 -- copia DHT_OUT para saida, caso nao, deixa o pino indefinido para atuar como entrada
assign o_Read = i_Dir ?  1'bz : i_Port;

endmodule
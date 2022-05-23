module loop (
   input        i_Clock,
   input        i_Tx_DV,
   input [7:0]  i_Tx_Byte, 
   input        i_Rx_Serial,
   output       o_Tx_Active,
   output wire   o_Tx_Serial,
   output       o_Tx_Done,
	output       o_Rx_DV,
   output [7:0] o_Rx_Byte,
	output [2:0] led
);

reg [2:0] r_led = 3'b000;

assign led = r_led;

uart_tx insttx(
	.i_Clock(i_Clock),
	.i_Tx_DV(i_Tx_DV),
	.i_Tx_Byte (i_Tx_Byte), 
   .o_Tx_Active(o_Tx_Active),
   .o_Tx_Serial(o_Tx_Serial),
   .o_Tx_Done(o_Tx_Done)
	
);

uart_rx instrx(
	.i_Clock(i_Clock),
   .i_Rx_Serial(i_Rx_Serial),
   .o_Rx_DV(o_Rx_DV),
   .o_Rx_Byte(o_Rx_Byte),

);

always @(posedge i_Clock) begin
	if(o_Rx_Byte == 8'b11001010) begin
		r_led <= 3'b010;
		end
	//else begin 
		//r_led <= 3'b000;
end

endmodule 
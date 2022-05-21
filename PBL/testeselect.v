module testeselect (
	input        i_Clock,
   input        i_Rx_Serial,
	input			 i_Rst,
   output       o_Rx_DV,
   output [7:0] o_Rx_Byte,
	output [7:0] address,
	output [7:0] request,
	output o_done,
	output red,
	output blue,
	output green
);

reg	r_red = 1'b0;
reg	r_blue = 1'b0;
reg	r_green = 1'b0;

uart_rx instrx(
	.i_Clock(i_Clock),
   .i_Rx_Serial(i_Rx_Serial),
   .o_Rx_DV(o_Rx_DV),
   .o_Rx_Byte(o_Rx_Byte)

);

selector inst_selec(
	.i_Clock(i_Clock),
	.i_Rst(i_Rst),
	.i_Data(o_Rx_Byte),
	.i_Data_Done(o_Rx_DV),
   .o_address(address),
	.o_request(request),
	.o_done(done)

);

always @(posedge i_Clock) begin
	if (address == 8'b11001010) begin
		r_red <= 1'b0;
	end
	else begin
		r_red <= 1'b0;
	end
	if (request == 8'b11001010) begin
		r_blue <= 1'b1;
	end
	else begin
		r_blue <= 1'b0;
	end
	if (o_Rx_Byte == 8'b11001010) begin
		r_green <= 1'b0;
	end
	else begin
		r_green <= 1'b0;
	end
	
end

assign red = r_red;
assign blue = r_blue;
assign green = r_green;
endmodule 
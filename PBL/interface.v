module interface(
	input i_En,
	input [7:0] i_Request,
	input [7:0] i_Hum_Int, 
					i_Hum_Float, 
					i_Temp_Int, 
					i_Temp_Float,
					i_Crc,
	output [23:0] o_Data_Out
);

	reg [23:0] data;
	assign o_Data_Out = data;

//Definindo casos
localparam TEMP=8'b00000001, 
			  HUM=8'b00000010, 
			  ERR=8'b00000000;

always @(posedge i_En) begin
		if (i_En == 1'b1)
		begin
			case(i_Request)
			TEMP	:  data = {i_Temp_Int, i_Temp_Float,i_Crc};
			HUM	:  data = {i_Hum_Int, i_Hum_Float,i_Crc};
			default: data = 23'b00000000000000000000000;
			endcase
		end else begin
			assign data = 23'b00000000000000000000000;
		end
	end
endmodule

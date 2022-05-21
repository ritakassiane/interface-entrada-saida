module interface2(
	input i_Clock,
	input i_En,
	input [7:0] i_request,
	inout	dht_data_int,
	output [7:0] o_data_int,
	output [7:0] o_data_float,
	output o_done_i1
	
);

	wire [7:0] 	w_Hum_Int, 
					w_Hum_Float, 
					w_Temp_Int, 
					w_Temp_Float,
					w_Crc;
					
	reg [7:0] r_data_int = 8'd0;
	reg [7:0] r_data_float = 8'd0;
	reg r_done = 1'b0;
	reg r_Rst = 1'b0;
	wire w_done11;
	reg [1:0] state = 2'b00;
	reg en_dht11;
	
	wire         wait_int;
	wire         error_int;


//Definindo casos
localparam idle =  2'b00, 
			  read  =  2'b01, 
			  reset  =  2'b10,
			  send  =  2'b10;
			  

dht11 ints_dht11 (
	.i_Clock(i_Clock),  
	.i_En(en_dht11),
	.i_Rst(r_Rst),	 
	.i_Dht_Data(dht_data_int),
	.o_Hum_Int(w_Hum_Int),
	.o_Hum_Float(w_Hum_Float),
	.o_Temp_Int(w_Temp_Int),
	.o_Temp_Float(w_Temp_Float),
	.o_Crc(w_Crc),
	.o_Wait(wait_int),
	.o_Error(error_int),
	.o_done11(w_done11)
	
);


always @(posedge i_Clock) begin
			case(state)
			idle:  
				begin
					if (i_En == 1'b1) begin
						en_dht11 <= 1'b1;
						state <= read;
					end
				end
			read:
				begin
					if(w_done11 == 1'b1) begin			
						if(i_request == 8'b00000010)begin
							r_data_int <= w_Temp_Int;
							r_data_float <= w_Temp_Float;
						end
						else if (i_request == 8'b00000011)begin
							r_data_int <= w_Hum_Int;
							r_data_float <= w_Hum_Float;
						end
						state <= reset;
					end
				end
			reset:
				begin
					r_done <= 1'b1;
					r_Rst <= 1'b1;
					state <= send;
				end
			send:
				begin	
					r_Rst <= 1'b0;
					r_done <= 1'b0;
					en_dht11 <= 1'b0;
					state <= idle;
				end
			endcase
end
	
assign o_data_int = r_data_int;
assign o_data_float = r_data_float;
assign o_done_i1 = r_done;
endmodule
	
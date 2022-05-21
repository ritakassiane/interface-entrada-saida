module pack_send(
	input i_Clock,
	input i_en,
	input [7:0] i_data_one,
	input [7:0] i_data_two,
	output      o_Tx_Active,
   output 	   o_Tx_Serial,
   output      o_Tx_Done
	
);

localparam [1:0] s_one         = 2'b01,
					  s_two         = 2'b10,
					  s_idle			 = 2'b11;
					  

reg r_ps_done = 1'b0;
reg [1:0] s_ps = 2'b01;
reg [7:0] r_Tx_Byte  = 8'd0;


always @(posedge i_Clock) begin
	r_ps_done <= 1'b0;
	if(i_en == 1 ) begin
		case (s_ps)
			s_one: 
				begin
					r_Tx_Byte <= i_data_one;
					r_ps_done <= 1'b1;
					s_ps <= s_two;
				end
			s_two:
				begin
					r_Tx_Byte <= i_data_two;
					r_ps_done <= 1'b1;
					s_ps <= s_one;
				end
			s_idle:
				begin
					r_ps_done <= 1'b0;
					s_ps <= s_one; 
				end
		endcase
	end
end

uart_tx insttx(
	.i_Clock(i_Clock),
	.i_Tx_DV(r_ps_done),
	.i_Tx_Byte (r_Tx_Byte), 
   .o_Tx_Active(o_Tx_Active),
   .o_Tx_Serial(o_Tx_Serial),
   .o_Tx_Done(o_Tx_Done)
	
);

endmodule 
module selector (
	input i_Clock,
	input [7:0] i_Data,
	input i_Data_Done,
	output [7:0] o_request,
	output [31:0] o_interface
);

	wire [7:0] 	w_data_int, 
					w_data_float, 
					w_data_error;
	
					
reg [7:0] 		address		= 8'd0;
reg [7:0]		request		= 8'd0;
reg [1:0]		count			= 2'd0;
reg [31:0]		r_interface	= 31'd0;
reg				r_done = 1'b0;


assign o_request 		 = request;
assign o_interface    = r_interface;

always @(posedge i_Clock) begin
		if (i_Data_Done == 1'b1)begin
			if (count == 2'b00)  begin
					address <= i_Data;
					count <= 2'b01;
					end
			 else if (count == 2'b01) begin
					request <= i_Data;
					count <= 2'b00;
					r_interface = 32'd0;
					if (address == 8'b00000000) begin
						r_interface[0] <= 1'b1;
					end
			 end

		   end
		else begin
			r_interface <= 32'd0;
		end
end


endmodule 
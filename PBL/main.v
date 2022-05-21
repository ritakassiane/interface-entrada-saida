module main(
   input        i_Clock,
   input        i_Rx_Serial,
	inout			 dht_data_int,
   output 	    o_Tx_Active,
   output 		 o_Tx_Serial,
   output       o_Tx_Done
);
	wire 			 o_Rx_DV;
   wire [7:0]   o_Rx_Byte;
	wire [7:0]   o_request;
	wire [31:0]  o_interface;
	wire         o_data_int;
	wire   		 o_data_float;
	wire  		 o_done_i1;
	
uart_rx instrx(
	.i_Clock(i_Clock),
   .i_Rx_Serial(i_Rx_Serial),
   .o_Rx_DV(o_Rx_DV),
   .o_Rx_Byte(o_Rx_Byte)

);

selector inst_selec(
	.i_Clock(i_Clock),
	.i_Data(o_Rx_Byte),
	.i_Data_Done(o_Rx_DV),
	.o_request(o_request),
	.o_interface(o_interface)

);

interface2 i_dht11(
	.i_Clock(i_Clock),
	.i_En(o_interface[0]),
	.i_request(o_request),
	.dht_data_int(dht_data_int),
	.o_data_int(o_data_int),
	.o_data_float(o_data_float),
	.o_done_i1(o_done_i1)
);

pack_send inst_ps(
	.i_Clock(i_Clock),
	.i_en(o_done_i1),
	.i_data_one(o_data_int),
	.i_data_two(o_data_float),
	.o_Tx_Active(o_Tx_Active),
   .o_Tx_Serial(o_Tx_Serial),
   .o_Tx_Done(o_Tx_Done)
);


endmodule 
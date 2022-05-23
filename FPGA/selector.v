
/*
Modulo que recebe as duas entradas de 8 bits do RX e armazena temporariamente,
a depender da primeira entrada que é o endereço, este modulo irá ativar a interface
do sensor selecionado e passar a requesição pedida.
*/


module selector (
	input i_Clock,
	input [7:0] i_Data, // Dado do rx
	input i_Data_Done, // Entrada para saber que o RX terminou de receber um dado
	output [7:0] o_request, // Saida da requisição
	output [31:0] o_interface // Saída a qual o bit referente a interface a ser utilizada será ativada
);

				
reg [7:0] 		address		= 8'd0;
reg [7:0]		request		= 8'd0;
reg [1:0]		count			= 2'd0;
reg [31:0]		r_interface	= 31'd0;
reg				r_done = 1'b0;


assign o_request 		 = request;
assign o_interface    = r_interface;

always @(posedge i_Clock) begin
		if (i_Data_Done == 1'b1)begin //Se for o primeira dado é o byte de endereço 
			if (count == 2'b00)  begin
					address <= i_Data; // Armazena no reg de endereço
					count <= 2'b01;
					end
			 else if (count == 2'b01) begin // Se for o segundo dado é o byte de requisiçaõ 
					request <= i_Data; // Armazena no reg de requisição
					count <= 2'b00; // Zera-se o contador
					r_interface = 32'd0;
					if (address == 8'b00000000) begin // Se o endereço for 0 ativa a primeira interface (e unica até o momento)
						r_interface[0] <= 1'b1;
					end
			 end

		   end
		else begin
			r_interface <= 32'd0;
		end
end


endmodule 
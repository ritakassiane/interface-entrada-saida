# 📌Sistemas Digitais
O aumento da produtividade industrial utilizando cada vez menos recursos humanos é um dos principais frutos proporcionados pela 4ª revolução industrial. Nesse contexto, a exponencial evolução da tecnologia torna indubitável a necessidade por engenharia qualificada, capaz de maximizar a eficiência de processos utilizando, sobretudo, a prototipação de sistemas. 

Pensando nisso,


## 👥Equipe: <br>
* Paulo Queiroz de Carvalho <br>
* Rita Kassiane Santos  <br>
* Rodrigo Damasceno Sampaio <br>

<h1 align="center"> Sumário </h1>
<div id="sumario" style="display: inline_block" align="center">
	<a href="#diagrama"> Diagrama  </a> |
	<a href="#mapeamento"> Mapeamento de memória </a> |
	<a href="#configuracao"> Configurando a UART</a> |
	<a href="#enviando"> Enviando dado</a> |
	<a href="#teste"> Teste </a> |
	<a href="#executar"> Como executar </a> |
	<a href="#conclusao"> Conclusão </a>
</div>

<div id="diagrama">
	<h1> Diagrama </h1>
		<div id="image01" style="display: inline_block" align="center">
		<img src="/diagrama-do-sis.png"/>
		<p>
			Diagrama do sistema desenvolvido
			</p>
		</div>
	
</div>

<div id="uart-tx">
	<h1> Recebendo dados via UART através da FPGA </h1>
		<p>
		O módulo UART RX é responsável por implementar a recepção de dados na UART da FPGA. Ele possui duas entradas, duas saídas, e um parâmetro, sendo estes, 		respectivamente: 
		Clock: pulso de clock
		RX_Serial: Dado serial
		RX_Byte: Byte com os 8 bits recebidos
		Clock por bit: é necessário para que faça com que a UART da Raspberry e da FPGA funcionem na mesma frequência. Para definir o valor deste parâmetro 			calcula-se o  quociente entre a frequência da placa e o baud rate. [Frequência/Baud Rate = 50MHz/14400]). <br>
		Para realizar a sincronização entre essas duas entidades (Raspberry e FPGA), utiliza-se esse valor como parâmetro para controlar um contador que 		definirá se já é ou não possível identificar o bit que está sendo recebido. Nesse contexto, quando ocorre a variação de 3603 ciclos de clocks da placa, 		significa que já se consegue realizar tal identificação, ou seja, já houve tempo suficiente para que o bit tenha sido recebido. 
		</p>
		<p> Nesse módulo existe uma FSM que possui 5 estados:</p>
		<ul>
			<li> <strong>IDLE</strong>: <br>Tem a função de zerar todos os registradores. Nesse estado, uma estrutura condicional verifica se a entrada de dados 							RXData recebeu o bit 0 (que representa o Start Bit). Em caso afirmativo, a máquina vai para o próximo estado RX Start 							Bit. Em caso negativo, a máquina se mantém nesse estado até que essa situação ocorra. 
</li>
					<li>RX START BIT:
Nesse estado, o valor de um registrador que funciona como um contador é comparado com o valor do parâmetro Clock por bit definido anteriormente. Se o contador for diferente da quantidade de clocks por bits, ele é incrementado em um.  Essa comparação é realizada para que se possa garantir que a frequência entre as UARTs são iguais, e portanto, já é possível analisar o bit enviado. Posteriormente, quando o contador estiver alcançado o valor exato do clock por bit definido, outra estrutura condicional verifica se o valor do dado em rx_data é zero, em caso afirmativo significa que tudo ocorreu como previsto, o start bit foi recebido, portanto, o contador pode ser resetado e a máquina pode seguir para o próximo estado DATABITS. Caso a condicional seja falsa, algum erro ocorreu, logo, a máquina é levada para o estado de IDLE novamente. 
</li>
	<li>RX_DATA_BITS:
Nesse estado a lógica implementada é semelhante à explicitada no estado anterior. Enquanto não ocorre a quantidade de variações necessárias para a recepção de um bit (3603 ciclos de clock), um registrador que atua como contador é acrescido em 1. 
Sabendo que o dado que está sendo recebido tem o tamanho de 1 byte, cria-se um registrador chamado RX_Byte para armazenar este. A cada bit recebido - ou seja, a cada 3603 ciclos de clock - um registrador de 3 bits denonimado r_Bit_index é acrescido em 1, e este bit recebido é atribuido ao RX_Byte na posição indicada por r_Bit_index.
Para garantir que os 8 bits já foram recebidos, uma estrutura condicional verifica se r_Bit_index é menor que 7 (tamanho máximo que este pode assumir). Em caso afirmativo, os bits não foram todos recebidos, portanto, incrementa-se 1 ao index e a máquina de estados volta novamente para o estado de recepção de dados (RX_Data_Bits). Em caso negativo, atribui-se 0 ao index e a FSM segue para o estado de recepção do stop bit.

 </li>
	<li>RX STOP BIT
A lógica de funcionamento desse estado é semelhante ao RX START BIT. O valor de um registrador que funciona como um contador é comparado com o valor do parâmetro Clock por bit definido anteriormente. Se o contador for diferente da quantidade de clocks por bits, ele é incrementado em um até que essa igualdade ocorra. Posteriormente, quando o contador estiver alcançado o valor exato do clock por bit definido, atribui-se um nível lógico alto para o registrador Done, o contador pode ser resetado e a máquina pode seguir para o próximo estado CLEANUP. 
</li>
					<li>CLEANUP:
É responsável por enviar a máquina para o estado IDLE, e atribuir 0 para o registrador Done. 
</li>
		</ul>
</div>


<div id="uart-rx">
	<h1> Enviando dados via UART através da FPGA </h1>
	<p>
		O módulo UART TX é responsável por implementar a lógica de envio de dados na UART da FPGA.  Ele possui um parâmetro, três entradas e três saídas, sendo estes, respectivamente: 
		Clock por bit:
		Esse parâmetro existe neste módulo pelo mesmo motivo de estar presente no módulo de recepção. No entanto, este valor é utilizado para controlar um 			contador que definirá se já é ou não possível enviar o bit desejado.  Nesse contexto, quando ocorre a variação de 3603 ciclos de clocks da placa, 			significa que já se consegue realizar tal envio, ou seja, já houve tempo suficiente para que o bit tenha sido enviado. 
	</p>	
	<ul>
		<li>TX_DV: Identifica o momento em que a transmissão iniciará</li>
		<li>TX_Byte: Valor que será transmitido</li>
		<li>Clock</li>
		<li>output_TX_Active: Representa o momento em a transmissão está ocorrendo</li>
		<li>output_TX_Serial: O dado que está sendo enviado para raspberry </li>
		<li>output_TX_Done</li>
	</ul>
	<p> Nesse módulo existe uma FSM que possui 5 estados:</p>
	<ul>
		<li> <strong>IDLE</strong>: <br>
			Tem a função de zerar todos os registradores, exceto à saída TX_Serial, a qual tem nível lógico alto atribuído, para que quando a transmissão se inicie no estado posterior, seja possível reconhecer o Start BIt como 0. 
Nesse estado, uma estrutura condicional verifica se a entrada de dados TX_DV recebeu o bit 1. Em caso afirmativo, significa que irá iniciar uma transmissão de dados, portanto, atribui-se  o valor que deseja transmitir a um registrador denominado TX_DATA e a máquina segue para o estado de envio do Start Bit. Em caso negativo, a máquina se mantém no estado IDLE até que a situação descrita anteriormente ocorra. 
		</li>
		<li> <strong>RX START BIT</strong>: <br>
			Nesse estado, como se sabe que o start bit é 0, inicialmente atribui-se nível lógico baixo à saída TX_Serial. Posteriormente, o valor de um registrador que funciona como um contador é comparado com o valor do parâmetro Clock por bit definido anteriormente para garantir que o envio está sendo realizado sob a frequência necessária. Se o contador for diferente da quantidade de clocks por bits, ele é incrementado em um até que essa igualdade ocorra. Quando essa situação ocorrer, a FSM vai para o estado TX_DATA_BITS para envio de dados. 
		</li>
		<li> <strong>TX_DATA_BITS</strong>: <br>
			Inicialmente atribui-se à saída o_Tx_Serial o bit referente ao byte que deve ser enviado, o qual está localizado no index 0  (representado pelo registrador Bit_Index) do registrador de 8 bits TX_DATA. Enquanto não ocorre a quantidade de variações de clock necessárias para a envio de um bit, um registrador que atua como contador é acrescido em 1 e a máquina vai para o mesmo estado atual denominado TX DATA BITS. Quando o contador alcança 3603, significa que o primeiro bit já foi transmitido e, portanto, já é possível enviar o próximo bit. Para isso, o registrador que atua como contador é zerado e verifica-se se o Bit_index é menor que 7 (tamanho máximo que este pode assumir). Em caso afirmativo, os bits não foram todos enviados, portanto, incrementa-se 1 ao index e a máquina de estados volta novamente para o estado de transmissão de dados (RX_Data_Bits) para que possa enviar o bit da próxima posição. Em caso negativo, atribui-se 0 ao index e a FSM segue para o estado de envio do stop bit.
		</li>
		<li> <strong>TX STOP BIT</strong>: <br>
			Inicialmente, atribui-se nível lógico alto à saída TX_SERIAL, o qual representa o Stop Bit. Posteriormente, o valor de um registrador que funciona como um contador é comparado com o valor do parâmetro Clock por bit definido anteriormente. Se o contador for diferente da quantidade de clocks por bits, ele é incrementado em um até que essa igualdade ocorra. Posteriormente, quando o contador estiver alcançado o valor exato do clock por bit definido, atribui-se um nível lógico alto para o registrador Done (que irá representar que o a transmissão do byte está completa), nível lógico baixo para o registrador TX_Active (para sinalizar que não há transmissão ocorrendo), o contador pode ser resetado e a máquina pode seguir para o próximo estado CLEANUP. 
		</li>
		<li> <strong>CLEANUP</strong>: <br>
			É responsável por enviar a máquina para o estado IDLE, e atribuir 1 para o registrador Done. 
		</li>
	</ul>
</div>

<div id="selector">
	<h1> Enviando e Recebendo dados </h1>
	<p>
	Antes de enviar o dado, deve-se verificar se o FIFO está cheio. Para isso utiliza-se o bit denominado TXFF do registrador Flag. Posteriormente, move-se a sequência de bits que deve ser enviada em um registrador e escreve este valor no endereço do registrador UART_DATA. 
	Para verificar se o dado enviado foi recebido, utiliza-se o bit RXFF do Flag Register para verificar se o FIFO está vazio ou não.
	</p>
</div>

<div id="dht11">
	<h1> Enviando e Recebendo dados </h1>
	<p>
	Antes de enviar o dado, deve-se verificar se o FIFO está cheio. Para isso utiliza-se o bit denominado TXFF do registrador Flag. Posteriormente, move-se a sequência de bits que deve ser enviada em um registrador e escreve este valor no endereço do registrador UART_DATA. 
	Para verificar se o dado enviado foi recebido, utiliza-se o bit RXFF do Flag Register para verificar se o FIFO está vazio ou não.
	</p>
</div>

<div id="interface">
	<h1> Enviando e Recebendo dados </h1>
	<p>
	Antes de enviar o dado, deve-se verificar se o FIFO está cheio. Para isso utiliza-se o bit denominado TXFF do registrador Flag. Posteriormente, move-se a sequência de bits que deve ser enviada em um registrador e escreve este valor no endereço do registrador UART_DATA. 
	Para verificar se o dado enviado foi recebido, utiliza-se o bit RXFF do Flag Register para verificar se o FIFO está vazio ou não.
	</p>
</div>


<div id="teste">
	<h1>Testes</h1>
	<div id="image01" style="display: inline_block" align="center">
			<img src="/MAP001.jpg"/><br>
		<p>
		Dado: 11001010
		8 Bts
		2 SB
		Paridade: Par
		</p>
	</div>
	<div id="image02" style="display: inline_block" align="center">
		<img src="/MAP002_1.jpg"/><br>
		<p>
		Dado: 11001010;
		8 bts;
		2 SB
		Paridade: Par;
		Parity Disable;
		</p>
	</div>
	<div id="image03" style="display: inline_block" align="center">
		<img src="/MAP003.jpg"/><br>
		<p>
		Dado: 11001010;
		8 bts;
		2 SB;
		Paridade: Impar		
		</p>
	</div>
	<div id="image04" style="display: inline_block" align="center">
		<img src="/MAP004.jpg"/><br>
		<p>
		Dado: 11001010;
		8 bts;
		1 SB;
		Paridade: Par		
		</p>
	</div>
	<div id="image05" style="display: inline_block" align="center">
			<img src="/MAP005.jpg"/><br>
		<p>
		Dado: 11001010;
		7 bts;
		1 SB;
		Paridade: Par
		</p>
	</div>
		<div id="image06" style="display: inline_block" align="center">
			<img src="/MAP006.jpg"/><br>
		<p>
		Dado: 11001010;
		6 bts;
		1 SB;
		Paridade: Par	
		</p>
	</div>
		<div id="image08" style="display: inline_block" align="center">
			<img src="/MAP008.jpg"/><br>
		<p>
		Dado: 00110101
		8 bts;
		2 SB;
		Paridade: Par	
		</p>
	</div>
	<div id="image09" style="display: inline_block" align="center">
		<img src="/MAP009.jpg"/><br>
		<p>
		Dado: 01110101
		8 bts;
		2 SB;
		Paridade: Par	
		</p>
	</div>
	<div id="image10" style="display: inline_block" align="center">
		<img src="/MAP010.jpg"/><br>
		<p>
		Dado: 11001010
		8 bts;
		2 SB;
		Baud Rate: 14400 Hz
		I = 212
		F = 63
		Paridade: Par	
		</p>
	</div>
	<div id="image11" style="display: inline_block" align="center">
		<img src="/MAP011.jpg"/><br>
		<p>
		Dado: 11001010
		8 bts;
		2 SB;
		Baud Rate: 76800 Hz
		I = 40
		F = 0
		Paridade: Par	
		</p>
	</div>
	<div id="image11" style="display: inline_block" align="center">
		<img src="/MAP012.jpg"/><br>
		<p>
		Dado: 11001010
		8 bts;
		2 SB;
		Baud Rate: 38400 Hz
		I = 79
		F = 63
		Paridade: Par	
		</p>
	</div>
</div>

<div id="executar">
	<h1>Como executar</h1>
		<p>
		Os arquivos base do códgio assembly encontra-se no caminho diretório (/pbl-sistemas-digitais/PBL/) e são denominados:
		</p>
		<ul>
			<li>uartConfig.s</li>
			<p>Arquivo principal o qual é usado para a configuração da UART</p>
		</ul>
		<ul>
			<li>uartDateL.s</li>
			<p>Arquivo de envio de dado e teste de loopback</p>
		</ul>
		<ul>
			<li>uartDateO.s</li>
			<p>Arquivo que implementa um loop de envio de dados para serem visualizados via osciloscópio</p>
		</ul>
		<ul>
			<li>macros.s</li>
			<p>Arquivo que implementa um macro de impressão na tela (print) para a utilização em outras partes do sistema</p>
		</ul>
		<p>
			Para executar o produto desenvolvido, utiliza-se o arquivo makefile. 
			Para isso, dentro de um terminal linux, abra o diretório que contém os arquivos bases mencionados anteriormente e execute os seguinte comando:
		<ul>
			<li>make all</li>
			<p>Cria o executável</p>
		</ul>
		<ul>
			<li>sudo ./UartDateL</li>
			<p>Executa o programa</p>
		</ul>
		</p>
</div>
<div id="conclusao">
	<h1>Conclusão</h1>
	<p>
	Para atingir o objetivo solicitado neste problema foi necessário entender o conceito de mapemento de memória e o implementar, a fim de obter o endereço de memória virtual e consequentemente conseguir acessar a UART. Posteriormente a isso foi possível configura-la a partir das necessidades apontadas como requisitos do sistema, e enviar um dado de acordo com o padrão RS232.
	</p>
	<p>
Além disso, o protótipo do sistema auxiliou os graduandos em Engenharia da Computação na solidificação do conhecimento a cerca da arquitetura ARM e conceitos base da linguagem Assembly, como: principais mnemônicos, estruturas condicionais e estruturas de repetição.
	</p>
	<p>
O problema solucionado cumpre <strong>todos</strong> os requisitos solicitados, e foi desenvolvido utilizando Raspberry Pi Zero além de ter sido devidamente testado através da verificação do dado enviado utilizando o osciloscópio e teste de loopback.
	</p>
</div>

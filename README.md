# 📌Sistemas Digitais
<p>
O aumento da produtividade industrial utilizando cada vez menos recursos humanos é um dos principais frutos proporcionados pela 4ª revolução industrial. Nesse contexto, a exponencial evolução da tecnologia torna indubitável a necessidade por engenharia qualificada, capaz de maximizar a eficiência de processos utilizando, sobretudo, a prototipação de sistemas. 

Pensando nisso, uma empresa contratou uma equipe de engenheiros da computação em formação, para o desenvolvimento de um protótipo de sistema digital capaz de monitorar 32 sensores. O produto implementado consiste em um sistema comandado por um Single Board Computer (SBC), o qual controla o acionamento de um conjunto variáveis de sensores, assim como monitora o seu seu estado de funcionamento de forma automatizada. Cada operação de pode ser representada por um código o qual é interpretado por um driver UART. 
</p>

<h1>  👥Equipe: <br></h1>
<uL> 
	<li>Paulo Queiroz de Carvalho <br></li>
	<li>Rita Kassiane Santos  <br></li>
	<li>Rodrigo Damasceno Sampaio <br></li>
</ul>

<h1 align="center"> Sumário </h1>
<div id="sumario">
	<ul>
		<li><a href="#diagrama"> Diagrama</li>
		<li><a href="#recursos"> Recursos  </a></li>
		<li><a href="#raspberry"> Configurando, enviado e recebendo dados na Raspberry Pi Zero </a> </li>
		<li><a href="#uart-rx"> Recebendo dados via UART através da FPGA </a></li>
		<li><a href="#uart-tx"> Enviando dados via UART através da FPGA </a> </li>
		<li><a href="#selector"> Selecionando endereço e requisição </a> </li>
		<li><a href="#dht11"> Recebendo dados do sensor </a> </li>
		<li><a href="#interface"> Filtrando requisição para obter dado solicitado  </a> </li>
		<li><a href="#pins-les"> Pins e LE's </a> </li>
		<li><a href="#executar"> Como executar </a></li>
		<li><a href="#conclusao"> Conclusão </a> </li>
	</ul>	
</div>
<div id="recursos">
	<h1> Recursos </h1>
	<ul>
		<li>Kit de desenvolvimento Mercúrio IV</li>
		<li>FPGA Cyclone IV</li>
		<li>Raspberry Pi Zero<V/li>
	</ul>
	
</div>

<div id="diagrama">
	<h1> <a href="https://www.figma.com/proto/MKDfCcjhxhD78d0mm3sMHW/Diagrama_Problema02?node-id=103%3A218&scaling=contain&page-id=0%3A1&starting-point-node-id=103%3A218" target="_blank">Diagrama</a>  </h1>
		<div id="image01" style="display: inline_block" align="center">
		<img src="images/Diagrama01.png"/>
		<p>
			Diagrama geral do sistema desenvolvido
		</p>
		</div>
		<div id="image02" style="display: inline_block" align="center">
		<img src="images/diagrama02.png"/>
		<p>
			Diagrama do sistema desenvolvido
		</p>
		</div>
	
</div>
<div id="raspberry">
	<h1> Configurando, enviado e recebendo dados na Raspberry Pi Zero </h1>
	<p> 
		Para a implementação deste módulo, cria-se funções do código desenvolvido no <a href="https://github.com/ritakassiane/pbl-sistemas-digitais"> Problema 01</a>, sendo estas:	
	</p>
	<ul>
		<li>uartConfig: tem a função de realizar a configuração da UART. Esta recebe 3 parâmetros que são referentes a <a href="https://github.com/ritakassiane/pbl-sistemas-digitais#configuracao">UART_LCRH, UART_IBRD, UART_FBRD</a> </li>
		<li>uartSendData: responsável pelo envio de dados. Recebe como parâmetro o dado que deve ser enviado. No entanto, é válido ressaltar que esta função não trata a possibi,brade do parametro enviado ter tamanho maior que 8 bits. Portanto, caso isso ocorra, será enviado apenas os 8 bits menos significativos do dado a ser enviado. </li>
		<li>uartReciveData: recebe o dado. Realiza a leitura de todos os bits do registrador UART DATA. </li>
	</ul>
	<h2>Enviando requisição da Raspberry para a FPGA</h2>
	<p>
		Inicialmente, o programa utiliza os valores das variáveis UART LCRH, UART_IBRD E UART_FBRD pré-definidos pelo programador como parâmetros da função que configura a Uart.  <br>
	Posteriormente, inicia-se a interação com o usuário a qual solicita a este qual requisição ele gostaria de saber (Medida de umidade, medida de temperatura ou estado atual do sensor) e qual o número de identificação do sensor que este deseja (apenas permitidos valores entre 0 e 31). Depois, é enviado, respectivamente, o endereço e a requisição para  o pino TX da Raspberry, o qual está ligada ao pino RX da FPGA. 
	</p>
	<h2>Leitura da resposta da FPGA</h2>
	<p>
			Seguidamente, os dados recebidos no pino RX da Raspberry são lidos e inicialmente analisa se este tem um tamanho maior que 255. Em caso afirmativo, significa que ocorreu a leitura das flags de erro que o registrador UART_DR armazena, portanto, há algum erro no recebimento do dado. Com isso, o programa informa qual o valor deste erro (No entanto, deve-se buscar na documentação da UART qual erro este valor representa). 
	Se não houver problema de comunicação, verifica-se se o dado é maior que 127. Isso representa uma decisão de arquitetura do projeto, a qual define que o primeiro bit do sinal recebido da FPGA indica se houve erro ou não. Ou seja, se esse valor recebido for 1, o número binário referente será maior que 127 (11111111). 
	Caso nenhuma dessas implicações ocorram, significa que o dado foi recebido com sucesso e este é exibido na tela de acordo com o que foi solicitado. 
	</p>
	
	
</div>
<div id="uart-rx">
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


<div id="uart-tx">
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
	<h1>Selecionando endereço e requisição</h1>
	<p>
		Este módulo tem como principal função permitir que dado uma requisição ou um endereço (ambos com 8 bits), seja possível selecionar um dos 32 sensores possíveis. Para isso existem 3 entradas e 2 saídas, as quais são representadas por, respectivamente:
	</p>	
	<ul>
		<li> i_Clock: pulso de clock</li>
		<li> i_Data: entrada de 8 bits a qual representa a saída com os dados do módulo RX de recepção de dados.</li>
		<li> i_Data_Done: </li>
		<li> o_request: saída que contém a requisição</li>
		<li>o_interface:  saída que é um registrador de 32 bits. Cada bit deste representa um sensor. Neste problema, os desenvolvedores consideram a existencia de apenas 1 sensor, o qual esta localizado no index 0 deste registrador.  </li>
	</ul>
	<p>
		Os desenvolvedores deste projeto definiram que o primeiro dado recebido por este módulo é o endereço do sensor requisitado. Por isso, cria-se um contador de 2 bits, o qual quando for zero representa a recepção do endereço, portanto, armazena-se o dado recebido no registrador address e incrementa 1. Quando o contador for 1, o valor da recepção agora é atribuido ao registrador request, que representa a requisição. Posteriormente, verifica-se o endereço recebido é um byte de 0 (que representa o único sensor com interface implementada), e em caso afirmativo, atribui-se nível lógico alto à posição 0 da saída o_interface, indicando que a solicitação do usuário refere-se à este sensor.
	</p>
</div>

<div id="dht11">
	<h1> Recebendo dados do sensor </h1>
	<p>
		Uma máquina de estados controla o funcionamento do sensor DHT11, e tem o ínicio de sua execução quando este módulo recebe nível alto lógico no pino de entrada denominado Enable.
		Posteriormente, verifica se a entrada de RST não está ativa. Em caso afirmativo, entra-se no estado START. Caso RST receba nível lógico alto, a máquina deve ser resetada e depois enviada para o estado de START.
		A FSM possui 12 estados. Sendo esses:
	</p>
	<ul>
		<li>START: Irá indicar o estado da máquina como ocupado e a direção do pino birecional como saída de dados. Posteriormente, segue-se para o estado S0.
</li>
		<li>S0: Consultando a documentação do DHT11, é possível inferir que para sinalizar para este sensor que deseja-se inicializar uma aquisição de dados, deve-se setar o pino DHT_DATA como nível lógico alto, posteriormente, coloca-se este em nível lógico baixo por 18ms e seguidamente, coloca-se em nivel logico alto novamente. 
Por esse motivo, o estado S0 possui um contador, o qual, depois que alcança 900.000 ciclos de clock, envia a máquina para o próximo estágio.
[imagem da documentacao]
 </li>
		<li>S1: Nesse estado, seta-se DHT_DATA como 0, altera a direção do pino (que antes era de envio e agora será de recepção de dados) e novamente, aguarda-se 18ms e posteriormente, envia-se para o estado S2
Simboliza a borda de descida do sinal em que o SBC envia para o sensor, espera por mais 900000 clocks, e segue para o próximo estágio.
 </li>
		<li>
S2: Aguarda 20us ou 1000 ciclos de clock (tempo de resposta do sensor) e em seguida, deta DHT_DATA como nivel logico alto, para indicar a direção de entrada de dados. Posteriormente, a FSM vai para o estagio S3. </li>
		<li>S3: Enquanto o contador não alcança a marca de 60us e e o pino de entrada de dados do sensor estiver alto, a maquina se mantem nesse estado. Se esse tempo for excedido e o pino de entrada não mudar para nivel lógico baixo, sinaliza-se um erro. Caso contrário, segue-se para o estado S4. </li>
		<li>S4: A FSM se mantém nesse estado enquanto não ocorre 4400 ciclos de clock (80us), o qual equivale ao tempo para o pulso de sincronismo acontecer. Caso este sinal seja recebido, segue para o próximo estágio. </li>
		<li>S5: Estado que simboliza o tempo de espera em que aguardamos para o sensor nos enviar o seu pulso de sincronismo, neste caso, a borda de descida. Aguardamos por 4400 ciclos de clock. Caso o sinal de sincronismo ainda esteja alto, segue para o estado de erro. Caso ele já esteja baixo, segue para o próximo estado. </li>
		<li>S6: Se o sinal do sensor DHT11 estiver baixo, segue para o próximo estado. Caso seja alto, vá para o estado de erro. </li>
		<li>S7: Espera o sinal de dados do DHT11 por 1600000 ciclos de clock, caso esse contador chegue ao fim, vá para o estado de erro. Se chegou algum sinal do DHT11, vá para o próximo estado. </li>
		<li>S8: Estado que simboliza a decisão entre 0 e 1 do sinal que chega do DHT11, e o insere em sua posição correta (40 bits). Também verifica se nenhum bit chegou, nesses casos, segue para o estado de erro. Caso o contador ainda seja menor que 39 (número de bits que o DHT11 envia, começando do Bit 0), vá para o estado S9. Caso seja maior ou igual a 39, segue para o estado de erro. </li>
		<li>
S9: Soma 1 ao contador que indica qual posição do Bit e segue para o estado S6. </li>
	</ul>
</div>

<div id="interface">
	<h1>  Filtrando requisição para obter dado solicitado </h1>
	<p>
	Neste projeto utilizou-se o sensor DHT11 o qual tem a capacidade de medir a temperatura e umidade do ambiente.
	Para filtrar o dado solicitado pelo usuário e requisitar o sensor existente no sistema, foi desenvolvido o módulo denominado interface, o qual tem como função principal instanciar o módulo DHT11, pegar a saída deste e tratar, retornando apenas o dado referente ao que a solicitação pede. 
	</p>
	<p>
	Nesse módulo, existe uma máquina de estados que possui 3 estados, sendo esses:
	</p>
	<ul>
		<li><strong>IDLE:</strong> 
			<p>Verifica se o DHT11 está ativo - ou seja, se o ENABLE do módulo DHT11 instanciado é nível lógico alto -. EM caso afirmativo, envia a FSM para o estado de leitura denominado READ. Posteriormente, atribui-se nível lógico alto para a entrada Reset do módulo DHT11. </p>
		</li>
		<li><strong>READ:</strong> 
			<p>
				 Nesse estado, é verificado se a saída DONE do módulo DHT11 é nível lógico alto - fator que indica que a leitura ja ocorreu -. Em caso afirmativo, uma estrutura condicional analisa a requisição para conseguir definir se esta solicita umidade ou temperatura, e a partir disso, atribui-se ao registrador data_int a parte inteira, e a data_float a parte fracionada.
				Posteriormente, a máquina é enviada para o estado de RESET.
			</p>
		</li>
		<li><strong>RESET:</strong> 
			<p> Este estado existe para atribuir nível lógico alto a DONE e RESET, o que indicará que o armazenamento do dado fornecido pelo DHT11 ocorreu. Seguidamente, o estado da máquina é alterado para SEND.</p>
		</li>
		<li><strong>SEND:</strong> 
			<p> Altera a saída DONE para nível lógico alto e envia a FSM para o estado FINISH </p>
		</li>
		<li><strong>FINISH:</strong> 
			<p> Atribui-se nível lógico baixo para DONE e Enable do módulo DHT11, e envia a máquina de estados para o estado de IDLE novamente.</p>
		</li>
	</ul>
</div>
<div id="pins-les">
	<h1> LEs, LABs e Pinos</h1>
	<div id="image01" style="display: inline_block" align="center">
			<img src="images/pins-les.jpeg"/><br>
	</div>
</div>
	
<div id="executando">
	<h1> Programa em execução</h1>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/01.png"/><br>
		<p>
			Tela de seleção de ações possíveis	
		</p>
	</div>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/02.png"/><br>
		<p>
			Selecionar sensor	
		</p>
	</div>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/03.png"/><br>
		<p>
			Estado atual do sensor	
		</p>
	</div>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/04.png"/><br>
		<p>
			Temperatura medida pelo sensor	
		</p>
	</div>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/05.png"/><br>
		<p>
			Umidade medida pelo sensor	
		</p>
	</div>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/06.png"/><br>
		<p>
			Temperatura medida pelo sensor	
		</p>
	</div>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/09.png"/><br>
		<p>
			Selecionando um sensor inexistente
		</p>
	</div>
	<div id="image01" style="display: inline_block" align="center">
		<img src="images/10.png"/><br>
		<p>
			Erro na recepção de dados
		</p>
	</div>
</div>

<div id="executar">
	<h1>Como executar</h1>
                <p>
                    Para a execução deste produto é necessário dos itens listados na <a href="#recursos">seção de recursos</a>. Com isso, realiza a pinagem, compila e descarrega o código na pasta FPGA na placa, posteriormente, liga-se o pino TX da raspberry no RX da FPGA, e o pino RX da mesma no TX. 
Seguidamente, abrindo o terminal no diretório Rasp, executa-se: 
<br>
make all
<br>
Este comando irá gerar o executável PBLSensores, o qual deve ser executado. 
		</p>
</div>
<div id="conclusao">
	<h1>Conclusão</h1>
	<p>
	Para atingir o objetivo solicitado neste problema foi necessário compreender conceitos da programação em Verilog e integrar código assembly e C, a fim de solidificar o entendimento dos conceitos básicos a cerca de protocolos de comunicação serial.
	Além disso, o problema solucionado cumpre <strong>todos</strong> os requisitos solicitados, e foi desenvolvido utilizando Raspberry Pi Zero e FPGA Cyclone IV, além de ter sido devidamente testado através da verificação do dado enviado e recebido utilizando o osciloscópio.
	</p>
</div>

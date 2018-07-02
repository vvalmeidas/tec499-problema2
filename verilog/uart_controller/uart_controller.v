module uart_controller (clk, rst, controls, rx, rts, empty, data_out, read);

	//controls(paridade, quantidade de bits de dados, stop bits...) PIO de output do Nios (Nios informa) - configuração
	//do modo de operação da uart 
	
	//empty input do Nios (verifica se tem dados na fifo)
	
	//data_out input do Nios
	
	//read é output do Nios (tem que dar um pulso no read para ler o data_out)

	input clk;
	input rst;
	input [7:0] controls;
	input rx;
	input rts;
	input read;
	
	output       empty;
	output [7:0] data_out;
	
	wire clk7200;
	wire clk9600;
	wire clk19200;
	wire clk115200;
	
	wire clkUart;
	wire [3:0] amountBits;
	
	wire [7:0] data;
	wire ready;
	wire error;
	
	mux4_1 mux4_1(
		.a(clk7200),
		.b(clk9600),
		.c(clk19200),
		.d(clk115200),
		.sel(controls[7:6]),
		.out(clkUart)
	);
	
	fifo_controller fifo_controller(
		.clk(clk), 
		.rst(rst), 
		.rx_ready(ready), 
		.data(data),
		.empty(empty), 
		.data_out(data_out), 
		.read(read)
	);
	
	mux4_1_4bits mux4_1_4bits(
		.a(4'd5),
		.b(4'd6),
		.c(4'd7),
		.d(4'd8),
		.sel(controls[3:2]),
		.out(amountBits)
	);
	
	uart_rx uart_rx(
		.clk(clkUart),
		.rst(rst),
		.rx(rx),
		.amountBits(amountBits),
		.parity(controls[0]),
		.even(controls[1]),
		.handshake(controls[4]),
		.stop(controls[5]),
		.data(data),
		.ready(ready),
		.rts(rts),
		.error(error)
		);
	
	baud_7200_generator baud_7200_generator(
		.clk_in(clk),
		.rst(rst),
		.clk_out(clk7200)
	);
	
	baud_9600_generator baud_9600_generator(
		.clk_in(clk),
		.rst(rst),
		.clk_out(clk9600)
	);
	
	baud_19200_generator baud_19200_generator(
		.clk_in(clk),
		.rst(rst),
		.clk_out(clk19200)
	);
	
	baud_115200_generator baud_115200_generator(
		.clk_in(clk),
		.rst(rst),
		.clk_out(clk115200)
	);
	
endmodule
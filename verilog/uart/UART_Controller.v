module UART_Controller(clk, rst, rx, led);
	
	input clk;
	input rst;
	input rx;
	
	output [3:0] led;
	
	wire clk_9600;
	wire [7:0] data;
	wire ready;
	
	
	assign led = ~data[3:0];
	
	clk_divider clk_divider (
		.clk_in(clk),
		.rst(~rst),
		.clk_out(clk_9600)
	);
	
	uart_rx uart_rx (
		.rx(rx),
		.rst(~rst),
		.clk(clk_9600),
		.data(data),
		.ready(ready)
		);
	
endmodule
module uart_rx(rx, rst, clk, data, ready);
	
	input rx;
	input clk;
	input rst;
	
	output reg [7:0] data;
	output reg ready;
	
	reg [3:0] counter;
	reg [7:0] dataA;
	
	reg [1:0] state;
	
	localparam idle= 2'b00, receving = 2'b01, done = 2'b11; 
	
	always @ (posedge clk) begin
			if (rst) begin
				state <= idle;
				ready <= 1'b0;
				data  <= 8'd0;
			end else begin
				case (state)
					idle:begin
						ready <= 1'b0;
						if (!rx) begin
							state   <= receving;
							counter <= 4'd0;
						end else begin
							state <= idle;
						end
					end
					receving:begin
						if (counter == 4'd8) begin
							state <= done;
						end else begin
							dataA[counter] <= rx;
							counter <= counter + 1'd1;
							state <= receving;
						end
					end
					done:begin
						ready <= 1'b1;
						state <= idle;
						data <= dataA;
					end
				endcase
			end
	end
	
endmodule
module uart_rx(rx, rst, clk, data, ready, ready_word, number_received_words);
	
	input rx;
	input clk;
	input rst;
	
	output reg [31:0] data;
	output reg ready;
	output reg ready_word;
	output reg [10:0] number_received_words;
	
	
	reg [3:0] counter;
	reg [1:0] counter_received_bytes = 2'd0;
	reg [10:0] counter_received_words = 11'd0;
	reg [7:0] dataA;
	
	reg [1:0] state;
	
	localparam idle= 2'b00, receving = 2'b01, store=2'b10, done = 2'b11; 
	localparam first_address = 14'h1;
	
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
							state <= store;
						end else begin
							dataA[counter] <= rx;
							counter <= counter + 1'd1;
							state <= receving;
						end
					end
					
					store:begin
						if(counter_received_bytes == 2'd0) begin
							data[7:0] <= dataA;
							counter_received_bytes <= counter_received_bytes + 11'd1;
							ready_word <= 1'b0;
						end else if(counter_received_bytes == 2'd1) begin
							data[15:8] <= dataA;
							counter_received_bytes <= counter_received_bytes + 11'd1;
							ready_word <= 1'b0;
						end else if(counter_received_bytes == 2'd2) begin
							data[23:16] <= dataA;
							counter_received_bytes <= counter_received_bytes + 11'd1;
							ready_word <= 1'b0;
						end else if(counter_received_bytes == 2'd3) begin
							data[31:24] <= dataA;
							data <= {data_1, data_2};
							number_received_words <= number_received_words + 11'd1;
							counter_received_bytes <= 11'd0;
							ready_word <= 1'b1;
						end
						
						state <= done;
					end
					
					done:begin
						ready <= 1'b1;
						state <= idle;
					end
				endcase
			end
	end
	
endmodule

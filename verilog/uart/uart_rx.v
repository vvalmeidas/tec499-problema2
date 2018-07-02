module uart_rx(clk, rst, rx, amountBits, parity, even, handshake, stop, data, ready, rts, error);

	input clk;
	input rst;
	input rx;
	input [3:0] amountBits;
	input parity;
	input even;
	input handshake;
	input stop;
	input rts;
	
	output reg [7:0] data;
	output reg ready;
	output reg error;
	
	reg received_parity;
	
	localparam idle = 3'd0, receiving = 3'd1, checking = 3'd2, done = 3'd3, failed = 3'd4;
	
	reg [2:0] state;
	reg [3:0] counter;
	
	always @ (posedge clk) begin
		if (rst)begin
			state           <= idle;
			counter         <= 4'd0;
			received_parity <= 1'b0;
			ready           <= 1'b0;
			data            <= 8'd0;
			error           <= 1'd0;
		end else begin
			case (state)
				idle:begin
					ready           <= 1'b0;
					received_parity <= 1'b0;
					counter         <= 4'd0;
					error           <= 1'b0;
					if (!rx) begin
						state <= receiving;
					end else begin
						state <= idle;
					end
				end
				receiving:begin	
					if (counter == (amountBits+stop+parity+1'b1))begin
						if (parity)
							state <= checking;
						else
							state <= done;
					end else if (counter < amountBits) begin
						data[counter] <= rx;
						counter <= counter + 4'd1;
						state   <= receiving;
					end else if (parity == 1'd1 && (counter < amountBits + parity)) begin
						counter <= counter + 4'd1;
						state   <= receiving;
						received_parity <= rx;
					end else begin
						counter <= counter + 4'd1;
						state   <= receiving;
					end
				end
				checking:begin
					if(even == 1'b1) begin //se a paridade for par
						if(received_parity == ^data) begin
							state <= done;
						end
						else begin
							state <= failed;
						end
					end
					else if(even == 1'b0) begin //se a paridade for ímpar
						if(received_parity == ~^data) begin
							state <= done;
						end
						else begin
							state <= failed;
						end
					end
				end
				failed:begin
					error <= 1'b1; 
				end
				done:begin
					ready <= 1'b1;
					error <= 1'b1;
					state <= idle;
				end
			endcase
		end
	end
endmodule
module fifo_controller(clk, rst, rx_ready, data, empty, data_out, read);

input 		clk;
input 		rst;
input 		rx_ready;
input [7:0] data;
input 		read;

output 			empty;
output [7:0] 	data_out;

reg wrreq;
reg [1:0] state;

reg rdreq;
reg [1:0] state_2;

localparam a=2'd0, b=2'd1, c=2'd2;

always@(posedge clk) begin
	if(rst) begin
		state <= a;
		wrreq <= 1'd0;
	end
	else begin
		case(state)
			a: begin
				wrreq <= 1'd0;
				if(rx_ready) begin
					state <= b;
				end
				else begin
					state <= a;
				end
			end
			
			b: begin
				wrreq <= 1'b1;
				state <= c;
			end
			c: begin
				wrreq <= 1'd0;
				if(rx_ready) begin
					state <= c;
				end
				else begin
					state <= a;
				end
			end
		endcase
	end
end


always@(posedge clk) begin
	if(rst) begin
		state_2 <= a;
		rdreq <= 1'd0;
	end
	else begin
		case(state_2)
			a: begin
				rdreq <= 1'd0;
				if(read) begin
					state_2 <= b;
				end
				else begin
					state_2 <= a;
				end
			end
			
			b: begin
				rdreq <= 1'b1;
				state_2 <= c;
			end
			c: begin
				rdreq <= 1'd0;
				if(read) begin
					state_2 <= c;
				end
				else begin
					state_2 <= a;
				end
			end
		endcase
	end
end


	fifo	fifo(
		.clock(clk),
		.data(data),
		.rdreq(rdreq),
		.wrreq(wrreq),
		.empty(empty),
		.q(data_out),
		.usedw()
	);

endmodule





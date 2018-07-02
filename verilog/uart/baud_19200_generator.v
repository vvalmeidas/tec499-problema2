module baud_19200_generator(clk_in, rst, clk_out);

	input clk_in;
	input rst;
	
	output reg clk_out;
	
	reg [10:0] counter;
	
	always @ (posedge clk_in) begin
		if (rst) begin
			clk_out <= 1'b0;
		end else begin
			if (counter > 11'd1302) begin
				clk_out <= ~clk_out;
				counter <= 11'd0;
			end else begin
				counter <= counter + 11'd1;
			end
		end
	end
	
endmodule
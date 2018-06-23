module divisor(clk_50mhz,rst_50mhz,clk_out);

// generate 100 Hz from 50 MHz
input clk_50mhz, rst_50mhz;
output clk_out;
reg[17:0] count_reg = 0;
reg out_100hz = 0;

always @(posedge clk_50mhz or posedge rst_50mhz) 
begin
    if (rst_50mhz) 
		begin
        count_reg <= 0;
        out_100hz <= 0;
		end 
	else 
		begin
        if (count_reg < 70000) 
				begin
					count_reg <= count_reg + 1;
				end 
		  else 
			  begin
					count_reg <= 0;
					out_100hz <= ~out_100hz;
			  end
		end
end
assign clk_out = out_100hz;
endmodule

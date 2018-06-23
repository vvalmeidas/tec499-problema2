
module	Escritor_LCD(
			//------------------------------------------------------------------
			//	Clock & Reset Inputs
			//------------------------------------------------------------------
			Clock,
			Reset,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Inputs
			//------------------------------------------------------------------
			Inicializado,
			Entrada,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Outputs
			//------------------------------------------------------------------
			Estado,
			Enable,
			RS,
			RW,
			Contador,
			Dados
			//------------------------------------------------------------------
	);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	reg	[27:0]	contador_delay = 28'd0;
	reg 	[27:0]	contador_delay_temp;
	reg	[10:0]	byte = 8;
	reg 	[10:0]	index;
	reg 	[10:0]	index_temp;
	reg	[63:0] 	entrada = "ABCDEFGH";
										
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Clock & Reset Inputs
	//--------------------------------------------------------------------------
	input					Clock;	// System clock
	input					Reset;	// System reset
	input					Inicializado; //Indica se o display foi inicializado
	input		[63:0]	Entrada;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Inputs
	//--------------------------------------------------------------------------
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Outputs
	//--------------------------------------------------------------------------
	output	[1:0]		Estado;
	output			 	Enable;
	output				RS;
	output				RW;
	output				Contador;
	output	[7:0]		Dados;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Estado Encoding
	//--------------------------------------------------------------------------
	
	// place state encoding here
	
	//--------------------------------------------------------------------------

	parameter [1:0] 	WAIT_30MS = 2'b00,
							WRITE = 2'b01,
							WAIT_153MS = 2'b10,
							FINISH = 2'b11;
							
	
	//--------------------------------------------------------------------------
	//	Wire Declarations
	//--------------------------------------------------------------------------
	
	reg[1:0]	estado, proximo;
	reg[7:0] dados;
	reg		enable, rs;
	
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Logic
	//--------------------------------------------------------------------------
	
	always @(posedge Clock or negedge Reset) begin
		if(!Reset) begin
			estado <= WAIT_30MS;
		end
		else begin
			index <= index_temp;
			contador_delay <= contador_delay_temp;
			estado <= proximo;
		end
	end

	always @(estado) begin
		case(estado)
			WAIT_30MS: begin
				enable = 1'b1;
				rs = 1'b0;
				dados = 8'b00000000;
				
				if(contador_delay == 28'd8000000) begin		
					index_temp = 63;
					proximo = WRITE;
				end else begin
					contador_delay_temp = contador_delay + 1'd1;
					proximo = WAIT_30MS;
				end 
			end

			WRITE:	begin
				enable = 1'b0;
				rs = 1'b1;
			
				dados = entrada[index -: 8];
				
				index_temp = index - byte;
				contador_delay_temp = 28'd0;
				proximo = WAIT_153MS;
			end
			
			
			WAIT_153MS: begin
				enable = 1'b1;
				rs = 1'b0;				
				index_temp = index;

				if($signed(index) == $signed(-1)) begin
					proximo = FINISH;
				end
				else begin
					if(contador_delay == 28'd20000000) begin
						proximo = WRITE;
					end else begin
						contador_delay_temp = contador_delay + 1'd1;
						proximo = WAIT_153MS;
					end 
				end
			end
			
			FINISH:	begin
				enable = 1'b1;
				rs = 1'b0;
				proximo = FINISH;
			end
			
		endcase
	end

	assign Estado = ~estado;
	assign Enable = enable;
	assign Dados = dados;
	assign RW = 1'b0;
	assign RS = rs;

	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------

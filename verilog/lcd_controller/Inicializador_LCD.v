
module	Inicializador_LCD(
			//------------------------------------------------------------------
			//	Clock & Reset Inputs
			//------------------------------------------------------------------
			Clock,
			Reset,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Inputs
			//------------------------------------------------------------------
			Modo,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Outputs
			//------------------------------------------------------------------
			Estado,
			Enable,
			RS,
			RW,
			Dados,
			Inicializado
			//------------------------------------------------------------------
	);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	reg[23:0]	contador = 24'd0;
	reg			estado_anterior;
										
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Clock & Reset Inputs
	//--------------------------------------------------------------------------
	input					Clock;	
	input					Reset;	
	input					Modo;		//Indica o modo de operação
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Inputs
	//--------------------------------------------------------------------------
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Outputs
	//--------------------------------------------------------------------------
	output[2:0]			Estado;
	output			 	Enable;
	output				RS;
	output				RW;
	output				Inicializado;
	output[7:0]			Dados;
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Estado Encoding
	//--------------------------------------------------------------------------
	parameter [2:0] 	WAIT_30MS = 3'b000,
							FUNCTION_SET = 3'b001,
							WAIT_39US = 3'b010,
							DISPLAY_ONOFF = 3'b011,
							DISPLAY_CLEAR = 3'b100,
							WAIT_153MS = 3'b101,
							ENTRY_MODE_SET = 3'b110,
							FINISH_INITIALIZATION = 3'b111;	
	//--------------------------------------------------------------------------


	
	//--------------------------------------------------------------------------
	//	Wire Declarations
	//--------------------------------------------------------------------------
	
	reg[2:0]		estado, proximo;
	reg[7:0]		dados;
	reg[23:0]	contador_temp;
	reg			enable, rs;

	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Logic
	//--------------------------------------------------------------------------
	
	always @(posedge Clock or negedge Reset) begin
		if(!Reset)	estado <= WAIT_30MS;
		else begin
			contador <= contador_temp;
			estado <= proximo;
		end
	end

	always @(estado) begin
		case(estado)
			WAIT_30MS: begin
				enable = 1'b1;
				dados = 8'b00000000;
				if(contador == 24'd8000000) begin
					contador_temp = 1'd0;
					proximo = FUNCTION_SET;
				end else begin
					contador_temp = contador + 1'd1;
					proximo = WAIT_30MS;
				end
			end

			FUNCTION_SET:	begin
				enable = 1'b0;
				dados = 8'b000001XX;
				estado_anterior = estado;
				proximo = WAIT_39US;
			end
			
			WAIT_39US: begin
				enable = 1'b1;
				dados = 8'b00000000;
				if(contador == 24'd8000)	begin
					contador_temp = 1'd0;
					if(estado_anterior == FUNCTION_SET)	proximo = DISPLAY_ONOFF;
					else											proximo = DISPLAY_CLEAR;
				end else	begin
					contador_temp = contador + 1'd1;
					proximo = WAIT_39US;
				end
			end

			DISPLAY_ONOFF:	begin
				enable = 1'b0;
				dados = 8'b00001110;
				estado_anterior = estado;
				proximo = WAIT_39US;
			end
			
			DISPLAY_CLEAR:	begin
				enable = 1'b0;
				dados = 8'b00000001;
				estado_anterior = estado;
				proximo = WAIT_39US;
			end
					
			WAIT_153MS: begin
				enable = 1'b1;
				dados = 8'b00000000;
				if(contador == 24'd20000000) begin
					contador_temp = 1'd0;
					proximo = ENTRY_MODE_SET;
				end else begin
					contador_temp = contador + 1'd1;
					proximo = WAIT_153MS;
				end 
			end

			ENTRY_MODE_SET:	begin
				enable = 1'b0;
				dados = 8'b00000111;
				estado_anterior = estado;
				proximo = FINISH_INITIALIZATION;
			end
			
			FINISH_INITIALIZATION:	begin
				proximo = FINISH_INITIALIZATION;
			end

		endcase
	end

	assign Estado = ~estado;
	assign Enable = enable;
	assign Dados = dados;
	assign RW = 1'b0;
	assign RS = 1'b0;
	assign Inicializado = estado == FINISH_INITIALIZATION ? 1'b1 : 1'b0;

	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------

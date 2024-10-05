module spi_controller #(
	parameter CLK_FPGA = 50000000,
	parameter CLK_SPI = 5000000,
	parameter DATA_WIDTH_SPI = 8,
	parameter DATA_WIDTH_SPI_CONFIG = 16
	)(
    input wire reset_n,
	 input wire clk,
    input wire enable_spi,
	 input wire [DATA_WIDTH_SPI_CONFIG-1:0] tx_byte,
    output wire sclk,
    output reg ss,
    output reg mosi, 
	 input wire miso,
	 output reg [DATA_WIDTH_SPI_CONFIG-1:0] rx_byte,
	 output reg busy,
    output wire complete
);  
     
	 localparam IDLE  = 2'b00;
    localparam WAIT1 = 2'b01;
    localparam WAIT2 = 2'b10;
    localparam TX_RX = 2'b11;
	 
    reg [1:0] state_next, state_reg;
    integer num_bits_tx = 0;
    integer num_bits_rx = 0;
	 reg enable_div; 
	 wire s_clk_5M;
	 reg complete_rx;
	 reg complete_tx;
	 reg reset_sclk;
	 reg enable_counter_sincr;
	 wire sincr;
	 
	 div_freq #(
		 .CLK_FPGA(CLK_FPGA),
		 .CLK_SPI(CLK_SPI)
	 ) div_freq_inst(
	  	 .reset_n(reset_n),
		 .clk(clk),
		 .enable_div(enable_div),
		 .s_clk(s_clk_5M)
	 );
	 
	
	
	//Secuential logic - stage

	always @(posedge clk or negedge reset_n ) 
	begin: FSM_SEQ
		if (!reset_n) begin
			state_reg <= IDLE;
		end else begin
			state_reg <= state_next;
		end
	end
	
	//Combinational logic, next state
	
	always @* 
	begin: FSM_NEXT_STATE
		case (state_reg)
		
			IDLE: begin
				if (enable_spi) begin
					state_next = WAIT1;
				end else begin
					state_next = IDLE;
				end 
			end
			
			WAIT1: begin

				state_next = WAIT2;
			end
			
			WAIT2: begin
					state_next = TX_RX;
			end
			
			
			TX_RX: begin
				if (complete) begin
					state_next = IDLE;
				end else begin
					state_next = TX_RX;
				end 
			end
			
			default: begin
					state_next = IDLE;
			end		
		endcase 
	 end

	 
	 
	//Combinational logic, outputs
	
	always @*
	begin: FSM_OUTPUTS

		 ss = 1'b1;
		 enable_div = 1'b0;
		 busy = 1'b0;
		 reset_sclk = 1'b1;
		 mosi = 1'bz;

		 case (state_reg)
			IDLE: begin
				ss = 1'b1;
				enable_div = 1'b0;
				busy = 1'b0;
				reset_sclk = 1'b0;
				mosi = 1'bz;
				
			end
			
			WAIT1: begin
				ss = 1'b1;
				enable_div = 1'b0;
				busy = 1'b1;
				reset_sclk = 1'b1;
				mosi = 1'bz;
			end
			
			WAIT2: begin
				ss = 1'b1;
				enable_div = 1'b0;
				busy = 1'b1;
				reset_sclk = 1'b1;
				mosi = 1'bz;
			end
			
			
			TX_RX: begin

				ss = 1'b0;
				enable_div = 1'b1;
				busy = 1'b1;
				reset_sclk = 1'b1;
				
				if (!ss) begin
   				mosi = tx_byte[DATA_WIDTH_SPI_CONFIG - 1 - num_bits_tx];
				end else begin
					mosi = 1'bz;
				end
				
			end
					
			default: begin
				ss = 1'b1;
				enable_div = 1'b0;
				busy = 1'b0;
				reset_sclk = 1'b1;
				mosi = 1'bz;
				
				
			end
			
		endcase 
	 end


    assign sclk = s_clk_5M;
	 assign complete = complete_rx && complete_tx;
	 
	//Secuential logic - tx

    always @(negedge sclk or negedge reset_n or negedge reset_sclk) begin
            if (!reset_n || !reset_sclk) begin
					num_bits_tx <= 0;
					complete_tx <= 0;
				end else begin
				   if (enable_div) begin  
						
						if (num_bits_tx < DATA_WIDTH_SPI_CONFIG - 1) begin
							 complete_tx <= 0;
							 num_bits_tx <= num_bits_tx + 1;
						end else begin
							 num_bits_tx <= 0;
							 complete_tx <= 1;
						end
					end else begin
						num_bits_tx <= 0;
						complete_tx <= 0;
					end	
				end  	
	 end
    

	 //Secuential logic - rx
	 
    always @(posedge sclk or negedge reset_n or negedge reset_sclk) begin
            if (!reset_n || !reset_sclk) begin
					num_bits_rx <= 0;
					complete_rx <= 0;
					rx_byte <= 16'bzzzzzzzzzzzzzzzz;
				end else begin
					if (enable_div) begin  	
						
						if (num_bits_rx < DATA_WIDTH_SPI_CONFIG - 1) begin
							 rx_byte[DATA_WIDTH_SPI_CONFIG - 1 - num_bits_rx] <= miso;
							 complete_rx <= 0;
							 num_bits_rx <= num_bits_rx + 1;
						end else begin
						    rx_byte[DATA_WIDTH_SPI_CONFIG - 1 - num_bits_rx] <= miso;
							 num_bits_rx <= 0;
							 complete_rx <= 1;
						end									
					end else begin
						num_bits_rx <= 0;
						complete_rx <= 0;
						rx_byte <= 0;				
					end
				end	
    end

	 
endmodule

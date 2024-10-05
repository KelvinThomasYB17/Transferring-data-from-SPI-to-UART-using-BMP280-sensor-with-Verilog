 module fsm #(
	parameter CLK_FPGA = 50000000,
	parameter CLK_SPI = 5000000,
	parameter DATA_WIDTH_UART = 8,
	parameter DATA_WIDTH_SPI = 8,
	parameter DATA_WIDTH_SPI_CONFIG = 16,
	/////BMP280 CONFIGS
	parameter [2:0] T_SB = 3'b000, 				/// 0,5 ms t_standby
	parameter[2:0] FILTER = 3'b100,				/// IIR coeficient 16
	parameter SPI3W = 1'b0,					   	/// 4 wires SPI
	parameter [2:0] OSRS_T =  3'b001,			/// temperature resolution 16 bit
	parameter [2:0] OSRS_P = 3'b000,  			/// preasure skipped	
	parameter [1:0] MODE = 2'b11, 				/// Normal mode
	parameter [7:0] TEMP_XLSB_ADDR = 8'hFC,	/// XLSB Temperature address 
	parameter [7:0] TEMP_LSB_ADDR = 8'hFB,		/// LSB Temperature address
	parameter [7:0] TEMP_MSB_ADDR = 8'hFA,		/// MSB Temperature address
	parameter [7:0] CONFIG_ADDR = 8'hF5,		/// Config address
	parameter [7:0] CTRL_MEAS_ADDR = 8'hF4,	/// Control measure address
	parameter [7:0] TEMP_1_MSB_COEF_ADDR = 8'h89, /// MSB Temperature coeficient dgT1 address
	parameter [7:0] TEMP_1_LSB_COEF_ADDR = 8'h88, /// LSB Temperature coeficient dgT1 address
	parameter [7:0] TEMP_2_MSB_COEF_ADDR = 8'h8B, /// MSB Temperature coeficient dgT2 address
	parameter [7:0] TEMP_2_LSB_COEF_ADDR = 8'h8A, /// LSB Temperature coeficient dgT2 address
	parameter [7:0] TEMP_3_MSB_COEF_ADDR = 8'h8D, /// MSB Temperature coeficient dgT3 address
	parameter [7:0] TEMP_3_LSB_COEF_ADDR = 8'h8C  /// LSB Temperature coeficient dgT3 address
	)(
	input wire clk, 
	input wire rst_n,
	input wire [DATA_WIDTH_SPI_CONFIG - 1:0] rx_byte_spi,
	input wire busy_spi,
	input wire complete_spi,
	input wire busy_uart,
	input wire complete_uart,
	output reg enable_uart,
	output reg [DATA_WIDTH_UART -1:0] tx_byte_uart,
	output reg [DATA_WIDTH_SPI_CONFIG -1:0] tx_byte_spi,
	output reg enable_spi 
);

localparam IDLE = 3'b000;
localparam TX_CONFIG_SPI = 3'b001;
localparam RX_DATA_SPI = 3'b010;
localparam TX_DATA_UART = 3'b011;

//////////////////////////////////////////////////////////////////////////////
////DONT FORGET TO DECLARE THE SIGNALS BEFORE THE INSTANCE CONFIG_CIRCUIT_INST
/// IN ORDER TO AVOID PROBLEMS. THIS ENSURE THE SIGNALS ARE CORRECTLY DEFINED 
// //////////////////////////////////////////////////////////////////////////


wire [DATA_WIDTH_SPI -1: 0] temp_xlsb;
wire [DATA_WIDTH_SPI -1: 0] temp_lsb;
wire [DATA_WIDTH_SPI -1: 0] temp_msb;
wire [DATA_WIDTH_UART -1: 0] temp_cut;
wire [DATA_WIDTH_SPI_CONFIG -1: 0] dgT1;
wire [DATA_WIDTH_SPI_CONFIG -1: 0] dgT2;
wire [DATA_WIDTH_SPI_CONFIG -1: 0] dgT3;
wire [(2*DATA_WIDTH_SPI_CONFIG)-1:0] config_inst_temp_tx_packed;
wire [(3*DATA_WIDTH_SPI_CONFIG)-1:0] config_inst_temp_rx_packed;
wire [(6*DATA_WIDTH_SPI_CONFIG)-1:0] config_inst_temp_coef_rx_packed;
wire [DATA_WIDTH_SPI -1: 0] dgT1_msb;
wire [DATA_WIDTH_SPI -1: 0] dgT1_lsb;
wire [DATA_WIDTH_SPI -1: 0] dgT2_msb;
wire [DATA_WIDTH_SPI -1: 0] dgT2_lsb;
wire [DATA_WIDTH_SPI -1: 0] dgT3_msb;
wire [DATA_WIDTH_SPI -1: 0] dgT3_lsb;

config_circuit #(
		.DATA_WIDTH_SPI(DATA_WIDTH_SPI),
		.DATA_WIDTH_SPI_CONFIG(DATA_WIDTH_SPI_CONFIG),
		.DATA_WIDTH_UART(DATA_WIDTH_UART),
		.T_SB(T_SB),
		.FILTER(FILTER),
		.SPI3W(SPI3W),
		.OSRS_T(OSRS_T),
		.OSRS_P(OSRS_P),
		.MODE(MODE),
		.CONFIG_ADDR(CONFIG_ADDR),
		.CTRL_MEAS_ADDR(CTRL_MEAS_ADDR),
		.TEMP_XLSB_ADDR(TEMP_XLSB_ADDR),
		.TEMP_LSB_ADDR(TEMP_LSB_ADDR),
		.TEMP_MSB_ADDR(TEMP_MSB_ADDR),
		.TEMP_1_MSB_COEF_ADDR(TEMP_1_MSB_COEF_ADDR),
		.TEMP_1_LSB_COEF_ADDR(TEMP_1_LSB_COEF_ADDR),
		.TEMP_2_MSB_COEF_ADDR(TEMP_2_MSB_COEF_ADDR),
		.TEMP_2_LSB_COEF_ADDR(TEMP_2_LSB_COEF_ADDR),
		.TEMP_3_MSB_COEF_ADDR(TEMP_3_MSB_COEF_ADDR),
		.TEMP_3_LSB_COEF_ADDR(TEMP_3_LSB_COEF_ADDR)
	)config_circuit_inst(
		.temp_xlsb(temp_xlsb), 
		.temp_lsb(temp_lsb), 
		.temp_msb(temp_msb),
	   .dgT1_msb(dgT1_msb),
		.dgT2_msb(dgT2_msb),
		.dgT3_msb(dgT3_msb),
	   .dgT1_lsb(dgT1_lsb),
		.dgT2_lsb(dgT2_lsb),
		.dgT3_lsb(dgT3_lsb),
		.config_inst_temp_tx_packed(config_inst_temp_tx_packed),//////////////////////////////////////////////////////
		.config_inst_temp_rx_packed(config_inst_temp_rx_packed),///////////////////////////////////////////////////////
		.config_inst_temp_coef_rx_packed(config_inst_temp_coef_rx_packed),
		.temp_cut(temp_cut) 
);




reg [2:0] state_next, state_reg;

reg start = 1;
reg end_transfer_uart = 0;
reg end_config = 0;
reg tx_spi_config_flag = 0;
reg rx_spi_read_flag = 0;

reg send_to_uart = 0;
integer bit_count = 0;
integer bit_count_config_tx = 0;

//reg [DATA_WIDTH_UART -1:0] data_transfer; /////////////////////////////////////////////////////////////////////////////////
reg [DATA_WIDTH_SPI -1: 0] temp_xlsb_reg;
reg [DATA_WIDTH_SPI -1: 0] temp_lsb_reg;
reg [DATA_WIDTH_SPI -1: 0] temp_msb_reg;
reg [DATA_WIDTH_SPI -1: 0] dgT1_msb_reg;
reg [DATA_WIDTH_SPI -1: 0] dgT1_lsb_reg;
reg [DATA_WIDTH_SPI -1: 0] dgT2_msb_reg;
reg [DATA_WIDTH_SPI -1: 0] dgT2_lsb_reg;
reg [DATA_WIDTH_SPI -1: 0] dgT3_msb_reg;
reg [DATA_WIDTH_SPI -1: 0] dgT3_lsb_reg;

//reg [DATA_WIDTH_SPI_CONFIG -1:0] data_rx_temp_inst [2:0];
reg [DATA_WIDTH_SPI_CONFIG -1:0] config_inst_temp_tx [1:0];
reg [DATA_WIDTH_SPI_CONFIG -1:0] config_inst_temp_rx [8:0];

reg [DATA_WIDTH_SPI_CONFIG -1:0] data_rx_all_register [8:0];

always @(*)
begin: UNPACKED

	config_inst_temp_tx[1] = config_inst_temp_tx_packed[(2*DATA_WIDTH_SPI_CONFIG)-1:DATA_WIDTH_SPI_CONFIG];
	config_inst_temp_tx[0] = config_inst_temp_tx_packed[DATA_WIDTH_SPI_CONFIG-1:0];

	config_inst_temp_rx[0] = config_inst_temp_coef_rx_packed[(DATA_WIDTH_SPI_CONFIG)-1:0];
	config_inst_temp_rx[1] = config_inst_temp_coef_rx_packed[(2*DATA_WIDTH_SPI_CONFIG)-1:(DATA_WIDTH_SPI_CONFIG)];
	config_inst_temp_rx[2] = config_inst_temp_coef_rx_packed[(3*DATA_WIDTH_SPI_CONFIG)-1:(2*DATA_WIDTH_SPI_CONFIG)];
	config_inst_temp_rx[3] = config_inst_temp_coef_rx_packed[(4*DATA_WIDTH_SPI_CONFIG)-1:(3*DATA_WIDTH_SPI_CONFIG)];
	config_inst_temp_rx[4] = config_inst_temp_coef_rx_packed[(5*DATA_WIDTH_SPI_CONFIG)-1:(4*DATA_WIDTH_SPI_CONFIG)];
	config_inst_temp_rx[5] = config_inst_temp_coef_rx_packed[(6*DATA_WIDTH_SPI_CONFIG)-1:(5*DATA_WIDTH_SPI_CONFIG)];
	
	config_inst_temp_rx[6] = config_inst_temp_rx_packed[DATA_WIDTH_SPI_CONFIG-1:0];
	config_inst_temp_rx[7] = config_inst_temp_rx_packed[(2*DATA_WIDTH_SPI_CONFIG)-1:DATA_WIDTH_SPI_CONFIG];
	config_inst_temp_rx[8] = config_inst_temp_rx_packed[(3*DATA_WIDTH_SPI_CONFIG)-1:(2*DATA_WIDTH_SPI_CONFIG)];
end

assign temp_xlsb = temp_xlsb_reg;
assign temp_lsb = temp_lsb_reg;
assign temp_msb = temp_msb_reg;
assign dgT1_msb = dgT1_msb_reg;
assign dgT1_lsb = dgT1_lsb_reg;
assign dgT2_msb = dgT2_msb_reg;
assign dgT2_lsb = dgT2_lsb_reg;
assign dgT3_msb = dgT3_msb_reg;
assign dgT3_lsb = dgT3_lsb_reg;



////////////////////////////////////////////////////////////////////////

//Secuential logic - stage

always @(posedge clk or negedge rst_n ) 
begin: FSM_SEQ
	if (!rst_n) begin
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
			if (start) begin
				state_next = TX_CONFIG_SPI;
			end else begin
				state_next = IDLE;
			end 
		end
		
		TX_CONFIG_SPI: begin
			if (end_config) begin
				state_next = RX_DATA_SPI;
			end else begin
				state_next = TX_CONFIG_SPI;
			end 
		end
		
		RX_DATA_SPI: begin
			if (send_to_uart) begin
				state_next = TX_DATA_UART;
			end else begin
				state_next = RX_DATA_SPI;
			end 
		end
		
		
		TX_DATA_UART : begin
			if (end_transfer_uart) begin
				state_next = RX_DATA_SPI;
			end else begin
				state_next = TX_DATA_UART;
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

	 start = 1;
	 end_config = 0;
	 enable_spi = 0;
	 send_to_uart = 1'b0;
	 end_transfer_uart = 0;
	 tx_byte_uart = 8'd0;
	 enable_uart = 0;
	 tx_spi_config_flag = 0;
	 rx_spi_read_flag = 0;
	 
	case (state_reg)
		IDLE: begin
			start = 1;
			end_config = 0;
			enable_spi = 0;
			send_to_uart = 1'b0;
			end_transfer_uart = 0;
			tx_byte_uart = 8'd0;
			enable_uart = 0;
			tx_spi_config_flag = 0;
			rx_spi_read_flag = 0;
			
		end
		
		TX_CONFIG_SPI: begin
			
			enable_spi = 1;	
			tx_spi_config_flag = 1;
			if (bit_count_config_tx ==1  && complete_spi == 1) begin
				end_config = 1;				
			end
			
		end 
		
		RX_DATA_SPI: begin
		
			enable_spi = 1;
		   end_transfer_uart = 0;
			tx_spi_config_flag = 0;
			rx_spi_read_flag = 1;
			
			
			if (bit_count == 8 && complete_spi) begin
				send_to_uart = 1;
			end else begin
				send_to_uart = 0;
			end	
			
			
		end
		
		
		TX_DATA_UART: begin
			tx_spi_config_flag = 0;
			enable_uart = 1'b1;

			tx_byte_uart = temp_cut;
			if (complete_uart) begin
				end_transfer_uart = 1'b1;
		   end
		end
		
		default: begin

			start = 1;
			end_config = 0;
			bit_count = 0;
			enable_spi = 0;
			send_to_uart = 1'b0;
			end_transfer_uart = 0;
			tx_byte_uart = 8'd0;
			enable_uart = 0;
			tx_spi_config_flag = 0;
			rx_spi_read_flag = 0;
		end
		
	endcase 
end


always @(posedge clk or negedge rst_n) 
begin: SEQ_PROCESS_BEHAVIOR

          if (!rst_n) begin
				bit_count <= 0;
				bit_count_config_tx <= 0;
				tx_byte_spi <= 16'bzzzzzzzzzzzzzzzz;
			 end else begin
			 
			   if (tx_spi_config_flag) begin			 
					tx_byte_spi <= config_inst_temp_tx [bit_count_config_tx];
				end
				
				if (rx_spi_read_flag) begin
					tx_byte_spi <= config_inst_temp_rx [bit_count];		
				end
				

			
				dgT1_msb_reg <= data_rx_all_register [0][7:0];
				dgT1_lsb_reg <= data_rx_all_register [1][7:0];
				dgT2_msb_reg <= data_rx_all_register [2][7:0];
				dgT2_lsb_reg <= data_rx_all_register [3][7:0];
				dgT3_msb_reg <= data_rx_all_register [4][7:0];
				dgT3_lsb_reg <= data_rx_all_register [5][7:0];

				temp_msb_reg <= data_rx_all_register [6][7:0];
				temp_lsb_reg <= data_rx_all_register [7][7:0];
				temp_xlsb_reg <= data_rx_all_register[8][7:0];
				
				if (complete_spi) begin
					///data_transfer <= rx_byte_spi;
			
					if (tx_spi_config_flag) begin
					
						if (bit_count_config_tx < 2) begin
							bit_count_config_tx  <= bit_count_config_tx  +1;
						end else begin
							bit_count_config_tx  <= 0;
						end
					end	
							
							
					if (rx_spi_read_flag)  begin 	
						data_rx_all_register [bit_count] <= rx_byte_spi;
				
						if (bit_count < 8) begin
							bit_count <= bit_count +1;
						end else begin
							bit_count <= 0;
						end
					
					end
					
				end		
				
			 end	
end



endmodule

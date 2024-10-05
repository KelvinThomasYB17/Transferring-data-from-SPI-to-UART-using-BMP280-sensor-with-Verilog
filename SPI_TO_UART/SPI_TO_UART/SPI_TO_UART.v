/////////////////////////////////////////////////////////////////////////////// 
//CONFIG SPI: CPOL=0, CPHA=0 //////////////////////////////////////////////////
///////////BMP280 parameter////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//////Handheld device dynamic config///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////// 
//parameter [2:0] T_SB = 3'b000, 				/// 0,5 ms t_standby
//parameter[2:0] FILTER = 3'b100,				/// IIR coeficient 16
//parameter SPI3W = 1'b0,					   	/// 4 wires SPI
//parameter [2:0] OSRS_T =  3'b001,			/// temperature resolution 16 bit
//parameter [2:0] OSRS_P = 3'b000,  			/// preasure skipped	
//parameter [1:0] MODE = 2'b11, 				/// Normal mode
//parameter [7:0] TEMP_XLSB_ADDR = 8'hFC,	/// XLSB Temperature address 
//parameter [7:0] TEMP_LSB_ADDR = 8'hFB,		/// LSB Temperature address
//parameter [7:0] TEMP_MSB_ADDR = 8'hFA,		/// MSB Temperature address
//parameter [7:0] CONFIG_ADDR = 8'hF5,		/// Config address
//parameter [7:0] CTRL_MEAS_ADDR = 8'hF4,	/// Control measure address	
///////////////////////////////////////////////////////////////////////////////
/////////End parameter configs/////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////// 


module SPI_TO_UART #(
	parameter CLK_FPGA = 50000000,
	parameter BAUDIOS = 9600,
	parameter CLK_COUNT = 24,
	parameter CLK_SPI = 5000000,
	parameter DATA_WIDTH_UART = 20,//8
	parameter DATA_WIDTH_SPI = 8,
	parameter DATA_WIDTH_SPI_CONFIG = 16,
	/////BMP280 CONFIGS
	parameter [2:0] T_SB = 3'b101, 				/// 1000 ms t_standby
	parameter[2:0] FILTER = 3'b000,				/// IIR coeficient 
	parameter SPI3W = 1'b0,					   	/// 4 wires SPI
	parameter [2:0] OSRS_T =  3'b111,			/// temperature resolution 20 bit
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
	input wire miso,
	output wire tx_uart,
	output wire ss,
	output wire mosi,
	output wire sclk

);

//internal signals

	wire enable_spi;
	wire enable_uart;
	wire [DATA_WIDTH_SPI_CONFIG-1:0] tx_byte_spi;
	//wire [DATA_WIDTH_UART-1:0] tx_byte_uart;
	wire [DATA_WIDTH_SPI_CONFIG-1:0] rx_byte_spi;
	wire [DATA_WIDTH_UART-1:0] data_tx_uart;
	wire busy_spi;
	wire complete_spi;
	wire busy_uart;
	wire complete_uart;



spi_controller #(
		.CLK_FPGA(CLK_FPGA),
		.CLK_SPI(CLK_SPI),
		.DATA_WIDTH_SPI(DATA_WIDTH_SPI),
		.DATA_WIDTH_SPI_CONFIG(DATA_WIDTH_SPI_CONFIG)
)spi_controller_inst(
		.reset_n(rst_n),
		.clk(clk),
		.enable_spi(enable_spi),
		.tx_byte(tx_byte_spi),
      .sclk(sclk),
      .ss(ss),
      .mosi(mosi), 
      .miso(miso),
		.rx_byte(rx_byte_spi),
		.busy(busy_spi),
      .complete(complete_spi)
);     

uart_tx #(
		.CLK_FPGA(CLK_FPGA),
		.BAUDIOS(BAUDIOS),
		.CLK_COUNT(CLK_COUNT),
		.DATA_WIDTH_UART(DATA_WIDTH_UART)
	)uart_tx_inst(
		.clk(clk), 
		.rst_n(rst_n),
		.enable_uart(enable_uart),
		.data_tx(data_tx_uart),
		.stop_done(complete_uart),
		.busy(busy_uart),
		.tx(tx_uart)
);

fsm #(
		.CLK_FPGA(CLK_FPGA),
		.CLK_SPI(CLK_SPI),
		.DATA_WIDTH_UART(DATA_WIDTH_UART),
		.DATA_WIDTH_SPI(DATA_WIDTH_SPI),
		.DATA_WIDTH_SPI_CONFIG(DATA_WIDTH_SPI_CONFIG),
		.T_SB(T_SB),
		.FILTER(FILTER),
		.SPI3W(SPI3W),
		.OSRS_T(OSRS_T),
		.OSRS_P(OSRS_P),
		.MODE(MODE),
		.TEMP_XLSB_ADDR(TEMP_XLSB_ADDR),
		.TEMP_LSB_ADDR(TEMP_LSB_ADDR),
		.TEMP_MSB_ADDR(TEMP_MSB_ADDR),
		.CONFIG_ADDR(CONFIG_ADDR),
		.CTRL_MEAS_ADDR(CTRL_MEAS_ADDR),
		.TEMP_1_MSB_COEF_ADDR(TEMP_1_MSB_COEF_ADDR),
		.TEMP_1_LSB_COEF_ADDR(TEMP_1_LSB_COEF_ADDR),
		.TEMP_2_MSB_COEF_ADDR(TEMP_2_MSB_COEF_ADDR),
		.TEMP_2_LSB_COEF_ADDR(TEMP_2_LSB_COEF_ADDR),
		.TEMP_3_MSB_COEF_ADDR(TEMP_3_MSB_COEF_ADDR),
		.TEMP_3_LSB_COEF_ADDR(TEMP_3_LSB_COEF_ADDR)		
	)fsm_inst(
		.clk(clk), 
		.rst_n(rst_n),
		.rx_byte_spi(rx_byte_spi),
		.busy_spi(busy_spi),
		.complete_spi(complete_spi),
		.busy_uart(busy_uart),
		.complete_uart(complete_uart),
		.enable_uart(enable_uart),
		.tx_byte_uart(data_tx_uart),
		.tx_byte_spi(tx_byte_spi),
		.enable_spi(enable_spi)
);


endmodule

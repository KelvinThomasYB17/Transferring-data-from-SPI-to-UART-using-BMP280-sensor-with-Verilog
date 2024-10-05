 module config_circuit #(
	parameter DATA_WIDTH_SPI = 8,
	parameter DATA_WIDTH_SPI_CONFIG = 16,
	parameter DATA_WIDTH_UART = 8,
	/////BMP280 CONFIGS
	parameter [2:0] T_SB = 3'b000, 					 /// 0,5 ms t_standby
	parameter[2:0] FILTER = 3'b001,					 /// IIR coeficient 16
	parameter SPI3W = 1'b0,					    		 /// 4 wires SPI	
	parameter [2:0] OSRS_T =  3'b001,				 /// temperature resolution 16 bit
	parameter [2:0] OSRS_P = 3'b000,  				 /// preasure skipped	
	parameter [1:0] MODE = 2'b11, 			  		 /// Normal mode
	parameter [7:0] CONFIG_ADDR = 8'hF5,			 /// Config address
	parameter [7:0] CTRL_MEAS_ADDR = 8'hF4,		 /// Control measure address
	parameter [7:0] TEMP_XLSB_ADDR = 8'hFC,		 /// XLSB Temperature address 
	parameter [7:0] TEMP_LSB_ADDR = 8'hFB,			 /// LSB Temperature address
	parameter [7:0] TEMP_MSB_ADDR = 8'hFA,			 /// MSB Temperature address
	parameter [7:0] TEMP_1_MSB_COEF_ADDR = 8'h89, /// MSB Temperature coeficient dgT1 address
	parameter [7:0] TEMP_1_LSB_COEF_ADDR = 8'h88, /// LSB Temperature coeficient dgT1 address
	parameter [7:0] TEMP_2_MSB_COEF_ADDR = 8'h8B, /// MSB Temperature coeficient dgT2 address
	parameter [7:0] TEMP_2_LSB_COEF_ADDR = 8'h8A, /// LSB Temperature coeficient dgT2 address
	parameter [7:0] TEMP_3_MSB_COEF_ADDR = 8'h8D, /// MSB Temperature coeficient dgT3 address
	parameter [7:0] TEMP_3_LSB_COEF_ADDR = 8'h8C  /// LSB Temperature coeficient dgT3 address
	)(
	input wire [DATA_WIDTH_SPI -1: 0] temp_xlsb, 
	input wire [DATA_WIDTH_SPI -1: 0] temp_lsb, 
	input wire [DATA_WIDTH_SPI -1: 0] temp_msb,
	input wire [DATA_WIDTH_SPI -1: 0] dgT1_msb,
	input wire [DATA_WIDTH_SPI -1: 0] dgT2_msb,
	input wire [DATA_WIDTH_SPI -1: 0] dgT3_msb,
	input wire [DATA_WIDTH_SPI -1: 0] dgT1_lsb,
	input wire [DATA_WIDTH_SPI -1: 0] dgT2_lsb,
	input wire [DATA_WIDTH_SPI -1: 0] dgT3_lsb,
	output reg [(2*DATA_WIDTH_SPI_CONFIG)-1:0] config_inst_temp_tx_packed,
	//output reg [DATA_WIDTH_SPI_CONFIG -1:0] config_inst_temp_tx [1:0],
	output reg [(3*DATA_WIDTH_SPI_CONFIG)-1:0] config_inst_temp_rx_packed,
	//output reg [DATA_WIDTH_SPI_CONFIG -1:0] config_inst_temp_rx [2:0],
	output reg [(6*DATA_WIDTH_SPI_CONFIG)-1:0] config_inst_temp_coef_rx_packed,
	output reg [DATA_WIDTH_UART -1: 0] temp_cut 
);

reg bit_config = 1'b0;
reg [19: 0] temp_raw;
reg [DATA_WIDTH_SPI -1: 0] config_byte; 
reg [DATA_WIDTH_SPI -1: 0] ctrl_meas_byte;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_config_byte;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_ctrl_meas_byte;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_temp_xlsb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_temp_lsb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_temp_msb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_coef_temp_1_msb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_coef_temp_1_lsb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_coef_temp_2_msb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_coef_temp_2_lsb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_coef_temp_3_msb;
reg [DATA_WIDTH_SPI -1: 0] mask_addr_coef_temp_3_lsb;

reg [DATA_WIDTH_SPI_CONFIG  -1: 0] config_inst_temp_tx[1:0];
//reg [DATA_WIDTH_SPI_CONFIG  -1: 0] config_inst_temp_tx_1;
reg [DATA_WIDTH_SPI_CONFIG  -1: 0] config_inst_temp_rx[2:0];
//reg [DATA_WIDTH_SPI_CONFIG  -1: 0] config_inst_temp_rx_1;
//reg [DATA_WIDTH_SPI_CONFIG  -1: 0] config_inst_temp_rx_2;
reg [DATA_WIDTH_SPI_CONFIG  -1: 0] config_inst_temp_coef_rx[5:0];

reg [DATA_WIDTH_SPI_CONFIG -1: 0] dgT1;
reg [DATA_WIDTH_SPI_CONFIG -1: 0] dgT2;
reg [DATA_WIDTH_SPI_CONFIG -1: 0] dgT3;

reg signed [31:0] var1, var2, t_fine, t_celsius ;

localparam signed Tmin = -40;
localparam signed Tmax = 85;
localparam signed scale_factor = 255/(Tmax - Tmin);
reg signed [31:0] temp_C;


always @(*) begin

	temp_raw = {temp_msb, temp_lsb, temp_xlsb[7:4]};
	config_byte = {T_SB,FILTER,bit_config ,SPI3W};
	ctrl_meas_byte = {OSRS_T, OSRS_P, MODE};
	
	mask_addr_config_byte = CONFIG_ADDR &  8'b01111111;
	mask_addr_ctrl_meas_byte = CTRL_MEAS_ADDR  &  8'b01111111;
	
	mask_addr_temp_xlsb = TEMP_XLSB_ADDR |  8'b10000000;
	mask_addr_temp_lsb = TEMP_LSB_ADDR |  8'b10000000;
	mask_addr_temp_msb = TEMP_MSB_ADDR |  8'b10000000;
	
	mask_addr_coef_temp_1_msb = TEMP_1_MSB_COEF_ADDR |  8'b10000000;
	mask_addr_coef_temp_1_lsb = TEMP_1_LSB_COEF_ADDR |  8'b10000000;
	mask_addr_coef_temp_2_msb = TEMP_2_MSB_COEF_ADDR |  8'b10000000;
	mask_addr_coef_temp_2_lsb = TEMP_2_LSB_COEF_ADDR |  8'b10000000;
	mask_addr_coef_temp_3_msb = TEMP_3_MSB_COEF_ADDR |  8'b10000000;
	mask_addr_coef_temp_3_lsb = TEMP_3_LSB_COEF_ADDR |  8'b10000000;
	
	config_inst_temp_tx[0] = {mask_addr_config_byte,config_byte};
	config_inst_temp_tx[1] = {mask_addr_ctrl_meas_byte, ctrl_meas_byte};
	config_inst_temp_tx_packed = {config_inst_temp_tx[1], config_inst_temp_tx[0]};
	
	config_inst_temp_rx[0] = {mask_addr_temp_msb, 8'bzzzzzzzz};
	config_inst_temp_rx[1] = {mask_addr_temp_lsb, 8'bzzzzzzzz};
	config_inst_temp_rx[2] = {mask_addr_temp_xlsb, 8'bzzzzzzzz};
	config_inst_temp_rx_packed = {config_inst_temp_rx[2], config_inst_temp_rx[1], config_inst_temp_rx[0]};
	

	config_inst_temp_coef_rx[0] = {mask_addr_coef_temp_1_msb, 8'bzzzzzzzz};
	config_inst_temp_coef_rx[1] = {mask_addr_coef_temp_1_lsb, 8'bzzzzzzzz};
	config_inst_temp_coef_rx[2] = {mask_addr_coef_temp_2_msb, 8'bzzzzzzzz};
	config_inst_temp_coef_rx[3] = {mask_addr_coef_temp_2_lsb, 8'bzzzzzzzz};
	config_inst_temp_coef_rx[4] = {mask_addr_coef_temp_3_msb, 8'bzzzzzzzz};
	config_inst_temp_coef_rx[5] = {mask_addr_coef_temp_3_lsb, 8'bzzzzzzzz};	
	config_inst_temp_coef_rx_packed = {config_inst_temp_coef_rx[5], config_inst_temp_coef_rx[4], config_inst_temp_coef_rx[3], config_inst_temp_coef_rx[2], config_inst_temp_coef_rx[1], config_inst_temp_coef_rx[0]};
	
	dgT1 = {dgT1_msb, dgT1_lsb};
	dgT2 = {dgT2_msb, dgT2_lsb};
	dgT3	= {dgT3_msb, dgT3_lsb};
	
	// Cálculo de la temperatura en grados Celsius según la hoja de datos del BMP280
   // Fórmula: T = ((temp_raw / 16384.0) - (dig_T1 / 1024.0)) * dig_T2 + (dig_T3 * (temp_raw / 131072.0) ^ 2)

   // Parte 1 del cálculo
   var1 = (((temp_raw >> 3) - (dgT1 << 1)) * dgT2) >> 11;

   // Parte 2 del cálculo
   var2 = (((((temp_raw >> 4) - dgT1) * ((temp_raw >> 4) - dgT1)) >> 12) * dgT3) >> 14;

   // Compensación final de la temperatura
   t_fine = (var1 + var2) >> 4;
	t_celsius = (t_fine * 5 + 128) >> 8;
	
	//temp_C  = t_celsius /1000;
	
	//if(temp_C < Tmin)
	//	temp_C = Tmin;
	//else if (temp_C > Tmax)
	//	temp_C = Tmax;
		
	
   //temp_cut = (temp_C - Tmin)* scale_factor;
	temp_cut = t_celsius;
end



endmodule

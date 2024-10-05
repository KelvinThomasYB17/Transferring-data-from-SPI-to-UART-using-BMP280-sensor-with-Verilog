// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "08/26/2024 21:06:46"
                                                                                
// Verilog Test Bench template for design : SPI_TO_UART
// 
// Simulation tool : ModelSim-Altera (Verilog)
// 

`timescale 1 ns/ 1 ns
//set IterationLimit 10000
module SPI_TO_UART_vlg_tst();
// constants
parameter CLK_FPGA = 50000000;
parameter BAUDIOS = 9600;
parameter CLK_COUNT = 24;
parameter CLK_SPI = 5000000;
parameter DATA_WIDTH_UART = 8;
parameter DATA_WIDTH_SPI = 8;
parameter DATA_WIDTH_SPI_CONFIG = 16;
parameter [2:0] T_SB = 3'b000; 				/// 0,5 ms t_standby
parameter[2:0] FILTER = 3'b100;				/// IIR coeficient 16
parameter SPI3W = 1'b0;					   	/// 4 wires SPI
parameter [2:0] OSRS_T =  3'b001;			/// temperature resolution 16 bit
parameter [2:0] OSRS_P = 3'b000;  			/// preasure skipped	
parameter [1:0] MODE = 2'b11; 				/// Normal mode
parameter [7:0] TEMP_XLSB_ADDR = 8'hFC;	/// XLSB Temperature address 
parameter [7:0] TEMP_LSB_ADDR = 8'hFB;		/// LSB Temperature address
parameter [7:0] TEMP_MSB_ADDR = 8'hFA;		/// MSB Temperature address
parameter [7:0] CONFIG_ADDR = 8'hF5;		/// Config address
parameter [7:0] CTRL_MEAS_ADDR = 8'hF4;	/// Control measure address
parameter [7:0] TEMP_1_MSB_COEF_ADDR = 8'h89; /// MSB Temperature coeficient dgT1 address
parameter [7:0] TEMP_1_LSB_COEF_ADDR = 8'h88; /// LSB Temperature coeficient dgT1 address
parameter [7:0] TEMP_2_MSB_COEF_ADDR = 8'h8B; /// MSB Temperature coeficient dgT2 address
parameter [7:0] TEMP_2_LSB_COEF_ADDR = 8'h8A; /// LSB Temperature coeficient dgT2 address
parameter [7:0] TEMP_3_MSB_COEF_ADDR = 8'h8D; /// MSB Temperature coeficient dgT3 address
parameter [7:0] TEMP_3_LSB_COEF_ADDR = 8'h8C;  /// LSB Temperature coeficient dgT3 address
	                                       
// test vector input registers
reg clk;
reg miso;
reg rst_n;
// wires                                               
wire mosi;
wire sclk;
wire ss;
wire tx_uart;

// assign statements (if any)                          
SPI_TO_UART #(
		.CLK_FPGA(CLK_FPGA),
		.BAUDIOS(BAUDIOS),
		.CLK_COUNT(CLK_COUNT),
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
		
)i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.miso(miso),
	.mosi(mosi),
	.rst_n(rst_n),
	.sclk(sclk),
	.ss(ss),
	.tx_uart(tx_uart)
);


always begin
	#10 clk = ~ clk;
end

initial begin
	clk = 0;
	rst_n = 0;
	miso = 0;
	
	#60 rst_n = 1;

	#8290 miso = 1'b1;
	
	#200 miso = 1'b0;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b0;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b0;

	#200 miso = 1'b1;
	
	#200 miso = 1'b0;
	
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b0;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b0;

	#200 miso = 1'b1;
	
	#200 miso = 1'b0;
	
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b0;

	#200 miso = 1'b1;
	
	#200 miso = 1'b0;
	
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	

	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	
	
	#1880 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#4000000 $finish;
	

end                                               
                                                                                           
endmodule

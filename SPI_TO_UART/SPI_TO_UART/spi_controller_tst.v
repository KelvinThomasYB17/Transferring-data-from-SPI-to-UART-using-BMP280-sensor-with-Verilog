`timescale 1 ns/ 1 ns

module spi_controller_tst();

// constants

parameter CLK_FPGA = 50000000;
parameter CLK_SPI = 5000000;
parameter DATA_WIDTH_SPI = 8;
                                     
// test vector input registers
reg reset_n;
reg clk;
reg enable_spi;
reg [DATA_WIDTH_SPI-1:0] tx_byte;
reg miso;
// wires
wire sclk;
wire ss;
wire mosi; 
wire [DATA_WIDTH_SPI-1:0] rx_byte;
wire busy;
wire complete;

spi_controller #(
		.CLK_FPGA(CLK_FPGA),
		.CLK_SPI(CLK_SPI),
		.DATA_WIDTH_SPI(DATA_WIDTH_SPI)
		)i1(
		.reset_n(reset_n),
		.clk(clk),
		.enable_spi(enable_spi),
		.tx_byte(tx_byte),
		.sclk(sclk),
		.ss(ss),
		.mosi(mosi), 
		.miso(miso),
		.rx_byte(rx_byte),
		.busy(busy),
		.complete(complete)
);  


always begin
	#10 clk = ~ clk;
end

initial begin
	clk = 0;
	reset_n = 0;
	enable_spi = 0;
	
	#10 reset_n = 1;
	
	
	#10 enable_spi = 1;
	
	#10 tx_byte = 8'b11001011;
	#40  miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b0;
	
	#200 miso = 1'b1;	

	#200 miso = 1'b0;
	
	#200 miso = 1'b1;

	#200 miso = 1'b1;
	
	#200 miso = 1'b1;
	
	#200 miso = 1'b0;

	
	
	#80000 $finish;
	

end                                               
                                                                                           
endmodule


    
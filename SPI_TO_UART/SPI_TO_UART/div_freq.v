module div_freq #(
	parameter CLK_FPGA = 50000000,
	parameter CLK_SPI = 5000000
	)(
	input wire reset_n,
	input wire clk,
	input wire enable_div,
	output reg s_clk
	
);

integer cuenta;
localparam cantidad = CLK_FPGA / CLK_SPI;

always @(posedge clk or negedge reset_n)
begin

	if (!reset_n) begin
		s_clk <= 1'b0;
		cuenta <= 0;
	end else begin
		if (enable_div) begin
		
			if (cuenta == cantidad/2-1) begin
				cuenta <= 0;
				s_clk  <= ~s_clk;
			end
			else begin
				cuenta <= cuenta + 1;
			end
		end else begin
			cuenta <= 0;
			s_clk <= 1'b0;
		end
	end
end

endmodule

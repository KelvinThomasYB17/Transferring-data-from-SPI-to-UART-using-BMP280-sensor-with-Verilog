module uart_tx #(
	parameter CLK_FPGA = 50000000,
	parameter BAUDIOS = 9600, //9600
	parameter CLK_COUNT = 24, //24
	parameter DATA_WIDTH_UART = 8
	)(
	input wire clk, 
	input wire rst_n,
	input wire enable_uart,
	input wire [DATA_WIDTH_UART-1:0] data_tx,
	output reg stop_done,
	output reg busy,
	output reg tx
);

localparam IDLE = 3'b000;
localparam START = 3'b001;
localparam SEND = 3'b010;
localparam PARITY = 3'b011;
localparam STOP = 3'b100;

localparam ACUMULATOR = CLK_FPGA *CLK_COUNT / BAUDIOS;


reg [2:0] state_next, state_reg;
reg started;
reg array_done;
reg parity_done;
reg send_data;
reg start;
reg prescaler;
integer bit_count;
reg [DATA_WIDTH_UART - 1:0] data_tx_reg;
integer counter = 0;

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
			if (enable_uart) begin
				state_next = START;
			end else begin
				state_next = IDLE;
			end 
		end
		
		START: begin
			if (started) begin
				state_next = SEND;
			end else begin
				state_next = START;
			end 
		end
		
		SEND: begin
			if (array_done) begin
				state_next = PARITY;
			end else begin
				state_next = SEND;
			end 
		end
		
		
		PARITY: begin
			if (parity_done) begin
				state_next = STOP;
			end else begin
				state_next = PARITY;
			end 
		end
		
		STOP: begin
			if (stop_done) begin
				state_next = IDLE;
			end else begin
				state_next = STOP;
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

    array_done = 1'b0;
    parity_done = 1'b0;
    stop_done = 1'b0;
    tx = 1'bz;
    busy = 1'b0;
    //data_tx_reg = 8'b0;
    started = 1'b0;
	 send_data = 1'b0;
	 start = 1'b0;

	case (state_reg)
		IDLE: begin
			array_done = 1'b0;
			parity_done = 1'b0;
			stop_done = 1'b0;
			tx = 1'bZ;
			busy = 1'b0;
			//data_tx_reg <= 8'b0;
			send_data = 1'b0;
			start = 1'b0;
		end
		
		START: begin
			busy = 1'b1;
			tx = 1'b0;
			//data_tx_reg = data_tx;
			start =  1'b1;
			if (prescaler) begin
				started =1'b1;
			end else begin
				started = 1'b0;
			end
		end
		
		SEND: begin
			
			busy = 1'b1;
			send_data = 1'b1;
			
			if (bit_count > 0) begin
				tx = data_tx_reg[bit_count-1];
				array_done = 1'b0; 
			end else begin
				array_done = 1'b1; 
			end	
		end
		
		
		PARITY: begin

			busy = 1'b1;
			tx = ^data_tx_reg;
			
			if (prescaler) begin
					parity_done = 1'b1;
			end else begin
				parity_done = 1'b0;
			end
		
		end
		
		STOP: begin
			tx = 1'b1;
			busy = 1'b1;
			
			if (prescaler) begin
				stop_done =1'b1;
			end else begin
				stop_done = 1'b0;
			end
		
		end
		
	endcase 
end



//Secuential logic - Prescaler

always @(posedge clk or negedge rst_n ) 
begin: PRESCALER_CKTO
	if (!rst_n) begin
		prescaler <= 1'b0;
		counter <= 0;
		bit_count <= DATA_WIDTH_UART;
		data_tx_reg <= 0;
	end else begin	
		if (busy) begin 
			if (counter > ACUMULATOR) begin
				counter <= 0;
				prescaler <= 1'b1;
				if (send_data) begin
					bit_count <= bit_count - 1;
			   end else begin
					bit_count <= bit_count;
				end
				if (start) begin
					data_tx_reg <= data_tx;
				end else begin 
					data_tx_reg <= data_tx_reg;
				end
				
			end else begin
				counter <= counter + CLK_COUNT;
				prescaler <= 1'b0;
				bit_count <= bit_count;
			end
		end else begin
			prescaler <= 1'b0;
			counter <= 0;
			bit_count <= DATA_WIDTH_UART;
	   end
	end
end




endmodule

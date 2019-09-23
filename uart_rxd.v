module uart_rxd (
	input        rxd    , //
	input        clk    , //CLOOK
	input        rst_n  , //
	output       ena_rxd, //
	output [7:0] data_o   //
);

	parameter 	CLOCK_FREQUENCY = 100_000_000,		//
		BAUD_RATE = 115200;					//
	localparam LENGTH_BAUD      = (CLOCK_FREQUENCY / BAUD_RATE)    ;
	localparam LENGTH_BAUD_HALF = (CLOCK_FREQUENCY / BAUD_RATE) / 2;


	reg [                         7:0] shift_data ; //
	reg                                shift_rxd  ; //
	reg [     $clog2(LENGTH_BAUD)-1:0] count_baund; //
	reg [                         3:0] count_bit  ; //
	reg                                load       ; //
	reg [$clog2(LENGTH_BAUD_HALF)-1:0] count_half ;

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n) 														shift_data <= 8'b1111_1111;					//
			else if (rxd == 1'b0 && shift_rxd == 1'b1 && count_bit == 4'd0)		shift_data <= {1'b0, rxd};					//
			else if (count_baund == LENGTH_BAUD - 1 && count_bit < 8)			shift_data <= {shift_data[7:0], rxd};		//
			else 																shift_data <= shift_data;					//

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n) 			shift_rxd <= 1'b1;		//
			else					shift_rxd <= rxd;			//

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)											count_baund <= LENGTH_BAUD - 1;
			else if (~rxd && shift_rxd)							count_baund <= 9'h0;
			else if (count_bit == 4'd9)							count_baund <= count_baund;
			else if (count_baund == LENGTH_BAUD - 1)			count_baund <= 9'h0;
			else												count_baund <= count_baund + 1'b1;

		end

	always @(posedge clk or negedge rst_n)
		begin
			if(~rst_n) 									 count_half <= LENGTH_BAUD_HALF - 1;
			else if (count_bit == 4'd8) 				 count_half <= '0;
			else if (count_half == LENGTH_BAUD_HALF - 1) count_half <= count_half;
			else 										 count_half <= count_half + 1'b1;
		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)												count_bit <= 4'd9;
			else if (~rxd && shift_rxd && ~load)					count_bit <= 4'd0;
			else if (count_bit == 4'd9)								count_bit <= count_bit;
			else if (count_baund == LENGTH_BAUD - 1)				count_bit <= count_bit + 1'b1;

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)					load <= 1'b0;
			else if (ena_rxd) 			load <= 1'b0;
			else if (~rxd && shift_rxd)	load <= 1'b1;

		end

	assign ena_rxd = count_bit == 4'd9 && count_half == LENGTH_BAUD_HALF - 2;
	assign data_o  = shift_data[7:0];		//

endmodule

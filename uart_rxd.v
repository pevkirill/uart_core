  /*
  uart rxd
  09.06.2018
  */
  
module uart_rxd #(
  parameter CLOCK_FREQUENCY = 100_000_000,
  parameter BAUD_RATE       = 115_200
) (
	input        rxd    , //
	input        clk    , //CLOOK
	input        rst_n  , //
	output       ena_rxd, //
	output [7:0] data_o   //
);

localparam LENGTH_BAUD      = (CLOCK_FREQUENCY / BAUD_RATE) ;
localparam LENGTH_BAUD_HALF = (CLOCK_FREQUENCY / BAUD_RATE) / 2   ;

reg [7:0] shift_data      ; //
reg       shift_rxd       ; //
reg [12:0] count_baund     ; //
reg [3:0] count_bit       ; //
reg [9:0] count_half_bound; //
reg       load            ; //
reg       start_bit       ;


	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n) 									shift_data <= 8'b1111_1111;					//
			else if (start_bit == 1'b1)						shift_data <= {1'b0, rxd};					//
			else if (count_baund == LENGTH_BAUD - 1)		shift_data <= {shift_data[7:0], rxd};		//
			else 											shift_data <= shift_data;					//

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n) 				shift_rxd <= 1'b1;		//
			else					shift_rxd <= rxd;			//

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)											count_baund <= LENGTH_BAUD - 1;
			else if (rxd == 1'b0 && shift_rxd == 1'b1)			count_baund <= 9'h0;
			else if (count_bit == 4'd8)							count_baund <= count_baund;
			else if (count_baund == LENGTH_BAUD - 1)			count_baund <= 9'h0;
			else												count_baund <= count_baund + 1'b1;

		end  

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)														count_bit <= 4'd8;
			else if (count_baund == LENGTH_BAUD - 1 && load == 1'b1)		count_bit <= count_bit + 1'b1;
			else if (rxd == 1'b0 && shift_rxd == 1'b1 && load == 1'b0)		count_bit <= 4'd0;
			else if (count_bit == 4'd8)										count_bit <= count_bit;
			else															count_bit <= count_bit;

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)													count_half_bound <= LENGTH_BAUD_HALF - 1;
			else if (count_bit == 4'd7)									count_half_bound <= 9'h0;
			else if (count_half_bound == LENGTH_BAUD_HALF - 1)		    count_half_bound <= count_half_bound;
			else														count_half_bound <= count_half_bound + 1'b1;

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)														load <= 1'b0;
			else if (ena_rxd == 1'b1)	     								load <= 1'b0;
			else if (rxd == 1'b0 && count_baund == LENGTH_BAUD_HALF - 1)	load <= 1'b1;
			else															load <= load;

		end

	always @(posedge clk or negedge rst_n)
		begin
			if (~rst_n)											start_bit <= 1'b0;
			else if (rxd == 1'b0 && count_bit == 4'd0)			start_bit <= 1'b1;
			else												start_bit <= 1'b0;

		end

	assign ena_rxd = count_bit == 4'd8 && count_half_bound == LENGTH_BAUD_HALF - 1;
	assign data_o  = shift_data[7:0];		//

endmodule

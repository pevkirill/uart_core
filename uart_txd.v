module uart_txd 
#(
	 parameter 	 CLOCK_FREQUENCY = 100_000_000,
	 parameter	 BAUD_RATE = 115_200,
	 localparam	 DIV = CLOCK_FREQUENCY/BAUD_RATE
)
(
input 		clk, 	
input [7:0] d, 		
input 		ena,	
input 		rst_n,	
output 		txd,
output 		rts		
);		
 
 reg [8:0] shift_data;			
 reg [9:0] count_baund;			
 reg shift_ena;					
 wire w_ena;					
 reg [3:0] count_bit;			
 reg ready;						
 
 always @(posedge clk or negedge rst_n)			
begin
	if (~rst_n) 						        shift_data <= 9'b1111_11111;
	else if (ready && w_ena) 				shift_data <= {1'b0, d}; 
	else if(count_baund == DIV)     shift_data <= {shift_data[7:0], 1'b1};	
end

 always @(posedge clk or negedge rst_n)
begin
 	if (~rst_n || count_baund == DIV)   count_baund <= 9'h0;
 	else if (ready && w_ena) 			      count_baund <= 9'h0;
	else          						          count_baund <= count_baund + 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
 	if (~rst_n)     shift_ena <= 1'b0;
 	else 			shift_ena <= ena;
end

 always @(posedge clk or negedge rst_n)
 begin 
 	if      (~rst_n) 						          count_bit <= 4'd10;
  	else if (ready && w_ena) 				    count_bit <= 4'd0;
  	else if (count_bit == 4'd10) 		  	count_bit <= count_bit;
  	else if (count_baund == DIV) 		    count_bit <= count_bit + 1'b1;
  	else 									              count_bit <= count_bit;	
end

always @(posedge clk or negedge rst_n)
begin
  	if (~rst_n) 					           ready <= 1'b0;
  	else if (w_ena) 				         ready <= 1'b0;
  	else if (count_bit == 4'd10)     ready <= 1'b1;
  	else							               ready <= ready;
end


 assign rts   = ready;
 assign w_ena = (~shift_ena && ena) ? 1'b1 : 1'b0;
 assign txd   = shift_data[8];

endmodule 

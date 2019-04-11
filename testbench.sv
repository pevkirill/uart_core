`timescale 1ns/1ns
module testbench;

 logic        clk_i;
 logic        rst_n;
 logic [3:0]  addres;
 logic [7:0]  data_i;
 logic        write;
 logic        read;

parameter xtal_CLK = 100_000_000,
			  baud = 115_200,
	 halfperiod_50 = 25/2;	// 50 mHz

/*------------------------------------------------------------------------------
 --  generator clock
 ------------------------------------------------------------------------------*/ 
initial begin
	clk_i = 1'b0;
	forever #(halfperiod_50) clk_i=~clk_i;
end

initial begin 
    rst_n  = 1'b0;
    addres = 4'h0;
    write  = 1'b0;
    read   = 1'b0;
    data_i = 8'h0;
    $display("running testbench");
@(posedge clk_i);
    rst_n = 1;
@(ready);
    addres = 4'd1;
    write  = 1'b1;
    read   = 1'b0;
    data_i = 8'h13;
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
@(ready);
    addres = 4'd2;
    write  = 1'b1;
    read   = 1'b0;
    data_i = 8'h19;
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
@(ready);
    addres = 4'd3;
    write  = 1'b1;
    read   = 1'b0;
    data_i = 8'h21;
@(ready);
write  = 1'b0;
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);

   #500000 $display("end");
   $stop;
end

uart_core uart_core_inst
(
    .clk_i              (clk_i), 
    .arst_n_i           (rst_n), 

    .avms_address_i     (addres),
    .avms_read_i        (read),
    .avms_write_i       (write),
    .avms_writedata_i   (data_i),
    .ready              (ready),
    .avms_readdata_o    (),

    .uart_txd_o         ()
);

endmodule // testbench


`timescale 1ns/1ns
module testbench;

 logic        clk_i;
 logic        rst_n;
 logic [3:0]  addres;
 logic [7:0]  data_i;
 logic        write;
 logic        read;

parameter    xtal_CLK = 100_000_000,
			     baud = 115_200;
localparam halfperiod = 1_000_000_000/xtal_CLK/2;

/*------------------------------------------------------------------------------
 --  generator clock
 ------------------------------------------------------------------------------*/ 
initial begin
	clk_i = 1'b0;
	forever #(halfperiod) clk_i=~clk_i;
end

initial begin 
    rst_n  = 1'b0;
    write  = 1'b0;
    read   = 1'b0;
    data_i = 8'h0;
$display("Running testbench. Testbench is works on frequency = ", xtal_CLK, " MHz");
@(posedge clk_i);
    rst_n = 1;
@(posedge clk_i);
    write  = 1'b1;
    data_i = 8'h13;
    addres = 4'h2;
@(posedge clk_i);
    write  = 1'b1;
    data_i = 8'h63;
    addres = 4'h0;///
@(posedge clk_i);
    write  = 1'b1;
    data_i = 8'h93;
    addres = 4'h2;
@(posedge clk_i);
    write  = 1'b1;
    data_i = 8'h17;
    addres = 4'h0;
@(posedge clk_i);
    write  = 1'b1;
    data_i = 8'h97;
    addres = 4'h2;
@(posedge clk_i);

   #500000 $display("stop testbench");
   $stop;
end

uart_core #(.CLK_FREQ  (xtal_CLK),
            .BAUD_RATE (baud   ))
                     uart_core_inst
(
    .clk_i              (clk_i ), 
    .arst_n_i           (rst_n ), 

    .avms_address_i     (addres),
    .avms_read_i        (read  ),
    .avms_write_i       (write ),
    .avms_writedata_i   (data_i),
    .avms_readdata_o    (),

    .uart_txd_o         ()
);

endmodule // testbench


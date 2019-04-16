`timescale 1ns/1ns
module testbench;

 logic        clk_i;
 logic        rst_n;
 logic [3:0]  address;
 logic [7:0]  data_i;
 logic        write;
 logic        read;
 logic [7:0]  busy;
 logic        data_txd;

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
    busy   = '0;
    address = 4'h0;
$display("Running testbench. Testbench is works on frequency = ", xtal_CLK, " Hz");
@(posedge clk_i);
    rst_n = 1'b1;
forever #(1) begin
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
    read = 1'b1;
    address = 4'h1;
@(posedge clk_i);
    read = 1'b0;
@(posedge clk_i)
if (busy[0]==1'b1) begin 
    write = 1'b1;
    address = 4'h0;
    data_i = 8'h17;
@(posedge clk_i);
    write = 1'b0;
    address = 4'h1;
    data_i = 8'h0;
end
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
    read = 1'b1;
    address = 4'h1;
@(posedge clk_i);
    read = 1'b0;
@(posedge clk_i)
if (busy[0]==1'b1) begin 
    write = 1'b1;
    address = 4'h0;
    data_i = 8'h99;
@(posedge clk_i);
    write = 1'b0;
    address = 4'h1;
    data_i = 8'h0;
end
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
    read = 1'b1;
    address = 4'h1;
@(posedge clk_i);
    read = 1'b0;
@(posedge clk_i)
if (busy[0]==1'b1) begin 
    write = 1'b1;
    address = 4'h0;
    data_i = 8'h87;
@(posedge clk_i);
    write = 1'b0;
    address = 4'h1;
    data_i = 8'h0;
end
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
    read = 1'b1;
    address = 4'h1;
@(posedge clk_i);
    read = 1'b0;
@(posedge clk_i)
if (busy[0]==1'b1) begin 
    write = 1'b1;
    address = 4'h0;
    data_i = 8'h37;
@(posedge clk_i);
    write = 1'b0;
    address = 4'h1;
    data_i = 8'h0;
end
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
    read = 1'b1;
    address = 4'h1;
@(posedge clk_i);
    read = 1'b0;
@(posedge clk_i)
if (busy[0]==1'b1) begin 
    write = 1'b1;
    address = 4'h0;
    data_i = 8'h57;
@(posedge clk_i);
    write = 1'b0;
    address = 4'h1;
    data_i = 8'h0;
end
@(posedge clk_i);
@(posedge clk_i);
@(posedge clk_i);
    read = 1'b1;
    address = 4'h1;
@(posedge clk_i);
    read = 1'b0;
@(posedge clk_i)
if (busy[0]==1'b1) begin 
    write = 1'b1;
    address = 4'h0;
    data_i = 8'h47;
@(posedge clk_i);
    write = 1'b0;
    address = 4'h1;
    data_i = 8'h0;
end

end
#500000 $display("stop testbench");///this kusok code don't work's
   $stop;
end

uart_core #(.CLK_FREQ  (xtal_CLK),
            .BAUD_RATE (baud   ))
                     uart_core_inst
(
    .clk_i              (clk_i ), 
    .arst_n_i           (rst_n ), 

    .avms_address_i     (address),
    .avms_read_i        (read  ),
    .avms_write_i       (write ),
    .avms_writedata_i   (data_i),
    .avms_readdata_o    (busy  ),

    .uart_txd_o         (data_txd)
);

endmodule // testbench


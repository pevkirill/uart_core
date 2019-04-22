`timescale 1ns/1ns
module testbench;

logic       clk_i   ;
logic       rst_n   ;
logic [3:0] address ;
logic [7:0] data_i  ;
logic       write   ;
logic       read    ;
logic [7:0] busy    ;
logic       data_txd;
logic [7:0] data_o  ;

parameter    XTAL_CLK = 100_000_000,
			     BAUD = 115_200;
localparam HALFPERIOD = 1_000_000_000/XTAL_CLK/2;

/*------------------------------------------------------------------------------
 --  generator clock
 ------------------------------------------------------------------------------*/ 
initial begin
	clk_i = 1'b0;
	forever #(HALFPERIOD) clk_i=~clk_i;
end

initial begin
    rst_n  = 1'b0;
    write  = 1'b0;
    read   = 1'b0;
    data_i = 8'h0;
    busy   = '0;
    address = 4'hx;
    data_o = '0;
    $display("Running testbench. Testbench is works on frequency = ", XTAL_CLK, " Hz");
    @(posedge clk_i);
    rst_n = 1'b1;

ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h13);
ReadUart(4'h1, data_o);
@(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h37);
ReadUart(4'h1, data_o);
@(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h17);
ReadUart(4'h1, data_o);
@(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h19);
ReadUart(4'h1, data_o);
@(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h21);
ReadUart(4'h1, data_o);
@(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h99);
ReadUart(4'h1, data_o);
@(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h41);
ReadUart(4'h1, data_o);
@(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_o);
WriteUart(4'h0, 8'h55);

#500000 $display("stop testbench");
   $stop;
end

task ReadUart;
    input [3:0] addr_r;
    output [7:0] data;

    begin 
        @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        read = 1'b1;
        address = addr_r;
        data = data_o;
        @(posedge clk_i);
        read = 1'b0;
        address = 4'h1;    
    end

endtask : ReadUart

task WriteUart;
    input [3:0] addr_w;
    input [7:0] data;

    begin
        @(posedge clk_i);
        if (busy[0]==1'b1) begin
        @(posedge clk_i);
        @(posedge clk_i);
            write = 1'b1;
            address = addr_w;
            data_i = data;
            @(posedge clk_i);
            write = 1'b0;
            address = 4'h1;
            data_i = 8'h0;
            end
    end

endtask : WriteUart


logic [7:0] memory [7:0];

always @(address or write or read)
begin 
    if (write) begin 
        memory[address] = data_i;
    end
    if (read) begin 
        data_o = memory[0];
    end
end

logic true_data_uart;

assign true_data_uart = (memory[0] == data_i) ? 1'b1 : 1'b0;

uart_core #(
    .CLK_FREQ (XTAL_CLK),
    .BAUD_RATE(BAUD    ))
                     uart_core_inst 
(
    .clk_i           (clk_i   ),
    .arst_n_i        (rst_n   ),
    
    .avms_address_i  (address ),
    .avms_read_i     (read    ),
    .avms_write_i    (write   ),
    .avms_writedata_i(data_i  ),
    .avms_readdata_o (busy    ),
    
    .uart_txd_o      (data_txd)
);

endmodule // testbench


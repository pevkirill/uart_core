`timescale 1ns/1ns
module testbench;

logic       clk_i         ;
logic       rst_n         ;
logic [3:0] address       ;
logic [7:0] data_i        ;
logic       write         ;
logic       read          ;
logic       data_txd      ;
logic [7:0] data_o        ;
logic [7:0] data_r        ;
logic [7:0] busy          ;
logic [7:0] memory  [11:0];

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
    forever @(posedge clk_i) busy = data_r;
end

initial begin
    rst_n  = 1'b0;
    write  = 1'b0;
    read   = 1'b0;
    data_i = 8'h0;
    address = 4'h1;
    memory = {8'h48, 8'h45, 8'h4c, 8'h4c, 8'h4f, 8'h5f, 8'h57, 8'h4f, 8'h52, 8'h4c, 8'h44, 8'h21};
    $display("Running testbench. Testbench is works on frequency = ", XTAL_CLK, " Hz");
    @(posedge clk_i);
    rst_n = 1'b1;

ReadUart(4'h1, data_r);
 @(posedge clk_i);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);
if   (busy[0]==1) WriteUart(4'h0, data_mem);
while(busy[0]==1) ReadUart(4'h1, data_r);
while(busy[0]==0) ReadUart(4'h1, data_r);


#500000 $display("stop testbench");
   $stop;
end

task ReadUart;
    input [3:0] addr_r;
    output [7:0] data_r;

    begin 
        @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        read = 1'b1;
        address = addr_r;
        data_r = data_o;
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

endtask : WriteUart

initial begin
forever @(posedge write)
begin
    memory[0]  <= memory[11];
    memory[1]  <= memory[0];
    memory[2]  <= memory[1];
    memory[3]  <= memory[2];
    memory[4]  <= memory[3];
    memory[5]  <= memory[4];
    memory[6]  <= memory[5];
    memory[7]  <= memory[6];
    memory[8]  <= memory[7];
    memory[9]  <= memory[8];
    memory[10] <= memory[9];
    memory[11] <= memory[10];
end
end

logic [7:0] data_mem;

initial begin 
    forever @(posedge clk_i) data_mem = memory[11];
end


uart_core #(.CLK_FREQ (XTAL_CLK),.BAUD_RATE(BAUD)) uart_core_inst
(
    .clk_i           (clk_i   ),
    .arst_n_i        (rst_n   ),
    
    .avms_address_i  (address ),
    .avms_read_i     (read    ),
    .avms_write_i    (write   ),
    .avms_writedata_i(data_i  ),
    .avms_readdata_o (data_o  ),
    
    .uart_txd_o      (data_txd)
);

endmodule // testbench


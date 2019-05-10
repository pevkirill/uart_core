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
localparam SIZE_MEMORY = 12 ;
logic [7:0] memory  [SIZE_MEMORY];

parameter    XTAL_CLK = 100_000_000,
BAUD = 115_200;
localparam HALFPERIOD      = 1_000_000_000/XTAL_CLK/2;
localparam STATUS_ADDR_REG = 4'h1                    ;
localparam TXDATA_ADDR_REG = 4'h0                    ;

logic [7:0] check_uart;///
localparam DIV = XTAL_CLK/BAUD;///
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
    check_uart = '0;
    memory = {8'h48, 8'h45, 8'h4c, 8'h89, 8'h4f, 8'h5f, 8'h57, 8'h66, 8'h52, 8'h99, 8'h44, 8'h21};
    $display("Running testbench. Testbench is works on frequency = ", XTAL_CLK, " Hz");
    @(posedge clk_i);
    rst_n = 1'b1;

    ReadUart(4'h1, data_r);

    @(posedge clk_i);
    for (int i = 0; i < SIZE_MEMORY; i++) begin
        while(busy[0]==0) ReadUart(STATUS_ADDR_REG, data_r);
        if   (busy[0]==1) WriteUart(TXDATA_ADDR_REG, memory[i]);
        while(busy[0]==1) ReadUart(STATUS_ADDR_REG, data_r);
    end

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
    forever begin
        @(posedge write);
        for (int j = 0; j < DIV*10; j++) begin
            @(posedge clk_i);
            if (j==DIV*1+2) begin
                check_uart[7] = data_txd;
            end
            if (j==DIV*2+5) begin
                check_uart[6] = data_txd;
            end
            if (j==DIV*3+10) begin
                check_uart[5] = data_txd;
            end
            if (j==DIV*4+15) begin
                check_uart[4] = data_txd;
            end
            if (j==DIV*5+20) begin
                check_uart[3] = data_txd;
            end
            if (j==DIV*6+25) begin
                check_uart[2] = data_txd;
            end
            if (j==DIV*7+30) begin
                check_uart[1] = data_txd;
            end
            if (j==DIV*8+35) begin
                check_uart[0] = data_txd;
            end
            if(j==DIV*9+13 && data_txd) begin
                for (int g = 0; g < SIZE_MEMORY; g++) begin
                    if(check_uart == memory[g]) begin
                        $display("uart data is correct", check_uart);
                    end 
                end
            end
        end
    end
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


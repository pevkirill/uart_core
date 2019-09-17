`timescale 1ns/1ns
module testbench;

logic       clk_i         ;
logic       rst_n         ;
logic [3:0] address       ;
logic [7:0] data_i        ;
logic       write         ;
logic       read          ;
logic       data_txd      ;
logic       data_rxd      ;
logic [7:0] data_o        ;
logic [7:0] data_r        ;
localparam SIZE_MEMORY = 12 ;
logic [7:0] memory  [SIZE_MEMORY];

logic interrupt;
logic [7:0] check_uart;///

parameter    XTAL_CLK = 100_000_000,
    BAUD = 115_200;
localparam HALFPERIOD      = 1_000_000_000/XTAL_CLK/2;
localparam DIV             = XTAL_CLK/BAUD           ;
localparam STATUS_ADDR_REG = 4'h1                    ;
localparam TXDATA_ADDR_REG = 4'h0                    ;
localparam ADDR_IRQ        = 4'h2                    ;
/*------------------------------------------------------------------------------
 --  generator clock
 ------------------------------------------------------------------------------*/
initial begin
    clk_i = 1'b0;
    forever #(HALFPERIOD) clk_i=~clk_i;
end

initial begin
    for (int g = 1; g < 3; g++) begin
        repeat (g*11*DIV) @(posedge clk_i);
        for (int el = 0; el < 2; el++) begin
            if(el == 1) begin
                data_rxd=1'b0; //start bit
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b0; //packet data 'h6e
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b0;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b0;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;  //stop bit
                read = '1;
                address = 4'd2;
                @(posedge clk_i);
                read = '0;
                repeat (1*DIV) @(posedge clk_i);
            end else begin 
                data_rxd=1'b0; //start bit
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1; //packet data 'h
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b0;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b0;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b0;
                repeat (1*DIV) @(posedge clk_i);
                data_rxd=1'b1;  //stop bit
                read = '1;
                address = 4'd2;
                @(posedge clk_i);
                read = '0;
                repeat (1*DIV) @(posedge clk_i);
            end
        end
    end
end

initial begin
    rst_n  = 1'b0;
    write  = 1'b0;
    read   = 1'b0;
    data_i = 8'h0;
    address = 4'h1;
    check_uart = '0;
    data_r = 0;
    data_rxd = '1;
    memory = {8'h48, 8'h45, 8'h4c, 8'h89, 8'h4f, 8'h5f, 8'h57, 8'h66, 8'h52, 8'h99, 8'h44, 8'h21};
    $display("Running testbench. Testbench is works on frequency = ", XTAL_CLK, " Hz");
    @(posedge clk_i);
    #5;
    rst_n = 1'b1;
    @(posedge clk_i);


for (int i = 0; i < SIZE_MEMORY; i++) begin
    if(~interrupt) begin
        do begin
            ReadUart(STATUS_ADDR_REG, data_r);
        end while(data_r[0] == 0);
            WriteUart(TXDATA_ADDR_REG, memory[i]);
    end
end


    #(11*DIV*SIZE_MEMORY) $display("stop testbench");
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
        @(posedge clk_i);
        #1;
        data_r = data_o;
        read = 1'b0;
    end
endtask : ReadUart


task WriteUart;
    input [3:0] addr_w;
    input [7:0] data_w;

    begin
        @(posedge clk_i);
        @(posedge clk_i);
        @(posedge clk_i);
        write = 1'b1;
        address = addr_w;
        data_i = data_w;
        @(posedge clk_i);
        write = 1'b0;
        data_i = 8'h0;
    end

endtask : WriteUart


initial begin
    forever begin
        @(data_r[0]);
        @(posedge clk_i);
        repeat (DIV+31) @(posedge clk_i);
        check_uart[7] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        check_uart[6] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        check_uart[5] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        check_uart[4] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        check_uart[3] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        check_uart[2] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        check_uart[1] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        check_uart[0] = data_txd;
        repeat (DIV+3) @(posedge clk_i);
        for (int j = 0; j < SIZE_MEMORY; j++) begin
            if(check_uart == memory[j]) begin
                $display("uart data is correct %h", check_uart);
            end 
        end
    end
end

uart_core #(.CLK_FREQ(XTAL_CLK), .BAUD_RATE(BAUD)) uart_core_inst (
    .clk_i           (clk_i    ),
    .arst_n_i        (rst_n    ),
    
    .avms_address_i  (address  ),
    .avms_read_i     (read     ),
    .avms_write_i    (write    ),
    .avms_writedata_i(data_i   ),
    .avms_readdata_o (data_o   ),
    
    .uart_txd_o      (data_txd ),
    .uart_rxd_i      (data_rxd ),

    .IRQ_event       (interrupt)
);

endmodule // testbench

`timescale 1ns/1ns
module testbench;

bit       clk_i         ;
bit       rst_n         ;
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
logic [0:7] check_uart;
bit avms_byteenable_i;

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

    fork
        begin : first_process // RxD
            for (int g = 10; g < 20; g++) begin
                if(~data_r[1]) begin
                    Data_RxD(g,g);
                    #(9*DIV);
                end
            end
        end
        begin : second_process // TxD
            for (int i = 0; i < SIZE_MEMORY; i++) begin
                do begin
                    //IRQ();
                    ReadUart(STATUS_ADDR_REG, data_r);
                end while(~data_r[0]);
                    WriteUart(TXDATA_ADDR_REG, memory[i], 1'b1);
            end
        end
        begin : third_process // Check txd data
            while(~data_r[0]) begin
                Check_Uart();
            end
        end
    join


    #(12*DIV*SIZE_MEMORY) $display("stop testbench");
    $stop;
end
/*------------------------------------------------------------------------------
--  data is not correct
------------------------------------------------------------------------------*/
initial begin 
    #316939;
    Data_RxD(8'h7f, 8'hd);
end


task wait_clocks(int i );
    repeat (i) @(posedge clk_i) #1;
endtask : wait_clocks


task Data_RxD;
    input bit [0:7] data_to_send;
    input bit [7:0] check;
    begin
        data_rxd=1'b0; //start bit
        repeat (DIV) @(posedge clk_i);
        for (int i = 0; i < 8; i++) begin
            data_rxd = data_to_send[i]; //packet data
            repeat (DIV) @(posedge clk_i);
        end
        data_rxd=1'b1;  //stop bit
        repeat (DIV/2) @(posedge clk_i);
        address = 4'd2;
        $display("interrupt");
        wait_clocks(1);
        address = 4'd1;
        repeat (DIV/2) @(posedge clk_i);
        if(check == data_to_send) begin
            $display("data is correct ", check);
        end else $display("!!! data isn't correct. uart RxD over !!! ", data_to_send);

    end

endtask : Data_RxD

/*
task IRQ;
    begin 
        if(interrupt) begin
            address = 4'd2;
            $display("interrupt"); 
            wait_clocks(1);
            address = 4'd1;
        end
    end

endtask : IRQ
*/

task ReadUart;
    input [3:0] addr_r;
    output [7:0] data_r;

    begin
        wait_clocks(3);
        read = 1'b1;
        address = addr_r;
        wait_clocks(1);
        data_r = data_o;
        read = 1'b0;
        #1;

    end
endtask : ReadUart


task WriteUart;
    input [3:0] addr_w;
    input [7:0] data_w;
    input bit byteenable;

    begin
        wait_clocks(3);
        write = 1'b1;
        address = addr_w;
        data_i = data_w;
        avms_byteenable_i = byteenable;
        wait_clocks(1);
        write = 1'b0;
        data_i = 8'h0;
    end

endtask : WriteUart


task Check_Uart;

    begin 
        repeat(DIV+31) @(posedge clk_i);
        for (int q = 0; q < 8; q++) begin
            check_uart[q] = data_txd;
            repeat(DIV+3) @(posedge clk_i);
        end
        repeat(DIV+3) @(posedge clk_i);
        $display("data %h", check_uart);
        @(posedge clk_i);
        check_uart = '0;
    end

endtask : Check_Uart


uart_core #(.CLK_FREQ(XTAL_CLK), .BAUD_RATE(BAUD)) uart_core_inst (
    .clk_i            (clk_i            ),
    .arst_n_i         (rst_n            ),
    
    .avms_address_i   (address          ),
    .avms_byteenable_i(avms_byteenable_i),
    .avms_read_i      (read             ),
    .avms_write_i     (write            ),
    .avms_writedata_i (data_i           ),
    .avms_readdata_o  (data_o           ),
    
    .uart_txd_o       (data_txd         ),
    .uart_rxd_i       (data_rxd         ),
    
    .IRQ_event        (interrupt        )
);

endmodule // testbench

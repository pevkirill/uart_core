
/*-------------------------------------------------------------------------------------
--     _____________         __________        ________          _________
      |            |        |         |    8   |       |        |         |
      |Hello world!|  <-----|uart_txd | <==/===|slave  | <======|testbech |
      /            /        |_________|        |_______|        |_________|
     /____________/
---------------------------------------------------------------------------------------*/

module uart_core #(
    parameter int unsigned CLK_FREQ = 100_000_000, // freq of clk_i (Hz)
    parameter int unsigned BAUD_RATE = 115_200 //  (Hz)
    )(
    input              clk_i         , // Clock
    input              arst_n_i      , // Asynchronous reset active low

    input  logic [3:0] avms_address_i     ,
    input  logic       avms_read_i        ,
    input  logic       avms_write_i       ,
    input  logic [7:0] avms_writedata_i   ,
    output logic [7:0] avms_readdata_o    ,

    output logic       uart_txd_o
);

logic [7:0] txdata;
logic [7:0] busy;
logic [7:0] data_i;
logic valid;
logic ready;
logic enable;

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_busy
    if(~arst_n_i) begin
        busy[0] = '0;
        busy[1] = '0;
        busy[2] = '0;
        busy[3] = '0;
        busy[4] = '0;
        busy[5] = '0;
        busy[6] = '0;
        busy[7] = '0;
    end else if (avms_address_i == 4'h1 || avms_address_i == 4'h2 || avms_address_i == 4'h3) begin 
        busy <= 1'b1;
    end else if (ready) begin
        busy <= 1'b0;
    end else begin 
        busy <= 1'b1;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_uart_data
    if(~arst_n_i) begin
        txdata <= '0;
    end else if (busy == 8'h0) begin
        txdata <= data_i;
    end else begin
        txdata <= txdata;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_enable
    if(~arst_n_i) begin
        enable <= 0;
    end else if (busy == 8'h0 && avms_write_i) begin
        enable <= 1'b1;
    end else begin 
        enable <= 1'b0;
    end
end

slave_mm                       slave_mm_inst
(        
    .clk_i                     (clk_i            ),
    .arst_n_i                  (arst_n_i         ),
    .avs_address_i             (avms_address_i   ),
    .avs_read_i                (avms_read_i      ),
    .avs_write_i               (avms_write_i     ),
    .avs_writedata_i           (avms_writedata_i ),
    .avs_readdata_o            (avms_readdata_o  ),
    .valid                     (valid            ),
    .data_o                    (data_i           )
);

uart_txd #(.clock_frequency  (CLK_FREQ),
           .baud_rate        (BAUD_RATE))
                              uart_txd_inst
(
    .clk                       (clk_i            ),
    .rst_n                     (arst_n_i         ),
    .d                         (txdata           ),
    .ena                       (enable           ),
    .txd                       (uart_txd_o       ),    
    .rts                       (ready            )
);


endmodule

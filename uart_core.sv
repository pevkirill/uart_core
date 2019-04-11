
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
    input  logic       ready              ,
    output logic [7:0] avms_readdata_o    ,

    output logic       uart_txd_o
);

logic [7:0] uart_data;
logic busy;
logic [7:0] data_i;
logic enable;
logic valid;

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_enable
    if(~arst_n_i || ~avms_write_i) begin
        enable <= 0;
    end else if (ready && ~busy) begin
        enable <= 1'b1;
    end else begin 
        enable <= 1'b0;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_busy
    if(~arst_n_i) begin
        busy <= 0;
    end else begin
        busy <= ~ready;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_uart_data
    if(~arst_n_i) begin
        uart_data <= 0;
    end else if (~busy) begin
        uart_data <= data_i;
    end else if (busy) begin
        uart_data <= uart_data;
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
    .ready                     (ready            ),
    .avs_readdata_o            (avms_readdata_o  ),
    .valid                     (valid            ),
    .data_o                    (data_i           )
);

uart_txd                       uart_txd_inst
(
    .clk                       (clk_i            ),
    .rst_n                     (arst_n_i         ),
    .d                         (uart_data        ),
    .ena                       (enable           ),
    .txd                       (uart_txd_o       ),    
    .rts                       (ready            )
);


endmodule

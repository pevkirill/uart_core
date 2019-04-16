
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
logic valid;

slave_mm                       slave_mm_inst
(        
    .clk_i                     (clk_i            ),
    .arst_n_i                  (arst_n_i         ),
    .avs_address_i             (avms_address_i   ),
    .avs_read_i                (avms_read_i      ),
    .avs_write_i               (avms_write_i     ),
    .ready                     (ready            ),
    .avs_writedata_i           (avms_writedata_i ),
    .avs_readdata_o            (avms_readdata_o  ),
    .valid                     (valid            ),
    .data_o                    (txdata           )
);

uart_txd #(.clock_frequency  (CLK_FREQ),
           .baud_rate        (BAUD_RATE))
                              uart_txd_inst
(
    .clk                       (clk_i            ),
    .rst_n                     (arst_n_i         ),
    .d                         (txdata           ),
    .ena                       (valid            ),
    .txd                       (uart_txd_o       ),    
    .rts                       (ready            )
);


endmodule


/*-------------------------------------------------------------------------------------
--     _____________         __________        ________          _________
      |            |        |         |    8   |       |    8   |         |
      |Hello world!|  <-----|uart_txd | <==/===|slave  | <==/===|testbech |
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
    //uart
    output logic       uart_txd_o         ,
    input  logic       uart_rxd_i         ,
    //interrupt
    output logic       IRQ_event
);

logic [7:0] data_TxD;
logic [7:0] rxdata  ;
logic       valid   ;
logic       ready   ;
logic       enable  ;

assign valid = (avms_write_i && avms_address_i == 4'd0 && ready) ? 1'b1 : 1'b0;

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_IRQ_event
    if(~arst_n_i) begin
        IRQ_event <= '0;
    end else if (~enable) begin
        IRQ_event <= '1;
    end else begin 
        IRQ_event <= '0;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_data_TxD
    if(~arst_n_i) begin
        data_TxD <= 0;
    end else if(avms_write_i && avms_address_i == 4'd0) begin
        data_TxD <= avms_writedata_i;
    end
end

always @(posedge clk_i or negedge arst_n_i)
    begin
        if (~arst_n_i) avms_readdata_o <= '0;
        else if (avms_read_i) begin
            case (avms_address_i)
                4'd0 : avms_readdata_o  <= data_TxD;
                4'd1 : avms_readdata_o  <= {{7{1'b0}}, ready};
                4'd2 : avms_readdata_o  <= rxdata;

                default : begin
                    avms_readdata_o <= avms_readdata_o;
                end
            endcase
        end
    end


uart_txd #(.CLOCK_FREQUENCY  (CLK_FREQ ),
           .BAUD_RATE        (BAUD_RATE))
                              uart_txd_inst
(
    .clk                       (clk_i              ),
    .rst_n                     (arst_n_i           ),
    .d                         (data_TxD           ),
    .ena                       (valid              ),
    .txd                       (uart_txd_o         ),
    .ready                     (ready              )
);

uart_rxd #(.CLOCK_FREQUENCY  (CLK_FREQ ),
           .BAUD_RATE        (BAUD_RATE))
                              uart_rxd_inst
(
    .clk          (clk_i      ),
    .rst_n        (arst_n_i   ),
    .rxd          (uart_rxd_i ),
    .ena_rxd      (enable     ),
    .data_o       (rxdata     )
);

endmodule

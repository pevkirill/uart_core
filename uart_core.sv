
/*-------------------------------------------------------------------------------------
--     _____________         __________        ________          _________
      |            |        |         |    8   |       |    8   |         |
      |Hello world!|  <-----|uart_txd | <==/===|slave  | <==/===|testbech |
      /            /        |_________|        |_______|        |_________|
     /____________/
---------------------------------------------------------------------------------------*/

module uart_core #(
    parameter int unsigned CLK_FREQ  = 100_000_000, // freq of clk_i (Hz)
    parameter int unsigned BAUD_RATE = 115_200      //  (Hz)
) (
    input               clk_i            , // Clock
    input               arst_n_i         , // Asynchronous reset active low
    input  logic [ 3:0] avms_address_i   ,
    input  logic [ 3:0] avms_byteenable_i,
    input  logic        avms_read_i      ,
    input  logic        avms_write_i     ,
    input  logic [31:0] avms_writedata_i ,
    output logic [31:0] avms_readdata_o  ,
    //uart
    output logic        uart_txd_o       ,
    input  logic        uart_rxd_i       ,
    //interrupt
    output logic        IRQ_event
);

    localparam LENGTH_BAUD      = (CLK_FREQ / BAUD_RATE) - 1     ; 
    localparam LENGTH_BAUD_HALF = (CLK_FREQ / BAUD_RATE) / 2 - 1 ;

logic [7:0] data_TxD;
logic [7:0] data_RxD;
logic       valid   ;
logic       ready   ;
logic       enable  ;
/// for busy
logic                           shift_data;
logic [$clog2(LENGTH_BAUD):0]   cnt_bound ;
logic [                  3:0]   cnt_bit   ;
logic                           busy      ;

logic [3:0][31:0] read_regs    ;
logic [3:0][31:0] write_regs   ;
logic [3:0]       word_valid_rd;

assign valid = (avms_write_i && avms_address_i == 4'd0 && ready) ? 1'b1 : 1'b0;

always @(posedge clk_i)
    begin
        read_regs[0] <= {24'd0, data_TxD};
        read_regs[1] <= {30'd0, busy, ready};
        read_regs[2] <= {24'd0, data_RxD};
        read_regs[3] <= '0;
    end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_data_TxD
    if(~arst_n_i) begin
        data_TxD <= '0;
    end else if(avms_write_i && avms_address_i == 4'd0) begin
        data_TxD <= write_regs[0][7:0];
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_IRQ_event
    if(~arst_n_i) begin
        IRQ_event <= '0;
    end else if (word_valid_rd == 4'h4) begin
        IRQ_event <= '0;
    end else if (shift_data && ~uart_rxd_i) begin 
        IRQ_event <= '1;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_shift_data
    if(~arst_n_i) begin
        shift_data <= 0;
    end else begin
        shift_data <= uart_rxd_i;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_cnt_bound
    if(~arst_n_i) begin
        cnt_bound <= '0;
    end else if(shift_data && ~uart_rxd_i) begin
        cnt_bound <= '0;
    end else if(busy && cnt_bound < LENGTH_BAUD_HALF) begin
        cnt_bound <= cnt_bound + 1'b1;
    end else if(cnt_bit == 4'd9) begin
        cnt_bound <= cnt_bound;
    end else if(cnt_bound == LENGTH_BAUD) begin
        cnt_bound <= '0;
    end else begin
        cnt_bound <= cnt_bound + 1'b1;
    end
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_cnt_bit
    if(~arst_n_i) begin
        cnt_bit <= 4'd9;
    end else if(shift_data && ~uart_rxd_i && ~busy) begin
        cnt_bit <= '0;
    end else if(cnt_bit == 4'd9) begin
        cnt_bit <= cnt_bit;
    end else if(cnt_bound == LENGTH_BAUD) begin
        cnt_bit <= cnt_bit + 1'b1;
    end 
end

always_ff @(posedge clk_i or negedge arst_n_i) begin : proc_busy
    if(~arst_n_i) begin
        busy <= 0;
    end else if(cnt_bit == 4'd9 && cnt_bound == LENGTH_BAUD_HALF - 1) begin
        busy <= '0;
    end else if(cnt_bit == 4'd0) begin
        busy <= '1;
    end
end

uart_txd #(.CLOCK_FREQUENCY  (CLK_FREQ ),
           .BAUD_RATE        (BAUD_RATE))
                              uart_txd_inst
(
    .clk                      (clk_i       ),
    .rst_n                    (arst_n_i    ),
    .d                        (data_TxD    ),
    .ena                      (valid       ),
    .txd                      (uart_txd_o  ),
    .ready                    (ready       )
);

uart_rxd #(.CLOCK_FREQUENCY  (CLK_FREQ ),
           .BAUD_RATE        (BAUD_RATE))
                              uart_rxd_inst
(
    .clk                      (clk_i      ),
    .rst_n                    (arst_n_i   ),
    .rxd                      (uart_rxd_i ),
    .ena_rxd                  (enable     ),
    .data_o                   (data_RxD   )
);

av_univ_regs #(
    .DW      (32),
    .AW      (4 ),
    .REGS_NUM(4 )
) av_univ_regs_inst (
    .clk_i          (clk_i            ),
    .reset_n_i      (arst_n_i         ),
    .avms_address   (avms_address_i   ),
    .avms_byteenable(avms_byteenable_i),
    .avms_read      (avms_read_i      ),
    .avms_readdata  (avms_readdata_o  ),
    .avms_write     (avms_write_i     ),
    .avms_writedata (avms_writedata_i ),
    .word_valid_wr_o(                 ),
    .mst_word_o     (write_regs       ),
    .slv_word_i     (read_regs        ),
    .word_valid_rd_o(word_valid_rd    )
);

endmodule

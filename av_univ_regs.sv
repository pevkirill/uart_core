module av_univ_regs #(
    parameter                            DW            = 32                    ,
    parameter                            AW            = 16                    ,
    parameter                            REGS_NUM      = 2                     ,
    parameter bit [REGS_NUM-1:0][DW-1:0] REGS_INIT     = '{default:'0}         ,
    parameter                            BYTES_IN_WORD = DW/8                  ,
    parameter                            BYTES_NUM     = REGS_NUM*BYTES_IN_WORD
) (
    input                               clk_i          , // Clock
    input                               reset_n_i      ,
    input        [      AW-1:0]         avms_address   ,
    input        [    DW/8-1:0]         avms_byteenable,
    input                               avms_read      ,
    output logic [      DW-1:0]         avms_readdata  ,
    input                               avms_write     ,
    input        [      DW-1:0]         avms_writedata ,
    output logic [REGS_NUM-1:0]         word_valid_wr_o,
    output logic [REGS_NUM-1:0][DW-1:0] mst_word_o     ,
    input  logic [REGS_NUM-1:0][DW-1:0] slv_word_i     ,
    output logic [REGS_NUM-1:0]         word_valid_rd_o
);

    /*------------------------------------------------------------------------------
    --  Declare
    ------------------------------------------------------------------------------*/
    typedef struct packed {
        logic [REGS_NUM-1:0][DW-1:0] regs;
    } regs_words_t;

    typedef logic [7:0] byte_t;
    typedef struct packed {
        byte_t byte_reg;
    } regs_bytes_t;
    regs_bytes_t [BYTES_NUM-1:0] mst_regs_av;//,slv_regs_av;

    logic [BYTES_NUM-1:0] byte_valid_wr;//,byte_valid_rd;
    logic [BYTES_IN_WORD-1:0][7:0]avms_writedata_bytes;

    /*------------------------------------------------------------------------------
    --  Functional
    ------------------------------------------------------------------------------*/
    // Comb logic
    always_comb begin
        for (int unsigned ind_bytes = 0; ind_bytes < BYTES_NUM; ind_bytes++) begin
            byte_valid_wr[ind_bytes] = avms_byteenable[ind_bytes%(BYTES_IN_WORD)] &&
                                    avms_address == (ind_bytes/(BYTES_IN_WORD)) && avms_write ;
        end
    end

    assign avms_writedata_bytes = avms_writedata;
    // Sequential logic
    always_ff @(posedge clk_i or negedge reset_n_i) begin : proc_mst_regs_av
        if(~reset_n_i) begin
            mst_regs_av        <= REGS_INIT;
            word_valid_rd_o    <= '0;
            word_valid_wr_o    <= '0;
        end else begin
            for (int unsigned ind_bytes = 0; ind_bytes < BYTES_NUM; ind_bytes++) begin
                if( byte_valid_wr[ind_bytes] ) begin
                    mst_regs_av[ind_bytes].byte_reg <= avms_writedata_bytes[ind_bytes%(BYTES_IN_WORD)];
                end
            end
            for (int unsigned ind_word = 0; ind_word < REGS_NUM; ind_word++) begin
                if( avms_write && (|avms_byteenable) && avms_address == ind_word) begin
                    word_valid_wr_o[ind_word] <= 1'b1;
                end else begin
                    word_valid_wr_o[ind_word] <= 1'b0;
                end
                if(/* avms_read && */(|avms_byteenable) && avms_address == ind_word) begin
                    word_valid_rd_o[ind_word] <= 1'b1;
                end else begin
                    word_valid_rd_o[ind_word] <= 1'b0;
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        for (int ind_bytes = 0; ind_bytes < BYTES_IN_WORD; ind_bytes++) begin
            if(avms_byteenable[ind_bytes]) begin
                avms_readdata[ind_bytes*8+:8] <= slv_word_i[avms_address][ind_bytes*8 +: 8];
            end else begin
                avms_readdata[ind_bytes*8+:8] <= '0;
            end
        end
    end

    assign mst_word_o = mst_regs_av ;

endmodule
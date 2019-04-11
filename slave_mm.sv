module slave_mm 
(
    input              clk_i         , // Clock
    input              arst_n_i      , // Asynchronous reset active low

    input  logic [3:0] avs_address_i     ,
    input  logic       avs_read_i        ,
    input  logic       avs_write_i       ,
    input  logic [7:0] avs_writedata_i   ,
    input  logic       ready             ,
    output logic [7:0] avs_readdata_o    ,
    output logic [7:0] data_o            ,
    output logic       valid
);

logic [7:0]  reg_slave_1;
logic [7:0]  reg_slave_2;
logic [7:0]  reg_slave_3;
logic [7:0]  reg_slave_4;
logic [7:0]  reg_slave_5;
logic [7:0]  reg_slave_6;
logic [7:0]  reg_slave_7;
logic [7:0]  reg_slave_8;
logic [7:0]  reg_slave_9;
logic [7:0]  reg_slave_10;

assign data_o = avs_writedata_i;

always @(posedge clk_i)
begin 
	if (~arst_n_i) begin
		reg_slave_1  <= '0;
		reg_slave_2  <= '0;
		reg_slave_3  <= '0;
		reg_slave_4  <= '0;
		reg_slave_5  <= '0;
		reg_slave_6  <= '0;
		reg_slave_7  <= '0;
		reg_slave_8  <= '0;
		reg_slave_9  <= '0;
		reg_slave_10 <= '0;
	end
	else if (avs_write_i) begin 
		case (avs_address_i)
			4'd1 : reg_slave_1   <= avs_writedata_i;
			4'd2 : reg_slave_2   <= avs_writedata_i;
			4'd3 : reg_slave_3   <= avs_writedata_i;
			4'd4 : reg_slave_4   <= avs_writedata_i;
			4'd5 : reg_slave_5   <= avs_writedata_i;
			4'd6 : reg_slave_6   <= avs_writedata_i;
			4'd7 : reg_slave_7   <= avs_writedata_i;
			4'd8 : reg_slave_8   <= avs_writedata_i;
			4'd9 : reg_slave_9   <= avs_writedata_i;
			4'd10 : reg_slave_10 <= avs_writedata_i;
		
			default : begin
							reg_slave_1  <= reg_slave_1;
							reg_slave_2  <= reg_slave_2;
							reg_slave_3  <= reg_slave_3;
							reg_slave_4  <= reg_slave_4;
							reg_slave_5  <= reg_slave_5;
							reg_slave_6  <= reg_slave_6;
							reg_slave_7  <= reg_slave_7;
							reg_slave_8  <= reg_slave_8;
							reg_slave_9  <= reg_slave_9;
							reg_slave_10 <= reg_slave_10;
						end
		endcase // avs_address_i[3:0]
	end
end
/*
always @(posedge clk_i or negedge arst_n_i) 
begin
	if (~arst_n_i)          data_o <= 0;
	else                    data_o <= avs_writedata_i;
end
*/
always @(posedge clk_i or negedge arst_n_i)
begin
	if (~arst_n_i)              valid <= 1'b0;
	else if (avs_address_i)     valid <= 1'b1;
end 

always @(posedge clk_i or negedge arst_n_i)
begin
	if (~arst_n_i) avs_readdata_o <= '0;
	else if (avs_read_i) begin
		case (avs_address_i)
			4'd1  : avs_readdata_o  <= reg_slave_1;
			4'd2  : avs_readdata_o  <= reg_slave_2;
			4'd3  : avs_readdata_o  <= reg_slave_3;
			4'd4  : avs_readdata_o  <= reg_slave_4;
			4'd5  : avs_readdata_o  <= reg_slave_5;
			4'd6  : avs_readdata_o  <= reg_slave_6;
			4'd7  : avs_readdata_o  <= reg_slave_7;
			4'd8  : avs_readdata_o  <= reg_slave_8;
			4'd9  : avs_readdata_o  <= reg_slave_9;
			4'd10 : avs_readdata_o  <= reg_slave_10;
		
			default : begin
				avs_readdata_o <= avs_readdata_o;
			end
		endcase
	end
end


endmodule

module slave_mm (
	input              clk_i          , // Clock
	input              arst_n_i       , // Asynchronous reset active low
	input  logic [3:0] avs_address_i  ,
	input  logic       avs_read_i     ,
	input  logic       avs_write_i    ,
	input  logic       ready          ,
	input  logic [7:0] avs_writedata_i,
	output logic [7:0] avs_readdata_o ,
	output logic [7:0] data_o         ,
	output logic       valid          ,
	input  logic [7:0] data_i		  
);

logic [7:0] reg_slave_0;
logic [7:0] reg_slave_1;
logic [7:0] reg_slave_2;
logic [7:0] reg_slave_3;


assign valid  = (avs_address_i == 4'h0 && avs_write_i && ready) ? 1'b1 : 1'b0;
assign data_o = avs_writedata_i;

always @(posedge clk_i or negedge arst_n_i)
	begin
		if (~arst_n_i) begin
			reg_slave_0 <= '0;
			reg_slave_1 <= '0;
			reg_slave_2 <= '0;
			reg_slave_3 <= '0;
		end
		else if (avs_write_i) begin
			case (avs_address_i)
				4'd0 : reg_slave_0   <= avs_writedata_i;
				4'd1 : reg_slave_1   <= avs_writedata_i;
				4'd2 : reg_slave_2   <= avs_writedata_i;
				4'd3 : reg_slave_3   <= avs_writedata_i;

				default : begin
					reg_slave_0 <= reg_slave_0;
					reg_slave_1 <= reg_slave_1;
					reg_slave_2 <= reg_slave_2;
					reg_slave_3 <= reg_slave_3;
				end
			endcase // avs_address_i[3:0]
		end
	end

always @(posedge clk_i or negedge arst_n_i)
	begin
		if (~arst_n_i) avs_readdata_o <= '0;
		else if (avs_read_i) begin
			case (avs_address_i)
				4'd0 : avs_readdata_o  <= reg_slave_0;
				4'd1 : avs_readdata_o  <= {{7{1'b0}}, ready};
				4'd2 : avs_readdata_o  <= data_i;
				4'd3 : avs_readdata_o  <= reg_slave_3;

				default : begin
					avs_readdata_o <= avs_readdata_o;
				end
			endcase
		end
	end


endmodule

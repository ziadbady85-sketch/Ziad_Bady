module Spi_Wrapper(
	input MOSI , ss_n , clk , rst ,
	 output MISO);

parameter MEM_DEPTH  = 256    ;
parameter ADDER_SIZE = 8      ;

parameter IDLE       = 3'b000 ;
parameter CHK_CMD    = 3'b001 ;
parameter WRITE      = 3'b010 ;
parameter READ_ADD   = 3'b011 ;
parameter READ_DATA  = 3'b100 ;

wire [9:0] rx_data       ;
wire [7:0] tx_data       ;
wire rx_valid , tx_valid ;

slave #(.IDLE(IDLE),.CHK_CMD(CHK_CMD),.WRITE(WRITE),.READ_ADD(READ_ADD),.READ_DATA(READ_DATA))
      spi_slave (.MOSI(MOSI),.ss_n(ss_n),.clk(clk),.rst(rst),.rx_data(rx_data),.rx_valid(rx_valid),
      	         .tx_data(tx_data),.tx_valid(tx_valid),.MISO(MISO)) ;

RAM #(.MEM_DEPTH(MEM_DEPTH),.ADDER_SIZE(ADDER_SIZE)) 
    ram (.din(rx_data),.rx_valid(rx_valid),.dout(tx_data),.tx_valid(tx_valid),.clk(clk),.rst(rst)) ;      

endmodule 
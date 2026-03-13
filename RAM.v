module RAM(
	input clk , rst , rx_valid ,
	input [9:0] din ,
	output reg tx_valid , 
	output reg [7:0] dout);

parameter MEM_DEPTH  = 256 ;
parameter ADDER_SIZE = 8   ;

reg [7:0] mem [MEM_DEPTH-1:0] ;
reg [ADDER_SIZE-1:0] hold_wr  ;
reg [ADDER_SIZE-1:0] hold_re  ;
integer i ;
always @(posedge clk) begin
	if (~rst) begin
		for (i=0 ; i<MEM_DEPTH ; i=i+1) begin
			mem[i]   <= 0 ;
			tx_valid <= 0 ;
			dout     <= 0 ;
		end
		
	end
	else begin
     
	  if (rx_valid) begin
		case (din[9:8])
		  2'b00 : hold_wr      <= din[7:0]      ;
		  2'b01 : mem[hold_wr] <= din[7:0]      ;
		  2'b10 : hold_re      <= din[7:0]      ;
		  2'b11 : begin
		  	      dout         <= mem[hold_re]  ;		  
		  	      tx_valid     <= 1             ;		  
		  end 
		endcase
	  end
	end
end

endmodule
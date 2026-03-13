module slave(
	input MOSI , clk , rst , ss_n , tx_valid ,
	input [7:0] tx_data ,
	output reg MISO , rx_valid ,
	output reg [9:0] rx_data ) ;

parameter IDLE      = 3'b000 ;
parameter CHK_CMD   = 3'b001 ;
parameter WRITE     = 3'b010 ;
parameter READ_ADD  = 3'b011 ;
parameter READ_DATA = 3'b100 ;

reg [2:0] cs , ns  ;
reg signal         ;
reg send           ;
reg sending        ;
reg [3:0] counter  ;
reg [9:0] shift    ;
reg [7:0] tx_shift ;


always @(posedge clk) begin
	if (~rst)
		cs <= IDLE ;
		
	else
		cs <= ns ;
end

always @(*) begin

	case (cs)
	  IDLE : 
	  	if (ss_n)
	  	   ns = IDLE ;
	    else 
	       ns = CHK_CMD ;

	  CHK_CMD : begin
         if (ss_n)
           ns = IDLE ;

         else if (MOSI == 0)
           ns = WRITE ;

         else if (MOSI == 1 && signal == 0)
           ns = READ_ADD ;

         else if (MOSI == 1 && signal == 1)
           ns = READ_DATA ;

         else
           ns = IDLE ;   
      end

	 WRITE :
	    if (ss_n)
	        ns = IDLE ;
	    else 
	    	ns = WRITE ;

	 READ_ADD :
	    if (ss_n) 
	        ns = IDLE ;
	    else 
	        ns = READ_ADD ;
	        
	 READ_DATA :
	    if (ss_n)
	        ns = IDLE ;
	    else
	        ns = READ_DATA ;

	 default : ns = IDLE ;
	endcase 
end

always @(posedge clk) begin
	if (~rst) begin
		rx_valid <= 0 ;
		rx_data  <= 0 ;
		MISO     <= 0 ;
		counter  <= 0 ;
		shift    <= 0 ;
		tx_shift <= 0 ;
		sending  <= 0 ;
		send     <= 0 ;
		signal   <= 0 ;
		
	end

	else  begin
		rx_valid <= 0 ;
        MISO     <= 0 ;
		case (cs)

		 WRITE  : begin
		  shift      <= {shift[8:0],MOSI} ;
		  counter    <= counter + 1       ;
		   if (counter == 9) begin
		   	rx_data  <= {shift[8:0],MOSI} ;
		   	rx_valid <= 1                 ;
		   	counter  <= 0                 ;
		   	
		   end
		 end  

		 READ_ADD  : begin
		  shift      <= {shift[8:0],MOSI} ;
		  counter    <= counter + 1       ;
		   if (counter == 9) begin
		   	rx_data  <= {shift[8:0],MOSI} ;
		   	rx_valid <= 1                 ;
		   	signal   <= 1                 ;
		   	counter  <= 0                 ;
		   end
		 end 

		 READ_DATA : begin
           if (~send) begin
           	shift    <= {shift[8:0],MOSI} ;
		    counter  <= counter + 1       ;
		    
		   if (counter == 9) begin
		   	rx_data  <= {shift[8:0],MOSI} ;
		   	rx_valid <= 1                 ;
		   	counter  <= 0                 ;
		   	send     <= 1                 ;
		   	sending  <= 0                 ;

		   end
           end

           else if (send && !sending) begin
           	if (tx_valid) begin
		 		tx_shift <= tx_data ;
		 		sending  <= 1       ;
		 		counter  <= 0       ;
		 		end
		  end 

		  else if (sending) begin
		 		MISO        <= tx_shift[7]           ;
		 		tx_shift    <= {tx_shift[6:0],1'b0}  ;
		 		counter     <= counter + 1           ;
		 		  if (counter == 7) begin
		 			counter <= 0                     ;
		 			sending <= 0                     ;
		 			send    <= 0                     ;
		 		  end
		 	
		 		end	
		 	end

		 default : begin
		 	counter  <= 0 ;
		 	rx_valid <= 0 ;
		 end
		endcase  
	end
end

endmodule
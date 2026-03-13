module Spi_Wrapper_tb();

parameter MEM_DEPTH  = 256    ;
parameter ADDER_SIZE = 8      ;

parameter IDLE       = 3'b000 ;
parameter CHK_CMD    = 3'b001 ;
parameter WRITE      = 3'b010 ;
parameter READ_ADD   = 3'b011 ;
parameter READ_DATA  = 3'b100 ;

reg MOSI , ss_n , clk , rst ;
wire MISO ;

Spi_Wrapper #(.MEM_DEPTH(MEM_DEPTH),.ADDER_SIZE(ADDER_SIZE),.IDLE(IDLE),.CHK_CMD(CHK_CMD),.WRITE(WRITE),
	  .READ_ADD(READ_ADD),.READ_DATA(READ_DATA)) DUT (.clk(clk),.rst(rst),.ss_n(ss_n),.MOSI(MOSI),.MISO(MISO)) ;

initial begin
	clk=0 ;
	forever #1 clk=~clk ;
end

initial begin
 $readmemh ("mem_spi.dat" , DUT.ram.mem ) ;
	rst =0 ;
	ss_n=1 ;
	MOSI=1 ;
	@(negedge clk);

	rst =1 ;
	ss_n=0 ;   // go to state CHK_CMD
	DUT.ram.mem[8'hB4] = 8'hA5;      // I wrote this line because the entire mem file contains zeros, so I assigned a random value to hold_re.
    @(negedge clk);
    
    // write_ADD
	MOSI=0 ; // go to state write
	@(negedge clk);
	MOSI=0 ;
    @(negedge clk);
    MOSI=0 ;
    @(negedge clk);
    repeat(8) begin
    	MOSI = $random ;
    	@(negedge clk);
    end

    ss_n = 1 ;  // back to state IDLE

    @(negedge clk) ;
    ss_n = 0 ;   // go to state CHK_CMD
    @(negedge clk) ;

    // write_DATA   
    MOSI = 0 ; // go to state write
    @(negedge clk) ;
    MOSI = 0 ;
    @(negedge clk) ;    
    MOSI = 1 ;
    @(negedge clk) ; 
    repeat(8) begin
    	MOSI = $random ;
    	@(negedge clk);
    end  

    ss_n = 1 ;  // back to state IDLE

    @(negedge clk) ;
    ss_n = 0 ;   // go to state CHK_CMD
    @(negedge clk) ;

    // Read_ADD
    MOSI = 1 ;  // go to state read
    @(negedge clk) ;
    MOSI = 1 ;
    @(negedge clk) ;    
    MOSI = 0 ;
    @(negedge clk) ; 
    repeat(8) begin
    	MOSI = $random ;
    	@(negedge clk);
    end 

       ss_n = 1 ;  // back to state IDLE

    @(negedge clk) ;
    ss_n = 0 ;   // go to state CHK_CMD
    @(negedge clk) ;

    // Read_DATA
    MOSI = 1 ;  // go to state read
    @(negedge clk) ;
    MOSI = 1 ;
    @(negedge clk) ;    
    MOSI = 1 ;
    @(negedge clk) ; 
    repeat(8) begin
    	MOSI = $random ;
    	@(negedge clk);
    end 

    ss_n =1 ; // back to state IDLE
    @(negedge clk);

     @(negedge clk) ;
    ss_n = 0 ;   // go to state CHK_CMD
    @(negedge clk) ;

    // Read_DATA
    MOSI = 1 ;  // go to state read
    @(negedge clk) ;
    MOSI = 1 ;
    @(negedge clk) ;    
    MOSI = 1 ;
    @(negedge clk) ; 
    repeat(8) begin
    	MOSI = $random ;
    	@(negedge clk);
    end 



    ss_n =1 ; // back to state IDLE
    @(negedge clk);


    $stop ;
end

endmodule



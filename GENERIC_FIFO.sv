`include "defines.v"
// TYPEDEF


module GENERIC_FIFO #( 
		    parameter 			DATA_WIDTH = 32,
		    parameter 			DATA_DEPTH = 8
		  )
		  
		  (
		    input  logic			clk,
		    input  logic			rst_n,
		    //PUSH SIDE
		    input  logic [DATA_WIDTH-1:0]	DATA_IN,
		    input  logic			VALID_IN,
		    output logic			GRANT_OUT,
		    //POP SIDE
		    output logic [DATA_WIDTH-1:0]	DATA_OUT,
		    output logic			VALID_OUT,
		    input  logic			GRANT_IN
		  );
		  
		  // Local Parameter
		  localparam 				ADDR_DEPTH = `log2(DATA_DEPTH-1);
		  
		  
		  
		  enum logic [1:0] { EMPTY, FULL, MIDDLE } CS, NS;
		  // Internal Signals

		  logic [ADDR_DEPTH-1:0]		Pop_Pointer_CS,  Pop_Pointer_NS;
		  logic	[ADDR_DEPTH-1:0]		Push_Pointer_CS, Push_Pointer_NS;
		  logic [DATA_WIDTH-1:0]		FIFO_REGISTERS[DATA_DEPTH-1:0];
		  integer				i;
		  
		  
		  
		  // Parameter Check
		  // synopsys translate_off
		  initial
		    begin : parameter_check
		      integer param_err_flg;
		      param_err_flg = 0;
		      
		      if (DATA_WIDTH < 1)
			begin
			  param_err_flg = 1;
			  $display("ERROR: %m :\n  Invalid value (%d) for parameter DATA_WIDTH (legal range: greater than 1)", DATA_WIDTH );
			end
			
		      if (DATA_DEPTH < 1)
			begin
			  param_err_flg = 1;
			  $display("ERROR: %m :\n  Invalid value (%d) for parameter DATA_DEPTH (legal range: greater than 1)", DATA_DEPTH );
			end		      
		    end
		  // synopsys translate_on
		  
		  
		  
		  // UPDATE THE STATE
		  always_ff @(posedge clk, negedge rst_n)
		    begin
		      if(rst_n == 1'b0)
			begin
			  CS              <= EMPTY;
			  Pop_Pointer_CS  <= {ADDR_DEPTH {1'b0}};
			  Push_Pointer_CS <= {ADDR_DEPTH {1'b0}};
			end
		      else
			begin
			  CS              <= NS;
			  Pop_Pointer_CS  <= Pop_Pointer_NS;
			  Push_Pointer_CS <= Push_Pointer_NS;
			end
		    end
		    
		    
		    // Compute Next State
		    always_comb
		      begin
			
			case(CS)
			
			EMPTY:
			  begin
			    GRANT_OUT = 1'b1;
			    VALID_OUT = 1'b0;
				
			    case(VALID_IN)
			    
			    1'b0 : 
			      begin 
				NS 	  	= EMPTY;
				Push_Pointer_NS = Push_Pointer_CS;
				Pop_Pointer_NS  = Pop_Pointer_CS;
			      end
			    
			    1'b1: 
			      begin 
				NS 	  	= MIDDLE;
				Push_Pointer_NS = Push_Pointer_CS + 1'b1;
				Pop_Pointer_NS  = Pop_Pointer_CS;
			      end
			    
			    endcase
			    
			  end
			
			MIDDLE:
			  begin
			    GRANT_OUT = 1'b1;
			    VALID_OUT = 1'b1;
				
			    case({VALID_IN,GRANT_IN})
			    
			    2'b01:
			      begin 
			      	if((Pop_Pointer_CS == Push_Pointer_CS -1 ) || ((Pop_Pointer_CS == DATA_DEPTH-1) && (Push_Pointer_CS == 0) ))
				    NS 	  	= EMPTY;
				else
				    NS 	  	= MIDDLE;
				
				Push_Pointer_NS = Push_Pointer_CS;
				
				if(Pop_Pointer_CS == DATA_DEPTH-1)
				  Pop_Pointer_NS  = 0;
				else
				  Pop_Pointer_NS  = Pop_Pointer_CS + 1'b1;
			      end
			    2'b00 : 
			      begin 
				NS 	  	= MIDDLE;
				Push_Pointer_NS = Push_Pointer_CS;
				Pop_Pointer_NS  = Pop_Pointer_CS;
			      end
			    
			    2'b11: 
			      begin 
			      
				NS 	  	= MIDDLE;
				
				if(Push_Pointer_CS == DATA_DEPTH-1)
				    Push_Pointer_NS = 0;
				else
				    Push_Pointer_NS = Push_Pointer_CS + 1'b1;
				    
				if(Pop_Pointer_CS == DATA_DEPTH-1)
				    Pop_Pointer_NS  = 0;
				else
				    Pop_Pointer_NS  = Pop_Pointer_CS  + 1'b1;
				
			      end
			      
			    2'b10:
			    begin 
			    
				if(( Push_Pointer_CS == Pop_Pointer_CS - 1) || ( (Push_Pointer_CS == DATA_DEPTH-1) && (Pop_Pointer_CS == 0) ))
				    NS 	  	= FULL;
				else
				    NS 	  = MIDDLE;
				    
				if(Push_Pointer_CS == DATA_DEPTH - 1)
				    Push_Pointer_NS = 0;
				else
				    Push_Pointer_NS = Push_Pointer_CS + 1'b1;
				    
				Pop_Pointer_NS  = Pop_Pointer_CS;
			      end
			    
			    endcase			    
			  end
			  
			FULL:
			  begin
			    GRANT_OUT = 1'b0;
			    VALID_OUT = 1'b1;
			    
			    case(GRANT_IN)
			      
			    
			    1'b1: 
			      begin 
			      
				NS 	  	= MIDDLE;
				
				Push_Pointer_NS = Push_Pointer_CS;
				    
				if(Pop_Pointer_CS == DATA_DEPTH-1)
				    Pop_Pointer_NS  = 0;
				else
				    Pop_Pointer_NS  = Pop_Pointer_CS  + 1'b1;
				
			      end
			      
			    1'b0:
			    begin 
				NS 	  	= FULL;
				
				Push_Pointer_NS = Push_Pointer_CS;
				Pop_Pointer_NS  = Pop_Pointer_CS;
			      end
			    
			    endcase			
				
			  end // end of FULL
			  
			  default :
			    begin
			      	GRANT_OUT = 1'b0;
				VALID_OUT = 1'b0;
				NS = EMPTY;
				Pop_Pointer_NS = 0;
				Push_Pointer_NS = 0;
			    end
		    
		      endcase
		    
		    
		      end
		  
		  
		  
		  always_ff @(posedge clk, negedge rst_n)
		    begin
		      if(rst_n == 1'b0)
			begin
			  for (i=0; i< DATA_DEPTH; i++)
			    FIFO_REGISTERS[i] <= {DATA_WIDTH {1'b0}};
			end
		      else
			if((GRANT_OUT == 1'b1) && (VALID_IN == 1'b1))
			    FIFO_REGISTERS[Push_Pointer_CS] <= DATA_IN;
			else ;
		    end
		  
		  assign DATA_OUT = FIFO_REGISTERS[Pop_Pointer_CS];
		  



endmodule

`include "defines.v"


module axi_address_decoder_DW
#(
    parameter  N_INIT_PORT    = 4,
    parameter  FIFO_DEPTH     = 8
)
(
    input  logic					clk,
    input  logic					rst_n,
    
    input  logic 					wvalid_i,
    input  logic 					wlast_i,
    output logic 					wready_o,
    
    output logic [N_INIT_PORT-1:0]			wvalid_o,
    input  logic [N_INIT_PORT-1:0]			wready_i,
    
    output logic					grant_FIFO_DEST_o,
    input  logic [N_INIT_PORT-1:0]			DEST_i,
    input  logic					push_DEST_i,

    input  logic					handle_error_i,
    output logic					wdata_error_completed_o
);


  logic							valid_DEST;
  logic							pop_from_DEST_FIFO;
  logic [N_INIT_PORT-1:0]				DEST_int; 
 
  
  
  
  GENERIC_FIFO 
  #( 
	  .DATA_WIDTH(N_INIT_PORT),
	  .DATA_DEPTH(FIFO_DEPTH)
  )
  MASTER_ID_FIFO
  (
	  .clk(clk),
	  .rst_n(rst_n),
	  //PUSH SIDE
	  .DATA_IN(DEST_i),
	  .VALID_IN(push_DEST_i),
	  .GRANT_OUT(grant_FIFO_DEST_o),
	  //POP SIDE
	  .DATA_OUT(DEST_int),
	  .VALID_OUT(valid_DEST),
	  .GRANT_IN(pop_from_DEST_FIFO)
  );
  
  
  assign pop_from_DEST_FIFO = wlast_i & wvalid_i & wready_o;
  
  

  
  always_comb
  begin
      
      if(handle_error_i)
      begin
	  wready_o = 1'b1;
	  wvalid_o = '0;
	  
	  wdata_error_completed_o = wlast_i & wvalid_i;
      end
      else
      begin
	  wready_o = |(wready_i & DEST_int);
	  wdata_error_completed_o           = 1'b0;
	  
	  if(wvalid_i & valid_DEST)
	  begin
	      wvalid_o  = {N_INIT_PORT{wvalid_i}} & DEST_int;
	  end
	  else
	  begin
	      wvalid_o  = '0;
	  end
      end
      
  end
 
  
   
  

endmodule
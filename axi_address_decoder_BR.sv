`include "defines.v"

module axi_address_decoder_BR
#(
    parameter  N_TARG_PORT     = 8,
    parameter  AXI_ID_IN       = 16,
    parameter  AXI_ID_OUT      = AXI_ID_IN+`log2(N_TARG_PORT-1)
)
(
  //AXI BACKWARD write response bus -----------------------------------------------------//
  input  logic [AXI_ID_OUT-1:0]						rid_i,
  input  logic 								rvalid_i,
  output logic 								rready_o,
  // To BW ALLOC --> FROM BW DECODER
  output logic [N_TARG_PORT-1:0] 					rvalid_o,
  input  logic [N_TARG_PORT-1:0]					rready_i 
);

  logic [N_TARG_PORT-1:0]				req_mask;
  logic	[`log2(N_TARG_PORT-1)-1:0]			ROUTING;
  
  
  assign ROUTING = rid_i[AXI_ID_IN+ `log2(N_TARG_PORT-1)-1: AXI_ID_IN];
   
  always_comb
  begin
      req_mask = '0;
      req_mask[ROUTING] = 1'b1;
  end
  
  
  
 
  always_comb
  begin

	    if(rvalid_i)
	    begin
		rvalid_o = {N_TARG_PORT{rvalid_i}} & req_mask;
	    end
	    else
	    begin
		rvalid_o = '0;
	    end
	    
	    rready_o = |(rready_i & req_mask);

  end
 
 
 
 endmodule
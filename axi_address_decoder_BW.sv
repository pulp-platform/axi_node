`include "defines.v"

module axi_address_decoder_BW
#(
    parameter  N_TARG_PORT     = 3,
    parameter  AXI_ID_IN       = 3,
    parameter  AXI_ID_OUT      = AXI_ID_IN+`log2(N_TARG_PORT-1)
)
(
  //AXI BACKWARD write response bus -----------------------------------------------------//
  input  logic [AXI_ID_OUT-1:0]						bid_i,
  input  logic 								bvalid_i,
  output logic 								bready_o,
  // To BW ALLOC --> FROM BW DECODER
  output logic [N_TARG_PORT-1:0] 					bvalid_o,
  input  logic [N_TARG_PORT-1:0]					bready_i 
);

  logic [N_TARG_PORT-1:0]				req_mask;
  logic	[`log2(N_TARG_PORT-1)-1:0]			ROUTING;
  
  
  assign ROUTING = bid_i[AXI_ID_IN+ `log2(N_TARG_PORT-1)-1: AXI_ID_IN];
   
  always_comb
  begin
      req_mask = '0;
      req_mask[ROUTING] = 1'b1;
  end
  
  
  
 
  always_comb
  begin

	    if(bvalid_i)
	    begin
		bvalid_o = {N_TARG_PORT{bvalid_i}} & req_mask;
	    end
	    else
	    begin
		bvalid_o = '0;
	    end
	    
	    bready_o = |(bready_i & req_mask);

  end
 
 
 
 endmodule
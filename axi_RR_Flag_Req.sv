`include "defines.v"


module axi_RR_Flag_Req
  #(
	
	parameter MAX_COUNT   = 8,
	parameter WIDTH       = `log2(MAX_COUNT-1)
   )
   (
	input  logic 			clk,
	input  logic 			rst_n,
	output logic [WIDTH-1:0] 	RR_FLAG_o,
	input  logic			data_req_i,
	input  logic			data_gnt_i

  );
  
  
  
  
	always_ff @(posedge clk, negedge rst_n)
	begin : RR_Flag_Req_SEQ
		if(rst_n == 1'b0)
		   RR_FLAG_o <= '0;
		else
		  if( data_req_i  & data_gnt_i )
		      if(RR_FLAG_o < MAX_COUNT-1)
			RR_FLAG_o <= RR_FLAG_o + 1'b1;
		      else
			RR_FLAG_o <= '0;
		       
	end
	
	
endmodule

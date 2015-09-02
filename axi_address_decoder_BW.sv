// ============================================================================= //
//                           COPYRIGHT NOTICE                                    //
// Copyright 2014 Multitherman Laboratory - University of Bologna                //
// ALL RIGHTS RESERVED                                                           //
// This confidential and proprietary software may be used only as authorised by  //
// a licensing agreement from Multitherman Laboratory - University of Bologna.   //
// The entire notice above must be reproduced on all authorized copies and       //
// copies may only be made to the extent permitted by a licensing agreement from //
// Multitherman Laboratory - University of Bologna.                              //
// ============================================================================= //

// ============================================================================= //
// Company:        Multitherman Laboratory @ DEIS - University of Bologna        //
//                    Viale Risorgimento 2 40136                                 //
//                    Bologna - fax 0512093785 -                                 //
//                                                                               //
// Engineer:       Igor Loi - igor.loi@unibo.it                                  //
//                                                                               //
//                                                                               //
// Additional contributions by:                                                  //
//                                                                               //
//                                                                               //
//                                                                               //
// Create Date:    01/02/2014                                                    //
// Design Name:    AXI 4 INTERCONNECT                                            //
// Module Name:    axi_address_decoder_BW                                        //
// Project Name:   PULP                                                          //
// Language:       SystemVerilog                                                 //
//                                                                               //
// Description:   Address decoder for the address write channel: Decoding        //
//                is performed on the ID B. This block calculates the            //
//                destination slave port to backroute the write response         //
//                                                                               //
// Revision:                                                                     //
// Revision v0.1 - 01/02/2014 : File Created                                     //
//                                                                               //
//                                                                               //
//                                                                               //
//                                                                               //
//                                                                               //
//                                                                               //
// ============================================================================= //

module axi_address_decoder_BW
#(
    parameter  N_TARG_PORT     = 3,
    parameter  AXI_ID_IN       = 3,
    parameter  AXI_ID_OUT      = AXI_ID_IN+$clog2(N_TARG_PORT)
)
(
  //AXI BACKWARD write response bus -----------------------------------------------------//
  input  logic [AXI_ID_OUT-1:0]            bid_i,
  input  logic                             bvalid_i,
  output logic                             bready_o,
  // To BW ALLOC --> FROM BW DECODER
  output logic [N_TARG_PORT-1:0]           bvalid_o,
  input  logic [N_TARG_PORT-1:0]           bready_i 
);

  logic [N_TARG_PORT-1:0]                  req_mask;
  logic [$clog2(N_TARG_PORT)-1:0]          ROUTING;
  
  
  assign ROUTING = bid_i[AXI_ID_IN+ $clog2(N_TARG_PORT)-1: AXI_ID_IN];
   
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

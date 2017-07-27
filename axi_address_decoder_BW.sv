/* Copyright (C) 2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */


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

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
// Module Name:    axi_address_decoder_DW                                        //
// Project Name:   PULP                                                          //
// Language:       SystemVerilog                                                 //
//                                                                               //
// Description:   Address decoder for the  write channel: Decoding information   //
//                is passed from the axi_address_decoder_AW. Once it recevices   //
//                a routing infotmation, it sets the multiplexer to the rigth    //
//                master ports. Information are pushed in a fifo and served      //
//                in order. Fifo are pushed when wlast comes                     //
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

module axi_address_decoder_DW
#(
    parameter  N_INIT_PORT    = 4,
    parameter  FIFO_DEPTH     = 8
)
(
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       test_en_i,
    
    input  logic                       wvalid_i,
    input  logic                       wlast_i,
    output logic                       wready_o,
    
    output logic [N_INIT_PORT-1:0]     wvalid_o,
    input  logic [N_INIT_PORT-1:0]     wready_i,
    
    output logic                       grant_FIFO_DEST_o,
    input  logic [N_INIT_PORT-1:0]     DEST_i,
    input  logic                       push_DEST_i,

    input  logic                       handle_error_i,
    output logic                       wdata_error_completed_o
);


  logic                                valid_DEST;
  logic                                pop_from_DEST_FIFO;
  logic [N_INIT_PORT-1:0]              DEST_int; 
 
  
  
  
   generic_fifo 
   #( 
      .DATA_WIDTH(N_INIT_PORT),
      .DATA_DEPTH(FIFO_DEPTH)
   )
   MASTER_ID_FIFO
   (
      .clk          ( clk                 ),
      .rst_n        ( rst_n               ),
      .test_mode_i  ( test_en_i           ),
      .data_i       ( DEST_i              ),
      .valid_i      ( push_DEST_i         ),
      .grant_o      ( grant_FIFO_DEST_o   ),
      .data_o       ( DEST_int            ),
      .valid_o      ( valid_DEST          ),
      .grant_i      ( pop_from_DEST_FIFO  )
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
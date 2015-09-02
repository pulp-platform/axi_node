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
// Module Name:    axi_RR_Flag_Req                                               //
// Project Name:   PULP                                                          //
// Language:       SystemVerilog                                                 //
//                                                                               //
// Description:   A simple Flag generator for round robin arbitration, that      //
//                ensure fair arbitration among slave ports (AR, AW, B and R).   //
//                This component is used inside the arbitration trees.           //
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

module axi_RR_Flag_Req
#(
    
    parameter MAX_COUNT   = 8,
    parameter WIDTH       = $clog2(MAX_COUNT)
)
(
    input  logic               clk,
    input  logic               rst_n,
    output logic [WIDTH-1:0]   RR_FLAG_o,
    input  logic               data_req_i,
    input  logic               data_gnt_i

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

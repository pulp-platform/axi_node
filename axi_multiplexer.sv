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
// Module Name:    axi_multiplexer                                               //
// Project Name:   PULP                                                          //
// Language:       SystemVerilog                                                 //
//                                                                               //
// Description:   A simple multiplexer with parametric number of inputs and      //
//                datawidth                                                      //
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

module axi_multiplexer
#(
    parameter DATA_WIDTH = 64,
    parameter N_IN       = 16,
    parameter SEL_WIDTH  = $clog2(N_IN)
) 
(
    input  logic [N_IN-1:0][DATA_WIDTH-1:0]   IN_DATA,
    output logic [DATA_WIDTH-1:0]             OUT_DATA,
    input  logic [SEL_WIDTH-1:0]              SEL
);


assign OUT_DATA = IN_DATA[SEL];

endmodule

`include "defines.v"

module axi_node
#(

    parameter AXI_ADDRESS_W  = 32,
    parameter AXI_DATA_W     = 64,
    parameter           AXI_NUMBYTES   = AXI_DATA_W/8,
    parameter AXI_USER_W     = 6,
    
    parameter AXI_LITE_ADDRESS_W = 32,
    parameter AXI_LITE_DATA_W    = 32,
  
    parameter N_INIT_PORT    = 2,
    parameter N_TARG_PORT    = 2,
  
    parameter AXI_ID_IN      = 16,  
    parameter AXI_ID_OUT     = AXI_ID_IN + `log2(N_TARG_PORT-1),
    
    parameter FIFO_DEPTH_DW  = 8,
    
    parameter N_REGION       = 2,
    
    parameter NUM_REGS       = N_INIT_PORT*2
)
(
  input logic                         clk,
  input logic                         rst_n,
  // ---------------------------------------------------------------
  // AXI TARG Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // USED// -------------- 
  input  logic [N_TARG_PORT-1:0][AXI_ID_IN-1:0]           targ_awid_i,   //
  input  logic [N_TARG_PORT-1:0][AXI_ADDRESS_W-1:0]       targ_awaddr_i,   //
  input  logic [N_TARG_PORT-1:0][ 7:0]                    targ_awlen_i,      //burst length is 1 + (0 - 15)
  input  logic [N_TARG_PORT-1:0][ 2:0]                    targ_awsize_i,     //size of each transfer in burst
  input  logic [N_TARG_PORT-1:0][ 1:0]                    targ_awburst_i,    //for bursts>1, accept only incr burst=01
  input  logic [N_TARG_PORT-1:0]                          targ_awlock_i,     //only normal access supported axs_awlock=00
  input  logic [N_TARG_PORT-1:0][ 3:0]                    targ_awcache_i,    //
  input  logic [N_TARG_PORT-1:0][ 2:0]                    targ_awprot_i,   //
  input  logic [N_TARG_PORT-1:0][ 3:0]                    targ_awregion_i,   //
  input  logic [N_TARG_PORT-1:0][ AXI_USER_W-1:0]         targ_awuser_i,   //
  input  logic [N_TARG_PORT-1:0][ 3:0]                    targ_awqos_i,   //  
  input  logic [N_TARG_PORT-1:0]                          targ_awvalid_i,    //master addr valid
  output logic [N_TARG_PORT-1:0]                          targ_awready_o,    //slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // USED// -------------- 
  input  logic [N_TARG_PORT-1:0] [AXI_DATA_W-1:0]         targ_wdata_i,
  input  logic [N_TARG_PORT-1:0] [AXI_NUMBYTES-1:0]       targ_wstrb_i,   //1 strobe per byte
  input  logic [N_TARG_PORT-1:0]                          targ_wlast_i,   //last transfer in burst
  input  logic [N_TARG_PORT-1:0][AXI_USER_W-1:0]          targ_wuser_i,   // User sideband signal
  input  logic [N_TARG_PORT-1:0]                          targ_wvalid_i,  //master data valid
  output logic [N_TARG_PORT-1:0]                          targ_wready_o,  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI write response bus -------------- // USED// -------------- 
  output  logic [N_TARG_PORT-1:0]  [AXI_ID_IN-1:0]        targ_bid_o,
  output  logic [N_TARG_PORT-1:0]  [ 1:0]                 targ_bresp_o,
  output  logic [N_TARG_PORT-1:0]                         targ_bvalid_o,
  output  logic [N_TARG_PORT-1:0]  [AXI_USER_W-1:0]       targ_buser_o,   // User sideband signal
  input   logic [N_TARG_PORT-1:0]                         targ_bready_i,
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  input  logic [N_TARG_PORT-1:0][AXI_ID_IN-1:0]           targ_arid_i,
  input  logic [N_TARG_PORT-1:0][AXI_ADDRESS_W-1:0]       targ_araddr_i,
  input  logic [N_TARG_PORT-1:0][ 7:0]                    targ_arlen_i,   //burst length - 1 to 16
  input  logic [N_TARG_PORT-1:0][ 2:0]                    targ_arsize_i,  //size of each transfer in burst
  input  logic [N_TARG_PORT-1:0][ 1:0]                    targ_arburst_i, //for bursts>1, accept only incr burst=01
  input  logic [N_TARG_PORT-1:0]                          targ_arlock_i,  //only normal access supported axs_awlock=00
  input  logic [N_TARG_PORT-1:0][ 3:0]                    targ_arcache_i, 
  input  logic [N_TARG_PORT-1:0][ 2:0]                    targ_arprot_i,
  input  logic [N_TARG_PORT-1:0][ 3:0]                    targ_arregion_i,   //
  input  logic [N_TARG_PORT-1:0][ AXI_USER_W-1:0]         targ_aruser_i,   //
  input  logic [N_TARG_PORT-1:0][ 3:0]                    targ_arqos_i,   //  
  input  logic [N_TARG_PORT-1:0]                          targ_arvalid_i, //master addr valid
  output logic [N_TARG_PORT-1:0]                          targ_arready_o, //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI read data bus ----------------------------------------------
  output logic [N_TARG_PORT-1:0][AXI_ID_IN-1:0]           targ_rid_o,
  output logic [N_TARG_PORT-1:0][AXI_DATA_W-1:0]          targ_rdata_o,
  output logic [N_TARG_PORT-1:0][ 1:0]                    targ_rresp_o,
  output logic [N_TARG_PORT-1:0]                          targ_rlast_o,   //last transfer in burst
  output logic [N_TARG_PORT-1:0][AXI_USER_W-1:0]          targ_ruser_o,   //last transfer in burst
  output logic [N_TARG_PORT-1:0]                          targ_rvalid_o,  //slave data valid
  input  logic [N_TARG_PORT-1:0]                          targ_rready_i,   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
  
  
  // ---------------------------------------------------------------
  // AXI INIT Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // // -------------- 
  output logic [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]          init_awid_o,   //
  output logic [N_INIT_PORT-1:0][AXI_ADDRESS_W-1:0]       init_awaddr_o,   //
  output logic [N_INIT_PORT-1:0][ 7:0]                    init_awlen_o,      //burst length is 1 + (0 - 15)
  output logic [N_INIT_PORT-1:0][ 2:0]                    init_awsize_o,     //size of each transfer in burst
  output logic [N_INIT_PORT-1:0][ 1:0]                    init_awburst_o,    //for bursts>1, accept only incr burst=01
  output logic [N_INIT_PORT-1:0]                          init_awlock_o,     //only normal access supported axs_awlock=00
  output logic [N_INIT_PORT-1:0][ 3:0]                    init_awcache_o,    //
  output logic [N_INIT_PORT-1:0][ 2:0]                    init_awprot_o,   //
  output logic [N_INIT_PORT-1:0][ 3:0]                    init_awregion_o,   //
  output logic [N_INIT_PORT-1:0][ AXI_USER_W-1:0]         init_awuser_o,   //
  output logic [N_INIT_PORT-1:0][ 3:0]                    init_awqos_o,   //  
  output logic [N_INIT_PORT-1:0]                          init_awvalid_o,    //master addr valid
  input  logic [N_INIT_PORT-1:0]                          init_awready_i,    //slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // // -------------- 
  output logic [N_INIT_PORT-1:0] [AXI_DATA_W-1:0]         init_wdata_o,
  output logic [N_INIT_PORT-1:0] [AXI_NUMBYTES-1:0]       init_wstrb_o,   //1 strobe per byte
  output logic [N_INIT_PORT-1:0]                          init_wlast_o,   //last transfer in burst
  output logic [N_INIT_PORT-1:0] [ AXI_USER_W-1:0]        init_wuser_o,   //user sideband signals
  output logic [N_INIT_PORT-1:0]                          init_wvalid_o,  //master data valid
  input  logic [N_INIT_PORT-1:0]                          init_wready_i,  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI BACKWARD write response bus -------------- // // -------------- 
  input  logic [N_INIT_PORT-1:0] [AXI_ID_OUT-1:0]         init_bid_i,
  input  logic [N_INIT_PORT-1:0] [ 1:0]                   init_bresp_i,
  input  logic [N_INIT_PORT-1:0] [ AXI_USER_W-1:0]        init_buser_i,
  input  logic [N_INIT_PORT-1:0]                          init_bvalid_i,
  output logic [N_INIT_PORT-1:0]                          init_bready_o,
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  output  logic [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]         init_arid_o,
  output  logic [N_INIT_PORT-1:0][AXI_ADDRESS_W-1:0]      init_araddr_o,
  output  logic [N_INIT_PORT-1:0][ 7:0]                   init_arlen_o,   //burst length - 1 to 16
  output  logic [N_INIT_PORT-1:0][ 2:0]                   init_arsize_o,  //size of each transfer in burst
  output  logic [N_INIT_PORT-1:0][ 1:0]                   init_arburst_o, //for bursts>1, accept only incr burst=01
  output  logic [N_INIT_PORT-1:0]                         init_arlock_o,  //only normal access supported axs_awlock=00
  output  logic [N_INIT_PORT-1:0][ 3:0]                   init_arcache_o, 
  output  logic [N_INIT_PORT-1:0][ 2:0]                   init_arprot_o,
  output  logic [N_INIT_PORT-1:0][ 3:0]                   init_arregion_o,   //
  output  logic [N_INIT_PORT-1:0][ AXI_USER_W-1:0]        init_aruser_o,   //
  output  logic [N_INIT_PORT-1:0][ 3:0]                   init_arqos_o,   //  
  output  logic [N_INIT_PORT-1:0]                         init_arvalid_o, //master addr valid
  input logic [N_INIT_PORT-1:0]                           init_arready_i, //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  input  logic [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]          init_rid_i,
  input  logic [N_INIT_PORT-1:0][AXI_DATA_W-1:0]          init_rdata_i,
  input  logic [N_INIT_PORT-1:0][ 1:0]                    init_rresp_i,
  input  logic [N_INIT_PORT-1:0]                          init_rlast_i,   //last transfer in burst
  input  logic [N_INIT_PORT-1:0][ AXI_USER_W-1:0]         init_ruser_i,
  input  logic [N_INIT_PORT-1:0]                          init_rvalid_i,  //slave data valid
  output logic [N_INIT_PORT-1:0]                          init_rready_o,   //master ready to accept
  // ---------------------------------------------------------------
  
  
  //PROGRAMMABLE PORT -- AXI LITE
  input  logic [AXI_LITE_ADDRESS_W-1:0]                   s_axi_awaddr,
  input  logic                                            s_axi_awvalid,
  output logic                                            s_axi_awready,
  input  logic [AXI_LITE_DATA_W-1:0]                      s_axi_wdata,
  input  logic [AXI_LITE_DATA_W/8-1:0]                    s_axi_wstrb,
  input  logic                                            s_axi_wvalid,
  output logic                                            s_axi_wready,
  output logic [1:0]                                      s_axi_bresp,
  output logic                                            s_axi_bvalid,
  input  logic                                            s_axi_bready,
  input  logic [AXI_LITE_ADDRESS_W-1:0]                   s_axi_araddr,
  input  logic                                            s_axi_arvalid,
  output logic                                            s_axi_arready,
  output logic [AXI_LITE_DATA_W-1:0]                      s_axi_rdata,
  output logic [1:0]                                      s_axi_rresp,
  output logic                                            s_axi_rvalid,
  input  logic                                            s_axi_rready,
  
  //Initial Memory map
  input  logic [N_REGION-1:0][N_INIT_PORT-1:0][AXI_LITE_DATA_W-1:0]   init_START_ADDR_i,
  input  logic [N_REGION-1:0][N_INIT_PORT-1:0][AXI_LITE_DATA_W-1:0]   init_END_ADDR_i,
  input  logic [N_REGION-1:0][N_INIT_PORT-1:0][AXI_LITE_DATA_W-1:0]   init_valid_rule_i,
  input  logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]                     init_connectivity_map_i
   
);
 
 
 
genvar i,j,k;
 
logic  [N_TARG_PORT-1:0][N_INIT_PORT-1:0]         arvalid_int;
logic  [N_INIT_PORT-1:0][N_TARG_PORT-1:0]         arready_int;
logic  [N_INIT_PORT-1:0][N_TARG_PORT-1:0]         arvalid_int_reverse;
logic  [N_TARG_PORT-1:0][N_INIT_PORT-1:0]         arready_int_reverse;


logic  [N_TARG_PORT-1:0][N_INIT_PORT-1:0]         awvalid_int;
logic  [N_INIT_PORT-1:0][N_TARG_PORT-1:0]         awready_int;
logic  [N_INIT_PORT-1:0][N_TARG_PORT-1:0]         awvalid_int_reverse;
logic  [N_TARG_PORT-1:0][N_INIT_PORT-1:0]         awready_int_reverse;


logic  [N_TARG_PORT-1:0][N_INIT_PORT-1:0]         wvalid_int;
logic  [N_INIT_PORT-1:0][N_TARG_PORT-1:0]         wready_int;
logic  [N_INIT_PORT-1:0][N_TARG_PORT-1:0]         wvalid_int_reverse;
logic  [N_TARG_PORT-1:0][N_INIT_PORT-1:0]         wready_int_reverse;


logic [N_INIT_PORT-1:0][N_TARG_PORT-1:0]          bvalid_int;
logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]          bready_int;
logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]          bvalid_int_reverse;
logic [N_INIT_PORT-1:0][N_TARG_PORT-1:0]          bready_int_reverse;


logic [N_INIT_PORT-1:0][N_TARG_PORT-1:0]          rvalid_int;
logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]          rready_int;
logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]          rvalid_int_reverse;
logic [N_INIT_PORT-1:0][N_TARG_PORT-1:0]          rready_int_reverse; 

 
 
 
 logic [N_REGION-1:0][N_INIT_PORT-1:0][31:0]    START_ADDR;
 logic [N_REGION-1:0][N_INIT_PORT-1:0][31:0]    END_ADDR;
 logic [N_REGION-1:0][N_INIT_PORT-1:0]          valid_rule;
 logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]       connectivity_map;
 
 
 
 
 
 assign START_ADDR       = init_START_ADDR_i;
 assign END_ADDR         = init_END_ADDR_i;
 assign connectivity_map = init_connectivity_map_i;
 
 
 
 
 
 
 
generate

for(i=0; i<N_REGION; i++)
begin
    for(j=0; j<N_INIT_PORT; j++)
    begin
   assign valid_rule[i][j] = init_valid_rule_i[i][j][0];
    end
end

// 2D REQ AND GRANT MATRIX REVERSING (TRANSPOSE)
for(i=0;i<N_INIT_PORT;i++)
begin
    for(j=0;j<N_TARG_PORT;j++)
    begin
      assign arvalid_int_reverse[i][j] = arvalid_int[j][i];
      assign awvalid_int_reverse[i][j] = awvalid_int[j][i];
      assign wvalid_int_reverse[i][j]  = wvalid_int[j][i];
      assign bvalid_int_reverse[j][i]  = bvalid_int[i][j];
      assign rvalid_int_reverse[j][i]  = rvalid_int[i][j];
      
      
      assign arready_int_reverse[j][i] = arready_int[i][j];
      assign awready_int_reverse[j][i] = awready_int[i][j];
      assign wready_int_reverse[j][i]  = wready_int[i][j];
      assign bready_int_reverse[i][j]  = bready_int[j][i];
      assign rready_int_reverse[i][j]  = rready_int[j][i];
    end
end










for(i=0; i<N_INIT_PORT; i++)
begin : REQ_BLOCK_GEN

axi_request_block
#(
    .AXI_ADDRESS_W  (  AXI_ADDRESS_W   ),
    .AXI_DATA_W     (  AXI_DATA_W      ),
    .AXI_USER_W     (  AXI_USER_W      ),
    .N_INIT_PORT    (  N_INIT_PORT     ),
    .N_TARG_PORT    (  N_TARG_PORT     ),
    .FIFO_DW_DEPTH  (  FIFO_DEPTH_DW   ),
    .AXI_ID_IN      (  AXI_ID_IN       )
)
REQ_BLOCK
(
  .clk         (   clk                   ),
  .rst_n       (   rst_n                 ),
  
  
  // -----------------------------------------------------------------------------------//
  //                           INTERNAL (N_TARGET PORT )                                //
  // -----------------------------------------------------------------------------------//
  //AXI write address bus --------------------------------------------------------------// 
  .awid_i      (  targ_awid_i                 ),     //
  .awaddr_i    (  targ_awaddr_i               ),     //
  .awlen_i     (  targ_awlen_i                ),        //burst length is 1 + (0 - 15)
  .awsize_i    (  targ_awsize_i               ),       //size of each transfer in burst
  .awburst_i   (  targ_awburst_i              ),      //for bursts>1(),  accept only incr burst=01
  .awlock_i    (  targ_awlock_i               ),      //only normal access supported axs_awlock=00
  .awcache_i   (  targ_awcache_i              ),      //
  .awprot_i    (  targ_awprot_i               ),      //
  .awregion_i  (  targ_awregion_i             ),      //
  .awuser_i    (  targ_awuser_i               ),      //
  .awqos_i     (  targ_awqos_i                ),      //  
  .awvalid_i   (  awvalid_int_reverse[i]      ),      //master addr valid
  .awready_o   (  awready_int[i]              ),      //slave ready to accept
  // -----------------------------------------------------------------------------------//

  //AXI write data bus -----------------------------------------------------------------//
  .wdata_i    (  targ_wdata_i                 ), 
  .wstrb_i    (  targ_wstrb_i                 ),      //1 strobe per byte
  .wlast_i    (  targ_wlast_i                 ),      //last transfer in burst
  .wuser_i    (  targ_wuser_i                 ), 
  .wvalid_i   (  wvalid_int_reverse[i]        ),      //master data valid
  .wready_o   (  wready_int[i]                ),      //slave ready to accept
  // -----------------------------------------------------------------------------------//
  
  
  //AXI read address bus ---------------------------------------------------------------//
  .arid_i     (  targ_arid_i                  ), 
  .araddr_i   (  targ_araddr_i                ), 
  .arlen_i    (  targ_arlen_i                 ),      //burst length - 1 to 16
  .arsize_i   (  targ_arsize_i                ),      //size of each transfer in burst
  .arburst_i  (  targ_arburst_i               ),      //for bursts>1(),  accept only incr burst=01
  .arlock_i   (  targ_arlock_i                ),      //only normal access supported axs_awlock=00
  .arcache_i  (  targ_arcache_i               ),  
  .arprot_i   (  targ_arprot_i                ), 
  .arregion_i (  targ_arregion_i              ),      //
  .aruser_i   (  targ_aruser_i                ),      //
  .arqos_i    (  targ_arqos_i                 ),      //
  .arvalid_i  (  arvalid_int_reverse[i]       ),      //master addr valid
  .arready_o  (  arready_int[i]               ),      //slave ready to accept
  // -----------------------------------------------------------------------------------//
  
  
  // ------------------------------------------------------------------------------------//
  //                           SLAVE SIDE (ONE PORT ONLY)                                //
  // ------------------------------------------------------------------------------------//
  //AXI BACKWARD write response bus -----------------------------------------------------//
  .bid_i      (  init_bid_i[i]                ), 
  .bvalid_i   (  init_bvalid_i[i]             ), 
  .bready_o   (  init_bready_o[i]             ), 
  // To BW ALLOC --> FROM BW DECODER
  .bvalid_o   (  bvalid_int[i]                ), 
  .bready_i   (  bready_int_reverse[i]        ),   
  
  
  //AXI BACKWARD read data bus ----------------------------------------------------------//
  .rid_i     (  init_rid_i[i]                 ), 
  .rvalid_i  (  init_rvalid_i[i]              ),   //slave data valid
  .rready_o  (  init_rready_o[i]              ),   //master ready to accept
  // To BR ALLOC --> FROM BW DECODER
  .rvalid_o  (  rvalid_int[i]                 ), 
  .rready_i  (  rready_int_reverse[i]         ),     
  
  
  
  
  //AXI write address bus --------------------------------------------------------------// 
  .awid_o    (  init_awid_o[i]                ),      //
  .awaddr_o  (  init_awaddr_o[i]              ),      //
  .awlen_o   (  init_awlen_o[i]               ),      //burst length is 1 + (0 - 15)
  .awsize_o  (  init_awsize_o[i]              ),      //size of each transfer in burst
  .awburst_o (  init_awburst_o[i]             ),      //for bursts>1(),  accept only incr burst=01
  .awlock_o  (  init_awlock_o[i]              ),      //only normal access supported axs_awlock=00
  .awcache_o (  init_awcache_o[i]             ),      //
  .awprot_o  (  init_awprot_o[i]              ),      //
  .awregion_o(  init_awregion_o[i]            ),      //
  .awuser_o  (  init_awuser_o[i]              ),      //
  .awqos_o   (  init_awqos_o[i]               ),      //  
  .awvalid_o (  init_awvalid_o[i]             ),      //master addr valid
  .awready_i (  init_awready_i[i]             ),      //slave ready to accept
  // -----------------------------------------------------------------------------------//

  //AXI write data bus -----------------------------------------------------------------//
  .wdata_o  (  init_wdata_o[i]                ), 
  .wstrb_o  (  init_wstrb_o[i]                ),      //1 strobe per byte
  .wlast_o  (  init_wlast_o[i]                ),      //last transfer in burst
  .wuser_o  (  init_wuser_o[i]                ), 
  .wvalid_o (  init_wvalid_o[i]               ),      //master data valid
  .wready_i (  init_wready_i[i]               ),      //slave ready to accept
  // -----------------------------------------------------------------------------------//
  
  
  //AXI read address bus ---------------------------------------------------------------//
  .arid_o    (  init_arid_o[i]                ), 
  .araddr_o  (  init_araddr_o[i]              ), 
  .arlen_o   (  init_arlen_o[i]               ),      //burst length - 1 to 16
  .arsize_o  (  init_arsize_o[i]              ),      //size of each transfer in burst
  .arburst_o (  init_arburst_o[i]             ),      //for bursts>1(),  accept only incr burst=01
  .arlock_o  (  init_arlock_o[i]              ),      //only normal access supported axs_awlock=00
  .arcache_o (  init_arcache_o[i]             ),  
  .arprot_o  (  init_arprot_o[i]              ), 
  .arregion_o(  init_arregion_o[i]            ),      //
  .aruser_o  (  init_aruser_o[i]              ),      //
  .arqos_o   (  init_arqos_o[i]               ),      //
  .arvalid_o (  init_arvalid_o[i]             ),      //master addr valid
  .arready_i (  init_arready_i[i]             )     //slave ready to accept
  // -----------------------------------------------------------------------------------//  
);
end

 
 
 
 
for(i=0; i<N_TARG_PORT; i++)
begin : RESP_BLOCK_GEN 
axi_response_block
#(
    .AXI_ADDRESS_W  (AXI_ADDRESS_W),
    .AXI_DATA_W     (AXI_DATA_W),
    .AXI_USER_W     (AXI_USER_W),
    
    .N_INIT_PORT    (N_INIT_PORT),
    .N_TARG_PORT    (N_TARG_PORT),
    .FIFO_DEPTH_DW  (FIFO_DEPTH_DW),
  
    .AXI_ID_IN       (AXI_ID_IN),
    .N_REGION       (N_REGION)
)
RESP_BLOCK
(
  .clk           (  clk                 ),
  .rst_n         (  rst_n               ),
  
  //AXI BACKWARD read data bus ----------------------------------------------
  .rid_i         (  init_rid_i               ), 
  .rdata_i       (  init_rdata_i             ), 
  .rresp_i       (  init_rresp_i             ), 
  .rlast_i       (  init_rlast_i             ),    //last transfer in burst
  .ruser_i       (  init_ruser_i             ),    //last transfer in burst
  .rvalid_i      (  rvalid_int_reverse[i]    ),    //slave data valid
  .rready_o      (  rready_int[i]            ),    //master ready to accept

  //AXI BACKWARD WRITE data bus ----------------------------------------------
  .bid_i         (  init_bid_i               ), 
  .bresp_i       (  init_bresp_i             ), 
  .buser_i       (  init_buser_i             ),    //last transfer in burst
  .bvalid_i      (  bvalid_int_reverse[i]    ),    //slave data valid
  .bready_o      (  bready_int[i]            ),    //master ready to accept
  
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  .rid_o         (  targ_rid_o[i]            ), 
  .rdata_o       (  targ_rdata_o[i]          ), 
  .rresp_o       (  targ_rresp_o[i]          ), 
  .rlast_o       (  targ_rlast_o[i]          ),    //last transfer in burst
  .ruser_o       (  targ_ruser_o[i]          ), 
  .rvalid_o      (  targ_rvalid_o[i]         ),    //slave data valid
  .rready_i      (  targ_rready_i[i]         ),    //master ready to accept
  
  //AXI BACKWARD WRITE data bus ----------------------------------------------
  .bid_o         (  targ_bid_o[i]            ), 
  .bresp_o       (  targ_bresp_o[i]          ), 
  .buser_o       (  targ_buser_o[i]          ),    //last transfer in burst
  .bvalid_o      (  targ_bvalid_o[i]         ),    //slave data valid
  .bready_i      (  targ_bready_i[i]         ),    //master ready to accept 
  
  
  
  // ADDRESS READ DECODER
  .arvalid_i     (  targ_arvalid_i[i]        ), 
  .araddr_i      (  targ_araddr_i[i]         ), 
  .arready_o     (  targ_arready_o[i]        ), 
  .arlen_i       (  targ_arlen_i[i]          ),
  .aruser_i      (  targ_aruser_i[i]         ),
  .arid_i        (  targ_arid_i[i]           ), 
  
  .arvalid_o     (  arvalid_int[i]           ), 
  .arready_i     (  arready_int_reverse[i]   ), 
    
    
  // ADDRESS WRITE DECODER
  .awvalid_i     (  targ_awvalid_i[i]        ), 
  .awaddr_i      (  targ_awaddr_i[i]         ), 
  .awready_o     (  targ_awready_o[i]        ), 

  .awuser_i      (  targ_awuser_i[i]         ),
  .awid_i        (  targ_awid_i[i]           ), 
  
  .awvalid_o     (  awvalid_int[i]           ), 
  .awready_i     (  awready_int_reverse[i]   ), 
  
  // DATA WRITE DECODER  
  .wvalid_i      (  targ_wvalid_i[i]         ), 
  .wlast_i       (  targ_wlast_i[i]          ), 
  .wready_o      (  targ_wready_o[i]         ), 
  
  .wvalid_o      (  wvalid_int[i]            ), 
  .wready_i      (  wready_int_reverse[i]    ),   
  
  
  // FROM CFG REGS
  .START_ADDR_i       ( START_ADDR              ), 
  .END_ADDR_i         ( END_ADDR                ),
  .enable_region_i    ( valid_rule              ),
  .connectivity_map_i ( connectivity_map[i]     )
);
end
endgenerate

endmodule

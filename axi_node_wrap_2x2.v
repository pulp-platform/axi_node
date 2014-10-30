`include "defines.v"

module axi_node_wrap_2x2
#(
    parameter  			AXI_ADDRESS_W  = 32,
    parameter  			AXI_DATA_W     = 32,
    parameter                   AXI_NUMBYTES   = AXI_DATA_W/8,
    parameter			AXI_USER_W     = 6,
    parameter			AXI_LITE_ADDRESS_W = 32,
    parameter			AXI_LITE_DATA_W    = 32,
    parameter  			AXI_ID_IN      = 16,  
    parameter			FIFO_DEPTH_DW  = 8,
    parameter 			AXI_ID_OUT     = AXI_ID_IN + 1,
    parameter			BUFF_DEPTH_SLAVE  = 2,
    parameter			BUFF_DEPTH_MASTER = 2
)
(
  input wire 						clk,
  input wire 						rst_n,
  // ---------------------------------------------------------------//
  // PORT 0 --> TARGET          ------------------------------------//
  // ---------------------------------------------------------------//
  
  // ---------------------------------------------------------------
  // AXI TARG Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // USED// -------------- 
  input  wire [AXI_ID_IN-1:0]      			targ_0_awid_i,	//
  input  wire [AXI_ADDRESS_W-1:0] 			targ_0_awaddr_i,	//
  input  wire [ 7:0]					targ_0_awlen_i,   	//burst length is 1 + (0 - 15)
  input  wire [ 2:0]					targ_0_awsize_i,  	//size of each transfer in burst
  input  wire [ 1:0]					targ_0_awburst_i, 	//for bursts>1, accept only incr burst=01
  input  wire 						targ_0_awlock_i,  	//only normal access supported axs_awlock=00
  input  wire [ 3:0]					targ_0_awcache_i, 	//
  input  wire [ 2:0]					targ_0_awprot_i,	//
  input  wire [ 3:0]					targ_0_awregion_i,	//
  input  wire [ AXI_USER_W-1:0]				targ_0_awuser_i,	//
  input  wire [ 3:0]					targ_0_awqos_i,	//  
  input  wire 						targ_0_awvalid_i, 	//master addr valid
  output wire 						targ_0_awready_o, 	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // USED// -------------- 
  input  wire  [AXI_DATA_W-1:0]				targ_0_wdata_i,
  input  wire  [AXI_NUMBYTES-1:0]			targ_0_wstrb_i,   //1 strobe per byte
  input  wire 						targ_0_wlast_i,   //last transfer in burst
  input  wire [AXI_USER_W-1:0]				targ_0_wuser_i,   // User sideband signal
  input  wire 						targ_0_wvalid_i,  //master data valid
  output wire 						targ_0_wready_o,  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI write response bus -------------- // USED// -------------- 
  output  wire   [AXI_ID_IN-1:0]			targ_0_bid_o,
  output  wire   [ 1:0]					targ_0_bresp_o,
  output  wire 						targ_0_bvalid_o,
  output  wire   [AXI_USER_W-1:0]			targ_0_buser_o,   // User sideband signal
  input   wire 						targ_0_bready_i,
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  input  wire [AXI_ID_IN-1:0]				targ_0_arid_i,
  input  wire [AXI_ADDRESS_W-1:0]			targ_0_araddr_i,
  input  wire [ 7:0]					targ_0_arlen_i,   //burst length - 1 to 16
  input  wire [ 2:0]					targ_0_arsize_i,  //size of each transfer in burst
  input  wire [ 1:0]					targ_0_arburst_i, //for bursts>1, accept only incr burst=01
  input  wire 						targ_0_arlock_i,  //only normal access supported axs_awlock=00
  input  wire [ 3:0]					targ_0_arcache_i, 
  input  wire [ 2:0]					targ_0_arprot_i,
  input  wire [ 3:0]					targ_0_arregion_i,	//
  input  wire [ AXI_USER_W-1:0]				targ_0_aruser_i,	//
  input  wire [ 3:0]					targ_0_arqos_i,	//  
  input  wire 						targ_0_arvalid_i, //master addr valid
  output wire 						targ_0_arready_o, //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI read data bus ----------------------------------------------
  output wire [AXI_ID_IN-1:0]				targ_0_rid_o,
  output wire [AXI_DATA_W-1:0]				targ_0_rdata_o,
  output wire [ 1:0]               			targ_0_rresp_o,
  output wire                      			targ_0_rlast_o,   //last transfer in burst
  output wire [AXI_USER_W-1:0]       			targ_0_ruser_o,   //last transfer in burst
  output wire                     			targ_0_rvalid_o,  //slave data valid
  input  wire                    			targ_0_rready_i,   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
  
  // ---------------------------------------------------------------//
  // PORT 1 --> TARGET          ------------------------------------//
  // ---------------------------------------------------------------//
  
  // ---------------------------------------------------------------
  // AXI TARG Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // USED// -------------- 
  input  wire [AXI_ID_IN-1:0]      			targ_1_awid_i,	//
  input  wire [AXI_ADDRESS_W-1:0] 			targ_1_awaddr_i,	//
  input  wire [ 7:0]					targ_1_awlen_i,   	//burst length is 1 + (0 - 15)
  input  wire [ 2:0]					targ_1_awsize_i,  	//size of each transfer in burst
  input  wire [ 1:0]					targ_1_awburst_i, 	//for bursts>1, accept only incr burst=01
  input  wire 						targ_1_awlock_i,  	//only normal access supported axs_awlock=00
  input  wire [ 3:0]					targ_1_awcache_i, 	//
  input  wire [ 2:0]					targ_1_awprot_i,	//
  input  wire [ 3:0]					targ_1_awregion_i,	//
  input  wire [ AXI_USER_W-1:0]				targ_1_awuser_i,	//
  input  wire [ 3:0]					targ_1_awqos_i,	//  
  input  wire 						targ_1_awvalid_i, 	//master addr valid
  output wire 						targ_1_awready_o, 	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // USED// -------------- 
  input  wire  [AXI_DATA_W-1:0]				targ_1_wdata_i,
  input  wire  [AXI_NUMBYTES-1:0]			targ_1_wstrb_i,   //1 strobe per byte
  input  wire 						targ_1_wlast_i,   //last transfer in burst
  input  wire [AXI_USER_W-1:0]				targ_1_wuser_i,   // User sideband signal
  input  wire 						targ_1_wvalid_i,  //master data valid
  output wire 						targ_1_wready_o,  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI write response bus -------------- // USED// -------------- 
  output  wire   [AXI_ID_IN-1:0]			targ_1_bid_o,
  output  wire   [ 1:0]					targ_1_bresp_o,
  output  wire 						targ_1_bvalid_o,
  output  wire   [AXI_USER_W-1:0]			targ_1_buser_o,   // User sideband signal
  input   wire 						targ_1_bready_i,
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  input  wire [AXI_ID_IN-1:0]				targ_1_arid_i,
  input  wire [AXI_ADDRESS_W-1:0]			targ_1_araddr_i,
  input  wire [ 7:0]					targ_1_arlen_i,   //burst length - 1 to 16
  input  wire [ 2:0]					targ_1_arsize_i,  //size of each transfer in burst
  input  wire [ 1:0]					targ_1_arburst_i, //for bursts>1, accept only incr burst=01
  input  wire 						targ_1_arlock_i,  //only normal access supported axs_awlock=00
  input  wire [ 3:0]					targ_1_arcache_i, 
  input  wire [ 2:0]					targ_1_arprot_i,
  input  wire [ 3:0]					targ_1_arregion_i,	//
  input  wire [ AXI_USER_W-1:0]				targ_1_aruser_i,	//
  input  wire [ 3:0]					targ_1_arqos_i,	//  
  input  wire 						targ_1_arvalid_i, //master addr valid
  output wire 						targ_1_arready_o, //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI read data bus ----------------------------------------------
  output wire [AXI_ID_IN-1:0]				targ_1_rid_o,
  output wire [AXI_DATA_W-1:0]				targ_1_rdata_o,
  output wire [ 1:0]               			targ_1_rresp_o,
  output wire                      			targ_1_rlast_o,   //last transfer in burst
  output wire [AXI_USER_W-1:0]       			targ_1_ruser_o,   //last transfer in burst
  output wire                     			targ_1_rvalid_o,  //slave data valid
  input  wire                    			targ_1_rready_i,   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
  
  
  // ---------------------------------------------------------------//
  // PORT 0 --> INIT            ------------------------------------//
  // ---------------------------------------------------------------//
  
  // ---------------------------------------------------------------
  // AXI INIT Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // // -------------- 
  output wire [AXI_ID_OUT-1:0]      			init_0_awid_o,	//
  output wire [AXI_ADDRESS_W-1:0] 			init_0_awaddr_o,	//
  output wire [ 7:0]					init_0_awlen_o,   	//burst length is 1 + (0 - 15)
  output wire [ 2:0]					init_0_awsize_o,  	//size of each transfer in burst
  output wire [ 1:0]					init_0_awburst_o, 	//for bursts>1, accept only incr burst=01
  output wire 						init_0_awlock_o,  	//only normal access supported axs_awlock=00
  output wire [ 3:0]					init_0_awcache_o, 	//
  output wire [ 2:0]					init_0_awprot_o,	//
  output wire [ 3:0]					init_0_awregion_o,	//
  output wire [ AXI_USER_W-1:0]				init_0_awuser_o,	//
  output wire [ 3:0]					init_0_awqos_o,	//  
  output wire 						init_0_awvalid_o, 	//master addr valid
  input  wire 						init_0_awready_i, 	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // // -------------- 
  output wire  [AXI_DATA_W-1:0]				init_0_wdata_o,
  output wire  [AXI_NUMBYTES-1:0]			init_0_wstrb_o,   //1 strobe per byte
  output wire 						init_0_wlast_o,   //last transfer in burst
  output wire  [ AXI_USER_W-1:0]			init_0_wuser_o,   //user sideband signals
  output wire 						init_0_wvalid_o,  //master data valid
  input  wire 						init_0_wready_i,  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI BACKWARD write response bus -------------- // // -------------- 
  input  wire  [AXI_ID_OUT-1:0]				init_0_bid_i,
  input  wire  [ 1:0]					init_0_bresp_i,
  input  wire  [ AXI_USER_W-1:0]			init_0_buser_i,
  input  wire 						init_0_bvalid_i,
  output wire 						init_0_bready_o,
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  output  wire [AXI_ID_OUT-1:0]				init_0_arid_o,
  output  wire [AXI_ADDRESS_W-1:0]			init_0_araddr_o,
  output  wire [ 7:0]					init_0_arlen_o,   //burst length - 1 to 16
  output  wire [ 2:0]					init_0_arsize_o,  //size of each transfer in burst
  output  wire [ 1:0]					init_0_arburst_o, //for bursts>1, accept only incr burst=01
  output  wire 						init_0_arlock_o,  //only normal access supported axs_awlock=00
  output  wire [ 3:0]					init_0_arcache_o, 
  output  wire [ 2:0]					init_0_arprot_o,
  output  wire [ 3:0]					init_0_arregion_o,	//
  output  wire [ AXI_USER_W-1:0]			init_0_aruser_o,	//
  output  wire [ 3:0]					init_0_arqos_o,	//  
  output  wire 						init_0_arvalid_o, //master addr valid
  input wire 						init_0_arready_i, //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  input  wire [AXI_ID_OUT-1:0]				init_0_rid_i,
  input  wire [AXI_DATA_W-1:0]				init_0_rdata_i,
  input  wire [ 1:0]               			init_0_rresp_i,
  input  wire                      			init_0_rlast_i,   //last transfer in burst
  input  wire [ AXI_USER_W-1:0]				init_0_ruser_i,
  input  wire                     			init_0_rvalid_i,  //slave data valid
  output wire                    			init_0_rready_o,   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
  
  // ---------------------------------------------------------------//
  // PORT 1 --> INIT            ------------------------------------//
  // ---------------------------------------------------------------//
  
  // ---------------------------------------------------------------
  // AXI INIT Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // // -------------- 
  output wire [AXI_ID_OUT-1:0]      			init_1_awid_o,	//
  output wire [AXI_ADDRESS_W-1:0] 			init_1_awaddr_o,	//
  output wire [ 7:0]					init_1_awlen_o,   	//burst length is 1 + (0 - 15)
  output wire [ 2:0]					init_1_awsize_o,  	//size of each transfer in burst
  output wire [ 1:0]					init_1_awburst_o, 	//for bursts>1, accept only incr burst=01
  output wire 						init_1_awlock_o,  	//only normal access supported axs_awlock=00
  output wire [ 3:0]					init_1_awcache_o, 	//
  output wire [ 2:0]					init_1_awprot_o,	//
  output wire [ 3:0]					init_1_awregion_o,	//
  output wire [ AXI_USER_W-1:0]				init_1_awuser_o,	//
  output wire [ 3:0]					init_1_awqos_o,	//  
  output wire 						init_1_awvalid_o, 	//master addr valid
  input  wire 						init_1_awready_i, 	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // // -------------- 
  output wire  [AXI_DATA_W-1:0]				init_1_wdata_o,
  output wire  [AXI_NUMBYTES-1:0]			init_1_wstrb_o,   //1 strobe per byte
  output wire 						init_1_wlast_o,   //last transfer in burst
  output wire  [ AXI_USER_W-1:0]			init_1_wuser_o,   //user sideband signals
  output wire 						init_1_wvalid_o,  //master data valid
  input  wire 						init_1_wready_i,  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI BACKWARD write response bus -------------- // // -------------- 
  input  wire  [AXI_ID_OUT-1:0]				init_1_bid_i,
  input  wire  [ 1:0]					init_1_bresp_i,
  input  wire  [ AXI_USER_W-1:0]			init_1_buser_i,
  input  wire 						init_1_bvalid_i,
  output wire 						init_1_bready_o,
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  output  wire [AXI_ID_OUT-1:0]				init_1_arid_o,
  output  wire [AXI_ADDRESS_W-1:0]			init_1_araddr_o,
  output  wire [ 7:0]					init_1_arlen_o,   //burst length - 1 to 16
  output  wire [ 2:0]					init_1_arsize_o,  //size of each transfer in burst
  output  wire [ 1:0]					init_1_arburst_o, //for bursts>1, accept only incr burst=01
  output  wire 						init_1_arlock_o,  //only normal access supported axs_awlock=00
  output  wire [ 3:0]					init_1_arcache_o, 
  output  wire [ 2:0]					init_1_arprot_o,
  output  wire [ 3:0]					init_1_arregion_o,	//
  output  wire [ AXI_USER_W-1:0]			init_1_aruser_o,	//
  output  wire [ 3:0]					init_1_arqos_o,	//  
  output  wire 						init_1_arvalid_o, //master addr valid
  input wire 						init_1_arready_i, //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  input  wire [AXI_ID_OUT-1:0]				init_1_rid_i,
  input  wire [AXI_DATA_W-1:0]				init_1_rdata_i,
  input  wire [ 1:0]               			init_1_rresp_i,
  input  wire                      			init_1_rlast_i,   //last transfer in burst
  input  wire [ AXI_USER_W-1:0]				init_1_ruser_i,
  input  wire                     			init_1_rvalid_i,  //slave data valid
  output wire                    			init_1_rready_o,   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
  // PROGRAMMABLE PORT -- AXI LITE
  input  wire [AXI_LITE_ADDRESS_W-1:0] 			s_axi_awaddr,
  input  wire						s_axi_awvalid,
  output wire						s_axi_awready,
  input  wire [AXI_LITE_DATA_W-1:0] 			s_axi_wdata,
  input  wire [AXI_LITE_DATA_W/8-1:0] 			s_axi_wstrb,
  input  wire 						s_axi_wvalid,
  output wire						s_axi_wready,
  output wire [1:0]					s_axi_bresp,
  output wire						s_axi_bvalid,
  input  wire						s_axi_bready,
  input  wire [AXI_LITE_ADDRESS_W-1:0] 			s_axi_araddr,
  input  wire						s_axi_arvalid,
  output wire          					s_axi_arready,
  output wire [AXI_LITE_DATA_W-1:0] 			s_axi_rdata,
  output wire [1:0] 					s_axi_rresp,
  output wire						s_axi_rvalid,
  input  wire						s_axi_rready
);

  localparam 						N_INIT_PORT    = 2;
  localparam 						N_TARG_PORT    = 2;
  localparam						NUM_REGS       = N_INIT_PORT*2;

    
  //AXI write address bus -------------- // USED// -------------- 
  wire  [N_TARG_PORT-1:0][AXI_ID_IN-1:0]      			targ_awid_internal;	//
  wire  [N_TARG_PORT-1:0][AXI_ADDRESS_W-1:0] 			targ_awaddr_internal;	//
  wire  [N_TARG_PORT-1:0][ 7:0]					targ_awlen_internal;   	//burst length is 1 + (0 - 15)
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_awsize_internal;  	//size of each transfer in burst
  wire  [N_TARG_PORT-1:0][ 1:0]					targ_awburst_internal; 	//for bursts>1; accept only incr burst=01
  wire  [N_TARG_PORT-1:0]					targ_awlock_internal;  	//only normal access supported axs_awlock=00
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_awcache_internal; 	//
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_awprot_internal;	//
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_awregion_internal;	//
  wire  [N_TARG_PORT-1:0][ AXI_USER_W-1:0]			targ_awuser_internal;	//
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_awqos_internal;	//  
  wire  [N_TARG_PORT-1:0]					targ_awvalid_internal; 	//master addr valid
  wire  [N_TARG_PORT-1:0]					targ_awready_internal;	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // USED// -------------- 
  wire  [N_TARG_PORT-1:0] [AXI_DATA_W-1:0]			targ_wdata_internal;
  wire  [N_TARG_PORT-1:0] [AXI_NUMBYTES-1:0]			targ_wstrb_internal;   //1 strobe per byte
  wire  [N_TARG_PORT-1:0]					targ_wlast_internal;   //last transfer in burst
  wire  [N_TARG_PORT-1:0][AXI_USER_W-1:0]			targ_wuser_internal;   // User sideband signal
  wire  [N_TARG_PORT-1:0]					targ_wvalid_internal;  //master data valid
  wire  [N_TARG_PORT-1:0]					targ_wready_internal;  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI write response bus -------------- // USED// -------------- 
  wire  [N_TARG_PORT-1:0]  [AXI_ID_IN-1:0]			targ_bid_internal;
  wire  [N_TARG_PORT-1:0]  [ 1:0]				targ_bresp_internal;
  wire  [N_TARG_PORT-1:0]					targ_bvalid_internal;
  wire  [N_TARG_PORT-1:0]  [AXI_USER_W-1:0]			targ_buser_internal;   // User sideband signal
  wire  [N_TARG_PORT-1:0]					targ_bready_internal;
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  wire  [N_TARG_PORT-1:0][AXI_ID_IN-1:0]			targ_arid_internal;
  wire  [N_TARG_PORT-1:0][AXI_ADDRESS_W-1:0]			targ_araddr_internal;
  wire  [N_TARG_PORT-1:0][ 7:0]					targ_arlen_internal;   //burst length - 1 to 16
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_arsize_internal;  //size of each transfer in burst
  wire  [N_TARG_PORT-1:0][ 1:0]					targ_arburst_internal; //for bursts>1; accept only incr burst=01
  wire  [N_TARG_PORT-1:0]					targ_arlock_internal;  //only normal access supported axs_awlock=00
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_arcache_internal; 
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_arprot_internal;
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_arregion_internal;	//
  wire  [N_TARG_PORT-1:0][ AXI_USER_W-1:0]			targ_aruser_internal;	//
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_arqos_internal;	//  
  wire  [N_TARG_PORT-1:0]					targ_arvalid_internal; //master addr valid
  wire  [N_TARG_PORT-1:0]					targ_arready_internal; //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI read data bus ----------------------------------------------
  wire  [N_TARG_PORT-1:0][AXI_ID_IN-1:0]			targ_rid_internal;
  wire  [N_TARG_PORT-1:0][AXI_DATA_W-1:0]			targ_rdata_internal;
  wire  [N_TARG_PORT-1:0][ 1:0]               			targ_rresp_internal;
  wire  [N_TARG_PORT-1:0]                     			targ_rlast_internal;   //last transfer in burst
  wire  [N_TARG_PORT-1:0][AXI_USER_W-1:0]       		targ_ruser_internal;   //last transfer in burst
  wire  [N_TARG_PORT-1:0]                    			targ_rvalid_internal;  //slave data valid
  wire  [N_TARG_PORT-1:0]                   			targ_rready_internal;   //master ready to accept
  // ---------------------------------------------------------------
  


  
  // ---------------------------------------------------------------
  // AXI INIT wire Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // // -------------- 
  wire [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]      			init_awid_internal;	//
  wire [N_INIT_PORT-1:0][AXI_ADDRESS_W-1:0] 			init_awaddr_internal;	//
  wire [N_INIT_PORT-1:0][ 7:0]					init_awlen_internal;   	//burst length is 1 + (0 - 15)
  wire [N_INIT_PORT-1:0][ 2:0]					init_awsize_internal;  	//size of each transfer in burst
  wire [N_INIT_PORT-1:0][ 1:0]					init_awburst_internal; 	//for bursts>1; accept only incr burst=01
  wire [N_INIT_PORT-1:0]					init_awlock_internal;  	//only normal access supported axs_awlock=00
  wire [N_INIT_PORT-1:0][ 3:0]					init_awcache_internal; 	//
  wire [N_INIT_PORT-1:0][ 2:0]					init_awprot_internal;	//
  wire [N_INIT_PORT-1:0][ 3:0]					init_awregion_internal;	//
  wire [N_INIT_PORT-1:0][ AXI_USER_W-1:0]			init_awuser_internal;	//
  wire [N_INIT_PORT-1:0][ 3:0]					init_awqos_internal;	//  
  wire [N_INIT_PORT-1:0]					init_awvalid_internal; 	//master addr valid
  wire [N_INIT_PORT-1:0]					init_awready_internal; 	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // // -------------- 
  wire [N_INIT_PORT-1:0] [AXI_DATA_W-1:0]			init_wdata_internal;
  wire [N_INIT_PORT-1:0] [AXI_NUMBYTES-1:0]			init_wstrb_internal;   //1 strobe per byte
  wire [N_INIT_PORT-1:0]					init_wlast_internal;   //last transfer in burst
  wire [N_INIT_PORT-1:0] [ AXI_USER_W-1:0]			init_wuser_internal;   //user sideband signals
  wire [N_INIT_PORT-1:0]					init_wvalid_internal;  //master data valid
  wire [N_INIT_PORT-1:0]					init_wready_internal;  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI BACKWARD write response bus -------------- // // -------------- 
  wire [N_INIT_PORT-1:0] [AXI_ID_OUT-1:0]			init_bid_internal;
  wire [N_INIT_PORT-1:0] [ 1:0]					init_bresp_internal;
  wire [N_INIT_PORT-1:0] [ AXI_USER_W-1:0]			init_buser_internal;
  wire [N_INIT_PORT-1:0]					init_bvalid_internal;
  wire [N_INIT_PORT-1:0]					init_bready_internal;
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  wire [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]			init_arid_internal;
  wire [N_INIT_PORT-1:0][AXI_ADDRESS_W-1:0]			init_araddr_internal;
  wire [N_INIT_PORT-1:0][ 7:0]					init_arlen_internal;   //burst length - 1 to 16
  wire [N_INIT_PORT-1:0][ 2:0]					init_arsize_internal;  //size of each transfer in burst
  wire [N_INIT_PORT-1:0][ 1:0]					init_arburst_internal; //for bursts>1; accept only incr burst=01
  wire [N_INIT_PORT-1:0]					init_arlock_internal;  //only normal access supported axs_awlock=00
  wire [N_INIT_PORT-1:0][ 3:0]					init_arcache_internal; 
  wire [N_INIT_PORT-1:0][ 2:0]					init_arprot_internal;
  wire [N_INIT_PORT-1:0][ 3:0]					init_arregion_internal;	//
  wire [N_INIT_PORT-1:0][ AXI_USER_W-1:0]			init_aruser_internal;	//
  wire [N_INIT_PORT-1:0][ 3:0]					init_arqos_internal;	//  
  wire [N_INIT_PORT-1:0]					init_arvalid_internal; //master addr valid
  wire [N_INIT_PORT-1:0]					init_arready_internal; //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  wire [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]			init_rid_internal;
  wire [N_INIT_PORT-1:0][AXI_DATA_W-1:0]			init_rdata_internal;
  wire [N_INIT_PORT-1:0][ 1:0]               			init_rresp_internal;
  wire [N_INIT_PORT-1:0]                     			init_rlast_internal;   //last transfer in burst
  wire [N_INIT_PORT-1:0][ AXI_USER_W-1:0]			init_ruser_internal;
  wire [N_INIT_PORT-1:0]                    			init_rvalid_internal;  //slave data valid
  wire [N_INIT_PORT-1:0]                   			init_rready_internal;   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
      
      

axi_node
#(
    .AXI_ADDRESS_W           ( AXI_ADDRESS_W       ),
    .AXI_DATA_W              ( AXI_DATA_W          ),
    .AXI_NUMBYTES            ( AXI_DATA_W/8        ),
    .AXI_LITE_ADDRESS_W      ( AXI_LITE_ADDRESS_W  ),
    .AXI_LITE_DATA_W         ( AXI_LITE_DATA_W     ),
    .N_INIT_PORT             ( N_INIT_PORT         ),
    .N_TARG_PORT             ( N_TARG_PORT         ),
    .AXI_ID_IN               ( AXI_ID_IN           ),  
    .NUM_REGS                ( NUM_REGS            ),
    .AXI_USER_W              ( AXI_USER_W          )
)
AXI4_NODE
(
  .clk            (   clk              ),
  .rst_n          (   rst_n            ),
  
  // ---------------------------------------------------------------
  // AXI TARG Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // USED// -------------- 
  .targ_awid_i    (   targ_awid_internal      ),            //
  .targ_awaddr_i  (   targ_awaddr_internal    ),          //
  .targ_awlen_i   (   targ_awlen_internal     ), 	  //burst length is 1 + (0 - 15)
  .targ_awsize_i  (   targ_awsize_internal    ),	  //size of each transfer in burst
  .targ_awburst_i (   targ_awburst_internal   ),	  //for bursts>1(), accept only incr burst=01
  .targ_awlock_i  (   targ_awlock_internal    ),	  //only normal access supported axs_awlock=00
  .targ_awcache_i (   targ_awcache_internal   ),	  //
  .targ_awprot_i  (   targ_awprot_internal    ),    	  //
  .targ_awregion_i(   targ_awregion_internal  ),    	  //
  .targ_awqos_i   (   targ_awqos_internal     ),     	  //
  .targ_awuser_i  (   targ_awuser_internal    ),    	  //
  .targ_awvalid_i (   targ_awvalid_internal   ),	  //master addr valid
  .targ_awready_o (   targ_awready_internal   ),	  //slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // USED// -------------- 
  .targ_wdata_i  (    targ_wdata_internal     ),
  .targ_wstrb_i  (    targ_wstrb_internal     ),   //1 strobe per byte
  .targ_wlast_i  (    targ_wlast_internal     ),   //last transfer in burst
  .targ_wuser_i  (    targ_wuser_internal     ),   //last transfer in burst
  .targ_wvalid_i (    targ_wvalid_internal    ),  //master data valid
  .targ_wready_o (    targ_wready_internal    ),  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI write response bus -------------- // USED// -------------- 
  .targ_bid_o    (    targ_bid_internal      ),
  .targ_bresp_o  (    targ_bresp_internal    ),
  .targ_buser_o  (    targ_buser_internal    ),
  .targ_bvalid_o (    targ_bvalid_internal   ),
  .targ_bready_i (    targ_bready_internal   ),
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  .targ_arid_i    (  targ_arid_internal      ),
  .targ_araddr_i  (  targ_araddr_internal    ),
  .targ_arlen_i   (  targ_arlen_internal     ),   //burst length - 1 to 16
  .targ_arsize_i  (  targ_arsize_internal    ),  //size of each transfer in burst
  .targ_arburst_i (  targ_arburst_internal   ), //for bursts>1(), accept only incr burst=01
  .targ_arlock_i  (  targ_arlock_internal    ),  //only normal access supported axs_awlock=00
  .targ_arcache_i (  targ_arcache_internal   ), 
  .targ_arprot_i  (  targ_arprot_internal    ),
  .targ_arregion_i(  targ_arregion_internal  ),
  .targ_aruser_i  (  targ_aruser_internal    ),
  .targ_arqos_i   (  targ_arqos_internal     ),
  .targ_arvalid_i (  targ_arvalid_internal   ), //master addr valid
  .targ_arready_o (  targ_arready_internal   ), //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI read data bus ----------------------------------------------
  .targ_rid_o     (  targ_rid_internal       ),
  .targ_rdata_o   (  targ_rdata_internal     ),
  .targ_rresp_o   (  targ_rresp_internal     ),
  .targ_rlast_o   (  targ_rlast_internal     ),   //last transfer in burst
  .targ_ruser_o   (  targ_ruser_internal     ),
  .targ_rvalid_o  (  targ_rvalid_internal    ),  //slave data valid
  .targ_rready_i  (  targ_rready_internal    ),   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
  
  
  // ---------------------------------------------------------------
  // AXI INIT Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // // -------------- 
  .init_awid_o    (  init_awid_internal      ),    	  //
  .init_awaddr_o  (  init_awaddr_internal    ),  	  //
  .init_awlen_o   (  init_awlen_internal     ), 	  //burst length is 1 + (0 - 15)
  .init_awsize_o  (  init_awsize_internal    ),	  //size of each transfer in burst
  .init_awburst_o (  init_awburst_internal   ),	  //for bursts>1(), accept only incr burst=01
  .init_awlock_o  (  init_awlock_internal    ),	  //only normal access supported axs_awlock=00
  .init_awcache_o (  init_awcache_internal   ),	  //
  .init_awprot_o  (  init_awprot_internal    ),  	  //
  .init_awregion_o(  init_awregion_internal  ),  	  //
  .init_awuser_o  (  init_awuser_internal    ),  	  //
  .init_awqos_o   (  init_awqos_internal     ),  	  //
  .init_awvalid_o (  init_awvalid_internal   ),	  //master addr valid
  .init_awready_i (  init_awready_internal   ),	  //slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // // -------------- 
  .init_wdata_o   (  init_wdata_internal    ),
  .init_wstrb_o   (  init_wstrb_internal    ),   //1 strobe per byte
  .init_wlast_o   (  init_wlast_internal    ),   //last transfer in burst
  .init_wuser_o   (  init_wuser_internal    ),  //master data valid
  .init_wvalid_o  (  init_wvalid_internal   ),  //master data valid
  .init_wready_i  (  init_wready_internal   ),  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI BACKWARD write response bus -------------- // // -------------- 
  .init_bid_i     (  init_bid_internal      ),
  .init_bresp_i   (  init_bresp_internal    ),
  .init_buser_i   (  init_buser_internal    ),
  .init_bvalid_i  (  init_bvalid_internal   ),
  .init_bready_o  (  init_bready_internal   ),
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  .init_arid_o    (  init_arid_internal     ),
  .init_araddr_o  (  init_araddr_internal   ),
  .init_arlen_o   (  init_arlen_internal    ),   //burst length - 1 to 16
  .init_arsize_o  (  init_arsize_internal   ),  //size of each transfer in burst
  .init_arburst_o (  init_arburst_internal  ), //for bursts>1(), accept only incr burst=01
  .init_arlock_o  (  init_arlock_internal   ),  //only normal access supported axs_awlock=00
  .init_arcache_o (  init_arcache_internal  ), 
  .init_arprot_o  (  init_arprot_internal   ),
  .init_arregion_o(  init_arregion_internal ),
  .init_aruser_o  (  init_aruser_internal   ),
  .init_arqos_o   (  init_arqos_internal    ),
  .init_arvalid_o (  init_arvalid_internal  ), //master addr valid
  .init_arready_i (  init_arready_internal  ), //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  .init_rid_i     (  init_rid_internal     ),
  .init_rdata_i   (  init_rdata_internal   ),
  .init_rresp_i   (  init_rresp_internal   ),
  .init_rlast_i   (  init_rlast_internal   ),   //last transfer in burst
  .init_ruser_i   (  init_ruser_internal   ),   //last transfer in burst
  .init_rvalid_i  (  init_rvalid_internal  ),  //slave data valid
  .init_rready_o  (  init_rready_internal  ),   //master ready to accept
  // ---------------------------------------------------------------
  
  
  // PROGRAMMABLE PORT -- AXI LITE
  .s_axi_awaddr   (  s_axi_awaddr   ),
  .s_axi_awvalid  (  s_axi_awvalid  ),
  .s_axi_awready  (  s_axi_awready  ),
  .s_axi_wdata    (  s_axi_wdata    ),
  .s_axi_wstrb    (  s_axi_wstrb    ),
  .s_axi_wvalid   (  s_axi_wvalid   ),
  .s_axi_wready   (  s_axi_wready   ),
  .s_axi_bresp    (  s_axi_bresp    ),
  .s_axi_bvalid   (  s_axi_bvalid   ),
  .s_axi_bready   (  s_axi_bready   ),
  .s_axi_araddr   (  s_axi_araddr   ),
  .s_axi_arvalid  (  s_axi_arvalid  ),
  .s_axi_arready  (  s_axi_arready  ),
  .s_axi_rdata    (  s_axi_rdata    ),
  .s_axi_rresp    (  s_axi_rresp    ),
  .s_axi_rvalid   (  s_axi_rvalid   ),
  .s_axi_rready   (  s_axi_rready   )
);    
    
    





   //-----------------------------------------------------//
   // REGISTER_SLICES PORT 0 MASTER
   //-----------------------------------------------------//
   axi_aw_buffer
   #(
       .ID_WIDTH(AXI_ID_IN),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_aw_buffer_0
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( targ_0_awvalid_i  ),
      .slave_addr_i    ( targ_0_awaddr_i   ),
      .slave_prot_i    ( targ_0_awprot_i   ),
      .slave_region_i  ( targ_0_awregion_i ),
      .slave_len_i     ( targ_0_awlen_i    ),
      .slave_size_i    ( targ_0_awsize_i   ),
      .slave_burst_i   ( targ_0_awburst_i  ),
      .slave_lock_i    ( targ_0_awlock_i   ),
      .slave_cache_i   ( targ_0_awcache_i  ),
      .slave_qos_i     ( targ_0_awqos_i    ),
      .slave_id_i      ( targ_0_awid_i     ),
      .slave_user_i    ( targ_0_awuser_i   ),
      .slave_ready_o   ( targ_0_awready_o  ),
      
      .master_valid_o  ( targ_awvalid_internal[0]        ),
      .master_addr_o   ( targ_awaddr_internal[0]         ),
      .master_prot_o   ( targ_awprot_internal[0]         ),
      .master_region_o ( targ_awregion_internal[0]       ),
      .master_len_o    ( targ_awlen_internal[0]          ),
      .master_size_o   ( targ_awsize_internal[0]         ),
      .master_burst_o  ( targ_awburst_internal[0]        ),
      .master_lock_o   ( targ_awlock_internal[0]         ),
      .master_cache_o  ( targ_awcache_internal[0]        ),
      .master_qos_o    ( targ_awqos_internal[0]          ),
      .master_id_o     ( targ_awid_internal[0]           ),
      .master_user_o   ( targ_awuser_internal[0]         ),
      .master_ready_i  ( targ_awready_internal[0]        )
   );	
	
	
   // AXI WRITE ADDRESS CHANNEL BUFFER
   axi_ar_buffer
   #(
       .ID_WIDTH(AXI_ID_IN),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_ar_buffer_0
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( targ_0_arvalid_i  ),
      .slave_addr_i    ( targ_0_araddr_i   ),
      .slave_prot_i    ( targ_0_arprot_i   ),
      .slave_region_i  ( targ_0_arregion_i ),
      .slave_len_i     ( targ_0_arlen_i    ),
      .slave_size_i    ( targ_0_arsize_i   ),
      .slave_burst_i   ( targ_0_arburst_i  ),
      .slave_lock_i    ( targ_0_arlock_i   ),
      .slave_cache_i   ( targ_0_arcache_i  ),
      .slave_qos_i     ( targ_0_arqos_i    ),
      .slave_id_i      ( targ_0_arid_i     ),
      .slave_user_i    ( targ_0_aruser_i   ),
      .slave_ready_o   ( targ_0_arready_o  ),
                              
      .master_valid_o  ( targ_arvalid_internal[0]        ),
      .master_addr_o   ( targ_araddr_internal[0]         ),
      .master_prot_o   ( targ_arprot_internal[0]         ),
      .master_region_o ( targ_arregion_internal[0]       ),
      .master_len_o    ( targ_arlen_internal[0]          ),
      .master_size_o   ( targ_arsize_internal[0]         ),
      .master_burst_o  ( targ_arburst_internal[0]        ),
      .master_lock_o   ( targ_arlock_internal[0]         ),
      .master_cache_o  ( targ_arcache_internal[0]        ),
      .master_qos_o    ( targ_arqos_internal[0]          ),
      .master_id_o     ( targ_arid_internal[0]           ),
      .master_user_o   ( targ_aruser_internal[0]         ),
      .master_ready_i  ( targ_arready_internal[0]        )
   );		
   
   
   
   
   axi_w_buffer
   #(
       .DATA_WIDTH(AXI_DATA_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_w_buffer_0
   (
    
	.clk_i          ( clk    ),
	.rst_ni         ( rst_n  ),
	
	.slave_valid_i  (targ_0_wvalid_i ),
	.slave_data_i   (targ_0_wdata_i  ),
	.slave_strb_i   (targ_0_wstrb_i  ),
	.slave_user_i   (targ_0_wuser_i  ),
	.slave_last_i   (targ_0_wlast_i  ),
	.slave_ready_o  (targ_0_wready_o ),
	
	.master_valid_o (targ_wvalid_internal[0] ),
	.master_data_o  (targ_wdata_internal[0]  ),
	.master_strb_o  (targ_wstrb_internal[0]  ),
	.master_user_o  (targ_wuser_internal[0]  ),
	.master_last_o  (targ_wlast_internal[0]  ),
	.master_ready_i (targ_wready_internal[0] )
    );

   axi_r_buffer
   #(
	.ID_WIDTH(AXI_ID_IN),
	.DATA_WIDTH(AXI_DATA_W),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_r_buffer_0
   (
   
	.clk_i(clk), 
	.rst_ni(rst_n), 
	
	.slave_valid_i  (  targ_rvalid_internal[0]   ), 
	.slave_data_i   (  targ_rdata_internal[0]    ), 
	.slave_resp_i   (  targ_rresp_internal[0]    ), 
	.slave_user_i   (  targ_ruser_internal[0]    ), 
	.slave_id_i     (  targ_rid_internal[0]      ), 
	.slave_last_i   (  targ_rlast_internal[0]    ), 
	.slave_ready_o  (  targ_rready_internal[0]   ), 
	
	.master_valid_o (  targ_0_rvalid_o  ), 
	.master_data_o  (  targ_0_rdata_o   ), 
	.master_resp_o  (  targ_0_rresp_o   ), 
	.master_user_o  (  targ_0_ruser_o   ), 
	.master_id_o    (  targ_0_rid_o     ), 
	.master_last_o  (  targ_0_rlast_o   ), 
	.master_ready_i (  targ_0_rready_i  )
	
   );
   

 
 
   
   axi_b_buffer
   #(
	.ID_WIDTH(AXI_ID_IN),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_b_buffer_0
   (
	.clk_i         ( clk            ), 
	.rst_ni        ( rst_n          ), 

	.slave_valid_i ( targ_bvalid_internal[0]     ), 
	.slave_resp_i  ( targ_bresp_internal[0]      ), 
	.slave_id_i    ( targ_bid_internal[0]        ), 
	.slave_user_i  ( targ_buser_internal[0]      ), 
	.slave_ready_o ( targ_bready_internal[0]     ), 
                       
	.master_valid_o( targ_0_bvalid_o   ), 
	.master_resp_o ( targ_0_bresp_o    ), 
	.master_id_o   ( targ_0_bid_o      ), 
	.master_user_o ( targ_0_buser_o    ), 
	.master_ready_i( targ_0_bready_i   )
   );  
   
   
   
   
   
   
   
   
   
   
   
   //-----------------------------------------------------//
   // REGISTER_SLICES PORT 1 MASTER
   //-----------------------------------------------------//
   axi_aw_buffer
   #(
       .ID_WIDTH(AXI_ID_IN),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_aw_buffer_1
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( targ_1_awvalid_i  ),
      .slave_addr_i    ( targ_1_awaddr_i   ),
      .slave_prot_i    ( targ_1_awprot_i   ),
      .slave_region_i  ( targ_1_awregion_i ),
      .slave_len_i     ( targ_1_awlen_i    ),
      .slave_size_i    ( targ_1_awsize_i   ),
      .slave_burst_i   ( targ_1_awburst_i  ),
      .slave_lock_i    ( targ_1_awlock_i   ),
      .slave_cache_i   ( targ_1_awcache_i  ),
      .slave_qos_i     ( targ_1_awqos_i    ),
      .slave_id_i      ( targ_1_awid_i     ),
      .slave_user_i    ( targ_1_awuser_i   ),
      .slave_ready_o   ( targ_1_awready_o  ),
      
      .master_valid_o  ( targ_awvalid_internal[1]        ),
      .master_addr_o   ( targ_awaddr_internal[1]         ),
      .master_prot_o   ( targ_awprot_internal[1]         ),
      .master_region_o ( targ_awregion_internal[1]       ),
      .master_len_o    ( targ_awlen_internal[1]          ),
      .master_size_o   ( targ_awsize_internal[1]         ),
      .master_burst_o  ( targ_awburst_internal[1]        ),
      .master_lock_o   ( targ_awlock_internal[1]         ),
      .master_cache_o  ( targ_awcache_internal[1]        ),
      .master_qos_o    ( targ_awqos_internal[1]          ),
      .master_id_o     ( targ_awid_internal[1]           ),
      .master_user_o   ( targ_awuser_internal[1]         ),
      .master_ready_i  ( targ_awready_internal[1]        )
   );	
	
	
   // AXI WRITE ADDRESS CHANNEL BUFFER
   axi_ar_buffer
   #(
       .ID_WIDTH(AXI_ID_IN),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_ar_buffer_1
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( targ_1_arvalid_i  ),
      .slave_addr_i    ( targ_1_araddr_i   ),
      .slave_prot_i    ( targ_1_arprot_i   ),
      .slave_region_i  ( targ_1_arregion_i ),
      .slave_len_i     ( targ_1_arlen_i    ),
      .slave_size_i    ( targ_1_arsize_i   ),
      .slave_burst_i   ( targ_1_arburst_i  ),
      .slave_lock_i    ( targ_1_arlock_i   ),
      .slave_cache_i   ( targ_1_arcache_i  ),
      .slave_qos_i     ( targ_1_arqos_i    ),
      .slave_id_i      ( targ_1_arid_i     ),
      .slave_user_i    ( targ_1_aruser_i   ),
      .slave_ready_o   ( targ_1_arready_o  ),
      
      .master_valid_o  ( targ_arvalid_internal[1]        ),
      .master_addr_o   ( targ_araddr_internal[1]         ),
      .master_prot_o   ( targ_arprot_internal[1]         ),
      .master_region_o ( targ_arregion_internal[1]       ),
      .master_len_o    ( targ_arlen_internal[1]          ),
      .master_size_o   ( targ_arsize_internal[1]         ),
      .master_burst_o  ( targ_arburst_internal[1]        ),
      .master_lock_o   ( targ_arlock_internal[1]         ),
      .master_cache_o  ( targ_arcache_internal[1]        ),
      .master_qos_o    ( targ_arqos_internal[1]          ),
      .master_id_o     ( targ_arid_internal[1]           ),
      .master_user_o   ( targ_aruser_internal[1]         ),
      .master_ready_i  ( targ_arready_internal[1]        )
   );		
   
   
   
   
   axi_w_buffer
   #(
       .DATA_WIDTH(AXI_DATA_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_w_buffer_1
   (
    
	.clk_i          ( clk    ),
	.rst_ni         ( rst_n  ),
	
	.slave_valid_i  (targ_1_wvalid_i ),
	.slave_data_i   (targ_1_wdata_i  ),
	.slave_strb_i   (targ_1_wstrb_i  ),
	.slave_user_i   (targ_1_wuser_i  ),
	.slave_last_i   (targ_1_wlast_i  ),
	.slave_ready_o  (targ_1_wready_o ),
	
	.master_valid_o (targ_wvalid_internal[1] ),
	.master_data_o  (targ_wdata_internal[1]  ),
	.master_strb_o  (targ_wstrb_internal[1]  ),
	.master_user_o  (targ_wuser_internal[1]  ),
	.master_last_o  (targ_wlast_internal[1]  ),
	.master_ready_i (targ_wready_internal[1] )
    );

   axi_r_buffer
   #(
	.ID_WIDTH(AXI_ID_IN),
	.DATA_WIDTH(AXI_DATA_W),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_r_buffer_1
   (
   
	.clk_i(clk), 
	.rst_ni(rst_n), 
	
	.slave_valid_i  ( targ_rvalid_internal[1]    ), 
	.slave_data_i   ( targ_rdata_internal[1]     ), 
	.slave_resp_i   ( targ_rresp_internal[1]     ), 
	.slave_user_i   ( targ_ruser_internal[1]     ), 
	.slave_id_i     ( targ_rid_internal[1]       ), 
	.slave_last_i   ( targ_rlast_internal[1]     ), 
	.slave_ready_o  ( targ_rready_internal[1]    ), 
	
	.master_valid_o ( targ_1_rvalid_o      ), 
	.master_data_o  ( targ_1_rdata_o       ), 
	.master_resp_o  ( targ_1_rresp_o       ), 
	.master_user_o  ( targ_1_ruser_o       ), 
	.master_id_o    ( targ_1_rid_o         ), 
	.master_last_o  ( targ_1_rlast_o       ), 
	.master_ready_i ( targ_1_rready_i      )
	
   );





   axi_b_buffer
   #(
	.ID_WIDTH(AXI_ID_IN),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_MASTER)
   )
   Master_b_buffer_1
   (
	.clk_i         ( clk            ), 
	.rst_ni        ( rst_n          ), 

	.slave_valid_i ( targ_bvalid_internal[1]    ), 
	.slave_resp_i  ( targ_bresp_internal[1]     ), 
	.slave_id_i    ( targ_bid_internal[1]       ), 
	.slave_user_i  ( targ_buser_internal[1]     ), 
	.slave_ready_o ( targ_bready_internal[1]    ), 
                       
	.master_valid_o( targ_1_bvalid_o  ), 
	.master_resp_o ( targ_1_bresp_o   ), 
	.master_id_o   ( targ_1_bid_o     ), 
	.master_user_o ( targ_1_buser_o   ), 
	.master_ready_i( targ_1_bready_i  )
   
   );  
   




        
        
        
        
        
      
      
   //-----------------------------------------------------//
   // REGISTER_SLICES PORT 0 SLAVE
   //-----------------------------------------------------//
   // AXI WRITE ADDRESS CHANNEL BUFFER
   axi_aw_buffer
   #(
       .ID_WIDTH(AXI_ID_OUT),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_SLAVE )
   )
   Slave_aw_buffer_0
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( init_awvalid_internal[0]  ),
      .slave_addr_i    ( init_awaddr_internal[0]   ),
      .slave_prot_i    ( init_awprot_internal[0]   ),
      .slave_region_i  ( init_awregion_internal[0] ),
      .slave_len_i     ( init_awlen_internal[0]    ),
      .slave_size_i    ( init_awsize_internal[0]   ),
      .slave_burst_i   ( init_awburst_internal[0]  ),
      .slave_lock_i    ( init_awlock_internal[0]   ),
      .slave_cache_i   ( init_awcache_internal[0]  ),
      .slave_qos_i     ( init_awqos_internal[0]    ),
      .slave_id_i      ( init_awid_internal[0]     ),
      .slave_user_i    ( init_awuser_internal[0]   ),
      .slave_ready_o   ( init_awready_internal[0]  ),
      
      .master_valid_o  ( init_0_awvalid_o        ),
      .master_addr_o   ( init_0_awaddr_o         ),
      .master_prot_o   ( init_0_awprot_o         ),
      .master_region_o ( init_0_awregion_o       ),
      .master_len_o    ( init_0_awlen_o          ),
      .master_size_o   ( init_0_awsize_o         ),
      .master_burst_o  ( init_0_awburst_o        ),
      .master_lock_o   ( init_0_awlock_o         ),
      .master_cache_o  ( init_0_awcache_o        ),
      .master_qos_o    ( init_0_awqos_o          ),
      .master_id_o     ( init_0_awid_o           ),
      .master_user_o   ( init_0_awuser_o         ),
      .master_ready_i  ( init_0_awready_i        )
   );	
	
	
   // AXI WRITE ADDRESS CHANNEL BUFFER
   axi_ar_buffer
   #(
       .ID_WIDTH(AXI_ID_OUT),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_ar_buffer_0
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( init_arvalid_internal[0]  ),
      .slave_addr_i    ( init_araddr_internal[0]   ),
      .slave_prot_i    ( init_arprot_internal[0]   ),
      .slave_region_i  ( init_arregion_internal[0] ),
      .slave_len_i     ( init_arlen_internal[0]    ),
      .slave_size_i    ( init_arsize_internal[0]   ),
      .slave_burst_i   ( init_arburst_internal[0]  ),
      .slave_lock_i    ( init_arlock_internal[0]   ),
      .slave_cache_i   ( init_arcache_internal[0]  ),
      .slave_qos_i     ( init_arqos_internal[0]    ),
      .slave_id_i      ( init_arid_internal[0]     ),
      .slave_user_i    ( init_aruser_internal[0]   ),
      .slave_ready_o   ( init_arready_internal[0]  ),
      
      .master_valid_o  ( init_0_arvalid_o        ),
      .master_addr_o   ( init_0_araddr_o         ),
      .master_prot_o   ( init_0_arprot_o         ),
      .master_region_o ( init_0_arregion_o       ),
      .master_len_o    ( init_0_arlen_o          ),
      .master_size_o   ( init_0_arsize_o         ),
      .master_burst_o  ( init_0_arburst_o        ),
      .master_lock_o   ( init_0_arlock_o         ),
      .master_cache_o  ( init_0_arcache_o        ),
      .master_qos_o    ( init_0_arqos_o          ),
      .master_id_o     ( init_0_arid_o           ),
      .master_user_o   ( init_0_aruser_o         ),
      .master_ready_i  ( init_0_arready_i        )
   );		
   
   
   
   
   axi_w_buffer
   #(
       .DATA_WIDTH(AXI_DATA_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_w_buffer_0
   (
    
	.clk_i          ( clk    ),
	.rst_ni         ( rst_n  ),
	
	.slave_valid_i  (init_wvalid_internal[0] ),
	.slave_data_i   (init_wdata_internal[0]  ),
	.slave_strb_i   (init_wstrb_internal[0]  ),
	.slave_user_i   (init_wuser_internal[0]  ),
	.slave_last_i   (init_wlast_internal[0]  ),
	.slave_ready_o  (init_wready_internal[0] ),
	
	.master_valid_o (init_0_wvalid_o ),
	.master_data_o  (init_0_wdata_o  ),
	.master_strb_o  (init_0_wstrb_o  ),
	.master_user_o  (init_0_wuser_o  ),
	.master_last_o  (init_0_wlast_o  ),
	.master_ready_i (init_0_wready_i )
    );

   axi_r_buffer
   #(
	.ID_WIDTH(AXI_ID_OUT),
	.DATA_WIDTH(AXI_DATA_W),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_r_buffer_0
   (
   
	.clk_i(clk), 
	.rst_ni(rst_n), 
	
	.slave_valid_i  ( init_0_rvalid_i        ), 
	.slave_data_i   ( init_0_rdata_i         ), 
	.slave_resp_i   ( init_0_rresp_i         ), 
	.slave_user_i   ( init_0_ruser_i         ), 
	.slave_id_i     ( init_0_rid_i           ), 
	.slave_last_i   ( init_0_rlast_i         ), 
	.slave_ready_o  ( init_0_rready_o        ), 
	
	.master_valid_o ( init_rvalid_internal[0]  ), 
	.master_data_o  ( init_rdata_internal[0]   ), 
	.master_resp_o  ( init_rresp_internal[0]   ), 
	.master_user_o  ( init_ruser_internal[0]   ), 
	.master_id_o    ( init_rid_internal[0]     ), 
	.master_last_o  ( init_rlast_internal[0]   ), 
	.master_ready_i ( init_rready_internal[0]  )
	
   );
   
   axi_b_buffer
   #(
	.ID_WIDTH(AXI_ID_OUT),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_b_buffer_0
   (
	.clk_i         ( clk            ), 
	.rst_ni        ( rst_n          ), 

	.slave_valid_i ( init_0_bvalid_i       ), 
	.slave_resp_i  ( init_0_bresp_i        ), 
	.slave_id_i    ( init_0_bid_i          ), 
	.slave_user_i  ( init_0_buser_i        ), 
	.slave_ready_o ( init_0_bready_o       ), 

	.master_valid_o( init_bvalid_internal[0] ), 
	.master_resp_o ( init_bresp_internal[0]  ), 
	.master_id_o   ( init_bid_internal[0]    ), 
	.master_user_o ( init_buser_internal[0]  ), 
	.master_ready_i( init_bready_internal[0] )
   
   );  
   
   

   //-----------------------------------------------------//
   // REGISTER_SLICES PORT 1 SLAVE
   //-----------------------------------------------------//
   // AXI WRITE ADDRESS CHANNEL BUFFER
   axi_aw_buffer
   #(
       .ID_WIDTH(AXI_ID_OUT),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_SLAVE )
   )
   Slave_aw_buffer_1
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( init_awvalid_internal[1]  ),
      .slave_addr_i    ( init_awaddr_internal[1]   ),
      .slave_prot_i    ( init_awprot_internal[1]   ),
      .slave_region_i  ( init_awregion_internal[1] ),
      .slave_len_i     ( init_awlen_internal[1]    ),
      .slave_size_i    ( init_awsize_internal[1]   ),
      .slave_burst_i   ( init_awburst_internal[1]  ),
      .slave_lock_i    ( init_awlock_internal[1]   ),
      .slave_cache_i   ( init_awcache_internal[1]  ),
      .slave_qos_i     ( init_awqos_internal[1]    ),
      .slave_id_i      ( init_awid_internal[1]     ),
      .slave_user_i    ( init_awuser_internal[1]   ),
      .slave_ready_o   ( init_awready_internal[1]  ),
      
      .master_valid_o  ( init_1_awvalid_o        ),
      .master_addr_o   ( init_1_awaddr_o         ),
      .master_prot_o   ( init_1_awprot_o         ),
      .master_region_o ( init_1_awregion_o       ),
      .master_len_o    ( init_1_awlen_o          ),
      .master_size_o   ( init_1_awsize_o         ),
      .master_burst_o  ( init_1_awburst_o        ),
      .master_lock_o   ( init_1_awlock_o         ),
      .master_cache_o  ( init_1_awcache_o        ),
      .master_qos_o    ( init_1_awqos_o          ),
      .master_id_o     ( init_1_awid_o           ),
      .master_user_o   ( init_1_awuser_o         ),
      .master_ready_i  ( init_1_awready_i        )
   );	
	
	
   // AXI WRITE ADDRESS CHANNEL BUFFER
   axi_ar_buffer
   #(
       .ID_WIDTH(AXI_ID_OUT),
       .ADDR_WIDTH(AXI_ADDRESS_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_ar_buffer_1
   (
      .clk_i         ( clk),
      .rst_ni        ( rst_n),
      
      .slave_valid_i   ( init_arvalid_internal[1]  ),
      .slave_addr_i    ( init_araddr_internal[1]   ),
      .slave_prot_i    ( init_arprot_internal[1]   ),
      .slave_region_i  ( init_arregion_internal[1] ),
      .slave_len_i     ( init_arlen_internal[1]    ),
      .slave_size_i    ( init_arsize_internal[1]   ),
      .slave_burst_i   ( init_arburst_internal[1]  ),
      .slave_lock_i    ( init_arlock_internal[1]   ),
      .slave_cache_i   ( init_arcache_internal[1]  ),
      .slave_qos_i     ( init_arqos_internal[1]    ),
      .slave_id_i      ( init_arid_internal[1]     ),
      .slave_user_i    ( init_aruser_internal[1]   ),
      .slave_ready_o   ( init_arready_internal[1]  ),
      
      .master_valid_o  ( init_1_arvalid_o        ),
      .master_addr_o   ( init_1_araddr_o         ),
      .master_prot_o   ( init_1_arprot_o         ),
      .master_region_o ( init_1_arregion_o       ),
      .master_len_o    ( init_1_arlen_o          ),
      .master_size_o   ( init_1_arsize_o         ),
      .master_burst_o  ( init_1_arburst_o        ),
      .master_lock_o   ( init_1_arlock_o         ),
      .master_cache_o  ( init_1_arcache_o        ),
      .master_qos_o    ( init_1_arqos_o          ),
      .master_id_o     ( init_1_arid_o           ),
      .master_user_o   ( init_1_aruser_o         ),
      .master_ready_i  ( init_1_arready_i        )
   );		
   
   
   
   
   axi_w_buffer
   #(
       .DATA_WIDTH(AXI_DATA_W),
       .USER_WIDTH(AXI_USER_W),
       .BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_w_buffer_1
   (
    
	.clk_i          ( clk    ),
	.rst_ni         ( rst_n  ),
	
	.slave_valid_i  (init_wvalid_internal[1] ),
	.slave_data_i   (init_wdata_internal[1]  ),
	.slave_strb_i   (init_wstrb_internal[1]  ),
	.slave_user_i   (init_wuser_internal[1]  ),
	.slave_last_i   (init_wlast_internal[1]  ),
	.slave_ready_o  (init_wready_internal[1] ),
	
	.master_valid_o (init_1_wvalid_o ),
	.master_data_o  (init_1_wdata_o  ),
	.master_strb_o  (init_1_wstrb_o  ),
	.master_user_o  (init_1_wuser_o  ),
	.master_last_o  (init_1_wlast_o  ),
	.master_ready_i (init_1_wready_i )
    );

   axi_r_buffer
   #(
	.ID_WIDTH(AXI_ID_OUT),
	.DATA_WIDTH(AXI_DATA_W),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_r_buffer_1
   (
   
	.clk_i(clk), 
	.rst_ni(rst_n), 
	
	.slave_valid_i  ( init_1_rvalid_i        ), 
	.slave_data_i   ( init_1_rdata_i         ), 
	.slave_resp_i   ( init_1_rresp_i         ), 
	.slave_user_i   ( init_1_ruser_i         ), 
	.slave_id_i     ( init_1_rid_i           ), 
	.slave_last_i   ( init_1_rlast_i         ), 
	.slave_ready_o  ( init_1_rready_o        ), 
	
	.master_valid_o ( init_rvalid_internal[1]  ), 
	.master_data_o  ( init_rdata_internal[1]   ), 
	.master_resp_o  ( init_rresp_internal[1]   ), 
	.master_user_o  ( init_ruser_internal[1]   ), 
	.master_id_o    ( init_rid_internal[1]     ), 
	.master_last_o  ( init_rlast_internal[1]   ), 
	.master_ready_i ( init_rready_internal[1]  )
	
   );
   
   axi_b_buffer
   #(
	.ID_WIDTH(AXI_ID_OUT),
	.USER_WIDTH(AXI_USER_W),
	.BUFFER_DEPTH(BUFF_DEPTH_SLAVE)
   )
   Slave_b_buffer_1
   (
	.clk_i         ( clk            ), 
	.rst_ni        ( rst_n          ), 

	.slave_valid_i ( init_1_bvalid_i       ), 
	.slave_resp_i  ( init_1_bresp_i        ), 
	.slave_id_i    ( init_1_bid_i          ), 
	.slave_user_i  ( init_1_buser_i        ), 
	.slave_ready_o ( init_1_bready_o       ), 

	.master_valid_o( init_bvalid_internal[1] ), 
	.master_resp_o ( init_bresp_internal[1]  ), 
	.master_id_o   ( init_bid_internal[1]    ), 
	.master_user_o ( init_buser_internal[1]  ), 
	.master_ready_i( init_bready_internal[1] )
   
   );  
   
 
    
endmodule 
   
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
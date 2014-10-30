`include "defines.v"

module axi_node_wrap_2x2
#(
    parameter  			AXI_ADDRESS_W  = 32,
    parameter  			AXI_DATA_W     = 64,
    parameter                   AXI_NUMBYTES   = AXI_DATA_W/8,
    parameter			AXI_USER_W     = 6,
    parameter			AXI_LITE_ADDRESS_W = 32,
    parameter			AXI_LITE_DATA_W    = 32,
    parameter  			AXI_ID_IN      = 16,  
    parameter			FIFO_DEPTH_DW  = 8,
    
    parameter 			AXI_ID_OUT     = AXI_ID_IN + `log2(N_TARG_PORT-1),
    parameter			NUM_REGS       = N_INIT_PORT*2
)
(
  input wire 								clk,
  input wire 								rst_n,
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

    localparam 			N_INIT_PORT    = 2;
    localparam 			N_TARG_PORT    = 2;


    
  //AXI write address bus -------------- // USED// -------------- 
  wire  [N_TARG_PORT-1:0][AXI_ID_IN-1:0]      			targ_awid_i;	//
  wire  [N_TARG_PORT-1:0][AXI_ADDRESS_W-1:0] 			targ_awaddr_i;	//
  wire  [N_TARG_PORT-1:0][ 7:0]					targ_awlen_i;   	//burst length is 1 + (0 - 15)
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_awsize_i;  	//size of each transfer in burst
  wire  [N_TARG_PORT-1:0][ 1:0]					targ_awburst_i; 	//for bursts>1; accept only incr burst=01
  wire  [N_TARG_PORT-1:0]					targ_awlock_i;  	//only normal access supported axs_awlock=00
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_awcache_i; 	//
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_awprot_i;	//
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_awregion_i;	//
  wire  [N_TARG_PORT-1:0][ AXI_USER_W-1:0]			targ_awuser_i;	//
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_awqos_i;	//  
  wire  [N_TARG_PORT-1:0]					targ_awvalid_i; 	//master addr valid
  wire  [N_TARG_PORT-1:0]					targ_awready_o; 	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // USED// -------------- 
  wire  [N_TARG_PORT-1:0] [AXI_DATA_W-1:0]			targ_wdata_i;
  wire  [N_TARG_PORT-1:0] [AXI_NUMBYTES-1:0]			targ_wstrb_i;   //1 strobe per byte
  wire  [N_TARG_PORT-1:0]					targ_wlast_i;   //last transfer in burst
  wire  [N_TARG_PORT-1:0][AXI_USER_W-1:0]			targ_wuser_i;   // User sideband signal
  wire  [N_TARG_PORT-1:0]					targ_wvalid_i;  //master data valid
  wire  [N_TARG_PORT-1:0]					targ_wready_o;  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI write response bus -------------- // USED// -------------- 
  output  logic [N_TARG_PORT-1:0]  [AXI_ID_IN-1:0]		targ_bid_o;
  output  logic [N_TARG_PORT-1:0]  [ 1:0]			targ_bresp_o;
  output  logic [N_TARG_PORT-1:0]				targ_bvalid_o;
  output  logic [N_TARG_PORT-1:0]  [AXI_USER_W-1:0]		targ_buser_o;   // User sideband signal
  input   logic [N_TARG_PORT-1:0]				targ_bready_i;
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  wire  [N_TARG_PORT-1:0][AXI_ID_IN-1:0]			targ_arid_i;
  wire  [N_TARG_PORT-1:0][AXI_ADDRESS_W-1:0]			targ_araddr_i;
  wire  [N_TARG_PORT-1:0][ 7:0]					targ_arlen_i;   //burst length - 1 to 16
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_arsize_i;  //size of each transfer in burst
  wire  [N_TARG_PORT-1:0][ 1:0]					targ_arburst_i; //for bursts>1; accept only incr burst=01
  wire  [N_TARG_PORT-1:0]					targ_arlock_i;  //only normal access supported axs_awlock=00
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_arcache_i; 
  wire  [N_TARG_PORT-1:0][ 2:0]					targ_arprot_i;
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_arregion_i;	//
  wire  [N_TARG_PORT-1:0][ AXI_USER_W-1:0]			targ_aruser_i;	//
  wire  [N_TARG_PORT-1:0][ 3:0]					targ_arqos_i;	//  
  wire  [N_TARG_PORT-1:0]					targ_arvalid_i; //master addr valid
  wire  [N_TARG_PORT-1:0]					targ_arready_o; //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI read data bus ----------------------------------------------
  wire  [N_TARG_PORT-1:0][AXI_ID_IN-1:0]			targ_rid_o;
  wire  [N_TARG_PORT-1:0][AXI_DATA_W-1:0]			targ_rdata_o;
  wire  [N_TARG_PORT-1:0][ 1:0]               			targ_rresp_o;
  wire  [N_TARG_PORT-1:0]                     			targ_rlast_o;   //last transfer in burst
  wire  [N_TARG_PORT-1:0][AXI_USER_W-1:0]       		targ_ruser_o;   //last transfer in burst
  wire  [N_TARG_PORT-1:0]                    			targ_rvalid_o;  //slave data valid
  wire  [N_TARG_PORT-1:0]                   			targ_rready_i;   //master ready to accept
  // ---------------------------------------------------------------
  


  
  // ---------------------------------------------------------------
  // AXI INIT wire Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // // -------------- 
  wire [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]      			init_awid_o;	//
  wire [N_INIT_PORT-1:0][AXI_ADDRESS_W-1:0] 			init_awaddr_o;	//
  wire [N_INIT_PORT-1:0][ 7:0]					init_awlen_o;   	//burst length is 1 + (0 - 15)
  wire [N_INIT_PORT-1:0][ 2:0]					init_awsize_o;  	//size of each transfer in burst
  wire [N_INIT_PORT-1:0][ 1:0]					init_awburst_o; 	//for bursts>1; accept only incr burst=01
  wire [N_INIT_PORT-1:0]					init_awlock_o;  	//only normal access supported axs_awlock=00
  wire [N_INIT_PORT-1:0][ 3:0]					init_awcache_o; 	//
  wire [N_INIT_PORT-1:0][ 2:0]					init_awprot_o;	//
  wire [N_INIT_PORT-1:0][ 3:0]					init_awregion_o;	//
  wire [N_INIT_PORT-1:0][ AXI_USER_W-1:0]			init_awuser_o;	//
  wire [N_INIT_PORT-1:0][ 3:0]					init_awqos_o;	//  
  wire [N_INIT_PORT-1:0]					init_awvalid_o; 	//master addr valid
  wire [N_INIT_PORT-1:0]					init_awready_i; 	//slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // // -------------- 
  wire [N_INIT_PORT-1:0] [AXI_DATA_W-1:0]			init_wdata_o;
  wire [N_INIT_PORT-1:0] [AXI_NUMBYTES-1:0]			init_wstrb_o;   //1 strobe per byte
  wire [N_INIT_PORT-1:0]					init_wlast_o;   //last transfer in burst
  wire [N_INIT_PORT-1:0] [ AXI_USER_W-1:0]			init_wuser_o;   //user sideband signals
  wire [N_INIT_PORT-1:0]					init_wvalid_o;  //master data valid
  wire [N_INIT_PORT-1:0]					init_wready_i;  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI BACKWARD write response bus -------------- // // -------------- 
  wire [N_INIT_PORT-1:0] [AXI_ID_OUT-1:0]			init_bid_i;
  wire [N_INIT_PORT-1:0] [ 1:0]					init_bresp_i;
  wire [N_INIT_PORT-1:0] [ AXI_USER_W-1:0]			init_buser_i;
  wire [N_INIT_PORT-1:0]					init_bvalid_i;
  wire [N_INIT_PORT-1:0]					init_bready_o;
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  wire [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]			init_arid_o;
  wire [N_INIT_PORT-1:0][AXI_ADDRESS_W-1:0]			init_araddr_o;
  wire [N_INIT_PORT-1:0][ 7:0]					init_arlen_o;   //burst length - 1 to 16
  wire [N_INIT_PORT-1:0][ 2:0]					init_arsize_o;  //size of each transfer in burst
  wire [N_INIT_PORT-1:0][ 1:0]					init_arburst_o; //for bursts>1; accept only incr burst=01
  wire [N_INIT_PORT-1:0]					init_arlock_o;  //only normal access supported axs_awlock=00
  wire [N_INIT_PORT-1:0][ 3:0]					init_arcache_o; 
  wire [N_INIT_PORT-1:0][ 2:0]					init_arprot_o;
  wire [N_INIT_PORT-1:0][ 3:0]					init_arregion_o;	//
  wire [N_INIT_PORT-1:0][ AXI_USER_W-1:0]			init_aruser_o;	//
  wire [N_INIT_PORT-1:0][ 3:0]					init_arqos_o;	//  
  wire [N_INIT_PORT-1:0]					init_arvalid_o; //master addr valid
  wire [N_INIT_PORT-1:0]					init_arready_i; //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  wire [N_INIT_PORT-1:0][AXI_ID_OUT-1:0]			init_rid_i;
  wire [N_INIT_PORT-1:0][AXI_DATA_W-1:0]			init_rdata_i;
  wire [N_INIT_PORT-1:0][ 1:0]               			init_rresp_i;
  wire [N_INIT_PORT-1:0]                     			init_rlast_i;   //last transfer in burst
  wire [N_INIT_PORT-1:0][ AXI_USER_W-1:0]			init_ruser_i;
  wire [N_INIT_PORT-1:0]                    			init_rvalid_i;  //slave data valid
  wire [N_INIT_PORT-1:0]                   			init_rready_o;   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
      
      
      
    
 assign targ_awid_i    = {targ_1_awid_i     ,targ_0_awid_i};
 assign targ_awaddr_i  = {targ_1_awaddr_i   ,targ_0_awaddr_i};  
 assign targ_awlen_i   = {targ_1_awlen_i    ,targ_0_awlen_i};	    
 assign targ_awsize_i  = {targ_1_awsize_i   ,targ_0_awsize_i};      
 assign targ_awburst_i = {targ_1_awburst_i  ,targ_0_awburst_i};     
 assign targ_awlock_i  = {targ_1_awlock_i   ,targ_0_awlock_i};      
 assign targ_awcache_i = {targ_1_awcache_i  ,targ_0_awcache_i};     
 assign targ_awprot_i  = {targ_1_awprot_i   ,targ_0_awprot_i};  
 assign targ_awregion_i= {targ_1_awregion_i ,targ_0_awregion_i};
 assign targ_awuser_i  = {targ_1_awuser_i   ,targ_0_awuser_i};  
 assign targ_awqos_i   = {targ_1_awqos_i    ,targ_0_awqos_i};	
 assign targ_awvalid_i = {targ_1_awvalid_i  ,targ_0_awvalid_i};     
 assign {targ_1_awready_o  ,targ_0_awready_o} = targ_awready_o;	  
  

 assign targ_wdata_i  = {targ_1_wdata_i ,targ_0_wdata_i };
 assign targ_wstrb_i  = {targ_1_wstrb_i ,targ_0_wstrb_i };   
 assign targ_wlast_i  = {targ_1_wlast_i ,targ_0_wlast_i };   
 assign targ_wuser_i  = {targ_1_wuser_i ,targ_0_wuser_i };   
 assign targ_wvalid_i = {targ_1_wvalid_i,targ_0_wvalid_i};  
 assign {targ_1_wready_o,targ_0_wready_o} = targ_wready_o;  

 assign {targ_1_bid_o	,targ_0_bid_o	} = targ_bid_o    ;
 assign {targ_1_bresp_o ,targ_0_bresp_o } = targ_bresp_o  ;
 assign {targ_1_bvalid_o,targ_0_bvalid_o} = targ_bvalid_o ;
 assign {targ_1_buser_o ,targ_0_buser_o } = targ_buser_o  ;   
 assign targ_bready_i = {targ_1_bready_i,targ_0_bready_i} ;

 assign targ_arid_i     = {targ_1_arid_i    ,targ_0_arid_i    };
 assign targ_araddr_i   = {targ_1_araddr_i  ,targ_0_araddr_i  };
 assign targ_arlen_i    = {targ_1_arlen_i   ,targ_0_arlen_i   };   
 assign targ_arsize_i   = {targ_1_arsize_i  ,targ_0_arsize_i  };  
 assign targ_arburst_i  = {targ_1_arburst_i ,targ_0_arburst_i }; 
 assign targ_arlock_i   = {targ_1_arlock_i  ,targ_0_arlock_i  };  
 assign targ_arcache_i  = {targ_1_arcache_i ,targ_0_arcache_i }; 
 assign targ_arprot_i   = {targ_1_arprot_i  ,targ_0_arprot_i  };
 assign targ_arregion_i = {targ_1_arregion_i,targ_0_arregion_i};
 assign targ_aruser_i   = {targ_1_aruser_i  ,targ_0_aruser_i  };    
 assign targ_arqos_i    = {targ_1_arqos_i   ,targ_0_arqos_i   };    
 assign targ_arvalid_i  = {targ_1_arvalid_i ,targ_0_arvalid_i }; 
 assign {targ_1_arready_o ,targ_0_arready_o } = targ_arready_o; 

 assign {targ_1_rid_o	,targ_0_rid_o	} = targ_rid_o   ;
 assign {targ_1_rdata_o ,targ_0_rdata_o } = targ_rdata_o ;
 assign {targ_1_rresp_o ,targ_0_rresp_o } = targ_rresp_o ;
 assign {targ_1_rlast_o ,targ_0_rlast_o } = targ_rlast_o ;   
 assign {targ_1_ruser_o ,targ_0_ruser_o } = targ_ruser_o ;   
 assign {targ_1_rvalid_o,targ_0_rvalid_o} = targ_rvalid_o;  
 assign targ_rready_i = {targ_1_rready_i,targ_0_rready_i};     
    
    
    
    

 assign {,} = init_awid_o      ;	
 assign {,} = init_awaddr_o    ;	
 assign {,} = init_awlen_o     ;   
 assign {,} = init_awsize_o    ;  
 assign {,} = init_awburst_o   ; 
 assign {,} = init_awlock_o    ;  
 assign {,} = init_awcache_o   ; 
 assign {,} = init_awprot_o    ;	
 assign {,} = init_awregion_o  ;
 assign {,} = init_awuser_o    ;	
 assign {,} = init_awqos_o     ;	
 assign {,} = init_awvalid_o   ; 
 assign init_awready_i = {,}   ; 
  
assign  {,} = init_wdata_o     ;
assign  {,} = init_wstrb_o     ;	
assign  {,} = init_wlast_o     ;	
assign  {,} = init_wuser_o     ;	
assign  {,} = init_wvalid_o    ;  
assign  init_wready_i  = {,}   ;  
        
assign  init_bid_i    = {,}   ;
assign  init_bresp_i  = {,}   ;
assign  init_buser_i  = {,}   ;
assign  init_bvalid_i = {,}   ;
assign  {,} = init_bready_o   ;
        
assign  {,} = init_arid_o     ;
assign  {,} = init_araddr_o   ;
assign  {,} = init_arlen_o    ;	
assign  {,} = init_arsize_o   ;  
assign  {,} = init_arburst_o  ; 
assign  {,} = init_arlock_o   ;  
assign  {,} = init_arcache_o  ; 
assign  {,} = init_arprot_o   ;
assign  {,} = init_arregion_o ;
assign  {,} = init_aruser_o   ;  
assign  {,} = init_arqos_o    ;	
assign  {,} = init_arvalid_o  ; 
assign  init_arready_i = {,}  ; 
        
assign  init_rid_i   = {,}    ;
assign  init_rdata_i = {,}    ;
assign  init_rresp_i = {,}    ;
assign  init_rlast_i = {,}    ;	
assign  init_ruser_i = {,}    ;
assign  init_rvalid_i= {,}    ;   
assign  {,} = init_rready_o   ;  
 
    
    
    

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
  .targ_awid_i    (   targ_awid_i      ),            //
  .targ_awaddr_i  (   targ_awaddr_i    ),          //
  .targ_awlen_i   (   targ_awlen_i     ), 	  //burst length is 1 + (0 - 15)
  .targ_awsize_i  (   targ_awsize_i    ),	  //size of each transfer in burst
  .targ_awburst_i (   targ_awburst_i   ),	  //for bursts>1(), accept only incr burst=01
  .targ_awlock_i  (   targ_awlock_i    ),	  //only normal access supported axs_awlock=00
  .targ_awcache_i (   targ_awcache_i   ),	  //
  .targ_awprot_i  (   targ_awprot_i    ),    	  //
  .targ_awregion_i(   targ_awregion_i  ),    	  //
  .targ_awqos_i   (   targ_awqos_i     ),     	  //
  .targ_awuser_i  (   targ_awuser_i    ),    	  //
  .targ_awvalid_i (   targ_awvalid_i   ),	  //master addr valid
  .targ_awready_o (   targ_awready_o   ),	  //slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // USED// -------------- 
  .targ_wdata_i  (    targ_wdata_i     ),
  .targ_wstrb_i  (    targ_wstrb_i     ),   //1 strobe per byte
  .targ_wlast_i  (    targ_wlast_i     ),   //last transfer in burst
  .targ_wuser_i  (    targ_wuser_i     ),   //last transfer in burst
  .targ_wvalid_i (    targ_wvalid_i    ),  //master data valid
  .targ_wready_o (    targ_wready_o    ),  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI write response bus -------------- // USED// -------------- 
  .targ_bid_o    (    targ_bid_o      ),
  .targ_bresp_o  (    targ_bresp_o    ),
  .targ_buser_o  (    targ_buser_o    ),
  .targ_bvalid_o (    targ_bvalid_o   ),
  .targ_bready_i (    targ_bready_i   ),
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  .targ_arid_i    (  targ_arid_i      ),
  .targ_araddr_i  (  targ_araddr_i    ),
  .targ_arlen_i   (  targ_arlen_i     ),   //burst length - 1 to 16
  .targ_arsize_i  (  targ_arsize_i    ),  //size of each transfer in burst
  .targ_arburst_i (  targ_arburst_i   ), //for bursts>1(), accept only incr burst=01
  .targ_arlock_i  (  targ_arlock_i    ),  //only normal access supported axs_awlock=00
  .targ_arcache_i (  targ_arcache_i   ), 
  .targ_arprot_i  (  targ_arprot_i    ),
  .targ_arregion_i(  targ_arregion_i  ),
  .targ_aruser_i  (  targ_aruser_i    ),
  .targ_arqos_i   (  targ_arqos_i     ),
  .targ_arvalid_i (  targ_arvalid_i   ), //master addr valid
  .targ_arready_o (  targ_arready_o   ), //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI read data bus ----------------------------------------------
  .targ_rid_o     (  targ_rid_o       ),
  .targ_rdata_o   (  targ_rdata_o     ),
  .targ_rresp_o   (  targ_rresp_o     ),
  .targ_rlast_o   (  targ_rlast_o     ),   //last transfer in burst
  .targ_ruser_o   (  targ_ruser_o     ),
  .targ_rvalid_o  (  targ_rvalid_o    ),  //slave data valid
  .targ_rready_i  (  targ_rready_i    ),   //master ready to accept
  // ---------------------------------------------------------------
  
  
  
  
  
  // ---------------------------------------------------------------
  // AXI INIT Port Declarations -----------------------------------------
  // ---------------------------------------------------------------
  //AXI write address bus -------------- // // -------------- 
  .init_awid_o    (  init_awid_o      ),    	  //
  .init_awaddr_o  (  init_awaddr_o    ),  	  //
  .init_awlen_o   (  init_awlen_o     ), 	  //burst length is 1 + (0 - 15)
  .init_awsize_o  (  init_awsize_o    ),	  //size of each transfer in burst
  .init_awburst_o (  init_awburst_o   ),	  //for bursts>1(), accept only incr burst=01
  .init_awlock_o  (  init_awlock_o    ),	  //only normal access supported axs_awlock=00
  .init_awcache_o (  init_awcache_o   ),	  //
  .init_awprot_o  (  init_awprot_o    ),  	  //
  .init_awregion_o(  init_awregion_o  ),  	  //
  .init_awuser_o  (  init_awuser_o    ),  	  //
  .init_awqos_o   (  init_awqos_o     ),  	  //
  .init_awvalid_o (  init_awvalid_o   ),	  //master addr valid
  .init_awready_i (  init_awready_i   ),	  //slave ready to accept
  // ---------------------------------------------------------------

  //AXI write data bus -------------- // // -------------- 
  .init_wdata_o   (  init_wdata_o    ),
  .init_wstrb_o   (  init_wstrb_o    ),   //1 strobe per byte
  .init_wlast_o   (  init_wlast_o    ),   //last transfer in burst
  .init_wuser_o   (  init_wuser_o    ),  //master data valid
  .init_wvalid_o  (  init_wvalid_o   ),  //master data valid
  .init_wready_i  (  init_wready_i   ),  //slave ready to accept
  // ---------------------------------------------------------------
  
  //AXI BACKWARD write response bus -------------- // // -------------- 
  .init_bid_i     (  init_bid_i      ),
  .init_bresp_i   (  init_bresp_i    ),
  .init_buser_i   (  init_buser_i    ),
  .init_bvalid_i  (  init_bvalid_i   ),
  .init_bready_o  (  init_bready_o   ),
  // ---------------------------------------------------------------
  
  
  
  //AXI read address bus -------------------------------------------
  .init_arid_o    (  init_arid_o     ),
  .init_araddr_o  (  init_araddr_o   ),
  .init_arlen_o   (  init_arlen_o    ),   //burst length - 1 to 16
  .init_arsize_o  (  init_arsize_o   ),  //size of each transfer in burst
  .init_arburst_o (  init_arburst_o  ), //for bursts>1(), accept only incr burst=01
  .init_arlock_o  (  init_arlock_o   ),  //only normal access supported axs_awlock=00
  .init_arcache_o (  init_arcache_o  ), 
  .init_arprot_o  (  init_arprot_o   ),
  .init_arregion_o(  init_arregion_o ),
  .init_aruser_o  (  init_aruser_o   ),
  .init_arqos_o   (  init_arqos_o    ),
  .init_arvalid_o (  init_arvalid_o  ), //master addr valid
  .init_arready_i (  init_arready_i  ), //slave ready to accept
  // ---------------------------------------------------------------
  
  
  //AXI BACKWARD read data bus ----------------------------------------------
  .init_rid_i     (  init_rid_i     ),
  .init_rdata_i   (  init_rdata_i   ),
  .init_rresp_i   (  init_rresp_i   ),
  .init_rlast_i   (  init_rlast_i   ),   //last transfer in burst
  .init_ruser_i   (  init_ruser_i   ),   //last transfer in burst
  .init_rvalid_i  (  init_rvalid_i  ),  //slave data valid
  .init_rready_o  (  init_rready_o  ),   //master ready to accept
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
    
    
    
     
    
endmodule 
 

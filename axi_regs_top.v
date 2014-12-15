module axi_regs_top
#(
    parameter C_S_AXI_ADDR_WIDTH = 32,
    parameter C_S_AXI_DATA_WIDTH = 32,
    
    parameter N_REGION_MAX       = 4,
    parameter N_INIT_PORT        = 16,
    parameter N_TARG_PORT        = 16
)
(
    input  logic							s_axi_aclk,
    input  logic							s_axi_aresetn,
    // ADDRESS WRITE CHANNEL
    input  logic [C_S_AXI_ADDR_WIDTH-1:0] 				s_axi_awaddr,
    input  logic							s_axi_awvalid,
    output logic							s_axi_awready,
    
    
    // ADDRESS READ CHANNEL
    input  logic [C_S_AXI_ADDR_WIDTH-1:0]				s_axi_araddr,
    input  logic 							s_axi_arvalid,
    output logic							s_axi_arready,
    
    
    // ADDRESS WRITE CHANNEL
    input  logic [C_S_AXI_DATA_WIDTH-1:0]				s_axi_wdata,
    input  logic [C_S_AXI_DATA_WIDTH/8-1:0]				s_axi_wstrb,
    input  logic 							s_axi_wvalid,
    output logic							s_axi_wready,
    
    input  logic 							s_axi_bready,
    output logic [1:0] 							s_axi_bresp,
    output logic							s_axi_bvalid,
    
     // RESPONSE READ CHANNEL
    output logic  [C_S_AXI_DATA_WIDTH-1:0] 				s_axi_rdata,
    output logic             		    				s_axi_rvalid,
    input  logic             		    				s_axi_rready,
    output logic [1:0] 							s_axi_rresp,
   
    input  logic [N_REGION_MAX-1:0][N_INIT_PORT-1:0][C_S_AXI_DATA_WIDTH-1:0]	 init_START_ADDR_i,
    input  logic [N_REGION_MAX-1:0][N_INIT_PORT-1:0][C_S_AXI_DATA_WIDTH-1:0]	 init_END_ADDR_i,
    input  logic [N_REGION_MAX-1:0][N_INIT_PORT-1:0][C_S_AXI_DATA_WIDTH-1:0]	 init_valid_rule_i,
    input  logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]				 init_connectivity_map_i,
    
    output logic [N_REGION_MAX-1:0][N_INIT_PORT-1:0][C_S_AXI_DATA_WIDTH-1:0]	START_ADDR_o,
    output logic [N_REGION_MAX-1:0][N_INIT_PORT-1:0][C_S_AXI_DATA_WIDTH-1:0]	END_ADDR_o,
    output logic [N_REGION_MAX-1:0][N_INIT_PORT-1:0]				valid_rule_o,
    
    output logic [N_TARG_PORT-1:0][N_INIT_PORT-1:0]				connectivity_map_o
);

  localparam NUM_REGS           = N_INIT_PORT*4*N_REGION_MAX + N_TARG_PORT;
  
  
  
  reg                               awaddr_done_reg;
  reg                               awaddr_done_reg_dly;
  reg                               wdata_done_reg;
  reg                               wdata_done_reg_dly;
  reg                               wresp_done_reg;
  reg                               wresp_running_reg;

  reg                               araddr_done_reg;
  reg                               rresp_done_reg;
  reg                               rresp_running_reg;

  reg                               awready;
  reg                               wready;
  reg                               bvalid;

  reg                               arready;
  reg                               rvalid;

  reg      [C_S_AXI_ADDR_WIDTH-1:0] waddr_reg;
  reg      [C_S_AXI_DATA_WIDTH-1:0] wdata_reg;
  reg                         [3:0] wstrb_reg;

  reg      [C_S_AXI_ADDR_WIDTH-1:0] raddr_reg;
  reg      [C_S_AXI_DATA_WIDTH-1:0] data_out_reg;

  integer                           byte_index;
  
  integer			    k,y;
  genvar i,j;

  wire wdata_done_rise;
  wire awaddr_done_rise;
  wire write_en;
  
  
  logic [NUM_REGS-1:0][C_S_AXI_DATA_WIDTH/8-1:0][7:0]		cfg_reg;
  
  
  assign write_en = (wdata_done_rise & awaddr_done_reg) | (awaddr_done_rise & wdata_done_reg);
  assign wdata_done_rise = wdata_done_reg & ~wdata_done_reg_dly;
  assign awaddr_done_rise = awaddr_done_reg & ~awaddr_done_reg_dly;
  always @(posedge s_axi_aclk or negedge s_axi_aresetn)
  begin
    if (!s_axi_aresetn)
    begin
      wdata_done_reg_dly  <= 0;
      awaddr_done_reg_dly <= 0;
    end
    else
    begin
      wdata_done_reg_dly  <= wdata_done_reg;
      awaddr_done_reg_dly <= awaddr_done_reg;
    end
  end
  // WRITE ADDRESS CHANNEL logic
  always @(posedge s_axi_aclk or negedge s_axi_aresetn)
  begin
    if (!s_axi_aresetn)
    begin
      awaddr_done_reg <= 0;
      waddr_reg       <= 0;
      awready         <= 1;
    end
    else
    begin
      if (awready && s_axi_awvalid)
      begin
        awready   <= 0;
        awaddr_done_reg <= 1;
        waddr_reg <= s_axi_awaddr;
      end
      else if (awaddr_done_reg && wresp_done_reg)
      begin
        awready   <= 1;
        awaddr_done_reg <= 0;
      end
    end
  end

  // WRITE DATA CHANNEL logic
  always @(posedge s_axi_aclk or negedge s_axi_aresetn)
  begin
    if (!s_axi_aresetn)
    begin
      wdata_done_reg <= 0;
      wready         <= 1;
      wdata_reg      <= 0;
      wstrb_reg      <= 0;
    end
    else
    begin
      if (wready && s_axi_wvalid)
      begin
        wready   <= 0;
        wdata_done_reg <= 1;
        wdata_reg <= s_axi_wdata;
        wstrb_reg <= s_axi_wstrb;
      end
      else if (wdata_done_reg && wresp_done_reg)
      begin
        wready   <= 1;
        wdata_done_reg <= 0;
      end
    end
  end

  // WRITE RESPONSE CHANNEL logic
  always @(posedge s_axi_aclk or negedge s_axi_aresetn)
  begin
    if (!s_axi_aresetn)
    begin
      bvalid            <= 0;
      wresp_done_reg    <= 0;
      wresp_running_reg <= 0;
    end
    else
    begin
      if (awaddr_done_reg && wdata_done_reg && !wresp_done_reg)
      begin
        if (!wresp_running_reg)
        begin
          bvalid         <= 1;
          wresp_running_reg <= 1;
        end
        else if (s_axi_bready)
        begin
          bvalid         <= 0;
          wresp_done_reg <= 1;
          wresp_running_reg <= 0;
        end
      end
      else
      begin
        bvalid         <= 0;
        wresp_done_reg <= 0;
        wresp_running_reg <= 0;
      end
    end
  end

  // READ ADDRESS CHANNEL logic
  always @(posedge s_axi_aclk or negedge s_axi_aresetn)
  begin
    if (!s_axi_aresetn)
    begin
      araddr_done_reg <= 0;
      arready         <= 1;
      raddr_reg       <= 0;
    end
    else
    begin
      if (arready && s_axi_arvalid)
      begin
        arready   <= 0;
        araddr_done_reg <= 1;
        raddr_reg <= s_axi_araddr;
      end
      else if (araddr_done_reg && rresp_done_reg)
      begin
        arready   <= 1;
        araddr_done_reg <= 0;
      end
    end
  end

  // READ RESPONSE CHANNEL logic
  always @(posedge s_axi_aclk or negedge s_axi_aresetn)
  begin
    if (!s_axi_aresetn)
    begin
      rresp_done_reg    <= 0;
      rvalid            <= 0;
      rresp_running_reg <= 0;
    end
    else
    begin
      if (araddr_done_reg && !rresp_done_reg)
      begin
        if (!rresp_running_reg)
        begin
          rvalid            <= 1;
          rresp_running_reg <= 1;
        end
        else if (s_axi_rready)
        begin
          rvalid            <= 0;
          rresp_done_reg    <= 1;
          rresp_running_reg <= 0;
        end
      end
      else
      begin
        rvalid         <= 0;
        rresp_done_reg <= 0;
        rresp_running_reg <= 0;
      end
    end
  end







  always @( posedge s_axi_aclk or negedge s_axi_aresetn )
  begin
      if ( s_axi_aresetn == 1'b0 )
      begin
        

      	  for(y = 0; y < N_REGION_MAX; y++)
	  begin
	      for(k = 0; k < N_INIT_PORT; k++)
	      begin	
      		    cfg_reg[ (y*N_INIT_PORT*4) + (k*4) + 0] <= init_START_ADDR_i [y][k];
		    cfg_reg[ (y*N_INIT_PORT*4) + (k*4) + 1] <= init_END_ADDR_i   [y][k];
		    cfg_reg[ (y*N_INIT_PORT*4) + (k*4) + 2] <= init_valid_rule_i [y][k];
		    cfg_reg[ (y*N_INIT_PORT*4) + (k*4) + 3] <= 32'hDEADBEEF;
	      end
	  end
         
 	 for(y = 0; y < N_TARG_PORT; y++)
 	 begin	      
 		    cfg_reg[N_INIT_PORT*4*N_REGION_MAX + y ][N_INIT_PORT-1:0] <=  init_connectivity_map_i[y];
 		    cfg_reg[N_INIT_PORT*4*N_REGION_MAX + y ][C_S_AXI_DATA_WIDTH-1:N_INIT_PORT] <=  '0;
 	 end
          
          
          

      end
      else  if (write_en)
	    begin
		  for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
		    if ( wstrb_reg[byte_index] == 1 )
		      cfg_reg[waddr_reg[7:0]][byte_index] <= wdata_reg[(byte_index*8) +: 8]; //TODO Handle Errors if we address unmapped address locations
            end

  end // SLAVE_REG_WRITE_PROC



  
  
  generate

  for(i=0;i<N_REGION_MAX;i++)
  begin
	for(j=0;j<N_INIT_PORT;j++)
	begin
	    	assign START_ADDR_o[i][j]    = cfg_reg[i*N_INIT_PORT*4 + j*4 + 0];
	    	assign END_ADDR_o[i][j]      = cfg_reg[i*N_INIT_PORT*4 + j*4 + 1];
	    	assign valid_rule_o[i][j]    = cfg_reg[i*N_INIT_PORT*4 + j*4 + 2];
	end   
  end
  
  for(i = 0; i < N_TARG_PORT; i++)
  begin	      
	    assign connectivity_map_o[i]  = cfg_reg[N_INIT_PORT*4*N_REGION_MAX + i][N_INIT_PORT-1:0];
  end

  endgenerate





  // implement slave model register read mux
  always_comb 
  begin
      data_out_reg = cfg_reg[raddr_reg[7:0]];
  end // SLAVE_REG_READ_PROC

  assign s_axi_awready = awready;
  assign s_axi_wready = wready;

  assign s_axi_bresp = 2'b00;
  assign s_axi_bvalid = bvalid;

  assign s_axi_arready = arready;
  assign s_axi_rresp = 2'b00;
  assign s_axi_rvalid = rvalid;
  assign s_axi_rdata = data_out_reg;

endmodule

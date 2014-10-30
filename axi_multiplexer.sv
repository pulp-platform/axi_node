`include "defines.v"

module axi_multiplexer
#(
    parameter DATA_WIDTH = 64,
    parameter N_IN       = 16,
    parameter SEL_WIDTH  = `log2(N_IN-1)
) 
(
    input  logic [N_IN-1:0][DATA_WIDTH-1:0]		IN_DATA,
    output logic [DATA_WIDTH-1:0]			OUT_DATA,
    input  logic [SEL_WIDTH-1:0]			SEL
);


assign OUT_DATA = IN_DATA[SEL];

endmodule
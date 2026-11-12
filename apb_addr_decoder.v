module addr_decoder #(
    parameter NUM_SLAVES = 8,
    parameter ADDR_WIDTH = 32,
    // Slave Adressess and Masks
    parameter [NUM_SLAVES*ADDR_WIDTH-1:0] SLAVE_BASE = {32'h0070_0000, 32'h0060_0000, 32'h0050_0000, 32'h0040_0000, 32'h0030_0000, 32'h0020_0000, 32'h0010_0000, 32'h0000_0000},
    parameter [NUM_SLAVES*ADDR_WIDTH-1:0] SLAVE_MASK = {32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_1}
)
(
    input wire [ADDR_WIDTH-1:0] xfer_addr,
    output reg [NUM_SLAVES-1:0] slave_sel, // One-hot encoding of selecting the slave
    output wire decode_err          // 1 when xfer_addr matched no slave range
);
    integer i;

    wire [ADDR_WIDTH-1:0] base [NUM_SLAVES-1:0];
    wire [ADDR_WIDTH-1:0] mask [NUM_SLAVES-1:0];

    // Converting linear array to 2D array for easy access
    genvar g;
    generate
        for (g = 0; g < NUM_SLAVES; g = g + 1) begin : gen_base_mask
            assign base[g] = SLAVE_BASE[(g+1)*ADDR_WIDTH-1 -: ADDR_WIDTH];
            assign mask[g] = SLAVE_MASK[(g+1)*ADDR_WIDTH-1 -: ADDR_WIDTH];
        end
    endgenerate

    // If address matches the corresponding slave value is made 1
    always@(*) begin
        for (i = 0; i < NUM_SLAVES; i = i + 1) begin
            if ((xfer_addr & mask[i]) == base[i]) begin
                slave_sel[i] = 1;
            end
	        else slave_sel[i] = 0;
        end
    end

    assign decode_err = ~|slave_sel; // If none of the slave is selected, generating error

endmodule //addr_decoder

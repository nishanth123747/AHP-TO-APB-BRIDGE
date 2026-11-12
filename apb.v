module apb #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_SLAVES = 8
)
(   
    // Inputs from CDC
    input wire PCLK,
    input wire PRESETn,
    input wire [ADDR_WIDTH-1:0] PADDR_IN,
    input wire [NUM_SLAVES-1:0] PSEL_IN,
    input wire PENABLE_IN,
    input wire PWRITE_IN,
    input wire [DATA_WIDTH-1:0] PWDATA_IN,
    input wire [2:0] PSIZE,

    // Outputs to CDC
    output reg [DATA_WIDTH-1:0] PRDATA_OUT,
    output reg PREADY_OUT,
    output reg PSLVERR_OUT,

    // Outputs to APB slave
    output reg [ADDR_WIDTH-1:0] PADDR,
    output reg [NUM_SLAVES-1:0] PSEL,
    output reg PENABLE,
    output reg PWRITE,
    output reg [DATA_WIDTH-1:0] PWDATA,
    output reg [(DATA_WIDTH/8)-1:0] PSTRB,
    
    // Inputs from APB slave
    input wire [DATA_WIDTH-1:0] PRDATA,
    input wire PREADY,
    input wire PSLVERR,

    // time_out module
    output reg timer_start,
    input wire timed_out
);
    // Parameters
    localparam IDLE = 2'b00, SETUP_PHASE = 2'b01, ACCESS_PHASE = 2'b10;
    localparam STRB_WIDTH = DATA_WIDTH/8;

    reg [1:0] cs, ns; // Current State and Next State

    // Data regs
    reg [ADDR_WIDTH-1:0] addr_r;
    reg [NUM_SLAVES-1:0] sel_r;
    reg write_r;
    reg [DATA_WIDTH-1:0] wdata_r;
    reg [2:0] size_r;

    // Regs for calculating PSTRB
    reg [9:0] num_bytes;
    reg [$clog2(STRB_WIDTH)-1:0] offset;

    // Assigning next state to current state
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) cs <= IDLE;
        else          cs <= ns;
    end

    // next state logic
    always @(*) begin
        case (cs)
            IDLE:         ns = PENABLE_IN ? SETUP_PHASE : IDLE;
            SETUP_PHASE:  ns = ACCESS_PHASE;
            ACCESS_PHASE: ns = (PREADY || timed_out) ? IDLE : ACCESS_PHASE;
            default:      ns = IDLE;
        endcase
    end

    // Capturing Data from CDC
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            addr_r <= 0; sel_r <= 0; write_r <= 0; wdata_r <= 0; size_r <= 0;
        end
        else if (cs == IDLE && PENABLE_IN) begin // Capture in IDLE and is enabled
            addr_r  <= PADDR_IN;
            sel_r   <= PSEL_IN;
            write_r <= PWRITE_IN;
            wdata_r <= PWRITE_IN ? PWDATA_IN : {DATA_WIDTH{1'b0}};
            size_r  <= PSIZE;
        end
    end

    // Output Logic (To Slave)
    always @(*) begin
        timer_start = (cs == ACCESS_PHASE) && !PREADY && !timed_out; // Start the timer in ACCESS phase stop when slave is done or when timed out 
        case (cs)
            SETUP_PHASE: begin
                PSEL = sel_r; PENABLE = 1'b0;
                PADDR = addr_r; PWRITE = write_r; PWDATA = wdata_r;
            end
            ACCESS_PHASE: begin
                PSEL = sel_r; PENABLE = 1'b1;
                PADDR = addr_r; PWRITE = write_r; PWDATA = wdata_r;
            end
            default: begin
                PSEL = {NUM_SLAVES{1'b0}}; PENABLE = 1'b0;
                PADDR = 0; PWRITE = 0; PWDATA = 0;
            end
        endcase
    end

    // Output logic (To AHB)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA_OUT <= 0; PREADY_OUT <= 1; PSLVERR_OUT <= 1;
        end
        else if (cs == ACCESS_PHASE && PREADY) begin // When the data recived successful
            PRDATA_OUT  <= write_r ? {DATA_WIDTH{1'b0}} : PRDATA;
            PREADY_OUT  <= 1'b1;
            PSLVERR_OUT <= PSLVERR;
        end
        else if (cs == ACCESS_PHASE && timed_out) begin // When the data is timed out
            PRDATA_OUT  <= {DATA_WIDTH{1'b0}};
            PREADY_OUT  <= 1'b1;
            PSLVERR_OUT <= 1'b1;
        end
        else begin
            PREADY_OUT  <= 1'b0;
            PSLVERR_OUT <= 1'b0;
        end
    end

    // PSTRB logic
    always @(*) begin
        if (!write_r) begin // If read is performed PSTB = 0
            PSTRB = {STRB_WIDTH{1'b0}};
        end
        else begin
            num_bytes = (1 << size_r); // Number of bytes to be transfered
            if (num_bytes > STRB_WIDTH) begin // number of bytes should be less than or equal to STRB width
                num_bytes = STRB_WIDTH;
            end
            offset = addr_r[$clog2(STRB_WIDTH)-1:0]; // Offset value
            PSTRB = {STRB_WIDTH{1'b0}}; // Default value
            if (num_bytes == STRB_WIDTH) PSTRB = {STRB_WIDTH{1'b1}}; // All bits will be transfered
            else PSTRB = ({STRB_WIDTH{1'b1}} >> (STRB_WIDTH-num_bytes)) << offset;
        end
    end
endmodule //apb

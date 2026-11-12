module cdc_handshake #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_SLAVES = 8
)
(
    // Inputs from AHB
    input wire HCLK,
    input wire HRESETn,
    input wire req_valid,
    input wire [ADDR_WIDTH-1:0] addr_in,
    input wire write_in,
    input wire [2:0] size_in,
    input wire [DATA_WIDTH-1:0] wdata_in,
    input wire [NUM_SLAVES-1:0] slave_sel_in,
    input wire decode_err_in,               

    // Outputs to AHB
    output wire xfer_done,                       
    output reg [DATA_WIDTH-1:0] rdata_out,
    output reg resp_err_out,

    // Inputs from APB
    input wire PCLK,
    input wire PRESETn,
    input wire apb_done,
    input wire [DATA_WIDTH-1:0] rdata_in,
    input wire resp_err_in,

    // Outputs to APB
    output reg req,
    output reg [ADDR_WIDTH-1:0] addr_out,
    output reg write_out,
    output reg [2:0] size_out,
    output reg [DATA_WIDTH-1:0] wdata_out,
    output reg [NUM_SLAVES-1:0] slave_sel_out
);
    // Internal wires and registers
    reg busy_h; // Ensures data is held for synchronization
    reg req_toggle_h; // Toggle value of the request
    // Reg to caputre data
    reg [ADDR_WIDTH-1:0] addr_h;
    reg write_h;
    reg [2:0] size_h;
    reg [DATA_WIDTH-1:0] wdata_h;
    reg [NUM_SLAVES-1:0] sel_h;
    reg resp_err_p;
    reg xfer_done_r;
    reg decode_err_h;
    // Regs for synchronization
    reg req_sync1_p, req_sync2_p, req_sync3_p;
    reg done_toggle_p;
    reg [DATA_WIDTH-1:0] rdata_p;
    reg busy_p;
    reg done_sync1_h, done_sync2_h, done_sync3_h;
    
    reg decode_done_r; // There is a error while decoding and error is flagged and done is set
    
    wire accept_req_h = req_valid && !busy_h; // Condition for accepting request : we recieve the request and the bridge is not busy

    wire req_pulse_p = req_sync2_p ^ req_sync3_p; // Detects the request toggle 
    
    wire done_pulse_h = done_sync2_h ^ done_sync3_h; // Detects the done toggle

    assign xfer_done = req_valid ? 1'b0 : xfer_done_r; // Done signal to AHB

    wire local_done_pulse_h = done_pulse_h | decode_done_r; // If either of the signals is active the bridge has done it's work

    // Decode error and done for 1 clk cycle
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            decode_err_h  <= 1'b0;
            decode_done_r <= 1'b0;
        end
        else begin
            decode_done_r <= 1'b0;
            if (accept_req_h && decode_err_in) begin // If request is accepted and there is error in decode
                decode_err_h <= 1'b1;
            end
            else if (decode_err_h) begin // After 1 clk cycle decode_err_h goes down
                decode_err_h  <= 1'b0;
                decode_done_r <= 1'b1;
            end
        end
    end

    // Data capturing and busy_h handling
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            busy_h       <= 1'b0;
            req_toggle_h <= 1'b0;
            addr_h  <= 0; write_h <= 0; size_h <= 0; wdata_h <= 0; sel_h <= 0;
        end
        else begin
            if (accept_req_h) begin // Capture when request is accepted
                busy_h  <= 1'b1;
                addr_h  <= addr_in;
                write_h <= write_in;
                size_h  <= size_in;
                wdata_h <= wdata_in;
                sel_h   <= slave_sel_in;
                if (!decode_err_in) begin // If there is no decode error transmit the request to APB
                    req_toggle_h <= ~req_toggle_h;
                end
            end
            else if (local_done_pulse_h) begin // If transmission is done reset the busy_h signal
                busy_h <= 1'b0; 
            end
        end
    end

    // 3FF synchronizer for request
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            req_sync1_p <= 0; req_sync2_p <= 0; req_sync3_p <= 0;
        end else begin
            req_sync1_p <= req_toggle_h;
            req_sync2_p <= req_sync1_p;
            req_sync3_p <= req_sync2_p;
        end
    end

    // Sending data to APB when request is detected
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            req <= 0; addr_out <= 0; write_out <= 0;
            size_out <= 0; wdata_out <= 0; slave_sel_out <= 0;
        end
        else begin
            req <= req_pulse_p;
            if (req_pulse_p) begin
                addr_out      <= addr_h;
                write_out     <= write_h;
                size_out      <= size_h;
                wdata_out     <= wdata_h;
                slave_sel_out <= sel_h;
            end
        end
    end

    // Handling busy_p signal
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) busy_p <= 1'b0;
        else if (req_pulse_p) busy_p <= 1'b1; // is busy when the request is recieved
        else if (apb_done && busy_p) busy_p <= 1'b0; // set to 0 when the transmission is done
    end

    // Capturing output of APB and toggling done signal when done
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            done_toggle_p <= 1'b0;
            rdata_p <= 0; resp_err_p <= 0;
        end
        else if (apb_done && busy_p) begin // The busy signal helps the incoming data to capture only once hence avoiding change of data later (holding the data)
            done_toggle_p <= ~done_toggle_p;
            rdata_p    <= rdata_in;
            resp_err_p <= resp_err_in;
        end
    end

    // 3FF synchroniser for synchronising done signal
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            done_sync1_h <= 0; done_sync2_h <= 0; done_sync3_h <= 0;
        end else begin
            done_sync1_h <= done_toggle_p;
            done_sync2_h <= done_sync1_h;
            done_sync3_h <= done_sync2_h;
        end
    end

    // Handling outputs to AHB
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            xfer_done_r  <= 1'b1;
            rdata_out    <= 0;
            resp_err_out <= 0;
        end
        else begin
            if (req_valid)               xfer_done_r <= 1'b0; // Stating the bridge is busy
            else if (local_done_pulse_h) xfer_done_r <= 1'b1; // Stating the bridge is done

            if (decode_done_r) begin // If error occurs send 0 and set error
                rdata_out    <= {DATA_WIDTH{1'b0}};
                resp_err_out <= 1'b1;
            end
            else if (done_pulse_h) begin // If done send output
                rdata_out    <= rdata_p;
                resp_err_out <= resp_err_p;
            end
        end
    end

endmodule //cdc_handshake

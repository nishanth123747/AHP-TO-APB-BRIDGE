module ahb #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    // AHB-Lite interface
    input wire HCLK,
    input wire HRESETn,
    input wire HSEL,
    input wire [ADDR_WIDTH-1:0] HADDR,
    input wire [1:0] HTRANS,
    input wire HWRITE,
    input wire [DATA_WIDTH-1:0] HWDATA,
    input wire [2:0] HSIZE,
    input [2:0] HBURST,

    // From cdc_handshake
    input wire HREADY,
    input wire [DATA_WIDTH-1:0] rdata_in,
    input wire resp_err,

    // AHB-Lite outputs
    output reg [ADDR_WIDTH-1:0] HRDATA,
    output reg HREADYOUT,
    output reg HRESP,

    // Sent to cdc_handshake
    output reg xfer_start,
    output reg [ADDR_WIDTH-1:0] xfer_addr,
    output reg xfer_write,
    output reg [2:0] xfer_size,
    output reg [2:0] xfer_burst,
    output reg [DATA_WIDTH-1:0] xfer_wdata
);
    // Error values
    localparam OKAY = 0, ERROR = 1;

    // Internal State registers
    reg data_phase, started;
    reg error_phase;

    // Address Phase
    wire addr_phase = HSEL && HREADY && HTRANS[1]; // Is active when bridge is selected as a slave, APB is ready to recieve and Master is in SEQ or Non SEQ state

    always@(posedge HCLK or negedge HRESETn) begin
        // Reset Conditions
        if(!HRESETn) begin
            data_phase <= 0;
            started <= 0;
            error_phase <= 0;
            xfer_start <= 0;
            xfer_addr <= 0;
            xfer_write <= 0;
            xfer_size <= 0;
            xfer_burst <= 0;
            xfer_wdata <= 0;
            HRDATA <= 0;
            HREADYOUT <= 1;
            HRESP <= 0;
        end
        else begin
            xfer_start <= 0; // Default value for xfer_start
            if (error_phase) begin // For holding the error for one more clk cycle
                error_phase <= 1'b0;
                HREADYOUT   <= 1'b1;
                started     <= 1'b0;
                if (addr_phase) begin // Captures the address phase in error to account for the pipelineing or burst nature of AHB which isnt there in APB
                    data_phase <= 1;
                    xfer_addr  <= HADDR;
                    xfer_write <= HWRITE;
                    xfer_size  <= HSIZE;
                    xfer_burst <= HBURST;
                    started    <= 1;
                end
            end
            else if(addr_phase && !started) begin // Caputres the address and control signals if addr_phase is active and transmission is not started
                data_phase <=1; // Starts the data phase
                xfer_addr <= HADDR;
                xfer_write <= HWRITE;
                xfer_size <= HSIZE;
                xfer_burst <= HBURST;
                started <= 1;
            end
            else if(data_phase) begin // Captures the write data in write operation mode
//                 $display(
//     "[AHB RTL CAPTURE] TIME=%0t ADDR=%08h WRITE=%b HWDATA=%08h",
//     $time, xfer_addr, xfer_write, HWDATA
//   );
              data_phase <=0;
                if(xfer_write) begin
                    xfer_wdata <= HWDATA;
                end
                xfer_start <= 1; // Starts the transmission
                HREADYOUT <= 0; // Indicates Master that its busy
                HRESP <= 0; // Default response value
            end
            else if(started && HREADY) begin // Waiting for APB's response
                xfer_start <= 0; // Transmission Done
                HRDATA <= rdata_in; 
                HRESP  <= resp_err ? ERROR : OKAY;  
                if (resp_err) begin // If error occurs start the error phase
                    HREADYOUT   <= 1'b0;
                    error_phase <= 1'b1;
                end
                else begin
                    HREADYOUT <= 1'b1;
                    started   <= 0;
                    if(addr_phase) begin // Accounts for pipelinging nature of AHB
                        data_phase <=1;
                        xfer_addr <= HADDR;
                        xfer_write <= HWRITE;
                        xfer_size <= HSIZE;
                        xfer_burst <= HBURST;
                        started <= 1;
                    end
                end
            end
        end
    end

endmodule //ahb

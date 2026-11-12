module bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_SLAVES = 8,
    parameter TIMEOUT_COUNT = 10,
    parameter [NUM_SLAVES*ADDR_WIDTH-1:0] SLAVE_BASE = {32'h0070_0000, 32'h0060_0000, 32'h0050_0000, 32'h0040_0000, 32'h0030_0000, 32'h0020_0000, 32'h0010_0000, 32'h0000_0000},
    parameter [NUM_SLAVES*ADDR_WIDTH-1:0] SLAVE_MASK = {32'hFFF0_0000, 33'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000, 32'hFFF0_0000}
)
(
    // Clocks and Resets
    input wire HCLK,
    input wire HRESETn,
    input wire PCLK,
    input wire PRESETn,

    // AHB-Lite interface
    input wire HSEL,
    input wire [ADDR_WIDTH-1:0] HADDR,
    input wire [1:0] HTRANS,
    input wire HWRITE,
    input wire [DATA_WIDTH-1:0] HWDATA,
    input wire [2:0] HSIZE,
    input [2:0] HBURST,
    output wire [DATA_WIDTH-1:0] HRDATA,
    output wire HREADYOUT,
    output wire HRESP,

    // APB interface
    output wire [ADDR_WIDTH-1:0] PADDR,
    output wire [NUM_SLAVES-1:0] PSEL,
    output wire PENABLE,
    output wire PWRITE,
    output wire [DATA_WIDTH-1:0] PWDATA,
    output wire [(DATA_WIDTH/8)-1:0] PSTRB,
    input wire [DATA_WIDTH-1:0] PRDATA,
    input wire PREADY,
    input wire PSLVERR
);
    // Wire Declarations
    wire [ADDR_WIDTH-1:0] xfer_addr, paddr;
    wire req_valid, xfer_write, hready, hresp, penable, pwrite, pready, pslverr, timer_start, timed_out;
    wire [2:0] xfer_size, psize;
    wire [DATA_WIDTH-1:0] xfer_wdata, hrdata, pwdata, prdata;
    wire [NUM_SLAVES-1:0] xfer_slave_sel, psel;
    wire xfer_decode_err;

    // AHB module
    ahb #(ADDR_WIDTH, DATA_WIDTH) ahb_inst (
    // AHB-Lite interface
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HSEL(HSEL),
    .HADDR(HADDR),
    .HTRANS(HTRANS),
    .HWRITE(HWRITE),
    .HWDATA(HWDATA),
    .HSIZE(HSIZE),
    .HBURST(HBURST),

    // From cdc_handshake
    .HREADY(hready),
    .rdata_in(hrdata),
    .resp_err(hresp),

    // AHB-Lite outputs
    .HRDATA(HRDATA),
    .HREADYOUT(HREADYOUT),
    .HRESP(HRESP),

    // Sent to cdc_handshake
    .xfer_start(req_valid),
    .xfer_addr(xfer_addr),
    .xfer_write(xfer_write),
    .xfer_size(xfer_size),
    .xfer_burst(),
    .xfer_wdata(xfer_wdata)
    );

    // Address Decoder
    addr_decoder #(NUM_SLAVES, ADDR_WIDTH, SLAVE_BASE, SLAVE_MASK) addr_decoder_inst (
        .xfer_addr(xfer_addr),
        .slave_sel(xfer_slave_sel),
        .decode_err(xfer_decode_err)
    );

    // CDC Synchronizer
    cdc_handshake #(ADDR_WIDTH, DATA_WIDTH, NUM_SLAVES) sync_inst (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .req_valid(req_valid),
        .addr_in(xfer_addr),
        .write_in(xfer_write),
        .size_in(xfer_size),
        .wdata_in(xfer_wdata),
        .slave_sel_in(xfer_slave_sel),
        .decode_err_in(xfer_decode_err),

        .xfer_done(hready),
        .rdata_out(hrdata),
        .resp_err_out(hresp),

        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .apb_done(pready),
        .rdata_in(prdata),
        .resp_err_in(pslverr),

        .req(penable),
        .addr_out(paddr),
        .write_out(pwrite),
        .size_out(psize),
        .wdata_out(pwdata),
        .slave_sel_out(psel)
    );

    // APB Module
    apb #(ADDR_WIDTH, DATA_WIDTH, NUM_SLAVES) apb_inst (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR_IN(paddr),
        .PSEL_IN(psel),
        .PENABLE_IN(penable),
        .PWRITE_IN(pwrite),
        .PWDATA_IN(pwdata),
        .PSIZE(psize),

        .PRDATA_OUT(prdata),
        .PREADY_OUT(pready),
        .PSLVERR_OUT(pslverr),

        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PSTRB(PSTRB),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),

        .timer_start(timer_start),
        .timed_out(timed_out)
    );

    // Time Out Module
    time_out #(TIMEOUT_COUNT) timeout_inst (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .start(timer_start),
        .timed_out(timed_out)
    );
endmodule

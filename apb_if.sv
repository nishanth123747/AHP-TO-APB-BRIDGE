interface apb_if (input logic pclk, input logic presetn);
  logic [31:0] paddr;
  logic [7:0]  psel;      // one-hot, one bit per APB region
  logic        penable;
  logic        pwrite;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;

  clocking slv_cb @(posedge pclk);    // driver: samples DUT outputs, drives slave responses
    default input #1step output #1;
    input  paddr, psel, penable, pwrite, pwdata, pstrb;
    output prdata, pready, pslverr;
  endclocking

  clocking mon_cb @(posedge pclk);
    default input #1step;
    input paddr, psel, penable, pwrite, pwdata, pstrb, prdata, pready, pslverr;
  endclocking
endinterface

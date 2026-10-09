interface ahb_if (input logic hclk, input logic hresetn);
  logic        hsel;
  logic [31:0] haddr;
  logic [1:0]  htrans;
  logic        hwrite;
  logic [2:0]  hsize;
  logic [2:0]  hburst;
  logic [31:0] hwdata;
  logic        hreadyout;
  logic        hresp;
  logic [31:0] hrdata;

  clocking drv_cb @(posedge hclk);
    default input #1step output #1;
    output hsel, haddr, htrans, hwrite, hsize, hburst, hwdata;
    input  hreadyout, hresp, hrdata;
  endclocking

  clocking mon_cb @(posedge hclk);
    default input #1step;
    input hsel, haddr, htrans, hwrite, hsize, hburst, hwdata, hreadyout, hresp, hrdata;
  endclocking
endinterface

interface ahb_if(input logic HCLK);

  logic        HRESETn;

  logic        HSEL;
  logic [31:0] HADDR;
  logic [1:0]  HTRANS;
  logic        HWRITE;
  logic [2:0]  HSIZE;
  logic [2:0]  HBURST;
  logic [31:0] HWDATA;

  logic [31:0] HRDATA;
  logic        HREADYOUT;
  logic        HRESP;

  // Driver clocking block
  clocking driver_cb @(posedge HCLK);
    default input #1step output #0;

    output HSEL;
    output HADDR;
    output HTRANS;
    output HWRITE;
    output HSIZE;
    output HBURST;
    output HWDATA;

    input HRESETn;
    input HRDATA;
    input HREADYOUT;
    input HRESP;
  endclocking

  // Monitor clocking block
  clocking monitor_cb @(posedge HCLK);
    default input #1step output #0;

    input HRESETn;
    input HSEL;
    input HADDR;
    input HTRANS;
    input HWRITE;
    input HSIZE;
    input HBURST;
    input HWDATA;
    input HRDATA;
    input HREADYOUT;
    input HRESP;
  endclocking

  // Modports
  modport DRIVER  (clocking driver_cb);
  modport MONITOR (clocking monitor_cb);

  // DUT side modport 
  modport DUT (
    input  HCLK,
    input  HRESETn,
    input  HSEL,
    input  HADDR,
    input  HTRANS,
    input  HWRITE,
    input  HSIZE,
    input  HBURST,
    input  HWDATA,
    output HRDATA,
    output HREADYOUT,
    output HRESP
  );

endinterface

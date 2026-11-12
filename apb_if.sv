interface apb_if(input logic PCLK);

  logic        PRESETn;

  // APB request signals 
  logic [31:0] PADDR;
  logic        PWRITE;
  logic [31:0] PWDATA;
  logic [3:0]  PSTRB;
  logic [7:0]  PSEL;
  logic        PENABLE;

  // APB response signals 
  logic [31:0] PRDATA;
  logic        PREADY;
  logic        PSLVERR;

  clocking driver_cb @(posedge PCLK);
    default input #1step output #0;

    output PRDATA;
    output PREADY;
    output PSLVERR;

    input PRESETn;
    input PADDR;
    input PWRITE;
    input PWDATA;
    input PSTRB;
    input PSEL;
    input PENABLE;
  endclocking
  
  clocking monitor_cb @(posedge PCLK);
    default input #1step output #0;

    input PRESETn;
    input PADDR;
    input PWRITE;
    input PWDATA;
    input PSTRB;
    input PSEL;
    input PENABLE;

    input PRDATA;
    input PREADY;
    input PSLVERR;
  endclocking

  // modports
  modport DRIVER  (clocking driver_cb);
  modport MONITOR (clocking monitor_cb);

  modport DUT (
    input  PCLK,
    input  PRESETn,
    input  PRDATA,
    input  PREADY,
    input  PSLVERR,

    output PADDR,
    output PWRITE,
    output PWDATA,
    output PSTRB,
    output PSEL,
    output PENABLE
  );

endinterface

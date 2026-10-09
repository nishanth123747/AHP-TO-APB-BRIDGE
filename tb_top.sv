`timescale 1ns/1ps
// Simple top: independent clocks, interfaces, DUT, config_db. Rename the DUT and its ports.
module tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import ahb2apb_pkg::*;

  bit   hclk, pclk;
  logic hresetn = 0, presetn = 0;

  initial forever #5  hclk = ~hclk;     // 100 MHz
  initial forever #20 pclk = ~pclk;     // 25 MHz
  initial begin                          // release each reset synchronously to its own clock
    #100;
    @(posedge hclk); hresetn <= 1;
    @(posedge pclk); presetn <= 1;
  end

  ahb_if ahb_vif (hclk, hresetn);
  apb_if apb_vif (pclk, presetn);

  // ---- DUT (ASSUMED module and port names; PPROT is not a bridge port) ----
  ahb_apb_bridge dut (
    .HCLK(hclk), .HRESETn(hresetn),
    .HSEL(ahb_vif.hsel), .HADDR(ahb_vif.haddr), .HTRANS(ahb_vif.htrans),
    .HWRITE(ahb_vif.hwrite), .HSIZE(ahb_vif.hsize), .HBURST(ahb_vif.hburst),
    .HWDATA(ahb_vif.hwdata), .HREADYOUT(ahb_vif.hreadyout),
    .HRESP(ahb_vif.hresp), .HRDATA(ahb_vif.hrdata),
    .PCLK(pclk), .PRESETn(presetn),
    .PADDR(apb_vif.paddr), .PSEL(apb_vif.psel), .PENABLE(apb_vif.penable),
    .PWRITE(apb_vif.pwrite), .PWDATA(apb_vif.pwdata), .PSTRB(apb_vif.pstrb),
    .PRDATA(apb_vif.prdata), .PREADY(apb_vif.pready), .PSLVERR(apb_vif.pslverr)
  );

  initial begin
    uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif", ahb_vif);
    uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb_vif);
    run_test();
  end
endmodule

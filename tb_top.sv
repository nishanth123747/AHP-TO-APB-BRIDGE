`timescale 1ns/1ps

// interfaces
`include "ahb_if.sv"
`include "apb_if.sv"

//  RTL files
`include "ahb.v"
`include "apb.v"
`include "apb_addr_decoder.v"
`include "cdc_handshake.v"
`include "time_out.v"
`include "ahb_to_apb_bridge.v"

// UVM package
`include "ahb2apb_pkg.sv"
module ahb2apb_top;
  import uvm_pkg::*;
  import ahb2apb_pkg::*;


  bit hclk = 0;
  bit pclk = 0;

  // HCLK = 100 MHz
  initial forever #5 hclk = ~hclk;

  // PCLK = 25 MHz
  initial forever #20 pclk = ~pclk;

  ahb_if ahb_vif(hclk);
  apb_if apb_vif(pclk);

  // Reset
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    ahb_vif.HRESETn = 0;
    apb_vif.PRESETn = 0;

    #100;
    @(posedge hclk);
    ahb_vif.HRESETn <= 1;

    @(posedge pclk);
    apb_vif.PRESETn <= 1;
  end

  // DUT
 bridge dut (

  // Clocks and resets
  .HCLK     (ahb_vif.HCLK),
  .HRESETn  (ahb_vif.HRESETn),
  .PCLK     (apb_vif.PCLK),
  .PRESETn  (apb_vif.PRESETn),

  // AHB inputs
  .HSEL     (ahb_vif.HSEL),
  .HADDR    (ahb_vif.HADDR),
  .HTRANS   (ahb_vif.HTRANS),
  .HWRITE   (ahb_vif.HWRITE),
  .HWDATA   (ahb_vif.HWDATA),
  .HSIZE    (ahb_vif.HSIZE),
  .HBURST   (ahb_vif.HBURST),

  // AHB outputs
  .HRDATA   (ahb_vif.HRDATA),
  .HREADYOUT(ahb_vif.HREADYOUT),
  .HRESP    (ahb_vif.HRESP),

  // APB outputs
  .PADDR    (apb_vif.PADDR),
  .PSEL     (apb_vif.PSEL),
  .PENABLE  (apb_vif.PENABLE),
  .PWRITE   (apb_vif.PWRITE),
  .PWDATA   (apb_vif.PWDATA),
  .PSTRB    (apb_vif.PSTRB),

  // APB inputs
  .PRDATA   (apb_vif.PRDATA),
  .PREADY   (apb_vif.PREADY),
  .PSLVERR  (apb_vif.PSLVERR)
);
  initial begin

    uvm_config_db#(virtual ahb_if)::set(
  null, "*", "ahb_vif", ahb_vif
);

uvm_config_db#(virtual apb_if)::set(
  null, "*", "apb_vif", apb_vif
);
   // run_test("ahb2apb_unmapped_addr_test");
 //  run_test("ahb2apb_regression_test");
    //run_test("ahb2apb_basic_write_test");
    run_test("read_size_test");
 //   run_test("pstrb_test");
  end
endmodule

package ahb2apb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
`uvm_analysis_imp_decl(_ahb)
`uvm_analysis_imp_decl(_apb)
  // AHB agent
  `include "ahb_seq_item.sv"
  `include "ahb_sequence.sv"
  `include "ahb_sqr.sv"
  `include "ahb_driver.sv"
  `include "ahb_monitor.sv"
  `include "ahb_master_agent.sv"

  // APB agent
  `include "apb_seq_item.sv"
  `include "apb_sequence.sv"
  `include "apb_sqr.sv"
  `include "apb_driver.sv"
  `include "apb_monitor.sv"
  `include "apb_slave_agent.sv"

  // Environment
  `include "ahb2apb_virtual_sequencer.sv"
  `include "ahb2apb_virtual_sequence.sv"
  `include "ahb2apb_subscriber.sv"
  `include "ahb2apb_scoreboard.sv"
  `include "ahb2apb_env.sv"

  // Test
  `include "ahb2apb_test.sv"

endpackage

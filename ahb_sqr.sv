class ahb_sqr extends uvm_sequencer #(ahb_seq_item);
  `uvm_component_utils(ahb_sqr)
  function new(string name = "ahb_sqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

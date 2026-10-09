class apb_sqr extends uvm_sequencer #(apb_seq_item);
  `uvm_component_utils(apb_sqr)
  function new(string name = "apb_sqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass

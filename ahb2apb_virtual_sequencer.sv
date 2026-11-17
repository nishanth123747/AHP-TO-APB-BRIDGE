class ahb2apb_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

  `uvm_component_utils(ahb2apb_virtual_sequencer)

  // Handles to the agent sequencers
  ahb_sqr ahb_seqr;
  apb_sqr apb_seqr;

  function new(string name = "ahb2apb_virtual_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

class ahb2apb_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(ahb2apb_virtual_sequencer)

  ahb_sqr ahb_seqr;
  apb_sqr apb_seqr;

  virtual ahb_if ahb_vif;
  virtual apb_if apb_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
      `uvm_fatal("VIF", "AHB interface not found")

    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
      `uvm_fatal("VIF", "APB interface not found")

  endfunction

endclass

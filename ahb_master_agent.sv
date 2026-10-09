class ahb_master_agent extends uvm_agent;
  `uvm_component_utils(ahb_master_agent)
  ahb_sqr     sqr;
  ahb_driver  drv;
  ahb_monitor mon;

  function new(string name = "ahb_master_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = ahb_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = ahb_sqr::type_id::create("sqr", this);
      drv = ahb_driver::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass

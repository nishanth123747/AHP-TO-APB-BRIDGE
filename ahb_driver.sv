// One transfer at a time (not pipelined). TODO: overlap the next address phase with the
// current data phase for the two-stage pipelining tests.
class ahb_driver extends uvm_driver #(ahb_seq_item);
  `uvm_component_utils(ahb_driver)
  virtual ahb_if vif;

  function new(string name = "ahb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", vif))
      `uvm_fatal("AHB_DRV", "ahb_vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    idle_bus();
    if (vif.hresetn !== 1'b1) @(posedge vif.hresetn);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task idle_bus();
    vif.drv_cb.hsel   <= 0;
    vif.drv_cb.htrans <= 2'b00;
    vif.drv_cb.haddr  <= '0;
    vif.drv_cb.hwrite <= 0;
    vif.drv_cb.hsize  <= '0;
    vif.drv_cb.hburst <= '0;
    vif.drv_cb.hwdata <= '0;
  endtask

  task drive(ahb_seq_item t);
    repeat (t.idle_cycles + 1) @(vif.drv_cb);
    // address phase (held until HREADYOUT is high)
    vif.drv_cb.hsel   <= 1;
    vif.drv_cb.haddr  <= t.haddr;
    vif.drv_cb.htrans <= t.htrans;
    vif.drv_cb.hwrite <= t.hwrite;
    vif.drv_cb.hsize  <= t.hsize;
    vif.drv_cb.hburst <= t.hburst;
    do @(vif.drv_cb); while (!vif.drv_cb.hreadyout);
    // data phase
    vif.drv_cb.hsel   <= 0;
    vif.drv_cb.htrans <= 2'b00;
    if (t.hwrite) vif.drv_cb.hwdata <= t.hwdata;
    do @(vif.drv_cb); while (!vif.drv_cb.hreadyout);
    t.hresp  = vif.drv_cb.hresp;
    t.hrdata = vif.drv_cb.hrdata;
    // TODO: on ERROR the master should cancel any next address in the first error cycle
  endtask
endclass

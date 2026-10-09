// Joins each accepted address phase with its data phase and publishes one item per transfer.
class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)
  virtual ahb_if vif;
  uvm_analysis_port #(ahb_seq_item) ap;

  function new(string name = "ahb_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", vif))
      `uvm_fatal("AHB_MON", "ahb_vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    ahb_seq_item cur = null;
    forever begin
      @(vif.mon_cb);
      if (!vif.hresetn) begin cur = null; continue; end
      // data phase of the previous transfer ends when HREADYOUT is high
      if (cur != null && vif.mon_cb.hreadyout) begin
        cur.hresp = vif.mon_cb.hresp;
        if (cur.hwrite) cur.hwdata = vif.mon_cb.hwdata;
        else            cur.hrdata = vif.mon_cb.hrdata;
        ap.write(cur);
        cur = null;
      end
      // a new address phase is accepted: HSEL, HTRANS[1] and HREADYOUT high
      if (vif.mon_cb.hsel && vif.mon_cb.htrans[1] && vif.mon_cb.hreadyout) begin
        cur = ahb_seq_item::type_id::create("ahb_mon_item");
        cur.haddr  = vif.mon_cb.haddr;
        cur.hwrite = vif.mon_cb.hwrite;
        cur.hsize  = vif.mon_cb.hsize;
        cur.htrans = vif.mon_cb.htrans;
        cur.hburst = vif.mon_cb.hburst;
      end
    end
  endtask
endclass

// Publishes one item per APB transfer: at PREADY in ACCESS, or when the DUT drops the
// transfer without PREADY (aborted = 1, the timeout case).
class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  virtual apb_if vif;
  uvm_analysis_port #(apb_seq_item) ap;

  function new(string name = "apb_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
      `uvm_fatal("APB_MON", "apb_vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item cur = null;
    int unsigned waited = 0;
    forever begin
      @(vif.mon_cb);
      if (!vif.presetn) begin cur = null; waited = 0; continue; end
      if ((|vif.mon_cb.psel) && vif.mon_cb.penable) begin            // ACCESS
        if (cur == null) begin
          cur = apb_seq_item::type_id::create("apb_mon_item");
          cur.paddr = vif.mon_cb.paddr;   cur.psel   = vif.mon_cb.psel;
          cur.pwrite = vif.mon_cb.pwrite; cur.pwdata = vif.mon_cb.pwdata;
          cur.pstrb = vif.mon_cb.pstrb;
        end
        if (vif.mon_cb.pready) begin
          cur.prdata = vif.mon_cb.prdata; cur.pslverr = vif.mon_cb.pslverr;
          cur.waited = waited;
          ap.write(cur); cur = null; waited = 0;
        end else waited++;
      end else if (cur != null) begin                                 // dropped without PREADY
        cur.aborted = 1; cur.waited = waited;
        ap.write(cur); cur = null; waited = 0;
      end
    end
  endtask
endclass

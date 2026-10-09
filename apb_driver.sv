// Reactive slave driver: the DUT starts every transfer; this driver only answers.
class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)
  virtual apb_if vif;
  apb_seq_item   dflt;                 // used when no item is ready (zero wait, no error)
  bit [31:0]     mem [bit [31:0]];     // slave memory
  bit [31:0]     mem_default = 32'h0;

  function new(string name = "apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dflt = apb_seq_item::type_id::create("dflt");
    dflt.wait_cycles = 0; dflt.error = 0; dflt.hang = 0; dflt.use_rdata = 0;
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
      `uvm_fatal("APB_DRV", "apb_vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    drive_idle();
    forever begin
      @(vif.slv_cb);
      if (!vif.presetn) begin drive_idle(); continue; end
      if ((|vif.slv_cb.psel) && !vif.slv_cb.penable) respond();   // SETUP seen
    end
  endtask

  task respond();
    apb_seq_item rsp;
    bit          got;
    bit [31:0]   a  = vif.slv_cb.paddr;
    bit          wr = vif.slv_cb.pwrite;
    bit [31:0]   wd = vif.slv_cb.pwdata;
    bit [3:0]    st = vif.slv_cb.pstrb;

    seq_item_port.try_next_item(rsp);
    got = (rsp != null);
    if (!got) rsp = dflt;

    if (rsp.hang) begin
      // hold PREADY low until the DUT drops PSEL (timeout) or reset
      while (!aborted()) @(vif.slv_cb);
      finish(got);
      return;
    end
    repeat (rsp.wait_cycles) begin
      @(vif.slv_cb);
      if (aborted()) begin finish(got); return; end
    end

    if (wr) begin
      if (!rsp.error) write_mem(a, wd, st);
      vif.slv_cb.prdata <= '0;
    end else begin
      vif.slv_cb.prdata <= rsp.use_rdata ? rsp.rdata : read_mem(a);
    end
    vif.slv_cb.pready  <= 1'b1;
    vif.slv_cb.pslverr <= rsp.error;
    @(vif.slv_cb);
    finish(got);
  endtask

  task finish(bit got);
    drive_idle();
    if (got) seq_item_port.item_done();
  endtask

  function bit aborted();
    return (!vif.presetn || (vif.slv_cb.psel == '0));
  endfunction

  task drive_idle();
    vif.slv_cb.pready  <= 1'b0;
    vif.slv_cb.pslverr <= 1'b0;
    vif.slv_cb.prdata  <= '0;
  endtask

  function void write_mem(bit [31:0] addr, bit [31:0] data, bit [3:0] strb);
    bit [31:0] k   = {addr[31:2], 2'b00};
    bit [31:0] cur = mem.exists(k) ? mem[k] : mem_default;
    for (int i = 0; i < 4; i++) if (strb[i]) cur[8*i +: 8] = data[8*i +: 8];
    mem[k] = cur;
  endfunction

  function bit [31:0] read_mem(bit [31:0] addr);
    bit [31:0] k = {addr[31:2], 2'b00};
    return mem.exists(k) ? mem[k] : mem_default;
  endfunction
endclass

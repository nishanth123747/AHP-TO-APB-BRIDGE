// Coverage skeleton. Expand the covergroups to match the coverage plan sheet.
class ahb2apb_subscriber extends uvm_component;
  `uvm_component_utils(ahb2apb_subscriber)
  uvm_analysis_imp_ahb #(ahb_seq_item, ahb2apb_subscriber) ahb_imp;
  uvm_analysis_imp_apb #(apb_seq_item, ahb2apb_subscriber) apb_imp;
  ahb_seq_item a;
  apb_seq_item p;

  covergroup cg_ahb;
    cp_write:    coverpoint a.hwrite;
    cp_size:     coverpoint a.hsize { bins byte_s = {0}; bins half = {1}; bins word = {2}; bins oversized = default; }
    cp_region:   coverpoint a.haddr[22:20] iff (a.haddr < 32'h0080_0000);
    cp_unmapped: coverpoint (a.haddr >= 32'h0080_0000);
    cp_resp:     coverpoint a.hresp;
    x_write_size: cross cp_write, cp_size;
  endgroup

  covergroup cg_apb;
    cp_write: coverpoint p.pwrite;
    cp_wait:  coverpoint p.waited { bins zero = {0}; bins few = {[1:3]}; bins many = {[4:8]}; bins long_w = {[9:$]}; }
    cp_err:   coverpoint p.pslverr;
    cp_abort: coverpoint p.aborted;
    cp_strb:  coverpoint p.pstrb iff (p.pwrite) { bins legal[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000, 4'b0011, 4'b1100, 4'b1111}; }
    x_write_wait: cross cp_write, cp_wait;
    x_write_err:  cross cp_write, cp_err;
  endgroup

  function new(string name = "ahb2apb_subscriber", uvm_component parent = null);
    super.new(name, parent);
    cg_ahb = new();
    cg_apb = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_imp = new("ahb_imp", this);
    apb_imp = new("apb_imp", this);
  endfunction

  function void write_ahb(ahb_seq_item t); a = t; cg_ahb.sample(); endfunction
  function void write_apb(apb_seq_item t); p = t; cg_apb.sample(); endfunction
endclass

// Compares each mapped AHB transfer with the APB transfer it should produce.
// Assumes one outstanding transfer, so AHB and APB items match in order.
class ahb2apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ahb2apb_scoreboard)
  uvm_analysis_imp_ahb #(ahb_seq_item, ahb2apb_scoreboard) ahb_imp;
  uvm_analysis_imp_apb #(apb_seq_item, ahb2apb_scoreboard) apb_imp;
  ahb_seq_item ahb_q[$];
  apb_seq_item apb_q[$];
  int unsigned n_pass, n_fail;

  function new(string name = "ahb2apb_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_imp = new("ahb_imp", this);
    apb_imp = new("apb_imp", this);
  endfunction

  function void write_ahb(ahb_seq_item t);
    if (t.haddr >= 32'h0080_0000) begin          // unmapped: no APB access, AHB must ERROR
      if (t.hresp !== 1'b1) fail($sformatf("unmapped 0x%0h did not return ERROR", t.haddr));
      else n_pass++;
    end else begin
      ahb_q.push_back(t);
      compare();
    end
  endfunction

  function void write_apb(apb_seq_item t);
    apb_q.push_back(t);
    compare();
  endfunction

  function bit [3:0] exp_pstrb(bit [31:0] addr, bit [2:0] size);
    case (size)
      3'd0:    return 4'b0001 << addr[1:0];
      3'd1:    return 4'b0011 << addr[1:0];
      default: return 4'b1111;
    endcase
  endfunction

  function void compare();
    ahb_seq_item a; apb_seq_item p; bit exp_err;
    while (ahb_q.size() > 0 && apb_q.size() > 0) begin
      a = ahb_q.pop_front();  p = apb_q.pop_front();
      exp_err = p.pslverr | p.aborted;           // PSLVERR or timeout -> AHB ERROR
      if (p.paddr  !== a.haddr)  fail($sformatf("PADDR 0x%0h != HADDR 0x%0h", p.paddr, a.haddr));
      if (p.psel   !== (8'b1 << a.haddr[22:20])) fail($sformatf("PSEL %b wrong for HADDR 0x%0h", p.psel, a.haddr));
      if (p.pwrite !== a.hwrite) fail("PWRITE != HWRITE");
      if (a.hwrite) begin
        if (p.pwdata !== a.hwdata) fail($sformatf("PWDATA 0x%0h != HWDATA 0x%0h", p.pwdata, a.hwdata));
        if (p.pstrb  !== exp_pstrb(a.haddr, a.hsize)) fail($sformatf("PSTRB %b wrong (size %0d, addr 0x%0h)", p.pstrb, a.hsize, a.haddr));
      end else begin
        if (p.pstrb !== 4'b0) fail("PSTRB not 0 on read");
        if (!exp_err && a.hrdata !== p.prdata) fail($sformatf("HRDATA 0x%0h != PRDATA 0x%0h", a.hrdata, p.prdata));
      end
      if (a.hresp !== exp_err) fail($sformatf("HRESP %0b, expected %0b", a.hresp, exp_err));
      n_pass++;
    end
  endfunction

  function void fail(string msg);
    n_fail++;
    `uvm_error("SCB", msg)
  endfunction

  function void report_phase(uvm_phase phase);
    if (ahb_q.size() || apb_q.size())
      `uvm_error("SCB", $sformatf("unmatched items at end: ahb=%0d apb=%0d", ahb_q.size(), apb_q.size()))
    `uvm_info("SCB", $sformatf("checks passed=%0d failed=%0d", n_pass, n_fail), UVM_LOW)
  endfunction
endclass

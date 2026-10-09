// Response sequence. Run it in the background (fork ... join_none) so the driver always
// has the next item ready. count = 0 means run forever.
class apb_sequence extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_sequence)
  int unsigned count    = 0;
  int unsigned wait_min = 0;
  int unsigned wait_max = 3;
  int unsigned err_pct  = 0;
  bit          hang     = 0;

  function new(string name = "apb_sequence");
    super.new(name);
  endfunction

  task body();
    int unsigned n = 0;
    while (count == 0 || n < count) begin
      req = apb_seq_item::type_id::create("rsp");
      start_item(req);
      if (!req.randomize() with { wait_cycles inside {[wait_min:wait_max]}; })
        `uvm_fatal("APB_SEQ", "randomize failed")
      req.error = ($urandom_range(99) < err_pct);
      req.hang  = hang;
      finish_item(req);
      n++;
    end
    // TODO: scenario sequences (zero wait, wait states, error, hang, timeout boundary)
  endtask
endclass

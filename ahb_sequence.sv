class ahb_sequence extends uvm_sequence #(ahb_seq_item);
  `uvm_object_utils(ahb_sequence)
  int unsigned num_items = 10;

  function new(string name = "ahb_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (num_items) begin
      req = ahb_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_fatal("AHB_SEQ", "randomize failed")
      finish_item(req);
    end
    // TODO: directed sequences (write then read same address, boundary addresses,
    //       unmapped address, back-to-back) as separate classes extending this one
  endtask
endclass

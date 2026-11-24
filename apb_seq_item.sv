class apb_sequence_item extends uvm_sequence_item;

  `uvm_object_utils(apb_sequence_item)

  // APB response configuration
  rand int unsigned wait_cycles;
  rand bit slave_error;
  rand bit hang;
  rand bit [31:0] read_data;

  // APB input signals
  bit PRESETn;
  bit [31:0] PADDR;
  bit [7:0] PSEL;
  bit PWRITE;
  bit [31:0] PWDATA;
  bit [3:0] PSTRB;
  bit PENABLE;

  // APB output signals
  bit [31:0] PRDATA;
  bit PREADY;
  bit PSLVERR;

  bit aborted;
  int unsigned waited;

  function new(string name = "apb_sequence_item");
    super.new(name);
  endfunction

endclass

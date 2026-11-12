class apb_sequence_item extends uvm_sequence_item;

  `uvm_object_utils(apb_sequence_item)

  // driver configuration fields
  rand int unsigned wait_cycles;
  rand bit          slave_error;
  rand bit          hang;
  rand bit          use_read_data;
  rand bit [31:0]   read_data;

 
  // APB  signals 

  bit PRESETn;
  bit [31:0] PADDR;
  bit [7:0]  PSEL;
  bit        PWRITE;
  bit [31:0] PWDATA;
  bit [3:0]  PSTRB;
  bit        PENABLE;

  bit [31:0] PRDATA;
  bit        PREADY;
  bit        PSLVERR;

  // Optional status / debug fields
  bit          aborted;
  int unsigned waited;

  function new(string name = "apb_sequence_item");
    super.new(name);
  endfunction

endclass

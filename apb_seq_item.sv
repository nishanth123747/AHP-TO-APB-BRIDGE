// Used two ways: sequences fill the RESPONSE fields; the monitor fills the OBSERVED fields.
class apb_seq_item extends uvm_sequence_item;
  // response (what the slave should do)
  rand int unsigned wait_cycles;   // PREADY-low ACCESS cycles
  rand bit          error;         // return PSLVERR
  rand bit          hang;          // never assert PREADY (timeout test)
  rand bit          use_rdata;     // 1 = drive rdata, 0 = read from the driver memory
  rand bit [31:0]   rdata;
  // observed (monitor)
  bit [31:0] paddr;  bit [7:0] psel;  bit pwrite;  bit [31:0] pwdata;  bit [3:0] pstrb;
  bit [31:0] prdata; bit pslverr;     bit aborted; int unsigned waited;

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(wait_cycles, UVM_ALL_ON)
    `uvm_field_int(error,       UVM_ALL_ON)
    `uvm_field_int(hang,        UVM_ALL_ON)
    `uvm_field_int(paddr,       UVM_ALL_ON)
    `uvm_field_int(pwrite,      UVM_ALL_ON)
    `uvm_field_int(pwdata,      UVM_ALL_ON)
    `uvm_field_int(pstrb,       UVM_ALL_ON)
    `uvm_field_int(prdata,      UVM_ALL_ON)
    `uvm_field_int(pslverr,     UVM_ALL_ON)
  `uvm_object_utils_end

  constraint c_wait { soft wait_cycles inside {[0:3]}; }
  constraint c_def  { soft error == 0; soft hang == 0; soft use_rdata == 0; }

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction
endclass

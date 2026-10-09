class ahb_seq_item extends uvm_sequence_item;
  rand bit [31:0]   haddr;
  rand bit          hwrite;
  rand bit [2:0]    hsize;
  rand bit [31:0]   hwdata;
  rand int unsigned idle_cycles;
  bit [1:0]         htrans = 2'b10;   // NONSEQ
  bit [2:0]         hburst = 3'b000;  // SINGLE
  // response: filled in by the driver / monitor
  bit               hresp;
  bit [31:0]        hrdata;

  `uvm_object_utils_begin(ahb_seq_item)
    `uvm_field_int(haddr,  UVM_ALL_ON)
    `uvm_field_int(hwrite, UVM_ALL_ON)
    `uvm_field_int(hsize,  UVM_ALL_ON)
    `uvm_field_int(hwdata, UVM_ALL_ON)
    `uvm_field_int(hresp,  UVM_ALL_ON)
    `uvm_field_int(hrdata, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint c_size   { hsize inside {3'd0, 3'd1, 3'd2}; }
  constraint c_align  { (haddr & ((32'd1 << hsize) - 1)) == 32'd0; }      // misaligned not supported
  constraint c_mapped { soft haddr < 32'h0080_0000; }                      // override to hit unmapped
  constraint c_idle   { idle_cycles inside {[0:3]}; }

  function new(string name = "ahb_seq_item");
    super.new(name);
  endfunction
endclass

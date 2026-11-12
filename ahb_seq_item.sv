class ahb_sequence_item extends uvm_sequence_item;

  `uvm_object_utils(ahb_sequence_item)

  rand bit HSEL;
  rand bit [31:0] HADDR;
  rand bit [1:0]  HTRANS;
  rand bit  HWRITE;
  rand bit [2:0]  HSIZE;
  rand bit [2:0]  HBURST;
  rand bit [31:0] HWDATA;
  bit [31:0] HRDATA;
  bit  HRESP;
bit HREADYOUT;
  bit HRESETn;


  function new(string name = "ahb_sequence_item");
    super.new(name);
  endfunction

endclass

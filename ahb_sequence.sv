
`ifndef AHB_SEQUENCES_SV
`define AHB_SEQUENCES_SV

//============================================================
// AHB BASE SEQUENCE
//============================================================
class ahb_base_seq extends uvm_sequence #(ahb_sequence_item);

  `uvm_object_utils(ahb_base_seq)

  localparam bit [1:0] IDLE   = 2'b00;
  localparam bit [1:0] BUSY   = 2'b01;
  localparam bit [1:0] NONSEQ = 2'b10;
  localparam bit [1:0] SEQ    = 2'b11;

  function new(string name = "ahb_base_seq");
    super.new(name);
  endfunction

  // Generic AHB transfer
  task send_transfer(
    input bit [31:0] addr,
    input bit        write,
    input bit [31:0] wdata = 32'h0,
    input bit [2:0]  size  = 3'b010,
    input bit [1:0]  trans = NONSEQ
  );

    ahb_sequence_item req;

    req = ahb_sequence_item::type_id::create("req");

    start_item(req);

    req.HSEL   = 1'b1;
    req.HADDR  = addr;
    req.HTRANS = trans;
    req.HWRITE = write;
    req.HWDATA = wdata;
    req.HSIZE  = size;
    req.HBURST = 3'b000;

    finish_item(req);

  endtask

  // Write transfer
  task send_write(
    input bit [31:0] addr,
    input bit [31:0] data,
    input bit [2:0]  size  = 3'b010,
    input bit [1:0]  trans = NONSEQ
  );

    send_transfer(addr, 1'b1, data, size, trans);

  endtask

  // Read transfer
  task send_read(
    input bit [31:0] addr,
    input bit [2:0]  size  = 3'b010,
    input bit [1:0]  trans = NONSEQ
  );

    send_transfer(addr, 1'b0, 32'h0, size, trans);

  endtask

  // IDLE transfer
  task send_idle();
    send_transfer(32'h0, 1'b0, 32'h0, 3'b010, IDLE);
  endtask

  // BUSY transfer
  task send_busy();
    send_transfer(32'h0, 1'b0, 32'h0, 3'b010, BUSY);
  endtask

endclass


//============================================================
// 1. BASIC WRITE
//============================================================
class ahb2apb_basic_write_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_basic_write_seq)

  function new(string name="ahb2apb_basic_write_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("AHB_SEQ", "Starting basic write test", UVM_LOW)

    send_write(32'h0000_0100, 32'h1234_ABCD);

    `uvm_info("AHB_SEQ", "Basic write test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 2. BASIC READ
//============================================================
class ahb2apb_basic_read_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_basic_read_seq)

  function new(string name="ahb2apb_basic_read_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("AHB_SEQ", "Starting basic read test", UVM_LOW)

    send_read(32'h0000_0100);

    `uvm_info("AHB_SEQ", "Basic read test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 3. APB WAIT-STATE TEST
//============================================================
class ahb_wait_states_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_wait_states_seq)

  function new(string name="ahb_wait_states_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("AHB_SEQ", "Starting APB wait-state test", UVM_LOW)

    // Zero wait states
    send_write(32'h0000_0100, 32'h1111_1111);

    // One wait state
    send_write(32'h0000_0104, 32'h2222_2222);

    // Two wait states
    send_write(32'h0000_0108, 32'h3333_3333);

    // Five wait states
    send_write(32'h0000_010C, 32'h4444_4444);

    `uvm_info("AHB_SEQ", "APB wait-state test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 4. APB ERROR-RESPONSE TEST
//============================================================
class ahb2apb_apb_error_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_apb_error_seq)

  function new(string name="ahb2apb_apb_error_seq");
    super.new(name);
  endfunction

  task body();
    
    `uvm_info("AHB_SEQ", "Starting APB error-response test", UVM_LOW)
     
    // Write transaction with APB error
    send_write(32'h0000_0110, 32'hAAAA_1111);

    // Read transaction with APB error
    send_read(32'h0000_0114);

    `uvm_info("AHB_SEQ", "APB error-response test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 5. BACK-TO-BACK TRANSFER TEST
//============================================================
class ahb2apb_back_to_back_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_back_to_back_seq)

  function new(string name = "ahb2apb_back_to_back_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("AHB_SEQ",
      "Starting back-to-back transfer test", UVM_LOW)

    // Consecutive WRITE transfers
    send_write(32'h0000_0100, 32'h1111_1111);
      send_read(32'h0000_0110);
//     send_write(32'h0000_0104, 32'h2222_2222);
//     send_write(32'h0000_0108, 32'h3333_3333);

//     // Consecutive READ transfers
//     send_read(32'h0000_0110);
//     send_read(32'h0000_0114);

//     // WRITE followed by READ
//     send_write(32'h0000_0118, 32'hAAAA_5555);
//     send_read(32'h0000_011C);

    `uvm_info("AHB_SEQ",
      "Back-to-back transfer test completed", UVM_LOW)

  endtask

endclass


class ahb2apb_htrans_test_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_htrans_test_seq)

  function new(string name = "ahb2apb_htrans_test_seq");
    super.new(name);
  endfunction

  task body();

    // IDLE - should not generate APB access
    send_transfer(
      32'h0000_0100, 1'b1, 32'h1111_1111,
      3'b010, 2'b00
    );

    // BUSY - should not generate APB access
    send_transfer(
      32'h0000_0104, 1'b1, 32'h2222_2222,
      3'b010, 2'b01
    );

    // NONSEQ - valid transfer
    send_transfer(
      32'h0000_0108, 1'b1, 32'h3333_3333,
      3'b010, 2'b10
    );

    // SEQ - valid transfer
    send_transfer(
      32'h0000_010C, 1'b1, 32'h4444_4444,
      3'b010, 2'b11
    );

  endtask
  
endclass

class ahb2apb_all_slave_decode_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_all_slave_decode_seq)

  function new(string name = "ahb2apb_all_slave_decode_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("AHB_SEQ", "Starting APB address decoding test", UVM_LOW)

    send_write(32'h0000_0100, 32'h1111_1111);
    send_write(32'h0010_0100, 32'h2222_2222);
    send_write(32'h0020_0100, 32'h3333_3333);
    send_write(32'h0030_0100, 32'h4444_4444);
    send_write(32'h0040_0100, 32'h5555_5555);
    send_write(32'h0050_0100, 32'h6666_6666);
    send_write(32'h0060_0100, 32'h7777_7777);
    send_write(32'h0070_0100, 32'h8888_8888);

    `uvm_info("AHB_SEQ", "APB address decoding sequence completed", UVM_LOW)

  endtask

endclass

class ahb2apb_timeout_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_timeout_seq)

  function new(string name = "ahb2apb_timeout_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("AHB_SEQ", "Starting timeout test", UVM_LOW)

    // This transfer should timeout.
    send_write(32'h0000_0100, 32'hAAAA_5555);

    // This transfer checks recovery.
    send_write(32'h0000_0104, 32'hBBBB_6666);

    `uvm_info("AHB_SEQ", "Timeout test completed", UVM_LOW)

  endtask

endclass
class ahb2apb_unmapped_addr_seq extends ahb_base_seq;

  `uvm_object_utils(ahb2apb_unmapped_addr_seq)

  function new(string name = "ahb2apb_unmapped_addr_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "Starting Unmapped Address Test", UVM_LOW)

    // Unmapped address 1
    send_write(32'h0080_0100, 32'hAAAA_1111);

    // Unmapped address 2
    send_write(32'h0090_0100, 32'hBBBB_2222);

    // Unmapped address 3
    send_read(32'h00A0_0100);

    // Unmapped address 4
    send_read(32'h0100_0000);

    `uvm_info(get_type_name(), "Unmapped Address Test Completed", UVM_LOW)

  endtask

endclass


class ahb_pstrb_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_pstrb_seq)

  function new(string name = "ahb_pstrb_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(), "PSTRB SEQUENCE STARTED", UVM_LOW)

    // --------------------------------
    // BYTE TRANSFERS
    // --------------------------------

    // Byte at offset 0
    send_transfer(32'h00000100, 1'b1, 32'h11111111, 3'b000);

    // Byte at offset 1
    send_transfer(32'h00000101, 1'b1, 32'h22222222, 3'b000);

    // Byte at offset 2
    send_transfer(32'h00000102, 1'b1, 32'h33333333, 3'b000);

    // Byte at offset 3
    send_transfer(32'h00000103, 1'b1, 32'h44444444, 3'b000);


    // --------------------------------
    // HALFWORD TRANSFERS
    // --------------------------------

    // Halfword at offset 0
    send_transfer(32'h00000100, 1'b1, 32'h55555555, 3'b001);

    // Halfword at offset 2
    send_transfer(32'h00000102, 1'b1, 32'h66666666, 3'b001);


    // --------------------------------
    // WORD TRANSFER
    // --------------------------------

    // Word at offset 0
    send_transfer(32'h00000100, 1'b1, 32'h77777777, 3'b010);


    // --------------------------------
    // INVALID ALIGNMENTS
    // --------------------------------

    // Halfword at offset 1
    send_transfer(32'h00000101, 1'b1, 32'h88888888, 3'b001);

    // Halfword at offset 3
    send_transfer(32'h00000103, 1'b1, 32'h99999999, 3'b001);

    // Word at offset 1
    send_transfer(32'h00000101, 1'b1, 32'hAAAAAAAA, 3'b010);

    // Word at offset 2
    send_transfer(32'h00000102, 1'b1, 32'hBBBBBBBB, 3'b010);

    // Word at offset 3
    send_transfer(32'h00000103, 1'b1, 32'hCCCCCCCC, 3'b010);


    // --------------------------------
    // OVERSIZED TRANSFERS
    // --------------------------------

    // --------------------------------
// OVERSIZED TRANSFERS
// --------------------------------

// HSIZE = 3'b011 : 8 bytes
send_transfer(32'h00000100, 1'b1, 32'hDDDDDDDD, 3'b011);

// HSIZE = 3'b100 : 16 bytes
send_transfer(32'h00000100, 1'b1, 32'hEEEEEEEE, 3'b100);

// HSIZE = 3'b101 : 32 bytes
send_transfer(32'h00000100, 1'b1, 32'hAAAAAAAA, 3'b101);

// HSIZE = 3'b110 : 64 bytes
send_transfer(32'h00000100, 1'b1, 32'hBBBBBBBB, 3'b110);

// HSIZE = 3'b111 : 128 bytes
send_transfer(32'h00000100, 1'b1, 32'hFFFFFFFF, 3'b111);


    `uvm_info(get_type_name(), "PSTRB SEQUENCE COMPLETED", UVM_LOW)

  endtask

endclass

 
class ahb_read_size_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_read_size_seq)

  function new(string name = "ahb_read_size_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "READ SIZE SEQUENCE STARTED", UVM_LOW)

    for (int i = 0; i < 8; i++) begin

      send_transfer(
        32'h00000100,  // Address
        1'b0,          // Read
        i[2:0],        // HSIZE
        32'h00000000   // Write data (unused)
      );

    end

    `uvm_info(get_type_name(),
              "READ SIZE SEQUENCE COMPLETED", UVM_LOW)

  endtask

endclass

class ahb_hsel_low_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_hsel_low_seq)

  function new(string name = "ahb_hsel_low_seq");
    super.new(name);
  endfunction

  task body();

    ahb_sequence_item req;

    `uvm_info(get_type_name(), "HSEL LOW TEST STARTED", UVM_LOW)

    req = ahb_sequence_item::type_id::create("req");

    start_item(req);

    req.HSEL   = 0;
    req.HTRANS = 2'b10;
    req.HWRITE = 1;
    req.HADDR  = 32'h0000_0100;
    req.HSIZE  = 3'b010;
    req.HBURST = 3'b000;
    req.HWDATA = 32'h1234_5678;

    finish_item(req);

    `uvm_info(get_type_name(), "HSEL LOW TEST COMPLETED", UVM_LOW)

  endtask

endclass

class ahb_hreadyout_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_hreadyout_seq)

  function new(string name = "ahb_hreadyout_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "HREADYOUT TEST STARTED", UVM_LOW)

    // APB response will be delayed by 5 cycles
    send_write(32'h0000_0100, 32'hAAAA_1111);

    `uvm_info(get_type_name(),
              "HREADYOUT TEST COMPLETED", UVM_LOW)

  endtask

endclass

class ahb_control_stability_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_control_stability_seq)

  function new(string name = "ahb_control_stability_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "AHB CONTROL STABILITY TEST STARTED", UVM_LOW)

    // First transfer creates APB activity
    send_write(32'h0000_0100, 32'hAAAA_1111);

    // Second transfer
    send_write(32'h0000_0200, 32'hBBBB_2222);

    `uvm_info(get_type_name(),
              "AHB CONTROL STABILITY TEST COMPLETED", UVM_LOW)

  endtask

endclass

class ahb_apb_phase_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_apb_phase_seq)

  function new(string name = "ahb_apb_phase_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_PHASE", "Starting APB phase test", UVM_LOW)

    // IDLE phase
    repeat (3)
      send_idle();

    // WRITE transaction: SETUP and ACCESS
    send_write(32'h0000_0000, 32'hABCD_1234);

    // READ transaction: SETUP and ACCESS
    send_read(32'h0000_0004);

    // Return to IDLE
    repeat (3)
      send_idle();

    `uvm_info("APB_PHASE", "Completed APB phase test", UVM_LOW)

  endtask

endclass

class ahb_data_integrity_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_data_integrity_seq)

  function new(string name = "ahb_data_integrity_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "Starting AHB data integrity test", UVM_MEDIUM)

    // Write transactions
    send_write(32'h00000000, 32'h00000000);
    send_write(32'h00000004, 32'hFFFFFFFF);
    send_write(32'h00000008, 32'hAAAAAAAA);
    send_write(32'h0000000C, 32'h55555555);
    send_write(32'h00000010, 32'h12345678);
    send_write(32'h00000014, 32'h87654321);
    send_write(32'h00000018, 32'hDEADBEEF);
    send_write(32'h0000001C, 32'hCAFEBABE);

    // Read transactions
    send_read(32'h00000000);
    send_read(32'h00000004);
    send_read(32'h00000008);
    send_read(32'h0000000C);
    send_read(32'h00000010);
    send_read(32'h00000014);
    send_read(32'h00000018);
    send_read(32'h0000001C);

    `uvm_info(get_type_name(),
              "Completed AHB data integrity test", UVM_MEDIUM)

  endtask

endclass


class ahb_control_change_wait_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_control_change_wait_seq)

  function new(string name = "ahb_control_change_wait_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "CONTROL CHANGE DURING WAIT SEQUENCE STARTED",
              UVM_LOW)

    // Send one AHB write transaction.
    // APB will introduce 5 wait cycles.
    send_transfer(
      32'h00000100,  // HADDR
      1'b1,          // HWRITE
      32'hABCD1234,  // HWDATA
      3'b010,        // HSIZE = WORD
      2'b10          // HTRANS = NONSEQ
    );

    `uvm_info(get_type_name(),
              "AHB WRITE TRANSACTION COMPLETED",
              UVM_LOW)

  endtask

endclass


class ahb_reset_sequence extends uvm_sequence #(ahb_sequence_item);

  `uvm_object_utils(ahb_reset_sequence)

  function new(string name = "ahb_reset_sequence");
    super.new(name);
  endfunction

  task body();
    ahb_sequence_item req;

    req = ahb_sequence_item::type_id::create("req");

    start_item(req);
    req.HSEL   = 1'b1;
    req.HTRANS = 2'b10; // NONSEQ
    req.HWRITE = 1'b1;
    req.HADDR  = 32'h0000_0100;
    req.HSIZE  = 3'b010;
    req.HBURST = 3'b000;
    req.HWDATA = 32'h1234_5678;
    finish_item(req);

  endtask

endclass


class ahb_hreadyout_timing_seq extends ahb_base_seq;

  `uvm_object_utils(ahb_hreadyout_timing_seq)

  function new(string name = "ahb_hreadyout_timing_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "HREADYOUT TIMING TEST STARTED", UVM_LOW)

    // Send one AHB write transaction
    send_transfer(
      32'h00000100,  // HADDR
      1'b1,          // HWRITE
      32'hABCD1234,  // HWDATA
      3'b010,        // HSIZE = WORD
      2'b10          // HTRANS = NONSEQ
    );

    `uvm_info(get_type_name(),
              "HREADYOUT TIMING TEST COMPLETED", UVM_LOW)

  endtask

endclass

`endif


`ifndef APB_SEQUENCES_SV
`define APB_SEQUENCES_SV

//============================================================
// APB BASE SEQUENCE
//============================================================
class apb_base_seq extends uvm_sequence #(apb_sequence_item);

  `uvm_object_utils(apb_base_seq)

  function new(string name="apb_base_seq");
    super.new(name);
  endfunction

  // Configure APB slave response
  task send_config(
    input int unsigned delay_cycles,
    input bit          error_response,
    input bit          hang_response,
    input bit          custom_read,
    input bit [31:0]   custom_data
  );

    apb_sequence_item req;

    req = apb_sequence_item::type_id::create("req");

    start_item(req);

    req.wait_cycles   = delay_cycles;
    req.slave_error   = error_response;
    req.hang          = hang_response;
    req.use_read_data = custom_read;
    req.read_data     = custom_data;

    finish_item(req);

    `uvm_info("APB_SEQ",
      $sformatf(
        "Config: wait=%0d error=%0b hang=%0b custom_read=%0b data=%08h",
        delay_cycles,
        error_response,
        hang_response,
        custom_read,
        custom_data),
      UVM_MEDIUM)

  endtask

endclass


//============================================================
// 1. BASIC WRITE
//============================================================
class apb2apb_basic_write_seq extends apb_base_seq;

  `uvm_object_utils(apb2apb_basic_write_seq)

  function new(string name="apb2apb_basic_write_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting basic write response", UVM_LOW)

    send_config(0, 0, 0, 0, 32'h0);

    `uvm_info("APB_SEQ", "Basic write response completed", UVM_LOW)

  endtask

endclass


//============================================================
// 2. BASIC READ
//============================================================
class apb2apb_basic_read_seq extends apb_base_seq;

  `uvm_object_utils(apb2apb_basic_read_seq)

  function new(string name="apb2apb_basic_read_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting basic read response", UVM_LOW)

    send_config(0, 0, 0, 1, 32'h1234_ABCD);

    `uvm_info("APB_SEQ", "Basic read response completed", UVM_LOW)

  endtask

endclass


//============================================================
// 3. APB WAIT-STATE TEST
//============================================================
class apb_wait_states_seq extends apb_base_seq;

  `uvm_object_utils(apb_wait_states_seq)

  function new(string name="apb_wait_states_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting APB wait-state test", UVM_LOW)

    // Zero wait states
    send_config(0, 0, 0, 0, 32'h0);

    // One wait state
    send_config(1, 0, 0, 0, 32'h0);

    // Two wait states
    send_config(2, 0, 0, 0, 32'h0);

    // Five wait states
    send_config(5, 0, 0, 0, 32'h0);

    `uvm_info("APB_SEQ", "APB wait-state test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 4. APB ERROR-RESPONSE TEST
//============================================================
class apb_error_seq extends apb_base_seq;

  `uvm_object_utils(apb_error_seq)

  function new(string name="apb_error_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting APB error-response test", UVM_LOW)

    // Write transaction with APB error
    send_config(0, 1, 0, 0, 32'h0);

    // Read transaction with APB error and 2 wait states
    send_config(2, 1, 0, 0, 32'h0);

    `uvm_info("APB_SEQ", "APB error-response test completed", UVM_LOW)

  endtask

endclass

//============================================================
// BACK-TO-BACK APB CONFIGURATION SEQUENCE
//============================================================
class apb_back_to_back_seq extends apb_base_seq;


`uvm_object_utils(apb_back_to_back_seq)

function new(string name = "apb_back_to_back_seq");
super.new(name);
endfunction

task body();

`uvm_info("APB_SEQ",
"Starting back-to-back APB test", UVM_LOW)

// 3 WRITE configurations
send_config(0, 0, 0, 0, 0);
send_config(0, 0, 0, 0, 0);
send_config(0, 0, 0, 0, 0);

// 2 READ configurations
send_config(0, 0, 0, 1, 32'h1111_1111);
send_config(0, 0, 0, 1, 32'h2222_2222);

// WRITE followed by READ
send_config(0, 0, 0, 0, 0);
send_config(0, 0, 0, 1, 32'hAAAA_5555);

`uvm_info("APB_SEQ",
"Back-to-back APB test completed", UVM_LOW)

endtask

endclass

class apb_htrans_test_seq extends apb_base_seq;

  `uvm_object_utils(apb_htrans_test_seq)

  function new(string name = "apb_htrans_test_seq");
    super.new(name);
  endfunction

  task body();

    // NONSEQ response
    send_config(0, 0, 0, 0, 0);

    // SEQ response
    send_config(0, 0, 0, 0, 0);

  endtask

endclass

class apb_all_slave_decode_seq extends apb_base_seq;


`uvm_object_utils(apb_all_slave_decode_seq)

function new(string name = "apb_all_slave_decode_seq");
super.new(name);
endfunction

task body();

`uvm_info("APB_SEQ", "Starting APB address decoding responses", UVM_LOW)

// Slave 0 response
send_config(0, 0, 0, 0, 0);

// Slave 1 response
send_config(0, 0, 0, 0, 0);

// Slave 2 response
send_config(0, 0, 0, 0, 0);

// Slave 3 response
send_config(0, 0, 0, 0, 0);

// Slave 4 response
send_config(0, 0, 0, 0, 0);

// Slave 5 response
send_config(0, 0, 0, 0, 0);

// Slave 6 response
send_config(0, 0, 0, 0, 0);

// Slave 7 response
send_config(0, 0, 0, 0, 0);

`uvm_info("APB_SEQ", "APB address decoding responses completed", UVM_LOW)

endtask

endclass

class apb_timeout_seq extends apb_base_seq;

  `uvm_object_utils(apb_timeout_seq)

  function new(string name = "apb_timeout_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting APB timeout test", UVM_LOW)

    // First transfer: Never assert PREADY.
    // DUT timeout logic should terminate the transfer.
    send_config(0, 0, 1, 0, 0);

    // Second transfer: Normal response after timeout recovery.
    send_config(0, 0, 0, 0, 0);

    `uvm_info("APB_SEQ", "APB timeout test completed", UVM_LOW)

  endtask

endclass

class apb_pstrb_seq extends apb_base_seq;

  `uvm_object_utils(apb_pstrb_seq)

  function new(string name = "apb_pstrb_seq");
    super.new(name);
  endfunction

  task body();

    repeat (12) begin
      send_config(0, 0, 0, 0, 0);
    end

  endtask

endclass

class apb_read_size_seq extends apb_base_seq;

  `uvm_object_utils(apb_read_size_seq)

function new(string name = "apb_read_size_seq");
    super.new(name);
  endfunction

  task body();

`uvm_info(get_type_name(),
              "APB READ SIZE SEQUENCE STARTED", UVM_LOW)

    for (int i = 0; i < 8; i++) begin

send_config(
        0,                  // Wait cycles
        0,                  // Error response
        0,                  // Hang
        1,                  // Custom read data enabled
        32'hA5000000 + i    // Read data
      );

    end

`uvm_info(get_type_name(),
              "APB READ SIZE SEQUENCE COMPLETED", UVM_LOW)

  endtask

endclass
`endif

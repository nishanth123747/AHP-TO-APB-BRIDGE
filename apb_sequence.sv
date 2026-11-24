
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
    input bit [31:0]   custom_data
  );

    apb_sequence_item req;

    req = apb_sequence_item::type_id::create("req");

    start_item(req);

    req.wait_cycles = delay_cycles;
    req.slave_error = error_response;
    req.hang        = hang_response;
    req.read_data   = custom_data;

    finish_item(req);

    `uvm_info("APB_SEQ",
      $sformatf(
        "Config: wait=%0d error=%0b hang=%0b data=%08h",
        delay_cycles,
        error_response,
        hang_response,
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

    send_config(0, 0, 0, 32'h0);

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

    send_config(0, 0, 0, 32'h1234_ABCD);

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

    send_config(0, 0, 0, 32'h0);
    send_config(1, 0, 0, 32'h0);
    send_config(2, 0, 0, 32'h0);
    send_config(5, 0, 0, 32'h0);

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
    send_config(0, 1, 0, 32'h0);

    // Read transaction with APB error and 2 wait states
    send_config(2, 1, 0, 32'h0);

    `uvm_info("APB_SEQ", "APB error-response test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 5. BACK-TO-BACK APB CONFIGURATION SEQUENCE
//============================================================
class apb_back_to_back_seq extends apb_base_seq;

  `uvm_object_utils(apb_back_to_back_seq)

  function new(string name = "apb_back_to_back_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting back-to-back APB test", UVM_LOW)

    // 3 WRITE configurations
    send_config(0, 0, 0, 32'h0);
     send_config(0, 0, 0, 32'h1111_1111);
//     send_config(0, 0, 0, 32'h0);
//     send_config(0, 0, 0, 32'h0);

//     // 2 READ configurations
//     send_config(0, 0, 0, 32'h1111_1111);
//     send_config(0, 0, 0, 32'h2222_2222);

//     // WRITE followed by READ
//     send_config(0, 0, 0, 32'h0);
//     send_config(0, 0, 0, 32'hAAAA_5555);

    `uvm_info("APB_SEQ", "Back-to-back APB test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 6. AHB HTRANS TEST
//============================================================
class apb_htrans_test_seq extends apb_base_seq;

  `uvm_object_utils(apb_htrans_test_seq)

  function new(string name = "apb_htrans_test_seq");
    super.new(name);
  endfunction

  task body();

    // NONSEQ response
    send_config(0, 0, 0, 32'h0);

    // SEQ response
    send_config(0, 0, 0, 32'h0);

  endtask

endclass


//============================================================
// 7. ALL SLAVE DECODE TEST
//============================================================
class apb_all_slave_decode_seq extends apb_base_seq;

  `uvm_object_utils(apb_all_slave_decode_seq)

  function new(string name = "apb_all_slave_decode_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting APB address decoding responses", UVM_LOW)

    repeat (8)
      send_config(0, 0, 0, 32'h0);

    `uvm_info("APB_SEQ", "APB address decoding responses completed", UVM_LOW)

  endtask

endclass


//============================================================
// 8. APB TIMEOUT TEST
//============================================================
class apb_timeout_seq extends apb_base_seq;

  `uvm_object_utils(apb_timeout_seq)

  function new(string name = "apb_timeout_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_SEQ", "Starting APB timeout test", UVM_LOW)

    // First transfer: Never assert PREADY
    send_config(0, 0, 1, 32'h0);

    // Second transfer: Normal response after timeout recovery
    send_config(0, 0, 0, 32'h0);

    `uvm_info("APB_SEQ", "APB timeout test completed", UVM_LOW)

  endtask

endclass


//============================================================
// 9. APB PSTRB TEST
//============================================================
class apb_pstrb_seq extends apb_base_seq;

  `uvm_object_utils(apb_pstrb_seq)

  function new(string name = "apb_pstrb_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "APB PSTRB RESPONSE SEQUENCE STARTED", UVM_LOW)

    repeat (17) begin
      send_config(0, 0, 0, 32'h0);
    end

    `uvm_info(get_type_name(),
              "APB PSTRB RESPONSE SEQUENCE COMPLETED", UVM_LOW)

  endtask

endclass


//============================================================
// 10. APB READ SIZE TEST
//============================================================
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
        0,
        0,
        0,
        32'hA5000000 + i
      );

    end

    `uvm_info(get_type_name(),
              "APB READ SIZE SEQUENCE COMPLETED", UVM_LOW)

  endtask

endclass


//============================================================
// 11. AHB HREADYOUT TEST
//============================================================
class apb_hreadyout_seq extends uvm_sequence #(apb_sequence_item);

  `uvm_object_utils(apb_hreadyout_seq)

  function new(string name = "apb_hreadyout_seq");
    super.new(name);
  endfunction

  task body();

    apb_sequence_item req;

    `uvm_info(get_type_name(),
              "APB WAIT STATE SEQUENCE STARTED", UVM_LOW)

    req = apb_sequence_item::type_id::create("req");

    start_item(req);

    req.wait_cycles = 5;
    req.slave_error = 0;
    req.hang        = 0;
    req.read_data   = 32'h0;

    finish_item(req);

    `uvm_info(get_type_name(),
              "APB WAIT STATE CONFIGURATION SENT", UVM_LOW)

  endtask

endclass


//============================================================
// 12. AHB CONTROL STABILITY TEST
//============================================================
class apb_control_stability_seq extends uvm_sequence #(apb_sequence_item);

  `uvm_object_utils(apb_control_stability_seq)

  function new(string name = "apb_control_stability_seq");
    super.new(name);
  endfunction

  task body();

    apb_sequence_item req;

    req = apb_sequence_item::type_id::create("req");

    start_item(req);

    req.wait_cycles = 5;
    req.slave_error = 0;
    req.hang        = 0;
    req.read_data   = 32'h0;

    finish_item(req);

  endtask

endclass

class apb_phase_seq extends apb_base_seq;

  `uvm_object_utils(apb_phase_seq)

  function new(string name = "apb_phase_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_PHASE", "Starting APB response sequence", UVM_LOW)

    // Response for WRITE
    send_config(2, 0, 0, 32'h0);

    // Response for READ
    send_config(2, 0, 0, 32'h5678_ABCD);

    `uvm_info("APB_PHASE", "Completed APB response sequence", UVM_LOW)

  endtask

endclass

class apb_data_integrity_seq extends apb_base_seq;

  `uvm_object_utils(apb_data_integrity_seq)

  function new(string name = "apb_data_integrity_seq");
    super.new(name);
  endfunction

  task body();

    // Write responses
    send_config(0, 0, 0, 32'h00000000);

    // Read responses
    send_config(0, 0, 0, 32'h00000000);
    send_config(0, 0, 0, 32'hFFFFFFFF);
    send_config(0, 0, 0, 32'hAAAAAAAA);
    send_config(0, 0, 0, 32'h55555555);
    send_config(0, 0, 0, 32'h12345678);
    send_config(0, 0, 0, 32'h87654321);
    send_config(0, 0, 0, 32'hDEADBEEF);
    send_config(0, 0, 0, 32'hCAFEBABE);

  endtask

endclass

//============================================================
// 13. APB RESET SEQUENCE
//============================================================
class apb_reset_sequence extends uvm_sequence #(apb_sequence_item);

  `uvm_object_utils(apb_reset_sequence)

  bit [31:0] read_data;
  int wait_cycles;
  bit slave_error;
  bit hang;

  function new(string name = "apb_reset_sequence");
    super.new(name);
  endfunction

  task body();

    apb_sequence_item req;

    req = apb_sequence_item::type_id::create("req");

    start_item(req);

    req.wait_cycles = wait_cycles;
    req.slave_error = slave_error;
    req.hang        = hang;
    req.read_data   = read_data;

    finish_item(req);

  endtask

endclass

`endif


`ifndef AHB_APB_VIRTUAL_SEQUENCES_SV
`define AHB_APB_VIRTUAL_SEQUENCES_SV

//============================================================
// BASE VIRTUAL SEQUENCE
//============================================================
class ahb2apb_virtual_sequence extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(ahb2apb_virtual_sequence)
  `uvm_declare_p_sequencer(ahb2apb_virtual_sequencer)

  function new(string name = "ahb2apb_virtual_sequence");
    super.new(name);
  endfunction

endclass


//============================================================
// 1. BASIC WRITE VIRTUAL SEQUENCE
//============================================================
class ahb2apb_basic_write_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_basic_write_vseq)

  function new(string name="ahb2apb_basic_write_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_basic_write_seq ahb_seq;
    apb2apb_basic_write_seq apb_seq;

    ahb_seq = ahb2apb_basic_write_seq::type_id::create("ahb_seq");
    apb_seq = apb2apb_basic_write_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass


//============================================================
// 2. BASIC READ VIRTUAL SEQUENCE
//============================================================
class ahb2apb_basic_read_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_basic_read_vseq)

  function new(string name="ahb2apb_basic_read_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_basic_read_seq ahb_seq;
    apb2apb_basic_read_seq apb_seq;

    ahb_seq = ahb2apb_basic_read_seq::type_id::create("ahb_seq");
    apb_seq = apb2apb_basic_read_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass


//============================================================
// 3. WAIT-STATE VIRTUAL SEQUENCE
//============================================================
class ahb2apb_wait_states_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_wait_states_vseq)

  function new(string name="ahb2apb_wait_states_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_wait_states_seq ahb_seq;
    apb_wait_states_seq apb_seq;

    ahb_seq = ahb_wait_states_seq::type_id::create("ahb_seq");
    apb_seq = apb_wait_states_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass


//============================================================
// 4. APB ERROR VIRTUAL SEQUENCE
//============================================================
class ahb2apb_apb_error_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_apb_error_vseq)

  function new(string name="ahb2apb_apb_error_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_apb_error_seq ahb_seq;
    apb_error_seq apb_seq;

    ahb_seq = ahb2apb_apb_error_seq::type_id::create("ahb_seq");
    apb_seq = apb_error_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass


//============================================================
// BACK-TO-BACK VIRTUAL SEQUENCE
//============================================================
class ahb2apb_back_to_back_vseq
  extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_back_to_back_vseq)

  function new(string name = "ahb2apb_back_to_back_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_back_to_back_seq ahb_seq;
    apb_back_to_back_seq    apb_seq;

    ahb_seq = ahb2apb_back_to_back_seq::type_id::create("ahb_seq");
    apb_seq = apb_back_to_back_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass


class ahb2apb_htrans_test_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_htrans_test_vseq)

  function new(string name = "ahb2apb_htrans_test_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_htrans_test_seq ahb_seq;
    apb_htrans_test_seq apb_seq;

    ahb_seq = ahb2apb_htrans_test_seq::type_id::create("ahb_seq");
    apb_seq = apb_htrans_test_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass

class ahb2apb_all_slave_decode_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_all_slave_decode_vseq)

  function new(string name = "ahb2apb_all_slave_decode_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_all_slave_decode_seq ahb_seq;
    apb_all_slave_decode_seq apb_seq;

    ahb_seq = ahb2apb_all_slave_decode_seq::type_id::create("ahb_seq");

    apb_seq = apb_all_slave_decode_seq::type_id::create("apb_seq");

    `uvm_info("VSEQ", "Starting address decoding virtual sequence", UVM_LOW)

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

    `uvm_info("VSEQ", "Address decoding virtual sequence completed", UVM_LOW)

  endtask

endclass

class ahb2apb_timeout_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_timeout_vseq)

  function new(string name = "ahb2apb_timeout_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_timeout_seq ahb_seq;
    apb_timeout_seq apb_seq;

    ahb_seq = ahb2apb_timeout_seq::type_id::create("ahb_seq");
    apb_seq = apb_timeout_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass

class ahb2apb_unmapped_addr_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_unmapped_addr_vseq)

  function new(string name = "ahb2apb_unmapped_addr_vseq");
    super.new(name);
  endfunction

  task body();

    ahb2apb_unmapped_addr_seq ahb_seq;

    ahb_seq = ahb2apb_unmapped_addr_seq::type_id::create("ahb_seq");

    ahb_seq.start(p_sequencer.ahb_seqr);

  endtask

endclass

class ahb2apb_pstrb_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_pstrb_vseq)

  ahb_pstrb_seq ahb_seq;
  apb_pstrb_seq apb_seq;

  function new(string name = "ahb2apb_pstrb_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_seq = ahb_pstrb_seq::type_id::create("ahb_seq");
    apb_seq = apb_pstrb_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass


class ahb2apb_read_size_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_read_size_vseq)

  function new(string name = "ahb2apb_read_size_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_read_size_seq ahb_seq;
    apb_read_size_seq apb_seq;

    ahb_seq = ahb_read_size_seq::type_id::create("ahb_seq");
    apb_seq = apb_read_size_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass

class ahb_hsel_low_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb_hsel_low_vseq)

  function new(string name = "ahb_hsel_low_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_hsel_low_seq ahb_seq;

    `uvm_info(get_type_name(), "HSEL LOW VSEQ STARTED", UVM_LOW)

    ahb_seq = ahb_hsel_low_seq::type_id::create("ahb_seq");

    ahb_seq.start(p_sequencer.ahb_seqr);

    `uvm_info(get_type_name(), "HSEL LOW VSEQ COMPLETED", UVM_LOW)

  endtask

endclass

class ahb_hreadyout_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb_hreadyout_vseq)

  function new(string name = "ahb_hreadyout_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_hreadyout_seq ahb_seq;
    apb_hreadyout_seq apb_seq;

    `uvm_info(get_type_name(),
              "HREADYOUT VSEQ STARTED", UVM_LOW)

    ahb_seq = ahb_hreadyout_seq::type_id::create("ahb_seq");
    apb_seq = apb_hreadyout_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

    `uvm_info(get_type_name(),
              "HREADYOUT VSEQ COMPLETED", UVM_LOW)

  endtask

endclass

class ahb_control_stability_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb_control_stability_vseq)

  function new(string name = "ahb_control_stability_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_control_stability_seq ahb_seq;
    apb_control_stability_seq apb_seq;

    ahb_seq = ahb_control_stability_seq::type_id::create("ahb_seq");
    apb_seq = apb_control_stability_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass

class apb_phase_vseq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(apb_phase_vseq)
  `uvm_declare_p_sequencer(ahb2apb_virtual_sequencer)

  function new(string name = "apb_phase_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_apb_phase_seq ahb_seq;
    apb_phase_seq apb_seq;

    ahb_seq = ahb_apb_phase_seq::type_id::create("ahb_seq");
    apb_seq = apb_phase_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass

class data_integrity_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(data_integrity_vseq)

  function new(string name = "data_integrity_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_data_integrity_seq ahb_seq;
    apb_data_integrity_seq apb_seq;

    ahb_seq = ahb_data_integrity_seq::type_id::create("ahb_seq");
    apb_seq = apb_data_integrity_seq::type_id::create("apb_seq");

    fork
      ahb_seq.start(p_sequencer.ahb_seqr);
      apb_seq.start(p_sequencer.apb_seqr);
    join

  endtask

endclass

class ahb_control_change_wait_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb_control_change_wait_vseq)

function new(string name = "ahb_control_change_wait_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_control_change_wait_seq ahb_seq;

`uvm_info(get_type_name(),
              "CONTROL CHANGE WAIT VSEQ STARTED",
              UVM_LOW)

    ahb_seq = ahb_control_change_wait_seq::type_id::create("ahb_seq");

    ahb_seq.start(p_sequencer.ahb_seqr);

`uvm_info(get_type_name(),
              "CONTROL CHANGE WAIT VSEQ COMPLETED",
              UVM_LOW)

  endtask

endclass

class ahb_hreadyout_timing_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb_hreadyout_timing_vseq)

function new(string name = "ahb_hreadyout_timing_vseq");
    super.new(name);
  endfunction

  task body();

    ahb_hreadyout_timing_seq ahb_seq;

`uvm_info(get_type_name(),
              "HREADYOUT TIMING VSEQ STARTED", UVM_LOW)

    ahb_seq = ahb_hreadyout_timing_seq::type_id::create("ahb_seq");

    ahb_seq.start(p_sequencer.ahb_seqr);

`uvm_info(get_type_name(),
              "HREADYOUT TIMING VSEQ COMPLETED", UVM_LOW)

  endtask

endclass




class reset_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(reset_vseq)

  ahb_reset_sequence ahb_seq;
  apb_reset_sequence apb_seq;

  bit access_seen;

  function new(string name = "reset_vseq");
    super.new(name);
  endfunction


  task body();

    `uvm_info("RESET_VSEQ",
              "Starting reset scenarios",
              UVM_MEDIUM)

    reset_idle_test();

    preset_active_test();

    ahb_reset_before_apb_test();

    ahb_reset_after_apb_test();

    `uvm_info("RESET_VSEQ",
              "All reset scenarios completed",
              UVM_MEDIUM)

  endtask


  // --------------------------------------------------
  // Helper: Wait for APB ACCESS with timeout
  // --------------------------------------------------

  task wait_for_apb_access(output bit found);

    int unsigned count;

    found = 0;

    for (count = 0; count < 100; count++) begin

      @(p_sequencer.apb_vif.monitor_cb);

      if ((p_sequencer.apb_vif.monitor_cb.PSEL != 0) &&
          (p_sequencer.apb_vif.monitor_cb.PENABLE == 1'b1)) begin

        found = 1;

        `uvm_info("RESET_VSEQ",
                  "APB ACCESS detected",
                  UVM_LOW)

        return;
      end

    end

    `uvm_error("RESET_VSEQ",
               "APB ACCESS not detected within 100 PCLK cycles")

  endtask


  // --------------------------------------------------
  // Helper: Wait for AHB address phase with timeout
  // --------------------------------------------------

  task wait_for_ahb_address(output bit found);

    int unsigned count;

    found = 0;

    for (count = 0; count < 100; count++) begin

      @(p_sequencer.ahb_vif.monitor_cb);

      if ((p_sequencer.ahb_vif.monitor_cb.HSEL == 1'b1) &&
          (p_sequencer.ahb_vif.monitor_cb.HTRANS[1] == 1'b1)) begin

        found = 1;

        `uvm_info("RESET_VSEQ",
                  "AHB address phase detected",
                  UVM_LOW)

        return;
      end

    end

    `uvm_error("RESET_VSEQ",
               "AHB address phase not detected within 100 HCLK cycles")

  endtask


  // --------------------------------------------------
  // Helper: Wait for a sequence to finish with timeout
  // --------------------------------------------------

  task wait_for_sequence_completion(bit is_ahb);

    int unsigned count;

    if (is_ahb) begin

      for (count = 0; count < 1000; count++) begin

        if (!ahb_seq.is_active())
          return;

        @(p_sequencer.ahb_vif.monitor_cb);

      end

      `uvm_error("RESET_VSEQ",
                 "AHB sequence did not complete within 1000 HCLK cycles")

    end
    else begin

      for (count = 0; count < 1000; count++) begin

        if (!apb_seq.is_active())
          return;

        @(p_sequencer.apb_vif.monitor_cb);

      end

      `uvm_error("RESET_VSEQ",
                 "APB sequence did not complete within 1000 PCLK cycles")

    end

  endtask


  // --------------------------------------------------
  // Scenario 1: Reset while idle
  // --------------------------------------------------

  task reset_idle_test();

    `uvm_info("RESET_VSEQ",
              "Reset during idle",
              UVM_MEDIUM)

    @(negedge p_sequencer.ahb_vif.HCLK);

    p_sequencer.ahb_vif.HRESETn = 1'b0;
    p_sequencer.apb_vif.PRESETn = 1'b0;

    repeat(5)
      @(posedge p_sequencer.ahb_vif.HCLK);

    @(negedge p_sequencer.ahb_vif.HCLK);

    p_sequencer.ahb_vif.HRESETn = 1'b1;
    p_sequencer.apb_vif.PRESETn = 1'b1;

    repeat(5)
      @(posedge p_sequencer.ahb_vif.HCLK);

    if ((p_sequencer.apb_vif.PSEL == 0) &&
        (p_sequencer.apb_vif.PENABLE == 0))

      `uvm_info("RESET_VSEQ",
                "Idle reset PASS",
                UVM_LOW)

    else

      `uvm_error("RESET_VSEQ",
                 "APB not idle after reset")

  endtask


  // --------------------------------------------------
  // Scenario 2: PRESETn during active APB transaction
  // --------------------------------------------------

  task preset_active_test();

    `uvm_info("RESET_VSEQ",
              "PRESETn during active transaction",
              UVM_MEDIUM)

    fork

      begin
        apb_seq = apb_reset_sequence::type_id::create("apb_seq");
        apb_seq.wait_cycles = 5;
        apb_seq.hang = 1'b0;
        apb_seq.slave_error = 1'b0;
        apb_seq.start(p_sequencer.apb_seqr);
      end

      begin
        ahb_seq = ahb_reset_sequence::type_id::create("ahb_seq");
        ahb_seq.start(p_sequencer.ahb_seqr);
      end

    join_none

    // Wait until the APB transaction actually reaches ACCESS.
    wait_for_apb_access(access_seen);

    if (!access_seen) begin

      `uvm_error("RESET_VSEQ",
                 "Scenario 2 aborted: APB ACCESS not reached")

      disable fork;
      return;

    end

    // Assert PRESETn during APB ACCESS.
    @(negedge p_sequencer.apb_vif.PCLK);

    p_sequencer.apb_vif.PRESETn = 1'b0;

    `uvm_info("RESET_VSEQ",
              "PRESETn asserted during APB ACCESS",
              UVM_LOW)

    repeat(5)
      @(posedge p_sequencer.apb_vif.PCLK);

    @(negedge p_sequencer.apb_vif.PCLK);

    p_sequencer.apb_vif.PRESETn = 1'b1;

    `uvm_info("RESET_VSEQ",
              "PRESETn released",
              UVM_LOW)

    // Bounded wait for both sequences.
    wait_for_sequence_completion(1'b1);
    wait_for_sequence_completion(1'b0);

    disable fork;

  endtask


  // --------------------------------------------------
  // Scenario 3: HRESETn before APB request
  // --------------------------------------------------

  task ahb_reset_before_apb_test();

    `uvm_info("RESET_VSEQ",
              "HRESETn before APB request",
              UVM_MEDIUM)

    fork
      begin
        ahb_seq = ahb_reset_sequence::type_id::create("ahb_seq");
        ahb_seq.start(p_sequencer.ahb_seqr);
      end
    join_none

    // Wait for AHB address phase.
    wait_for_ahb_address(access_seen);

    if (!access_seen) begin

      `uvm_error("RESET_VSEQ",
                 "Scenario 3 aborted: AHB address not detected")

      disable fork;
      return;

    end

    @(negedge p_sequencer.ahb_vif.HCLK);

    p_sequencer.ahb_vif.HRESETn = 1'b0;

    `uvm_info("RESET_VSEQ",
              "HRESETn asserted before APB request",
              UVM_LOW)

    repeat(5)
      @(posedge p_sequencer.ahb_vif.HCLK);

    @(negedge p_sequencer.ahb_vif.HCLK);

    p_sequencer.ahb_vif.HRESETn = 1'b1;

    wait_for_sequence_completion(1'b1);

    disable fork;

  endtask


  // --------------------------------------------------
  // Scenario 4: HRESETn after APB request
  // --------------------------------------------------

  task ahb_reset_after_apb_test();

    `uvm_info("RESET_VSEQ",
              "HRESETn after APB request",
              UVM_MEDIUM)

    fork

      begin
        apb_seq = apb_reset_sequence::type_id::create("apb_seq");
        apb_seq.wait_cycles = 5;
        apb_seq.hang = 1'b0;
        apb_seq.slave_error = 1'b0;
        apb_seq.start(p_sequencer.apb_seqr);
      end

      begin
        ahb_seq = ahb_reset_sequence::type_id::create("ahb_seq");
        ahb_seq.start(p_sequencer.ahb_seqr);
      end

    join_none

    wait_for_apb_access(access_seen);

    if (!access_seen) begin

      `uvm_error("RESET_VSEQ",
                 "Scenario 4 aborted: APB ACCESS not reached")

      disable fork;
      return;

    end

    // Assert HRESETn while APB is in ACCESS.
    @(negedge p_sequencer.ahb_vif.HCLK);

    p_sequencer.ahb_vif.HRESETn = 1'b0;

    `uvm_info("RESET_VSEQ",
              "HRESETn asserted during APB ACCESS",
              UVM_LOW)

    repeat(5)
      @(posedge p_sequencer.ahb_vif.HCLK);

    @(negedge p_sequencer.ahb_vif.HCLK);

    p_sequencer.ahb_vif.HRESETn = 1'b1;

    wait_for_sequence_completion(1'b1);
    wait_for_sequence_completion(1'b0);

    disable fork;

  endtask

endclass


 
   

//============================================================
// 5. FULL REGRESSION VIRTUAL SEQUENCE
//============================================================
class ahb2apb_regression_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(ahb2apb_regression_vseq)

  function new(string name="ahb2apb_regression_vseq");
    super.new(name);
  endfunction

  task body();
   
    ahb2apb_basic_write_vseq write_vseq;
    ahb2apb_basic_read_vseq  read_vseq;
    ahb2apb_wait_states_vseq wait_vseq;
    ahb2apb_apb_error_vseq   error_vseq;
    ahb2apb_back_to_back_vseq back_to_back_vseq;
    ahb2apb_htrans_test_vseq    htrans_test_vseq;
    ahb2apb_all_slave_decode_vseq  all_slave_decode_vseq;
    ahb2apb_timeout_vseq  timeout_vseq;
    ahb2apb_unmapped_addr_vseq  unmapped_addr_vseq;
    ahb2apb_pstrb_vseq pstrb_vseq;
    ahb2apb_read_size_vseq read_size_vseq;
    ahb_hsel_low_vseq hsel_low_vseq;
    ahb_hreadyout_vseq hreadyout_vseq;
    ahb_control_stability_vseq control_stability_vseq;
    apb_phase_vseq  phase_vseq;
    data_integrity_vseq integrity_vseq;
     reset_vseq  rst_vseq;
   
    write_vseq = ahb2apb_basic_write_vseq::type_id::create("write_vseq");
    read_vseq  = ahb2apb_basic_read_vseq::type_id::create("read_vseq");
    wait_vseq  = ahb2apb_wait_states_vseq::type_id::create("wait_vseq");
    error_vseq = ahb2apb_apb_error_vseq::type_id::create("error_vseq");
    back_to_back_vseq = ahb2apb_back_to_back_vseq::type_id::create("back_to_back_vseq");
    htrans_test_vseq =  ahb2apb_htrans_test_vseq::type_id::create("htrans_test_vseq");
    all_slave_decode_vseq= ahb2apb_all_slave_decode_vseq::type_id::create("all_slave_decode_vseq");
    timeout_vseq =  ahb2apb_timeout_vseq::type_id::create("timeout_vseq");
    unmapped_addr_vseq= ahb2apb_unmapped_addr_vseq::type_id::create("unmapped_addr_vseq");
    pstrb_vseq =ahb2apb_pstrb_vseq::type_id::create("pstrb_vseq");
    read_size_vseq = ahb2apb_read_size_vseq::type_id::create("read_size_vseq");
    hsel_low_vseq = ahb_hsel_low_vseq::type_id::create("hsel_low_vseq");
    hreadyout_vseq = ahb_hreadyout_vseq::type_id::create("hreadyout_vseq");
    control_stability_vseq = ahb_control_stability_vseq::type_id::create("ahb_control_stability_vseq");
    phase_vseq = apb_phase_vseq::type_id::create("apb_phase_vseq");
    integrity_vseq = data_integrity_vseq::type_id::create("data_integrity_vseq");
    rst_vseq = reset_vseq::type_id::create("rst_vseq");
    
    write_vseq.start(p_sequencer);
    read_vseq.start(p_sequencer);
    wait_vseq.start(p_sequencer);
    error_vseq.start(p_sequencer);
    back_to_back_vseq.start(p_sequencer);
    htrans_test_vseq.start(p_sequencer);
    all_slave_decode_vseq.start(p_sequencer);
    timeout_vseq.start(p_sequencer);
    unmapped_addr_vseq.start(p_sequencer);
    pstrb_vseq.start(p_sequencer);
    read_size_vseq.start(p_sequencer);
    hsel_low_vseq.start(p_sequencer);
    hreadyout_vseq.start(p_sequencer);
    control_stability_vseq.start(p_sequencer);
    phase_vseq.start(p_sequencer);
    integrity_vseq.start(p_sequencer);
    rst_vseq.start(p_sequencer);
    `uvm_info("REG_VSEQ", "Full regression completed", UVM_LOW)

  endtask

endclass


`endif

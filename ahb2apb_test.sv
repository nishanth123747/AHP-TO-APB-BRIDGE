
`ifndef AHB_APB_TESTS_SV
`define AHB_APB_TESTS_SV

//============================================================
// BASE TEST
//============================================================
class ahb2apb_test extends uvm_test;

  `uvm_component_utils(ahb2apb_test)

  ahb2apb_env env;

  function new(string name="ahb2apb_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = ahb2apb_env::type_id::create("env", this);

  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);

    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();

  endfunction

endclass


//============================================================
// 1. BASIC WRITE TEST
//============================================================
class ahb2apb_basic_write_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_basic_write_test)

  ahb2apb_basic_write_vseq vseq;

  function new(string name="ahb2apb_basic_write_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    vseq = ahb2apb_basic_write_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass


//============================================================
// 2. BASIC READ TEST
//============================================================
class ahb2apb_basic_read_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_basic_read_test)

  ahb2apb_basic_read_vseq vseq;

  function new(string name="ahb2apb_basic_read_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    vseq = ahb2apb_basic_read_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass


//============================================================
// 3. WAIT-STATE TEST
//============================================================
class ahb2apb_wait_states_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_wait_states_test)

  ahb2apb_wait_states_vseq vseq;

  function new(string name="ahb2apb_wait_states_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    vseq = ahb2apb_wait_states_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass


//============================================================
// 4. APB ERROR TEST
//============================================================
class ahb2apb_apb_error_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_apb_error_test)

  ahb2apb_apb_error_vseq vseq;

  function new(string name="ahb2apb_apb_error_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    vseq = ahb2apb_apb_error_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass


//============================================================
// BACK-TO-BACK TEST
//============================================================
class ahb2apb_back_to_back_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_back_to_back_test)

  function new(string name = "ahb2apb_back_to_back_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb2apb_back_to_back_vseq vseq;

    phase.raise_objection(this);

    vseq = ahb2apb_back_to_back_vseq::type_id::create("vseq");

    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass


class ahb2apb_htrans_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_htrans_test)

  function new(string name = "ahb2apb_htrans_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb2apb_htrans_test_vseq vseq;

    phase.raise_objection(this);

    vseq = ahb2apb_htrans_test_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class ahb2apb_timeout_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_timeout_test)

  function new(string name = "ahb2apb_timeout_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb2apb_timeout_vseq vseq;

    phase.raise_objection(this);

    vseq = ahb2apb_timeout_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class ahb2apb_unmapped_addr_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_unmapped_addr_test)

  function new(string name = "ahb2apb_unmapped_addr_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb2apb_unmapped_addr_vseq vseq;

    phase.raise_objection(this);

    vseq = ahb2apb_unmapped_addr_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class ahb2apb_all_slave_decode_test extends ahb2apb_test;


`uvm_component_utils(ahb2apb_all_slave_decode_test)

function new(string name = "ahb2apb_all_slave_decode_test",
uvm_component parent = null);
super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);

ahb2apb_all_slave_decode_vseq vseq;

phase.raise_objection(this);

`uvm_info("TEST", "Starting APB address decoding test", UVM_LOW)

vseq = ahb2apb_all_slave_decode_vseq::type_id::create("vseq");

vseq.start(env.v_sequencer);

`uvm_info("TEST", "APB address decoding test completed", UVM_LOW)

phase.drop_objection(this);

endtask

endclass

class pstrb_test extends ahb2apb_test;

  `uvm_component_utils(pstrb_test)

  function new(string name = "pstrb_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

   ahb2apb_pstrb_vseq vseq;

    phase.raise_objection(this);

    vseq = ahb2apb_pstrb_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class read_size_test extends ahb2apb_test;

  `uvm_component_utils(read_size_test)

  function new(string name = "read_size_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb2apb_read_size_vseq vseq;

    phase.raise_objection(this);

    vseq = ahb2apb_read_size_vseq::type_id::create("vseq");

    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class ahb_hsel_low_test extends ahb2apb_test;

  `uvm_component_utils(ahb_hsel_low_test)

  function new(string name = "ahb_hsel_low_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb_hsel_low_vseq vseq;

    phase.raise_objection(this);

    `uvm_info(get_type_name(), "HSEL LOW TEST STARTED", UVM_LOW)

    vseq = ahb_hsel_low_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);
    `uvm_info(get_type_name(), "HSEL LOW TEST COMPLETED", UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass

class ahb_hreadyout_test extends ahb2apb_test;

  `uvm_component_utils(ahb_hreadyout_test)

  function new(string name = "ahb_hreadyout_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb_hreadyout_vseq vseq;

    phase.raise_objection(this);

    `uvm_info(get_type_name(),
              "HREADYOUT TEST STARTED", UVM_LOW)

    vseq = ahb_hreadyout_vseq::type_id::create("vseq");

    vseq.start(env.v_sequencer);

    `uvm_info(get_type_name(),
              "HREADYOUT TEST COMPLETED", UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass

class ahb_control_stability_test extends ahb2apb_test;

  `uvm_component_utils(ahb_control_stability_test)

  function new(string name = "ahb_control_stability_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    ahb_control_stability_vseq vseq;

    phase.raise_objection(this);

    vseq = ahb_control_stability_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class apb_phase_test extends ahb2apb_test;

  `uvm_component_utils(apb_phase_test)

  function new(string name = "apb_phase_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    apb_phase_vseq vseq;

    phase.raise_objection(this);

    vseq = apb_phase_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class data_integrity_test extends ahb2apb_test;

  `uvm_component_utils(data_integrity_test)

  function new(string name = "data_integrity_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    data_integrity_vseq vseq;

    phase.raise_objection(this);

    vseq = data_integrity_vseq::type_id::create("vseq");
    vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass

class ahb2apb_reset_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_reset_test)

  reset_vseq rst_vseq;

function new(string name = "ahb2apb_reset_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

rst_vseq = reset_vseq::type_id::create("rst_vseq");
    rst_vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass
//============================================================
// 5. FULL REGRESSION TEST
//============================================================
class ahb2apb_regression_test extends ahb2apb_test;

  `uvm_component_utils(ahb2apb_regression_test)

  ahb2apb_regression_vseq reg_vseq;

  function new(string name="ahb2apb_regression_test",
               uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    reg_vseq = ahb2apb_regression_vseq::type_id::create("reg_vseq");
    reg_vseq.start(env.v_sequencer);

    phase.drop_objection(this);

  endtask

endclass



`endif

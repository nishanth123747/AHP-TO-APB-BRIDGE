
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


class read_size_vseq extends ahb2apb_virtual_sequence;

  `uvm_object_utils(read_size_vseq)

  function new(string name = "read_size_vseq");
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
    `uvm_info("REG_VSEQ", "Full regression completed", UVM_LOW)

  endtask

endclass




`endif


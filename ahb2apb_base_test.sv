class ahb2apb_base_test extends uvm_test;
  `uvm_component_utils(ahb2apb_base_test)
  ahb2apb_env env;

  function new(string name = "ahb2apb_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ahb2apb_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    apb_sequence apb_seq = apb_sequence::type_id::create("apb_seq");
    ahb_sequence ahb_seq = ahb_sequence::type_id::create("ahb_seq");
    phase.raise_objection(this);
    // background APB responses (runs forever, so the driver always has an item ready)
    fork apb_seq.start(env.apb_agent.sqr); join_none
    ahb_seq.num_items = 20;
    ahb_seq.start(env.ahb_agent.sqr);
    #2000;   // drain; TODO wait until the scoreboard queues are empty
    phase.drop_objection(this);
  endtask
endclass

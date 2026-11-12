class ahb2apb_env extends uvm_env;
  `uvm_component_utils(ahb2apb_env)
  ahb_master_agent          ahb_agent;
  apb_slave_agent           apb_agent;
  ahb2apb_scoreboard        scoreboard;
  ahb2apb_subscriber        coverage_subscriber;
  ahb2apb_virtual_sequencer v_sequencer;

  function new(string name = "ahb2apb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_agent           = ahb_master_agent::type_id::create("ahb_agent", this);
    apb_agent           = apb_slave_agent::type_id::create("apb_agent", this);
    scoreboard          = ahb2apb_scoreboard::type_id::create("scoreboard", this);
    coverage_subscriber = ahb2apb_subscriber::type_id::create("coverage_subscriber", this);
    v_sequencer         = ahb2apb_virtual_sequencer::type_id::create("v_sequencer", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ahb_agent.monitor.ap.connect(scoreboard.ahb_imp);
    ahb_agent.monitor.ap.connect(coverage_subscriber.ahb_imp);
    apb_agent.monitor.ap.connect(scoreboard.apb_imp);
    apb_agent.monitor.ap.connect(coverage_subscriber.apb_imp);
    // handles
    v_sequencer.ahb_seqr = ahb_agent.sequencer;
    v_sequencer.apb_seqr = apb_agent.sequencer;
  endfunction
endclass

class ahb2apb_env extends uvm_env;
  `uvm_component_utils(ahb2apb_env)
  ahb_master_agent     ahb_agent;
  apb_slave_agent      apb_agent;
  ahb2apb_scoreboard   sb;
  ahb2apb_subscriber   sub;

  function new(string name = "ahb2apb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ahb_agent = ahb_master_agent::type_id::create("ahb_agent", this);
    apb_agent = apb_slave_agent::type_id::create("apb_agent", this);
    sb        = ahb2apb_scoreboard::type_id::create("sb", this);
    sub       = ahb2apb_subscriber::type_id::create("sub", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    ahb_agent.mon.ap.connect(sb.ahb_imp);
    ahb_agent.mon.ap.connect(sub.ahb_imp);
    apb_agent.mon.ap.connect(sb.apb_imp);
    apb_agent.mon.ap.connect(sub.apb_imp);
  endfunction
endclass

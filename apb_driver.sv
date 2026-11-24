
class apb_driver extends uvm_driver #(apb_sequence_item);

  `uvm_component_utils(apb_driver)

  virtual apb_if vif;


  function new(string name = "apb_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // --------------------------------------------------
  // BUILD PHASE
  // --------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "apb_vif", vif))
      `uvm_fatal("APB_DRV", "APB virtual interface not found")

  endfunction

  // --------------------------------------------------
  // RUN PHASE
  // --------------------------------------------------
  task run_phase(uvm_phase phase);

    apb_sequence_item req;

    drive_idle();
    wait_reset_release();



// //       `uvm_info("DEBUG",
// //                 "APB driver waiting for sequence item",
// //                 UVM_LOW)

//       seq_item_port.get_next_item(req);

// //       `uvm_info("DEBUG",
// //                 "APB response item received",
// //                 UVM_LOW)

//       wait_for_setup();

// //       `uvm_info("DEBUG",
// //                 $sformatf("APB SETUP detected: ADDR=%08h WRITE=%0b",
// //                           vif.driver_cb.PADDR,
// //                           vif.driver_cb.PWRITE),
// //                 UVM_LOW)

//       respond(req);

// //       `uvm_info("DEBUG",
// //                 "APB response task completed",
// //                 UVM_LOW)

//       seq_item_port.item_done();
      forever begin

  `uvm_info("DEBUG", "APB driver waiting for sequence item", UVM_LOW)

  seq_item_port.get_next_item(req);

  `uvm_info("DEBUG", "APB sequence item received", UVM_LOW)

  wait_for_setup();

  `uvm_info("DEBUG", "APB SETUP detected", UVM_LOW)

  respond(req);

  `uvm_info("DEBUG", "APB response completed", UVM_LOW)

  seq_item_port.item_done();

end

  endtask

  // --------------------------------------------------
  // CHECK RESET
  // --------------------------------------------------
  function bit in_reset();
    return (vif.driver_cb.PRESETn !== 1'b1);
  endfunction

  // --------------------------------------------------
  // CHECK APB ACCESS
  // --------------------------------------------------
  function bit access_active();

    return ((|vif.driver_cb.PSEL) &&
            (vif.driver_cb.PENABLE === 1'b1));

  endfunction

  // --------------------------------------------------
  // DRIVE IDLE
  // --------------------------------------------------
  task drive_idle();

    vif.driver_cb.PREADY  <= 1'b0;
    vif.driver_cb.PRDATA  <= 32'h0;
    vif.driver_cb.PSLVERR <= 1'b0;

  endtask

  // --------------------------------------------------
  // WAIT FOR RESET RELEASE
  // --------------------------------------------------
  task wait_reset_release();

    do begin
      @(vif.driver_cb);
    end
    while (in_reset());

    //`uvm_info("DEBUG", "APB reset released", UVM_LOW)

  endtask

  // --------------------------------------------------
  // WAIT FOR APB SETUP
  // --------------------------------------------------
 task wait_for_setup();

  forever begin

    @(vif.driver_cb);

    `uvm_info("APB_DEBUG",
      $sformatf(
        "PRESETn=%0b PSEL=%b PENABLE=%0b PADDR=%h",
        vif.driver_cb.PRESETn,
        vif.driver_cb.PSEL,
        vif.driver_cb.PENABLE,
        vif.driver_cb.PADDR),
      UVM_LOW)

    if (in_reset()) begin
      drive_idle();
      continue;
    end

    if ((|vif.driver_cb.PSEL) &&
        (vif.driver_cb.PENABLE === 1'b0)) begin

      `uvm_info("APB_DEBUG", "APB SETUP DETECTED", UVM_LOW)
      return;

    end

  end

endtask

  // --------------------------------------------------
  // RESPOND TO APB TRANSFER
  // --------------------------------------------------
  task respond(apb_sequence_item req);

  bit [31:0] rdata;
  int unsigned waited;

  // Start with PREADY low
  vif.driver_cb.PREADY  <= 1'b0;
  vif.driver_cb.PSLVERR <= 1'b0;
  vif.driver_cb.PRDATA  <= 32'h0;

  // WAIT FOR ACCESS PHASE
  do begin
    @(vif.driver_cb);

    if (in_reset()) begin
      drive_idle();
      return;
    end

  end while (!access_active());

  // HANG / TIMEOUT SCENARIO
  if (req.hang) begin

    forever begin
      @(vif.driver_cb);

      if (in_reset()) begin
        drive_idle();
        return;
      end

      if (!access_active()) begin
        drive_idle();
        return;
      end
    end

  end

  // SELECT READ DATA
  rdata = req.read_data;

  // GENERATE WAIT STATES
  for (waited = 0; waited < req.wait_cycles; waited++) begin

    vif.driver_cb.PREADY  <= 1'b0;
    vif.driver_cb.PSLVERR <= 1'b0;
    vif.driver_cb.PRDATA  <= 32'h0;

    @(vif.driver_cb);

    if (in_reset()) begin
      drive_idle();
      return;
    end

    if (!access_active()) begin
      drive_idle();
      return;
    end

  end

  // COMPLETE APB TRANSFER
  vif.driver_cb.PRDATA  <= rdata;
  vif.driver_cb.PSLVERR <= req.slave_error;
  vif.driver_cb.PREADY  <= 1'b1;

  // Wait for DUT to sample PREADY high
  @(vif.driver_cb);

  if (in_reset()) begin
    drive_idle();
    return;
  end

  `uvm_info("APB_DRV",
    $sformatf("APB response completed: ADDR=%08h WRITE=%0b DATA=%08h WAIT=%0d ERROR=%0b",
      vif.driver_cb.PADDR,
      vif.driver_cb.PWRITE,
      vif.driver_cb.PWDATA,
      req.wait_cycles,
      req.slave_error),
    UVM_MEDIUM)

  drive_idle();

endtask

endclass

class apb_driver extends uvm_driver #(apb_sequence_item);

  `uvm_component_utils(apb_driver)

  virtual apb_if vif;

  bit noise_prdata = 0;

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

    forever begin

//       `uvm_info("DEBUG",
//                 "APB driver waiting for sequence item",
//                 UVM_LOW)

      seq_item_port.get_next_item(req);

//       `uvm_info("DEBUG",
//                 "APB response item received",
//                 UVM_LOW)

      wait_for_setup();

//       `uvm_info("DEBUG",
//                 $sformatf("APB SETUP detected: ADDR=%08h WRITE=%0b",
//                           vif.driver_cb.PADDR,
//                           vif.driver_cb.PWRITE),
//                 UVM_LOW)

      respond(req);

//       `uvm_info("DEBUG",
//                 "APB response task completed",
//                 UVM_LOW)

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

      if (in_reset()) begin
        drive_idle();
        continue;
      end

      if ((|vif.driver_cb.PSEL) &&
          (vif.driver_cb.PENABLE === 1'b0))
        return;

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

    // ----------------------------------------------
    // WAIT FOR ACCESS PHASE
    // ----------------------------------------------
    do begin

      @(vif.driver_cb);

      if (in_reset()) begin
        drive_idle();
        return;
      end

    end
    while (!access_active());

//     `uvm_info("DEBUG",
//               $sformatf("APB ACCESS detected: ADDR=%08h WRITE=%0b PSEL=%b",
//                         vif.driver_cb.PADDR,
//                         vif.driver_cb.PWRITE,
//                         vif.driver_cb.PSEL),
//               UVM_LOW)

    // ----------------------------------------------
    // HANG / TIMEOUT SCENARIO
    // ----------------------------------------------
    if (req.hang) begin

//       `uvm_info("APB_DRV",
//                 "Holding PREADY low for timeout scenario",
//                 UVM_MEDIUM)

      forever begin

        @(vif.driver_cb);

        if (in_reset()) begin
          drive_idle();
          return;
        end

        if (!access_active()) begin

//           `uvm_info("DEBUG",
//                     "DUT ended ACCESS during timeout",
//                     UVM_LOW)

          drive_idle();
          return;

        end

      end

    end

    // ----------------------------------------------
    // SELECT READ DATA
    // ----------------------------------------------
    if (req.use_read_data)
      rdata = req.read_data;
    else
      rdata = 32'h0;

    // ----------------------------------------------
    // GENERATE WAIT STATES
    // ----------------------------------------------
    for (waited = 0;
         waited < req.wait_cycles;
         waited++) begin

      vif.driver_cb.PREADY  <= 1'b0;
      vif.driver_cb.PSLVERR <= 1'b0;
      vif.driver_cb.PRDATA  <=
          noise_prdata ? $urandom() : 32'h0;

//       `uvm_info("DEBUG",
//                 $sformatf("APB WAIT: cycle=%0d PREADY=0 ADDR=%08h",
//                           waited + 1,
//                           vif.driver_cb.PADDR),
//                 UVM_LOW)

      @(vif.driver_cb);

      if (in_reset()) begin
        drive_idle();
        return;
      end

      if (!access_active()) begin

//         `uvm_info("APB_DRV",
//                   "DUT ended ACCESS before response",
//                   UVM_MEDIUM)

        drive_idle();
        return;

      end

    end

    // ----------------------------------------------
    // COMPLETE APB TRANSFER
    // ----------------------------------------------
    vif.driver_cb.PRDATA  <= rdata;
    vif.driver_cb.PSLVERR <= req.slave_error;
    vif.driver_cb.PREADY  <= 1'b1;

//     `uvm_info("DEBUG",
//               $sformatf("APB PREADY ASSERTED: ADDR=%08h WRITE=%0b RDATA=%08h",
//                         vif.driver_cb.PADDR,
//                         vif.driver_cb.PWRITE,
//                         rdata),
//               UVM_LOW)

    // Wait for DUT to sample PREADY high
    @(vif.driver_cb);

    if (in_reset()) begin
      drive_idle();
      return;
    end

    `uvm_info("APB_DRV",
              $sformatf(
                "APB response completed: ADDR=%08h WRITE=%0b DATA=%08h WAIT=%0d ERROR=%0b",
                vif.driver_cb.PADDR,
                vif.driver_cb.PWRITE,
                vif.driver_cb.PWDATA,
                req.wait_cycles,
                req.slave_error),
              UVM_MEDIUM)

    `uvm_info("DEBUG",
              $sformatf("After response: PSEL=%b PENABLE=%b PREADY=%b",
                        vif.driver_cb.PSEL,
                        vif.driver_cb.PENABLE,
                        vif.driver_cb.PREADY),
              UVM_LOW)

    // Return response signals to idle
    drive_idle();

  endtask

endclass

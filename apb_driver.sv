
// class apb_driver extends uvm_driver #(apb_sequence_item);

//   `uvm_component_utils(apb_driver)

//   virtual apb_if vif;


//   function new(string name = "apb_driver",
//                uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   // --------------------------------------------------
//   // BUILD PHASE
//   // --------------------------------------------------
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);

//     if (!uvm_config_db#(virtual apb_if)::get(
//           this, "", "apb_vif", vif))
//       `uvm_fatal("APB_DRV", "APB virtual interface not found")

//   endfunction

//   // --------------------------------------------------
//   // RUN PHASE
//   // --------------------------------------------------
//   task run_phase(uvm_phase phase);

//     apb_sequence_item req;

//     drive_idle();
//     wait_reset_release();



// // //       `uvm_info("DEBUG",
// // //                 "APB driver waiting for sequence item",
// // //                 UVM_LOW)

// //       seq_item_port.get_next_item(req);

// // //       `uvm_info("DEBUG",
// // //                 "APB response item received",
// // //                 UVM_LOW)

// //       wait_for_setup();

// // //       `uvm_info("DEBUG",
// // //                 $sformatf("APB SETUP detected: ADDR=%08h WRITE=%0b",
// // //                           vif.driver_cb.PADDR,
// // //                           vif.driver_cb.PWRITE),
// // //                 UVM_LOW)

// //       respond(req);

// // //       `uvm_info("DEBUG",
// // //                 "APB response task completed",
// // //                 UVM_LOW)

// //       seq_item_port.item_done();
//       forever begin

//   `uvm_info("DEBUG", "APB driver waiting for sequence item", UVM_LOW)

//   seq_item_port.get_next_item(req);

//   `uvm_info("DEBUG", "APB sequence item received", UVM_LOW)

//   wait_for_setup();

//   `uvm_info("DEBUG", "APB SETUP detected", UVM_LOW)

//   respond(req);

//   `uvm_info("DEBUG", "APB response completed", UVM_LOW)

//   seq_item_port.item_done();

// end

//   endtask

//   // --------------------------------------------------
//   // CHECK RESET
//   // --------------------------------------------------
//   function bit in_reset();
//     return (vif.driver_cb.PRESETn !== 1'b1);
//   endfunction

//   // --------------------------------------------------
//   // CHECK APB ACCESS
//   // --------------------------------------------------
//   function bit access_active();

//     return ((|vif.driver_cb.PSEL) &&
//             (vif.driver_cb.PENABLE === 1'b1));

//   endfunction

//   // --------------------------------------------------
//   // DRIVE IDLE
//   // --------------------------------------------------
//   task drive_idle();

//     vif.driver_cb.PREADY  <= 1'b0;
//     vif.driver_cb.PRDATA  <= 32'h0;
//     vif.driver_cb.PSLVERR <= 1'b0;

//   endtask

//   // --------------------------------------------------
//   // WAIT FOR RESET RELEASE
//   // --------------------------------------------------
//   task wait_reset_release();

//     do begin
//       @(vif.driver_cb);
//     end
//     while (in_reset());

//     //`uvm_info("DEBUG", "APB reset released", UVM_LOW)

//   endtask

//   // --------------------------------------------------
//   // WAIT FOR APB SETUP
//   // --------------------------------------------------
//  task wait_for_setup();

//   forever begin

//     @(vif.driver_cb);

//     `uvm_info("APB_DEBUG",
//       $sformatf(
//         "PRESETn=%0b PSEL=%b PENABLE=%0b PADDR=%h",
//         vif.driver_cb.PRESETn,
//         vif.driver_cb.PSEL,
//         vif.driver_cb.PENABLE,
//         vif.driver_cb.PADDR),
//       UVM_LOW)

//     if (in_reset()) begin
//       drive_idle();
//       continue;
//     end

//     if ((|vif.driver_cb.PSEL) &&
//         (vif.driver_cb.PENABLE === 1'b0)) begin

//       `uvm_info("APB_DEBUG", "APB SETUP DETECTED", UVM_LOW)
//       return;

//     end

//   end

// endtask

//   // --------------------------------------------------
//   // RESPOND TO APB TRANSFER
//   // --------------------------------------------------
//   task respond(apb_sequence_item req);

//   bit [31:0] rdata;
//   int unsigned waited;

//   // Start with PREADY low
//   vif.driver_cb.PREADY  <= 1'b0;
//   vif.driver_cb.PSLVERR <= 1'b0;
//   vif.driver_cb.PRDATA  <= 32'h0;

//   // WAIT FOR ACCESS PHASE
//   do begin
//     @(vif.driver_cb);

//     if (in_reset()) begin
//       drive_idle();
//       return;
//     end

//   end while (!access_active());

//   // HANG / TIMEOUT SCENARIO
//   if (req.hang) begin

//     forever begin
//       @(vif.driver_cb);

//       if (in_reset()) begin
//         drive_idle();
//         return;
//       end

//       if (!access_active()) begin
//         drive_idle();
//         return;
//       end
//     end

//   end

//   // SELECT READ DATA
//   rdata = req.read_data;

//   // GENERATE WAIT STATES
//   for (waited = 0; waited < req.wait_cycles; waited++) begin

//     vif.driver_cb.PREADY  <= 1'b0;
//     vif.driver_cb.PSLVERR <= 1'b0;
//     vif.driver_cb.PRDATA  <= 32'h0;

//     @(vif.driver_cb);

//     if (in_reset()) begin
//       drive_idle();
//       return;
//     end

//     if (!access_active()) begin
//       drive_idle();
//       return;
//     end

//   end

//   // COMPLETE APB TRANSFER
//   vif.driver_cb.PRDATA  <= rdata;
//   vif.driver_cb.PSLVERR <= req.slave_error;
//   vif.driver_cb.PREADY  <= 1'b1;

//   // Wait for DUT to sample PREADY high
//   @(vif.driver_cb);

//   if (in_reset()) begin
//     drive_idle();
//     return;
//   end

//   `uvm_info("APB_DRV",
//     $sformatf("APB response completed: ADDR=%08h WRITE=%0b DATA=%08h WAIT=%0d ERROR=%0b",
//       vif.driver_cb.PADDR,
//       vif.driver_cb.PWRITE,
//       vif.driver_cb.PWDATA,
//       req.wait_cycles,
//       req.slave_error),
//     UVM_MEDIUM)

//   drive_idle();

// endtask

// endclass



class ahb_driver extends uvm_driver #(ahb_sequence_item);

  `uvm_component_utils(ahb_driver)

  virtual ahb_if vif;

  function new(string name = "ahb_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  // --------------------------------------------------
  // BUILD PHASE
  // --------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual ahb_if)::get(
          this, "", "ahb_vif", vif))
      `uvm_fatal("AHB_DRV", "AHB virtual interface not found")

  endfunction


  // --------------------------------------------------
  // RUN PHASE
  // --------------------------------------------------
  task run_phase(uvm_phase phase);

    ahb_sequence_item req;

    drive_idle();
    wait_reset_release();

    forever begin

      seq_item_port.get_next_item(req);

      drive_transfer(req);

      seq_item_port.item_done();

    end

  endtask


  // --------------------------------------------------
  // RESET
  // --------------------------------------------------
  task wait_reset_release();

    do begin
      @(vif.driver_cb);
    end while (vif.driver_cb.HRESETn !== 1'b1);

  endtask


  // --------------------------------------------------
  // IDLE
  // --------------------------------------------------
  task drive_idle();

    vif.driver_cb.HSEL   <= 1'b0;
    vif.driver_cb.HADDR  <= '0;
    vif.driver_cb.HTRANS <= 2'b00;
    vif.driver_cb.HWRITE <= 1'b0;
    vif.driver_cb.HSIZE  <= 3'b010;
    vif.driver_cb.HBURST <= 3'b000;
    vif.driver_cb.HWDATA <= '0;

  endtask


  // --------------------------------------------------
  // DRIVE TRANSFER
  // --------------------------------------------------
//   task drive_transfer(ahb_sequence_item t);

//     // IDLE, BUSY, or unselected transfer
//     if (!(t.HSEL && t.HTRANS[1])) begin

//       vif.driver_cb.HSEL   <= t.HSEL;
//       vif.driver_cb.HADDR  <= t.HADDR;
//       vif.driver_cb.HTRANS <= t.HTRANS;
//       vif.driver_cb.HWRITE <= t.HWRITE;
//       vif.driver_cb.HSIZE  <= t.HSIZE;
//       vif.driver_cb.HBURST <= t.HBURST;
//       vif.driver_cb.HWDATA <= '0;

//       @(vif.driver_cb);

//       drive_idle();
//       return;

//     end


//     // ----------------------------------------------
//     // WAIT 1: BUS READY BEFORE ADDRESS
//     // ----------------------------------------------
//     while (vif.driver_cb.HREADYOUT !== 1'b1) begin
//       @(vif.driver_cb);
//     end


//     // ADDRESS PHASE
// vif.driver_cb.HSEL   <= 1'b1;
// vif.driver_cb.HADDR  <= t.HADDR;
// vif.driver_cb.HTRANS <= t.HTRANS;
// vif.driver_cb.HWRITE <= t.HWRITE;
// vif.driver_cb.HSIZE  <= t.HSIZE;
// vif.driver_cb.HBURST <= t.HBURST;

// // Wait for the next clocking event
// @(vif.driver_cb);

// // DATA PHASE
// vif.driver_cb.HSEL   <= 1'b0;
// vif.driver_cb.HTRANS <= 2'b00;

// if (t.HWRITE)
//     vif.driver_cb.HWDATA <= t.HWDATA;
// else
//     vif.driver_cb.HWDATA <= '0;

//     `uvm_info("AHB_DRV",
//       $sformatf(
//         "ADDRESS AND DATA DRIVEN: ADDR=%08h WRITE=%0b WDATA=%08h",
//         t.HADDR, t.HWRITE, t.HWDATA),
//       UVM_LOW)


//     // ----------------------------------------------
//     // WAIT 2: ADDRESS ACCEPTANCE
//     // ----------------------------------------------
//     do begin
//       @(vif.driver_cb);
//     end while (vif.driver_cb.HREADYOUT !== 1'b1);


//     // ----------------------------------------------
//     // DATA PHASE
//     // ----------------------------------------------
//     // Deassert address/control signals.
//     // Keep HWDATA stable.
//     vif.driver_cb.HSEL   <= 1'b0;
//     vif.driver_cb.HTRANS <= 2'b00;


//     // ----------------------------------------------
//     // WAIT 3: WAIT FOR BRIDGE WAIT STATE
//     // ----------------------------------------------
//     // HREADYOUT may still be HIGH immediately after
//     // address acceptance. First wait for LOW.

//     while (vif.driver_cb.HREADYOUT !== 1'b0) begin
//       @(vif.driver_cb);
//     end


//     // ----------------------------------------------
//     // WAIT 4: WAIT FOR TRANSFER COMPLETION
//     // ----------------------------------------------
//     // Now wait until HREADYOUT returns HIGH.

//     while (vif.driver_cb.HREADYOUT !== 1'b1) begin
//       @(vif.driver_cb);
//     end


//     `uvm_info("AHB_DRV",
//       $sformatf(
//         "TRANSFER COMPLETED: HSEL =%0b HTRANS=%0b ADDR=%08h WRITE=%0b WDATA=%08h HRESP=%0b HRDATA=%08h",
//         t.HSEL,
//         t.HTRANS,
//         t.HADDR,
//         t.HWRITE,
//         t.HWDATA,
//         vif.driver_cb.HRESP,
//         vif.driver_cb.HRDATA),
//       UVM_MEDIUM)


//     // ----------------------------------------------
//     // RETURN TO IDLE
//     // ----------------------------------------------
//     drive_idle();

//   endtask
    
    
 
task wait_hready_value(
  input bit expected_value,
  output bit ok
);

  int unsigned count;

  count = 0;
  ok = 0;

  while (count < 1000) begin

    @(vif.driver_cb);

    if (vif.driver_cb.HRESETn !== 1'b1) begin
      `uvm_warning("AHB_DRV",
                   "HRESETn asserted while waiting for HREADYOUT")
      drive_idle();
      return;
    end

    if (vif.driver_cb.HREADYOUT === expected_value) begin
      ok = 1;
      return;
    end

    count++;

  end

  `uvm_error("AHB_DRV",
             $sformatf("Timeout waiting for HREADYOUT=%0b",
                       expected_value))

  drive_idle();

endtask
   
    
    
task drive_transfer(ahb_sequence_item t);

  bit ok;

  // IDLE, BUSY, or unselected transfer
  if (!(t.HSEL && t.HTRANS[1])) begin

    vif.driver_cb.HSEL   <= t.HSEL;
    vif.driver_cb.HADDR  <= t.HADDR;
    vif.driver_cb.HTRANS <= t.HTRANS;
    vif.driver_cb.HWRITE <= t.HWRITE;
    vif.driver_cb.HSIZE  <= t.HSIZE;
    vif.driver_cb.HBURST <= t.HBURST;
    vif.driver_cb.HWDATA <= '0;

    @(vif.driver_cb);

    drive_idle();
    return;

  end

  // WAIT 1: BUS READY BEFORE ADDRESS
  wait_hready_value(1'b1, ok);

  if (!ok)
    return;

  // ADDRESS PHASE
  vif.driver_cb.HSEL   <= 1'b1;
  vif.driver_cb.HADDR  <= t.HADDR;
  vif.driver_cb.HTRANS <= t.HTRANS;
  vif.driver_cb.HWRITE <= t.HWRITE;
  vif.driver_cb.HSIZE  <= t.HSIZE;
  vif.driver_cb.HBURST <= t.HBURST;

  `uvm_info("AHB_DRV",
            $sformatf("ADDRESS DRIVEN: ADDR=%08h WRITE=%0b",
                      t.HADDR, t.HWRITE),
            UVM_LOW)

  @(vif.driver_cb);

  // DATA PHASE
  vif.driver_cb.HSEL   <= 1'b0;
  vif.driver_cb.HTRANS <= 2'b00;

  if (t.HWRITE)
    vif.driver_cb.HWDATA <= t.HWDATA;
  else
    vif.driver_cb.HWDATA <= '0;

  `uvm_info("AHB_DRV",
            $sformatf("DATA DRIVEN: ADDR=%08h WDATA=%08h",
                      t.HADDR, t.HWDATA),
            UVM_LOW)

  // WAIT 2: WAIT FOR BRIDGE WAIT STATE
  wait_hready_value(1'b0, ok);

  if (!ok)
    return;

  // WAIT 3: WAIT FOR TRANSFER COMPLETION
  wait_hready_value(1'b1, ok);

  if (!ok)
    return;

  `uvm_info("AHB_DRV",
            $sformatf(
              "TRANSFER COMPLETED: ADDR=%08h WRITE=%0b WDATA=%08h HRESP=%0b HRDATA=%08h",
              t.HADDR,
              t.HWRITE,
              t.HWDATA,
              vif.driver_cb.HRESP,
              vif.driver_cb.HRDATA),
            UVM_MEDIUM)

  drive_idle();

endtask

    
 task wait_hreadyout(output bit ok);
  int unsigned count;

  count = 0;
  ok = 1;

  do begin
    @(vif.driver_cb);

    if (vif.driver_cb.HRESETn !== 1'b1) begin
      `uvm_warning("AHB_DRV",
                   "HRESETn asserted while waiting for HREADYOUT")
      ok = 0;
      return;
    end

    count++;

    if (count >= 1000) begin
      `uvm_error("AHB_DRV",
                 "Timeout: HREADYOUT did not become HIGH")
      ok = 0;
      return;
    end

  end while (vif.driver_cb.HREADYOUT !== 1'b1);

endtask   

endclass


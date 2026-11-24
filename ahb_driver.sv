
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


// class ahb_driver extends uvm_driver #(ahb_sequence_item);

//   `uvm_component_utils(ahb_driver)

//   virtual ahb_if vif;

//   function new(string name = "ahb_driver",
//                uvm_component parent = null);
//     super.new(name, parent);
//   endfunction


//   // --------------------------------------------------
//   // BUILD PHASE
//   // --------------------------------------------------
//   function void build_phase(uvm_phase phase);

//     super.build_phase(phase);

//     if (!uvm_config_db#(virtual ahb_if)::get(
//           this, "", "ahb_vif", vif))
//       `uvm_fatal("AHB_DRV", "AHB virtual interface not found")

//   endfunction


//   // --------------------------------------------------
//   // RUN PHASE
//   // --------------------------------------------------
//   task run_phase(uvm_phase phase);

//     ahb_sequence_item req;

//     drive_idle();
//     wait_reset_release();

//     forever begin

//       seq_item_port.get_next_item(req);

//       drive_transfer(req);

//       seq_item_port.item_done();

//     end

//   endtask


//   // --------------------------------------------------
//   // RESET RELEASE
//   // --------------------------------------------------
//   task wait_reset_release();

//     do begin
//       @(vif.driver_cb);
//     end while (vif.driver_cb.HRESETn !== 1'b1);

//   endtask


//   // --------------------------------------------------
//   // IDLE
//   // --------------------------------------------------
//   task drive_idle();

//     vif.driver_cb.HSEL   <= 1'b0;
//     vif.driver_cb.HADDR  <= '0;
//     vif.driver_cb.HTRANS <= 2'b00;
//     vif.driver_cb.HWRITE <= 1'b0;
//     vif.driver_cb.HSIZE  <= 3'b010;
//     vif.driver_cb.HBURST <= 3'b000;
//     vif.driver_cb.HWDATA <= '0;

//   endtask


//   // --------------------------------------------------
//   // CHECK RESET
//   // --------------------------------------------------
//   function bit reset_active();

//     return (vif.driver_cb.HRESETn !== 1'b1);

//   endfunction


//   // --------------------------------------------------
//   // WAIT FOR HREADYOUT
//   // Returns 1 when ready, 0 when reset interrupts wait
//   // --------------------------------------------------
//   task wait_hready(output bit ready);

//     ready = 0;

//     while (vif.driver_cb.HREADYOUT !== 1'b1) begin

//       @(vif.driver_cb);

//       if (reset_active()) begin
//         drive_idle();
//         return;
//       end

//     end

//     ready = 1;

//   endtask


//   // --------------------------------------------------
//   // DRIVE TRANSFER
//   // --------------------------------------------------
//   task drive_transfer(ahb_sequence_item t);

//     bit ready;

//     // If reset is active, do not drive a transaction
//     if (reset_active()) begin
//       drive_idle();
//       wait_reset_release();
//     end

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
//     wait_hready(ready);

//     if (!ready)
//       return;


//     // ----------------------------------------------
//     // ADDRESS PHASE
//     // ----------------------------------------------
//     vif.driver_cb.HSEL   <= 1'b1;
//     vif.driver_cb.HADDR  <= t.HADDR;
//     vif.driver_cb.HTRANS <= t.HTRANS;
//     vif.driver_cb.HWRITE <= t.HWRITE;
//     vif.driver_cb.HSIZE  <= t.HSIZE;
//     vif.driver_cb.HBURST <= t.HBURST;
// `uvm_info("AHB_DEBUG",
//   $sformatf(
//     "HRESETn=%0b HSEL=%0b HTRANS=%b HADDR=%h",
//     vif.HRESETn,
//     vif.HSEL,
//     vif.HTRANS,
//     vif.HADDR
//   ),
//   UVM_LOW)
//     @(vif.driver_cb);

//     if (reset_active()) begin
//       drive_idle();
//       return;
//     end


//     // ----------------------------------------------
//     // DATA PHASE
//     // ----------------------------------------------
//     vif.driver_cb.HSEL   <= 1'b0;
//     vif.driver_cb.HTRANS <= 2'b00;

//     if (t.HWRITE)
//       vif.driver_cb.HWDATA <= t.HWDATA;
//     else
//       vif.driver_cb.HWDATA <= '0;

//     `uvm_info("AHB_DRV",
//       $sformatf(
//         "ADDRESS AND DATA DRIVEN: ADDR=%08h WRITE=%0b WDATA=%08h",
//         t.HADDR, t.HWRITE, t.HWDATA),
//       UVM_LOW)


//     // ----------------------------------------------
//     // WAIT FOR BRIDGE WAIT STATE
//     // ----------------------------------------------
//     while (vif.driver_cb.HREADYOUT !== 1'b0) begin

//       @(vif.driver_cb);

//       if (reset_active()) begin
//         drive_idle();
//         return;
//       end

//     end


//     // ----------------------------------------------
//     // WAIT FOR TRANSFER COMPLETION
//     // ----------------------------------------------
//     wait_hready(ready);

//     if (!ready)
//       return;


//     `uvm_info("AHB_DRV",
//       $sformatf(
//         "TRANSFER COMPLETED: ADDR=%08h WRITE=%0b WDATA=%08h HRESP=%0b HRDATA=%08h",
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

// endclass


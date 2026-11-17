
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
  
task drive_transfer(ahb_sequence_item t);

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

  // Wait until the bus is ready before starting
  while (vif.driver_cb.HREADYOUT !== 1'b1)
    @(vif.driver_cb);

  // ADDRESS PHASE
  vif.driver_cb.HSEL   <= 1'b1;
  vif.driver_cb.HADDR  <= t.HADDR;
  vif.driver_cb.HTRANS <= t.HTRANS;
  vif.driver_cb.HWRITE <= t.HWRITE;
  vif.driver_cb.HSIZE  <= t.HSIZE;
  vif.driver_cb.HBURST <= t.HBURST;

  @(vif.driver_cb);

  // DATA PHASE
  vif.driver_cb.HSEL   <= 1'b0;
  vif.driver_cb.HTRANS <= 2'b00;

  if (t.HWRITE)
    vif.driver_cb.HWDATA <= t.HWDATA;
  else
    vif.driver_cb.HWDATA <= '0;

  `uvm_info("AHB_DRV",
    $sformatf("ADDRESS AND DATA DRIVEN: ADDR=%08h WRITE=%0b WDATA=%08h",
              t.HADDR, t.HWRITE, t.HWDATA), UVM_LOW)

  // Wait for transfer completion.
  // Allow the DUT to enter its wait/error response state.
  do begin
    @(vif.driver_cb);
  end while (vif.driver_cb.HREADYOUT !== 1'b1);

  `uvm_info("AHB_DRV",
    $sformatf("TRANSFER COMPLETED: ADDR=%08h WRITE=%0b WDATA=%08h HRESP=%0b HRDATA=%08h",
              t.HADDR, t.HWRITE, t.HWDATA,
              vif.driver_cb.HRESP, vif.driver_cb.HRDATA),
    UVM_MEDIUM)

  drive_idle();

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


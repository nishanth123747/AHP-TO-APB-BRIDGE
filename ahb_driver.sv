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


    // ----------------------------------------------
    // WAIT 1: BUS READY BEFORE ADDRESS
    // ----------------------------------------------
    while (vif.driver_cb.HREADYOUT !== 1'b1) begin
      @(vif.driver_cb);
    end


    // ADDRESS PHASE
vif.driver_cb.HSEL   <= 1'b1;
vif.driver_cb.HADDR  <= t.HADDR;
vif.driver_cb.HTRANS <= t.HTRANS;
vif.driver_cb.HWRITE <= t.HWRITE;
vif.driver_cb.HSIZE  <= t.HSIZE;
vif.driver_cb.HBURST <= t.HBURST;

// Wait for the next clocking event
@(vif.driver_cb);

// DATA PHASE
vif.driver_cb.HSEL   <= 1'b0;
vif.driver_cb.HTRANS <= 2'b00;

if (t.HWRITE)
    vif.driver_cb.HWDATA <= t.HWDATA;
else
    vif.driver_cb.HWDATA <= '0;

    `uvm_info("AHB_DRV",
      $sformatf(
        "ADDRESS AND DATA DRIVEN: ADDR=%08h WRITE=%0b WDATA=%08h",
        t.HADDR, t.HWRITE, t.HWDATA),
      UVM_LOW)


    // ----------------------------------------------
    // WAIT 2: ADDRESS ACCEPTANCE
    // ----------------------------------------------
    do begin
      @(vif.driver_cb);
    end while (vif.driver_cb.HREADYOUT !== 1'b1);


    // ----------------------------------------------
    // DATA PHASE
    // ----------------------------------------------
    // Deassert address/control signals.
    // Keep HWDATA stable.
    vif.driver_cb.HSEL   <= 1'b0;
    vif.driver_cb.HTRANS <= 2'b00;


    // ----------------------------------------------
    // WAIT 3: WAIT FOR BRIDGE WAIT STATE
    // ----------------------------------------------
    // HREADYOUT may still be HIGH immediately after
    // address acceptance. First wait for LOW.

    while (vif.driver_cb.HREADYOUT !== 1'b0) begin
      @(vif.driver_cb);
    end


    // ----------------------------------------------
    // WAIT 4: WAIT FOR TRANSFER COMPLETION
    // ----------------------------------------------
    // Now wait until HREADYOUT returns HIGH.

    while (vif.driver_cb.HREADYOUT !== 1'b1) begin
      @(vif.driver_cb);
    end


    `uvm_info("AHB_DRV",
      $sformatf(
        "TRANSFER COMPLETED: HSEL =%0b HTRANS=%0b ADDR=%08h WRITE=%0b WDATA=%08h HRESP=%0b HRDATA=%08h",
        t.HSEL,
        t.HTRANS,
        t.HADDR,
        t.HWRITE,
        t.HWDATA,
        vif.driver_cb.HRESP,
        vif.driver_cb.HRDATA),
      UVM_MEDIUM)


    // ----------------------------------------------
    // RETURN TO IDLE
    // ----------------------------------------------
    drive_idle();

  endtask

endclass

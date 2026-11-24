
class ahb_monitor extends uvm_monitor;

  `uvm_component_utils(ahb_monitor)

  virtual ahb_if vif;

  uvm_analysis_port #(ahb_sequence_item) ap;

  function new(string name = "ahb_monitor",
               uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual ahb_if)::get(
      this, "", "ahb_vif", vif))
      `uvm_fatal("AHB_MON", "AHB virtual interface not found")
  endfunction


 
// task run_phase(uvm_phase phase);

//   ahb_sequence_item tr;

//   forever begin

//     @(vif.monitor_cb);

//     // Ignore reset
//     if (vif.monitor_cb.HRESETn !== 1'b1)
//       continue;

//     // ------------------------------------------------
//     // STEP 1: Capture IDLE, BUSY and HSEL LOW
//     // ------------------------------------------------
//     if ((vif.monitor_cb.HTRANS[1] === 1'b0) ||
//         (vif.monitor_cb.HSEL === 1'b0)) begin

//       tr = ahb_sequence_item::type_id::create("tr");

//       tr.HSEL   = vif.monitor_cb.HSEL;
//       tr.HTRANS = vif.monitor_cb.HTRANS;
//       tr.HADDR  = vif.monitor_cb.HADDR;
//       tr.HWRITE = vif.monitor_cb.HWRITE;
//       tr.HSIZE  = vif.monitor_cb.HSIZE;

//       tr.transaction_complete = 1'b0;

//       ap.write(tr);

//       `uvm_info("AHB_MON",
//         $sformatf("AHB CONTROL: HSEL=%0b HTRANS=%b",
//           tr.HSEL, tr.HTRANS),
//         UVM_MEDIUM)

//     end

//     // ------------------------------------------------
//     // STEP 2: Detect valid and accepted address phase
//     // ------------------------------------------------
//     if ((vif.monitor_cb.HSEL === 1'b1) &&
//         (vif.monitor_cb.HTRANS[1] === 1'b1) &&
//         (vif.monitor_cb.HREADYOUT === 1'b1)) begin

//       tr = ahb_sequence_item::type_id::create("tr");

//       tr.HSEL   = vif.monitor_cb.HSEL;
//       tr.HADDR  = vif.monitor_cb.HADDR;
//       tr.HTRANS = vif.monitor_cb.HTRANS;
//       tr.HWRITE = vif.monitor_cb.HWRITE;
//       tr.HSIZE  = vif.monitor_cb.HSIZE;
//       tr.HBURST = vif.monitor_cb.HBURST;

//       // Data phase
//       @(vif.monitor_cb);

//       if (tr.HWRITE)
//         tr.HWDATA = vif.monitor_cb.HWDATA;
//       else
//         tr.HWDATA = '0;

//       // Wait for HREADYOUT LOW
//       while ((vif.monitor_cb.HREADYOUT !== 1'b0) &&
//              (vif.monitor_cb.HRESETn === 1'b1))
//         @(vif.monitor_cb);

//       // Wait for HREADYOUT HIGH
//       while ((vif.monitor_cb.HREADYOUT !== 1'b1) &&
//              (vif.monitor_cb.HRESETn === 1'b1))
//         @(vif.monitor_cb);

//       // Capture response
//       tr.HRDATA = vif.monitor_cb.HRDATA;
//       tr.HRESP  = vif.monitor_cb.HRESP;

//       tr.transaction_complete = 1'b1;

//       ap.write(tr);

//       `uvm_info("AHB_MON",
//         $sformatf(
//           "AHB COMPLETED: TIME=%0t ADDR=%08h WRITE=%0b HWDATA=%08h HRDATA=%08h HRESP=%0b",
//           $time, tr.HADDR, tr.HWRITE,
//           tr.HWDATA, tr.HRDATA, tr.HRESP),
//         UVM_MEDIUM)

//     end

//   end

// endtask
      
 
task run_phase(uvm_phase phase);

  ahb_sequence_item tr;
  bit reset_interrupted;

  forever begin

    @(vif.monitor_cb);

    // Ignore reset
    if (vif.monitor_cb.HRESETn !== 1'b1)
      continue;

    // ------------------------------------------------
    // STEP 1: Capture IDLE, BUSY and HSEL LOW
    // ------------------------------------------------
    if ((vif.monitor_cb.HTRANS[1] === 1'b0) ||
        (vif.monitor_cb.HSEL === 1'b0)) begin

      tr = ahb_sequence_item::type_id::create("tr");

      tr.HSEL   = vif.monitor_cb.HSEL;
      tr.HTRANS = vif.monitor_cb.HTRANS;
      tr.HADDR  = vif.monitor_cb.HADDR;
      tr.HWRITE = vif.monitor_cb.HWRITE;
      tr.HSIZE  = vif.monitor_cb.HSIZE;

      tr.transaction_complete = 1'b0;

      ap.write(tr);

      `uvm_info("AHB_MON",
        $sformatf("AHB CONTROL: HSEL=%0b HTRANS=%b",
          tr.HSEL, tr.HTRANS),
        UVM_MEDIUM)

    end

    // ------------------------------------------------
    // STEP 2: Detect valid and accepted address phase
    // ------------------------------------------------
    if ((vif.monitor_cb.HSEL === 1'b1) &&
        (vif.monitor_cb.HTRANS[1] === 1'b1) &&
        (vif.monitor_cb.HREADYOUT === 1'b1)) begin

      tr = ahb_sequence_item::type_id::create("tr");

      tr.HSEL   = vif.monitor_cb.HSEL;
      tr.HADDR  = vif.monitor_cb.HADDR;
      tr.HTRANS = vif.monitor_cb.HTRANS;
      tr.HWRITE = vif.monitor_cb.HWRITE;
      tr.HSIZE  = vif.monitor_cb.HSIZE;
      tr.HBURST = vif.monitor_cb.HBURST;

      reset_interrupted = 1'b0;

      // ----------------------------------------------
      // STEP 3: Capture data phase
      // ----------------------------------------------
      @(vif.monitor_cb);

      if (vif.monitor_cb.HRESETn !== 1'b1) begin
        reset_interrupted = 1'b1;
      end
      else begin

        if (tr.HWRITE)
          tr.HWDATA = vif.monitor_cb.HWDATA;
        else
          tr.HWDATA = '0;

        // --------------------------------------------
        // STEP 4: Wait for HREADYOUT LOW
        // --------------------------------------------
        while ((vif.monitor_cb.HREADYOUT !== 1'b0) &&
               (vif.monitor_cb.HRESETn === 1'b1))
          @(vif.monitor_cb);

        // --------------------------------------------
        // STEP 5: Wait for HREADYOUT HIGH
        // --------------------------------------------
        while ((vif.monitor_cb.HREADYOUT !== 1'b1) &&
               (vif.monitor_cb.HRESETn === 1'b1))
          @(vif.monitor_cb);

        // Check reset again after the wait
        if (vif.monitor_cb.HRESETn !== 1'b1)
          reset_interrupted = 1'b1;

      end

      // ----------------------------------------------
      // STEP 6: Publish only a normally completed transfer
      // ----------------------------------------------
      if (reset_interrupted) begin

        tr.transaction_complete = 1'b0;

        `uvm_warning("AHB_MON",
          $sformatf(
            "AHB TRANSFER INTERRUPTED BY RESET: ADDR=%08h",
            tr.HADDR))

        ap.write(tr);

      end
      else begin

        tr.HRDATA = vif.monitor_cb.HRDATA;
        tr.HRESP  = vif.monitor_cb.HRESP;

        tr.transaction_complete = 1'b1;

        ap.write(tr);

        `uvm_info("AHB_MON",
          $sformatf(
            "AHB COMPLETED: TIME=%0t ADDR=%08h WRITE=%0b HWDATA=%08h HRDATA=%08h HRESP=%0b",
            $time, tr.HADDR, tr.HWRITE,
            tr.HWDATA, tr.HRDATA, tr.HRESP),
          UVM_MEDIUM)

      end

    end

  end

endtask
     


endclass

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


  task run_phase(uvm_phase phase);

    ahb_sequence_item tr;

    forever begin

      // Sample AHB interface
      @(vif.monitor_cb);

      // Ignore reset
      if (vif.monitor_cb.HRESETn !== 1'b1)
        continue;

      // Detect valid and accepted address phase
      if ((vif.monitor_cb.HSEL === 1'b1) &&
          (vif.monitor_cb.HTRANS[1] === 1'b1) &&
          (vif.monitor_cb.HREADYOUT === 1'b1)) begin

        tr = ahb_sequence_item::type_id::create("tr");

        // STEP 1: Capture address and control information
        tr.HSEL   = vif.monitor_cb.HSEL;
        tr.HADDR  = vif.monitor_cb.HADDR;
        tr.HTRANS = vif.monitor_cb.HTRANS;
        tr.HWRITE = vif.monitor_cb.HWRITE;
        tr.HSIZE  = vif.monitor_cb.HSIZE;
        tr.HBURST = vif.monitor_cb.HBURST;

        // STEP 2: Move to the next clock (data phase)
        @(vif.monitor_cb);

//         if (vif.monitor_cb.HRESETn !== 1'b1)
//           continue;

        // Capture write data in the data phase
        if (tr.HWRITE)
          tr.HWDATA = vif.monitor_cb.HWDATA;
        else
          tr.HWDATA = '0;


        // STEP 3: Wait until HREADYOUT goes LOW
        while ((vif.monitor_cb.HREADYOUT !== 1'b0) &&
               (vif.monitor_cb.HRESETn === 1'b1)) begin

          @(vif.monitor_cb);
        end

//         if (vif.monitor_cb.HRESETn !== 1'b1)
//           continue;


        // STEP 4: Wait until HREADYOUT returns HIGH
        while ((vif.monitor_cb.HREADYOUT !== 1'b1) &&
               (vif.monitor_cb.HRESETn === 1'b1)) begin

          @(vif.monitor_cb);
        end

//         if (vif.monitor_cb.HRESETn !== 1'b1)
//           continue;


        // STEP 5: Capture final response
        tr.HRDATA = vif.monitor_cb.HRDATA;
        tr.HRESP  = vif.monitor_cb.HRESP;


        // STEP 6: Publish transaction
        ap.write(tr);

        `uvm_info("AHB_MON",
          $sformatf(
            "AHB COMPLETED: TIME=%0t ADDR=%08h WRITE=%0b HWDATA=%08h HRDATA=%08h HRESP=%0b",
            $time,
            tr.HADDR,
            tr.HWRITE,
            tr.HWDATA,
            tr.HRDATA,
            tr.HRESP),
          UVM_MEDIUM)

      end
    end

  endtask

endclass

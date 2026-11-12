class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  virtual apb_if vif;

  uvm_analysis_port #(apb_sequence_item) ap;

  bit access_active;
  apb_sequence_item pending_tr;

  function new(string name = "apb_monitor",
               uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
    access_active = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "apb_vif", vif))
      `uvm_fatal("APB_MON",
                 "APB monitor virtual interface not found")
  endfunction


  task run_phase(uvm_phase phase);

    forever begin

      @(vif.monitor_cb);

      if (vif.monitor_cb.PRESETn !== 1'b1) begin
        access_active = 0;
        pending_tr = null;
        continue;
      end


      // ------------------------------------------
      // Detect APB ACCESS phase
      // ------------------------------------------
      if (!access_active) begin

        if ((|vif.monitor_cb.PSEL) &&
            (vif.monitor_cb.PENABLE === 1'b1)) begin

          pending_tr = apb_sequence_item::type_id::create("pending_tr");

          pending_tr.PADDR   = vif.monitor_cb.PADDR;
          pending_tr.PSEL    = vif.monitor_cb.PSEL;
          pending_tr.PWRITE  = vif.monitor_cb.PWRITE;
          pending_tr.PWDATA  = vif.monitor_cb.PWDATA;
          pending_tr.PSTRB   = vif.monitor_cb.PSTRB;
          pending_tr.PENABLE = vif.monitor_cb.PENABLE;
          pending_tr.PREADY  = vif.monitor_cb.PREADY;
          pending_tr.PRDATA  = vif.monitor_cb.PRDATA;
          pending_tr.PSLVERR = vif.monitor_cb.PSLVERR;
          pending_tr.aborted = 0;

          // Normal completion
          if (vif.monitor_cb.PREADY === 1'b1) begin

            ap.write(pending_tr);

            `uvm_info("APB_MON",
              $sformatf(
                "APB COMPLETED: ADDR=%08h WRITE=%0b WDATA=%08h PSLVERR=%0b",
                pending_tr.PADDR,
                pending_tr.PWRITE,
                pending_tr.PWDATA,
                pending_tr.PSLVERR),
              UVM_MEDIUM)

            pending_tr = null;

          end
          else begin

            // PREADY is LOW: wait for completion or abort
            access_active = 1;

          end

        end

      end
      else begin

        // ------------------------------------------
        // Wait for normal completion
        // ------------------------------------------
        if ((|vif.monitor_cb.PSEL) &&
            (vif.monitor_cb.PENABLE === 1'b1) &&
            (vif.monitor_cb.PREADY === 1'b1)) begin

          pending_tr.PREADY  = 1'b1;
          pending_tr.PRDATA  = vif.monitor_cb.PRDATA;
          pending_tr.PSLVERR = vif.monitor_cb.PSLVERR;

          ap.write(pending_tr);

          `uvm_info("APB_MON",
            $sformatf(
              "APB COMPLETED: ADDR=%08h WRITE=%0b WDATA=%08h PSLVERR=%0b",
              pending_tr.PADDR,
              pending_tr.PWRITE,
              pending_tr.PWDATA,
              pending_tr.PSLVERR),
            UVM_MEDIUM)

          access_active = 0;
          pending_tr = null;

        end

        // ------------------------------------------
        // Detect timeout abort
        // ------------------------------------------
        else if (!(|vif.monitor_cb.PSEL) ||
                 (vif.monitor_cb.PENABLE === 1'b0)) begin

          pending_tr.aborted = 1'b1;
          pending_tr.PREADY  = 1'b0;

          ap.write(pending_tr);

          `uvm_info("APB_MON",
            $sformatf(
              "APB TIMEOUT ABORT: ADDR=%08h WRITE=%0b WDATA=%08h",
              pending_tr.PADDR,
              pending_tr.PWRITE,
              pending_tr.PWDATA),
            UVM_MEDIUM)

          access_active = 0;
          pending_tr = null;

        end

      end

    end

  endtask

endclass


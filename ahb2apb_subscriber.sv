// `uvm_analysis_imp_decl(_ahb)
// `uvm_analysis_imp_decl(_apb)

class ahb2apb_subscriber extends uvm_component;

  `uvm_component_utils(ahb2apb_subscriber)

  uvm_analysis_imp_ahb #(ahb_sequence_item, ahb2apb_subscriber) ahb_imp;
  uvm_analysis_imp_apb #(apb_sequence_item, ahb2apb_subscriber) apb_imp;

  ahb_sequence_item a;
  apb_sequence_item p;

  // =====================================================
  // AHB INPUT COVERAGE
  // =====================================================

  covergroup cg_ahb;

    HRESETN_CP: coverpoint a.HRESETn {
      bins reset_asserted   = {0};
      bins reset_deasserted = {1};
    }

    HSEL_CP: coverpoint a.HSEL {
      bins not_selected = {0};
      bins selected     = {1};
    }

    HTRANS_CP: coverpoint a.HTRANS {
      bins idle   = {2'b00};
      bins busy   = {2'b01};
      bins nonseq = {2'b10};
      bins seq    = {2'b11};
    }

    HWRITE_CP: coverpoint a.HWRITE {
      bins read  = {0};
      bins write = {1};
    }

    HSIZE_CP: coverpoint a.HSIZE {
      bins byte_transfer = {3'b000};
      bins halfword      = {3'b001};
      bins word          = {3'b010};
      bins oversized     = {[3'b011:3'b111]};
    }

    HBURST_CP: coverpoint a.HBURST {
      bins burst_types[] = {[3'b000:3'b111]};
    }

    HWDATA_CP: coverpoint a.HWDATA {
      bins smal = {[32'h00000000:32'h0000FFFF]};
      bins med = {[32'h00010000:32'h7FFFFFFF]};
      bins lar  = {[32'h80000000:32'hFFFFFFFF]};
    }

    HWRITE_X_HSIZE: cross HWRITE_CP, HSIZE_CP;
    HTRANS_X_HSEL:  cross HTRANS_CP, HSEL_CP;

  endgroup


  // =====================================================
  // APB COVERAGE
  // =====================================================

  covergroup cg_apb;

    PRESETN_CP: coverpoint p.PRESETn {
      bins reset_asserted   = {0};
      bins reset_deasserted = {1};
    }

    PREADY_CP: coverpoint p.PREADY {
      bins not_ready = {0};
      bins ready     = {1};
    }

    PRDATA_CP: coverpoint p.PRDATA {
      bins sma  = {[32'h00000000:32'h0000FFFF]};
      bins med = {[32'h00010000:32'h7FFFFFFF]};
      bins lar  = {[32'h80000000:32'hFFFFFFFF]};
    }

    PSLVERR_CP: coverpoint p.PSLVERR {
      bins okay  = {0};
      bins error = {1};
    }

    PADDR_CP: coverpoint p.PADDR {
      bins region0 = {[32'h00000000:32'h0FFFFFFF]};
      bins region1 = {[32'h10000000:32'h1FFFFFFF]};
      bins region2 = {[32'h20000000:32'h2FFFFFFF]};
      bins region3 = {[32'h30000000:32'h3FFFFFFF]};
      bins region4 = {[32'h40000000:32'h4FFFFFFF]};
      bins region5 = {[32'h50000000:32'h5FFFFFFF]};
      bins region6 = {[32'h60000000:32'h6FFFFFFF]};
      bins region7 = {[32'h70000000:32'h7FFFFFFF]};
    }

    PWRITE_CP: coverpoint p.PWRITE {
      bins read  = {0};
      bins write = {1};
    }

    PWDATA_CP: coverpoint p.PWDATA {
      bins smal = {[32'h00000000:32'h0000FFFF]};
      bins med = {[32'h00010000:32'h7FFFFFFF]};
      bins lar  = {[32'h80000000:32'hFFFFFFFF]};
    }

    PSTRB_CP: coverpoint p.PSTRB {
      bins byte0      = {4'b0001};
      bins byte1      = {4'b0010};
      bins byte2      = {4'b0100};
      bins byte3      = {4'b1000};
      bins lower_half = {4'b0011};
      bins upper_half = {4'b1100};
      bins all_bytes  = {4'b1111};
    }

    PSEL_CP: coverpoint p.PSEL {
      bins slave0 = {8'b00000001};
      bins slave1 = {8'b00000010};
      bins slave2 = {8'b00000100};
      bins slave3 = {8'b00001000};
      bins slave4 = {8'b00010000};
      bins slave5 = {8'b00100000};
      bins slave6 = {8'b01000000};
      bins slave7 = {8'b10000000};
    }

    PENABLE_CP: coverpoint p.PENABLE {
      bins setup  = {0};
      bins access = {1};
    }

  endgroup


  // =====================================================
  // AHB OUTPUT COVERAGE
  // =====================================================

  covergroup cg_output;

    HREADYOUT_CP: coverpoint a.HREADYOUT {
      bins not_ready = {0};
      bins ready     = {1};
    }

    HRESP_CP: coverpoint a.HRESP {
      bins okay  = {0};
      bins error = {1};
    }

    HRDATA_CP: coverpoint a.HRDATA {
      bins smal  = {[32'h00000000:32'h0000FFFF]};
      bins med = {[32'h00010000:32'h7FFFFFFF]};
      bins lar  = {[32'h80000000:32'hFFFFFFFF]};
    }

  endgroup


  // =====================================================
  // CROSS COVERAGE
  // =====================================================

  covergroup cg_cross;

    HSIZE_CP: coverpoint a.HSIZE {
      bins byte_transfer = {3'b000};
      bins halfword      = {3'b001};
      bins word          = {3'b010};
      bins oversized     = {[3'b011:3'b111]};
    }

    HWRITE_CP: coverpoint a.HWRITE {
      bins read  = {0};
      bins write = {1};
    }

    PREADY_CP: coverpoint p.PREADY {
      bins not_ready = {0};
      bins ready     = {1};
    }

    PSLVERR_CP: coverpoint p.PSLVERR {
      bins okay  = {0};
      bins error = {1};
    }

    PSTRB_CP: coverpoint p.PSTRB {
      bins byte0      = {4'b0001};
      bins byte1      = {4'b0010};
      bins byte2      = {4'b0100};
      bins byte3      = {4'b1000};
      bins lower_half = {4'b0011};
      bins upper_half = {4'b1100};
      bins all_bytes  = {4'b1111};
    }

    HSIZE_X_PSTRB:    cross HSIZE_CP, PSTRB_CP;
    HWRITE_X_PREADY:  cross HWRITE_CP, PREADY_CP;
    HWRITE_X_PSLVERR: cross HWRITE_CP, PSLVERR_CP;

  endgroup


  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  function new(string name = "ahb2apb_subscriber",
               uvm_component parent = null);

    super.new(name, parent);

    cg_ahb    = new();
    cg_apb    = new();
    cg_output = new();
    cg_cross  = new();

  endfunction


  // =====================================================
  // BUILD PHASE
  // =====================================================

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    ahb_imp = new("ahb_imp", this);
    apb_imp = new("apb_imp", this);

  endfunction


  // =====================================================
  // 1. AHB SAMPLING
  // =====================================================

  function void sample_ahb_coverage();

    cg_ahb.sample();
    cg_output.sample();

  endfunction


  // =====================================================
  // 2. APB SAMPLING
  // =====================================================

  function void sample_apb_coverage();

    cg_apb.sample();

  endfunction


  // =====================================================
  // 3. CROSS SAMPLING
  // =====================================================

  function void sample_cross_coverage();

    if ((a != null) && (p != null))
      cg_cross.sample();

  endfunction


  // =====================================================
  // AHB MONITOR CALLBACK
  // =====================================================

  function void write_ahb(ahb_sequence_item t);

    a = t;

    sample_ahb_coverage();

  endfunction


  // =====================================================
  // APB MONITOR CALLBACK
  // =====================================================

  function void write_apb(apb_sequence_item t);

    p = t;

    sample_apb_coverage();

  endfunction


  // =====================================================
  // REPORT PHASE
  // =====================================================

  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info("COVERAGE",
      $sformatf("AHB coverage = %0.2f%%",
                cg_ahb.get_coverage()), UVM_LOW)

    `uvm_info("COVERAGE",
      $sformatf("APB coverage = %0.2f%%",
                cg_apb.get_coverage()), UVM_LOW)

    `uvm_info("COVERAGE",
      $sformatf("Output coverage = %0.2f%%",
                cg_output.get_coverage()), UVM_LOW)

    `uvm_info("COVERAGE",
      $sformatf("Cross coverage = %0.2f%%",
                cg_cross.get_coverage()), UVM_LOW)

  endfunction

endclass

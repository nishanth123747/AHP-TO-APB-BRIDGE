
// class ahb2apb_scoreboard extends uvm_scoreboard;

//   `uvm_component_utils(ahb2apb_scoreboard)

//   uvm_analysis_imp_ahb #(ahb_sequence_item, ahb2apb_scoreboard) ahb_imp;
//   uvm_analysis_imp_apb #(apb_sequence_item, ahb2apb_scoreboard) apb_imp;

//   ahb_sequence_item ahb_q[$];
//   apb_sequence_item apb_q[$];

//   int unsigned pass_count;
//   int unsigned fail_count;

//   function new(string name = "ahb2apb_scoreboard",
//                uvm_component parent = null);
//     super.new(name, parent);

//     ahb_imp = new("ahb_imp", this);
//     apb_imp = new("apb_imp", this);

//     pass_count = 0;
//     fail_count = 0;
//   endfunction


//   // AHB monitor callback
//  // AHB monitor callback
// function void write_ahb(ahb_sequence_item t);

//   // Ignore incomplete observations.
//   // These are used only for AHB control-signal coverage.
//   if (!t.transaction_complete)
//     return;

//   if (!is_mapped(t.HADDR)) begin

//     if (t.HRESP === 1'b1) begin
//       pass_count++;
//       `uvm_info("SB_PASS",
//         $sformatf("Unmapped address correctly returned error: %08h",
//                   t.HADDR), UVM_LOW)
//     end
//     else begin
//       fail_count++;
//       `uvm_error("SB_FAIL",
//         $sformatf("Unmapped address did not return error: %08h",
//                   t.HADDR))
//     end

//   end
//   else begin
//     ahb_q.push_back(t);
//   end

//   process_queues();

// endfunction

//   // APB monitor callback
//   function void write_apb(apb_sequence_item t);

//     apb_q.push_back(t);

//     process_queues();

//   endfunction


//   // Address mapping
//   function bit is_mapped(bit [31:0] addr);

//     return (addr < 32'h0080_0000);

//   endfunction


//   // Expected APB select
//   function bit [7:0] get_expected_psel(bit [31:0] addr);

//     bit [7:0] sel;

//     sel = 8'b0;
//     sel[addr[22:20]] = 1'b1;

//     return sel;

//   endfunction
 

//   // Expected byte strobes
// //   function bit [3:0] get_expected_pstrb(
// //     bit [2:0] hsize,
// //     bit [1:0] addr_low
// //   );

// //     bit [3:0] strb;

// //     strb = 4'b0000;

// //     case (hsize)

// //       3'b000:
// //         strb = 4'b0001 << addr_low;

// //       3'b001: begin
// //         if (addr_low[0] == 1'b0)
// //           strb = 4'b0011 << addr_low;
// //       end

// //       3'b010: begin
// //         if (addr_low == 2'b00)
// //           strb = 4'b1111;
// //       end

// //       default:
// //         strb = 4'b0000;

// //     endcase

// //     return strb;

// //   endfunction
// function bit [3:0] get_expected_pstrb(
//     bit [2:0] hsize,
//     bit [1:0] addr_low
// );

//     bit [3:0] strb;
//     int num_bytes;

//     strb = 4'b0000;

//     num_bytes = (1 << hsize);

//     // Clamp to maximum PSTRB width
//     if (num_bytes > 4)
//         num_bytes = 4;

//     if (num_bytes == 4)
//         strb = 4'b1111;
//     else
//         strb = (4'b1111 >> (4-num_bytes)) << addr_low;

//     return strb;

// endfunction

//   // Compare AHB and APB transactions
//   function void process_queues();

//     ahb_sequence_item ahb;
//     apb_sequence_item apb;

//     bit [7:0] expected_psel;
//     bit [3:0] expected_pstrb;

//     bit transaction_pass;

//     while ((ahb_q.size() > 0) && (apb_q.size() > 0)) begin

//       ahb = ahb_q.pop_front();
//       apb = apb_q.pop_front();

//       transaction_pass = 1'b1;

//       expected_psel  = get_expected_psel(ahb.HADDR);
//      // 4. Write data and strobe checks
// if (ahb.HWRITE === 1'b1) begin

//   expected_pstrb = get_expected_pstrb(
//                      ahb.HSIZE,
//                      ahb.HADDR[1:0]
//                    );
// `uvm_info("PSTRB_DEBUG",
//   $sformatf(
//     "HADDR=%08h HSIZE=%03b ADDR_LOW=%02b EXPECTED=%04b ACTUAL=%04b",
//     ahb.HADDR,
//     ahb.HSIZE,
//     ahb.HADDR[1:0],
//     expected_pstrb,
//     apb.PSTRB
//   ),
//   UVM_LOW)
//   // Write data check
//   if (ahb.HWDATA !== apb.PWDATA) begin
//     transaction_pass = 1'b0;
//     `uvm_error("SB_FAIL",
//       $sformatf("WDATA MISMATCH: AHB=%08h APB=%08h",
//                 ahb.HWDATA, apb.PWDATA))
//   end
//   else
//     `uvm_info("SB_CHECK", "WRITE DATA CHECK PASS", UVM_LOW)

//   // Write strobe check
//   if (apb.PSTRB !== expected_pstrb) begin
//     transaction_pass = 1'b0;
//     `uvm_error("SB_FAIL",
//       $sformatf("PSTRB MISMATCH: EXPECTED=%04b ACTUAL=%04b",
//                 expected_pstrb, apb.PSTRB))
//   end
//   else
//     `uvm_info("SB_CHECK", "PSTRB CHECK PASS", UVM_LOW)

// end


// // 5. Read data check
// if (ahb.HWRITE === 1'b0) begin

//   // Read strobe must be zero
//   if (apb.PSTRB !== 4'b0000) begin
//     transaction_pass = 1'b0;
//     `uvm_error("SB_FAIL",
//       $sformatf("READ PSTRB should be zero, actual=%04b",
//                 apb.PSTRB))
//   end
//   else
//     `uvm_info("SB_CHECK", "READ PSTRB CHECK PASS", UVM_LOW)

//   if (apb.PSLVERR === 1'b0) begin
//     if (ahb.HRDATA !== apb.PRDATA) begin
//       transaction_pass = 1'b0;
//       `uvm_error("SB_FAIL",
//         $sformatf("RDATA MISMATCH: AHB=%08h APB=%08h",
//                   ahb.HRDATA, apb.PRDATA))
//     end
//     else
//       `uvm_info("SB_CHECK", "READ DATA CHECK PASS", UVM_LOW)
//   end

// end



// // ------------------------------------------
//     // 1. Address check
//     // ------------------------------------------
//     if (ahb.HADDR !== apb.PADDR) begin
//       transaction_pass = 0;

// `uvm_error("SB_FAIL",
//         $sformatf("ADDRESS MISMATCH: AHB=%08h APB=%08h",
//                   ahb.HADDR, apb.PADDR))
//     end

// // ------------------------------------------
//     // 2. PSEL check
//     // ------------------------------------------
//     if (apb.PSEL !== expected_psel) begin
//       transaction_pass = 0;

// `uvm_error("SB_FAIL",
//         $sformatf("PSEL MISMATCH: EXPECTED=%02h ACTUAL=%02h",
//                   expected_psel, apb.PSEL))
//     end

// // ------------------------------------------
//     // 3. Direction check
//     // ------------------------------------------
//     if (ahb.HWRITE !== apb.PWRITE) begin
//       transaction_pass = 0;

// `uvm_error("SB_FAIL",
//         $sformatf("DIRECTION MISMATCH: AHB=%0b APB=%0b",
//                   ahb.HWRITE, apb.PWRITE))
//     end

// // ------------------------------------------
//     // 4. Write checks
//     // ------------------------------------------
//     if (ahb.HWRITE === 1'b1) begin

// expected_pstrb = get_expected_pstrb(
//                          ahb.HSIZE,
//                          ahb.HADDR[1:0]
//                        );

// if (ahb.HWDATA !== apb.PWDATA) begin
//         transaction_pass = 0;

// `uvm_error("SB_FAIL",
//           $sformatf("WDATA MISMATCH: AHB=%08h APB=%08h",
//                     ahb.HWDATA, apb.PWDATA))
//       end

// if (apb.PSTRB !== expected_pstrb) begin
//         transaction_pass = 0;

// `uvm_error("SB_FAIL",
//           $sformatf("PSTRB MISMATCH: EXPECTED=%04b ACTUAL=%04b",
//                     expected_pstrb, apb.PSTRB))
//       end

//     end

// // ------------------------------------------
//     // 5. Read checks
//     // ------------------------------------------
//     if (ahb.HWRITE === 1'b0) begin

// if (apb.PSTRB !== 4'b0000) begin
//         transaction_pass = 0;

// `uvm_error("SB_FAIL",
//           $sformatf("READ PSTRB MISMATCH: ACTUAL=%04b",
//                     apb.PSTRB))
//       end

//       if (!apb.aborted && (apb.PSLVERR === 1'b0)) begin

// if (ahb.HRDATA !== apb.PRDATA) begin
//           transaction_pass = 0;

// `uvm_error("SB_FAIL",
//             $sformatf("RDATA MISMATCH: AHB=%08h APB=%08h",
//                       ahb.HRDATA, apb.PRDATA))
//         end

//       end

//     end

// // ------------------------------------------
//     // 6. Timeout abort check
//     // ------------------------------------------
//     if (apb.aborted === 1'b1) begin

// if (ahb.HRESP !== 1'b1) begin
//         transaction_pass = 0;

// `uvm_error("SB_FAIL",
//           "TIMEOUT RESPONSE MISMATCH: APB ABORTED BUT AHB HRESP=0")
//       end
//       else begin

// `uvm_info("SB_CHECK",
//           "TIMEOUT CHECK PASS: APB ABORTED AND AHB HRESP=1",
//           UVM_LOW)

//       end

//     end

// // ------------------------------------------
//     // 7. Normal APB error response check
//     // ------------------------------------------
//     else begin

//       if (apb.PSLVERR === 1'b1) begin

// if (ahb.HRESP !== 1'b1) begin
//           transaction_pass = 0;

// `uvm_error("SB_FAIL",
//             "APB ERROR RESPONSE NOT PROPAGATED TO AHB")
//         end

// end
//       else if (apb.PSLVERR === 1'b0) begin

// if (ahb.HRESP !== 1'b0) begin
//           transaction_pass = 0;

// `uvm_error("SB_FAIL",
//             "AHB ERROR WITHOUT APB ERROR")
//         end

// end
//       else begin

//         transaction_pass = 0;

//         `uvm_error("SB_FAIL", "APB PSLVERR contains X/Z")

//       end

//     end
    
//     `uvm_info("SB_COMPARE",
//   $sformatf("\n====================================================\nTRANSACTION TYPE : %s\n----------------------------------------------------\nSIGNAL       AHB VALUE       APB VALUE\n----------------------------------------------------\nADDRESS      %08h       %08h\nWRITE        %0b               %0b\nWDATA        %08h       %08h\nRDATA        %08h       %08h\nPSEL EXPECTED=%b  ACTUAL=%b\nPSTRB EXPECTED=%04b ACTUAL=%04b\nHRESP        %0b               PSLVERR=%0b\n====================================================",
//     ahb.HWRITE ? "WRITE" : "READ",
//     ahb.HADDR, apb.PADDR,
//     ahb.HWRITE, apb.PWRITE,
//     ahb.HWDATA, apb.PWDATA,
//     ahb.HRDATA, apb.PRDATA,
//     expected_psel, apb.PSEL,
//     expected_pstrb, apb.PSTRB,
//     ahb.HRESP, apb.PSLVERR),
//   UVM_LOW)


// // ------------------------------------------
//     // 8. Final result
//     // ------------------------------------------
//     if (transaction_pass) begin

//       pass_count++;

// if (apb.aborted)
//         `uvm_info("SB_PASS",
//           $sformatf("TIMEOUT TRANSACTION PASS: ADDR=%08h",
//                     ahb.HADDR), UVM_LOW)
//       else
//         `uvm_info("SB_PASS",
//           $sformatf("TRANSACTION PASS: ADDR=%08h WRITE=%0b",
//                     ahb.HADDR, ahb.HWRITE), UVM_LOW)

// end
//     else begin

//       fail_count++;

// `uvm_error("SB_FAIL",
//         $sformatf("TRANSACTION FAIL: ADDR=%08h WRITE=%0b",
//                   ahb.HADDR, ahb.HWRITE))

//     end

//   end

// endfunction


//   // Final scoreboard summary
//  function void report_phase(uvm_phase phase);

//   super.report_phase(phase);

//   `uvm_info("SB_SUMMARY",
//     $sformatf("\n========== SCOREBOARD SUMMARY ==========\nPASS COUNT = %0d\nFAIL COUNT = %0d\n========================================",
//       pass_count, fail_count),
//     UVM_LOW)

//   if (ahb_q.size() != 0)
//     `uvm_error("SB_PENDING",
//       $sformatf("Unmatched AHB transactions: %0d", ahb_q.size()))

//   if (apb_q.size() != 0)
//     `uvm_error("SB_PENDING",
//       $sformatf("Unmatched APB transactions: %0d", apb_q.size()))

// endfunction

// endclass



class ahb2apb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(ahb2apb_scoreboard)

  // Analysis implementation ports
  uvm_analysis_imp_ahb #(ahb_sequence_item, ahb2apb_scoreboard) ahb_imp;
  uvm_analysis_imp_apb #(apb_sequence_item, ahb2apb_scoreboard) apb_imp;

  // Normal transaction queues
  ahb_sequence_item ahb_q[$];
  apb_sequence_item apb_q[$];

  // Transactions interrupted by AHB reset
  ahb_sequence_item ahb_reset_q[$];

  // Counters
  int unsigned pass_count;
  int unsigned fail_count;
  int unsigned apb_after_ahb_reset_count;

  function new(string name = "ahb2apb_scoreboard",
               uvm_component parent = null);

    super.new(name, parent);

    ahb_imp = new("ahb_imp", this);
    apb_imp = new("apb_imp", this);

    pass_count = 0;
    fail_count = 0;
    apb_after_ahb_reset_count = 0;

  endfunction


  // ---------------------------------------------------------
  // AHB monitor callback
  // ---------------------------------------------------------
  function void write_ahb(ahb_sequence_item t);

    // Incomplete AHB observation
    if (!t.transaction_complete) begin

      // Capture only a valid interrupted transfer.
      // Ignore IDLE, BUSY and HSEL-low observations.
      if ((t.HSEL === 1'b1) &&
          (t.HTRANS[1] === 1'b1)) begin

        ahb_reset_q.push_back(t);

        `uvm_warning("SB_RESET",
          $sformatf(
            "AHB TRANSACTION INTERRUPTED: ADDR=%08h WRITE=%0b",
            t.HADDR, t.HWRITE))

      end

      return;

    end

    // -------------------------------------------------------
    // Normal completed AHB transaction
    // -------------------------------------------------------

    if (!is_mapped(t.HADDR)) begin

      if (t.HRESP === 1'b1) begin

        pass_count++;

        `uvm_info("SB_PASS",
          $sformatf(
            "UNMAPPED ADDRESS ERROR CHECK PASS: ADDR=%08h",
            t.HADDR),
          UVM_LOW)

      end
      else begin

        fail_count++;

        `uvm_error("SB_FAIL",
          $sformatf(
            "UNMAPPED ADDRESS DID NOT RETURN ERROR: ADDR=%08h",
            t.HADDR))

      end

    end
    else begin

      ahb_q.push_back(t);

      `uvm_info("SB_AHB",
        $sformatf(
          "AHB TRANSACTION QUEUED: ADDR=%08h WRITE=%0b",
          t.HADDR, t.HWRITE),
        UVM_MEDIUM)

    end

    process_queues();

  endfunction


  // ---------------------------------------------------------
  // APB monitor callback
  // ---------------------------------------------------------
  function void write_apb(apb_sequence_item t);

    ahb_sequence_item reset_ahb;
    int match_idx;
    bit matched;
    bit transaction_pass;
    bit [7:0] expected_psel;
    bit [3:0] expected_pstrb;

    matched   = 1'b0;
    match_idx = -1;
    reset_ahb = null;

    // -------------------------------------------------------
    // First check whether this APB transaction belongs to
    // an AHB transaction interrupted by HRESETn.
    //
    // Search newest-to-oldest because scenarios 3 and 4
    // use the same address and direction.
    // -------------------------------------------------------

    for (int i = ahb_reset_q.size()-1; i >= 0; i--) begin

      if ((ahb_reset_q[i].HADDR  === t.PADDR) &&
          (ahb_reset_q[i].HWRITE === t.PWRITE)) begin

        match_idx = i;
        matched   = 1'b1;
        reset_ahb = ahb_reset_q[i];

        break;

      end

    end

    // -------------------------------------------------------
    // APB completion after AHB reset
    // -------------------------------------------------------

    if (matched) begin

      transaction_pass = 1'b1;

      expected_psel = get_expected_psel(reset_ahb.HADDR);
      expected_pstrb = 4'b0000;

      if (reset_ahb.HWRITE === 1'b1) begin

        expected_pstrb = get_expected_pstrb(
                           reset_ahb.HSIZE,
                           reset_ahb.HADDR[1:0]);

      end

      // Address check
      if (reset_ahb.HADDR !== t.PADDR) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_RESET",
          "ADDRESS MISMATCH AFTER AHB RESET")

      end

      // PSEL check
      if (t.PSEL !== expected_psel) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_RESET",
          $sformatf(
            "PSEL MISMATCH: EXPECTED=%02h ACTUAL=%02h",
            expected_psel, t.PSEL))

      end

      // Direction check
      if (reset_ahb.HWRITE !== t.PWRITE) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_RESET",
          "DIRECTION MISMATCH AFTER AHB RESET")

      end

      // Write data check
      if (reset_ahb.HWRITE === 1'b1) begin

        if (reset_ahb.HWDATA !== t.PWDATA) begin

          transaction_pass = 1'b0;

          `uvm_error("SB_RESET",
            $sformatf(
              "WRITE DATA MISMATCH: AHB=%08h APB=%08h",
              reset_ahb.HWDATA, t.PWDATA))

        end
        else begin

          `uvm_info("SB_RESET",
            "WRITE DATA CHECK PASS AFTER AHB RESET",
            UVM_LOW)

        end

      end

      // PSTRB check
      if (t.PSTRB !== expected_pstrb) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_RESET",
          $sformatf(
            "PSTRB MISMATCH: EXPECTED=%04b ACTUAL=%04b",
            expected_pstrb, t.PSTRB))

      end
      else begin

        `uvm_info("SB_RESET",
          "PSTRB CHECK PASS AFTER AHB RESET",
          UVM_LOW)

      end

      // APB completion check
      if (t.aborted === 1'b1) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_RESET",
          "APB TRANSACTION ABORTED AFTER AHB RESET; EXPECTED COMPLETION")

      end

      // Remove the matched reset-interrupted AHB transaction
      ahb_reset_q.delete(match_idx);

      apb_after_ahb_reset_count++;

      if (transaction_pass) begin

        pass_count++;

        `uvm_info("SB_PASS",
          $sformatf(
            "EXPECTED APB COMPLETION AFTER AHB RESET: ADDR=%08h",
            t.PADDR),
          UVM_LOW)

      end
      else begin

        fail_count++;

        `uvm_error("SB_FAIL",
          $sformatf(
            "APB CHECK FAILED AFTER AHB RESET: ADDR=%08h",
            t.PADDR))

      end

      // Do not put this APB transaction into normal apb_q.
      return;

    end

    // -------------------------------------------------------
    // Normal APB transaction
    // -------------------------------------------------------

    apb_q.push_back(t);

    process_queues();

  endfunction


  // ---------------------------------------------------------
  // Address mapping
  // ---------------------------------------------------------
  function bit is_mapped(bit [31:0] addr);

    return (addr < 32'h0080_0000);

  endfunction


  // ---------------------------------------------------------
  // Expected APB select
  // ---------------------------------------------------------
  function bit [7:0] get_expected_psel(bit [31:0] addr);

    bit [7:0] sel;

    sel = 8'b0;
    sel[addr[22:20]] = 1'b1;

    return sel;

  endfunction


  // ---------------------------------------------------------
  // Expected byte strobes
  // ---------------------------------------------------------
  function bit [3:0] get_expected_pstrb(
    bit [2:0] hsize,
    bit [1:0] addr_low
  );

    bit [3:0] strb;
    int num_bytes;

    strb = 4'b0000;

    num_bytes = (1 << hsize);

    // Clamp to maximum PSTRB width
    if (num_bytes > 4)
      num_bytes = 4;

    if (num_bytes == 4)
      strb = 4'b1111;
    else
      strb = (4'b1111 >> (4-num_bytes)) << addr_low;

    return strb;

  endfunction


  // ---------------------------------------------------------
  // Normal AHB and APB transaction comparison
  // ---------------------------------------------------------
  function void process_queues();

    ahb_sequence_item ahb;
    apb_sequence_item apb;

    bit [7:0] expected_psel;
    bit [3:0] expected_pstrb;

    bit transaction_pass;

    while ((ahb_q.size() > 0) &&
           (apb_q.size() > 0)) begin

      ahb = ahb_q.pop_front();
      apb = apb_q.pop_front();

      transaction_pass = 1'b1;

      expected_psel = get_expected_psel(ahb.HADDR);
      expected_pstrb = 4'b0000;

      if (ahb.HWRITE === 1'b1) begin

        expected_pstrb = get_expected_pstrb(
                           ahb.HSIZE,
                           ahb.HADDR[1:0]);

      end

      // -----------------------------------------------------
      // 1. Address check
      // -----------------------------------------------------

      if (ahb.HADDR !== apb.PADDR) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_FAIL",
          $sformatf(
            "ADDRESS MISMATCH: AHB=%08h APB=%08h",
            ahb.HADDR, apb.PADDR))

      end

      // -----------------------------------------------------
      // 2. PSEL check
      // -----------------------------------------------------

      if (apb.PSEL !== expected_psel) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_FAIL",
          $sformatf(
            "PSEL MISMATCH: EXPECTED=%02h ACTUAL=%02h",
            expected_psel, apb.PSEL))

      end

      // -----------------------------------------------------
      // 3. Direction check
      // -----------------------------------------------------

      if (ahb.HWRITE !== apb.PWRITE) begin

        transaction_pass = 1'b0;

        `uvm_error("SB_FAIL",
          $sformatf(
            "DIRECTION MISMATCH: AHB=%0b APB=%0b",
            ahb.HWRITE, apb.PWRITE))

      end

      // -----------------------------------------------------
      // 4. Write checks
      // -----------------------------------------------------

      if (ahb.HWRITE === 1'b1) begin

        if (ahb.HWDATA !== apb.PWDATA) begin

          transaction_pass = 1'b0;

          `uvm_error("SB_FAIL",
            $sformatf(
              "WRITE DATA MISMATCH: AHB=%08h APB=%08h",
              ahb.HWDATA, apb.PWDATA))

        end
        else begin

          `uvm_info("SB_CHECK",
            "WRITE DATA CHECK PASS",
            UVM_LOW)

        end

        if (apb.PSTRB !== expected_pstrb) begin

          transaction_pass = 1'b0;

          `uvm_error("SB_FAIL",
            $sformatf(
              "PSTRB MISMATCH: EXPECTED=%04b ACTUAL=%04b",
              expected_pstrb, apb.PSTRB))

        end
        else begin

          `uvm_info("SB_CHECK",
            "PSTRB CHECK PASS",
            UVM_LOW)

        end

      end

      // -----------------------------------------------------
      // 5. Read checks
      // -----------------------------------------------------

      if (ahb.HWRITE === 1'b0) begin

        if (apb.PSTRB !== 4'b0000) begin

          transaction_pass = 1'b0;

          `uvm_error("SB_FAIL",
            $sformatf(
              "READ PSTRB SHOULD BE ZERO: ACTUAL=%04b",
              apb.PSTRB))

        end
        else begin

          `uvm_info("SB_CHECK",
            "READ PSTRB CHECK PASS",
            UVM_LOW)

        end

        if ((!apb.aborted) &&
            (apb.PSLVERR === 1'b0)) begin

          if (ahb.HRDATA !== apb.PRDATA) begin

            transaction_pass = 1'b0;

            `uvm_error("SB_FAIL",
              $sformatf(
                "READ DATA MISMATCH: AHB=%08h APB=%08h",
                ahb.HRDATA, apb.PRDATA))

          end
          else begin

            `uvm_info("SB_CHECK",
              "READ DATA CHECK PASS",
              UVM_LOW)

          end

        end

      end

      // -----------------------------------------------------
      // 6. Timeout abort check
      // -----------------------------------------------------

      if (apb.aborted === 1'b1) begin

        if (ahb.HRESP !== 1'b1) begin

          transaction_pass = 1'b0;

          `uvm_error("SB_FAIL",
            "TIMEOUT RESPONSE MISMATCH: APB ABORTED BUT AHB HRESP=0")

        end
        else begin

          `uvm_info("SB_CHECK",
            "TIMEOUT CHECK PASS: APB ABORTED AND AHB HRESP=1",
            UVM_LOW)

        end

      end

      // -----------------------------------------------------
      // 7. Normal APB error response check
      // -----------------------------------------------------

      else begin

        if (apb.PSLVERR === 1'b1) begin

          if (ahb.HRESP !== 1'b1) begin

            transaction_pass = 1'b0;

            `uvm_error("SB_FAIL",
              "APB ERROR RESPONSE NOT PROPAGATED TO AHB")

          end

        end
        else if (apb.PSLVERR === 1'b0) begin

          if (ahb.HRESP !== 1'b0) begin

            transaction_pass = 1'b0;

            `uvm_error("SB_FAIL",
              "AHB ERROR WITHOUT APB ERROR")

          end

        end
        else begin

          transaction_pass = 1'b0;

          `uvm_error("SB_FAIL",
            "APB PSLVERR CONTAINS X/Z")

        end

      end

      // -----------------------------------------------------
      // 8. Transaction comparison summary
      // -----------------------------------------------------

      `uvm_info("SB_COMPARE",
        $sformatf(
          "\n====================================================\nTRANSACTION TYPE : %s\n----------------------------------------------------\nSIGNAL       AHB VALUE       APB VALUE\n----------------------------------------------------\nADDRESS      %08h       %08h\nWRITE        %0b               %0b\nWDATA        %08h       %08h\nRDATA        %08h       %08h\nPSEL EXPECTED=%b ACTUAL=%b\nPSTRB EXPECTED=%04b ACTUAL=%04b\nHRESP        %0b               PSLVERR=%0b\n====================================================",
          ahb.HWRITE ? "WRITE" : "READ",
          ahb.HADDR, apb.PADDR,
          ahb.HWRITE, apb.PWRITE,
          ahb.HWDATA, apb.PWDATA,
          ahb.HRDATA, apb.PRDATA,
          expected_psel, apb.PSEL,
          expected_pstrb, apb.PSTRB,
          ahb.HRESP, apb.PSLVERR),
        UVM_LOW)

      // -----------------------------------------------------
      // 9. Final result
      // -----------------------------------------------------

      if (transaction_pass) begin

        pass_count++;

        if (apb.aborted) begin

          `uvm_info("SB_PASS",
            $sformatf(
              "TIMEOUT TRANSACTION PASS: ADDR=%08h",
              ahb.HADDR),
            UVM_LOW)

        end
        else begin

          `uvm_info("SB_PASS",
            $sformatf(
              "TRANSACTION PASS: ADDR=%08h WRITE=%0b",
              ahb.HADDR, ahb.HWRITE),
            UVM_LOW)

        end

      end
      else begin

        fail_count++;

        `uvm_error("SB_FAIL",
          $sformatf(
            "TRANSACTION FAIL: ADDR=%08h WRITE=%0b",
            ahb.HADDR, ahb.HWRITE))

      end

    end

  endfunction


  // ---------------------------------------------------------
  // Final scoreboard report
  // ---------------------------------------------------------
  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info("SB_SUMMARY",
      $sformatf(
        "\n========== SCOREBOARD SUMMARY ==========\nPASS COUNT = %0d\nFAIL COUNT = %0d\nAPB COMPLETIONS AFTER AHB RESET = %0d\n========================================",
        pass_count,
        fail_count,
        apb_after_ahb_reset_count),
      UVM_NONE)

    // Normal unmatched AHB transactions are errors
    if (ahb_q.size() != 0) begin

      `uvm_error("SB_PENDING",
        $sformatf(
          "Unmatched normal AHB transactions: %0d",
          ahb_q.size()))

    end

    // Normal unmatched APB transactions are errors
    if (apb_q.size() != 0) begin

      `uvm_error("SB_PENDING",
        $sformatf(
          "Unmatched normal APB transactions: %0d",
          apb_q.size()))

    end

    // Remaining reset-interrupted AHB transactions are
    // expected when reset occurs before APB request.
    if (ahb_reset_q.size() != 0) begin

      `uvm_info("SB_RESET_SUMMARY",
        $sformatf(
          "AHB transactions interrupted before APB completion: %0d",
          ahb_reset_q.size()),
        UVM_LOW)

    end

  endfunction

endclass


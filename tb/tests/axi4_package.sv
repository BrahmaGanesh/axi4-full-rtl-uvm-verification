//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_package.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.0
// Description : AXI4 UVM package integrating all
//               transaction, sequence, driver, monitor,
//               agent, coverage, scoreboard, environment,
//               and test files for complete verification.
//=====================================================

package axi4_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi4_transaction.sv"
    `include "axi4_sequence.sv"
    `include "axi4_sequencer.sv"
    `include "axi4_driver.sv"
    `include "axi4_monitor.sv"
    `include "axi4_agent.sv"

    `include "axi4_coverage.sv"
    `include "axi4_scoreboard.sv"
    `include "axi4_env.sv"

    `include "axi4_fixed_wr_rd_seq.sv"
    `include "axi4_incr_wr_rd_seq.sv"
    `include "axi4_wrap_wr_rd_seq.sv"
    `include "axi4_error_seq.sv"
    `include "axi4_reset_seq.sv"
    `include "axi4_virtual_seq.sv"

    `include "axi4_base_test.sv"
    `include "axi4_fixed_wr_rd_test.sv"
    `include "axi4_incr_wr_rd_test.sv"
    `include "axi4_wrap_wr_rd_test.sv"
    `include "axi4_error_test.sv"
    `include "axi4_reset_test.sv"
    `include "axi4_virtual_test.sv"
endpackage
//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_fixed_wr_rd_test.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM test implementing FIXED burst mode
//               write and read sequence for AXI4 protocol
//               verification. Instantiates FIXED_sequence
//               and runs it on the sequencer to validate
//               FIXED burst transactions.
//=====================================================

class FIXED_test extends axi4_base_test;
    `uvm_component_utils(FIXED_test)
    FIXED_sequence fixed;
  
    function new(string name = "FIXED_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        fixed = FIXED_sequence::type_id::create("fixed");
    endfunction
  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fixed.start(env.m_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass
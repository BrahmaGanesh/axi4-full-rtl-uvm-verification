//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_incr_wr_rd_test.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM test implementing INCR burst mode
//               write and read sequence for AXI4 protocol
//               verification. Instantiates INCR_sequence
//               and runs it on the sequencer to validate
//               INCR burst transactions.
//=====================================================

class INCR_test extends axi4_base_test;
    `uvm_component_utils(INCR_test)
    INCR_sequence incr;
  
    function new(string name = "INCR_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        incr = INCR_sequence::type_id::create("incr");
    endfunction
  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        incr.start(env.m_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass
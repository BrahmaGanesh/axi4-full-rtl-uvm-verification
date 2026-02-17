//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_wrap_wr_rd_test.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM test implementing WRAP burst mode
//               write and read sequence for AXI4 protocol
//               verification. Instantiates WRAP_sequence
//               and runs it on the sequencer to validate
//               WRAP burst transactions.
//=====================================================

class WRAP_test extends axi4_base_test;
    `uvm_component_utils(WRAP_test)
    WRAP_sequence wrap;
  
    function new(string name = "WRAP_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wrap = WRAP_sequence::type_id::create("wrap");
    endfunction
  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        wrap.start(env.m_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass
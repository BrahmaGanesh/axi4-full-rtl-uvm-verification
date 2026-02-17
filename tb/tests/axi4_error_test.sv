//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_error_test.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM test implementing error sequence for
//               AXI4 protocol verification. Instantiates
//               error_sequence and runs it on the sequencer
//               to validate DUT error response handling for
//               invalid address transactions.
//=====================================================

class error_test extends axi4_base_test;
    `uvm_component_utils(error_test)
    error_sequence err;
  
    function new(string name = "error_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        err = error_sequence::type_id::create("err");
    endfunction
  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        err.start(env.m_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass
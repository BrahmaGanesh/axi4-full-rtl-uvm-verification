//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_reset_test.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM test implementing reset sequence for
//               AXI4 protocol verification. Instantiates
//               reset_sequence and runs it on the sequencer
//               to validate DUT reset handling and recovery
//               across AXI4 channels.
//=====================================================

class reset_test extends axi4_base_test;
    `uvm_component_utils(reset_test)
    reset_sequence rst;
  
    function new(string name = "reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rst = reset_sequence::type_id::create("rst");
    endfunction
  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        rst.start(env.m_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass
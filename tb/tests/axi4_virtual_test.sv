//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_virtual_test.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM virtual test coordinating FIXED,
//               INCR, WRAP, ERROR, and RESET sequences
//               for AXI4 protocol verification. Instantiates
//               axi4_virtual_sequence and runs it on the
//               sequencer to validate combined execution
//               of multiple burst and scenario sequences.
//=====================================================

class axi4_virtual_test extends axi4_base_test;
    `uvm_component_utils(axi4_virtual_test)
    axi4_virtual_sequence vir;
  
    function new(string name = "axi4_virtual_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        vir = axi4_virtual_sequence::type_id::create("vir");
    endfunction
  
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        vir.start(env.m_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass
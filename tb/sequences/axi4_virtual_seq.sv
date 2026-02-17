//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_virtual_seq.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM virtual sequence coordinating FIXED,
//               INCR, WRAP, ERROR, and RESET sequences
//               for AXI4 protocol verification. Ensures
//               combined execution of multiple burst and
//               scenario sequences on the virtual sequencer.
//=====================================================

class axi4_virtual_sequence extends axi4_sequence;
    `uvm_object_utils(axi4_virtual_sequence)
    
    FIXED_sequence fixed;
    INCR_sequence  incr;
    WRAP_sequence  wrap;
    error_sequence error;
    reset_sequence reset;
  
    function new( string name = "axi4_virtual_sequence");
        super.new(name);
    endfunction
  
    task body();

        fixed   = FIXED_sequence::type_id::create("fixed");
        incr    = INCR_sequence::type_id::create("incr");
        wrap    = WRAP_sequence::type_id::create("wrap");
        error   = error_sequence::type_id::create("error");
        reset   = reset_sequence::type_id::create("reset");

        fixed.start(m_sequencer);
        incr.start(m_sequencer);
        wrap.start(m_sequencer);
        error.start(m_sequencer);
        reset.start(m_sequencer);

    endtask
endclass
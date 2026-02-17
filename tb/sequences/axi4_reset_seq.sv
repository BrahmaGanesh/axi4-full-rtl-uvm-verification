//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_reset_seq.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM sequence implementing reset scenario
//               for AXI4 protocol verification. Generates
//               reset transactions to validate DUT reset
//               handling and recovery across channels.
//=====================================================

class reset_sequence extends axi4_sequence;
    `uvm_object_utils(reset_sequence)
    
    axi4_transaction tr;
  
    function new( string name = "reset_sequence");
        super.new(name);
    endfunction
  
    task body();
        tr = axi4_transaction::type_id::create("tr");
        if (!tr.randomize())
            `uvm_error(get_type_name(), "Randomization failed for reset Mode transaction")
        tr.op = RESET;
        start_item(tr);
        finish_item(tr);
    endtask
endclass
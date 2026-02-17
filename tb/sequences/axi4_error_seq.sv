//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_error_seq.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM sequence implementing error scenario
//               transactions for AXI4 protocol verification.
//               Forces invalid address range to trigger
//               error response handling.
//=====================================================

class error_sequence extends axi4_sequence;
    `uvm_object_utils(error_sequence)
    
    axi4_transaction tr;
  
    function new( string name = "error_sequence");
        super.new(name);
    endfunction
  
    task body();
        tr = axi4_transaction::type_id::create("tr");
        if (!tr.randomize() with {AWADDR == 32'hF000_0000;})
            `uvm_error(get_type_name(), "Randomization failed for error Mode transaction")

        tr.op = ERROR;    
        start_item(tr);
        finish_item(tr);
    endtask
endclass
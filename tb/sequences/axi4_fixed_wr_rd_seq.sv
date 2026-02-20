//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_fised_wr_rd_seq.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM sequence implementing FIXED burst
//               mode write and read transactions for
//               AXI4 protocol verification environment.
//=====================================================

class FIXED_sequence extends axi4_sequence;
    `uvm_object_utils(FIXED_sequence)
    
    axi4_transaction tr;
  
    function new( string name = "FIXED_sequence");
        super.new(name);
    endfunction
  
    task body();
        repeat(3) begin
            tr = axi4_transaction::type_id::create("tr");
            if (!tr.randomize() with {AWBURST == 2'b00;})
                `uvm_error(get_type_name(), "Randomization failed for FIXED Mode transaction")
            tr.op = FIXED;
            start_item(tr);
            finish_item(tr);
        end
    endtask
endclass
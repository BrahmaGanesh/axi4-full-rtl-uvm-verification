//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_wrap_wr_rd_seq.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 18-02-2026
// Version     : 1.0
// Description : UVM sequence implementing WRAP burst
//               mode write and read transactions for
//               AXI4 protocol verification environment.
//=====================================================

class WRAP_sequence extends axi4_sequence;
    `uvm_object_utils(WRAP_sequence)
    
    axi4_transaction tr;
  
    function new( string name = "WRAP_sequence");
        super.new(name);
    endfunction
  
    task body();
        repeat(3) begin
            tr = axi4_transaction::type_id::create("tr");
            if (!tr.randomize() with {AWBURST == 2'b10;})
                `uvm_error(get_type_name(), "Randomization failed for WRAP Mode transaction")
            tr.op = WRAP;
            start_item(tr);
            finish_item(tr);
        end
    endtask
endclass
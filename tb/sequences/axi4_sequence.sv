//=====================================================
// Project     : AXI4 Slave RTL
// File        : axi4_sequence.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : UVM sequence class for generating AXI4
//               transactions to drive master stimulus
//               in the verification environment
//=====================================================

class axi4_sequence extends uvm_sequence #(axi4_transaction);
    `uvm_object_utils(axi4_sequence)

    function new ( string name = "axi4_sequence");
        super.new(name);
    endfunction

    virtual task body();
    endtask
endclass
//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_sequencer.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : UVM sequencer class for coordinating
//               axi4_sequence items and driving them
//               into the AXI4 driver in the testbench
//=====================================================

class axi4_sequencer extends uvm_sequencer #(axi4_transaction);
    `uvm_component_utils(axi4_sequencer)

    function new( string name = "axi4_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
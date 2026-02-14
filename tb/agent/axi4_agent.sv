//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_agent.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : UVM agent encapsulating sequencer,
//               driver, and monitor for AXI4 protocol
//               with active/passive configuration
//=====================================================

class axi4_agent extends uvm_agent;
    `uvm_component_utils(axi4_agent)

    axi4_sequencer  seqr;
    axi4_driver     drv;
    axi4_monitor    mon;

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    function new(string name = "axi4_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        seqr    = axi4_sequencer::type_id::create("seqr", this);
        drv     = axi4_driver::type_id::create("drv", this);
        mon     = axi4_monitor::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass
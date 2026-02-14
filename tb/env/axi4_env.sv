//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_env.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : UVM environment encapsulating AXI4 agent
//               and scoreboard, connecting monitor output
//               to scoreboard for protocol checking
//=====================================================

class axi4_env extends uvm_env;
    `uvm_component_utils(axi4_env)

    axi4_agent      m_agent;
    axi4_scoreboard soc;

    function new(string name = "axi4_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_agent  = axi4_agent::type_id::create("m_agent", this);
        soc     = axi4_scoreboard::type_id::create("soc", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_agent.mon.mon_ap.connect(soc.soc_export);
    endfunction
endclass
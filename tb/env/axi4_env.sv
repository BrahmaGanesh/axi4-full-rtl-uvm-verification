//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_env.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.1
// Description : UVM environment encapsulating AXI4 agent,
//               scoreboard, and coverage. Updated check,
//               extract, report, and final phases for
//               improved result tracking and reporting.
//=====================================================

class axi4_env extends uvm_env;
    `uvm_component_utils(axi4_env)

    axi4_agent      m_agent;
    axi4_scoreboard soc;
    axi4_coverage   cov;

    int Total;
    int Pass;
    int Fail;

    function new(string name = "axi4_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_agent = axi4_agent::type_id::create("m_agent", this);
        soc     = axi4_scoreboard::type_id::create("soc", this);
        cov     = axi4_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_agent.mon.mon_ap.connect(soc.soc_export);
        m_agent.mon.mon_ap.connect(cov.cov_export);
    endfunction

    function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        Total = soc.total_reads;
        Pass  = soc.matched_reads;
        Fail  = soc.mismatched_reads;
    endfunction

    function void check_phase(uvm_phase phase);
        if(Fail > 0)
            `uvm_error(get_type_name(),$sformatf("Check Failed : %0d Mismatched detected",Fail))
        else
            `uvm_info(get_type_name(),"Check Passed : no Mismatched ",UVM_LOW)
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("Report",$sformatf("Total Coverage    : %0d",cov.axi4_cg.get_coverage()),UVM_LOW)
        `uvm_info("Report",$sformatf("Total Reads       : %0d",Total),UVM_LOW)
        `uvm_info("Report",$sformatf("Total PASS        : %0d",Pass),UVM_LOW)
        `uvm_info("Report",$sformatf("Total FAIL        : %0d",Fail),UVM_LOW)
    endfunction

    function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("PHASE","Clean up phase.....",UVM_LOW)
    endfunction
endclass
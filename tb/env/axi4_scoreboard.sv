//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_scoreboard.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.0
// Description : UVM scoreboard for AXI4 protocol with
//               burst-aware memory model. Validates
//               DUT read/write data against reference
//               memory for FIXED, INCR, and WRAP bursts,
//               applying WSTRB per beat and tracking
//               pass/fail results with counters.
//=====================================================

class axi4_scoreboard extends uvm_component;
    `uvm_component_utils(axi4_scoreboard)

    uvm_analysis_imp #(axi4_transaction, axi4_scoreboard) soc_export;

    virtual axi4_interface vif;
    axi4_transaction tr;

    bit [7:0] mem [0:4095];
    bit [31:0] r_data;
    int addr;

    int total_reads         = 0;
    int matched_reads       = 0;
    int mismatched_reads    = 0;
    int write_transaction   = 0;
    int reset_transaction   = 0;

    function new(string name = "axi4_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        soc_export = new("soc_export", this);
        tr = axi4_transaction::type_id::create("tr", this);
        if(!uvm_config_db#(virtual axi4_interface)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"virtual interface not set")
    endfunction

    function int calc_addr(input int base_addr,
                           input int beat_index,
                           input [1:0] burst,
                           input [2:0] size,
                           input [7:0] len);
        int addr;
        case (burst)
            2'b00: addr = base_addr;
            2'b01: addr = base_addr + beat_index * (1 << size);
            2'b10: begin 
                int wrap_size = (len+1) * (1 << size);
                addr = (base_addr & ~(wrap_size-1)) | ((base_addr + beat_index*(1<<size)) % wrap_size);
            end
            default: addr = base_addr;
        endcase
        return addr;
    endfunction

    function void write(axi4_transaction tr);
        process_transaction(tr);
    endfunction

    task process_transaction(axi4_transaction tr);
        if(vif.ARESETn == 1'b0) begin
            `uvm_info("[SCO]",$sformatf("Reset = %0d",vif.ARESETn),UVM_LOW);
            reset_transaction++;
            foreach(mem[i]) mem[i] = 0;
            return;
        end

        if(tr.WVALID) begin
            write_transaction++;
            if (tr.AWBURST == 2'b00) begin
                int addr = tr.AWADDR;
                int last = tr.AWLEN;
                if (tr.wstrb[last][0]) mem[addr]   = tr.wdata[last][7:0];
                if (tr.wstrb[last][1]) mem[addr+1] = tr.wdata[last][15:8];
                if (tr.wstrb[last][2]) mem[addr+2] = tr.wdata[last][23:16];
                if (tr.wstrb[last][3]) mem[addr+3] = tr.wdata[last][31:24];
            end else if(tr.AWBURST == 2'b01 || tr.AWBURST == 2'b10) begin
                for (int i = 0; i < tr.AWLEN+1; i++) begin
                    int addr = calc_addr(tr.AWADDR, i, tr.AWBURST, tr.AWSIZE, tr.AWLEN);
                    if (tr.wstrb[i][0]) mem[addr]   = tr.wdata[i][7:0];
                    if (tr.wstrb[i][1]) mem[addr+1] = tr.wdata[i][15:8];
                    if (tr.wstrb[i][2]) mem[addr+2] = tr.wdata[i][23:16];
                    if (tr.wstrb[i][3]) mem[addr+3] = tr.wdata[i][31:24];
                end
            end
        end

        if(tr.RVALID) begin
            if (tr.ARBURST == 2'b00) begin
                int addr = tr.ARADDR;
                int last = tr.ARLEN;
                r_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                total_reads++;
                if (tr.RDATA[last] == r_data) begin
                    matched_reads++;
                    `uvm_info("[SCO]",$sformatf("PASS rdata=%0h <==> mem=%0h",tr.RDATA[last],r_data),UVM_LOW);
                end else begin
                    mismatched_reads++;
                  `uvm_info("[SCO]",$sformatf("FAIL addr=%0h rdata=%0h <==> mem=%0h",addr,tr.RDATA[last],r_data),UVM_LOW);
                end
            end else if(tr.ARBURST == 2'b01 || tr.ARBURST == 2'b10) begin
                for (int i = 0; i < tr.ARLEN+1; i++) begin
                    int addr = calc_addr(tr.ARADDR, i, tr.ARBURST, tr.ARSIZE, tr.ARLEN);
                    r_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                    total_reads++;
                    if (tr.RDATA[i] == r_data) begin
                        matched_reads++;
                        `uvm_info("[SCO]",$sformatf("PASS rdata=%0h <==> mem=%0h",tr.RDATA[i],r_data),UVM_LOW);
                    end else begin
                        mismatched_reads++;
                        `uvm_info("[SCO]",$sformatf("FAIL addr=%0h rdata=%0h <==> mem=%0h",addr,tr.RDATA[i],r_data),UVM_LOW);
                    end
                end
            end
        end
    endtask
    
endclass

//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_monitor.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 15-02-2026
// Version     : 1.0
// Description : UVM monitor for AXI4 protocol capturing
//               transactions across AW, W, B, AR, and R
//               channels. Publishes observed transactions
//               via analysis port for scoreboard checking.
//=====================================================

class axi4_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_monitor)

    virtual axi4_interface vif;
    axi4_transaction tr;

    uvm_analysis_port #(axi4_transaction) mon_ap;

    function new( string name = "axi4_monitor", uvm_component parent = null);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi4_interface)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"virtual interface not set")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
           tr = axi4_transaction::type_id::create("tr", this);

            @(posedge vif.ACLK);
                if (vif.AWVALID && vif.AWREADY) begin
               `uvm_info(get_type_name(),"AW channel handshake detected", UVM_LOW)
                tr.AWADDR  = vif.AWADDR;
                tr.AWBURST = vif.AWBURST;
                tr.AWSIZE  = vif.AWSIZE;
                tr.AWLEN   = vif.AWLEN;
            end

            if (vif.WVALID && vif.WREADY) begin
                `uvm_info(get_type_name(),"W channel handshake detected", UVM_LOW)
                tr.WDATA = vif.WDATA;
                tr.WSTRB = vif.WSTRB;
                tr.WLAST = vif.WLAST;
            end

            if (vif.BVALID && vif.BREADY) begin
                `uvm_info(get_type_name(),"B channel handshake detected", UVM_LOW)
                tr.BRESP = vif.BRESP;
                mon_ap.write(tr);
                `uvm_info(get_type_name(),"Write channel capture completed", UVM_LOW)
            end
          
            @(posedge vif.ACLK);
            if (vif.ARVALID && vif.ARREADY) begin
                `uvm_info(get_type_name(),"AR channel handshake detected", UVM_LOW)
                tr.ARADDR  = vif.ARADDR;
                tr.ARBURST = vif.ARBURST;
                tr.ARSIZE  = vif.ARSIZE;
                tr.ARLEN   = vif.ARLEN;
            end

            if (vif.RVALID && vif.RREADY) begin
                `uvm_info(get_type_name(),"R channel handshake detected", UVM_LOW)
                tr.RDATA =vif.RDATA;
                tr.RRESP = vif.RRESP;

                if (vif.RLAST) begin
                    mon_ap.write(tr);
                    `uvm_info(get_type_name(),"Read transaction capture completed", UVM_LOW)
                end
            end
        end
    endtask
endclass
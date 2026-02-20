//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_monitor.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.1
// Description : UVM monitor for AXI4 protocol with
//               burst-level capture. Records AW, W, B,
//               AR, and R channel activity including
//               VALID/READY handshakes, multi-beat data,
//               and publishes transactions via analysis
//               port for scoreboard checking.
//=====================================================


class axi4_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_monitor)

    virtual axi4_interface vif;
    axi4_transaction tr;

    uvm_analysis_port #(axi4_transaction) mon_ap;

    function new(string name = "axi4_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);

        if(!uvm_config_db#(virtual axi4_interface)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"virtual interface not set")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
          
            tr = axi4_transaction::type_id::create("tr", this);

            @(posedge vif.ACLK);
            tr.AWADDR  = vif.AWADDR;
            tr.AWBURST = vif.AWBURST;
            tr.AWSIZE  = vif.AWSIZE;
            tr.AWLEN   = vif.AWLEN;
          	tr.AWVALID = vif.AWVALID;
          	tr.AWREADY = vif.AWREADY;
          
            if (vif.WVALID && vif.WREADY) begin
                int beat = 0;
                do begin
                    tr.wdata[beat] = vif.WDATA;
                    tr.wstrb[beat] = vif.WSTRB;
                    beat++;
                    @(posedge vif.ACLK);
                end while (!vif.WLAST);
                tr.WLAST  = vif.WLAST;
                tr.WVALID = 1;
                `uvm_info(get_type_name(),"Write burst capture completed", UVM_LOW)
            end

            if (vif.BVALID && vif.BREADY) begin
                `uvm_info(get_type_name(),"B channel handshake detected", UVM_LOW)
                tr.BRESP  = vif.BRESP;
                tr.BREADY = vif.BREADY;
                tr.BVALID = vif.BVALID;
                `uvm_info(get_type_name(),"Write channel capture completed", UVM_LOW)
            end

            tr.ARADDR  = vif.ARADDR;
            tr.ARBURST = vif.ARBURST;
            tr.ARSIZE  = vif.ARSIZE;
            tr.ARLEN   = vif.ARLEN;
          	tr.ARVALID = vif.ARVALID;
          	tr.ARREADY = vif.ARREADY;

            if (vif.RVALID && vif.RREADY) begin
                int beat = 0; 
                @(posedge vif.ACLK);
                forever begin
                    tr.RDATA[beat] = vif.RDATA;
                    tr.RRESP[beat] = vif.RRESP;
                    beat++;
                    if (vif.RLAST) break;
                    @(posedge vif.ACLK);
                end
                tr.RLAST  = vif.RLAST;
                tr.RVALID = 1;
              	tr.RREADY = vif.RREADY;
              	tr.RVALID = vif.RVALID;
                `uvm_info(get_type_name(),"Read burst capture completed", UVM_LOW)
            end
            mon_ap.write(tr);
        end
    endtask
endclass

//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_driver.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.2
// Description : UVM driver for AXI4 protocol handling
//               write and read transactions. Implements
//               reset, phase control, and unified burst
//               mode stimulus generation with improved
//               logging and enum-based operation handling.
//=====================================================

class axi4_driver extends uvm_driver #(axi4_transaction);
    `uvm_component_utils(axi4_driver)

    virtual axi4_interface vif;
    axi4_transaction tr;

    function new ( string name = "axi4_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi4_interface)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"virtual interface not set")
    endfunction

     function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_top.set_report_verbosity_level(UVM_LOW);
        `uvm_info(get_type_name(), "Start of Simulation...", UVM_LOW)
    endfunction

    task pre_reset_phase(uvm_phase phase);
        super.pre_reset_phase(phase);
         `uvm_info("PHASE", "Preparing reset...", UVM_LOW)
    endtask

    task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        phase.raise_objection(this, "driver reset");
            reset_dut();
        phase.drop_objection(this, "driver reset");
    endtask

    task post_reset_phase(uvm_phase phase);
        super.post_reset_phase(phase);
        `uvm_info("PHASE", "Reset Completed...", UVM_LOW)
    endtask

    task run_phase(uvm_phase phase);
        @(posedge vif.ARESETn);
        forever begin
            seq_item_port.get_next_item(tr);
            if(tr.op == RESET) begin
                reset_dut();
            end
            else begin
                write($sformatf("%s", tr.op.name()));
                read($sformatf("%s", tr.op.name()));
            end
            seq_item_port.item_done();
        end
    endtask

    task reset_dut();
        vif.ARESETn <= 0;
            
        vif.AWADDR  <= 0;
        vif.AWBURST <= 0;
        vif.AWSIZE  <= 0;
        vif.AWLEN   <= 0;
      	vif.AWVALID <= 0;
            
        vif.WDATA   <= 0;
        vif.WSTRB   <= 0;
        vif.WLAST   <= 0;
        vif.WVALID  <= 0;

            
        vif.BREADY <= 0;
            
        vif.ARADDR  <= 0;
        vif.ARBURST <= 0;
        vif.ARSIZE  <= 0;
        vif.ARLEN   <= 0;
        vif.ARVALID <= 0;

        vif.RREADY <= 0;
        #40;
        vif.ARESETn <= 1;
        `uvm_info("PHASE", "Reset applied...", UVM_LOW)
    endtask
  
    task write(input string mode);
        @(posedge vif.ACLK);
        `uvm_info(get_type_name(),$sformatf(" %s Mode write transaction Start.....",mode), UVM_LOW)
        vif.AWVALID <= 1;
        vif.AWADDR  <= tr.AWADDR;
        vif.AWBURST <= tr.AWBURST;
        vif.AWSIZE  <= tr.AWSIZE;
        vif.AWLEN   <= tr.AWLEN;
        wait(vif.AWREADY);
        @(posedge vif.ACLK);
        vif.AWVALID <= 0;
      
        for (int i = 0; i <= tr.AWLEN; i++) begin
            vif.WVALID <= 1;
            vif.WDATA  <= tr.WDATA + i;
            vif.WSTRB  <= 4'b1111;
            vif.WLAST  <= (i == tr.AWLEN);
            wait(vif.WREADY && vif.WVALID);
            @(posedge vif.ACLK);
        end
        vif.WVALID <= 0;
        vif.WLAST  <= 0;

        vif.BREADY <= 1;
        wait(vif.BVALID);
        @(posedge vif.ACLK);
        vif.BREADY <= 0;
        `uvm_info(get_type_name(),$sformatf(" %s Mode write transaction Completed.....",mode), UVM_LOW)
  	endtask
    
    task read(input string mode);
        @(posedge vif.ACLK);
        `uvm_info(get_type_name(),$sformatf(" %s Mode Read transaction Start.....",mode), UVM_LOW)
        vif.ARVALID <= 1;
        vif.ARADDR  <= tr.AWADDR;
        vif.ARBURST <= tr.AWBURST;   
        vif.ARSIZE  <= tr.AWSIZE;  
        vif.ARLEN   <= tr.AWLEN;       
        wait(vif.ARREADY);
        @(posedge vif.ACLK);
        vif.ARVALID <= 0;
        
        @(posedge vif.ACLK);
        vif.RREADY <= 1;
        do begin
            wait(vif.RVALID);
            @(posedge vif.ACLK);
        end while (!vif.RLAST);
        vif.RREADY <= 0;
        `uvm_info(get_type_name(),$sformatf(" %s Mode Read transaction Completed.....",mode), UVM_LOW)
    endtask

endclass
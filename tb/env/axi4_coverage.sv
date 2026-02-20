//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_coverage.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.0
// Description : UVM coverage component for AXI4 protocol.
//               Captures burst types, address ranges,
//               lengths, sizes, BRESP, RRESP, and key
//               handshake signals. Ensures functional
//               coverage across legal and error scenarios.
//=====================================================

class axi4_coverage extends uvm_component;
    `uvm_component_utils(axi4_coverage)
  
    uvm_analysis_imp #(axi4_transaction, axi4_coverage) cov_export;
    axi4_transaction tr;
  
    function new(string name = "axi4_coverage", uvm_component parent = null);
        super.new(name, parent);
        
        cov_export = new("cov_export",this);
        axi4_cg = new();
    endfunction
  
    function write(axi4_transaction tr);
        this.tr = tr;
        foreach(tr.RRESP[i]) begin
            tr.last_RRESP = tr.RRESP[i];
            axi4_cg.sample();
        end
    endfunction
  
    covergroup axi4_cg;
    
        coverpoint tr.AWBURST{
                        bins fixed = {2'b00};
                        bins incr  = {2'b01};
                        bins wrap  = {2'b10};
                        ignore_bins error = {2'b11};
                    }

        coverpoint tr.AWADDR {
                        bins b1 = {[0:4095]};
                        bins b2 = {[4096:$]};
                    }

        coverpoint tr.AWLEN {
                        bins len_all = {[0:15]};
                    }

        coverpoint tr.AWSIZE {
                        bins legal = {3'b010};
                        bins ilegal = {[0:7]} with (item != 3'b010);
                    }

        coverpoint tr.BRESP { 
                        bins OKAY = {2'b00}; 
                        bins SLVERR = {2'b10}; 
                    }

        coverpoint tr.last_RRESP {
                        bins OKAY   = {2'b00};
                        bins SLVERR = {2'b10};
                    }

        coverpoint tr.AWVALID;
        coverpoint tr.WVALID;
        coverpoint tr.ARVALID;
        coverpoint tr.RREADY;
        coverpoint tr.RLAST;
        coverpoint tr.WLAST;
  endgroup
  
endclass
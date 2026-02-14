//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_txn.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : UVM sequence item representing AXI4
//               transactions across AW, W, B, AR, R
//               channels for verification environment
//=====================================================

class axi4_transaction extends uvm_sequence_item;

    rand bit [31:0] AWADDR;
	rand bit [7:0]  AWLEN;
	rand bit [2:0]  AWSIZE;
	rand bit [1:0]  AWBURST;
  
  	rand bit [31:0] WDATA;
    rand bit [3:0]  WSTRB;
    rand bit        WLAST;
  
  	rand bit [31:0] ARADDR; 
	rand bit [7:0]  ARLEN;
	rand bit [2:0]  ARSIZE;
	rand bit [1:0]  ARBURST;

    	 bit [31:0] RDATA;
         bit [1:0]  RRESP;
         bit        RLAST;
  		
  		 bit [1:0]  BRESP;

    `uvm_object_utils_begin(axi4_transaction)
        `uvm_field_int(AWADDR, UVM_ALL_ON)
        `uvm_field_int(AWLEN, UVM_ALL_ON)
        `uvm_field_int(AWSIZE, UVM_ALL_ON)
        `uvm_field_int(AWBURST, UVM_ALL_ON)
        `uvm_field_int(WDATA, UVM_ALL_ON)
        `uvm_field_int(WSTRB, UVM_ALL_ON)
        `uvm_field_int(WLAST, UVM_ALL_ON)
        `uvm_field_int(BRESP, UVM_ALL_ON)
        `uvm_field_int(ARADDR, UVM_ALL_ON)
        `uvm_field_int(ARLEN, UVM_ALL_ON)
        `uvm_field_int(ARSIZE, UVM_ALL_ON)
        `uvm_field_int(ARBURST, UVM_ALL_ON)
        `uvm_field_int(RDATA, UVM_ALL_ON)
        `uvm_field_int(RLAST, UVM_ALL_ON)
        `uvm_field_int(RRESP, UVM_ALL_ON)
    `uvm_object_utils_end

    function new( string name = "axi4_transaction");
        super.new(name);
    endfunction

endclass
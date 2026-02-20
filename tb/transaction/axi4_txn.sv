//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_txn.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.2
// Description : UVM sequence item representing AXI4
//               transactions across AW, W, B, AR, R
//               channels. Updated enum definition and
//               refined constraints for alignment,
//               burst length, and memory depth.
//=====================================================

typedef enum bit [2:0] {FIXED=0,INCR=1, WRAP=2,RESET=3,ERROR=4} operation_t;

class axi4_transaction extends uvm_sequence_item;

    operation_t op;

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
  
         bit [31:0] wdata [0:255];
         bit [31:0] wstrb [0:255];

         bit [31:0] RDATA [0:255];
         bit [1:0]  RRESP[0:255];
         bit        RLAST;
  		
  		 bit [1:0]  BRESP;
  		 bit [1:0] last_RRESP;

         bit        AWVALID;
         bit        AWREADY;
         bit        WVALID;
         bit        WREADY;
         bit        BVALID;
         bit        BREADY;
         bit        ARVALID;
         bit        ARREADY;
         bit        RVALID;
         bit        RREADY;
  
    constraint word_size_c {
        AWSIZE == 3'b010;
        }
    constraint burst_length_c {
        AWLEN inside {[0 : 15]};
        }
    constraint address_range_c {
        soft AWADDR inside {[32'h0000_0000 : 32'h0000_FFFF]};
        }
    constraint alignment_and_boundary_c {
      AWADDR % ((AWLEN+1) * (1 << AWSIZE)) == 0;
        (AWADDR[11:0] + ((AWLEN + 1) << AWSIZE)) <= 4090;
        }
    constraint memory_depth_c {
        soft (AWADDR >> $clog2(32/8)) < 256;
        }

    `uvm_object_utils_begin(axi4_transaction)
        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
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
        `uvm_field_int(RLAST, UVM_ALL_ON)
    `uvm_object_utils_end

    function new( string name = "axi4_transaction");
        super.new(name);
    endfunction

endclass
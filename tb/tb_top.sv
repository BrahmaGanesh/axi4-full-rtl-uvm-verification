//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : tb_top.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : Top-level testbench instantiating AXI4
//               interface, DUT, clock/reset generation,
//               waveform dump, and UVM run_test()
//=====================================================

`include "axi4_interface.sv"
`include "axi4_package.sv"

module tb;
  
  import axi4_pkg::*;
  
  localparam ADDR_WIDTH = 32;
  localparam DATA_WIDTH = 32;
  localparam DEPTH 		= 256;
  
  axi4_interface #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH)) vif();
  
  axi_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (.ACLK(vif.ACLK),
    .ARESETn(vif.ARESETn),
    .AWADDR(vif.AWADDR),
    .AWLEN(vif.AWLEN),
    .AWSIZE(vif.AWSIZE),
    .AWBURST(vif.AWBURST),
    .AWVALID(vif.AWVALID),
    .AWREADY(vif.AWREADY),
    .WDATA(vif.WDATA),
    .WSTRB(vif.WSTRB),
    .WLAST(vif.WLAST),
    .WVALID(vif.WVALID),
    .WREADY(vif.WREADY),
    .BRESP(vif.BRESP),
    .BVALID(vif.BVALID),
    .BREADY(vif.BREADY),
    .ARADDR(vif.ARADDR),
    .ARLEN(vif.ARLEN),
    .ARSIZE(vif.ARSIZE),
    .ARBURST(vif.ARBURST),
    .ARVALID(vif.ARVALID),
    .ARREADY(vif.ARREADY),
    .RDATA(vif.RDATA),
    .RLAST(vif.RLAST),
    .RVALID(vif.RVALID),
    .RREADY(vif.RREADY),
    .RRESP(vif.RRESP)
  );
  
  initial begin
    vif.ACLK = 0;
    forever #5 vif.ACLK = ~vif.ACLK;
  end
  
  initial begin
      $dumpfile("waveform.vcd");
    	$dumpvars(0,tb);
    end
  
  initial begin
    uvm_config_db#(virtual axi4_interface)::set(null,"*","vif",vif);
    run_test();
  end
endmodule
  
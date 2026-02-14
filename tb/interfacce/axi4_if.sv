//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_if.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : AXI4 interface definition for connecting
//               master and slave modules, including
//               all channel signals (AW, W, B, AR, R)
//=====================================================

interface axi4_interface #(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32
);
    logic   ACLK;
    logic   ARESETn;

    logic   [ADDR_WIDTH - 1 : 0] AWADDR;
    logic   [1:0]                AWBURST;
    logic   [2:0]                AWSIZE;
    logic   [7:0]                AWLEN;
    logic                        AWREADY;
    logic                        AWVALID;

    logic   [DATA_WIDTH - 1 : 0] WDATA;
    logic   [DATA_WIDTH/8 -1 :0] WSTRB;
    logic                        WLAST;
    logic                        WREADY;
    logic                        WVALID;

    logic   [1:0]                BRESP;
    logic                        BREADY;
    logic                        BVALID;

    logic   [ADDR_WIDTH -1 : 0]  ARADDR;
  	logic   [1:0]                ARBURST;
  	logic   [2:0]                ARSIZE;
  	logic   [7:0]                ARLEN;
    logic                        ARREADY;
    logic                        ARVALID;

    logic   [DATA_WIDTH - 1 : 0] RDATA;
    logic                        RLAST;
    logic                        RREADY;
    logic                        RVALID;
    logic   [1:0]                RRESP;

endinterface
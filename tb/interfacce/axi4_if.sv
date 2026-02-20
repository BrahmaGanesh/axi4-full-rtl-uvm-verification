//=====================================================
// Project     : AXI4 UVM VERIFICATION
// File        : axi4_if.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 20-02-2026
// Version     : 1.1
// Description : AXI4 interface with protocol assertions
//               and cover properties for handshake,
//               burst alignment, response validity,
//               and address alignment.
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
    logic 	[7:0]				 beat_cnt;
  
  

    property aw_handshake;
        @(posedge ACLK) disable iff (!ARESETn)
        AWVALID |-> AWREADY;
    endproperty
    assert_aw_handshake: assert property (aw_handshake)
    else $error("AW channel handshake failed");
    cover property (aw_handshake);

    property wlast_check;
        @(posedge ACLK) disable iff (!ARESETn)
        (WVALID && WREADY && WLAST) |-> (beat_cnt  == AWLEN);
    endproperty
    assert_wlast_check: assert property (wlast_check)
    else $error("WLAST not aligned with AWLEN");
    cover property (wlast_check);

    property bresp_valid;
        @(posedge ACLK) disable iff (!ARESETn)
        BVALID |-> (BRESP inside {2'b00, 2'b01, 2'b10, 2'b11});
    endproperty
    assert_bresp_valid: assert property (bresp_valid)
    else $error("Invalid BRESP value detected");
    cover property (bresp_valid);

    property rlast_check;
        @(posedge ACLK) disable iff (!ARESETn)
        (RVALID && RREADY && RLAST) |-> (beat_cnt == ARLEN);
    endproperty
    assert_rlast_check: assert property (rlast_check)
    else $error("RLAST not aligned with ARLEN");
    cover property (rlast_check);

    property addr_alignment;
        @(posedge ACLK) disable iff (!ARESETn)
        AWVALID |-> (AWADDR % (1 << AWSIZE) == 0);
    endproperty
    assert_addr_alignment: assert property (addr_alignment)
    else $error("AWADDR not aligned to AWSIZE");
    cover property (addr_alignment);

endinterface
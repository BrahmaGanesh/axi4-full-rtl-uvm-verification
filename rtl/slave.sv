//=====================================================
// Project     : AXI4 Slave RTL
// File        : slave.sv
// Author      : Brahma Ganesh Katrapalli
// Date        : 14-02-2026
// Version     : 1.0
// Description : AXI4-compliant slave module with
//               write/read channel handling,
//               burst support, and error checks
//=====================================================

module axi_slave #(
    parameter ADDR_WIDTH = 32 ,
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 256
    )(
       input    logic                       ACLK,
       input    logic                       ARESETn,
       
       input    logic [ADDR_WIDTH - 1 :0]   AWADDR,
       input    logic [7:0]                 AWLEN,
       input    logic [2:0]                 AWSIZE,
       input    logic [1:0]                 AWBURST,
       input    logic                       AWVALID,
       output   logic                       AWREADY,
       
       input    logic [DATA_WIDTH - 1 :0]   WDATA,
       input    logic [(DATA_WIDTH/8)-1:0]  WSTRB,
       input    logic                       WLAST,
       input    logic                       WVALID,
       output   logic                       WREADY,
       
       output   logic [1:0]                 BRESP,
       output   logic                       BVALID,
       input    logic                       BREADY,

       input    logic [ADDR_WIDTH - 1 :0]   ARADDR,
       input    logic [7:0]                 ARLEN,
       input    logic [2:0]                 ARSIZE,
       input    logic [1:0]                 ARBURST,
       input    logic                       ARVALID,
       output   logic                       ARREADY,

       output    logic [DATA_WIDTH - 1 :0]   RDATA,
       output    logic                       RLAST,
       output    logic                       RVALID,
       input     logic                       RREADY,
       output   logic [1:0]                  RRESP
    );

    logic [DATA_WIDTH - 1 :0] mem [0:DEPTH - 1];
    
    logic [ADDR_WIDTH - 1 :0] wr_addr_reg,wr_next_addr_reg;
    logic [ADDR_WIDTH - 1 :0] rd_addr_reg;
    logic [7:0] wr_len_reg, rd_len_reg;
    logic [2:0] wr_size_reg, rd_size_reg;
    logic [1:0] wr_burst_reg, rd_burst_reg;
    logic [7:0] wr_beat_cnt, rd_beat_cnt;
    logic [ADDR_WIDTH - 1 :0] wr_wrap_boundary_reg, rd_wrap_boundary_reg;
  	
  	logic wr_error_flag, rd_error_flag;

    typedef enum logic [1:0] { 
        W_IDLE,
        W_TRANSFER,
      	W_ERROR,
        B_RESP
        } wr_state_t;
    
    typedef enum logic [1:0] {
        R_IDLE,
        R_TRANSFER,
      	R_ERROR
        } rd_state_t;
    
    wr_state_t wr_state;
    rd_state_t rd_state;

    function automatic [ADDR_WIDTH - 1 : 0] next_addr;
        input [ADDR_WIDTH - 1 : 0] curr;
        input [1:0] burst;
        input [2:0] size;
        input [ADDR_WIDTH - 1 : 0] wrap_bound;
        input [7:0] len;

        begin
            case(burst)
                2'b00 : next_addr = curr;
                2'b01 : next_addr = curr + (1 << size);
                2'b10 : begin
                            if((curr + (1 << size)) >= (wrap_bound + wrap_base(len, size)))
                                next_addr = wrap_bound;
                            else
                                next_addr = curr + (1 << size);
                        end
                default : next_addr = curr;
            endcase
        end
    endfunction

    function automatic int wrap_base(input [7:0] len,input [2:0] size);
        wrap_base = (len + 1) * (1 << size);
    endfunction

    function automatic [ADDR_WIDTH -1 : 0] wrap_boundary;
        input [ADDR_WIDTH - 1 : 0 ] addr;
        input [7:0] len;
        input [2:0] size;
        int base;
        base = wrap_base(len,size);
        wrap_boundary = (addr/base) * base;
    endfunction

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) begin
            wr_state        <= W_IDLE;
            AWREADY         <= 0;
            WREADY          <= 0;
            BVALID          <= 0;
          	BRESP           <= 2'b00;
            wr_len_reg      <= 0;
            wr_size_reg     <= 0;
            wr_burst_reg    <=0;
            wr_beat_cnt     <= 0;
            wr_addr_reg     <= 0;
            wr_next_addr_reg <= 0;
        end
        else begin
            AWREADY <= 0;
            WREADY  <= 0;
            BRESP   <= BRESP;
            BVALID  <= BVALID;

            case(wr_state)
                W_IDLE          :   begin
                                        AWREADY <= 1;
                                        WREADY  <= 0;
                                        BVALID  <= 0;
                                        wr_error_flag = 0;

                                        if(AWVALID && AWREADY) begin

                                          if(AWADDR % (1 << AWSIZE) != 0) 
                                            wr_error_flag = 1;
                                            if (AWBURST == 2'b11) wr_error_flag = 1;
                                            if ((AWADDR[11:0] + ((AWLEN+1) << AWSIZE)) > 12'hFFF) begin
                                                BRESP   <= 2'b10;
                                                BVALID  <= 1;
                                                AWREADY <= 0;
                                                WREADY  <= 0;
                                                wr_state <= W_ERROR;
                                            end
                                            if ((AWADDR >> $clog2(DATA_WIDTH/8)) >= DEPTH) begin
                                                BRESP   <= 2'b10;
                                                BVALID  <= 1;
                                                AWREADY <= 0;
                                                WREADY  <= 0;
                                                wr_error_flag <= 1;
                                                wr_state <= W_ERROR;
                                            end
                                            if (AWSIZE > $clog2(DATA_WIDTH)) wr_error_flag = 1;
                                            if(!wr_error_flag)begin
                                            
                                                wr_addr_reg <= AWADDR;
                                                wr_next_addr_reg <= AWADDR;
                                                wr_burst_reg    <= AWBURST;
                                                wr_len_reg      <= AWLEN;
                                                wr_size_reg     <= AWSIZE;
                                                wr_beat_cnt     <= AWLEN + 1;
                                                wr_wrap_boundary_reg <= wrap_boundary(AWADDR,AWLEN,AWSIZE);

                                                AWREADY <= 0;
                                                WREADY  <= 1;
                                                wr_state <= W_TRANSFER;
                                            end
                                            else begin
                                                BRESP   <= 2'b10;
                                                BVALID  <= 1;
                                                AWREADY <= 0;
                                                WREADY  <= 0;
                                                wr_state <= W_ERROR;
                                            end
                                        end
                                    end
                W_TRANSFER   :   begin
                   WREADY <= 1;
                                    if(WVALID && WREADY) begin
                                       
                                        for(int i=0; i< DATA_WIDTH/8; i++) begin

                                            if(WSTRB[i])
                                                mem[wr_next_addr_reg >> $clog2(DATA_WIDTH/8)][8*i +: 8] <= WDATA[8*i +: 8];
                                        end
                                        wr_next_addr_reg <= next_addr(wr_next_addr_reg, wr_burst_reg, wr_size_reg, wr_wrap_boundary_reg, wr_len_reg);
                                        wr_beat_cnt <= wr_beat_cnt - 1;
                                        
                                        if(WLAST && wr_beat_cnt == 1)begin
                                            BRESP       <= 2'b00;
                                            WREADY      <= 0;
                                            BVALID      <= 1;
                                            wr_state    <= B_RESP;
                                        end 
                                        else if(WLAST && wr_beat_cnt > 1)begin
                                            BRESP       <= 2'b10;
                                            WREADY      <= 0;
                                            BVALID      <= 1;
                                            wr_state    <= B_RESP;
                                        end
                                        else if(!WLAST && wr_beat_cnt == 1)begin
                                            BRESP   <= 2'b10;
                                            WREADY  <= 0;
                                            BVALID  <= 1;
                                            wr_state <= B_RESP;
                                        end
                                    end
                                end
              W_ERROR		: 	begin
                					WREADY <= 0;
                                    if(BVALID && BREADY) begin
                  	                    BVALID <= 0;
                	                    wr_state <= W_IDLE;
                                    end
              					end
                B_RESP      :   begin
                                    if(BVALID && BREADY) begin
                                        wr_state    <= W_IDLE;
                                        BVALID      <= 0;
                                    end
                                end
                endcase
        end
    end

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn)begin
            rd_state        <= R_IDLE;
            ARREADY         <= 0;
            RVALID          <= 0;
          	RRESP 			<= 2'b00;
          	RLAST			<= 0;
            rd_len_reg      <= 0;
            rd_size_reg     <= 0;
            rd_burst_reg    <=0;
            rd_beat_cnt     <= 0;
            rd_addr_reg     <= 0;
          	rd_error_flag	<= 0;
        end
        else begin
            ARREADY <= 0;
            RVALID  <= RVALID;
            RRESP   <= RRESP;
            RLAST   <= 0;

            case(rd_state)
                R_IDLE      :   begin
                                    ARREADY <= 1;
                                    rd_error_flag	<= 0;
                                    if( ARVALID && ARREADY) begin
                                        if (ARADDR % (1 << ARSIZE) != 0) rd_error_flag = 1;
                                        if (ARBURST == 2'b11) rd_error_flag = 1;
                                        if ((ARADDR[11:0] + ((ARLEN+1) << ARSIZE)) > 12'hFFF) begin
                                            RRESP   <= 2'b10; 
                                            RVALID  <= 1;
                                            RLAST   <= 1;
                                            ARREADY <= 0;
                                            rd_state <= R_ERROR;
                                        end
                                        if ((ARADDR >> $clog2(DATA_WIDTH/8)) >= DEPTH) begin
                                            RRESP   <= 2'b10;
                                            RVALID  <= 1;
                                            ARREADY <= 0;
                                            rd_state <= R_ERROR;
                                        end
                                        if (ARSIZE > $clog2(DATA_WIDTH)) rd_error_flag = 1;
                                        if(!rd_error_flag) begin
                                            rd_addr_reg     <= ARADDR;
                                            rd_len_reg      <= ARLEN;
                                            rd_size_reg     <= ARSIZE;
                                            rd_burst_reg    <= ARBURST;
                                            rd_beat_cnt     <= ARLEN + 1;
                                            rd_wrap_boundary_reg <= wrap_boundary(ARADDR, ARLEN, ARSIZE);

                                            RVALID      <= 1;
                                            rd_state    <= R_TRANSFER;
                                        end
                                        else begin
                                            RRESP       <= 2'b10;
                                            RVALID      <= 1;
                                            ARREADY     <= 0;
                                            rd_state    <= R_ERROR;
                                        end
                                    end
                                end
                R_TRANSFER  :   begin
                                    ARREADY <= 0;
                                    RDATA   <= mem[rd_addr_reg >> $clog2(DATA_WIDTH/8)];

                                    if(RVALID && RREADY) begin
                                        rd_addr_reg <= next_addr(rd_addr_reg, rd_burst_reg, rd_size_reg, rd_wrap_boundary_reg, rd_len_reg); 
                                        rd_beat_cnt <= rd_beat_cnt - 1;
                                        RLAST   <= (rd_beat_cnt == 1);
                                    end

                                    
                                    if(RVALID && RREADY && RLAST) begin
                                        rd_state    <= R_IDLE;
                                        RVALID      <= 0;
                                        RRESP       <= 2'b00;
                                    end
                                end
              R_ERROR		:	begin
              					    if(RVALID && RREADY) begin
      									rd_beat_cnt <= rd_beat_cnt - 1;
      									RLAST <= (rd_beat_cnt == 1);
      									if(RLAST) begin
         									RVALID <= 0;
         									rd_state <= R_IDLE;
      									end
                                    end
              					end
            endcase
        end
    end
endmodule
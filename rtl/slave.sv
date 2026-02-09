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
       input    logic                       BREADY
    );

    logic [DATA_WIDTH - 1 :0] mem [0:DEPTH - 1];
    
    logic [ADDR_WIDTH - 1 :0] addr_reg,next_addr_reg;
    logic [7:0] len_reg;
    logic [2:0] size_reg;
    logic [1:0] burst_reg;
    logic [7:0] beat_cnt;
    logic [ADDR_WIDTH - 1 :0] wrap_boundary_reg;

    typedef enum logic [1:0] { 
        IDLE,
        W_TRANSFER,
        B_RESP
        } wr_state_t;
    
    wr_state_t wr_state;

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
            wr_state <= IDLE;
            AWREADY <= 0;
            WREADY  <= 0;
            BVALID  <= 0;
            len_reg <= 0;
            size_reg <= 0;
            burst_reg <=0;
            beat_cnt <= 0;
            addr_reg <= 0;
            next_addr_reg <= 0;
        end
        else begin

            case(wr_state)
                IDLE        :   begin
                                    AWREADY <= 1;
                                    WREADY  <= 0;
                                    BVALID  <= 0;
                                    if(AWVALID && AWREADY) begin
                                        addr_reg <= AWADDR;
                                        next_addr_reg <= AWADDR;
                                        burst_reg <= AWBURST;
                                        len_reg <= AWLEN;
                                        size_reg <= AWSIZE;
                                        beat_cnt <= AWLEN + 1;
                                        wrap_boundary_reg <= wrap_boundary(AWADDR,AWLEN,AWSIZE);

                                        AWREADY <= 0;
                                        WREADY  <= 1;
                                        wr_state <= W_TRANSFER;
                                    end
                                end
                W_TRANSFER   :   begin
                                    if(WVALID && WREADY) begin
                                       
                                        for(int i=0; i< DATA_WIDTH/8; i++) begin
                                            if(WSTRB[i])
                                                mem[next_addr_reg >> $clog2(DATA_WIDTH/8)][8*i +: 8] <= WDATA[8*i +: 8];

                                        end
                                        next_addr_reg <= next_addr(next_addr_reg,burst_reg,size_reg,wrap_boundary_reg,len_reg);
                                        beat_cnt <= beat_cnt - 1;
                                        if(WLAST && beat_cnt == 1)begin
                                            BRESP   <= 2'b00;
                                            WREADY <= 0;
                                            BVALID <= 1;
                                            wr_state <= B_RESP;
                                        end 
                                        else if(WLAST && beat_cnt > 1)begin
                                            BRESP   <= 2'b10;
                                            WREADY <= 0;
                                            BVALID <= 1;
                                            wr_state <= B_RESP;
                                        end
                                        else if(!WLAST && beat_cnt == 1)begin
                                            BRESP   <= 2'b10;
                                            WREADY <= 0;
                                            BVALID <= 1;
                                            wr_state <= B_RESP;
                                        end
                                    end
                                end
                B_RESP      :   begin
                                    if(BVALID && BREADY) begin
                                        wr_state <= IDLE;
                                        BVALID <= 0;
                                    end
                                end
                endcase
        end
    end
endmodule
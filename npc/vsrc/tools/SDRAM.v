
//state of read addr
`define READ_ADDR_INIT          2'b01
`define READ_ADDR_SEND          2'b10

//state of read data
`define READ_DATA_WAIT          3'b001
`define READ_DATA_RECV_INST     3'b010
`define READ_DATA_RECV_DATA     3'b100

//state of write addr
`define WRITE_ADDR_WAIT           2'b01
`define WRITE_ADDR_SEND           2'b10

//state of write data
`define WRITE_DATA_WAIT           2'b01
`define WRITE_DATA_SEND           2'b10

//state of write response
`define WRITE_RES_WAIT          2'b01
`define WRITE_RES_RECV          2'b10

module SDRAM (
    input  wire clk,
    input  wire rst,
    /*
    input  wire        is_loaddata,
    output wire        recv_data,
    output wire        recv_inst,
    input  wire [63:0] pc,
    output wire [31:0] inst,*/

    //read addr
    input  wire [31:0] araddr,
    input  wire        arvalid,
    output wire        arready,
    input  wire [ 7:0] arlen,
    input  wire [ 2:0] arsize,
    input  wire [ 1:0] arburst,
    //read data
    output wire [63:0] rdata,
    output wire [ 1:0] rresp,
    output wire        rvalid,
    output wire        rlast,
    input  wire        rready,

    //write addr
    input  wire [31:0] awaddr,
    input  wire        awvalid,
    output wire        awready,
    input  wire [ 7:0] awlen,
    input  wire [ 2:0] awsize,
    input  wire [ 1:0] awburst,
    //write data
    input  wire [63:0] wdata,
    input  wire [ 7:0] wstrb,
    input  wire        wlast,
    input  wire        wvalid,
    output wire        wready,

    //write response
    output wire [ 1:0] bresp,
    output wire        bvalid,
    input  wire        bready
);

    reg  [1 :0] read_addr_state;
    reg  [1 :0] read_addr_nstate;
    reg  [63:0] pc_reg;
    reg  [31:0] araddr_reg;
    reg  [ 7:0] arlen_reg;
    reg  [ 2:0] arsize_reg;
    reg  [ 1:0] arburst_reg;
    
    always @(posedge clk) begin
        if(rst) begin
            read_addr_state <= `READ_ADDR_INIT;
        end else begin
            read_addr_state <= read_addr_nstate;
        end
    end

    // read_addr state change
    always @(*) begin
        case(read_addr_state)
            `READ_ADDR_INIT:
                if(arvalid) begin
                    read_addr_nstate = `READ_ADDR_SEND;
                end else begin
                    read_addr_nstate = `READ_ADDR_INIT;
                end
            `READ_ADDR_SEND:
                read_addr_nstate = `READ_ADDR_INIT;
            default:
                read_addr_nstate = `READ_ADDR_INIT;
        endcase
    end

    always @(posedge clk)begin
        if(arvalid & arready) begin
            //pc_reg     <= pc;
            araddr_reg <= araddr;
            arlen_reg  <= arlen;
            arsize_reg <= arsize;
            arburst_reg<= arburst;
        end
    end
    assign arready = (read_addr_state == `READ_ADDR_INIT); //?

    //read data
    reg  [2 :0] read_data_state;
    reg  [2 :0] read_data_nstate;
    
    always@(posedge clk) begin
        if(rst) begin
            read_data_state <= `READ_DATA_WAIT;
        end
        else begin
            read_data_state <= read_data_nstate;
        end
    end

    //read_ready state change
    always@(*) begin
        case(read_data_state)
        `READ_DATA_WAIT:
            if(arvalid & arready) begin
                read_data_nstate = `READ_DATA_RECV_INST;
            end
            else begin
                read_data_nstate = `READ_DATA_WAIT;
            end
        `READ_DATA_RECV_INST:
            /*if(rready && rlast && is_loaddata) begin
                read_data_nstate = `READ_DATA_RECV_DATA;
            end 
            else*/if(rready && rlast) begin
                read_data_nstate = `READ_DATA_WAIT;
            end
            else begin
                read_data_nstate = `READ_DATA_RECV_INST;
            end
        `READ_DATA_RECV_DATA:
            if(rready && rlast) begin
                read_data_nstate = `READ_DATA_WAIT;
            end 
            else begin
                read_data_nstate = `READ_DATA_RECV_DATA;
            end
        default:
            read_data_nstate = `READ_DATA_WAIT;
        endcase
    end

    //assign recv_inst = (read_data_state == `READ_DATA_RECV_INST); 
    //assign recv_data = (read_data_state == `READ_DATA_RECV_DATA); 
    assign rvalid = (read_data_state == `READ_DATA_RECV_INST) || (read_data_state == `READ_DATA_RECV_DATA); 
    assign rresp = 2'b0;


    reg [7:0] rcnt;
    always @(posedge clk) begin
        if(rst || read_data_state == `READ_DATA_WAIT)
            rcnt <= 0;
        else if(rvalid && (rcnt < arlen))
            rcnt <= rcnt + 1;
        else if(rvalid && (rcnt == arlen))
            rcnt <= 0;
    end
    assign rlast = rvalid && (rcnt == arlen);

    wire [31:0] pmem_raddr = (arburst_reg == 2'b00) ? araddr_reg:
                             (arburst_reg == 2'b01) ? araddr_reg + rcnt * (32'b1 << arsize_reg):
                             (arburst_reg == 2'b10) ? araddr_reg + rcnt * (32'b1 << arsize_reg): //WRAP module not finish
                             0;


    /* verilator lint_off LATCH */
    /*import "DPI-C" function void inst_fetch(input longint raddr, output int rdata);
    always @(*) begin
        if(!rst && recv_inst)
            inst_fetch(pc, inst);
    end*/
    //wire [63:0] rinst;
    import "DPI-C" function void pmem_read(input longint raddr, output longint rdata,input byte ren);
    always @(*) begin
        if(!rst && rvalid)
            pmem_read({32'b0,pmem_raddr}, rdata, 8'hff);
        /*else if(!rst && rvalid && recv_inst)
            pmem_read(pc_reg, rinst, 8'b11111111);*/
    end
    //assign inst = rinst[32*pc_reg[2] +: 32];

    
    //write addr
    reg [ 1:0] write_addr_state;
    reg [ 1:0] write_addr_nstate;
    reg [31:0] awaddr_reg;
    reg [ 7:0] awlen_reg;
    reg [ 2:0] awsize_reg;
    reg [ 1:0] awburst_reg;

    always @(posedge clk) begin
        if(rst) begin
            write_addr_state <= `WRITE_ADDR_WAIT;
        end
        else begin
            write_addr_state <= write_addr_nstate;
        end
    end

    always @(*) begin
        case(write_addr_state)
            `WRITE_ADDR_WAIT:
                if(awvalid) begin
                    write_addr_nstate = `WRITE_ADDR_SEND;
                end else begin
                    write_addr_nstate = `WRITE_ADDR_WAIT;
                end
            `WRITE_ADDR_SEND:
                if(wlast)
                    write_addr_nstate = `WRITE_ADDR_WAIT;
            default:
                write_addr_nstate = `WRITE_ADDR_WAIT;
        endcase
    end

    //store data_sram info when shake hands
    always @(posedge clk) begin
        if(awready & awvalid) begin
            awaddr_reg <= awaddr;
            awlen_reg  <= awlen;
            awsize_reg  <= awsize;
            awburst_reg  <= awburst;
        end
    end

    assign awready = (write_addr_state == `WRITE_ADDR_WAIT);

    //write data
    reg [ 1:0] write_data_state;
    reg [ 1:0] write_data_nstate;
    reg [63:0] wdata_reg;
    reg [ 7:0] wstrb_reg;
    always @(posedge clk) begin
        if(rst) begin
            write_data_state <= `WRITE_DATA_WAIT;
        end
        else begin
            write_data_state <= write_data_nstate;
        end
    end

    always @(*) begin
        case(write_data_state)
            `WRITE_DATA_WAIT:
                if(wvalid) begin
                    write_data_nstate = `WRITE_DATA_SEND;
                end else begin
                    write_data_nstate = `WRITE_DATA_WAIT;
                end
            `WRITE_DATA_SEND:
                if(wlast) begin
                    write_data_nstate = `WRITE_DATA_WAIT;
                end
            default:
                write_data_nstate = `WRITE_DATA_WAIT;
        endcase
    end

    assign wready  = 1;

    always @(posedge clk) begin
        if(wready & wvalid) begin
            wdata_reg  <= wdata;
            wstrb_reg  <= wstrb;
        end
    end

    //wburst cnt
    reg [7:0] wcnt;
    always @(posedge clk) begin
        if(rst || write_data_state == `WRITE_DATA_WAIT)
            wcnt <= 0;
        else if(wvalid && (wcnt == awlen))
            wcnt <= 0;
        else if(write_data_state == `WRITE_DATA_SEND)
            wcnt <= wcnt + 1;
        
    end

    wire [31:0] pmem_waddr = (awburst_reg == 2'b00) ? awaddr_reg:
                             (awburst_reg == 2'b01) ? awaddr_reg + wcnt * (32'b1 << awsize_reg):
                             (awburst_reg == 2'b10) ? awaddr_reg + wcnt * (32'b1 << awsize_reg): //WRAP module not finish
                             0;
    import "DPI-C" function void pmem_write(
      input longint waddr, input longint wdata, input byte wmask);
    
    always @(*) begin
        if(!rst && write_data_state == `WRITE_DATA_SEND)
            pmem_write({32'b0, pmem_waddr}, wdata_reg, wstrb_reg);
    end

    //write response
    reg  [1 :0] write_res_state;
    reg  [1 :0] write_res_nstate;
    always @(posedge clk) begin
        if(rst) begin
            write_res_state <= `WRITE_RES_WAIT;
        end else begin
            write_res_state <= write_res_nstate;
        end
    end 


    always @(*) begin
        case(write_res_state)
            `WRITE_RES_WAIT:
                if(wready & wvalid & wlast) begin
                    write_res_nstate = `WRITE_RES_RECV;
                end else begin
                    write_res_nstate = `WRITE_RES_WAIT;
                end
            `WRITE_RES_RECV:
                if(bready) begin
                    write_res_nstate = `WRITE_RES_WAIT;
                end 
                else begin
                    write_res_nstate = `WRITE_RES_RECV;
                end
            default:
                write_res_nstate = `WRITE_RES_WAIT;
        endcase
    end

    assign bvalid = (write_res_state == `WRITE_RES_RECV);
    assign bresp  = 2'b0;

endmodule
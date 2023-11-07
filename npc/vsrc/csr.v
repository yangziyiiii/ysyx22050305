module CSR (
    input  wire        clk,
    input  wire        rst, 
    input  wire        csr_re,
    input  wire [11:0] csr_num,
    output wire [63:0] csr_rvalue,
    input  wire        csr_we,
    input  wire [63:0] csr_wmask,
    input  wire [63:0] csr_wvalue,

    input  wire        ex,
    input  wire        ex_ret,
    input  wire [63:0] epc,
    input  wire [62:0] ecode,
    output wire [63:0] ex_entry
);
    `define CSR_MSTATUS 12'h300
    `define CSR_MTVEC   12'h305
    `define CSR_MEPC    12'h341
    `define CSR_MCAUSE  12'h342

    `define CSR_MTVEC_BASE  63:2
    `define CSR_MTVEC_MODE   1:0
    `define CSR_MCAUSE_CODE 62:0

    reg [63:0] mepc;
    always @(posedge clk) begin
        if(ex)
            mepc <= epc;
        else if (csr_we && csr_num==`CSR_MEPC)
            mepc <= csr_wmask& csr_wvalue
                 | ~csr_wmask& mepc;
    end

    reg [61:0] mtvec_base;
    reg [ 1:0] mtvec_mode;
    always @(posedge clk) begin
        if (csr_we && csr_num==`CSR_MTVEC)
            mtvec_base <= csr_wmask[`CSR_MTVEC_BASE]& csr_wvalue[`CSR_MTVEC_BASE] 
                        | ~csr_wmask[`CSR_MTVEC_BASE]& mtvec_base;
    end
    always @(posedge clk) begin
        if (rst)
            mtvec_mode <= 2'b0; //warning
    end
    
    reg        mcause_intr;
    reg [62:0] mcause_code;
    always @(posedge clk) begin
        if (rst)
            mcause_intr = 0; //warning
    end
    always @(posedge clk) begin
        if (ex)
            mcause_code <= ecode;
    end

    reg [63:0] mstatus; //warning
    always @(posedge clk) begin
        if (rst)
            mstatus <= 64'ha00001800;
    end

    assign ex_entry = (mtvec_mode==0)? {mtvec_base, 2'b0} :
                      {mtvec_base, 2'b0} + mcause_code << 2;

    assign csr_rvalue = {64{csr_re && csr_num==`CSR_MSTATUS}} & mstatus                  |
                        {64{csr_re && csr_num==`CSR_MTVEC}}   & {mtvec_base, mtvec_mode} |
                        {64{csr_re && csr_num==`CSR_MEPC || ex_ret}} & mepc              |
                        {64{csr_re && csr_num==`CSR_MCAUSE}}  & {mcause_intr, mcause_code};
endmodule

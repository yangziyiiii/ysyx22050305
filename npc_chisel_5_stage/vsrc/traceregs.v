import "DPI-C" function void set_gpr_ptr(input logic [63:0] Regfile []);
//import "DPI-C" function void get_pc(input longint pc);
//import "DPI-C" function void set_csr_ptr(input logic [63:0] Regfile []);

module traceregs(
    input [63:0] input_reg_0,
    input [63:0] input_reg_1,
    input [63:0] input_reg_2,
    input [63:0] input_reg_3,
    input [63:0] input_reg_4,
    input [63:0] input_reg_5,
    input [63:0] input_reg_6,
    input [63:0] input_reg_7,
    input [63:0] input_reg_8,
    input [63:0] input_reg_9,
    input [63:0] input_reg_10,
    input [63:0] input_reg_11,
    input [63:0] input_reg_12,
    input [63:0] input_reg_13,
    input [63:0] input_reg_14,
    input [63:0] input_reg_15,
    input [63:0] input_reg_16,
    input [63:0] input_reg_17,
    input [63:0] input_reg_18,
    input [63:0] input_reg_19,
    input [63:0] input_reg_20,
    input [63:0] input_reg_21,
    input [63:0] input_reg_22,
    input [63:0] input_reg_23,
    input [63:0] input_reg_24,
    input [63:0] input_reg_25,
    input [63:0] input_reg_26,
    input [63:0] input_reg_27,
    input [63:0] input_reg_28,
    input [63:0] input_reg_29,
    input [63:0] input_reg_30,
    input [63:0] input_reg_31
    // input [63:0] csr_reg_0,
    // input [63:0] csr_reg_1,
    // input [63:0] csr_reg_2,
    // input [63:0] csr_reg_3,
    // input [63:0] pc
);
    wire [63:0] traceregs [0:31];
    //wire [63:0] csr_regs [0:3];
    assign traceregs[0] = input_reg_0; 
    assign traceregs[1] = input_reg_1;
    assign traceregs[2] = input_reg_2;
    assign traceregs[3] = input_reg_3;
    assign traceregs[4] = input_reg_4;
    assign traceregs[5] = input_reg_5;
    assign traceregs[6] = input_reg_6;
    assign traceregs[7] = input_reg_7;
    assign traceregs[8] = input_reg_8;
    assign traceregs[9] = input_reg_9;
    assign traceregs[10] = input_reg_10;
    assign traceregs[11] = input_reg_11;
    assign traceregs[12] = input_reg_12;
    assign traceregs[13] = input_reg_13;
    assign traceregs[14] = input_reg_14;
    assign traceregs[15] = input_reg_15;
    assign traceregs[16] = input_reg_16;
    assign traceregs[17] = input_reg_17;
    assign traceregs[18] = input_reg_18;
    assign traceregs[19] = input_reg_19;
    assign traceregs[20] = input_reg_20;
    assign traceregs[21] = input_reg_21;
    assign traceregs[22] = input_reg_22;
    assign traceregs[23] = input_reg_23;
    assign traceregs[24] = input_reg_24;
    assign traceregs[25] = input_reg_25;
    assign traceregs[26] = input_reg_26;
    assign traceregs[27] = input_reg_27;
    assign traceregs[28] = input_reg_28;
    assign traceregs[29] = input_reg_29;
    assign traceregs[30] = input_reg_30;
    assign traceregs[31] = input_reg_31;
    // assign csr_regs[0] = csr_reg_0;
    // assign csr_regs[1] = csr_reg_1;
    // assign csr_regs[2] = csr_reg_2;
    // assign csr_regs[3] = csr_reg_3;
    always@(*)begin
        //get_pc(pc);
        set_gpr_ptr(traceregs);
        //set_csr_ptr(csr_regs);
    end
endmodule

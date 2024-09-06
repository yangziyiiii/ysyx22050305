package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class ALU extends Module{
    val io = IO(new Bundle{
        val src1_value = Input(UInt(64.W))
        val src2_value = Input(UInt(64.W))
        val ALUop = Input(UInt(32.W))
        val src_valid = Input(Bool())
        val src_ready = Output(Bool())
        val res_valid = Output(Bool())
        val alu_busy = Output(Bool())
        //val div_valid = Output(Bool())
        //val op_div = Output(Bool())
        //val div_ready = Input(Bool())
        //val out_valid = Input(Bool())
        val res_ready = Input(Bool())
        val alu_res = Output(UInt(64.W))
    })
   
    val src1_value = io.src1_value
    val src2_value = io.src2_value

    val mul_valid = Wire(Bool())
    val mul_w = Wire(Bool())
    val div_valid = Wire(Bool())
    val div_w = Wire(Bool())
    val div_signed = Wire(Bool())
    mul_valid := MuxLookup(io.ALUop,false.B,Array(
        MLU.U -> true.B,
        MLUW.U -> true.B
    ))
    div_valid := MuxLookup(io.ALUop,false.B,Array(
        DIV.U -> true.B,
        DIVU.U -> true.B,
        DIVW.U -> true.B,
        DIVUW.U -> true.B,
        REM.U -> true.B,
        REMU.U -> true.B,
        REMW.U -> true.B,
        REMUW.U -> true.B
    ))
    mul_w := io.ALUop===MLUW.U
    div_w := MuxLookup(io.ALUop,false.B,Array(
        DIVW.U -> true.B,
        DIVUW.U -> true.B,
        REMW.U -> true.B,
        REMUW.U -> true.B
    ))
    div_signed := MuxLookup(io.ALUop,false.B,Array(
        DIV.U -> true.B,
        DIVW.U -> true.B,
        REM.U -> true.B,
        REMW.U -> true.B
    ))


    val mul_module = Module(new Mul).io
    val div_module = Module(new Div).io
    mul_module.mul_valid := mul_valid && io.src_valid
    mul_module.flush := false.B
    mul_module.mulw := mul_w
    mul_module.mul_signed := 3.U
    mul_module.multiplicand := src1_value
    mul_module.multiplier := src2_value
    mul_module.out_ready := io.res_ready

    div_module.dividend := src1_value
    div_module.divisor := src2_value
    div_module.div_valid := div_valid && io.src_valid
    div_module.divw := div_w
    div_module.div_signed := div_signed
    div_module.flush := false.B
    div_module.out_ready := io.res_ready


    val add_res = src1_value + src2_value
    val sub_res = src1_value - src2_value
    val sra_res = (src1_value.asSInt() >> src2_value(5,0)).asUInt
    val srl_res = src1_value >> src2_value(5,0)
    val sll_res = src1_value << src2_value(5,0)
    val sraw_res = src1_value(31,0).asSInt() >> src2_value(4,0)
    val srlw_res = src1_value(31,0) >> src2_value(4,0)
    val sllw_res = src1_value(31,0) << src2_value(4,0)
    val or_res = src1_value | src2_value
    val xor_res = src1_value ^ src2_value
    val and_res = src1_value & src2_value
    val mlu_res = Cat(mul_module.result_hi,mul_module.result_lo)//(src1_value * src2_value)(63,0)
    val mluw_res = mul_module.result_lo//(src1_value(31,0) * src2_value(31,0))(31,0)
    val divw_res = div_module.quotient(31,0)//(src1_value(31,0).asSInt / src2_value(31,0).asSInt)(31,0)
    val divuw_res = div_module.quotient(31,0)//(src1_value(31,0) / src2_value(31,0))(31,0)
    val remw_res = div_module.remainder(31,0)//(src1_value(31,0).asSInt % src2_value(31,0).asSInt)(31,0)
    val remuw_res = div_module.remainder(31,0)//(src1_value(31,0) % src2_value(31,0))(31,0)
    val div_res = div_module.quotient//(src1_value.asSInt / src2_value.asSInt).asUInt
    val divu_res = div_module.quotient//src1_value / src2_value
    val rem_res = div_module.remainder//(src1_value.asSInt % src2_value.asSInt).asUInt
    val remu_res = div_module.remainder//src1_value % src2_value


    val alu_res = MuxLookup(io.ALUop, 0.U, Array(
        ADD.U -> add_res,
        // SH.U -> add_res,
        // SW.U -> add_res,
        // SD.U -> add_res,
        // LD.U -> add_res,
        // LW.U -> add_res,
        // LWU.U -> add_res,
        // LH.U -> add_res,
        // LHU.U -> add_res,
        // LB.U -> add_res,
        // LBU.U -> add_res,
        // ADDI.U -> add_res,
        // AUIPC.U -> add_res,
        LUI.U -> src2_value,
        JAL.U -> (src1_value+4.U),
        JALR.U -> (src1_value+4.U),
        //SLTIU.U -> Mux(src1_value<src2_value, 1.U, 0.U),
        SLTU.U -> Mux(src1_value<src2_value, 1.U, 0.U),
        //SLTI.U -> Mux(src1_value.asSInt()<src2_value.asSInt(), 1.U, 0.U),
        SLT.U -> Mux(src1_value.asSInt()<src2_value.asSInt(), 1.U, 0.U),
        ADDW.U -> Cat(Fill(32, add_res(31)), add_res(31,0)),
        SUB.U -> sub_res,
        //ADDIW.U -> Cat( Fill(32, add_res(31)), add_res(31,0)),
        //ADD.U -> add_res,
        SRAI.U -> sra_res,
        OR.U -> or_res,
        //ORI.U -> or_res,
        XOR.U -> xor_res,
        //XORI.U -> xor_res,
        AND.U -> and_res,
        //ANDI.U -> and_res,
        SUBW.U -> Cat(Fill(32, sub_res(31)), sub_res(31,0)),
        SLLW.U -> Cat(Fill(32, sllw_res(31)), sllw_res(31,0)),
        //SLLI.U -> sll_res,
        //SRLI.U -> srl_res,
        //SLLIW.U -> Cat(Fill(32, sllw_res(31)), sllw_res(31,0)),
        //SRAIW.U -> Cat(Fill(32, sraw_res(31)), sraw_res(31,0)),
        //SRLIW.U -> Cat(Fill(32, srlw_res(31)), srlw_res(31,0)),
        SRAW.U -> Cat(Fill(32, sraw_res(31)), sraw_res(31,0)),
        SRLW.U -> Cat(Fill(32, srlw_res(31)), srlw_res(31,0)),
        MLU.U -> mlu_res,
        MLUW.U -> Cat(Fill(32, mluw_res(31)), mluw_res),
        DIVW.U -> Cat(Fill(32, divw_res(31)), divw_res),
        DIVU.U -> divu_res,
        DIV.U -> div_res,
        DIVUW.U -> Cat(Fill(32, divuw_res(31)), divuw_res),
        REMW.U -> Cat(Fill(32, remw_res(31)), remw_res),
        REMUW.U -> Cat(Fill(32, remuw_res(31)), remuw_res),
        REMU.U -> remu_res,
        REM.U -> rem_res,
        SLL.U -> sll_res,
        SRA.U -> sra_res.asUInt,
        SRL.U -> srl_res,
        CSRRW.U -> src1_value,
        CSRRS.U -> src1_value,
        CSRRC.U -> src1_value
    ) )
    //printf("mul_valid:%d mul_w:%d mlu_res:%x\n",mul_valid,mul_w,mlu_res)
    io.src_ready := true.B
    io.res_valid := Mux(mul_valid,mul_module.out_valid,Mux(div_valid,div_module.out_valid,true.B))
    io.alu_busy := Mux(mul_valid,!mul_module.out_valid,Mux(div_valid,!div_module.out_valid,false.B))
    io.alu_res := alu_res
}
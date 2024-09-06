package  mycpu

import chisel3._
import chisel3.util._
//import  Constants._

class  Div extends Module{
    val io = IO(new Bundle{
        val dividend = Input(UInt(64.W))
        val divisor = Input(UInt(64.W))
        val div_valid = Input(Bool())
        val divw = Input(Bool())
        val div_signed = Input(UInt(1.W))
        val flush = Input(Bool())
        val div_ready = Output(Bool())
        val out_valid = Output(Bool())
        val out_ready = Input(Bool())
        val quotient = Output(UInt(64.W))
        val remainder = Output(UInt(64.W))
    })
    val dend_neg = Wire(UInt(1.W))
    val sor_neg = Wire(UInt(1.W))
    val quotient_neg = Wire(UInt(1.W))
    val remainder_neg = Wire(UInt(1.W))

    dend_neg := Mux(io.divw, io.dividend(31), io.dividend(63))
    sor_neg := Mux(io.divw, io.divisor(31), io.divisor(63))
    quotient_neg := (dend_neg & ~sor_neg) | (~dend_neg & sor_neg)
    remainder_neg := dend_neg

    val src1_32_s = Wire(UInt(64.W))
    val src2_32_s = Wire(UInt(64.W))
    val src1_32 = Wire(UInt(64.W))
    val src2_32 = Wire(UInt(64.W))

    src1_32_s := Mux(io.divw,Cat(Fill(32,io.dividend(31)),io.dividend(31,0)),io.dividend)
    src2_32_s := Mux(io.divw,Cat(Fill(32,io.divisor(31)),io.divisor(31,0)),io.divisor)
    src1_32 := Mux(io.divw,io.dividend(31,0),io.dividend)
    src2_32 := Mux(io.divw,io.divisor(31,0),io.divisor)

    val real_cand = Wire(UInt(64.W))
    val real_er = Wire(UInt(64.W))
    real_cand := Mux(io.div_signed===1.U,Mux(dend_neg===1.U,~src1_32_s+1.U,src1_32_s),src1_32)
    real_er := Mux(io.div_signed===1.U,Mux(sor_neg===1.U,~src2_32_s+1.U,src2_32_s),src2_32)

    val src1 = Wire(UInt(128.W))
    val src2 = Wire(UInt(65.W))
    src1 := Cat(Fill(32,0.U(1.W)),real_cand)
    src2 := Cat(0.U(1.W),real_er)

    val div_cand = RegInit(0.U(128.W))
    val div_start = RegInit(Bool(),false.B)
    //val div_return = RegInit(Bool(),false.B)
    val quotient = RegInit(0.U(64.W))
    //val rem = RegInit(0.U(64.W))
    val step_num = RegInit(0.U(32.W))
    io.div_ready := ~div_start
    when(io.flush){
        div_start := false.B
        quotient := 0.U
        step_num := 64.U
    }.otherwise{
        when(io.div_valid && !div_start){
            div_start := true.B
            div_cand := src1
            quotient := 0.U
            //rem := 0.U
            step_num := 64.U
        }.elsewhen(div_start && step_num.asSInt <= 0.S){
            div_start := false.B
        }
    }
    when(div_start){
        when(step_num.asSInt > 0.S){
            val sub_res = Wire(UInt(65.W))
            val new_cand = Wire(UInt(128.W))
            val update_cand = Wire(UInt(128.W))
            sub_res := div_cand(127,63) - src2
            //val index = step_num - 1.U
            quotient := Mux(sub_res(64)===1.U,(quotient << 1.U),quotient << 1.U | 1.U(64.W))
            update_cand := sub_res << 63
            new_cand := Mux(sub_res(64)===1.U, div_cand, (div_cand & "h7fffffffffffffff".U) | update_cand) 
            div_cand := new_cand << 1
            step_num := step_num - 1.U
            io.remainder := 0.U
            io.out_valid := false.B
            io.quotient := 0.U
        }.otherwise{
            io.remainder := Mux(io.div_signed===1.U,Mux(remainder_neg===1.U,~div_cand(127,64)+1.U,div_cand(127,64)),div_cand(127,64))
            io.out_valid := true.B
            io.quotient := Mux(io.div_signed===1.U,Mux(quotient_neg===1.U,~quotient+1.U,quotient),quotient)
        }
    }.otherwise{
        io.remainder := 0.U
        io.out_valid := false.B
        io.quotient := 0.U
    }
    






}
package  mycpu

import chisel3._
import chisel3.util._
import  Constants._


class Register extends Module{
    val io = IO(new Bundle{
        val raddr1 = Input(UInt(5.W))
        val raddr2 = Input(UInt(5.W))
        val rdata1 = Output(UInt(64.W))
        val rdata2 = Output(UInt(64.W))
        val we = Input(Bool())
        val waddr = Input(UInt(5.W))
        val wdata = Input(UInt(64.W))
    })
    val Reg = Mem(32, UInt(64.W))
    when(io.we&&io.waddr=/=0.U){
        Reg(io.waddr) := io.wdata
    }
    io.rdata1 := Mux(io.raddr1===0.U,0.U,Reg(io.raddr1))
    io.rdata2 := Mux(io.raddr2===0.U,0.U,Reg(io.raddr2))
    val reg_trace = Module(new traceregs())
    reg_trace.io.input_reg := VecInit(Seq.fill(32)(0.U(64.W)))
    (0 until 32).foreach(i => reg_trace.io.input_reg(i) := Reg(i))
    //reg_trace.io.pc := io.pc
    //reg_trace.io.csr_reg := VecInit(Seq.fill(4)(0.U(64.W)))
    //(0 until 3).foreach(i => reg_trace.io.csr_reg(i) := CSR_Reg(i))
}
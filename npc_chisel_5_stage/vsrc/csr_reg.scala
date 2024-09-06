package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class csr_reg extends Module{
    val io = IO(new Bundle{
        val wen1 = Input(Bool())
        val wen2 = Input(Bool())
        val waddr1 = Input(UInt(2.W))
        val waddr2 = Input(UInt(2.W))
        val wdata1 = Input(UInt(64.W))
        val wdata2 = Input(UInt(64.W))
        val raddr = Input(UInt(2.W))
        val rdata = Output(UInt(64.W))
    })

    val CSR_Reg = Mem(4, UInt(64.W))
    CSR_Reg(2) := "ha00001800".U
    when(io.wen1){
        CSR_Reg(io.waddr1) := io.wdata1
    }
    when(io.wen2){
        CSR_Reg(io.waddr2) := io.wdata2
    }
    io.rdata := CSR_Reg(io.raddr)
}
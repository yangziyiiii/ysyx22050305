package  mycpu

import chisel3._
import chisel3.util._

class MEM extends BlackBox with HasBlackBoxPath{
    val io = IO(new Bundle {
        val Raddr = Input(UInt(64.W))
        val Rdata = Output(UInt(64.W))
        val Waddr = Input(UInt(64.W))
        val Wdata = Input(UInt(64.W))
        val Wmask = Input(UInt(8.W))
        val Write_en = Input(Bool())
        val Read_en = Input(Bool())
    })
    addPath("./MEM.v")
}
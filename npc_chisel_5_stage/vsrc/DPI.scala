package  mycpu

import chisel3._
import chisel3.util._

class DPI extends BlackBox with HasBlackBoxPath{
    val io = IO(new Bundle {
        val flag = Input(UInt(32.W))
        val ecall_flag = Input(UInt(32.W))
        val pc = Input(UInt(64.W))
    })
    addPath("./DPI.v")
}
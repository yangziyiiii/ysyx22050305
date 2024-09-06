package  mycpu

import chisel3._
import chisel3.util._

class traceregs extends HasBlackBoxPath {
  val io = IO(new Bundle {
    val input_reg = Input(Vec(32, UInt(64.W)))
    //val csr_reg = Input(Vec(4, UInt(64.W)))
    //val pc = Input(UInt(64.W))
  })
  addPath("./traceregs.v")
}
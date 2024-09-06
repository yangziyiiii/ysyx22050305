package mycpu

import chisel3._
import chisel3.stage.ChiselStage

object Main extends App {
  (new ChiselStage).emitVerilog(new top(), Array("--target-dir", "output"))
}
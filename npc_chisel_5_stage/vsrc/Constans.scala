package  mycpu

import chisel3._
import chisel3.util._

object Constants {
  val I_TYPE = 0x40
  val R_TYPE = 0x41
  val U_TYPE = 0x42
  val J_TYPE = 0x43
  val S_TYPE = 0x44
  val B_TYPE = 0x45

  val ADDI = 0x1
  val EBREAK = 0x2
  val AUIPC = 0x3
  val LUI = 0x4
  val JAL = 0x5
  val JALR = 0x6
  val SD = 0x7
  val AND = 0x8
  val ANDI = 0x9
  val XORI = 0xa
  val OR = 0xb
  val ADDW = 0xc
  val SUBW = 0xd
  val SUB = 0xe
  val ADD = 0xf
  val ADDIW = 0x10
  val MLU = 0x11
  val MLUW = 0x12
  val DIVW = 0x13
  val REMW = 0x14
  val SRAI = 0x15
  val SLLW = 0x16
  val SLLI = 0x17
  val SRLI = 0x18
  val SLLIW = 0x19
  val SRAIW = 0x1a
  val SRLIW = 0x1b
  val SRAW = 0x1c
  val SRLW = 0x1d
  val SLTU = 0x1e
  val SLT = 0x1f
  val SLTIU = 0x20
  val LW = 0x21
  val LD = 0x22
  val LBU = 0x23
  val LH = 0x24
  val LHU = 0x25
  val SH = 0x26
  val SW = 0x27
  val SB = 0x28
  val BEQ = 0x29
  val BNE = 0x2a
  val BGE = 0x2b
  val BLT = 0x2c
  val BLTU = 0x2d
  val XOR = 0x2e
  val ORI = 0x2f
  val DIVU = 0x30
  val DIV = 0x31
  val REMUW = 0x32
  val REMU = 0x33
  val REM = 0x34
  val DIVUW = 0x35
  val SLTI = 0x36
  val SLL = 0x37
  val SRL = 0x38
  val SRA = 0x39
  val LWU = 0x3a
  val LB = 0x3b
  val BGEU = 0x3c
  val ECALL = 0x3d
  val MRET = 0x3e
  val CSRRW = 0x3f
  val CSRRS = 0x46
  val CSRRC = 0x47
}

class ctrl_in extends Bundle{
    val reg_write = Input(Bool())
    val csr_write = Input(Bool())
    //val src2_is_imm = Input(Bool())
    //val src1_is_pc = Input(Bool())
    val Writemem_en = Input(Bool())
    val Readmem_en = Input(Bool())
    val Wmask = Input(UInt(8.W))
}

class ctrl_out extends Bundle{
    val reg_write = Output(Bool())
    val csr_write = Output(Bool())
    //val src2_is_imm = Output(Bool())
    //val src1_is_pc = Output(Bool())
    val Writemem_en = Output(Bool())
    val Readmem_en = Output(Bool())
    val Wmask = Output(UInt(8.W))
}

//axi
class master_in extends Bundle{
  //request read
  val arready = Bool()

  //response read
  //val rid     = UInt(4.W)
  val rdata   = UInt(64.W)
  //val rresp   = UInt(2.W)
  val rlast   = Bool()
  val rvalid  = Bool()
  // request write
  val awready  = Bool()

  //write data
  val wready = Bool()

  //response write
  //val bid    = UInt(4.W)
  //val bresp  = UInt(2.W)
  val bvalid = Bool()
}

class master_out extends Bundle{
  //request read
  //val arid    = UInt(4.W)
  val araddr  = UInt(32.W)
  val arlen   = UInt(8.W)
  val arsize  = UInt(3.W)
  val arburst = UInt(2.W)
  //val arlock  = UInt(2.W)
  //val arcache = UInt(4.W)
  //val arprot  = UInt(3.W)
  val arvalid = Bool()
  
  //response read
  val rready  = Bool()

  //request write
 // val awid    = UInt(4.W)
  val awaddr  = UInt(32.W)
  val awlen   = UInt(8.W)
  val awsize  = UInt(3.W)
  val awburst = UInt(2.W)
  //val awlock  = UInt(2.W)
  //val awcache = UInt(4.W)
  //val awprot  = UInt(3.W)
  val awvalid = Bool()

  //write data
  //val wid     = UInt(4.W)
  val wdata   = UInt(64.W)
  val wstrb   = UInt(8.W)
  val wlast   = Bool()
  val wvalid  = Bool()

  //response write
  val bready  = Bool()
}
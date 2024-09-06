package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class EXU extends Module{
    val io = IO(new Bundle{
        val pc = Input(UInt(64.W))
        val ds_to_es_valid = Input(Bool())
        val ms_allowin = Input(Bool())
        val es_allowin = Output(Bool())
        val ALUop = Input(UInt(32.W))
        val src1_value = Input(UInt(64.W))
        val src2_value = Input(UInt(64.W))
        val rf_dst = Input(UInt(5.W))
        val store_data = Input(UInt(64.W))
        val es_to_ms_valid = Output(Bool())
        val load_type = Input(UInt(3.W))
        val to_ms_pc = Output(UInt(64.W))
        val to_ms_alures = Output(UInt(64.W))
        val to_ms_store_data = Output(UInt(64.W))
        val to_ms_wen = Output(Bool())
        val to_ms_wstrb = Output(UInt(8.W))
        val to_ms_ren = Output(Bool())
        val to_ms_maddr = Output(UInt(64.W))
        val to_ms_rf_dst = Output(UInt(5.W))
        val to_ms_rf_we = Output(Bool())
        val to_ms_load_type = Output(UInt(3.W))

        val ctrl_sign = new ctrl_in()
        val es_valid = Output(Bool())
        val es_rf_we = Output(Bool())
        val es_rf_dst = Output(UInt(5.W))
        val es_fwd_ready = Output(Bool())
        val es_fwd_res = Output(UInt(64.W))
        val es_ld = Output(Bool())
    })

    val alu = Module(new ALU).io

    val es_pc = RegInit(0.U(64.W))
    val es_valid = RegInit(Bool(),false.B)
    val es_to_ms_valid = Wire(Bool())
    val es_ready_go = Wire(Bool())
    val es_allowin = Wire(Bool())
    val es_rd = RegInit(0.U(5.W))
    val es_rf_we = RegInit(Bool(),false.B)
    val es_sel_rf_res = RegInit(Bool(),false.B)
    val src1_value = RegInit(0.U(64.W))
    val src2_value = RegInit(0.U(64.W))
    val store_data = RegInit(0.U(64.W))
    val st_wstrb = RegInit(0.U(8.W))
    val st_we = RegInit(Bool(),false.B)
    val ld_we = RegInit(Bool(),false.B)
    val alu_res = Wire(UInt(64.W))
    val ALUop = RegInit(0.U(32.W))
    val load_type = RegInit(0.U(3.W))

    when(es_allowin){
        es_valid := io.ds_to_es_valid
    }
    when(io.ds_to_es_valid && es_allowin){
        es_pc := io.pc
        es_rf_we := io.ctrl_sign.reg_write
        es_sel_rf_res := io.ctrl_sign.Readmem_en
        src1_value := io.src1_value
        src2_value := io.src2_value
        es_rd := io.rf_dst
        store_data := io.store_data
        st_wstrb := io.ctrl_sign.Wmask
        st_we := io.ctrl_sign.Writemem_en
        ld_we := io.ctrl_sign.Readmem_en
        ALUop := io.ALUop
        load_type := io.load_type
    }

    es_ready_go := ~alu.alu_busy
    es_to_ms_valid := es_valid && es_ready_go
    es_allowin := !es_valid || (es_ready_go&&io.ms_allowin)

    //val Mem_modle = Module(new MEM())
    //val mem_rdata = Wire(UInt(64.W))
    //val Regfile = Mem(32, UInt(64.W))
    // val CSR_Reg = Mem(4, UInt(64.W))
    // val csr_addr = io.imm(11,0)
    // val csr_index = MuxLookup(csr_addr, 0.U, Array(
    //     "h305".U -> 0.U,
    //     "h341".U -> 1.U,
    //     "h300".U -> 2.U,
    //     "h342".U -> 3.U
    // ))

    alu.src1_value := Mux(ALUop===JALR.U,es_pc,src1_value)
    alu.src2_value := src2_value
    alu.ALUop := ALUop
    alu.src_valid := es_valid
    alu_res := alu.alu_res
    alu.res_ready := io.ms_allowin

    // val csr_wdata = MuxLookup(io.inst_now, 0.U, Array(
    //     CSRRW.U -> src1_value,
    //     CSRRS.U -> (src1_value | CSR_Reg(csr_index)),
    //     CSRRC.U -> (src1_value & (~CSR_Reg(csr_index))),
    // ))

    // CSR_Reg(1.U) := Mux(io.inst_now === ECALL.U, io.pc, CSR_Reg(1.U))
    // CSR_Reg(3.U) := Mux(io.inst_now === ECALL.U, Regfile(17), CSR_Reg(3.U))

    // CSR_Reg(csr_index) := Mux(io.ctrl_sign.csr_write, csr_wdata, CSR_Reg(csr_index))  
    io.es_allowin := es_allowin
    io.to_ms_pc := es_pc
    io.es_to_ms_valid := es_to_ms_valid
    io.to_ms_alures := alu_res
    io.to_ms_store_data := store_data
    io.to_ms_wen := st_we
    io.to_ms_wstrb := st_wstrb
    io.to_ms_ren := ld_we
    io.to_ms_maddr := alu_res
    io.to_ms_rf_dst := es_rd
    io.to_ms_rf_we := es_rf_we
    io.es_valid := es_valid 
    io.es_rf_dst := es_rd
    io.es_rf_we := es_rf_we
    io.to_ms_load_type := load_type
    io.es_fwd_res := alu_res
    io.es_fwd_ready := es_to_ms_valid
    io.es_ld := ld_we && es_valid
    //printf("es_pc:%x es_valid:%d es_allowin:%d ld_we:%d alu_res:%x src1_value:%x  src2_value:%x\n",es_pc,es_valid,es_allowin,ld_we,alu_res,src1_value,src2_value)
    
}
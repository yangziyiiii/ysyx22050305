package mycpu

import chisel3._
import chisel3.util._
import  Constants._

class top extends Module{
    val io = IO(new Bundle{
        val inst = Output(UInt(32.W))
        val pc = Output(UInt(64.W))
        //val pc_next = Output(UInt(64.W))
        //val outval = Output(UInt(64.W))
        val step = Output(Bool())
        val skip = Output(Bool())
    })
    val regfile = Module(new Register).io
    val ifu = Module(new IFU).io
    val idu = Module(new IDU).io
    val exu = Module(new EXU).io
    val mem = Module(new LSU).io
    val wbu = Module(new WBU).io
    val arbiter = Module(new AXI_ARBITER())
    val i_cache = Module(new I_CACHE())
    val d_cache = Module(new D_CACHE())
    val axi = Module(new AXI())
    //val pre_if_to_if_valid = Wire(Bool())
    //i_cache.io.br_taken := idu.br_taken_cancel
    arbiter.io.ifu_axi_in <> i_cache.io.to_axi
    i_cache.io.from_axi <> arbiter.io.ifu_axi_out
    ifu.axi_in <> i_cache.io.to_ifu
    i_cache.io.from_ifu <> ifu.axi_out

    arbiter.io.lsu_axi_in <> d_cache.io.to_axi
    d_cache.io.from_axi <> arbiter.io.lsu_axi_out
    mem.axi_in <> d_cache.io.to_lsu
    d_cache.io.from_lsu <> mem.axi_out

    arbiter.io.axi_in <> axi.io.axi_out
    axi.io.axi_in <> arbiter.io.axi_out

    //pre_if_to_if_valid := true.B
    //ifu.to_fs_valid := pre_if_to_if_valid
    ifu.ds_valid := idu.ds_valid
    ifu.ds_ready_go := idu.ds_ready_go
    ifu.ds_allowin := idu.ds_allowin
    ifu.br_taken := idu.br_taken
    ifu.br_target := idu.br_target
    //ifu.br_taken_cancel := idu.br_taken_cancel
    ifu.fence := idu.fence
    ifu.cache_init := i_cache.io.cache_init
    i_cache.io.clear_cache := ifu.clear_cache
    
    idu.pc := ifu.to_ds_pc
    idu.fs_to_ds_valid := ifu.fs_to_ds_valid
    idu.es_allowin := exu.es_allowin
    idu.from_fs_inst := ifu.inst
    regfile.raddr1 := idu.raddr1
    regfile.raddr2 := idu.raddr2
    idu.rdata1 := regfile.rdata1
    idu.rdata2 := regfile.rdata2
    idu.es_valid := exu.es_valid
    idu.es_rf_dst := exu.es_rf_dst
    idu.es_rf_we := exu.es_rf_we
    idu.ms_valid := mem.ms_valid
    idu.ms_rf_dst := mem.ms_rf_dst
    idu.ms_rf_we := mem.ms_rf_we
    idu.ws_valid := wbu.ws_valid
    idu.ws_rf_dst := wbu.ws_rf_dst
    idu.ws_rf_we := wbu.ws_rf_we
    idu.es_fwd_ready := exu.es_fwd_ready
    idu.es_fwd_res := exu.es_fwd_res
    idu.ms_fwd_ready := mem.ms_fwd_ready
    idu.ms_fwd_res := mem.ms_fwd_res
    idu.ws_fwd_ready := wbu.ws_fwd_ready
    idu.ws_fwd_res := wbu.ws_fwd_res
    idu.es_ld := exu.es_ld
    
    exu.pc := idu.to_es_pc
    exu.ds_to_es_valid := idu.ds_to_es_valid
    exu.ms_allowin := mem.ms_allowin
    exu.ALUop := idu.ALUop
    exu.src1_value := idu.src1
    exu.src2_value := idu.src2
    exu.rf_dst := idu.rf_dst
    exu.store_data := idu.store_data
    exu.ctrl_sign := idu.ctrl_sign
    exu.load_type := idu.load_type

    mem.pc := exu.to_ms_pc
    mem.es_to_ms_valid := exu.es_to_ms_valid
    mem.ws_allowin := wbu.ws_allowin
    mem.rf_we := exu.to_ms_rf_we
    mem.rf_dst := exu.to_ms_rf_dst
    mem.alu_res := exu.to_ms_alures
    mem.store_data := exu.to_ms_store_data
    mem.wen := exu.to_ms_wen
    mem.wstrb := exu.to_ms_wstrb
    mem.ren := exu.to_ms_ren
    mem.maddr := exu.to_ms_maddr
    mem.load_type := exu.to_ms_load_type

    wbu.pc := mem.to_ws_pc
    wbu.ms_to_ws_valid := mem.ms_to_ws_valid
    wbu.ms_final_res := mem.ms_final_res
    wbu.rf_we := mem.to_ws_rf_we
    wbu.rf_dst := mem.to_ws_rf_dst
    wbu.device_access := mem.to_ws_device
    regfile.we := wbu.we
    regfile.waddr := wbu.waddr
    regfile.wdata := wbu.wdata

    io.pc := ifu.to_ds_pc
    //io.step := wbu.ws_valid
    io.inst := ifu.inst
    val diff_step = RegInit(Bool(),false.B)
    diff_step := wbu.ws_valid
    io.step := diff_step
    val skip = RegInit(Bool(),false.B)
    skip := wbu.skip
    io.skip := skip
    val dpi = Module(new DPI)
    dpi.io.flag := Mux(idu.ALUop === EBREAK.U, 1.U, 0.U)
    dpi.io.ecall_flag := Mux(idu.ALUop === ECALL.U, 1.U, 0.U)
    dpi.io.pc := Mux(wbu.ws_valid,wbu.ws_pc,Mux(mem.ms_valid,wbu.pc,Mux(exu.es_valid,mem.pc,Mux(idu.ds_valid,exu.pc,idu.pc))))
    //dpi.io.pc := wbu.ws_pc
    //printf("dpi_pc:%x\n",dpi.io.pc)
}
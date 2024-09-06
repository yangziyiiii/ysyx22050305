package  mycpu

import chisel3._
import chisel3.util._

class IFU extends Module{
    val io = IO(new Bundle{
        //val pc = Input(UInt(64.W))
        //val to_fs_valid = Input(Bool())
        val ds_allowin = Input(Bool())
        val ds_ready_go = Input(Bool())
        val ds_valid = Input(Bool())
        val br_taken = Input(Bool())
        val br_target =  Input(UInt(64.W))
        //val br_taken_cancel = Input(Bool())
        val to_ds_pc = Output(UInt(64.W))
        val fs_to_ds_valid = Output(Bool())
        val inst = Output(UInt(32.W))
        val axi_in = Input(new master_in())
        val axi_out = Output(new master_out())
        val pc_next = Output(UInt(64.W))

        val fence = Input(Bool())
        val clear_cache = Output(Bool())
        val cache_init = Input(Bool())
    })

    //val br_taken_cancel = RegInit(Bool(),false.B)
    //val br_taken = RegInit(Bool(),false.B)
    
    val br_target = RegInit(0.U(64.W))
    when(io.ds_valid && io.ds_ready_go){
        br_target := io.br_target
    }

    val fs_valid = RegInit(Bool(),false.B)
    val fs_ready_go = Wire(Bool())
    val fs_to_ds_valid = Wire(Bool())
    val to_fs_valid = Wire(Bool())
    val fs_allowin = Wire(Bool())
    val pc_next = Wire(UInt(64.W))
    val fs_pc_next = RegInit(0.U(64.W))
    val cache_init = RegInit(Bool(),false.B)
    when(io.cache_init){
        cache_init := true.B
    }.elsewhen(fs_to_ds_valid && io.ds_allowin&&cache_init){
        cache_init := false.B
    }
    //val br_taken = RegInit(Bool(),false.B)
    val fs_pc = RegInit("x7ffffffc".U(64.W))
    val fs_inst = RegInit(0.U(32.W))
    
    to_fs_valid := io.axi_in.rvalid

    io.clear_cache := io.fence && !cache_init

    // when(io.br_taken&&io.ds_ready_go&& to_fs_valid){
    //     br_taken_cancel := true.B
    // }.elsewhen(br_taken_cancel && fs_to_ds_valid && io.ds_allowin){
    //     br_taken_cancel := false.B
    // }

    // when(io.br_taken&&io.ds_ready_go&& to_fs_valid && !br_taken_cancel){
    //     br_taken := true.B
    //     br_target := io.br_target
    // }.elsewhen(br_taken&&to_fs_valid && fs_allowin){
    //     br_taken := false.B
    // }

    //val inst = RegInit(0.U(32.W))

    //val inst_read = Module(new MEM())
    //val br_taken_cancel = Wire(Bool())
    val seq_pc = fs_pc + 4.U
    pc_next := Mux(io.br_taken,Mux(io.ds_valid,io.br_target,br_target), seq_pc)
    when(io.axi_in.arready && io.ds_ready_go){
        fs_pc_next := pc_next
    }

    //fs_ready_go := io.axi_in.rvalid 
    fs_ready_go := fs_valid
    fs_to_ds_valid := fs_valid  & fs_ready_go
    fs_allowin := !fs_valid || (fs_ready_go && io.ds_allowin)
    when(fs_allowin){
        fs_valid := to_fs_valid
    }
    when(to_fs_valid && fs_allowin){
        fs_pc := fs_pc_next
        fs_inst := io.axi_in.rdata(31,0)
    }

    //inst_read.io.Raddr := fs_pc
    //inst_read.io.Read_en := fs_valid
    io.fs_to_ds_valid := fs_to_ds_valid
    io.to_ds_pc := fs_pc

    //io.inst := inst_read.io.Rdata(31,0)
    // val inst_ready = RegInit(Bool(),true.B)
    // when(io.axi_in.rvalid && inst_ready && io.axi_in.rlast){
    //     inst_ready := 0.U
    // }.otherwise{
    //     inst_ready := 1.U
    // }

    io.axi_out.araddr := pc_next
    io.axi_out.arvalid := io.ds_ready_go
    io.axi_out.arlen := 0.U
    io.axi_out.arsize := 6.U
    io.axi_out.arburst := 0.U
    io.axi_out.rready := fs_allowin
    io.axi_out.awaddr := 0.U
    io.axi_out.wdata := 0.U
    io.axi_out.awvalid := false.B
    io.axi_out.awburst := 0.U
    io.axi_out.awlen := 0.U
    io.axi_out.awsize := 6.U
    io.axi_out.wstrb := 0.U
    io.axi_out.wvalid := false.B
    io.axi_out.wlast := false.B
    io.axi_out.bready := false.B
    io.inst := fs_inst
    io.pc_next := pc_next
    //inst := inst_read.io.Rdata(31,0)
    //printf("fs_pc:%x fs_valid:%d fs_allowin:%d fs_inst:%x arvalid:%d rvalid:%d rdata:%x next_pc:%x br_taken:%d fs_ds_valid:%d\n",fs_pc,fs_valid,fs_allowin,fs_inst,io.axi_out.arvalid,io.axi_in.rvalid,io.axi_in.rdata(31,0),pc_next,io.br_taken,fs_to_ds_valid)
}
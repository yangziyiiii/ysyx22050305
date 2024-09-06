package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class LSU extends Module{
    val io = IO(new Bundle{
        val pc = Input(UInt(64.W))
        val es_to_ms_valid = Input(Bool())
        val ws_allowin = Input(Bool())
        val ms_allowin = Output(Bool())
        val rf_we = Input(Bool())
        val rf_dst = Input(UInt(5.W))
        val alu_res = Input(UInt(64.W))
        val store_data = Input(UInt(64.W))
        val load_type = Input(UInt(3.W))
        val wen = Input(Bool())
        val wstrb = Input(UInt(8.W))
        val ren = Input(Bool())
        val maddr = Input(UInt(64.W))
        val to_ws_pc = Output(UInt(64.W))
        val ms_final_res = Output(UInt(64.W))
        val ms_to_ws_valid = Output(Bool())
        val to_ws_rf_we = Output(Bool())
        val to_ws_rf_dst = Output(UInt(5.W))
        val to_ws_device = Output(Bool())
        val ms_valid = Output(Bool())
        val ms_rf_we = Output(Bool())
        val ms_rf_dst = Output(UInt(5.W))
        val ms_fwd_ready = Output(Bool())
        val ms_fwd_res = Output(UInt(64.W))
        val ms_pc = Output(UInt(64.W))
        val axi_in = Input(new master_in())
        val axi_out = Output(new master_out())
    })
    val ms_valid = RegInit(Bool(),false.B)
    val ms_pc = RegInit(0.U(64.W))
    val ms_to_ws_valid = Wire(Bool())
    val ms_ready_go = Wire(Bool())
    val ms_allowin = Wire(Bool())
    val ms_rf_we = RegInit(Bool(),false.B)
    val ms_rf_dst = RegInit(0.U(5.W))
    val ms_res = RegInit(0.U(64.W))
    //val ms_sel_rf_res = RegInit(false.B(Bool()))
    val store_data = RegInit(0.U(64.W))
    val wen = RegInit(Bool(),false.B)
    val wstrb = RegInit(0.U(8.W))
    val ren = RegInit(Bool(),false.B)
    val maddr = RegInit(0.U(64.W))
    val load_type = RegInit(0.U(3.W))
    

    when(ms_allowin){
        ms_valid := io.es_to_ms_valid
    }
    when(io.es_to_ms_valid&&ms_allowin){
        ms_pc := io.pc
        ms_rf_we := io.rf_we
        ms_rf_dst := io.rf_dst
        ms_res := io.alu_res
        store_data := io.store_data
        wen := io.wen
        wstrb := io.wstrb
        ren := io.ren
        maddr := io.maddr
        load_type := io.load_type
        ms_ready_go := ~(io.wen || io.ren)
    }

    ms_ready_go := (wen && io.axi_in.bvalid) || (ren && io.axi_in.rvalid) || !(wen || ren)
    ms_allowin := !ms_valid || (ms_ready_go&&io.ws_allowin)
    ms_to_ws_valid := ms_valid && ms_ready_go
    
    
    val mem_rdata = Wire(UInt(64.W))
    mem_rdata := io.axi_in.rdata

    // when(ms_valid && wen && io.axi_in.wready){
    //     wen := false.B
    //     ms_ready_go := true.B
    // }.elsewhen(ms_valid && ren && io.axi_in.rvalid){
    //     mem_rdata := io.axi_in.rdata
    //     ren := false.B
    //     ms_ready_go := true.B
    // }
    

    io.axi_out.araddr := maddr
    io.axi_out.arvalid := ren && ms_valid
    io.axi_out.arlen := 0.U
    io.axi_out.arsize := 6.U
    io.axi_out.arburst := 0.U
    io.axi_out.rready := io.ws_allowin
    io.axi_out.awaddr := maddr
    io.axi_out.awvalid := wen && ms_valid
    io.axi_out.awlen := 0.U
    io.axi_out.awsize := 6.U
    io.axi_out.awburst := 0.U
    io.axi_out.wdata := store_data
    io.axi_out.wstrb := wstrb
    io.axi_out.wlast := true.B
    io.axi_out.wvalid := wen
    io.axi_out.bready := io.ws_allowin

    
    val rdata = MuxLookup(load_type,mem_rdata,Array(
        1.U -> Cat( Fill(32, mem_rdata(31)), mem_rdata(31,0)),
        2.U -> mem_rdata,
        3.U -> Cat( Fill(56, 0.U), mem_rdata(7,0)),
        4.U -> Cat( Fill(32, 0.U), mem_rdata(31,0)),
        5.U -> Cat( Fill(48, mem_rdata(15)), mem_rdata(15,0)),
        6.U -> Cat( Fill(56, mem_rdata(7)), mem_rdata(7,0)),
        7.U -> Cat( Fill(48, 0.U), mem_rdata(15,0)),
    ))
    io.ms_final_res := Mux(load_type=/=0.U,rdata,ms_res)
    io.ms_to_ws_valid := ms_to_ws_valid
    io.to_ws_rf_dst := ms_rf_dst
    io.to_ws_rf_we := ms_rf_we
    io.to_ws_pc := ms_pc
    io.to_ws_device := (maddr  >= "ha0000000".U) && (ren || wen)
    io.ms_allowin := ms_allowin
    io.ms_valid := ms_valid 
    io.ms_rf_dst := ms_rf_dst
    io.ms_rf_we := ms_rf_we&&ms_valid
    io.ms_pc := ms_pc
    io.ms_fwd_ready := ms_to_ws_valid
    io.ms_fwd_res := Mux(load_type=/=0.U,rdata,ms_res)
    //printf("ms_pc:%x ms_valid:%d rdata:%x rvalid:%d maddr:%x wstrb:%x wdata:%x\n\n",ms_pc,ms_valid,io.axi_in.rdata,io.axi_in.rvalid,maddr,wstrb,store_data)
}
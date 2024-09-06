package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class WBU extends Module{
    val io = IO(new Bundle{
        val pc = Input(UInt(64.W))
        val ms_to_ws_valid = Input(Bool())
        val ws_allowin = Output(Bool())
        val ms_final_res = Input(UInt(64.W))
        val rf_we = Input(Bool())
        val rf_dst = Input(UInt(5.W))
        val we = Output(Bool())
        val waddr = Output(UInt(5.W))
        val wdata = Output(UInt(64.W))
        val ws_valid = Output(Bool())
        val ws_rf_we = Output(Bool())
        val ws_rf_dst = Output(UInt(5.W))
        val ws_fwd_ready = Output(Bool())
        val ws_fwd_res = Output(UInt(64.W))
        val ws_pc = Output(UInt(64.W))

        val device_access = Input(Bool())
        val skip = Output(Bool())
    })
    val ws_valid = RegInit(Bool(),false.B)
    val ws_pc = RegInit(0.U(64.W))
    //val ms_to_ws_valid = Wire(Bool())
    val ws_ready_go = Wire(Bool())
    val ws_allowin = Wire(Bool())
    val ws_rf_we = RegInit(Bool(),false.B)
    val ws_rf_dst = RegInit(0.U(5.W))
    val ws_res = RegInit(0.U(64.W))
    val device_access = RegInit(Bool(),false.B)
    //val ms_sel_rf_res = RegInit(false.B(Bool()))
    //val store_data = RegInit(0.U(64.W))
    //val wen = RegInit(false.B(Bool()))
    //val wstrb = RegInit(0.U(8.W))
    //val ren = RegInit(false.B(Bool()))
    

    when(ws_allowin){
        ws_valid := io.ms_to_ws_valid
    }
    when(io.ms_to_ws_valid&&ws_allowin){
        ws_pc := io.pc
        ws_rf_we := io.rf_we
        ws_rf_dst := io.rf_dst
        ws_res := io.ms_final_res
        device_access := io.device_access
        //ms_sel_rf_res := io.sel_rf_res
        //store_data := io.store_data
        //wen := io.wen
        //wstrb := io.wstrb
        //ren := io.ren
    }

    ws_ready_go := true.B
    ws_allowin := !ws_valid || ws_ready_go
    //ms_to_ws_valid := ms_valid && ms_ready_go
    
    //io.ms_to_ws_valid := ms_to_ws_valid
    io.ws_allowin := ws_allowin
    io.we := ws_rf_we&&ws_valid
    io.waddr := ws_rf_dst
    io.wdata := ws_res
    io.ws_valid := ws_valid 
    io.ws_rf_dst := ws_rf_dst
    io.ws_rf_we := ws_rf_we
    io.ws_fwd_ready := true.B
    io.ws_fwd_res := ws_res
    io.ws_pc := ws_pc
    io.skip := device_access && ws_valid
    //printf("ws_pc:%x ws_valid:%d rf_dst:%d rf_we:%d wdata:%x\n",ws_pc,ws_valid,ws_rf_dst,io.we,ws_res)
}
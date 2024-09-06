package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class AXI_ARBITER extends Module{
    val io = IO(new Bundle{
        val ifu_axi_in = Input(new master_out())
        val ifu_axi_out = Output(new master_in())
        val lsu_axi_in = Input(new master_out())
        val lsu_axi_out = Output(new master_in())
        val axi_in = Input(new master_in())
        val axi_out = Output(new master_out())
    })

    val idle :: ifu_r_state :: lsu_r_state :: lsu_w_state :: Nil = Enum(4)
    val state = RegInit(idle)

    val init_master_in = Wire(new master_in())
    val init_master_out = Wire(new master_out())
    init_master_in.arready := false.B
    init_master_in.rdata := 0.U
    init_master_in.rvalid := false.B
    init_master_in.rlast := false.B
    init_master_in.awready := false.B
    init_master_in.wready := false.B
    init_master_in.bvalid := false.B
    init_master_out.araddr := 0.U
    init_master_out.arvalid := false.B
    init_master_out.arlen := 0.U
    init_master_out.arsize := 6.U
    init_master_out.arburst := 0.U
    init_master_out.rready := false.B
    init_master_out.awaddr := 0.U
    init_master_out.awvalid := false.B
    init_master_out.awlen := 0.U
    init_master_out.awsize := 6.U
    init_master_out.awburst := 0.U
    init_master_out.wdata := 0.U
    init_master_out.wstrb := 0.U
    init_master_out.wlast := false.B
    init_master_out.wvalid := false.B
    init_master_out.bready := false.B

    //printf("arbiter state:%d\n",state)
    //printf("ifu_arvalid:%d lsu_awvalid:%d lsu_arvalid:%d\n",io.ifu_axi_in.arvalid, io.lsu_axi_in.awvalid,io.lsu_axi_in.arvalid)
    io.axi_out := init_master_out
    io.lsu_axi_out := init_master_in
    io.ifu_axi_out := init_master_in
    switch(state){
        is(idle){
            when(io.lsu_axi_in.awvalid){
                state := lsu_w_state
                io.axi_out := io.lsu_axi_in
                io.lsu_axi_out := io.axi_in
            }.elsewhen(io.lsu_axi_in.arvalid){
                state := lsu_r_state
                io.axi_out := io.lsu_axi_in
                io.lsu_axi_out := io.axi_in
            }.elsewhen(io.ifu_axi_in.arvalid){
                state := ifu_r_state
                io.axi_out := io.ifu_axi_in
                io.ifu_axi_out := io.axi_in
            }
        }
        is(ifu_r_state){
            io.axi_out := io.ifu_axi_in
            io.ifu_axi_out := io.axi_in
            when(io.ifu_axi_out.rvalid && io.ifu_axi_in.rready && io.ifu_axi_out.rlast){
                state := idle 
            }
        }
        is(lsu_r_state){
            io.axi_out := io.lsu_axi_in
            io.lsu_axi_out := io.axi_in
            when(io.lsu_axi_out.rvalid && io.lsu_axi_in.rready && io.lsu_axi_out.rlast){
                state := idle
            }
        }
        is(lsu_w_state){
            io.axi_out := io.lsu_axi_in
            io.lsu_axi_out := io.axi_in
            when(io.lsu_axi_out.bvalid && io.lsu_axi_in.bready){
                state := idle
            }
        }
    }
}
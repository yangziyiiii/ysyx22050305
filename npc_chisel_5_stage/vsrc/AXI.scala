package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class AXI extends Module{
    val io = IO(new Bundle{
        val axi_in = Input(new master_out())
        val axi_out = Output(new master_in())
    })
    //val axi_awaddr = RegInit(0.U(32.W))
    val axi_awready = RegInit(1.U(1.W))
    val axi_wready = RegInit(1.U(1.W))
    //val axi_wdata = RegInit(0.U(64.W))
    //val axi_wstrb = RegInit(0.U(8.W))
    val axi_bvalid = RegInit(0.U(1.W))
    //val axi_araddr = RegInit(0.U(32.W))
    val axi_arready = RegInit(1.U(1.W))
    //val axi_rdata = RegInit(0.U(64.W))
    val axi_rvalid = RegInit(1.U(1.W))
    val arlen = RegInit(0.U(8.W))
    val awlen = RegInit(0.U(8.W))
    val araddr = RegInit(0.U(64.W))
    val awaddr = RegInit(0.U(64.W))

    val idle :: r_state :: w_state :: bv_state :: ar_state :: Nil = Enum(5)
    val state = RegInit(idle)

    val Mem_modle = Module(new MEM())
    Mem_modle.io.Raddr := Mux(state===idle,io.axi_in.araddr,araddr)
    Mem_modle.io.Waddr := Mux(state===idle,io.axi_in.awaddr,awaddr)
    Mem_modle.io.Wdata := io.axi_in.wdata
    Mem_modle.io.Wmask := io.axi_in.wstrb
    Mem_modle.io.Write_en := axi_wready.asBool && io.axi_in.awvalid
    Mem_modle.io.Read_en := axi_rvalid.asBool && io.axi_in.arvalid
    val mem_rdata = Mem_modle.io.Rdata
    //printf("axi_arready:%d axi_arvalid:%d\n",axi_arready,io.axi_in.arvalid)
    //printf("read_en:%d read_addr :%x rvalid:%d read_data:%x\n",Mem_modle.io.Read_en,Mem_modle.io.Raddr,axi_rvalid,mem_rdata)
    //printf("write_en:%d\n",Mem_modle.io.Write_en)
    switch(state){
        is(idle){
            when(io.axi_in.awvalid && io.axi_in.wvalid){
                when(io.axi_in.awlen===0.U){
                    state := bv_state
                    axi_awready := 0.U
                    axi_wready := 0.U
                    axi_bvalid := 1.U
                }.otherwise{
                    state := w_state
                    axi_awready := 0.U
                    //axi_wready := 1.U
                    //axi_bvalid := 1.U
                    awlen := io.axi_in.awlen - 1.U
                    awaddr := io.axi_in.awaddr + 8.U
                }
                
                
                //axi_awaddr := io.axi_in.araddr
                //axi_wdata := io.axi_in.wdata
                //axi_wstrb := io.axi_in.wstrb

            }.elsewhen(io.axi_in.arvalid){
                when(io.axi_in.arlen===0.U){
                    state := idle
                }.otherwise{
                    state := r_state
                    arlen := io.axi_in.arlen - 1.U
                    araddr := io.axi_in.araddr + 8.U
                    axi_arready := 0.U
                    //axi_rvalid := 1.U
                }
                
            }
        }
        is(w_state){
            when(awlen===0.U){
                axi_wready := 0.U
                axi_awready := 0.U
                //axi_wready := 0.U
                axi_bvalid := 1.U
                state := bv_state
            }.otherwise{
                when(io.axi_in.wvalid && axi_wready.asBool){
                    awaddr := awaddr + 8.U
                    awlen := awlen - 1.U
                }
            }
        }
        is(r_state){
            when(arlen===0.U){
                when(io.axi_in.rready){
                    state := idle
                    axi_arready := 1.U
                    //axi_rvalid := 0.U       
                }
            }.otherwise{
                when(io.axi_in.rready){
                    araddr := araddr + 8.U
                    arlen := arlen - 1.U
                }
            }
        }
        is(bv_state){
            when(io.axi_in.bready){
                state := idle
                axi_bvalid := 0.U
                axi_awready := 1.U
                axi_wready := 1.U
            }
        }
        // is(ar_state){
        //     when(io.axi_in.rready){
        //         state := idle
        //         axi_arready := 1.U
        //         axi_rvalid := 0.U
        //     }
        // }
    }
    io.axi_out.arready := axi_arready
    io.axi_out.rdata := mem_rdata
    io.axi_out.rvalid := axi_rvalid
    io.axi_out.rlast := (state===r_state && arlen===0.U) || io.axi_in.arlen===0.U
    io.axi_out.awready := axi_awready
    io.axi_out.wready := axi_wready
    io.axi_out.bvalid := axi_bvalid
}
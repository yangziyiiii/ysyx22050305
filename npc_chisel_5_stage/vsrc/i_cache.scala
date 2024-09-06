package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class I_CACHE extends Module{
    val io = IO(new Bundle{
        val from_ifu = Input(new master_out())
        val to_ifu = Output(new master_in())
        val to_axi = Output(new master_out())
        val from_axi = Input(new master_in())
        val cache_init = Output(Bool())
        val clear_cache = Input(Bool())
    })
    //printf("enter cache\n")
    val idle :: lookup ::  miss :: reload :: clear :: Nil = Enum(5)
    val cacheLine = Mem(256, UInt(128.W))
    val validMem = Mem(256, Bool())
    // 定义标记存储器和组索引
    val tagMem = Mem(256, UInt(32.W)) 
    //val w_idle :: write :: Nil = Enum(2)
    // val ram_0 = RegInit(VecInit(Seq.fill(16)(0.U(128.W))))
    // val ram_1 = RegInit(VecInit(Seq.fill(16)(0.U(128.W))))
    // val ram_2 = RegInit(VecInit(Seq.fill(16)(0.U(128.W))))
    // val ram_3 = RegInit(VecInit(Seq.fill(16)(0.U(128.W))))
    // val tag_0 = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
    // val tag_1 = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
    // val tag_2 = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
    // val tag_3 = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
    // val valid_0 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))
    // val valid_1 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))
    // val valid_2 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))
    // val valid_3 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))

    val addr = RegInit(0.U(32.W))
    val offset = addr(3,0)
    val index = addr(9,4)
    val tag = addr(31,10)
    val shift_bit = offset(2,0) << 3.U

    val valid = Wire(Vec(4, Bool()))
    for (i <- 0 until 4) {
        valid(i) := validMem((i.asUInt << 6.U) + index)
    }
    val allvalid = valid.reduce(_ && _)
    val foundUnvalidIndex = MuxCase(0.U, Seq(
        (!valid(0)) -> 0.U,
        (!valid(1)) -> 1.U,
        (!valid(2)) -> 2.U,
        (!valid(3)) -> 3.U
    ))
    val unvalidIndex = (foundUnvalidIndex << 6.U) + index
    

    val tagMatch = Wire(Vec(4, Bool()))
    for (i <- 0 until 4) {
        tagMatch(i) := valid(i) && (tagMem((i.asUInt << 6.U) + index) === tag)
    }
    val anyMatch = tagMatch.reduce(_ || _)
    val foundtagIndex = MuxCase(0.U, Seq(
        tagMatch(0) -> 0.U,
        tagMatch(1) -> 1.U,
        tagMatch(2) -> 2.U,
        tagMatch(3) -> 3.U
    ))
    val tagIndex = (foundtagIndex << 6.U) + index

    val replaceIndex = Wire(UInt(32.W))

    // val way0_hit = Wire(Bool())
    // val way1_hit = Wire(Bool())
    // val way2_hit = Wire(Bool())
    // val way3_hit = Wire(Bool())

    // val unuse_way = Wire(UInt(3.W))
    val receive_data = RegInit(VecInit(Seq.fill(2)(0.U(64.W))))
    val receive_num = RegInit(0.U(3.W))
    val quene = Mem(64, UInt(8.W))
    
    val replace_way = quene(index)(7,6)
    replaceIndex := (replace_way << 6.U) + index

    // way0_hit := (tag_0(index) === tag) && valid_0(index)===1.U
    
    // way1_hit := (tag_1(index) === tag) && valid_1(index)===1.U
    // way2_hit := (tag_2(index) === tag) && valid_2(index)===1.U
    // way3_hit := (tag_3(index) === tag) && valid_3(index)===1.U
    // unuse_way := Mux(valid_0(index)===0.U,1.U,Mux(valid_1(index)===0.U,2.U,Mux(valid_2(index)===0.U,3.U,Mux(valid_3(index)===0.U,4.U,0.U))))

    val state = RegInit(idle)
    //printf("i_cache state:%d\n",state)
    //printf("rdata:%x addr:%x\n",io.from_axi.rdata,addr )
    //printf("index:%d replace_way:%d quene:%d\n",index,replace_way,quene(index)(1,0))
    switch(state){
        is(idle){
            when(io.clear_cache){
                state := clear
            }.elsewhen(io.from_ifu.arvalid){
                addr := io.from_ifu.araddr
                state := lookup
            }    
        }
        is(lookup){
            when(anyMatch){
                when(io.from_ifu.rready){
                    state := idle
                }
            }.otherwise{
                state := miss
                receive_num := 0.U
            }
        }
        is(miss){
            when(io.from_axi.rvalid){
                receive_data(receive_num) := io.from_axi.rdata 
                receive_num := receive_num + 1.U
                when(io.from_axi.rlast){
                    state := reload
                }
            }
        }
        is(reload){
            state := lookup
            when(!allvalid){
                cacheLine(unvalidIndex) := Cat(receive_data(1),receive_data(0))
                tagMem(unvalidIndex) := tag
                validMem(unvalidIndex) := 1.U
                quene(index) := (quene(index) << 2.U) | foundUnvalidIndex
            }.otherwise{
                cacheLine(replaceIndex) := Cat(receive_data(1),receive_data(0))
                tagMem(replaceIndex) := tag
                validMem(replaceIndex) := 1.U
                quene(index) := (quene(index) << 2.U) | replace_way
            }
        }
        is(clear){
            for (i <- 0 until 64) {
                validMem.write(i.U, false.B)
            }
           state := idle
        }
    }
    val rdata = Wire(UInt(64.W))
    rdata := MuxLookup(offset(3,2),0.U,Array(
        0.U -> cacheLine(tagIndex)(31,0),
        1.U -> cacheLine(tagIndex)(63,32),
        2.U -> cacheLine(tagIndex)(95,64),
        3.U -> cacheLine(tagIndex)(127,96)
    ))
    when(state===lookup){
        io.to_axi.arvalid := false.B
        io.to_axi.araddr := addr
        io.to_axi.arlen := 0.U
        io.to_axi.arsize := 6.U
        io.to_axi.arburst := 0.U
        io.to_axi.rready := false.B
        io.to_axi.awaddr := 0.U
        io.to_axi.awvalid := false.B
        io.to_axi.awlen := 0.U
        io.to_axi.awsize := 6.U
        io.to_axi.awburst := 0.U
        io.to_axi.wdata := 0.U
        io.to_axi.wstrb := 0.U
        io.to_axi.wlast := false.B
        io.to_axi.wvalid := false.B
        io.to_axi.bready := false.B
        io.to_ifu.rdata :=  rdata
        io.to_ifu.arready := false.B
        io.to_ifu.rvalid := anyMatch
        io.to_ifu.rlast := anyMatch
        io.to_ifu.wready := false.B
        io.to_ifu.awready := false.B
        io.to_ifu.bvalid := false.B
    }.elsewhen(state===miss){
        io.to_ifu.rdata := 0.U
        io.to_ifu.arready := false.B
        io.to_ifu.rvalid := false.B
        io.to_ifu.rlast := false.B
        io.to_ifu.wready := false.B
        io.to_ifu.bvalid := false.B
        io.to_ifu.awready := false.B
        io.to_axi.arvalid := true.B
        io.to_axi.araddr := addr  & "hfffffffffffffff0".U
        io.to_axi.arlen := 1.U
        io.to_axi.arsize := 6.U
        io.to_axi.arburst := 1.U
        io.to_axi.rready := true.B
        io.to_axi.awaddr := 0.U
        io.to_axi.awvalid := false.B
        io.to_axi.awlen := 0.U
        io.to_axi.awsize := 6.U
        io.to_axi.awburst := 1.U
        io.to_axi.wdata := 0.U
        io.to_axi.wstrb := 0.U
        io.to_axi.wlast := false.B
        io.to_axi.wvalid := false.B
        io.to_axi.bready := false.B
    }.otherwise{
        io.to_ifu.rdata := 0.U
        io.to_ifu.arready := (state===idle)
        io.to_ifu.rvalid := false.B
        io.to_ifu.rlast := false.B
        io.to_ifu.wready := false.B
        io.to_ifu.bvalid := false.B
        io.to_ifu.awready := false.B
        io.to_axi.arvalid := false.B
        io.to_axi.araddr := addr
        io.to_axi.rready := io.from_ifu.rready
        io.to_axi.arlen := 0.U
        io.to_axi.arsize := 6.U
        io.to_axi.arburst := 0.U
        io.to_axi.awaddr := 0.U
        io.to_axi.awvalid := false.B
        io.to_axi.awlen := 0.U
        io.to_axi.awsize := 6.U
        io.to_axi.awburst := 0.U
        io.to_axi.wdata := 0.U
        io.to_axi.wstrb := 0.U
        io.to_axi.wlast := false.B
        io.to_axi.wvalid := false.B
        io.to_axi.bready := false.B         
    }
    io.cache_init := state===clear
    //printf("to ifu rdata:%x araddr:%x ram0:%x ram1:%x\n",io.to_ifu.rdata,io.from_ifu.araddr,ram_0(index),ram_1(index))
}
package  mycpu

import chisel3._
import chisel3.util._
import  Constants._

class D_CACHE extends Module{
    val io = IO(new Bundle{
        //val pc_now = Input(UInt(64.W))
        val from_lsu = Input(new master_out())
        val to_lsu = Output(new master_in())
        val to_axi = Output(new master_out())
        val from_axi = Input(new master_in())
    })
    //printf("enter cache\n")
    //printf("read addr : %x  write addr : %x\n",io.from_lsu.araddr,io.from_lsu.awaddr)
    val idle :: r_lookup :: w_lookup ::  r_miss :: w_miss :: reload :: write_back  :: Nil = Enum(7)
    //val w_idle :: write :: Nil = Enum(2)

    val offset = io.from_lsu.araddr(3,0) //here
    val index = io.from_lsu.araddr(7,4)//here
    val tag = io.from_lsu.araddr(31,8)//here

    val cacheLine = Mem(64, UInt(128.W)) // 64行，每行16字节  //here
    val validMem = Mem(64, Bool())

    // 定义标记存储器和组索引
    val tagMem = Mem(64, UInt(32.W)) // 使用 UInt(4.W) 表示 16 字节的块偏移
    val dirtyMem = Mem(64, Bool())
    // val tag_0 = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
    // val tag_1 = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
    // val valid_0 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))
    // val valid_1 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))
    // val dirty_0 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))
    // val dirty_1 = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))
    // val way0_hit = Wire(Bool())
    // val way1_hit = Wire(Bool())
    // 标记比较
    val valid = Wire(Vec(4, Bool()))
    for (i <- 0 until 4) {
        valid(i) := validMem((i.asUInt << 4.U) + index)
    }
    val allvalid = valid.reduce(_ && _)
    val foundUnvalidIndex = MuxCase(0.U, Seq(
        (!valid(0)) -> 0.U,
        (!valid(1)) -> 1.U,
        (!valid(2)) -> 2.U,
        (!valid(3)) -> 3.U
    ))
    val unvalidIndex = (foundUnvalidIndex << 4.U) + index
    

    val tagMatch = Wire(Vec(4, Bool()))
    for (i <- 0 until 4) {
        tagMatch(i) := valid(i) && (tagMem((i.asUInt << 4.U) + index) === tag)
    }
    val anyMatch = tagMatch.reduce(_ || _)
    val foundtagIndex = MuxCase(0.U, Seq(
        tagMatch(0) -> 0.U,
        tagMatch(1) -> 1.U,
        tagMatch(2) -> 2.U,
        tagMatch(3) -> 3.U
    ))
    val tagIndex = (foundtagIndex << 4.U) + index

    val replaceIndex = Wire(UInt(32.W))
    


    val write_back_data = RegInit(0.U(128.W))  //here
    val write_back_addr = RegInit(0.U(32.W))
    


    val receive_data = RegInit(VecInit(Seq.fill(2)(0.U(64.W))))  //here
    val receive_num = RegInit(0.U(3.W))
    val quene = Mem(16, UInt(8.W))
    //val index = Wire(UInt(32.W))
    val replace_way = quene(index)(7,6)
    replaceIndex := (replace_way << 4.U) + index
    val shift_bit = offset << 3.U
    val shift_bit_t = offset(2,0) << 3.U
    val rdata = Wire(UInt(64.W))
    val ldata = Wire(UInt(64.W))
    val change_data = Wire(UInt(64.W))
    
   
    val wmask = Wire(UInt(64.W))
    wmask :=    Mux(io.from_lsu.wstrb==="b1".U,"hff".U,
                Mux(io.from_lsu.wstrb==="b11".U,"hffff".U,
                Mux(io.from_lsu.wstrb==="hf".U,"hffffffff".U,
                Mux(io.from_lsu.wstrb==="hff".U,"hffffffffffffffff".U,0.U))))
    val mask_shift = Wire(UInt(64.W))
    mask_shift := wmask << shift_bit_t
    rdata := Mux(offset(3)===1.U,cacheLine(tagIndex)(127,64),cacheLine(tagIndex)(63,0))
    ldata := Mux(offset(3)===1.U,cacheLine(tagIndex)(63,0),cacheLine(tagIndex)(127,64))
    change_data := ((io.from_lsu.wdata & wmask) << shift_bit_t) | (rdata & ~(mask_shift))
    // way0_hit := (tag_0(index) === tag) && valid_0(index)===1.U
    
    // way1_hit := (tag_1(index) === tag) && valid_1(index)===1.U
        

    val state = RegInit(idle)
    //printf("d_cache state:%d validindex:%d tagindex:%d replaceindex:%d\n",state,unvalidIndex,tagIndex,replaceIndex)
    //printf("index:%d foundindex:%d %d\n\n",index,foundtagIndex,foundUnvalidIndex)
    //printf("bvalid:%d\n",io.from_axi.bvalid)
    //printf("receive data:%x\n",receive_data)
    //printf("wstrb:%x\n",io.from_lsu.wstrb)
    io.to_lsu.rdata := 0.U
    io.to_lsu.arready := state===idle
    io.to_lsu.rvalid := false.B
    io.to_lsu.rlast := false.B
    io.to_lsu.wready := false.B
    io.to_lsu.bvalid := false.B
    io.to_lsu.awready := state===idle
    io.to_axi.arvalid := false.B
    io.to_axi.araddr := io.from_lsu.araddr
    io.to_axi.rready := io.from_lsu.rready
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
    switch(state){
        is(idle){
            when((io.from_lsu.arvalid||io.from_lsu.awvalid)&& io.from_lsu.araddr >= "ha0000000".U){
                io.to_lsu := io.from_axi
                io.to_axi := io.from_lsu
                state := idle
            }.elsewhen(io.from_lsu.arvalid){
                state := r_lookup
            }.elsewhen(io.from_lsu.awvalid){
                state := w_lookup
            }
        }
        is(r_lookup){
            io.to_lsu.rdata := rdata >> shift_bit_t
            io.to_lsu.rvalid := anyMatch
            io.to_lsu.rlast := true.B
            when(anyMatch){
                when(io.from_lsu.rready){
                    state := idle
                }
            }.otherwise{
                state := r_miss
                receive_num := 0.U
            }
        }
        is(w_lookup){
            io.to_lsu.wready := anyMatch
            io.to_lsu.awready := false.B
            io.to_lsu.bvalid := anyMatch
            when(anyMatch){
                when(io.from_lsu.bready){
                    state := idle
                }
                //ram_0(index) := ((io.from_lsu.wdata & wmask) << shift_bit) | (ram_0(index) & ~(wmask << shift_bit))
                //change_data := ((io.from_lsu.wdata & wmask) << shift_bit_t) | (rdata & ~(wmask << shift_bit_t))
                cacheLine(tagIndex) := Mux(offset(3)===1.U,Cat(change_data,ldata),Cat(ldata,change_data))
                dirtyMem(tagIndex) := 1.U
                //tag_0(index) := io.from_lsu.waddr(31,7)
            }.otherwise{
                state := w_miss
            }
        }
        is(r_miss){
            io.to_axi.arvalid := true.B
            io.to_axi.araddr := io.from_lsu.araddr  & "hfffffffffffffff0".U //here
            io.to_axi.arlen := 1.U //here
            io.to_axi.arsize := 6.U
            io.to_axi.arburst := 1.U
            io.to_axi.rready := io.from_lsu.rready
            when(io.from_axi.rvalid){ 
                receive_data(receive_num) := io.from_axi.rdata
                receive_num := receive_num + 1.U
                when(io.from_axi.rlast){
                    state := reload
                }
            }
        }
        is(w_miss){
            io.to_lsu.wready := io.from_axi.wready
            io.to_lsu.bvalid := io.from_axi.bvalid
            io.to_lsu.awready := io.from_axi.awready
            io.to_axi.awaddr := io.from_lsu.awaddr
            io.to_axi.awvalid := io.from_lsu.awvalid
            io.to_axi.awlen := io.from_lsu.awlen
            io.to_axi.awsize := io.from_lsu.awsize
            io.to_axi.awburst := io.from_lsu.awburst
            io.to_axi.wdata := io.from_lsu.wdata
            io.to_axi.wstrb := io.from_lsu.wstrb
            io.to_axi.wlast := io.from_lsu.wlast
            io.to_axi.wvalid := io.from_lsu.wvalid
            io.to_axi.bready := io.from_lsu.bready
            when(io.from_axi.bvalid && io.from_lsu.bready){
                state := idle
            }
        }
        is(reload){
            when(!allvalid){
                state := r_lookup
                cacheLine(unvalidIndex) := Cat(receive_data(1),receive_data(0)) //here
                tagMem(unvalidIndex) := tag
                validMem(unvalidIndex) := 1.U
                //ram_0(index) := Cat(receive_data(1),receive_data(0))
                //tag_0(index) := tag
                //valid_0(index) := 1.U
                quene(index) := (quene(index) << 2.U) | foundUnvalidIndex
            }.otherwise{
                cacheLine(replaceIndex) := Cat(receive_data(1),receive_data(0)) //here
                tagMem(replaceIndex) := tag
                validMem(replaceIndex) := 1.U
                quene(index) := (quene(index) << 2.U) | replace_way
                when(dirtyMem(replaceIndex)===1.U){
                    //stae := write_back
                    write_back_data := cacheLine(replaceIndex)
                    write_back_addr := Cat(tagMem(replaceIndex) , index, Fill(4,0.U))  //here
                    dirtyMem(replaceIndex) := 0.U
                    state := write_back
                }.otherwise{
                    state := r_lookup
                }
            }
        }
        is(write_back){
            io.to_axi.awaddr := write_back_addr
            io.to_axi.awvalid := true.B
            io.to_axi.awlen := 1.U //here
            io.to_axi.awsize := 6.U
            io.to_axi.awburst := 1.U
            io.to_axi.wdata := write_back_data(63,0)
            io.to_axi.wstrb := "hff".U
            io.to_axi.wlast := true.B
            io.to_axi.wvalid := true.B
            io.to_axi.bready := true.B
            when(io.from_axi.wready){
                write_back_data := write_back_data >> 64.U
            }
            when(io.from_axi.bvalid){
                state := r_lookup
            }
        }
    }
    
    
    //printf("to lsu rdata:%x\n",io.to_lsu.rdata)
    //printf("cacheline0:%x   cacheline1:%x\n",ram_0(index),ram_1(index))
    //printf("record_wdata1:%x  record_wstrb1:%x record_pc:%x record_awaddr:%x record_olddata:%x\n",record_wdata1(index),record_wstrb1(index),record_pc(index),record_addr(index),record_olddata(index))
}
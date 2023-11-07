#include "./include/common.h"

void (*ref_difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;
void dump_gpr();
void exec_once();
uint8_t* guest_to_host(paddr_t paddr);

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

static bool is_skip_ref = false;
void difftest_skip_ref() {
  is_skip_ref = true;
}

void init_difftest(char *ref_so_file, long img_size, int port) {
    assert(ref_so_file != NULL);

    void *handle;
    handle = dlopen(ref_so_file, RTLD_LAZY);
    assert(handle);

    ref_difftest_memcpy = (void (*)(paddr_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
    assert(ref_difftest_memcpy);

    ref_difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
    assert(ref_difftest_regcpy);

    ref_difftest_exec = (void (*)(uint64_t))dlsym(handle, "difftest_exec");
    assert(ref_difftest_exec);

    ref_difftest_raise_intr = (void (*)(uint64_t))dlsym(handle, "difftest_raise_intr");
    assert(ref_difftest_raise_intr);

    void (*ref_difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
    assert(ref_difftest_init);

    printf("Differential testing: ON\n");
    printf("The result of every instruction will be compared with %s.\n", ref_so_file);

    ref_difftest_init(port);
    ref_difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_size, DIFFTEST_TO_REF);
    ref_difftest_regcpy(&npc_cpu, DIFFTEST_TO_REF);
    //printf("npc_pc:%lx\n", npc_cpu.pc);
}

bool difftest_checkregs(CPU_state *ref_r, vaddr_t pc){

    for(int i=0; i<32; i++){
        if(ref_r->gpr[i] != npc_cpu.gpr[i]){
            printf("ref_reg[%d]= 0x%lx  npc_reg[%d]= 0x%lx\n", i, ref_r->gpr[i], i, npc_cpu.gpr[i]);
            return false;
        }
    }
    if(ref_r->pc != npc_cpu.pc){
        printf("ref_pc:%lx\n", ref_r->pc);
        printf("npc_pc:%lx\n", npc_cpu.pc);
        return false;
    }
    return true;
}

static void checkregs(CPU_state *ref, vaddr_t pc) {
    if (!difftest_checkregs(ref, pc)) {
        printf("difftest_check error\n");
        npc_state.state = NPC_ABORT;
        npc_state.halt_pc = pc;
        dump_gpr();
        exec_once();
    }
}

void difftest_step(vaddr_t pc, vaddr_t npc) {
    CPU_state ref_r;

    if(is_skip_ref){
        ref_difftest_regcpy(&npc_cpu, DIFFTEST_TO_REF);
        is_skip_ref = false;
        return;
    }
    ref_difftest_exec(1);
    ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
 
    checkregs(&ref_r, pc);
}
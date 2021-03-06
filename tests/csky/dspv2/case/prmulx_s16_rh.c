#include "testsuite.h"
#include "test_device.h"
#include "dspv2_insn.h"
#include "sample_array.h"
int main(void)
{
    int i = 0;
    init_testsuite("Testing insn prmulx.s16.rh\n");

    for (i = 0;
         i < sizeof(samples_prmulx_s16_rh)/sizeof(struct binary_calculation);
         i++) {
        TEST(test_prmulx_s16_rh(samples_prmulx_s16_rh[i].op1, samples_prmulx_s16_rh[i].op2)
                     == samples_prmulx_s16_rh[i].result);
    }
    return done_testing();
}

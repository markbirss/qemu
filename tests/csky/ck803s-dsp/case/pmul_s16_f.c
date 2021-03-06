/* ---------------------------------------------------------------------------
 * Copyright (C) 2016 CSKY Limited. All rights reserved.
 *
 * Redistribution and use of this software in source and binary forms,
 * with or without modification, are permitted provided that the following
 * conditions are met:
 *   * Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   * Neither the name of CSKY Ltd. nor the names of CSKY's contributors may
 *     be used to endorse or promote products derived from this software without
 *     specific prior written permission of CSKY Ltd.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 * -------------------------------------------------------------------------- */
#include "testsuite.h"
#include "test_device.h"
#include "dsp_insn.h"
#define TEST_TIMES      11
int main(void)
{
    int i = 0;

    init_testsuite("Testing insn PMUL.S16.F \n");

    /*
     * PMUL.S16.F
     * rz = (lo_x * lo_y) << 1, rn = (hi_x * hi_y) << 1, signed & fraction
     */
    struct binary64_calculation bin64_sample[TEST_TIMES] = {
        {0x56785678, 0xc000b000, 0xd4c40000c9f50000},
        {0x12345678, 0x12345678, 0x0296b5203a69b080},
        {0x8080c0c0, 0x9090a0a0, 0x6f0090002f20f000},
        {0xf0007fff, 0x90000001, 0x0e0000000000fffe},
        {0x7fff8000, 0x80008000, 0x8001000080000000},
        {0x76540000, 0x8000abcd, 0x89ac000000000000},
        {0x76540000, 0x7fff7654, 0x7653135800000000},
        {0xabcd0000, 0x80000000, 0x5433000000000000},
        {0xabcdffff, 0x7fffabcd, 0xabcda8660000a866},
        {0x7fffffff, 0x7fff7654, 0x7ffe0002ffff1358},
        {0xffffffff, 0xffffffff, 0x0000000200000002},
    };

    for (i = 0; i < TEST_TIMES; i++) {
        TEST(test_pmul_s16_f(bin64_sample[i].op1, bin64_sample[i].op2)
                     == bin64_sample[i].result);
    }

    return done_testing();
}


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
#define TEST_TIMES      15
int main(void)
{
    int i = 0;

    init_testsuite("Testing insn MULA.U32.H \n");

    /*
     * MULA.U32.H
     * rz = rz + (rx * ry)[63:32], unsigned
     */
    struct ternary_calculation sample[TEST_TIMES] = {
        {0x00000001, 0x00000001, 0x00000000, 0x00000000},
        {0x00000001, 0x00000001, 0xffffffff, 0xffffffff},
        {0x00000001, 0x00000001, 0x80000000, 0x80000000},
        {0x00000001, 0x00000001, 0x7fffffff, 0x7fffffff},
        {0x00000001, 0xffffffff, 0xffffffff, 0xffffffff},
        {0x00000001, 0xffffffff, 0x80000000, 0x80000000},
        {0x00000001, 0xffffffff, 0x7fffffff, 0x7fffffff},
        {0x80000000, 0x80000000, 0xffffffff, 0x3fffffff},
        {0x80000000, 0x80000000, 0x80000000, 0xc0000000},
        {0x80000000, 0x80000000, 0x7fffffff, 0xbfffffff},
        {0x7fffffff, 0xffffffff, 0xffffffff, 0x7ffffffd},
        {0x7fffffff, 0xffffffff, 0x80000000, 0xfffffffe},
        {0x7fffffff, 0xffffffff, 0x7fffffff, 0xfffffffd},
        {0x00000000, 0x00000001, 0x00000000, 0x00000000},
        {0x00000001, 0x00000000, 0x00000000, 0x00000000},
    };

    for (i = 0; i < TEST_TIMES; i++) {
        TEST(test_mula_u32_h(sample[i].op1, sample[i].op2, sample[i].op3)
                     == sample[i].result);
    }

    return done_testing();
}


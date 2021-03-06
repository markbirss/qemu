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
/*
 * crt0.S -- startup codes for CK-CPU.
 *
 * Define a exception vector table
 *
 * Initial PSR register.
 * Initial VBR register, relocate exception vector table.
 * Initial sp(stack pointer) register.
 * Initial BSS section to "0"
 * Then goto "main".
 *
 * Copyright (C) 2008~2015  Hangzhou C-SKY Microsystems Co., Ltd
 */

.file "crt0.S"

/*
 * For importing variable or functions from script file "ckcpu.ld".
 */
.import __stack		/* The stack pointer from linking script file */
.import	__sbss		/* The end of bss from linking script file */
.import __ebss		/* The end of bss from linking script file */

/*
 * For importing variable or functions from other c or assemble files.
 */
.import main				/* The c codes entry */
.import coretimer_irq_handler
.import user1_int_irq_handler
.import user2_int_irq_handler
.import user3_int_irq_handler
.import user4_int_irq_handler

/* For exporting varialbe or functions */
.export	ckcpu_vsr_table	/* Vector table base address. */
.export __start				/* The system entry. */

.section .exp_table
/* Vector table space. */

.align 10
ckcpu_vsr_table:

.long __start
.rept 29
.long default_exception_handler
.endr
.long fpu_vsr_autovec
.long default_exception_handler

.long default_exception_handler
.long coret_vsr_autovec
.long default_exception_handler
/************test CSI use**************************/
.long user1_vsr_autovec
/************test CSI use**************************/
.long user2_vsr_autovec
/************test CSI use**************************/
.long user3_vsr_autovec
/************test CSI use**************************/
.long user4_vsr_autovec
.rept 25
.long default_exception_handler
.endr

/* The ckcpu startup codes. */
.text
	/*
	 *
	 * This is the codes first entry point. This is where it all
	 * begins...
	 */

__start:
	/*
	 * Init psr value, enable exception, disable interrupt and fast interrupt.
	 * psr = 0x80000100
	 */
	lrw	a3, 0x80000100
	mtcr	a3, psr

	/*
	 * Setup initial vector base table for interrupts and exceptions
	 */
	lrw	a2, ckcpu_vsr_table
	mtcr	a2, vbr

	/* Initialize the normal stack pointer from the linker definition. */
	lrw	a1, __stack
	mov	sp, a1

	/*
	 * Zero out the bss region.
	 * NOTE: __sbss must align 4
	 */
	lrw	a3, __sbss	/* Get start of bss from linking script file */
	lrw	a2, __ebss	/* Get end of bss from linking script file */
	subu	a2, a3		/* Calculate size of bss */
	lsri	a2, 2		/* Size of whole words */
	cmpnei	a2, 0
	bf	__goto_c
	movi	a1, 0		/* Set zero value to write */
2:
	stw	a1, (a3)	/* Zero next word */
	addi	a3, 4		/* Increase bss pointer */
	subi	a2, 1		/* Decrease counter */
	cmpnei	a2, 0
	bt	2b		/* Repeat for all bss */

	/*
	 * Assember start up done, C codes start here.
	 */
__goto_c:
	bsr	main

	/* Should never get here. */
__exit:
        lrw a1, 0x10002000
        stw a0, (a1, 0x0)
	//bkpt
	br	__exit

/*
 * default exception service routine, before r0 initialized
 */
	.text
	.balign 4
default_exception_handler:
	br	default_exception_handler
	rte

.weak coretimer_irq_handler
/*
 * coret interrupt vector handler
 */
	.text
	.balign 4
coret_vsr_autovec:
	/* save context */
	subi    sp, 28             /* Allocate space for all registers */
	stw     a0, (sp, 0)
	stw     a1, (sp, 4)
	stw     a2, (sp, 8)
	stw     a3, (sp, 12)
	stw     t0, (sp, 16)
	stw     t1, (sp, 20)
	stw     lr, (sp, 24)

	subi    sp, 8
	mfcr    a3, epsr
	stw     a3, (sp, 4)	/* save epsr registwr */
	mfcr    a2, epc
	stw     a2, (sp, 0)	/* save epc register */
	//psrset	ie

	bsr	coretimer_irq_handler

	ldw     a3, (sp, 0)
	mtcr    a3, epc		/* restore the epc */
	ldw     a2, (sp, 4)
	mtcr    a2, epsr	/* restore the epsr */
	addi    sp, 8

	/* restore all the regs */
	ldw     a0, (sp, 0)
	ldw     a1, (sp, 4)
	ldw     a2, (sp, 8)
	ldw     a3, (sp, 12)
	ldw     t0, (sp, 16)
	ldw     t1, (sp, 20)
	ldw     lr, (sp, 24)
	addi    sp, 28

	rte


/************test CSI use**************************/
.weak user1_int_irq_handler
/*
 *  user1 interrupt vector handler
 */
        .text
        .balign 4
user1_vsr_autovec:
	nie
	ipush 
        subi sp,0x4
        stw lr,(sp,0x0)
 
        jbsr     user1_int_irq_handler
        ldw lr,(sp,0x0)
        addi sp,0x4
        ipop
        nir
        

/************test CSI use**************************/
.weak user2_int_irq_handler
/*
 *  user2 interrupt vector handler
 */
        .text
        .balign 4
user2_vsr_autovec:
	nie
	ipush 
        subi sp,0x4
        stw lr,(sp,0x0)
 
        jbsr     user2_int_irq_handler
        ldw lr,(sp,0x0)
        addi sp,0x4
        ipop
        nir
        

/************test CSI use**************************/
.weak user3_int_irq_handler
/*
 *  user3 interrupt vector handler
 */
        .text
        .balign 4
user3_vsr_autovec:
        nie
        ipush
        subi sp,0x4
        stw lr,(sp,0x0)

        jbsr     user3_int_irq_handler
        ldw lr,(sp,0x0)
        addi sp,0x4
        ipop
        nir

/************test CSI use**************************/
.weak user4_int_irq_handler
/*
 *  user4 interrupt vector handler
 */
        .text
        .balign 4
user4_vsr_autovec:
        nie
        ipush
        subi sp,0x4
        stw lr,(sp,0x0)

        jbsr     user4_int_irq_handler
        ldw lr,(sp,0x0)
        addi sp,0x4
        ipop
        nir

/************test FPU test use**************************/
/*
 *  fpu test interrupt vector handler
 */
        .text
        .balign 4
fpu_vsr_autovec:
        /* do nothing. */
        subi sp, 0x4
        stw  r0, (sp, 0x0)
        mfcr r0, epc
        addi r0, r0, 4
        mtcr r0, epc
        ldw  r0, (sp, 0x0)
        addi sp, 0x4
        rte
        


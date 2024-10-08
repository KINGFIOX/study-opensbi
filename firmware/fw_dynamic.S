	/*
* SPDX-License-Identifier:
	BSD-2-Clause
	*
	*            Copyright (c) 2019 Western Digital Corporation or its affiliates.
	*
* Authors:
	*            Anup Patel <anup.patel@wdc.com>
	*/

#include <sbi/fw_dynamic.h>

#include "fw_base.S"

	.section     .entry, "ax", %progbits
	.align       3
	.global      fw_boot_hart
	/*
	*            This function is called very early even before
	*            fw_save_info() is called.
	*            We can only use a0, a1, and a2 registers here.
	*            The boot HART id should be returned in 'a0'.
	*/
fw_boot_hart:
	/*           Sanity(健全性测试) checks */
	li           a1, FW_DYNAMIC_INFO_MAGIC_VALUE
	REG_L        a0, FW_DYNAMIC_INFO_MAGIC_OFFSET(a2)
	bne          a0, a1, _start_hang                                               # check magic number
	li           a1, FW_DYNAMIC_INFO_VERSION_MAX
	REG_L        a0, FW_DYNAMIC_INFO_VERSION_OFFSET(a2)                            # 8(a2)
	bgt          a0, a1, _start_hang                                               # check version

	/*           Read boot HART id */
	li           a1, FW_DYNAMIC_INFO_VERSION_2
	blt          a0, a1, 2f                                                        # goto 2:
	REG_L        a0, FW_DYNAMIC_INFO_BOOT_HART_OFFSET(a2)                          # 40(a2)
	ret
2:
	li           a0, -1
	ret

	.section     .entry, "ax", %progbits
	.align       3
	.global      fw_save_info
	/*
	*            We can only use a0, a1, a2, a3, and a4 registers here.
	*            The a0, a1, and a2 registers will be same as passed by
	*            previous booting stage.
	*            Nothing to be returned here.
	*/
fw_save_info:
	/*           Save next arg1 in 'a1' */
	lla          a4, _dynamic_next_arg1                                            # a1 存放有 下一个阶段的 arg1
	REG_S        a1, (a4)                                                          # (_dynamic_next_arg1) <- fdt

	/*           Save version == 0x1 fields */
	//           这个数据结构, 请看 include/sbi/fw_dynamic.h 中的 struct fw_dynamic_info
	lla          a4, _dynamic_next_addr                                            # (_dynamic_next_addr) <- 16(a2)
	REG_L        a3, FW_DYNAMIC_INFO_NEXT_ADDR_OFFSET(a2)
	REG_S        a3, (a4)
	lla          a4, _dynamic_next_mode                                            # (_dynamic_next_mode) <- 24(a2)
	REG_L        a3, FW_DYNAMIC_INFO_NEXT_MODE_OFFSET(a2)
	REG_S        a3, (a4)
	lla          a4, _dynamic_options                                              # (_dynamic_options) <- 32(a2)
	REG_L        a3, FW_DYNAMIC_INFO_OPTIONS_OFFSET(a2)
	REG_S        a3, (a4)

	/*           Save version == 0x2 fields */
	li           a4, FW_DYNAMIC_INFO_VERSION_2                                     # (FW_DYNAMIC_INFO_VERSION_2) <- 8(a2)
	REG_L        a3, FW_DYNAMIC_INFO_VERSION_OFFSET(a2)
	blt          a3, a4, 2f
	lla          a4, _dynamic_boot_hart                                            # (_dynamic_boot_hart) <- 40(a2)
	REG_L        a3, FW_DYNAMIC_INFO_BOOT_HART_OFFSET(a2)
	REG_S        a3, (a4)
2:
	ret

	.section     .entry, "ax", %progbits
	.align       3
	.global      fw_next_arg1
	/*
	*            We can only use a0, a1, and a2 registers here.
	*            The a0, a1, and a2 registers will be same as passed by
	*            previous booting stage.
	*            The next arg1 should be returned in 'a0'.
	*/
fw_next_arg1:
	lla          a0, _dynamic_next_arg1
	REG_L        a0, (a0)
	ret

	.section     .entry, "ax", %progbits
	.align       3
	.global      fw_next_addr
	/*
	*            We can only use a0, a1, and a2 registers here.
	*            The next address should be returned in 'a0'.
	*/
fw_next_addr:
	lla          a0, _dynamic_next_addr                                            # 一个动态的地址
	REG_L        a0, (a0)
	ret

	.section     .entry, "ax", %progbits
	.align       3
	.global      fw_next_mode
	/*
	*            We can only use a0, a1, and a2 registers here.
	*            The next address should be returned in 'a0'
	*/
fw_next_mode:
	lla          a0, _dynamic_next_mode
	REG_L        a0, (a0)
	ret

	.section     .entry, "ax", %progbits
	.align       3
	.global      fw_options
	/*
	*            We can only use a0, a1, and a2 registers here.
	*            The 'a4' register will have default options.
	*            The next address should be returned in 'a0'.
	*/
fw_options:
	lla          a0, _dynamic_options
	REG_L        a0, (a0)
	ret

	.section     .data
	.align       3
_dynamic_next_arg1:
	RISCV_PTR    0x0
_dynamic_next_addr:
	RISCV_PTR    0x0
_dynamic_next_mode:
	RISCV_PTR    PRV_S
_dynamic_options:
	RISCV_PTR    0x0
_dynamic_boot_hart:
	RISCV_PTR    -1

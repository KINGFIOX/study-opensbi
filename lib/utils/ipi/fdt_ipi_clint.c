/*
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2020 Western Digital Corporation or its affiliates.
 *
 * Authors:
 *   Anup Patel <anup.patel@wdc.com>
 */

#include <sbi_utils/fdt/fdt_helper.h>
#include <sbi_utils/ipi/fdt_ipi.h>
#include <sbi_utils/sys/clint.h>

static struct clint_data clint_ipi;

static int ipi_clint_cold_init(void *fdt, int nodeoff,
			       const struct fdt_match *match)
{
	int rc;
	u32 max_hartid;
	unsigned long addr;

	rc = fdt_parse_max_hart_id(fdt, &max_hartid);
	if (rc)
		return rc;

	rc = fdt_get_node_addr_size(fdt, nodeoff, &addr, NULL);
	if (rc)
		return rc;

	/* TODO: We should figure-out CLINT has_64bit_mmio from DT node */
	clint_ipi.addr = addr;
	clint_ipi.first_hartid = 0;
	clint_ipi.hart_count = max_hartid + 1;
	clint_ipi.has_64bit_mmio = TRUE;

	return clint_cold_ipi_init(&clint_ipi);
}

static const struct fdt_match ipi_clint_match[] = {
	{ .compatible = "riscv,clint0" },
	{ },
};

struct fdt_ipi fdt_ipi_clint = {
	.match_table = ipi_clint_match,
	.cold_init = ipi_clint_cold_init,
	.warm_init = clint_warm_ipi_init,
	.exit = NULL,
	.send = clint_ipi_send,
	.clear = clint_ipi_clear,
};

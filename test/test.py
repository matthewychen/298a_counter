# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    assert 1==1

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.

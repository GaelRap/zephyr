# STM32H745I-Disco board configuration
# Copyright (c) 2022 Systerel (https://www.systerel.fr)
# SPDX-License-Identifier: Apache-2.0

board_runner_args(stm32cubeprogrammer "--erase" "--port=swd" "--reset=hw")

include(${ZEPHYR_BASE}/boards/common/stm32cubeprogrammer.board.cmake)

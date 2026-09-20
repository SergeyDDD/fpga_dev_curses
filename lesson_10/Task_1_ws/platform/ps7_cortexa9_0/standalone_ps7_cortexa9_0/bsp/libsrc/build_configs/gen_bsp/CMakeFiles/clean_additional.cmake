# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/sleep.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/xiltimer.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/xtimer_config.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/lib/libxiltimer.a"
  )
endif()

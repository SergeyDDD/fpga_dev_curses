# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_2_ws/platform/microblaze_0/standalone_microblaze_0/bsp/include/sleep.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_2_ws/platform/microblaze_0/standalone_microblaze_0/bsp/include/xiltimer.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_2_ws/platform/microblaze_0/standalone_microblaze_0/bsp/include/xtimer_config.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_2_ws/platform/microblaze_0/standalone_microblaze_0/bsp/lib/libxiltimer.a"
  )
endif()

# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/diskio.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/ff.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/ffconf.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/sleep.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs_config.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/xilrsa.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/xiltimer.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/include/xtimer_config.h"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilffs.a"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilrsa.a"
  "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_10/Task_1_ws/platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxiltimer.a"
  )
endif()

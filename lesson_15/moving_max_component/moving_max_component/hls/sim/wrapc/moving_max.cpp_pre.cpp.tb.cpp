// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
# 1 "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_15/cpp_source/moving_max.cpp"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 419 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_15/cpp_source/moving_max.cpp" 2
# 1 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/climits" 1 3
# 40 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/climits" 3

# 1 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h" 1 3
# 236 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h" 3
namespace std
{
  typedef long unsigned int size_t;
  typedef long int ptrdiff_t;


  typedef decltype(nullptr) nullptr_t;

}
# 258 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h" 3
namespace std
{
  inline namespace __cxx11 __attribute__((__abi_tag__ ("cxx11"))) { }
}
namespace __gnu_cxx
{
  inline namespace __cxx11 __attribute__((__abi_tag__ ("cxx11"))) { }
}
# 508 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h" 3
# 1 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/os_defines.h" 1 3
# 39 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/os_defines.h" 3
# 1 "/usr/include/features.h" 1 3 4
# 394 "/usr/include/features.h" 3 4
# 1 "/usr/include/features-time64.h" 1 3 4
# 20 "/usr/include/features-time64.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 21 "/usr/include/features-time64.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 1 3 4
# 19 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 20 "/usr/include/x86_64-linux-gnu/bits/timesize.h" 2 3 4
# 22 "/usr/include/features-time64.h" 2 3 4
# 395 "/usr/include/features.h" 2 3 4
# 480 "/usr/include/features.h" 3 4
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 481 "/usr/include/features.h" 2 3 4
# 502 "/usr/include/features.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 1 3 4
# 576 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 577 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/long-double.h" 1 3 4
# 578 "/usr/include/x86_64-linux-gnu/sys/cdefs.h" 2 3 4
# 503 "/usr/include/features.h" 2 3 4
# 526 "/usr/include/features.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/gnu/stubs.h" 1 3 4
# 10 "/usr/include/x86_64-linux-gnu/gnu/stubs.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/gnu/stubs-64.h" 1 3 4
# 11 "/usr/include/x86_64-linux-gnu/gnu/stubs.h" 2 3 4
# 527 "/usr/include/features.h" 2 3 4
# 40 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/os_defines.h" 2 3
# 509 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h" 2 3


# 1 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/cpu_defines.h" 1 3
# 512 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h" 2 3
# 42 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/climits" 2 3
# 1 "/home/serhii/Xilinx/2025.2/lnx64/tools/clang-16/lib/clang/16/include/limits.h" 1 3
# 21 "/home/serhii/Xilinx/2025.2/lnx64/tools/clang-16/lib/clang/16/include/limits.h" 3
# 1 "/usr/include/limits.h" 1 3 4
# 26 "/usr/include/limits.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/libc-header-start.h" 1 3 4
# 27 "/usr/include/limits.h" 2 3 4
# 195 "/usr/include/limits.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/posix1_lim.h" 1 3 4
# 27 "/usr/include/x86_64-linux-gnu/bits/posix1_lim.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/wordsize.h" 1 3 4
# 28 "/usr/include/x86_64-linux-gnu/bits/posix1_lim.h" 2 3 4
# 161 "/usr/include/x86_64-linux-gnu/bits/posix1_lim.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/local_lim.h" 1 3 4
# 38 "/usr/include/x86_64-linux-gnu/bits/local_lim.h" 3 4
# 1 "/usr/include/linux/limits.h" 1 3 4
# 39 "/usr/include/x86_64-linux-gnu/bits/local_lim.h" 2 3 4
# 81 "/usr/include/x86_64-linux-gnu/bits/local_lim.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/pthread_stack_min-dynamic.h" 1 3 4
# 23 "/usr/include/x86_64-linux-gnu/bits/pthread_stack_min-dynamic.h" 3 4
extern "C" {
extern long int __sysconf (int __name) noexcept (true);
}
# 82 "/usr/include/x86_64-linux-gnu/bits/local_lim.h" 2 3 4
# 162 "/usr/include/x86_64-linux-gnu/bits/posix1_lim.h" 2 3 4
# 196 "/usr/include/limits.h" 2 3 4



# 1 "/usr/include/x86_64-linux-gnu/bits/posix2_lim.h" 1 3 4
# 200 "/usr/include/limits.h" 2 3 4



# 1 "/usr/include/x86_64-linux-gnu/bits/xopen_lim.h" 1 3 4
# 64 "/usr/include/x86_64-linux-gnu/bits/xopen_lim.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/uio_lim.h" 1 3 4
# 65 "/usr/include/x86_64-linux-gnu/bits/xopen_lim.h" 2 3 4
# 204 "/usr/include/limits.h" 2 3 4
# 22 "/home/serhii/Xilinx/2025.2/lnx64/tools/clang-16/lib/clang/16/include/limits.h" 2 3
# 43 "/home/serhii/Xilinx/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/climits" 2 3
# 2 "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_15/cpp_source/moving_max.cpp" 2
# 1 "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_15/cpp_source/moving_max.h" 1






void moving_max(int in_data[64], int out_data[64]);
# 3 "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_15/cpp_source/moving_max.cpp" 2




void moving_max(int in_data[64], int out_data[64]) {
    int window[8];

INIT_LOOP:
    for (int k = 0; k < 8; k++) {


        window[k] = (-2147483647 -1);
    }

MAIN_LOOP:
    for (int n = 0; n < 64; n++) {
#pragma HLS PIPELINE II=1



        for (int k = (8 - 1); k > 0; k--) {
            window[k] = window[k - 1];
        }



        window[0] = in_data[n];



        int max_data = window[0];
        for (int k = 1; k < 8; k++) {
            max_data = max_data > window[k] ? max_data : window[k];
        }
        out_data[n] = max_data;
    }
}
#ifndef HLS_FASTSIM
#ifdef __cplusplus
extern "C"
#endif
void apatb_moving_max_ir(int *, int *);
#ifdef __cplusplus
extern "C"
#endif
void moving_max_hw_stub(int *in_data, int *out_data){
moving_max(in_data, out_data);
return ;
}
#ifdef __cplusplus
extern "C"
#endif
void refine_signal_handler();
#ifdef __cplusplus
extern "C"
#endif
void apatb_moving_max_sw(int *in_data, int *out_data){
refine_signal_handler();
apatb_moving_max_ir(in_data, out_data);
return ;
}
#endif
# 39 "/home/serhii/workspace/fpga/fpga_dev_curses/lesson_15/cpp_source/moving_max.cpp"


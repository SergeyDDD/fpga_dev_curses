/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include "platform.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xtmrctr.h"
#include "xinterrupt_wrap.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "sleep.h"

#include <stdbool.h>

#define BUTTONS_ACTIVE_LOW  1
#define LEDS_ACTIVE_LOW     0
#define BUTTON_MASK         0x03U
#define LED_MASK            0x0FU
#define SAMPLE_US           50000U

typedef enum {
    BUTTON_ID_DIR,
    BUTTON_ID_SPEED,
    NUM_OF_BUTTON_ID
} button_id_t;

typedef enum {
    RELEASED,
    VERIFY_PRESS,
    PRESSED,
    VERIFY_RELEASE
} button_state_t;

typedef enum {
    BLINK_MODE_75MS,
    BLINK_MODE_150MS,
    BLINK_MODE_300MS,
    BLINK_MODE_500MS,
    BLINK_MODE_OFF,
    NUM_OF_ACTIVE_BLINK_MODES = BLINK_MODE_OFF,
    NUM_OF_BLINK_MODES,
} blink_modes_t;

static XGpio leds, buttons;
static XTmrCtr timer;
static volatile bool button_pending = false;
static volatile bool forward = true;
static volatile uint32_t position;
static volatile blink_modes_t mode;
static uint32_t reload_value[NUM_OF_ACTIVE_BLINK_MODES]; 

#if SIMULATION_CONFIG == 0
static const uint32_t periods_ms[NUM_OF_ACTIVE_BLINK_MODES] = {75U, 150U, 300U, 500U};
#else
static const uint32_t periods_ms[NUM_OF_ACTIVE_BLINK_MODES] = {1U, 2U, 4U, 8U};
#endif

static void show_led(void)
{
    uint32_t value = (mode == BLINK_MODE_OFF) ? 0U : (1U << position);
    if (LEDS_ACTIVE_LOW)
        value = ~value;
    XGpio_DiscreteWrite(&leds, 1, value & LED_MASK);
}

static void program_led_timer(void)
{
    XTmrCtr_Stop(&timer, 0);
    XTmrCtr_WriteReg(timer.BaseAddress, 0, XTC_TCSR_OFFSET, XTC_CSR_INT_OCCURED_MASK);

    if (mode < NUM_OF_ACTIVE_BLINK_MODES) {
        XTmrCtr_SetOptions(&timer, 0, XTC_INT_MODE_OPTION |
                          XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
        XTmrCtr_SetResetValue(&timer, 0, reload_value[mode]);
        XTmrCtr_Reset(&timer, 0);
        XTmrCtr_Start(&timer, 0);
    }
    show_led();
}

// Timer interrupt vector handler
static void on_led_timer(void *reference, u8 number)
{
    (void)reference;
    if (number == 0U && mode < NUM_OF_ACTIVE_BLINK_MODES) {
        position = (position + (forward ? 1U : 3U)) % 4U;
        show_led();
    }
}

// GPIO buttons interrupt vector handler
static void on_gpio(void *reference)
{
    XGpio *gpio = (XGpio *)reference;
    if (XGpio_InterruptGetStatus(gpio) & XGPIO_IR_CH1_MASK) {
        XGpio_InterruptGlobalDisable(gpio);
        XGpio_InterruptClear(gpio, XGPIO_IR_CH1_MASK);
        button_pending = true;
    }
}

static uint32_t read_buttons(void)
{
    uint32_t value = XGpio_DiscreteRead(&buttons, 1);
    if (BUTTONS_ACTIVE_LOW)
        value = ~value;
    return value & BUTTON_MASK;
}

static void buttons_press_proc(void)
{
    uint32_t raw = 0;

    while (1) {
        if (!button_pending) {
            continue;
        }

        do {
            raw = read_buttons();
            if (raw == 0) break;

            usleep(SAMPLE_US);

            raw = read_buttons();
            if (raw == 0) break;

            const bool direction_press = (raw & 1U) != 0;
            const bool speed_press = (raw & 2U) != 0;

            if (direction_press)
                forward = !forward;

            if (speed_press) {
                mode = (mode + 1U) % NUM_OF_BLINK_MODES;
                program_led_timer();
            }
        } while(0);

        button_pending = false;
        XGpio_InterruptGlobalEnable(&buttons);
    }
}

static int init_device()
{
    int status;

    Xil_ExceptionDisableMask(XIL_EXCEPTION_IRQ);

    mode = BLINK_MODE_75MS;

    status = XGpio_Initialize(&leds, XPAR_AXI_GPIO_LED_BASEADDR);
    if (status != XST_SUCCESS)
        return status;
//    XGpio_SetDataDirection(&leds, 1, 0U);

    show_led();

    status = XGpio_Initialize(&buttons, XPAR_AXI_GPIO_BUTTON_BASEADDR);
    if (status != XST_SUCCESS)
        return status;

//    XGpio_SetDataDirection(&buttons, 1, BUTTON_MASK);

    XGpio_InterruptGlobalDisable(&buttons);
    XGpio_InterruptDisable(&buttons, XGPIO_IR_CH1_MASK);
    XGpio_InterruptClear(&buttons, XGPIO_IR_CH1_MASK);

    status = XTmrCtr_Initialize(&timer, XPAR_AXI_TIMER_0_BASEADDR);
    if (status != XST_SUCCESS)
        return status;

    XTmrCtr_Stop(&timer, 0);
    XTmrCtr_SetHandler(&timer, on_led_timer, &timer);

    xil_printf("AXI Timer clock: %u Hz\r\n", (unsigned)timer.Config.SysClockFreqHz);

    // TIMING_INTERVAL = (TLRx + 2) * AXI_CLOCK_PERIOD
    // AXI Timer v2.0LogiCORE IP Product GuideVivado Design SuitePG079 (v2.0) August 15, 2025
    // page 21
    for (uint32_t i = 0; i < NUM_OF_ACTIVE_BLINK_MODES; ++i) {
        uint64_t clocks = ((uint64_t)timer.Config.SysClockFreqHz * periods_ms[i] + 500U) / 1000U;
        if (clocks < 2U || (clocks - 2U) > 0xFFFFFFFFULL) {
            status = XST_FAILURE;
            return status;
        }
        reload_value[i] = (uint32_t)(clocks - 2U);
    }

    status = XSetupInterruptSystem(&timer,
                  (XInterruptHandler)XTmrCtr_InterruptHandler,
                  timer.Config.IntrId, timer.Config.IntrParent,
                  XINTERRUPT_DEFAULT_PRIORITY);
    if (status != XST_SUCCESS)
        return status;

    status = XSetupInterruptSystem(&buttons, (XInterruptHandler)on_gpio,
                  XPAR_AXI_GPIO_BUTTON_INTERRUPTS,
                  XPAR_AXI_GPIO_BUTTON_INTERRUPT_PARENT,
                  XINTERRUPT_DEFAULT_PRIORITY);
    if (status != XST_SUCCESS)
        return status;

    program_led_timer();

    XGpio_InterruptEnable(&buttons, XGPIO_IR_CH1_MASK);
    XGpio_InterruptGlobalEnable(&buttons);

    Xil_ExceptionEnableMask(XIL_EXCEPTION_IRQ);

    print("Device successfully configured\n\r");

    return status;
}

int main()
{
    init_platform();

    print("Run application\n\r");
    
    const int status = init_device();
    if (status == 0)
        buttons_press_proc();

    xil_printf("Initialization failed, status = %d\r\n", status);
    cleanup_platform();

    return XST_FAILURE; 
}

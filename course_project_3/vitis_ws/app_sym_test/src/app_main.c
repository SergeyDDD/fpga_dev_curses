#include "xparameters.h"
#include <stdint.h>
#include "hub75_driver.h"
#include "xil_printf.h"
#include "platform.h"

#define HUB75_BASE XPAR_HUB75_CONTROLLER_0_BASEADDR
#define FRAME_MEMORY_BASE XPAR_AXI_BRAM_CTRL_0_BASEADDR

static void FillFrameBuffer(const Hub75 *instance)
{
    uint8_t *address;
    uint32_t offset;

    address = (uint8_t *) instance->frame_memory_base;
    for (offset = 0; offset < HUB75_FRAME_BYTES; offset++, address++)
    {
        const uint8_t upper = offset & 0x07;
        const uint8_t lower = ((HUB75_FRAME_BYTES - 1 - offset) & 0x07) << 4;
        const uint8_t pair = upper | lower;
        *address = pair;
    }
}

int main(void)
{
    Hub75 panel;

    Hub75_Init(&panel, (uintptr_t)HUB75_BASE, (uintptr_t)FRAME_MEMORY_BASE);

    if (Hub75_SetControl(&panel, 0U, 0U) != HUB75_OK ||
        Hub75_WaitStatus(&panel, 0U, 0U, 100000U) != HUB75_OK)
        goto error;

    FillFrameBuffer(&panel);

    if (Hub75_SetTiming(&panel, 2U, 2U, 2U) != HUB75_OK)
        goto error;

    if (Hub75_SetDisplay(&panel, 4000U, 2000U) != HUB75_OK)
        goto error;

    if (Hub75_ReadRegister(&panel, HUB75_REG_TIMING) != 0x222U)
        goto error;

    if (Hub75_ReadRegister(&panel, HUB75_REG_DISPLAY) != ((2000U << 16) | 4000U))
        goto error;
    
    if (Hub75_SetControl(&panel, 1U, 0) != HUB75_OK)
        goto error;

    while(1);

error:
    xil_printf("ERROR: STATUS=%lx\r\n", (unsigned long)Hub75_GetStatus(&panel));
    cleanup_platform();
    return 1;
}
 
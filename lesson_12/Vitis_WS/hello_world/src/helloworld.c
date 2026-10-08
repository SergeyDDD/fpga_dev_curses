#include "platform.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"
#include "streamer.h"

#define GPIO_DATA           0x00U
#define GPIO_TRI            0x04U
#define BUTTON_MASK         1U
#define BUTTON_ACTIVE_LOW   1
#define FRAME_TIMEOUT_MS    0U // Poll without timed sleeps

static int button_pressed(void)
{
    u32 level = Xil_In32(XPAR_AXI_GPIO_0_BASEADDR + GPIO_DATA) & BUTTON_MASK;
    return BUTTON_ACTIVE_LOW ? (level == 0U) : (level != 0U);
}

/*
   Debounce is not implemented to speed up the simulation.
 */
static void wait_button(int pressed)
{
    while (button_pressed() != pressed);
}

int main(void)
{
    Streamer streamer = {
        .control_base       = XPAR_STREAMER_TOP_0_BASEADDR,
        .dma_base           = XPAR_AXI_DMA_0_BASEADDR,
        .frame_base         = XPAR_AXI4_FULL_RAM_0_BASEADDR,
        .frame_capacity     = XPAR_AXI4_FULL_RAM_0_HIGHADDR - XPAR_AXI4_FULL_RAM_0_BASEADDR + 1U,
        .dma_length_bits    = XPAR_AXI_DMA_0_SG_LENGTH_WIDTH,
        .active = 0
    };
    int rc;
    u32 frame = 0;

    init_platform();

    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + GPIO_TRI, BUTTON_MASK);
    if (streamer.dma_length_bits < 16U) {
        xil_printf("DMA length width=%lu: need >=16 for 64000 bytes.\r\n", (unsigned long)streamer.dma_length_bits);
        xil_printf("Wrong DMA config in Vivado.\r\n");
        goto stop;
    }

    rc = Streamer_Init(&streamer);
    if (rc != STREAMER_OK) goto error;

    for (;;) {
        wait_button(0);
        xil_printf("Press button to capture a frame.\r\n");
        wait_button(1);

        rc = Streamer_Start(&streamer);
        if (rc != STREAMER_OK) goto error;

        rc = Streamer_Wait(&streamer, FRAME_TIMEOUT_MS);
        if (rc != STREAMER_OK) goto error;

        xil_printf("Frame %lu: 64000 bytes at 0x%08lx.\r\n", (unsigned long)++frame, (unsigned long)streamer.frame_base);
    }
error:
    xil_printf("Capture failed: rc=%d, busy=%lu, S2MM_DMASR=0x%08lx.\r\n",
               rc,
               (unsigned long)Streamer_Busy(&streamer),
               (unsigned long)Streamer_DmaStatus(&streamer));
stop:
    for (;;);
}

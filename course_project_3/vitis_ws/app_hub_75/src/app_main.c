#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#include "hub75_driver.h"
#include "ui_graph.h"
#include "ui_text.h"

#define HUB75_BASE XPAR_HUB75_CONTROLLER_0_BASEADDR
#define FRAME_MEMORY_BASE XPAR_AXI_BRAM_CTRL_0_BASEADDR


int UI_Run(Hub75 *panel)
{
    UI_Graph graph;
    uintptr_t buffer_address;

    if (Hub75_SetControl(panel, 0U, 0U) != HUB75_OK ||
        Hub75_WaitStatus(panel, 0U, 0U, 100000U) != HUB75_OK)
        return HUB75_ERROR;

    buffer_address = panel->frame_memory_base + HUB75_FRAME_BYTES;
    UI_Graph_Init(&graph, (volatile uint8_t *)buffer_address);
    UI_Graph_Clear(&graph, UI_COLOR_BLACK);

    UI_Text_DrawString(&graph, 2, 1,  "Курсовий проєкт HUB75", UI_COLOR_WHITE, UI_COLOR_BLACK, 0);
    UI_Text_DrawString(&graph, 3, 10, "LED Display Driver", UI_COLOR_RED, UI_COLOR_BLACK, 0);
    UI_Text_DrawString(&graph, 2, 20, "Xilinx ARTIX XC7A200T", UI_COLOR_YELLOW, UI_COLOR_BLACK, 0);

    UI_Graph_FillRect(&graph, 30, 30, 40, 34, UI_COLOR_BLUE);
    UI_Graph_FillCircle(&graph, 80, 47, 15,  UI_COLOR_RED);
    UI_Graph_FillCircle(&graph, 100, 47, 10, UI_COLOR_YELLOW);
    UI_Graph_FillCircle(&graph, 114, 47, 5, UI_COLOR_GREEN);
    

    UI_Graph_VLine(&graph, 7,  29, 26, UI_COLOR_RED);
    UI_Graph_VLine(&graph, 10,  30, 26, UI_COLOR_GREEN);
    UI_Graph_VLine(&graph, 13, 31, 26, UI_COLOR_BLUE);
    UI_Graph_VLine(&graph, 16, 32, 26, UI_COLOR_CYAN);
    UI_Graph_VLine(&graph, 19, 33, 26, UI_COLOR_MAGENTA);
    UI_Graph_VLine(&graph, 22, 34, 26, UI_COLOR_YELLOW);
    UI_Graph_VLine(&graph, 25, 35, 26, UI_COLOR_WHITE);

    UI_Graph_HLine(&graph, 95,  30, 30, UI_COLOR_RED);
    UI_Graph_HLine(&graph, 100, 33, 25, UI_COLOR_GREEN);
    UI_Graph_HLine(&graph, 105, 36, 20, UI_COLOR_BLUE);

    if (Hub75_SetTiming(panel, 2U, 2U, 2U) != HUB75_OK ||
        Hub75_SetDisplay(panel, 5000, 5000) != HUB75_OK ||
        Hub75_SetControl(panel, 1U, 1U) != HUB75_OK)
        return HUB75_ERROR;

    return Hub75_WaitStatus(panel, 1U, 1U, 100000U);
}  


int main()
{
    init_platform();

    print("Hello World\n\r");
    print("Successfully ran Hello World application");

    Hub75 panel;

    Hub75_Init(&panel, (uintptr_t)HUB75_BASE, (uintptr_t)FRAME_MEMORY_BASE);

    if (UI_Run(&panel) != HUB75_OK)
        goto error;

    while(1);

error:
    xil_printf("ERROR: STATUS=%lx\r\n", (unsigned long)Hub75_GetStatus(&panel));
    cleanup_platform();
    return 1; 
}

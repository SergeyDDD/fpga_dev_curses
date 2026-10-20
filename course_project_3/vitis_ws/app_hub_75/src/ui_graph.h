#ifndef UI_GRAPH_H
#define UI_GRAPH_H

#include <stdint.h>

#define UI_GRAPH_WIDTH       128
#define UI_GRAPH_HEIGHT      64
#define UI_GRAPH_FRAME_BYTES 4096

#define UI_COLOR_BLACK  0U
#define UI_COLOR_RED    4U
#define UI_COLOR_GREEN  1U
#define UI_COLOR_BLUE   2U

#define UI_COLOR_CYAN    ((UI_COLOR_BLUE) + (UI_COLOR_GREEN))
#define UI_COLOR_MAGENTA ((UI_COLOR_BLUE) + (UI_COLOR_RED))
#define UI_COLOR_YELLOW  ((UI_COLOR_GREEN) + (UI_COLOR_RED))
#define UI_COLOR_WHITE   ((UI_COLOR_BLUE) + (UI_COLOR_GREEN) + (UI_COLOR_RED))

typedef struct {
    volatile uint8_t *buffer;
} UI_Graph;

/*
   buffer points to one 4096-byte frame (A or B), in RAM or uncached BRAM.
 */
void UI_Graph_Init(UI_Graph *graph, volatile uint8_t *buffer);
void UI_Graph_SetPixel(UI_Graph *graph, int32_t x, int32_t y, uint8_t color);
uint8_t UI_Graph_GetPixel(const UI_Graph *graph, int32_t x, int32_t y);
void UI_Graph_Clear(UI_Graph *graph, uint8_t color);

void UI_Graph_HLine(UI_Graph *graph, int32_t x, int32_t y, int32_t length, uint8_t color);
void UI_Graph_VLine(UI_Graph *graph, int32_t x, int32_t y, int32_t length, uint8_t color);
void UI_Graph_FillRect(UI_Graph *graph, int32_t x, int32_t y,
                       int32_t width, int32_t height, uint8_t color);
void UI_Graph_FillCircle(UI_Graph *graph, int32_t center_x, int32_t center_y,
                         int32_t radius, uint8_t color);

#endif

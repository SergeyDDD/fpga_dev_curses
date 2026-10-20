#ifndef UI_TEXT_H
#define UI_TEXT_H

#include <stdint.h>
#include "ui_graph.h"

#define UI_TEXT_GLYPH_WIDTH  5
#define UI_TEXT_GLYPH_HEIGHT 8
#define UI_TEXT_ADVANCE     6
#define UI_TEXT_LINE_HEIGHT 8

void UI_Text_DrawChar(UI_Graph *graph, int32_t x, int32_t y, uint32_t codepoint,
                     uint8_t foreground, uint8_t background, uint8_t opaque);

void UI_Text_DrawString(UI_Graph *graph, int32_t x, int32_t y, const char *text,
                       uint8_t foreground, uint8_t background, uint8_t opaque);

#endif

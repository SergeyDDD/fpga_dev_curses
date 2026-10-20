#include "ui_graph.h"

static int graph_ready(const UI_Graph *graph)
{
    return graph != 0 && graph->buffer != 0;
}

static int clip_interval(int32_t start, int32_t length, int32_t limit,
                         int32_t *first, int32_t *end)
{
    int64_t finish;

    if (length <= 0)
        return 0;

    finish = (int64_t)start + length;
    if (start >= limit || finish <= 0)
        return 0;

    *first = start < 0 ? 0 : start;
    *end = finish > limit ? limit : (int32_t)finish;
    return 1;
}

void UI_Graph_Init(UI_Graph *graph, volatile uint8_t *buffer)
{
    if (graph != 0)
        graph->buffer = buffer;
}

void UI_Graph_SetPixel(UI_Graph *graph, int32_t x, int32_t y, uint8_t color)
{
    uint32_t offset;
    uint8_t pair;

    if (!graph_ready(graph) || x < 0 || x >= UI_GRAPH_WIDTH ||
        y < 0 || y >= UI_GRAPH_HEIGHT)
        return;

    offset = ((uint32_t)y % 32U) * UI_GRAPH_WIDTH + (uint32_t)x;
    pair = graph->buffer[offset];
    color &= 7U;
    if (y < 32)
        pair = (uint8_t)((pair & 0x8FU) | (color << 4));
    else
        pair = (uint8_t)((pair & 0xF8U) | color);
    graph->buffer[offset] = pair;
}

uint8_t UI_Graph_GetPixel(const UI_Graph *graph, int32_t x, int32_t y)
{
    uint8_t pair;

    if (!graph_ready(graph) || x < 0 || x >= UI_GRAPH_WIDTH ||
        y < 0 || y >= UI_GRAPH_HEIGHT)
        return 0;

    pair = graph->buffer[((uint32_t)y % 32U) * UI_GRAPH_WIDTH + (uint32_t)x];
    return y < 32 ? (uint8_t)((pair >> 4) & 7U) : (uint8_t)(pair & 7U);
}

void UI_Graph_Clear(UI_Graph *graph, uint8_t color)
{
    uint32_t offset;
    uint8_t pair;

    if (!graph_ready(graph))
        return;

    color &= 7U;
    pair = (uint8_t)((color << 4) | color);
    for (offset = 0; offset < UI_GRAPH_FRAME_BYTES; offset++)
        graph->buffer[offset] = (uint8_t)((graph->buffer[offset] & 0x88U) | pair);
}

void UI_Graph_HLine(UI_Graph *graph, int32_t x, int32_t y, int32_t length, uint8_t color)
{
    int32_t first, end;

    if (y < 0 || y >= UI_GRAPH_HEIGHT ||
        !clip_interval(x, length, UI_GRAPH_WIDTH, &first, &end))
        return;

    for (x = first; x < end; x++)
        UI_Graph_SetPixel(graph, x, y, color);
}

void UI_Graph_VLine(UI_Graph *graph, int32_t x, int32_t y, int32_t length, uint8_t color)
{
    int32_t first, end;

    if (x < 0 || x >= UI_GRAPH_WIDTH ||
        !clip_interval(y, length, UI_GRAPH_HEIGHT, &first, &end))
        return;

    for (y = first; y < end; y++)
        UI_Graph_SetPixel(graph, x, y, color);
}

void UI_Graph_FillRect(UI_Graph *graph, int32_t x, int32_t y,
                       int32_t width, int32_t height, uint8_t color)
{
    int32_t first_x, end_x, first_y, end_y;

    if (!clip_interval(x, width, UI_GRAPH_WIDTH, &first_x, &end_x) ||
        !clip_interval(y, height, UI_GRAPH_HEIGHT, &first_y, &end_y))
        return;

    for (y = first_y; y < end_y; y++)
        UI_Graph_HLine(graph, first_x, y, end_x - first_x, color);
}

void UI_Graph_FillCircle(UI_Graph *graph, int32_t center_x, int32_t center_y,
                         int32_t radius, uint8_t color)
{
    int32_t x, y;
    int32_t first_x, end_x, first_y, end_y;
    int32_t span_start, span_end;
    int64_t left, right, top, bottom, distance_x, distance_y;
    uint64_t radius_squared, distance_squared;

    if (!graph_ready(graph) || radius < 0)
        return;

    left = (int64_t)center_x - radius;
    right = (int64_t)center_x + radius;
    top = (int64_t)center_y - radius;
    bottom = (int64_t)center_y + radius;
    if (left >= UI_GRAPH_WIDTH || right < 0 || top >= UI_GRAPH_HEIGHT || bottom < 0)
        return;

    first_x = left < 0 ? 0 : (int32_t)left;
    end_x = right >= UI_GRAPH_WIDTH ? UI_GRAPH_WIDTH - 1 : (int32_t)right;
    first_y = top < 0 ? 0 : (int32_t)top;
    end_y = bottom >= UI_GRAPH_HEIGHT ? UI_GRAPH_HEIGHT - 1 : (int32_t)bottom;
    radius_squared = (uint64_t)radius * (uint64_t)radius;

    for (y = first_y; y <= end_y; y++) {
        span_start = -1;
        span_end = -1;
        distance_y = (int64_t)y - center_y;
        for (x = first_x; x <= end_x; x++) {
            distance_x = (int64_t)x - center_x;
            distance_squared = (uint64_t)(distance_x * distance_x) +
                               (uint64_t)(distance_y * distance_y);
            if (distance_squared <= radius_squared) {
                if (span_start < 0)
                    span_start = x;
                span_end = x;
            }
        }
        if (span_start >= 0)
            UI_Graph_HLine(graph, span_start, y, span_end - span_start + 1, color);
    }
}

#include "hub75_driver.h"
#include "xil_io.h"


static uintptr_t frame_address(const Hub75 *instance, uint8_t buffer_id)
{
    return instance->frame_memory_base + (uintptr_t)buffer_id * HUB75_FRAME_BYTES;
}

static uint8_t pack_pair(uint8_t upper_rgb, uint8_t lower_rgb)
{
    return (uint8_t)((upper_rgb << 4) | lower_rgb);
}

void Hub75_Init(Hub75 *instance, uintptr_t register_base, uintptr_t frame_memory_base)
{
    instance->register_base = register_base;
    instance->frame_memory_base = frame_memory_base;
}

uint32_t Hub75_ReadRegister(const Hub75 *instance, uint32_t offset)
{
    return Xil_In32(instance->register_base + offset);
}

uint32_t Hub75_GetStatus(const Hub75 *instance)
{
    return Hub75_ReadRegister(instance, HUB75_REG_STATUS) & 3U;
}

int Hub75_SetControl(const Hub75 *instance, uint8_t enable, uint8_t buffer_id)
{
    if (enable > 1U || buffer_id > 1U)
        return HUB75_ERROR;

    Xil_Out32(instance->register_base + HUB75_REG_CONTROL,
              (uint32_t)enable | ((uint32_t)buffer_id << 1));
    return HUB75_OK;
}

int Hub75_WaitStatus(const Hub75 *instance, uint8_t enable, uint8_t buffer_id, uint32_t max_polls)
{
    uint32_t poll;
    uint32_t expected;

    if (enable > 1U || buffer_id > 1U)
        return HUB75_ERROR;

    expected = (uint32_t)enable | ((uint32_t)buffer_id << 1);
    for (poll = 0; poll < max_polls; poll++) {
        if (Hub75_GetStatus(instance) == expected)
            return HUB75_OK;
    }
    return HUB75_TIMEOUT;
}

int Hub75_SetTiming(const Hub75 *instance, uint8_t clk_half_ticks, uint8_t latch_ticks, uint8_t blank_ticks)
{
    uint32_t timing;

    if (clk_half_ticks > 15U || latch_ticks > 15U || blank_ticks > 15U)
        return HUB75_ERROR;

    timing = (uint32_t)clk_half_ticks | ((uint32_t)latch_ticks << 4) | ((uint32_t)blank_ticks << 8);
    Xil_Out32(instance->register_base + HUB75_REG_TIMING, timing);
    return HUB75_OK;
}

int Hub75_SetDisplayTicks(const Hub75 *instance, uint32_t display_ticks)
{
    if (display_ticks > 65535U)
        return HUB75_ERROR;

    Xil_Out32(instance->register_base + HUB75_REG_DISPLAY,
              (Hub75_ReadRegister(instance, HUB75_REG_DISPLAY) & 0xFFFF0000U) | display_ticks);
    return HUB75_OK;
}

int Hub75_SetBrightnessTicks(const Hub75 *instance, uint32_t brightness_ticks)
{
    if (brightness_ticks > 65535U)
        return HUB75_ERROR;

    Xil_Out32(instance->register_base + HUB75_REG_DISPLAY,
              (Hub75_ReadRegister(instance, HUB75_REG_DISPLAY) & 0xFFFFU) | (brightness_ticks << 16));
    return HUB75_OK;
}

int Hub75_SetDisplay(const Hub75 *instance, uint32_t display_ticks, uint32_t brightness_ticks)
{
    if (display_ticks > 65535U || brightness_ticks > 65535U)
        return HUB75_ERROR;

    Xil_Out32(instance->register_base + HUB75_REG_DISPLAY,
              display_ticks | (brightness_ticks << 16));
    return HUB75_OK;
}

int Hub75_FillFrame(const Hub75 *instance, uint8_t buffer_id, uint8_t upper_rgb, uint8_t lower_rgb)
{
    uintptr_t address;
    uint32_t offset;
    uint8_t pair;

    if (buffer_id > 1U || upper_rgb > 7U || lower_rgb > 7U)
        return HUB75_ERROR;

    address = frame_address(instance, buffer_id);
    pair = pack_pair(upper_rgb, lower_rgb);
    for (offset = 0; offset < HUB75_FRAME_BYTES; offset++)
        Xil_Out8(address + offset, pair);
    return HUB75_OK;
}

int Hub75_CheckFrame(const Hub75 *instance, uint8_t buffer_id, uint8_t upper_rgb, uint8_t lower_rgb)
{
    uintptr_t address;
    uint32_t offset;
    uint8_t pair;

    if (buffer_id > 1U || upper_rgb > 7U || lower_rgb > 7U)
        return HUB75_ERROR;

    address = frame_address(instance, buffer_id);
    pair = pack_pair(upper_rgb, lower_rgb);
    for (offset = 0; offset < HUB75_FRAME_BYTES; offset++) {
        if (Xil_In8(address + offset) != pair)
            return HUB75_ERROR;
    }
    return HUB75_OK;
}

int Hub75_SetPixel(const Hub75 *instance, uint8_t buffer_id, uint32_t x, uint32_t y, uint8_t rgb)
{
    uintptr_t address;
    uint8_t pair;

    if (buffer_id > 1U || x >= HUB75_WIDTH || y >= HUB75_HEIGHT || rgb > 7U)
        return HUB75_ERROR;

    address = frame_address(instance, buffer_id) + (y % 32U) * HUB75_WIDTH + x;
    pair = Xil_In8(address);
    if (y < 32U)
        pair = (uint8_t)((pair & 0x8FU) | (rgb << 4));
    else
        pair = (uint8_t)((pair & 0xF8U) | rgb);
    Xil_Out8(address, pair);
    return HUB75_OK;
}

#ifndef HUB75_DRIVER_H
#define HUB75_DRIVER_H

#include <stdint.h>


#define HUB75_REG_CONTROL 0x00U
#define HUB75_REG_STATUS  0x04U
#define HUB75_REG_TIMING  0x08U
#define HUB75_REG_DISPLAY 0x0CU

#define HUB75_ENABLE_MASK 0x01U
#define HUB75_BUFFER_MASK 0x02U
#define HUB75_WIDTH       128U
#define HUB75_HEIGHT      64U
#define HUB75_FRAME_BYTES 4096U

#define HUB75_OK       0
#define HUB75_ERROR   -1
#define HUB75_TIMEOUT -2

typedef struct {
    uintptr_t register_base;
    uintptr_t frame_memory_base;
} Hub75;


void Hub75_Init(Hub75 *instance, uintptr_t register_base, uintptr_t frame_memory_base);
uint32_t Hub75_ReadRegister(const Hub75 *instance, uint32_t offset);
uint32_t Hub75_GetStatus(const Hub75 *instance);

int Hub75_SetControl(const Hub75 *instance, uint8_t enable, uint8_t buffer_id);
int Hub75_WaitStatus(const Hub75 *instance, uint8_t enable, uint8_t buffer_id, uint32_t max_polls);

int Hub75_SetTiming(const Hub75 *instance, uint8_t clk_half_ticks, uint8_t latch_ticks, uint8_t blank_ticks);
int Hub75_SetDisplayTicks(const Hub75 *instance, uint32_t display_ticks);
int Hub75_SetBrightnessTicks(const Hub75 *instance, uint32_t brightness_ticks);
int Hub75_SetDisplay(const Hub75 *instance, uint32_t display_ticks, uint32_t brightness_ticks);

int Hub75_FillFrame(const Hub75 *instance, uint8_t buffer_id, uint8_t upper_rgb, uint8_t lower_rgb);
int Hub75_CheckFrame(const Hub75 *instance, uint8_t buffer_id, uint8_t upper_rgb, uint8_t lower_rgb);
int Hub75_SetPixel(const Hub75 *instance, uint8_t buffer_id, uint32_t x, uint32_t y, uint8_t rgb);

#endif

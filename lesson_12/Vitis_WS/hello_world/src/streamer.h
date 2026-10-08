#ifndef STREAMER_H
#define STREAMER_H
#include "xil_types.h"
#define STREAMER_FRAME_BYTES 64000U
#define STREAMER_OK 0
#define STREAMER_ERR_CONFIG (-1)
#define STREAMER_ERR_TIMEOUT (-2)
#define STREAMER_ERR_DMA (-3)
#define STREAMER_ERR_BUSY (-4)
typedef struct {
    UINTPTR control_base;
    UINTPTR dma_base;
    UINTPTR frame_base;
    u32 frame_capacity;
    u32 dma_length_bits;
    int active;
} Streamer;
int Streamer_Init(Streamer *s);
int Streamer_Start(Streamer *s);
u32 Streamer_Busy(const Streamer *s);
u32 Streamer_DmaStatus(const Streamer *s);
/* timeout_ms == 0: continuous polling without a timeout or sleeps. */
int Streamer_Wait(Streamer *s, u32 timeout_ms);
#endif

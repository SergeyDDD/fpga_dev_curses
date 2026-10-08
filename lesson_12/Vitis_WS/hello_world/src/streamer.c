#include "streamer.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "sleep.h"
#define CONTROL 0x00U
#define STATUS 0x04U
#define S2MM_CR 0x30U
#define S2MM_SR 0x34U
#define S2MM_DEST 0x48U
#define S2MM_LENGTH 0x58U
#define DMA_RUN 0x01U
#define DMA_RESET 0x04U
#define DMA_HALTED 0x01U
#define DMA_IDLE 0x02U
#define DMA_SG_INCLUDED 0x08U
#define DMA_ERRORS 0x0770U
#define DMA_IOC 0x1000U
#define DMA_IRQS 0x7000U

u32 Streamer_Busy(const Streamer *s)
{
    return Xil_In32(s->control_base + STATUS) & 1U;
}

u32 Streamer_DmaStatus(const Streamer *s)
{
    return Xil_In32(s->dma_base + S2MM_SR);
}

int Streamer_Init(Streamer *s)
{
    u32 i;
    if (!s) return STREAMER_ERR_CONFIG;

    s->active = 0;

    if (s->dma_length_bits < 16U || s->dma_length_bits > 26U ||
        s->frame_capacity < STREAMER_FRAME_BYTES || (s->frame_base & 3U) ||
        Streamer_Busy(s) || (Streamer_DmaStatus(s) & DMA_SG_INCLUDED))
        return STREAMER_ERR_CONFIG;

    Xil_Out32(s->dma_base + S2MM_CR, DMA_RESET);

    for (i = 0; i < 100000U; ++i) {
        if (!(Xil_In32(s->dma_base + S2MM_CR) & DMA_RESET)) {
            Xil_Out32(s->dma_base + S2MM_SR, DMA_IRQS);
            return STREAMER_OK;
        }
    }
    return STREAMER_ERR_TIMEOUT;
}

int Streamer_Start(Streamer *s)
{
    u32 i, sr;
    if (s->active || Streamer_Busy(s)) return STREAMER_ERR_BUSY;
    sr = Streamer_DmaStatus(s);
    if (sr & DMA_ERRORS) return STREAMER_ERR_DMA;
    if (!(sr & DMA_HALTED) && !(sr & DMA_IDLE)) return STREAMER_ERR_BUSY;

    Xil_Out32(s->dma_base + S2MM_SR, DMA_IRQS);
    Xil_Out32(s->dma_base + S2MM_CR, DMA_RUN);

    for (i = 0; i < 100000U; ++i) {
        sr = Streamer_DmaStatus(s);
        if (sr & DMA_ERRORS) return STREAMER_ERR_DMA;
        if (!(sr & DMA_HALTED)) break;
    }

    if (i == 100000U) return STREAMER_ERR_TIMEOUT;

    Xil_Out32(s->dma_base + S2MM_DEST, (u32)s->frame_base);
    Xil_Out32(s->dma_base + S2MM_LENGTH, STREAMER_FRAME_BYTES);

    s->active = 1;

    Xil_Out32(s->control_base + CONTROL, 1U);

    return STREAMER_OK;
}

int Streamer_Wait(Streamer *s, u32 timeout_ms)
{
    u32 elapsed, sr;

    if (!s->active) return STREAMER_ERR_CONFIG;

    for (elapsed = 0; timeout_ms == 0U || elapsed < timeout_ms; ++elapsed) {
        sr = Streamer_DmaStatus(s);

        if (sr & DMA_ERRORS) return STREAMER_ERR_DMA;

        if (!Streamer_Busy(s) && (sr & DMA_IOC) && (sr & DMA_IDLE)) {
            s->active = 0;
            return STREAMER_OK;
        }

        if (timeout_ms != 0U) usleep(1000);
    }
    return STREAMER_ERR_TIMEOUT;
}

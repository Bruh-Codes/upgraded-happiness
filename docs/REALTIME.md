# What real-time delivery requires

## Hardware evidence
Authors report Lite at 96 FPS or up to three 25+ FPS streams on one RTX 4090; Pro at 10.8 FPS on one RTX 4090, or 25+ FPS on two RTX 5090 with SageAttention. These are author reports, not our measurements, and must not be applied to 768 resolution or a combined voice/LLM workload without testing.
Source: https://github.com/Soul-AILab/SoulX-FlashHead

The T4 fallback did not keep up at 512 or 768. First candidate for Lite: RTX 4090 24 GB with the supported attention stack and compilation warmup. L4 speed has not been tested. Pro requires a larger hardware budget; two 5090s are the authors' documented real-time configuration.

## Required pipeline
Browser microphone -> streaming speech recognition -> support agent with retrieval/tools -> streaming TTS -> incremental audio chunks -> persistent avatar worker -> video encoder -> synchronized WebRTC audio/video -> browser.

Keep weights loaded and warm before accepting a conversation. Keep the idle/listening state controlled. Cancel queued audio and video together when the visitor interrupts. Bound queue lengths, enforce per-tenant quotas, and admit sessions only when GPU capacity exists.

Existing Gradio sends MP4 segments and expects a complete WAV. It is a useful research preview, not a finished live voice product. Implement incremental audio input, timestamped output, encoding and media transport before claiming real-time support.

## Acceptance gates
- Measure warmed first-frame and first-audio delay separately from cold startup.
- For every chunk, generation + encoding + delivery should remain below its playback duration with margin.
- Test one stream first, then concurrent streams under sustained load.
- Measure p50/p95 delay, jitter, lip sync, GPU memory, queue depth, dropped frames and interruptions.
- Compare 512 vs 768 quality and capacity.
- Test long sessions and silence, not only short prerecorded speech.

## Cost planning
Runpod lists RTX 4090 Pods at $0.74/hour: about $540/month at 730 hours before storage, delivery and other services. This is a listed rate, not a selected deployment or guaranteed availability.
Source checked 5 October 2026: https://www.runpod.io/pricing

GPU cost per conversation minute = hourly price * billed GPU hours / delivered conversation minutes. Idle capacity matters. Budget extra for ASR/TTS/LLM hosting or APIs, backend, storage, media bandwidth, observability and redundancy. No production bill estimate is validated yet. With no customers, start GPU only for tests and demos.

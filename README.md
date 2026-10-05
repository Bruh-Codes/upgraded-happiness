# Voice Avatar Support Prototype

A reproducible research prototype for a voice-first customer support avatar. The UI will be built separately.

## References

- Product inspiration: https://www.salesforce.com/ (Piper's visible voice/avatar experience).
- Experience reference: https://language-demo.liveavatar.com/

These are references, not claims that our implementation uses their proprietary technology.

## Status

Tested on Lightning AI, one Tesla T4 (15,360 MiB). Portrait + English speech generates talking videos. Lite streaming was tested, but did not sustain playback speed. No live microphone, support backend, WebRTC integration, or production deployment exists yet.

## Running costs

**Development: budget $0.55 per GPU hour on a T4. Real-time Lite: budget $0.74 per GPU hour on an RTX 4090, pending our own benchmark.** These are GPU rental costs, not the total cost of a customer support service.

Prices checked 5 October 2026, in USD. Monthly figures assume 720 running hours (30 days).

| Use | Hardware | GPU cost / hour | GPU cost / 30 days, always running | What we know |
| --- | --- | ---: | ---: | --- |
| Render and test the included demos | 1 × T4, 16 GB | $0.55 | $396.00 | Tested. Lite and Pro run; neither sustained real-time generation in our tests. |
| Real-time Lite at 512 × 512 | 1 × RTX 4090, 24 GB | $0.74 | $532.80 | Upstream reports up to 3 simultaneous streams. We have not verified that capacity or end-to-end conversation latency. |
| Real-time Pro at 512 × 512 | 2 × RTX 5090, 32 GB each | $1.98 estimated | $1,425.60 estimated | Upstream requires two 5090s with optimized attention. Estimate is 2 × the listed $0.99 single-GPU rate; an available, compatible two-GPU machine and its price must be confirmed. |

Rates: [Lightning T4 pricing](https://lightning.ai/pricing) and [Runpod GPU pricing](https://www.runpod.io/pricing). Availability, region and deployment quotes can change. Hardware benchmark sources and implementation details are in [the real-time design](docs/REALTIME.md).

### Cost per conversation

For Lite, **one occupied GPU costs about $0.0123 per wall-clock minute**, or **$0.123 for a 10-minute session**, assuming the GPU is running only for that session. If three simultaneous sessions are confirmed, fully occupied and evenly share the GPU, the GPU portion falls to about **$0.0041 per session-minute**. That is a capacity-based estimate, not a measured product price.

An always-on GPU costs the same while idle. At 100 ten-minute sessions per month, the $532.80 always-on Lite GPU alone averages **$5.33 per session**; at 1,000 sessions, **$0.53 per session**, provided the schedule and concurrent capacity fit. With no customers, rent short test windows and stop the GPU afterward. Ten hours of Lite GPU testing at the listed rate costs **$7.40**, before storage and other charges.

### What costs extra

The total service bill also includes speech recognition, language-model responses, speech synthesis, the backend/database, stored model weights, video bandwidth and WebRTC/TURN infrastructure. These are not included above; provider choices and usage have not been fixed, so a complete per-minute price is not yet verified. Startup/loading and idle time are billable when the GPU instance is running; stored disks can remain billable after it stops.

Our T4 measurements: a 20-second Pro clip took about 6 minutes to render, approximately **$0.055 of GPU time**, excluding loading. Lite 512 steady generation took about 1.47 seconds per 0.96 seconds of video; Lite 768 took about 3.6 seconds. Higher resolution does not currently have a verified real-time capacity or cost. See [measured results](docs/BENCHMARKS.md).

## Run

Linux NVIDIA GPU required by this setup.

1. Run `bash scripts/setup.sh` (downloads several GB).
2. Run `bash scripts/render.sh lite 512`.
3. Run `bash scripts/render.sh pro 512` for the higher quality, slower variant.
4. Run `bash scripts/render.sh lite 768` for the experimental higher resolution.
5. For the official streaming UI: `cd vendor/SoulX-FlashHead && PATH="$PWD/.venv/bin:$PATH" FLASHHEAD_T4=1 .venv/bin/python gradio_app_streaming.py`. Use private port forwarding for port 7860.

Set FLASHHEAD_T4=0 on supported Ampere/Ada GPUs to use the original attention, BF16, and compilation settings. This path has not been benchmarked by us.

See docs/RUNNING.md, docs/BENCHMARKS.md, docs/REALTIME.md. Generated samples are in samples/. Model weights download separately; no credentials are included.

## Video demos

These are prerecorded test renders. Play them directly below. GitHub starts embedded videos muted; enable sound using each player's speaker control (or its ⋮ menu).

<table>
<tr><th>Stylized character · Pro</th><th>Warm greeting · Lite</th></tr>
<tr><td><video src="https://github.com/user-attachments/assets/7b39aabc-c0f2-462d-ba0e-18ef07de8827" controls width="360"></video></td><td><video src="https://github.com/user-attachments/assets/0bc9c157-7019-4438-8e3a-7a2910b2ea8a" controls width="360"></video></td></tr>
<tr><th>Short comparison · Pro · 3 seconds</th><th>20-second test · Pro</th></tr>
<tr><td><video src="https://github.com/user-attachments/assets/a035b00e-1ef4-400a-a9ff-98652eddf1e0" controls width="360"></video></td><td><video src="https://github.com/user-attachments/assets/eedab194-09a7-4d33-9a8d-bd3782353552" controls width="360"></video></td></tr>
</table>

All included videos render at 512 × 512. The 768 experiment is documented in the benchmarks, but its video was not available in the recovered package. The 20-second Pro ending showed unwanted facial motion; it is retained as a test result, not a polished product demo.

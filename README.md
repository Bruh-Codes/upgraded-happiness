# Voice Avatar Support Prototype

A reproducible research prototype for a voice-first customer support avatar. The UI will be built separately.

## References
- Product inspiration: https://www.salesforce.com/ (Piper's visible voice/avatar experience).
- Experience reference: https://language-demo.liveavatar.com/
- Animator: https://github.com/Soul-AILab/SoulX-FlashHead

These are references, not claims that our implementation uses their proprietary technology.

## Status
Tested on Lightning AI, one Tesla T4 (15,360 MiB). Portrait + English speech generates talking videos. Lite streaming was tested, but did not sustain playback speed. No live microphone, support backend, WebRTC integration, or production deployment exists yet.

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

Click a preview to open its video. Samples are prerecorded renders, not live conversations.

### Stylized 3D character — FlashHead Pro
[![Stylized character](samples/stylized-character.png)](https://github.com/Bruh-Codes/upgraded-happiness/raw/refs/heads/main/samples/stylized-character-pro.mp4)

[Watch the English character test](https://github.com/Bruh-Codes/upgraded-happiness/raw/refs/heads/main/samples/stylized-character-pro.mp4)

### Warm support avatar — FlashHead Lite
[![Warm support portrait](samples/support-man-warm.png)](https://github.com/Bruh-Codes/upgraded-happiness/raw/refs/heads/main/samples/warm-support-man.mp4)

[Watch the Lite greeting](https://github.com/Bruh-Codes/upgraded-happiness/raw/refs/heads/main/samples/warm-support-man.mp4)

### Same portrait — FlashHead Pro
- [Watch the 3-second Pro comparison](https://github.com/Bruh-Codes/upgraded-happiness/raw/refs/heads/main/samples/support-man-pro.mp4)
- [Watch the 20-second Pro test](https://github.com/Bruh-Codes/upgraded-happiness/raw/refs/heads/main/samples/support-man-pro-20s.mp4)

All included videos render at 512 × 512. The 768 experiment is documented in the benchmarks, but its video was not available in the recovered package. The 20-second Pro ending showed unwanted facial motion; it is retained as a test result, not a polished product demo.

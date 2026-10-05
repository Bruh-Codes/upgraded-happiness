# Observed results (5 October 2026)

Hardware: Tesla T4, 15,360 MiB. Python 3.10; torch 2.7.1+cu128; FP16 compatibility patch; SDPA fallback; compilation disabled. These are single-run prototype observations, not production capacity guarantees.

| Test | Result |
|---|---|
| Lite 512 first 3-second sample | Approx. 12 seconds generation, excluding loading |
| Warm Lite 512 | Steady chunks around 1.47 seconds for 0.96 seconds of video |
| Lite streaming generator | First 2.88-second segment at 22.726 seconds including loading; next at 27.323 seconds; final at 28.187 seconds |
| Lite streaming consequence | Next segment needed 4.597 seconds, exceeding 2.88-second playback by ~1.72 seconds |
| Lite 768 | Steady chunks ~3.6 seconds for 0.96-second video; ~8 GB GPU allocation observed |
| Pro 512, 3-second sample | ~57 seconds rendering excluding loading |
| Pro 512, 20-second sample | ~6 minutes rendering, excluding loading |

25 FPS output describes playback, not generation speed. The streaming test used an existing WAV, so it did not prove live audio input, conversational latency, interruption handling, or browser playback.

No direct gaze/blink control or text animation prompt was found in the released inference interface. Seed changes may vary motion but do not guarantee calm eyes. The paper describes 512x512 training samples; rendering 768 is experimental.

The owner preferred the warmer Lite result but noted graphics and eye movement concerns. Pro's longer ending was judged creepy. No independent perceptual quality evaluation exists.

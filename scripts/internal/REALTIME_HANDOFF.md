# Real-time avatar engineering handoff

Recorded 5 October 2026. This file preserves the work independently of the original chat. Read docs/RUNNING.md, docs/BENCHMARKS.md, docs/REALTIME.md and scripts/setup.sh before resuming. Historic results do not establish current pricing or production capacity.

## Product intent

A voice-first customer support agent for websites, restaurants, documentation and purchase assistance. The owner builds the UI. Self-host the animator; external language and voice APIs are acceptable. Salesforce Piper is the product reference; LiveAvatar's language demo is the experience reference. Neither is our implementation.

No customers yet. Prepare on CPU, rent short GPU test windows and stop compute afterward. This file does not authorize purchases or deployments.

Custom portraits, English speech, calm facial motion and improved graphics matter. The owner preferred the warmer Lite output. Excessive eye motion, an angry expression and the ending of the 20-second Pro render were concerns.

## Completed and outstanding work

Completed: inference scripts, T4 compatibility patch, English audio/portraits, four prerecorded video demos and a streaming-generator test driven by an existing WAV.

Outstanding: live microphone, conversational backend, streaming voice integration, synchronized WebRTC playback, interruption handling, support knowledge integration and deployment.

The complete real-time conversational agent has NOT been demonstrated. 25 FPS output means playback frame rate, not inference speed.

## Reproducibility

Animator source: https://github.com/Soul-AILab/SoulX-FlashHead
Tested upstream commit: 9bc03de06bb0de82cd6bc477804512ae06144bf2.

Test hardware: one Tesla T4, 15,360 MiB reported VRAM.
Test environment: Python 3.10.22, torch 2.7.1+cu128, torchvision 0.22.1.
Use scripts/setup.sh, scripts/download_models.py, scripts/render.sh and patches/t4.patch as the source of truth.

Lightning prohibited extra Conda environments; a Python 3.10 project venv worked. Model downloads include Lite/Pro, their VAEs and wav2vec2. Do not commit weights or environments.

FLASHHEAD_T4=1:
- Uses PyTorch SDPA attention because the original FlashAttention path is unsupported on T4.
- Uses FP16 parameters instead of BF16.
- Disables torch.compile for model/VAE.
Setup removes the conflicting explicit upstream NCCL pin while retaining torch's own dependency.
An installed flash-attn package does not make its optimized kernels usable on T4.

FFmpeg was supplied using imageio's FFmpeg binary. Inference succeeded despite autocast and Decord platform metadata warnings. Resolve dependency warnings before production. The optimized non-T4 path still needs independent validation.

## Measured results

| Test | Observation |
| --- | --- |
| Lite 512 warm chunks | ~1.47 seconds generation per 0.96 seconds video |
| First streaming segment | 2.88 seconds video available at 22.726 seconds including loading |
| Second streaming segment | available at 27.323 seconds; another 4.597 seconds generation |
| Playback implication | next segment exceeded its playback duration by ~1.72 seconds |
| Lite 768 | ~3.6 seconds generation per 0.96 seconds video; ~8 GB GPU allocation |
| Pro 512, 3-second clip | ~57 seconds rendering excluding loading |
| Pro 512, 20-second clip | ~6 minutes rendering excluding loading |

Individual observations, not capacity guarantees. The 768 output video was not recovered. Keep cold start, warm throughput, encoding time and conversation latency separate.

Upstream claims Lite 96 FPS or up to three 25+ FPS streams on one RTX 4090; Pro 10.8 FPS on one 4090 and 25+ FPS on two RTX 5090s with SageAttention. We have not verified those claims. The released Gradio streaming UI supports one GPU; multi-GPU inference does not establish a working multi-GPU conversation pipeline.

## Assets and animation lessons

The four MP4s in samples/ are the stylized female Pro test, warm male Lite test, short male Pro comparison and 20-second male Pro test. Inspect the accompanying portrait/WAV names before pairing them.

Experimental voice used edge-tts: en-US-AndrewNeural for the man (warm test rate -8%) and en-US-JennyNeural for the stylized character (rate -5%). This is not a production voice SLA.

Long-test audio was padded/truncated to 20 seconds. Silence may explain some odd ending motion, but that was not verified. Finish speech cleanly and use a controlled idle/listening state.

No direct text prompt, gaze or blink control was found in the released inference API. Do not invent these settings. Seeds can vary motion without guaranteeing calm eyes. Training used 512-square samples; higher resolution needs independent quality and speed tests. Test character assets do not establish commercial character rights.

## Resume with available GPU time

1. Confirm GPU model, VRAM and allotted runtime. Read the current scripts and upstream docs.
2. Prepare code/assets on CPU first. Reuse intact cached weights where possible.
3. Run setup on Linux with NVIDIA drivers and the project's venv.
4. Reproduce Lite 512, then a short Pro clip if time allows.
5. Use FLASHHEAD_T4=1 for compatibility; the supported-GPU optimized path needs matching attention dependencies.
6. Benchmark a full warm streaming utterance: first-chunk latency, sustained throughput, VRAM, synchronization and stalls.
7. Connect the conversation pipeline only after generation can keep pace.
8. Record actual findings and stop compute. Persistent storage can remain billable.

Do not assume old cloud instances or SSH access still exist. Repository setup must work independently of the original chat.

## Real-time implementation plan

Browser microphone -> session gateway -> speech recognition or speech-to-speech model -> support retrieval/tools -> streamed response audio -> animator worker -> synchronized audio/video -> WebRTC browser.

Separate the conversation layer from the animator with a provider-neutral adapter. Speech audio drives the portrait; text alone does not.

Every session needs session/turn/avatar IDs, monotonic audio offsets, bounded queues and cancellation. Derive sample rates, chunk sizes and history requirements from actual inference code. Do not assume independent arbitrary audio chunks are valid.

Animator worker:
- Keep the model warm during active service/test windows.
- Cache portrait preprocessing when supported.
- Feed audio incrementally with required context.
- Emit frames with timing information.
- Bound buffering and measure queue delay.
- Benchmark GPU video encoding separately if available.
- Transition to idle/listening at speech end instead of indefinitely animating silence.

Playback:
- Timestamp response audio and video consistently.
- Avoid playing audio immediately while delayed animation catches up.
- Measure first synchronized playback, drift and underruns.
- Prerecorded MP4 playback is a fallback demo, not live transport.

Interruption:
- Detect user speech during responses.
- Cancel current voice and animation work.
- Tag media by turn, discard stale output and clear playback queues.
- Transition to listening.
- Test that cancelled speech never resumes.

Support backend:
- Scope knowledge and tools to each business.
- Begin with a small known support knowledge set and human handoff.
- Confirm consequential purchase/account actions.
- Keep API keys server-side and outside commits/logs.

## Acceptance gates

- Sustained generation at target resolution without accumulating backlog.
- Measured cold/warm first-response latency.
- Stable synchronization and bounded memory over repeated turns.
- Interruption tests early, midway and near speech end.
- Review expression, speech ending and idle transitions.
- Test concurrent capacity before splitting GPU cost between sessions.
- Preserve source/license attribution and distinguish upstream claims from measured results.

## Costs and repository presentation

README has dated GPU estimates. Recheck rates when resuming. Include running, loading and idle GPU time. Add voice/LLM, storage, backend, bandwidth and TURN separately. Utilization strongly affects actual per-session cost.

README demos belong in a two-column gallery before running costs. Keep animator implementation details here and in technical files; preserve NOTICE and upstream attribution. GitHub itself added default muting to the rendered attachment players even though README omitted muted; do not claim a README attribute can force sound on.

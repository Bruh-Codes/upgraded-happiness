# Self-hosted live avatar animation

Research and revised implementation direction • 4 October 2026

## Decision

Benchmark SoulX-FlashHead Lite first, MuseTalk 1.5 second, and Ditto as a portrait-motion alternative. Operate our own GPU animator, encoder, and media delivery. Keep OpenAI voice independent. LiveAvatar becomes an optional adapter, with no automatic paid fallback.

This review inspected primary repositories, model cards, papers, and licenses. No models were run and no GPU was rented. Performance figures are author reports, not our measurements. We cannot yet promise HeyGen quality or a particular saving.

## Candidates

### SoulX-FlashHead Lite: first benchmark

Portrait-plus-audio streaming framework, 1.3B parameters. Authors report Lite at 96 FPS or up to three 25+ FPS streams on one RTX 4090. Pro is 10.8 FPS on one 4090 and needs two 5090s for their real-time setup. Code and model card list Apache 2.0; audit dependencies and preserve notices.

Promising for our generated headshots. A streaming demo does not prove low-latency processing of unknown future audio. Test genuinely incremental input and interruptions.

[Code](https://github.com/Soul-AILab/SoulX-FlashHead), [weights/license metadata](https://huggingface.co/Soul-AILab/SoulX-FlashHead-1_3B), [streaming implementation](https://github.com/Soul-AILab/SoulX-FlashHead/blob/main/gradio_app_streaming.py)

### MuseTalk 1.5: practical lip-sync baseline

Modifies a 256 x 256 face region and reports 30+ FPS on V100. Official project permits commercial use of its code and model subject to dependency licenses. Documented limits include jitter and identity-detail preservation. Head/body movement needs prepared footage or a separate motion system.

For our portrait, prepare a short approved motion/idle clip and cache face crops/features before live inference. A static portrait alone may look rigid. Repository test assets are research-only.

[Official code and terms](https://github.com/TMElyralab/MuseTalk)

LiveTalking is a streaming reference, not another model. It provides WebRTC integration and reports MuseTalk at 72 FPS on 4090. This is not proof of production concurrency or compatibility with every newer checkpoint. Backend weights have their own licenses.

[LiveTalking reference](https://github.com/lipku/LiveTalking/blob/main/README-EN.md)

### Ditto: portrait-driven motion

Released audio-driven portrait pipeline with online configuration, TensorRT, and PyTorch models. Repo/checkpoint page state Apache 2.0; published tested setup is A100. Benchmark smaller hardware ourselves. The checkpoint bundle includes InsightFace components: audit usage and replace restricted models or obtain their license before commercial deployment.

[Code](https://github.com/antgroup/ditto-talkinghead), [checkpoint inventory](https://huggingface.co/digital-avatar/ditto-talkinghead), [InsightFace terms](https://github.com/deepinsight/insightface)

### AVTR-1: compact, but commercially licensed components

Paper describes a 153M motion generator, not the whole rendering stack. Repo reports 25 FPS, five-frame chunks, and 166 ms/chunk on 4060 Ti; plain 4060 is below real time. Includes listening behavior.

Model license permits commercial use below its revenue threshold subject to conditions. Published renderer and streamer are noncommercial and require separate commercial agreements for commercial use. Patent notice also needs review. Do not assume the whole stack is free to sell.

[Code](https://github.com/avaturn-live/avtr-1), [paper](https://arxiv.org/abs/2609.22913), [component licenses](https://github.com/avaturn-live/avtr-1/blob/main/LICENSE.md)

### Browser 3D: lower server cost, different appearance

TalkingHead is MIT JavaScript/Three.js with streaming PCM, visemes/blendshapes, and interruption. Requires a rigged 3D asset, not an arbitrary JPEG. Assets need their own licenses. NVIDIA Audio2Face-3D SDK can generate facial motion on CUDA; selected weights and optional emotion models have separate terms. Neither directly produces photorealistic headshot pixels.

Rendering on visitor devices reduces server video inference/encoding costs. Asset preparation and mobile performance become tradeoffs. Keep this optional because the owner prefers realistic portraits.

[TalkingHead](https://github.com/met4citizen/TalkingHead), [NVIDIA SDK](https://github.com/NVIDIA/Audio2Face-3D-SDK)

## Avoid selecting these without resolving limitations

- Original Wav2Lip distribution prohibits commercial use. A permissive wrapper does not change its weights' terms. [Official terms](https://github.com/Rudrabha/Wav2Lip)
- LivePortrait alone is video-driven, not a complete audio animator. Its license requires replacing restricted InsightFace detection models for commercial use. [License](https://github.com/KlingAIResearch/LivePortrait/blob/main/LICENSE)
- Alibaba-Quark LiveAvatar is unrelated to HeyGen. Its 14B multi-GPU real-time design is not our lightweight baseline. Offline single-GPU support does not establish cheap live inference. [Repository](https://github.com/Alibaba-Quark/LiveAvatar)
- StreamAvatar: this review did not establish downloadable production weights/code and commercial terms. [Project](https://streamavatar.github.io/)
- Ultralight-Digital-Human: explicit commercial permission was not established from the inspected repository. Do not choose based on its mobile-efficiency description alone. [Repository](https://github.com/anliyuan/Ultralight-Digital-Human)

## Economics

Runpod's GPU page currently lists RTX 4090 at $0.34/hour Community and $0.74/hour Secure; availability/rates vary. Use $0.74/hour for these illustrative GPU-only scenarios. [Official rates](https://www.runpod.io/gpu-models/rtx-4090)

GPU cost per delivered session minute = hourly rate / (60 × validated concurrent capacity × utilization).

| Capacity and utilization | GPU-only cost/minute |
|---|---:|
| One stream, 100% | $0.0123 |
| One stream, 25% | $0.0493 |
| Three streams, 100% | $0.0041 |
| Three streams, 25% | $0.0164 |

Three streams is a scenario to validate, not guaranteed capacity. Include encoding CPU, bandwidth/TURN, storage, warm idle capacity, licensing, operations, and voice AI separately. An always-on $0.74/hour GPU costs $532.80 over 30 days; at just 1,000 delivered minutes that is $0.533/minute before extras.

Scale-to-zero introduces boot, weight loading, compilation, and warmup. Cache weights and hardware-matched engines. Cold-start waiting can destroy the conversational experience. Rent short development windows and shut compute down afterward; storage may still charge.

At 1–3 Mbps, video transfers about 7.5–22.5 MB/minute before overhead/relay duplication. Measure bitrate and TURN use. Compare full hosting costs with actual API invoices/allowance, not only busy GPU time with API overage.

## Revised architecture

```text
Browser mic -> existing gateway -> OpenAI voice
                                    |
                                generated PCM
                                    v
                         animator scheduler/ingress
                                    |
                      Python GPU worker + avatar cache
                                    |
                     frames + delayed original speech
                                    v
                      encoder + WebRTC media publisher
                                    |
                         synchronized browser A/V
```

Operate a WebRTC media service and TURN, or pay a media transport provider independently of animation. Existing LiveKit client contracts can remain if we operate compatible rooms. Verify current publishing SDKs during implementation.

New modules: Python inference workers, avatar preparation jobs, capacity scheduler, timestamped encoder/publisher, GPU metrics/autoscaling. Keep business tools in TypeScript. Models/assets are cached; each conversation has separate motion/audio state.

Animator contract: prepareAvatar, createSession, appendAudio(sequence,startSample,pcm), endUtterance, interrupt(epoch), stopSession, health, capacity.

Rules:

1. Consume incremental audio; do not generate whole MP4s per sentence.
2. Preserve sample counts, lookahead, frame timestamps, and one playback clock. Delay original audio to match video.
3. Interrupt increments epoch and clears inference, encoder, and playout queues. Discard stale output at every boundary.
4. Bound queues and enforce admission control. Model FPS alone is not session capacity.
5. Precompute safe idle/listening loops where possible, preserving pose continuity across transitions.
6. Measure first synchronized audible output, not just first generated frame.

## Benchmark and agent work order

Use five approved synthetic portraits and identical audio for all candidates. Test head shapes/hair/skin tones, target languages, silence, fast speech, laughter, interruptions, and ten-minute conversations. Use our own assets.

Start on a rented 4090 where supported. Record checkpoint hashes, resolution, precision, drivers, dependencies, cold/warm startup, audio lookahead, p50/p95 audible latency, sustained FPS, memory, encoder time, bandwidth, drift, and full cost assumptions. Test one/two/three sessions and require capacity headroom. Withhold future audio to prove incremental processing.

Compare mouth/teeth, identity, blinking, head motion, seams, and artifacts at actual widget size. Deliver side-by-side clips for the owner's visual review. No HeyGen-quality claims based solely on papers.

Provisional gates: sustained 25 FPS at selected resolution; animator-added first synchronized output p95 under 700 ms; confirmed interruption stop p95 under 500 ms; no growing drift over ten minutes. Proposed targets, not model guarantees.

Agent sequence:

1. License manifest: code, weights, detectors, audio encoders, VAE, assets, media/codec dependencies. Pin versions; identify unresolved terms.
2. Benchmark SoulX-FlashHead Lite and MuseTalk 1.5; add Ditto if needed.
3. Deliver measured clips, latency, validated concurrency, and utilization-aware costing.
4. Choose renderer after owner visual review; implement production adapter, publisher, capacity controls, and cleanup.
5. Continue SYSTEM_DESIGN.md backend phases with our animator primary and LiveAvatar optional. No automatic paid fallback.

Do not train a foundation model first. Start with commercially suitable weights and our own serving/streaming. Fine-tune/distill only after a measured limitation warrants it and licensing/data budget is resolved.


# Running the prototype

Use a Linux machine with an NVIDIA GPU. The tested T4 setup uses FP16, PyTorch SDPA attention, and disabled torch.compile. It is a compatibility path, not the authors' optimized benchmark setup.

Setup pins the upstream commit tested in our session, creates a Python 3.10 venv via uv, installs torch 2.7.1 CUDA 12.8 and torchvision 0.22.1, then installs the upstream dependencies without its conflicting explicit NCCL pin. Torch's NCCL dependency is retained. It applies our small T4 patch and downloads Lite/Pro weights, both VAEs, and wav2vec2.

Lightning prohibits creating extra Conda environments. The project .venv avoids this restriction. Run every command with the project's .venv Python.

On non-T4 hardware install the official FlashAttention 2.8.0.post2 wheel matching Python, torch, CUDA and CXX11 ABI before running FLASHHEAD_T4=0. Consult upstream README. Do not install a wheel for a different ABI.

Samples include the supplied original portrait, an edited warmer portrait, English input audio, and successful renders. Voice was generated with edge-tts for experimentation; this is not a production voice-service commitment or SLA. Replace it with a licensed streaming TTS provider or suitable self-hosted model for production.

The 20-second Pro audio was padded/truncated to exactly 20 seconds. The owner found the ending creepy. Silence was a possible explanation, not verified. Trim to speech end and use a controlled listening/idle state in the product.

GPU instances consume credits while running, including loading and idle time. Stop them after testing. Persistent storage may incur separate charges.

Known environment issue: pip check reported Decord platform metadata incompatibility, although importing Decord succeeded. End-to-end tests completed; resolve this packaging warning before release.

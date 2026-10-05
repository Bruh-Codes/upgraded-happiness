#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v uv >/dev/null || { echo "Install uv first: https://docs.astral.sh/uv/getting-started/installation/"; exit 1; }
mkdir -p vendor
if [ ! -d vendor/SoulX-FlashHead/.git ]; then git clone https://github.com/Soul-AILab/SoulX-FlashHead.git vendor/SoulX-FlashHead; fi
cd vendor/SoulX-FlashHead
git checkout 9bc03de06bb0de82cd6bc477804512ae06144bf2
if git apply --check ../../patches/t4.patch; then git apply ../../patches/t4.patch; elif ! git apply --reverse --check ../../patches/t4.patch; then echo "Patch conflicts with checkout"; exit 1; fi
uv venv --python 3.10 --seed .venv
.venv/bin/python -m pip install torch==2.7.1 torchvision==0.22.1 --index-url https://download.pytorch.org/whl/cu128
sed '/^nvidia-nccl-cu12/d' requirements.txt > requirements-lightning.txt
.venv/bin/python -m pip install -r requirements-lightning.txt
.venv/bin/python ../../scripts/download_models.py
.venv/bin/python -c 'import os,imageio_ffmpeg; dst=".venv/bin/ffmpeg"; os.path.lexists(dst) or os.symlink(imageio_ffmpeg.get_ffmpeg_exe(),dst)'
echo "Ready. T4 render: bash scripts/render.sh lite 512 (from project root)"

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
MODEL="${1:-lite}"
SIZE="${2:-512}"
cd vendor/SoulX-FlashHead
export PATH="$PWD/.venv/bin:$PATH"
export FLASHHEAD_T4="${FLASHHEAD_T4:-1}"
.venv/bin/python "$ROOT/scripts/render.py" --model "$MODEL" --size "$SIZE" --portrait "$ROOT/samples/support-man-warm.png" --audio "$ROOT/samples/warm-support.wav" --output "$ROOT/samples/render-$MODEL-$SIZE.mp4"

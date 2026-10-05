import argparse
import runpy
import sys
from pathlib import Path
sys.path.insert(0, str(Path.cwd()))
from flash_head.inference import infer_params

parser = argparse.ArgumentParser()
parser.add_argument("--model", choices=["lite", "pro"], default="lite")
parser.add_argument("--size", type=int, choices=[512, 768], default=512)
parser.add_argument("--portrait", required=True)
parser.add_argument("--audio", required=True)
parser.add_argument("--output", required=True)
args = parser.parse_args()
infer_params["height"] = args.size
infer_params["width"] = args.size
sys.argv = ["generate_video.py", "--ckpt_dir", "models/SoulX-FlashHead-1_3B",
            "--wav2vec_dir", "models/wav2vec2-base-960h", "--model_type", args.model,
            "--cond_image", args.portrait, "--audio_path", args.audio,
            "--audio_encode_mode", "stream", "--save_file", args.output]
runpy.run_path("generate_video.py", run_name="__main__")

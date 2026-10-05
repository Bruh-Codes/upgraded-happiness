from huggingface_hub import snapshot_download
snapshot_download("Soul-AILab/SoulX-FlashHead-1_3B", local_dir="models/SoulX-FlashHead-1_3B",
                  allow_patterns=["Model_Lite/*", "VAE_LTX/*", "Model_Pro/*", "VAE_Wan/*", "config.json", "model_index.json"])
snapshot_download("facebook/wav2vec2-base-960h", local_dir="models/wav2vec2-base-960h",
                  allow_patterns=["config.json", "preprocessor_config.json", "pytorch_model.bin",
                                  "tokenizer_config.json", "vocab.json", "special_tokens_map.json"])

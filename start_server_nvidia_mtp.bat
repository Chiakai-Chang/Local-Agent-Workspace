@echo off
chcp 65001 > nul
setlocal
title Qwen3.6 APEX-MTP - RTX A4500

:: ====================================================================
:: ⚠️ 請修改以下兩個路徑為您電腦中的實際位置
:: ====================================================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\Qwen3.6-35B-A3B-Claude-4.7-Opus-Reasoning-Distilled-APEX-MTP-I-Balanced.gguf
set CTX_SIZE=98304
set PORT=8080

echo Starting Local LLM Server with Self-Speculative MTP Decoding...
echo ========================================================
echo Model  : %MODEL%
echo Server : http://127.0.0.1:%PORT%
echo GPU    : RTX A4500 20GB (Or other NVIDIA GPUs)
echo Context: %CTX_SIZE% (96K)
echo KV     : q4_0 / q4_0 (KV Cache quantized to save VRAM)
echo MTP    : Enabled (--draft-mtp)
echo ========================================================

:: 說明：
:: --draft-mtp 會啟動 GGUF 模型內建的 Multi-Token Prediction (MTP) 頭進行自我推測解碼，
:: 無需額外掛載 draft 模型即可獲得大約 1.5x - 2x 的速度提升！

"%LLAMA_EXE%" ^
  -m "%MODEL%" ^
  -ngl 999 ^
  -c %CTX_SIZE% ^
  --host 127.0.0.1 ^
  --port %PORT% ^
  -np 1 ^
  -b 512 ^
  -ub 128 ^
  --cache-type-k q4_0 ^
  --cache-type-v q4_0 ^
  --flash-attn on ^
  --draft-mtp ^
  --mmap ^
  --no-warmup ^
  --jinja ^
  --threads 8 ^
  --prio 2 ^
  --timeout 1200

pause

@echo off
chcp 65001 > nul
setlocal
title GRM-2.6-Opus IQ4_XS 128K - RTX A4500

:: ====================================================================
:: ⚠️ 請修改以下兩個路徑為您電腦中的實際位置
:: ====================================================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\GRM-2.6-Opus.i1-IQ4_XS.gguf
set CTX_SIZE=131072
set PORT=8080

echo Starting Local LLM Server (NVIDIA CUDA)...
echo ========================================================
echo Model  : %MODEL%
echo Server : http://127.0.0.1:%PORT%
echo GPU    : RTX A4500 20GB (Or other NVIDIA GPUs)
echo Context: %CTX_SIZE% (128K)
echo KV     : q4_0 / q4_0 (KV Cache quantized to save VRAM)
echo Batch  : 512 / 128 (Logical / Physical Batch)
echo ========================================================

:: 修正說明：
:: 1. 移除了新版 llama.cpp 已不支援的舊參數：--cache-reuse, --cache-prompt, --context-shift
:: 2. 將舊版 --parallel 1 修正為新版標準的 -np 1 (slots)
:: 3. 調整 -b 4096 / -ub 1024 為穩健的 512 / 128，避免大 Context 時吞吐量爆 VRAM
:: 4. 使用 --mmap 來獲得更快的啟動速度與記憶體釋放，移除了 --no-mmap

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
  --mmap ^
  --no-warmup ^
  --jinja ^
  --threads 8 ^
  --prio 2 ^
  --timeout 1200

pause

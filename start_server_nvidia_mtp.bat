@echo off
setlocal
title Qwopus3.6-27B-v2-MTP [RTX A4500 128K Max Performance]

:: ====================================================================
:: [Configuration Paths] Please modify the paths below to match your system.
:: ====================================================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\Qwopus3.6-27B-v2-MTP-GGUF.gguf
set CTX_SIZE=131072
set PORT=8080

echo ========================================================
echo Starting Qwopus3.6-27B-v2-MTP Server...
echo Model  : %MODEL%
echo Host   : http://127.0.0.1:%PORT%
echo Context: %CTX_SIZE% (128K)
echo GPU    : Offloaded completely (Base model + Draft heads)
echo RAM    : 12GB allocated for Conversational Prompt Cache
echo Threads: P-core direct binding [8 Physical Cores]
echo ========================================================

:: Parameters Explained:
:: 1. Speculative Decoding: --spec-type draft-mtp (uses built-in predictive heads), drafts 3 tokens, offloaded to VRAM
:: 2. KV Cache quantized: -ctk q4_0 -ctv q4_0 (Target) & -ctkd q4_0 -ctvd q4_0 (Draft) saves 72% VRAM
:: 3. Unified KV Buffer: --kv-unified shares memory between model and draft
:: 4. Prompt Cache: --cache-ram 12288 holds 12GB chat history in system RAM for sub-second responses
:: 5. Threads optimization: --threads 8 binds to 12700K P-cores, --threads-batch 12 accelerates batching

"%LLAMA_EXE%" ^
  -m "%MODEL%" ^
  -ngl 999 ^
  -c %CTX_SIZE% ^
  --host 127.0.0.1 ^
  --port %PORT% ^
  -np 1 ^
  -b 512 ^
  -ub 128 ^
  --spec-type draft-mtp ^
  --spec-draft-n-max 3 ^
  --spec-draft-ngl all ^
  --cache-type-k q4_0 ^
  --cache-type-v q4_0 ^
  --cache-type-kd q4_0 ^
  --cache-type-vd q4_0 ^
  --kv-unified ^
  --cache-ram 12288 ^
  --cache-idle-slots ^
  --flash-attn on ^
  --mmap ^
  --no-warmup ^
  --jinja ^
  --threads 8 ^
  --threads-batch 12 ^
  --prio 2 ^
  --reasoning-format deepseek ^
  --timeout 1200

pause

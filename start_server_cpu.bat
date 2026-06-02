@echo off
setlocal
title Llama.cpp CPU Server [Unified CPU Performance Tuning]

:: ====================================================================
:: [Configuration Paths] Please modify the paths below to match your system.
:: ====================================================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\Qwopus3.6-7B-MTP-IQ3_M.gguf
set CTX_SIZE=16384
set PORT=8080

echo ========================================================
echo Starting Pure CPU LLM Server...
echo Model  : %MODEL%
echo Host   : http://127.0.0.1:%PORT%
echo Context: %CTX_SIZE% (16K optimized for CPU)
echo GPU    : Disabled (ngl 0)
echo Threads: P-core direct binding [8 Physical Cores]
echo ========================================================

:: Parameters Explained:
:: 1. ngl 0: Disables GPU offloading completely, forcing running on host CPU.
:: 2. c 16384: Default context size is 16K.
::    Note: Large physical RAM (e.g. 64GB) is the main advantage of CPU mode.
::    This allows loading high-precision models (e.g., IQ4_XS) and setting a huge context size (e.g. 32K/64K) without VRAM OOM.
::    However, since CPU bandwidth is much lower than GPU, prefill speed (TTFT) will scale slowly at higher contexts.
::    Adjust CTX_SIZE above to 32768 or 65536 if your application requires huge context and you accept slower prefill times.
:: 3. threads 8: Binds thread pool directly to P-cores to prevent scheduling onto E-cores or hyperthreads.
:: 4. prio 2: High Priority in Windows to prevent background OS interrupts.

"%LLAMA_EXE%" ^
  -m "%MODEL%" ^
  -ngl 0 ^
  -c %CTX_SIZE% ^
  --host 127.0.0.1 ^
  --port %PORT% ^
  -np 1 ^
  -b 512 ^
  -ub 128 ^
  --mmap ^
  --no-warmup ^
  --jinja ^
  --threads 8 ^
  --threads-batch 12 ^
  --prio 2 ^
  --timeout 1200

pause

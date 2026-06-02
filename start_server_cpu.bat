@echo off
setlocal
title Llama.cpp CPU Server [Unified CPU Performance Tuning]

:: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
:: !!! CRITICAL: YOU MUST UPDATE THE PATHS BELOW TO REFLECT YOUR     !!!
:: !!! LOCAL ENVIRONMENT BEFORE RUNNING THIS SCRIPT.                 !!!
:: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
:: ====================================================================
:: [Configuration Paths] Please modify the paths below to match your system.
:: ====================================================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set PORT=8080
set CTX_SIZE=16384

:: --------------------------------------------------------------------
:: [Model Selection] Uncomment the one you want to run.
:: --------------------------------------------------------------------
:: Option A: Extreme MoE Player Choice (Qwen3.6-35B-A3B-Cerebellum 12GB GGUF) - RECOMMENDED
set MODEL=D:\MyProject\llama\Qwen3.6-35B-A3B-Cerebellum.gguf

:: Option B: High-Precision 7B CPU Baseline (Recommended IQ4_XS for balanced speed/quality)
:: set MODEL=D:\MyProject\llama\Qwopus3.6-7B-IQ4_XS.gguf

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
:: 2. c 16384: Default context size is 16K (optimized for general CPU speed).
::    Note: Huge physical RAM capacity is the core advantage of running on CPU.
::    - 16GB RAM: Easily scale context size (-c) up to 32K.
::    - 32GB RAM: Run high-precision quant (like IQ4_XS) and scale context size (-c) to 128K (131072) without OOM.
::    - 64GB+ RAM: Run larger models (27B/72B) with 128K+ context sizes fully unhindered.
::    However, since CPU memory bandwidth is lower than GPU, prefill speed (TTFT) scales slowly.
::    If you accept slower prefill times, feel free to adjust CTX_SIZE above to 131072 to unlock maximum capacity.
:: 3. threads 8: Binds thread pool directly to P-cores to prevent scheduling onto E-cores or hyperthreads.
:: 4. prio 2: High Priority in Windows to prevent background OS interrupts.
:: 5. Note on MTP (Speculative Decoding) on CPU: While llama.cpp supports MTP on CPU, testing shows
::    that enabling MTP does NOT speed up CPU inference. The draft head evaluation overhead and memory
::    bandwidth contention actually slow down decoding. Thus, MTP parameters are omitted here.

:: Verify paths exist before executing to prevent silent crashes
if not exist "%LLAMA_EXE%" (
    echo ========================================================
    echo [CRITICAL ERROR] llama-server.exe was not found at:
    echo "%LLAMA_EXE%"
    echo.
    echo Please open this .bat file in a text editor and update
    echo the LLAMA_EXE path variable to point to your actual executable!
    echo ========================================================
    pause
    exit /b
)

if not exist "%MODEL%" (
    echo ========================================================
    echo [CRITICAL ERROR] GGUF Model file was not found at:
    echo "%MODEL%"
    echo.
    echo Please open this .bat file in a text editor and update
    echo the MODEL path variable to point to your actual .gguf file!
    echo ========================================================
    pause
    exit /b
)

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

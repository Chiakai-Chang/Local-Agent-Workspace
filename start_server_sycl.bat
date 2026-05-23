@echo off
chcp 65001 >nul
title Llama Server (Intel SYCL - Claw 8 AI+)

:: ====================================================================
:: ⚠️ Intel oneAPI setvars.bat 路徑 (若預設安裝路徑不同請修改)
:: ====================================================================
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"

:: SYCL 優化環境變數
set SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
set SYCL_CACHE_PERSISTENT=1
set SYCL_DEVICE_FILTER=level_zero:gpu:0
set ZES_ENABLE_SYSMAN=1

:: ====================================================================
:: ⚠️ 請修改以下變數以配合您的實際檔案與路徑
:: ====================================================================
set LLAMA_DIR=D:\Myproject\llama-win-sycl-x64
set MODEL=C:\models\GRM-2.6-Opus.i1-IQ3_M.gguf
set CTX_SIZE=98304
set PORT=8080

cd /d "%LLAMA_DIR%"

echo Starting Local LLM Server (Intel SYCL)...
echo ========================================================
echo Model  : %MODEL%
echo Server : http://127.0.0.1:%PORT%
echo GPU    : Intel Arc Graphics (Level Zero GPU 0)
echo Context: %CTX_SIZE% (96K)
echo KV     : q4_0 / q4_0 (KV Cache quantized to save memory)
echo Batch  : 512 / 128
echo ========================================================

llama-server.exe ^
  -m "%MODEL%" ^
  --host 127.0.0.1 ^
  --port %PORT% ^
  -ngl 99 ^
  -c %CTX_SIZE% ^
  -np 1 ^
  -b 512 ^
  -ub 128 ^
  --cache-type-k q4_0 ^
  --cache-type-v q4_0 ^
  --flash-attn on ^
  --mmap ^
  --no-warmup ^
  --jinja ^
  --cache-ram 0 ^
  --threads 12 ^
  --prio 2 ^
  --timeout 1200

pause

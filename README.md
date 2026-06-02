# 🚀 Local-Agent-Workspace

> [!IMPORTANT]
> **個人立場聲明：** 本專案僅為個人技術研究分享，所有內容與參數調校均基於公開開源數據（Open Source Data）。專案內容不代表任何機關立場，亦不涉及任何公務機敏資料與軟體。

### 開發者本地 AI 部署指南：Llama.cpp 極致壓榨與模型推薦

這是一個旨在協助開發者在本地環境快速部署高效能大語言模型（LLM）的實戰指南。我們專注於如何透過 **Llama.cpp** 與精準的參數調校，在有限的硬體資源下，榨出最大的 Context 空間與推理速度。

本專案的核心目標在於解決雲端 API 的隱私疑慮、頻繁的審查限制以及長文本處理成本，為後續銜接自動化 Agent 工具打造最堅實的底層引擎。

> [!IMPORTANT]
> **⚡ 3秒一鍵下載 & AI 自適應配置 C.A.S.E 規範 (極簡低摩擦力設計)**
>
> 1️⃣ **第一步：在您想開發的任何專案根目錄下，開啟終端機執行指令下載規則檔**：
> * **💻 Linux / macOS / Git Bash (cURL)**:
>   ```bash
>   curl -fsSL https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md -o CASE_framework_for_agents.md
>   ```
> * **💻 Windows (PowerShell)**:
>   ```powershell
>   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md" -OutFile "CASE_framework_for_agents.md"
>   ```
>
> 2️⃣ **第二步：啟動您的 AI 智能體 (如 Cursor / Claude Code / Windsurf) 並貼上下列 Prompt**：
> > 「請閱讀我專案中的 [CASE_framework_for_agents.md](CASE_framework_for_agents.md) 文件。閱讀後，請分析我目前的專案結構，規劃如何以最合適的方式為本專案建立 C.A.S.E 物理目錄結構（包含 Constitution、Roadmap、Task_Queue 任務資料夾），並將此執行期規則妥善整合寫入您的長效記憶配置中（例如 `CLAUDE.md`、`.cursorrules`、`gemini.md` 或 `memory.md` 等對應位置）。在建立目錄與寫入配置前，請先向我報告您的規劃並取得我的同意。」
>
> 🌟 **結果**：AI 智能體將會**自己動手**幫您做好專案分析、創立所有目錄、並配置好 IDE 的原生規則設定！完全不需要您手動搬移任何檔案，安全、乾淨且優雅！
> 👉 **[進入詳細 C.A.S.E. 框架設計說明](C.A.S.E._Framework/README.md)**

> [!TIP]
> **測試硬體參考：** NVIDIA RTX A4500 (20GB VRAM) / 64GB RAM。
> **硬體適應性：** 只要具備 NVIDIA GPU 且 VRAM 充足（建議 12GB 以上，20GB 為完美甜蜜點），皆可參考本指南進行部署與參數調整。

---

## 🧩 CK 的 AI 開發生態系 (The Ecosystem)

寫 Code 用 AI 輔助，常常遇到 API Quota 枯竭、或是全案掃描時 Token 費用太傷本的問題嗎？💸

本專案**無意取代強大的雲端大模型**，而是致力於探索一套 **「Hybrid AI (雲端 + 本地混合)」** 的高 CP 值開發流。

我們提倡將極需高智力、龐大 Context 與關聯研究能力的「高階規劃任務」交由雲端前沿模型（如 Claude、Gemini、GPT 等各大廠旗艦模型）擔任**架構師**；接著，將極度消耗 Token 的「依序執行、TDD 測試、全案掃描」等苦力活，無縫轉交給這套本地生態系擔任**執行者與稽核員**：

<p align="center">
  <img src="assets/ecosystem.svg" alt="CK's AI Development Ecosystem" width="100%">
</p>

* 🧠 **[Tier 1: 核心大腦 (Local-Agent-Workspace)](https://github.com/Chiakai-Chang/Local-Agent-Workspace)：** 建立極致優化的 Llama.cpp 本地伺服器。作為承接雲端架構師規劃後，能無情消耗 Token 進行打底運算的強大本地算力引擎。（📍 **您目前在這裡**）
* 🤖 **[Tier 2: 代理工程師 (CK's Pi Code Agent Harness)](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness)：** 混合開發的指揮樞紐。負責接收雲端模型開出的「任務菜譜與 SOP」，在本地端化身為懂工程紀律的虛擬同事，按部就班地切換目標檔案、撰寫程式碼並嚴格執行 TDD 測試。
* 👁️ **[Tier 3: 全域修復雷達 (OmniHeal)](https://github.com/Chiakai-Chang/OmniHeal)：** 零安裝的全局專案健檢工具。全案掃描是最耗 Token 的環節，直接交由本工具在本地一鍵免費深潛，自動抓出技術債並開立精準的修復處方箋，讓雲端模型或代理工程師能針對性地進行修復。

### 🏅 延伸工具：知識資產提煉

> **核心哲學：** 您過去的每一次會議、閱讀、工作經歷，都是尚未開採的「知識金礦」——問題只在於有沒有工具幫您煉出黃金。

📝 **[InfoGold - 經歷提煉與知識資產增值](https://github.com/Chiakai-Chang/InfoGold)**：扮演「煉金助理」的角色，將會議逐字稿、工作手稿、閱讀筆記等原始文字資產，透過四部曲系統化增值：**洗礦（忠實固化原始知識）→ 精煉金磚（結構加值）→ 圓桌思辨（MECE 跨域專家辯證，發掘隱藏洞察）→ 鑄造策略貨幣（30-60-90 天可行動落地路徑）**

不只是整理，更是讓「曾經發生過的事」持續產生複利——將每一份經歷轉化為可行動、可呈報、可傳承的黃金知識資產。

---

## 💎 部署本地環境的優勢

* **🔒 物理性資料隔離：** 在正確的部署設定下，程式碼與專案架構留在本地端，不經過外部伺服器。特別適合處理具備高度機敏性、數位鑑識或 OSINT 封閉分析等高度重視資料邊界的專案。
* **🧠 高上下文容量：** 透過優化的 KV 快取壓縮技術，在 20GB VRAM 下依然可支援至 **128K+ Context**。
* **🔓 任務連續性：** 選擇特徵消融（Abliterated）模型，可避免 Agent 在執行特定分析腳本時因安全機制而強行中斷。
* **💰 成本效益：** 適合頻繁開發與自動化迭代，無懼雲端 API 昂貴的 Token 費用。

---

## 🛠️ 1. 運算引擎準備：Llama.cpp

我們強烈推薦使用官方版的 **Llama.cpp** 作為伺服器引擎，更新最快、功能最完整。

> [!IMPORTANT]
> **Llama.cpp 官方版安裝必看：雙檔案合併解壓縮**
> 請至 [Llama.cpp Releases](https://github.com/ggml-org/llama.cpp/releases) 下載。必須同時下載兩個檔案：
> 1. **主程式：** `llama-b...-bin-win-cuda-cu12.4-x64.zip` (尋找標註 win-cuda-cu12.4 的版本)
> 2. **CUDA 依賴包：** `cudart-llama-bin-win-cu12.4-x64.zip`
> 
> 💡 **強烈建議選擇 `cu12.4` 版本**以確保最高穩定性。建立專屬資料夾（例如：`C:\llama.cpp`），**將這兩個壓縮檔解壓縮到同一個資料夾內**，確保 `llama-server.exe` 旁邊有 `.dll` 依賴檔。

---

## 📦 2. 模型權重推薦 (GGUF & MTP 自我推測)

在 20GB VRAM (如 RTX A4500) 或 32GB 記憶體 (如 Claw 8) 的環境下，以下是我實測後強烈推薦的模型：

### 🌟 A. 穩定首選 (代理橋接與複雜自動化)
🔥 **[GRM-2.6-Opus.i1-IQ4_XS](https://huggingface.co/mradermacher/GRM-2.6-Opus-i1-GGUF/blob/main/GRM-2.6-Opus.i1-IQ4_XS.gguf)** (約 15.2 GB)
> 融合頂尖的 GRM 邏輯與 Claude Opus 的推理風格。輸出極度穩定的結構化思維，大幅降低 Agent 解析指令的錯誤率。IQ4_XS 量化完美適配 20GB VRAM，留下充足餘裕給長文本運算。

### ⚡ B. 速度與效能黑科技 (MTP 自我推測解碼)
🔥 **[Qwen3.6-35B-A3B-Claude-4.7-Opus-Reasoning-Distilled-APEX-MTP-GGUF](https://huggingface.co/mudler/Qwen3.6-35B-A3B-Claude-4.7-Opus-Reasoning-Distilled-APEX-MTP-GGUF)** (Mini 版約 13.7 GB / Balanced 版約 18.5 GB)
> **黑科技推薦：** 該版本將 Model 的 **MTP (Multi-Token Prediction) 頭**與 Trunk 主體打包在同一個 GGUF 檔中。搭配近期版本的 llama.cpp，只需在啟動參數加入 `--draft-mtp`，即可在**不掛載額外 draft 模型**的情況下啟動「自我推測解碼（Self-Speculative Decoding）」，推理速度大幅飆升，極度適合 RTX A4500 等 20GB VRAM GPU 壓榨效能！

### 💻 C. 程式開發特化 (純代碼生成與 JSON 結構化)
🔥 **[Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS](https://huggingface.co/DavidAU/Qwen3.6-27B-NEO-CODE-Di-IMatrix-MAX-GGUF/blob/main/Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS.gguf)** (約 15.4 GB)
> 專為高難度程式碼任務與 JSON 格式輸出優化。若工作流偏好原生 Qwen 思維模式來進行專案重構，這是一台非常優秀的純代碼生產機器。

*(新手科普：`IQ` 系列量化搭配 `i1` 矩陣技術，能在相同檔案大小下比傳統 `Q` 系列保留更多模型智商。檔案大小與 VRAM 之間務必保留 4~5GB 以上作為 Context 運算空間。)*

---

## 🚀 3. 一鍵啟動伺服器 (多硬體極致優化版)

> [!WARNING]
> **💡 為什麼舊版的啟動腳本會出錯？**
> 隨著 Llama.cpp 的快速迭代，許多舊參數已被廢棄或整合。若您遇到啟動閃退或錯誤，通常是因為：
> 1. **已移除的參數：** `--cache-reuse`、`--cache-prompt`、`--context-shift` 在新版中已被廢棄（快取管理已自動化）。
> 2. **更名的參數：** `--parallel 1` 已更名為 `-np 1` 或 `--slots 1`（代表並行 Slot 數量）。
> 3. **記憶體映射：** `--no-mmap` 會大幅拖慢模型載入速度，新版建議改用預設的 `--mmap`。
> 4. **Batch 大小：** `-b 4096` 與 `-ub 1024` 在長 Context 時可能導致 OOM，已調整為穩健的 `512` 與 `128`。

本專案已將優化後的啟動腳本直接存於專案根目錄，您可以直接複製或修改使用：

### 🟢 A. NVIDIA GPU 專用啟動檔 ([`start_server_nvidia.bat`](file:///D:/Myproject/Local-Agent-Workspace/start_server_nvidia.bat))
適合 RTX A4500 (20GB VRAM) 或其他 NVIDIA 顯示卡，使用穩健的 Llama.cpp CUDA 引擎：
```batch
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
```

### ⚡ B. NVIDIA GPU + MTP 自我推測解碼 ([`start_server_nvidia_mtp.bat`](file:///D:/Myproject/Local-Agent-Workspace/start_server_nvidia_mtp.bat))
適合搭配 `APEX-MTP` 權重檔案，一鍵解鎖高達 2 倍的推理生成速度：
```batch
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
```

### 🔵 C. Intel Arc / SYCL 平台專用啟動檔 ([`start_server_sycl.bat`](file:///D:/Myproject/Local-Agent-Workspace/start_server_sycl.bat))
適合 MSI Claw 8 AI+、Intel 內顯、Arc 獨立顯卡或 Intel CPU，透過 level_zero 驅動加速：
```batch
@echo off
chcp 65001 >nul
title Llama Server (Intel SYCL - Claw 8 AI+)

:: 載入 Intel oneAPI 環境變數
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"

:: SYCL 執行優化環境變數
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
echo KV     : q4_0 / q4_0
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
```

---

## 🤖 4. 銜接自動化 Agent

本地伺服器啟動完成後（預設運行於 `http://127.0.0.1:8080`），您就可以將其接入各類 Coding Agent 或自動化工具。

### 🌟 生態系核心推薦：Pi Coding Agent + Harness 套件
雖然本指南過去以 Claude Code 為主，但在本地實戰中，我們強烈建議改用更輕量、更具擴充性的 **Pi Coding Agent**，並搭配我們的專屬套件：
👉 前往 [**CK's Pi Code Agent Harness**](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness)

**為什麼推薦這個組合？**
1. **解決 Context 溢位：** 雲端 CLI 工具（如 Claude Code）無法精準控制本地端 auto-compact 觸發時機，容易造成本地 LLM 的 Context 溢出。Pi Agent 可以完美依照本地模型的限制設定。
2. **極致輕量：** 本地 GGUF 模型對於冗餘 Token 極度敏感。Harness 精選了核心 plugins 與 skills，能以最精簡的 prompt 格式發揮本地模型的最大智商。
3. **無縫整合健康診斷：** 與 **OmniHeal** 工具完美串接，一鍵檢查專案技術債，再交由本地算力精準修復。

*(若您仍需使用 Claude Code，只需在專案目錄下設定環境變數 `set ANTHROPIC_BASE_URL=http://127.0.0.1:8080`，請參考根目錄的 `start_local_claude.bat` 啟動。)*

---

## 📮 聯繫與交流

如果您在部署過程中有任何技術問題或參數優化的建議，歡迎透過以下管道聯繫：

**May the Local AI be with you.**

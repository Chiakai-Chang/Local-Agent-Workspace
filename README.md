# 🚀 Local-Agent-Workspace

> [!IMPORTANT]
> **個人立場聲明：** 本專案僅為個人技術研究分享，所有內容與參數調校均基於公開開源數據（Open Source Data）。專案內容不代表任何機關立場，亦不涉及任何公務機敏資料與軟體。

### 開發者本地 AI 部署指南：Llama.cpp 極致壓榨與模型推薦

這是一個旨在協助開發者在本地環境快速部署高效能大語言模型（LLM）的實戰指南。我們專注於如何透過 **Llama.cpp** 與精準的參數調校，在有限的硬體資源下，榨出最大的 Context 空間與推理速度。

本專案的核心目標在於解決雲端 API 的隱私疑慮、頻繁的審查限制以及長文本處理成本，為後續銜接自動化 Agent 工具打造最堅實的底層引擎。

> [!TIP]
> **測試硬體參考：** NVIDIA RTX A4500 (20GB VRAM) / 64GB RAM。
> **硬體適應性：** 只要具備 NVIDIA GPU 且 VRAM 充足（建議 12GB 以上，20GB 為完美甜蜜點），皆可參考本指南進行部署與參數調整。

---

## 🧩 CK 的 AI 開發生態系 (The Ecosystem)

為了達到真正的「工業級本地 AI 開發」，本專案是完整生態系的**第一步（底層動力）**。建議搭配以下專案使用，以獲得最佳開發體驗：

1. ⚙️ **基礎引擎 (本專案)：** 建立極致優化的 Llama.cpp 本地伺服器與模型選擇。
2. 🧠 **作業大腦 [CK's Pi Code Agent Harness](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness)：** 放棄難以控制 Context 大小的 Claude Code，改用更輕量、具備專家紀律與完美 Context 控制的 Pi Coding Agent。
3. 🩺 **品質守衛 [OmniHeal](https://github.com/Chiakai-Chang/OmniHeal)：**
   AI 協作久了容易累積技術債？使用這個零安裝的健檢工具箱，一鍵掃描並產出修復行動路線圖。

---

## 💎 部署本地環境的優勢

* **🔒 物理級資料隔離：** 程式碼、專案架構完全留在本地。特別適合處理具備高度機敏性、數位鑑識或 OSINT 封閉分析等不容許資料外流的專案。
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

## 📦 2. 模型權重推薦 (GGUF)

在 20GB VRAM 的環境下，以下是我實測後強烈推薦的模型：

### 🌟 穩定首選 (代理橋接與複雜自動化)
🔥 **[GRM-2.6-Opus.i1-IQ4_XS](https://huggingface.co/mradermacher/GRM-2.6-Opus-i1-GGUF/blob/main/GRM-2.6-Opus.i1-IQ4_XS.gguf)** (約 15.2 GB)
> 融合頂尖的 GRM 邏輯與 Claude Opus 的推理風格。輸出極度穩定的結構化思維，大幅降低 Agent 解析指令的錯誤率。IQ4_XS 量化完美適配 20GB VRAM，留下充足餘裕給長文本運算。

### 💻 程式開發特化 (純代碼生成與 JSON 結構化)
🔥 **[Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS](https://huggingface.co/DavidAU/Qwen3.6-27B-NEO-CODE-Di-IMatrix-MAX-GGUF/blob/main/Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS.gguf)** (約 15.4 GB)
> 專為高難度程式碼任務與 JSON 格式輸出優化。若工作流偏好原生 Qwen 思維模式來進行專案重構，這是一台非常優秀的純代碼生產機器。

*(新手科普：`IQ` 系列量化搭配 `i1` 矩陣技術，能在相同檔案大小下比傳統 `Q` 系列保留更多模型智商。檔案大小與 VRAM 之間務必保留 4~5GB 以上作為 Context 運算空間。)*

---

## 🚀 3. 一鍵啟動伺服器 (RTX A4500 極致優化版)

以下是我針對 **20GB VRAM (如 RTX A4500)** 所調校出的最佳化啟動腳本。它能最大化吞吐量、開啟 Flash Attention，並使用 4-bit 壓縮 KV Cache 以換取更大的 Context 空間。

請將以下程式碼存成 `start_server.bat`，並確保修改變數路徑：

```batch
@echo off
chcp 65001 > nul
setlocal

title GRM-2.6-Opus IQ4_XS 128K - RTX A4500

:: ==========================================
:: ⚠️ 請修改以下兩個路徑為您電腦中的實際位置
:: ==========================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\GRM-2.6-Opus.i1-IQ4_XS.gguf
set CTX_SIZE=131072
set PORT=8080

echo Starting Local LLM Server...
echo ========================================================
echo Model  : %MODEL%
echo Server : [http://127.0.0.1](http://127.0.0.1):%PORT%
echo GPU    : RTX A4500 20GB
echo Context: %CTX_SIZE% (128K)
echo KV     : q4_0 / q4_0
echo Batch  : 1024 / 256
echo ========================================================

"%LLAMA_EXE%" ^
  -m "%MODEL%" ^
  -ngl 999 ^
  -c %CTX_SIZE% ^
  --host 127.0.0.1 ^
  --port %PORT% ^
  --parallel 1 ^
  -b 4096 ^
  -ub 1024 ^
  --cache-type-k q4_0 ^
  --cache-type-v q4_0 ^
  --flash-attn on ^
  --context-shift ^
  --no-mmap ^
  --mlock ^
  --no-warmup ^
  --jinja ^
  --cache-prompt ^
  --cache-reuse 512 ^
  --threads 8 ^
  --threads-batch 12 ^
  --prio 2 ^
  --timeout 900

pause

```

---

## 🤖 4. 銜接自動化 Agent

伺服器啟動完成後（預設運行於 `http://127.0.0.1:8080`），您就可以將其接入各類 Coding Agent。

### 🌟 首選推薦：Pi Coding Agent + Harness 套件

雖然本指南過去以 Claude Code 為主，但實戰中我們發現 Claude Code 難以自訂 Auto-compact 的大小，容易在本地模型中造成 Context 溢位或效能衰退。

因此，**我們強烈建議改用 Pi Coding Agent**，並搭配我們的專屬套件：
👉 前往 [**CK's Pi Code Agent Harness**](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness)

該套件解決了上述痛點，不僅更輕量，還注入了全球頂尖專家的開發直覺（TDD、BDD）與紀律，是目前本地環境最完美的搭檔。

*(若您仍需使用 Claude Code，只需在專案目錄下設定環境變數 `set ANTHROPIC_BASE_URL=http://127.0.0.1:8080` 與假 Token 即可啟動。)*
> 以下作法參考自: [How to Run Local LLMs with Claude Code](https://unsloth.ai/docs/basics/claude-code)

請將以下程式碼存成 `start_local_claude.bat`，並複製到想要啟動的資料夾內啟動即可 (注意 "ANTHROPIC_BASE_URL=http://127.0.0.1:8080" 要修改成你 llama.cpp 指定的 URL 與 port)：

```batch
@echo off
setlocal

title Claude Local
color 0A

set ANTHROPIC_BASE_URL=http://127.0.0.1:8080

set CLAUDE_CODE_ATTRIBUTION_HEADER=0
set CLAUDE_CODE_ENABLE_TELEMETRY=0
set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

claude --dangerously-skip-permissions

endlocal

```

---

## 📮 聯繫與交流

如果您在部署過程中有任何技術問題或參數優化的建議，歡迎透過以下管道聯繫：

**May the Local AI be with you.**

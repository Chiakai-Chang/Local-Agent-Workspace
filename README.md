# 🚀 Local-Agent-Workspace

> [!IMPORTANT]
> **個人立場聲明：** 本專案僅為個人技術研究分享，所有內容與參數調校均基於公開開源數據。專案內容不代表任何機關立場，亦不涉及任何公務機敏資料。

### 開發者本地 AI 部署指南：Llama.cpp 極致性能壓榨與 Agent 銜接

本專案旨在協助開發者在本地環境快速部署高效能大語言模型（LLM），解決雲端 API 的隱私疑慮、頻繁審查限制以及長文本成本。透過 **Llama.cpp** 與精準的參數調校，在有限硬體資源下榨出最大 Context 空間與極致推論速度。

---

## ⚡ 30 秒硬體與平台快速選取看板 (Dashboard)

請依據您的本機硬體配置，直接選用最合適的啟動腳本與推薦模型：

| 平台 / 硬體環境 (Platform) | 核心推薦模型 (Recommended Model) | 檔案大小 (Size) | 推理優化技術 (Inference Tech) | 啟動批次檔 (BAT Script) |
| :--- | :--- | :--- | :--- | :--- |
| **🟢 NVIDIA 高階卡 (20GB VRAM)** | GRM-2.6-Opus-Heretic 27B | 15.3 GB | MTP 投機解碼 (~49 T/s) | [`start_server_nvidia.bat`](start_server_nvidia.bat) |
| **🟡 NVIDIA 中階卡 (16GB VRAM)** | Qwopus3.6-27B-v2 | 15.4 GB | MTP 投機解碼 (~44 T/s) | [`start_server_nvidia_mtp.bat`](start_server_nvidia_mtp.bat) |
| **🔵 純 CPU / 大 RAM (32GB+)** | Qwen3.6-35B-A3B-Cerebellum | **12 GB** | SSM+MoE 混合線性推理 | [`start_server_cpu.bat`](start_server_cpu.bat) |

---

## 🚀 3 分鐘快速上手 (將 C.A.S.E 規範一鍵植入任何 AI 專案)

<details>
<summary><b>1️⃣ 第一步：一鍵下載 C.A.S.E. Agent 規則手冊 (CASE_framework_for_agents.md)</b></summary>

請在您的開發專案根目錄下，開啟終端機並執行以下指令下載唯讀規則檔：
* **💻 Linux / macOS / Git Bash (cURL)**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md -o CASE_framework_for_agents.md
  ```
* **💻 Windows (PowerShell)**:
  ```powershell
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md" -OutFile "CASE_framework_for_agents.md"
  ```
</details>

<details>
<summary><b>2️⃣ 第二步：給您的 AI Agent 貼上引導 Prompt</b></summary>

啟動您的 AI Agent (如 `Claude Code`、`Codex`、`Antigravity CLI`、`Pi`，或是 `Cursor` 等），將下載好的 `CASE_framework_for_agents.md` 文件作為參考（例如在 Cursor 中使用 `@`），並輸入以下 Prompt：

> 「請閱讀我專案中的 [CASE_framework_for_agents.md](CASE_framework_for_agents.md) 文件。閱讀後，請分析我目前的專案結構，規劃如何以最合適的方式為本專案建立 C.A.S.E 物理目錄結構（包含 Constitution、Roadmap、Task_Queue 任務資料夾），並將此執行期規則妥善整合寫入您的長效記憶配置中（例如 `CLAUDE.md`、`.cursorrules`、`gemini.md` 或 `memory.md` 等對應位置）。在建立目錄與寫入配置前，請先向我報告您的規劃並取得我的同意。」
</details>

<details>
<summary><b>3️⃣ 第三步：檢閱並同意 AI 的自動配置</b></summary>

AI Agent 讀取 Prompt 後，將會**自己動手**完成：
1. 分析您目前的程式語言與專案結構。
2. 自動建立 `00_Constitution/`、`01_Roadmap/` 與 `02_Task_Queue/` 等實體目錄。
3. 自動將 C.A.S.E. 執行期規則妥善整合寫入到您的本機長效記憶配置中。

您只需輸入同意，AI 就會自己幫您全部設定妥當！安全、乾淨且優雅！

👉 **[進入詳細 C.A.S.E. 框架設計說明](C.A.S.E._Framework/README.md)**
</details>

---

## 🧩 CK 的 AI 開發生態系 (The Ecosystem)

我們提倡 **「Hybrid AI (雲端架構師 + 本地執行者)」** 的高效能高 CP 值開發流：
* **雲端前沿模型（Claude/Gemini/GPT）**：擔任 **「架構師」**，處理高智力規劃、大方向架構與關聯研究。
* **本地生態系**：擔任 **「執行者與稽核員」**，進行極度消耗 Token 的「依序執行、代碼撰寫、TDD 測試與全案掃描」。

<p align="center">
  <img src="assets/ecosystem.svg" alt="CK's AI Development Ecosystem" width="100%">
</p>

<details>
<summary><b>🔍 展開檢視開發生態系三大核心 Tier</b></summary>

* 🧠 **[Tier 1: 核心大腦 (Local-Agent-Workspace)](https://github.com/Chiakai-Chang/Local-Agent-Workspace)：** 建立極致優化的 Llama.cpp 本地伺服器。作為承接雲端架構師規劃後，能無情消耗 Token 進行打底運算的強大本地算力引擎。（📍 **您目前在這裡**）
* 🤖 **[Tier 2: 代理工程師 (CK's Pi Code Agent Harness)](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness)：** 混合開發的指揮樞紐。負責接收雲端模型開出的「任務菜譜與 SOP」，在本地端化身為懂工程紀律的虛擬同事，按部就班地切換目標檔案、撰寫程式碼並嚴格執行 TDD 測試。
* 👁️ **[Tier 3: 全域修復雷達 (OmniHeal)](https://github.com/Chiakai-Chang/OmniHeal)：** 零安裝的全局專案健檢工具。全案掃描是最耗 Token 的環節，直接交由本工具在本地一鍵免費深漸，自動抓出技術債並開立精準的修復處方箋，讓雲端模型或代理工程師能針對性地進行修復。

#### 🏅 延伸工具：知識資產提煉
📝 **[InfoGold - 經歷提煉與知識資產增值](https://github.com/Chiakai-Chang/InfoGold)**：扮演「聯金助理」的角色，將會議逐字稿、工作手稿、閱讀筆記等原始文字資產，透過四部曲系統化增值：**洗礦→精煉金磚→圓桌思辨→鑄造策略貨幣**，讓「曾經發生過的事」持續產生知識複利。
</details>

<details>
<summary><b>💎 展開檢視本地部署的四大優勢 (隱私、高上下文、免安全中斷、零Token成本)</b></summary>

* **🔒 物理性資料隔離：** 程式碼與專案架構保留在本地，特別適合高度重視資料邊界、數位鑑識與 OSINT 封閉分析等專案。
* **🧠 高上下文容量：** 透過優化的 KV 快取壓縮技術，在 20GB VRAM 下依然可支援至 **128K+ Context**。
* **🔓 任務連續性：** 選擇特徵消融（Abliterated）模型，可避免 Agent 在執行特定分析腳本時因安全機制而強行中斷。
* **💰 成本效益：** 適合頻繁開發與自動化迭代，無懼雲端 API 昂貴的 Token 費用。
</details>

---

## 🛠️ 第一步：運算引擎與權重下載

為了維持頁面簡潔，詳細的下載與配置指南已整理至折疊卡片中：

<details>
<summary><b>📦 1. 下載並安裝 Llama.cpp 官方版 (雙檔案合併解壓縮)</b></summary>

請至 [Llama.cpp Releases](https://github.com/ggml-org/llama.cpp/releases) 下載。必須同時下載兩個檔案並解壓縮至同一個資料夾：
1. **主程式：** `llama-b...-bin-win-cuda-cu12.4-x64.zip` (尋找標註 win-cuda-cu12.4 的版本)
2. **CUDA 依賴包：** `cudart-llama-bin-win-cu12.4-x64.zip`

💡 **強烈建議選擇 `cu12.4` 版本**以確保最高推論穩定性。解壓至例如 `C:\llama.cpp`，確保 `llama-server.exe` 旁邊有 `.dll` 依賴檔即可。
</details>

<details>
<summary><b>📦 2. 下載推薦模型權重 (MTP 自我推測性能怪獸 & 頂級 MoE)</b></summary>

* **🔥 NVIDIA 首選：GRM-2.6-Opus-Heretic-Abliterated-MTP-IQ4_XS (15.3 GB)**
  * **特點**：融合極強的 GRM 推理邏輯與 Claude Opus 思考風格，完全移除安全限制，執行 Agent 指令最穩定。
  * **實測效能**：平均推論速度 **`49.12 tokens/sec`**，MTP 預測草案接受率高達 **`69.58%`**！
  * **[下載連結](https://huggingface.co/mradermacher/GRM-2.6-Opus-Heretic-Abliterated-MTP-i1-GGUF)**
* **⚡ NVIDIA 中階選：Qwopus3.6-27B-v2-MTP-IQ4_XS (15.4 GB)**
  * **特點**：專為寫程式與複雜架構分析優化的 27B 推理巨獸，本地最強代碼生產力機器。
  * **實測效能**：平均推論速度 **`44.14 tokens/sec`** (峰值可達 **`50.79 T/s`**)。
  * **[下載連結](https://huggingface.co/Jackrong/Qwopus3.6-27B-v2-MTP-GGUF/)**
* **🧠 CPU 首選：Qwen3.6-35B-A3B-Cerebellum (12 GB)**
  * **特點**：SSM+Attention+MoE 混合架構，活化參數僅 3B。原生支援 262K 上下文，Cerebellum 敏感度引導壓縮至 12GB，實體記憶體充足下是 CPU 智商與效能的極限選擇。
  * **[下載連結](https://huggingface.co/deucebucket/Qwen3.6-35B-A3B-Cerebellum-GGUF)**

*(科普提示：`IQ` 量化搭配 `i1` 矩陣技術，能在相同檔案下保留更多智商。檔案大小與 VRAM 之間務必保留 4~5GB 以上作為 Context 運算空間。)*
</details>

---

## 🚀 第二步：一鍵啟動伺服器 (Server Startup Scripts)

> [!IMPORTANT]
> **⚠️ 必做步驟：請務必開啟並修改批次檔中的路徑！**
> 本專案提供之 `.bat` 啟動檔中，`LLAMA_EXE` 與 `MODEL` 路徑預設為開發環境預設路徑（如 `D:\MyProject\...`）。**在您首次執行前，請務必用文字編輯器打開 `.bat` 檔案，將這兩個變數修改為您本機的實際路徑！**
> * 為了防範路徑錯誤造成的閃退，我們已在所有 `.bat` 中內建了 **「檔案路徑自動校驗機制」**，若路徑未修改或檔案不存在，啟動時將會在 Console 顯示錯誤警告並自動暫停（Pause），便於您排查！

> [!WARNING]
> **💡 批次檔語系相容性注意**：
> 舊版 batch 檔常因包含中文括號 `(` 與 `)` 導致 Windows CMD 解析錯誤閃退。本專案啟動檔已全面改為 **100% 純英文語法與括號**，徹底消除任何語系 Code Page 閃退問題。

### 🟢 A. GRM-Opus MTP 啟動檔 ([`start_server_nvidia.bat`](start_server_nvidia.bat))
適合配置 20GB VRAM (如 RTX A4500) 之高階 NVIDIA 環境，啟用最高效能推測解碼：
<details>
<summary><b>點此展開查看批次檔代碼與優化參數說明</b></summary>

```batch
@echo off
setlocal
title GRM-2.6-Opus-Heretic-Abliterated-MTP [RTX A4500 128K Max Performance]

:: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
:: !!! CRITICAL: YOU MUST UPDATE THE PATHS BELOW TO REFLECT YOUR     !!!
:: !!! LOCAL ENVIRONMENT BEFORE RUNNING THIS SCRIPT.                 !!!
:: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
:: ====================================================================
:: [Configuration Paths] Please modify the paths below to match your system.
:: ====================================================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\GRM-2.6-Opus-Heretic-Abliterated-MTP-IQ4_XS.gguf
set CTX_SIZE=131072
set PORT=8080

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
```

#### 🛠️ 終極性能參數解析：
* **`--spec-type draft-mtp` & `--spec-draft-ngl all`**：自動載入 GGUF 內建預測頭，並將 base model 與 draft heads 全數塞入 VRAM 進行 GPU 滿載加速。
* **`-ctk q4_0 -ctv q4_0` 與 `-ctkd q4_0 -ctvd q4_0`**：將 KV Cache 進行 4-bit 量化壓縮，節省 72% VRAM！在 128K Context 時 KV 快取僅佔 ~200MB，徹底防範 VRAM 溢出。
* **`--kv-unified`**：令主模型與預測頭共享 KV Buffer 快取以節省記憶體。
* **`--cache-ram 12288`**：劃分 12GB 實體 RAM 快取對話上下文。多輪對話時，歷史脈絡直接載入，**跳過 prompt re-eval 進程，解鎖 sub-second 首字輸出速度**。
* **`--threads 8`**：將計算線程強制鎖定在 Intel i7 的 **8 顆 P-cores 實體效能核心**上，防範系統將線程派發給 E-cores 或超線程而拉高延遲。
* **`--reasoning-format deepseek`**：自動提取模型推理時產生的 `<think>` 思考流，完美對接 Open WebUI 等折疊式思維泡泡 UI。
</details>

### ⚡ B. Qwopus 27B MTP 啟動檔 ([`start_server_nvidia_mtp.bat`](start_server_nvidia_mtp.bat))
適合搭配 `Qwopus3.6-27B-v2-MTP` 權重，提供中階 NVIDIA 環境最優寫程式與推理性能：
<details>
<summary><b>點此展開查看批次檔代碼</b></summary>

```batch
@echo off
setlocal
title Qwopus3.6-27B-v2-MTP [RTX A4500 128K Max Performance]

:: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
:: !!! CRITICAL: YOU MUST UPDATE THE PATHS BELOW TO REFLECT YOUR     !!!
:: !!! LOCAL ENVIRONMENT BEFORE RUNNING THIS SCRIPT.                 !!!
:: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
:: ====================================================================
:: [Configuration Paths] Please modify the paths below to match your system.
:: ====================================================================
set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\Qwopus3.6-27B-v2-MTP-GGUF.gguf
set CTX_SIZE=131072
set PORT=8080

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
```
</details>

### 🔵 C. 純 CPU 平台專用啟動檔 ([`start_server_cpu.bat`](start_server_cpu.bat))
專為無 NVIDIA GPU 環境或超巨型長上下文優化。受益於大容量 RAM（如 32GB/64GB），能無痛加載大模型並直推至 128K 超大上下文而不擔心 VRAM OOM：
<details>
<summary><b>點此展開查看批次檔代碼與優化參數說明</b></summary>

```batch
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
```
</details>

#### 🛠️ CPU 極致優化解析：
* **`-ngl 0`**：強制關閉所有 GPU offload，運算全數留置在 CPU 與系統記憶體中。
* **`-c 16384`**：預設為 16K 平衡點。CPU 運行的核心優勢在於**主記憶體 (RAM) 相比 GPU 顯存便宜且容量巨大**。您完全不需要擔心 GPU VRAM OOM 崩潰的問題。
  * **💡 RAM 與 Context 的對照指南**：
    * **16GB RAM**：可將 `-c` 輕鬆推至 **32K**。
    * **32GB RAM**：不僅能以高精度模型 (如 `IQ4_XS` 等級) 運作，還可**直接將 `-c` 開滿 128K**，這在多數 20GB VRAM 的 GPU 上是極難實現的。
    * **64GB+ RAM**：可輕鬆運行 27B/35B 級模型，並開啟 **128K 以上** 的超巨型上下文。
* **⚠️ Prefill 效能權衡提醒 (核心 Trade-off)**：雖然 32GB RAM 就能吞下 128K 大上下文，但**由於 CPU 記憶體頻寬遠不及 GPU 顯存，Prefill 階段 (提示詞載入評估) 速度會非常緩慢**。這意味著開滿 128K 時的首字生成時間 (TTFT) 會拉長。若您的場景（例如大型代碼庫重構、長文本分析）著重在「一次性讀入巨大上下文且不介意首字等待時間」，那麼在 CPU 將 `-c` 直接開滿 128K 將會是您最強大的智商武器。
* **`--threads 8` & `--threads-batch 12`**：計算線程強制派發至主機 CPU 的 8 顆實體 P-cores（Performance cores），避免背景計算任務被派發到 E-cores（Efficient cores）或超線程中而大幅拉高生成延遲。
* **⚠️ 避免在 CPU 啟用 MTP 投機解碼 (Speculative Decoding)**：雖然 `llama.cpp` 技術上支援在 CPU 模式下配置 MTP，但**實測結果證實，在純 CPU 模式下啟用 MTP 投機解碼並不能達到提速效果**。由於 CPU 記憶體頻寬限制，額外評估 Draft heads 的計算開銷與頻寬爭搶反而會拖慢解碼速率。因此 CPU 專用啟動檔中已完全移除投機解碼參數，維持純粹的標準解碼路徑。

---

## 🤖 第三步：銜接自動化 Agent (Pi Coding Agent + Harness)

本地伺服器啟動完成後（預設運行於 `http://127.0.0.1:8080`），您就可以將其接入各類 Coding Agent。

### 🌟 核心推薦：Pi Coding Agent + Harness 套件
在本地實戰中，我們強烈建議使用更輕量、更具擴充性的 **Pi Coding Agent**，並搭配我們的專屬套件：
👉 前往 [**CK's Pi Code Agent Harness**](https://github.com/Chiakai-Chang/CKs_PI_Code_Agent_Harness)

**為什麼推薦這個組合？**
1. **解決 Context 溢位：** 雲端 CLI 工具（如 Claude Code）無法精準控制本地端 auto-compact 觸發時機，容易造成本地 LLM 的 Context 溢出。Pi Agent 可以完美依照本機模型的限制設定。
2. **極致輕量：** 本地 GGUF 模型對於冗餘 Token 極度敏感。Harness 精選了核心 plugins 與 skills，能以最精簡的 prompt 格式發揮本地模型的最大智商。
3. **無縫整合健康診斷：** 與 **OmniHeal** 工具完美串接，一鍵檢查專案技術債，再交由本地算力精準修復。

*(若您仍需使用 Claude Code，只需在專案目錄下設定環境變數 `set ANTHROPIC_BASE_URL=http://127.0.0.1:8080`，並參考根目錄的 `start_local_claude.bat` 啟動。)*

---

## 🙏 參考先驅與開源致敬 (Prior Art & Acknowledgements)

本專案的 **C.A.S.E 框架** 與 **Harness 控制座** 設計理念，深受 IBM Developer Advocate **Tejas Kumar** 於 **AI Engineer Europe 2026** 發表之經典專題演講所啟發。我們在此對先驅者的無私分享致以最誠摯的敬意：

* **📺 經典演講影片**：[Harnesses in AI: A Deep Dive — Tejas Kumar, IBM (YouTube)](https://youtu.be/C_GG5g38vLU?si=NVt8LgZaIRPOO6-Z)
* **💻 官方開源示範**：[TejasQ/agent-harness-demo (GitHub)](https://github.com/TejasQ)
* **🐦 講者社群連結**：[@TejasKumar_ (X/Twitter)](https://x.com/TejasKumar_) | [@TejasQ (GitHub)](https://github.com/TejasQ)

我們強烈推薦所有使用本生態系的開發者觀看該演講，以深入理解「不該過度依賴寫死 Prompt，而應透過 Harness 外部程式碼來管束黑盒子模型」的控制座工程核心思維。

---

## 📮 聯繫與交流

如果您在部署過程中有任何技術問題或參數優化的建議，歡迎透過以下管道聯繫：

**May the Local AI be with you.**

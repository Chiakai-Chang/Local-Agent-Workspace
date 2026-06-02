# 🚀 Local-Agent-Workspace

> [!IMPORTANT]
> **個人立場聲明：** 本專案僅為個人技術研究分享，所有內容與參數調校均基於公開開源數據（Open Source Data）。專案內容不代表任何機關立場，亦不涉及任何公務機敏資料與軟體。

### 開發者本地 AI 部署指南：Llama.cpp 極致壓榨與模型推薦

這是一個旨在協助開發者在本地環境快速部署高效能大語言模型（LLM）的實戰指南。我們專注於如何透過 **Llama.cpp** 與精準的參數調校，在有限的硬體資源下，榨出最大的 Context 空間與推理速度。

本專案的核心目標在於解決雲端 API 的隱私疑慮、頻繁的審查限制以及長文本處理成本，為後續銜接自動化 Agent 工具打造最堅實的底層引擎。

> [!IMPORTANT]
> **⚡ 3 分鐘快速上手（將 C.A.S.E 規範一鍵植入任何 AI 專案）**
>
> <details>
> <summary><b>1️⃣ 第一步：一鍵下載 C.A.S.E. Agent 規則手冊 (CASE_framework_for_agents.md)</b></summary>
>
> 請在您的專案根目錄下，開啟終端機並執行以下指令下載唯讀規則檔：
> * **💻 Linux / macOS / Git Bash (cURL)**:
>   ```bash
>   curl -fsSL https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md -o CASE_framework_for_agents.md
>   ```
> * **💻 Windows (PowerShell)**:
>   ```powershell
>   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md" -OutFile "CASE_framework_for_agents.md"
>   ```
> </details>
>
> <details>
> <summary><b>2️⃣ 第二步：給您的 AI Agent 貼上引導 Prompt</b></summary>
>
> 啟動您的 AI Agent (如 `Claude Code`、`Codex`、`Antigravity CLI`、`Pi`，或是 `Cursor` 等），將下載好的 `CASE_framework_for_agents.md` 文件作為參考（例如在 Cursor 中使用 `@`），並輸入以下 Prompt：
>
> > 「請閱讀我專案中的 [CASE_framework_for_agents.md](CASE_framework_for_agents.md) 文件。閱讀後，請分析我目前的專案結構，規劃如何以最合適的方式為本專案建立 C.A.S.E 物理目錄結構（包含 Constitution、Roadmap、Task_Queue 任務資料夾），並將此執行期規則妥善整合寫入您的長效記憶配置中（例如 `CLAUDE.md`、`.cursorrules`、`gemini.md` 或 `memory.md` 等對應位置）。在建立目錄與寫入配置前，請先向我報告您的規劃並取得我的同意。」
> </details>
>
> <details>
> <summary><b>3️⃣ 第三步：檢閱並同意 AI 的自動配置</b></summary>
>
> AI Agent 讀取 Prompt 後，將會**自己動手**完成：
> 1. 分析您目前的程式語言與專案結構。
> 2. 自動建立 `00_Constitution/`、`01_Roadmap/` 與 `02_Task_Queue/` 等實體目錄。
> 3. 自動將 C.A.S.E. 執行期規則妥善整合寫入到您的本機長效記憶配置中。
>
> 您只需輸入同意，AI 就會自己幫您全部設定妥當！完全不需要您手動搬移任何檔案，安全、乾淨且優雅！
> </details>
>
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

## 📦 2. 模型權重推薦 (MTP 自我推測解碼性能怪獸)

在 20GB VRAM (如 RTX A4500) 或 64GB 記憶體的環境下，強烈推薦以下兩款 **27B 自我推測解碼 (MTP)** 模型。
這兩款模型在 GGUF 中內建了二次預測 draft heads，搭配最新版 `llama.cpp` 可在**完全不掛載外部小模型**的情況下啟動「自我推測解碼 (Self-Speculative Decoding)」，生成速度高達 **44 ~ 50 tokens/sec**，比一般 dense 27B 執行快上 4x - 5x！

### 🔥 推薦 A. GRM-2.6-Opus-Heretic-Abliterated-MTP-IQ4_XS (~14.3 GB)
* **特點**：融合極強的 GRM 推理邏輯與 Claude Opus 思考風格，且完全移除了安全審查限制（Abliterated），執行複雜 Agent 指令時最為穩定。
* **實測效能**：平均生成速度 **`49.12 tokens/sec`**，MTP 預測草案接受率高達 **`69.58%`**！
* **下載連結**：[GRM-2.6-Opus-Heretic-Abliterated-MTP-i1-GGUF (HuggingFace)](https://huggingface.co/mradermacher/GRM-2.6-Opus-Heretic-Abliterated-MTP-i1-GGUF)

### ⚡ 推薦 B. Qwopus3.6-27B-v2-MTP-IQ4_XS (~14.3 GB)
* **特點**：專為寫程式與複雜架構分析優化的 27B 推理型巨獸，思考深度極佳，是本地最強大代碼生產機器。
* **實測效能**：平均生成速度 **`44.14 tokens/sec`** (峰值可達 **`50.79 T/s`**)，MTP 預測草案接受率 **`58.40%`**！
* **下載連結**：[Qwopus3.6-27B-v2-MTP-GGUF (HuggingFace)](https://huggingface.co/Jackrong/Qwopus3.6-27B-v2-MTP-GGUF/)

*(新手科普：`IQ` 系列量化搭配 `i1` 矩陣技術，能在相同檔案大小下比傳統 `Q` 系列保留更多模型智商。檔案大小與 VRAM 之間務必保留 4~5GB 以上作為 Context 運算空間。)*

---

## 🚀 3. 一鍵啟動伺服器 (MTP 自我推測極速優化版)

本專案已將優化後的啟動批次檔 (.bat) 直接存於專案根目錄，您可以直接複製或修改使用。

> [!WARNING]
> **💡 批次檔語系相容性注意**：
> 舊版 batch 檔常因包含中文括號 `(` 與 `)` 導致 Windows CMD 解析錯誤閃退。本專案啟動檔已全面改為 **100% 純英文語法與括號**，徹底消除任何語系 Code Page 閃退問題。

### 🟢 A. GRM-Opus MTP 啟動檔 ([`start_server_nvidia.bat`](start_server_nvidia.bat))
適合搭配 `GRM-2.6-Opus-Heretic-MTP` 權重，完整啟用 P-core 核心綁定與推測解碼：
<details>
<summary><b>點此展開查看批次檔代碼與優化參數說明</b></summary>

```batch
@echo off
setlocal
title GRM-2.6-Opus-Heretic-Abliterated-MTP [RTX A4500 128K Max Performance]

set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\GRM-2.6-Opus-Heretic-Abliterated-MTP-IQ4_XS.gguf
set CTX_SIZE=131072
set PORT=8080

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
適合搭配 `Qwopus3.6-27B-v2-MTP` 權重，提供最優寫程式性能：
<details>
<summary><b>點此展開查看批次檔代碼</b></summary>

```batch
@echo off
setlocal
title Qwopus3.6-27B-v2-MTP [RTX A4500 128K Max Performance]

set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set MODEL=D:\MyProject\llama\Qwopus3.6-27B-v2-MTP-GGUF.gguf
set CTX_SIZE=131072
set PORT=8080

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
由於 `llama.cpp` 官方自 `b9455+` 起已正式停用 Windows/Linux 的 SYCL (Intel Arc GPU) binary 自動打包，為防範無 NVIDIA 顯示卡的使用者無法啟動，我們提供了一套專門針對**純 CPU 環境優化**的極速效能啟動檔。
適合任何標準筆記型電腦、辦公桌上型電腦或無 GPU 的伺服器環境：

```batch
@echo off
setlocal
title Llama.cpp CPU Server [Unified CPU Performance Tuning]

set LLAMA_EXE=D:\MyProject\llama\llama-server.exe
set PORT=8080
set CTX_SIZE=16384

:: --------------------------------------------------------------------
:: [Model Selection] Uncomment the one you want to run.
:: --------------------------------------------------------------------
:: Option A: High-Precision 7B CPU Baseline (Recommended IQ4_XS for balanced speed/quality)
set MODEL=D:\MyProject\llama\Qwopus3.6-7B-IQ4_XS.gguf

:: Option B: Extreme MoE Player Choice (Qwen3.6-35B-A3B-Cerebellum 12GB GGUF)
:: set MODEL=D:\MyProject\llama\Qwen3.6-35B-A3B-Cerebellum.gguf

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

#### 🛠️ CPU 極致優化解析：
* **`-ngl 0`**：強制關閉所有 GPU offload，將運算全數留置在實體 CPU 與系統記憶體中。
* **`-c 16384`**：預設設定為 16K 作為效能平衡點。**CPU 運作的核心本錢在於系統主記憶體 (RAM) 相比 GPU 顯存 (VRAM) 便宜且容量巨大**。在 CPU 模式下，您完全不需要像在 GPU 一樣斤斤計較 VRAM 溢位 (OOM) 的問題。
  * **💡 RAM 容量與開超大 Context 的對照指南**：
    * **16GB RAM**：足夠載入 7B 模型並將 `-c` 輕鬆推至 **32K** 上下文。
    * **32GB RAM**：不僅能以高精度模型 (如 `IQ4_XS` 等級) 運作，還可以**直接將 `-c` 上下文開滿 128K (131072)**，這在 20GB VRAM 的 GPU 上是極難實現的。
    * **64GB+ RAM**：可輕鬆運行 27B 或更大型模型，並無痛開啟 **128K 以上** 的超巨型上下文。
* **⚠️ Prefill 效能權衡提醒 (核心 Trade-off)**：雖然 32GB RAM 就能輕鬆吞下 128K 的超大上下文而不會崩潰，但**由於 CPU 記憶體頻寬遠不及 GPU 顯存，Prefill 階段 (提示詞預評估 / 載入大文字庫) 的速度會非常緩慢**。這意味著開滿 128K 時的首字生成延遲 (Time to First Token, TTFT) 會明顯增加。若您的應用場景（例如大型代碼庫重構、長文本合約分析）著重在「一次性讀入巨大上下文且不介意首字等待時間」，那麼把 CPU 版本的 `-c` 直接開滿 128K 將會是您最強大的智商武器。
* **`--threads 8` & `--threads-batch 12`**：計算線程強制派發至主機 CPU 的 8 顆實體 P-cores（Performance cores），避免背景計算任務被派發到 E-cores（Efficient cores）或超線程中而大幅拉高生成延遲。
* **⚠️ 避免在 CPU 啟用 MTP 投機解碼 (Speculative Decoding)**：雖然 `llama.cpp` 技術上支援在 CPU 模式下配置 MTP，但**實測結果證實，在純 CPU 模式下啟用 MTP 投機解碼並不能達到提速效果**。由於 CPU 記憶體頻寬限制，額外評估 Draft heads 的計算開銷與頻寬爭搶反而會拖慢解碼速率。因此 CPU 專用啟動檔中已完全移除投機解碼參數，維持純粹的標準解碼路徑。

---

### 🧠 極致玩家推薦：超強混合精度壓縮 MoE 模型 — Cerebellum
如果您是追求技術極限的玩家，在實體記憶體有限的消費級硬體下，我們強烈推薦您嘗試這款採用特殊敏感度引導壓縮處理的頂級 MoE 模型：
👉 [**deucebucket/Qwen3.6-35B-A3B-Cerebellum-GGUF (Hugging Face)**](https://huggingface.co/deucebucket/Qwen3.6-35B-A3B-Cerebellum-GGUF)

#### 🌟 核心特色解析：
* **極致瘦身 (12 GB GGUF)**：原版 Qwen3.6-35B-A3B 是一款搭載 **35B 總參數** 的頂級 MoE 混合模型。Cerebellum 透過**張量敏感度評估 (Sensitivity-guided mixed-precision)** 進行深度手術，套用了 400 個張量層級的精細 Override（將不敏感張量 demote 至 Q2_K，保留高敏感張量在 Q3_K_M 或 F32），最終將模型壓縮至僅 **12 GB (2.73 BPW)**。
* **🧠 前沿的 SSM + Attention + MoE 混合黑科技 (qwen35moe)**：根據 GGUF 元數據（Metadata）底層分析，此模型融合了多項頂級硬體最佳化結構設計：
  * **超省運算開銷**：總參數高達 35B，擁有 **256 個專家 (Experts)**，但每個 Token 僅啟用 **8 個專家 (Active Experts)**。這意味著**推理時活化參數僅約 3B (3B active parameters per token)**，在 CPU 上運作極為輕量省資源！
  * **SSM 線性時間複雜度優勢**：每 4 層進行一次 Full Attention（共 10 層），其餘 30 層皆採用線性注意力與 **SSM (State Space Model / Mamba 狀態空間模型)** 區塊（元數據標註 `ssm.state_size: 128`）。由於 SSM 對上下文長度的計算複雜度呈線性增長，相較傳統 Transformer 的二次方增長，能以極低的 CPU 負荷和記憶體開銷，無痛推展超長對話！
  * **原生支援 262K 超巨型上下文**：模型元數據原生配置 `context_length` 高達 **262,144 (262K)**，是處理超大型程式庫重構與海量文檔分析的終極武器。
* **不減智商的實測表現**：實測表明，Cerebellum v1 版在 ARC-Challenge 達到了 **94.8%**、HumanEval 達到了 **75.0%**，其視覺能力與原版 Q3_K_M (16 GB) 完全一致，甚至因為 imatrix 導引量化在 MoE 門控張量上帶來了正向的正規化效果，部分表現更優。
* **硬體友善度爆表**：僅需 12 GB 記憶體，因此不論是在 16GB VRAM 的消費級顯示卡（尚能留有空間供 Context 緩衝與 Vision Projector 載入），還是在 16GB/32GB RAM 的 CPU 主機上，都能以非常驚人的速度流暢玩轉！

*(若要啟用視覺多模態輸入，請至該 Repo 下載 `mmproj-F16.gguf` 投影器並透過 `--mmproj` 載入即可。)*

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

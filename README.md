# 🚀 Local-Agent-Workspace

> [!IMPORTANT]
> **個人立場聲明：** 本專案僅為個人技術研究分享，所有內容與參數調校均基於公開開源數據（Open Source Data）。專案內容不代表任何機關立場，亦不涉及任何公務機敏資料與軟體。

### 開發者本地 AI 部署與 Agent 橋接指南

這是一個旨在協助開發者在本地環境快速部署高效能大語言模型（LLM），並銜接自動化 Agent 工具（如 **Claude Code**）的實戰指南。

本專案的核心目標在於解決雲端 API 的隱私疑慮、頻繁的審查限制以及長文本處理成本。透過針對特定硬體配置的參數調校，實現流暢的本地輔助開發體驗。

> [!TIP]
> **測試硬體參考：** NVIDIA RTX A4500 (20GB VRAM) / 64GB RAM。
> **硬體適應性：** 只要具備 NVIDIA GPU 且 VRAM 充足（建議 12GB 以上，20GB 為完美甜蜜點），皆可參考本指南進行部署與參數調整。

-----

## 💎 部署本地環境的優勢

  * **🔒 物理級資料隔離：** 程式碼、專案架構與日誌數據完全留在本地，無需上傳至任何雲端節點。特別適合處理具備高度機敏性，或需進行數位鑑識、OSINT 封閉分析等不容許資料外流的專案。
  * **🧠 高上下文容量：** 透過優化的快取壓縮技術，在 20GB VRAM 的環境下依然可支援至 **64K~128K Context**，足以應付大規模 Repo 分析。
  * **🔓 任務連續性：** 使用特徵消融（Abliterated）或開發特化版模型，可避免 Agent 在執行特定腳本分析或封閉網路掃描時，因安全過濾機制而強行中斷。
  * **💰 成本效益：** 適合頻繁開發與自動化迭代需求，無需負擔雲端 API 昂貴的長文本 Token 費用。

-----

## 🛠️ 1. 運算引擎準備

我們提供兩種引擎選擇，請依據您的需求與熟悉度選擇其一：

| 引擎選擇 | 特色說明 | 推薦下載檔名 / 來源 |
| :--- | :--- | :--- |
| **🛡️ Llama.cpp (官方)**<br>*(強烈推薦)* | 更新最快，功能涵蓋最完整，穩定性最高。搭配最新 CUDA DLLs 已足以應付絕大多數開發場景。 | [Llama.cpp Releases](https://github.com/ggml-org/llama.cpp/releases)<br>(下載 `cudart-llama-bin-win-cu12.4-x64.zip`) |
| **🔥 TurboQuant**<br>*(極限壓榨備選)* | 針對 VRAM 佔用進行深度非官方優化，適合想要在極低 VRAM 下硬開超長上下文的極客玩家。 | [TurboQuant Releases](https://github.com/TheTom/llama-cpp-turboquant/releases)<br>(下載 `turboquant-plus...zip`) |

> **部署步驟：** 建立專屬資料夾（請自訂路徑，例如：`C:\llama.cpp`），並將解壓縮後的檔案放入其中。

-----

## 📦 2. 模型權重下載 (GGUF)

選擇模型時，除了看參數量（B），更要評估硬體 VRAM 的極限。以下推薦基於不同開發場景的模型選擇：

### 🌟 穩定首選 (程式碼開發與常規 Agent 自動化)
🔥 **[Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS](https://huggingface.co/DavidAU/Qwen3.6-27B-NEO-CODE-Di-IMatrix-MAX-GGUF/blob/main/Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS.gguf)** (約 15.4 GB)
> **強烈推薦：** 此版本（Dense 架構）專為開發與程式碼任務優化，處理 Agent 工具極度要求的 **JSON 格式輸出**具有極高的穩定性。搭配 IQ4_XS 量化，完美適配 20GB VRAM。在保留極高邏輯精度的同時，能留下約 4~5GB 的 VRAM 餘裕給長文本（Context）運算。**注意：此版本具備標準安全審查。**

### ⚠️ 實驗性質：頂規無審查版 (封閉環境分析、鑑識與 OSINT 腳本)
🧪 **[Qwen3.6-35B-A3B-Abliterix-EGA-abliterated.i1-IQ3_M](https://huggingface.co/mradermacher/Qwen3.6-35B-A3B-Abliterix-EGA-abliterated-i1-GGUF/blob/main/Qwen3.6-35B-A3B-Abliterix-EGA-abliterated.i1-IQ3_M.gguf)** (約 15.4 GB)
> [!WARNING]
> **未充分測試聲明：** 此為 35B MoE（混合專家）架構，尚未在自動化 Agent 連續呼叫工具的流程中進行長期穩定度測試。
> **推薦理由：** 使用了最先進的 **Abliteration（特徵消融）** 技術。若您的 Agent 需要頻繁分析具攻擊性的惡意代碼或滲透測試腳本，此模型能完美保留原廠邏輯能力並避免被安全機制中斷。受限於 20GB VRAM，請務必選擇 **`IQ3_M`** 或 **`IQ3_XS`** 版本。

-----

## 💡 科普：如何看懂模型後綴與量化參數？

初入本地 AI 部署的開發者，面對落落長的模型檔名（如 `...i1-IQ4_XS.gguf`）常感到困惑。以下是快速看懂這些參數的實戰指南：

### 1. 什麼是 GGUF？
GGUF 是一種專為 `llama.cpp` 設計的檔案格式。它的最大優勢在於**「異質運算（CPU+GPU 協同）」**。當您的 GPU VRAM 不夠塞下整個模型時，GGUF 允許將多出來的負擔轉移到系統 RAM 與 CPU 上。

### 2. 量化級別：Q 與 IQ 的差異
未壓縮的模型極大。為了放進消費級顯卡，我們必須降低精度（量化）。
* **Q 系列 (如 Q4_K_M)：** 傳統量化方式，數字代表位元數（4-bit）。
* **IQ 系列 (如 IQ4_XS, IQ3_M)：** 搭配 `i1` (Imatrix 重要性矩陣) 技術的新一代量化。它會去分析神經網路中「哪些參數最重要」，在壓縮時保留重要參數的精度。**結論：同等檔案大小下，IQ 系列通常比傳統 Q 系列更聰明、損失更少。**
* **尺寸後綴：** `S` (Small), `M` (Medium), `L` (Large), `XS` (Extra Small)。主要反映在檔案大小的微調。

### 3. 解除審查：Uncensored vs. Abliterated
* **Uncensored (無審查)：** 通常是拿沒有過濾的資料集對模型重新進行微調。缺點是微調過程有時會破壞模型原有的邏輯推理能力（變笨）。
* **Abliterated (特徵消融)：** 不重新訓練，而是直接在權重矩陣中，利用數學向量運算「抹除」掉掌管「拒絕回答（Refusal）」的特徵方向。**能完美保留原廠模型的高智商，同時解除護欄。**

> [!TIP]
> **VRAM 精算守則：** 您的 VRAM (如 20GB) = 模型權重大小 (如 15.4GB) + Context / KV Cache 快取空間。千萬不要把模型大小抓得剛剛好等於 VRAM，必須保留至少 4~5GB 給上下文運算，否則速度會面臨斷崖式下跌。

-----

## 🚀 3. 一鍵啟動伺服器 (A4500 最佳化版)

以下提供兩種引擎的啟動腳本，請依據您安裝的引擎選擇對應的程式碼，存成 `start_server.bat`，並與您的執行檔放在同一目錄下執行。

> [!CAUTION]
> **執行前請務必修改路徑：**
> 請將腳本中的 `<您的_引擎資料夾路徑>` 與 `<您的模型存放路徑>` 替換為您電腦中實際的位置與檔名！

### 選項 A：使用 Llama.cpp 官方引擎 (首選推薦)

此腳本已針對 RTX A4500 (20GB VRAM) 進行深度最佳化，無論您選擇上述哪一款模型皆適用。

```batch
@echo off
chcp 65001 > nul
title Llama.cpp Server - 本地代理引擎

:: 1. 請將此處修改為您存放 llama-server.exe 的實際資料夾路徑
cd /d <您的_引擎資料夾路徑>

echo ========================================================
echo 啟動 Llama.cpp 本地伺服器...
echo 目標硬體: NVIDIA RTX A4500 (20GB VRAM) / 64GB RAM
echo ========================================================

:: 參數解析：
:: -c 65536         : 設定 64K 上下文，適合 Agent 讀取專案
:: -b / -ub         : 加大批次處理量，大幅加速 Claude Code 首次讀取程式碼的速度
:: --cache-type-k/v : 啟用 8-bit KV 快取，節省近半 VRAM，防止 OOM 溢位降速
:: --no-mmap        : 確保模型完整載入記憶體，避免 Windows I/O 卡頓

:: 2. 請將 -m 後方的路徑與檔名修改為您實際下載的模型位置
llama-server.exe ^
  -m "<您的模型存放路徑>\Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS.gguf" ^
  -ngl 99 ^
  -c 65536 ^
  --port 18080 ^
  --parallel 1 ^
  -b 2048 ^
  -ub 512 ^
  --cache-type-k q8_0 ^
  --cache-type-v q8_0 ^
  --flash-attn on ^
  --no-mmap ^
  --jinja 

pause
```

### 選項 B：使用 TurboQuant 引擎 (備選極限版)

若您選擇使用 TurboQuant，可利用其特有的 `turbo3` 快取進一步壓縮 VRAM。

```batch
@echo off
chcp 65001 > nul
title TurboQuant Server - 本地代理引擎

cd /d <您的_引擎資料夾路徑>

echo ========================================================
echo 啟動 TurboQuant 本地伺服器 (極限 VRAM 壓榨模式)...
echo ========================================================

llama-server.exe ^
  -m "<您的模型存放路徑>\Qwen3.6-27B-NEO-CODE-2T-OT-IQ4_XS.gguf" ^
  -c 65536 ^
  -ngl 99 ^
  --port 18080 ^
  --parallel 1 ^
  --batch-size 2048 ^
  --ubatch-size 512 ^
  --cache-type-k turbo3 ^
  --cache-type-v turbo3 ^
  --flash-attn on ^
  --no-mmap ^
  --mlock ^
  --jinja 
pause
```

-----

## 🤖 4. 橋接自動化代理 (Claude Code)

請在您的**專案工作目錄**中建立 `claude-local.bat`。

> [!CAUTION]
> ### 🚨 安全警告：關於權限跳過模式
> 預設腳本包含 `--dangerously-skip-permissions` 參數，這將允許 Agent 在**不經詢問**的情況下直接執行終端機指令（如修改檔案、執行刪除指令）。
>
>   * **僅在受信任且已建立版本控制（Git）的專案目錄執行。**
>   * 若您在進行安全性未知的腳本分析，強烈建議移除此參數，以手動審核 Agent 的每一項操作。

```batch
@echo off
chcp 65001 > nul
title Claude Code - 本地橋接模式

echo ========================================================
echo ⚠️  警告：目前正在以「全自動授權」模式執行
echo 此模式下 Agent 執行任何指令都「不會」徵求您的同意。
echo 請確保您位於受信任的專案目錄中！
echo ========================================================

:: 將代理工具的通訊端點指向本地伺服器
set ANTHROPIC_BASE_URL=[http://127.0.0.1:18080](http://127.0.0.1:18080)
set ANTHROPIC_AUTH_TOKEN=local-qwen-token

:: 啟動助理
call claude --dangerously-skip-permissions

pause
```

> [!NOTE]
> 首次分析專案時，模型需要進行資料預讀（Prompt Prefill），此時得益於我們的批次參數優化，GPU 負載會瞬間拉滿以快速處理龐大上下文，此屬正常高效運算現象。完成後互動將恢復即時。

-----

## 📮 聯繫與交流

如果您在部署過程中有任何技術問題或參數優化的建議，歡迎透過以下管道聯繫：

<p align="left">
  <a href="mailto:lotifv@gmail.com">
    <img src="https://img.shields.io/badge/Email-lotifv@gmail.com-D14836?style=flat-square&logo=gmail&logoColor=white" alt="Email">
  </a>
  <a href="https://www.linkedin.com/in/chiakai-chang-htciu/">
    <img src="https://img.shields.io/badge/LinkedIn-Chang,%20Chia--Kai-0077B5?style=flat-square&logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</p>

**May the Local AI be with you.**

# 🚀 Local-Agent-Workspace

### 開發者本地 AI 部署與 Agent 橋接指南

這是一個旨在協助開發者在本地環境快速部署高效能大語言模型（LLM），並銜接自動化 Agent 工具（如 **Claude Code**）的實戰指南。

本專案的核心目標在於解決雲端 API 的隱私疑慮、頻繁的審查限制以及長文本處理成本。透過針對特定硬體配置的參數調校，實現流暢的本地輔助開發體驗。

> [\!TIP]
> **測試硬體參考：** NVIDIA RTX A4500 (20GB VRAM) / 64GB RAM。
> **硬體適應性：** 只要具備 NVIDIA GPU 且 VRAM 充足（建議 12GB 以上），皆可參考本指南進行部署與參數調整。

-----

## 💎 部署本地環境的優勢

  * **🔒 資料隱私：** 程式碼與日誌數據完全留在本地，適合處理具敏感性的專案。
  * **🧠 高上下文容量：** 透過優化後的快取技術，可支援至 **128K Context**，足以應付大規模 Repo 分析。
  * **🔓 任務連續性：** 使用無審查（Uncensored）特化版模型，可避免 Agent 在執行特定腳本分析時因安全過濾而中斷。
  * **💰 成本效益：** 適合頻繁開發需求，無需負擔雲端 API 的 Token 費用。

-----

## 🛠️ 1. 運算引擎準備

請建立專屬資料夾（建議 `D:\local-ai`），並依據需求下載運算核心：

| 引擎版本 | 特色說明 | 推薦下載檔名 |
| :--- | :--- | :--- |
| **🔥 TurboQuant** | 針對 VRAM 佔用進行深度優化，適合超長上下文。 | [Download](https://github.com/TheTom/llama-cpp-turboquant/releases) (`turboquant-plus...zip`) |
| **🛡️ Llama.cpp (官方)** | 更新最快，功能涵蓋最完整，社群支援度最高。 | [Download](https://github.com/ggml-org/llama.cpp/releases) (`cudart-llama-bin...zip`) |

-----

## 🔧 2. Windows 依賴補丁 (OpenSSL)

若啟動伺服器時提示缺失 `libssl...` 系列 DLL 檔案，請依序執行：

1.  **安裝組件：** 以管理員權限開啟 PowerShell，執行 `winget install ShiningLight.OpenSSL.Light`
2.  **提取檔案：** 至 `C:\Program Files\OpenSSL-Win64\bin` 複製 **`libssl-4-x64.dll`** 與 **`libcrypto-4-x64.dll`**。
3.  **相容補丁：** 將檔案更名為 **`libssl-3-x64.dll`** 與 **`libcrypto-3-x64.dll`** 並放入引擎資料夾。

-----

## 📦 3. 模型權重下載 (GGUF)

本指南基於以下模型測試，其在指令遵循與邏輯推理上具有優異的穩定性：

👉 **[Qwen3.6-27B-Uncensored-IQ3\_M](https://huggingface.co/HauhauCS/Qwen3.6-27B-Uncensored-HauhauCS-Aggressive/blob/main/Qwen3.6-27B-Uncensored-HauhauCS-Aggressive-IQ3_M.gguf)** (約 12.6GB)

> [\!IMPORTANT]
> 實測建議選用 **Dense (稠密)** 架構模型（如 27B），在處理 Agent 格式化輸出（JSON/Code）任務時通常比 MoE 架構更穩健。

### 💡 持續追蹤與更新 (Upstream & Community)

開源模型與量化技術迭代極快，建議追蹤以下來源以獲取最新的模型優化成果：

  * **[Unsloth AI](https://huggingface.co/unsloth)**：提供極速且優化的量化版本，通常在模型發佈數小時內即會跟進。
  * **[HauhauCS](https://huggingface.co/HauhauCS)**：專注於高品質的「無審查（Uncensored）」版本與經過 I-Matrix 優化的 GGUF 權重。

-----

## 🚀 4. 一鍵啟動伺服器

將本 Repo 提供的 `.bat` 檔放入引擎資料夾中，依據下載的版本雙擊執行：

  * **執行 `start_27B_turbo.bat`：** 開啟 `turbo3` 快取壓縮，最大化利用 GPU 空間。
  * **執行 `start_27B_vanilla.bat`：** 開啟專家層 CPU Offload 分流與碎片整理，確保 128K 運作穩定。

-----

## 🤖 5. 橋接自動化代理 (Claude Code)

在目標專案目錄中執行本專案提供的 **`claude-local.bat`**。該腳本會將 API 請求重新導向至本地伺服器。

> [\!CAUTION]
>
> ### 🚨 安全警告：關於權限跳過模式
>
> 預設腳本包含 `--dangerously-skip-permissions` 參數，這將允許 Agent 在**不經詢問**的情況下直接執行終端機指令（如修改檔案、執行刪除指令）。
>
>   * **僅在受信任且已建立版本控制（Git）的專案目錄執行。**
>   * 若您在不熟悉的環境開發，建議移除此參數以手動審核 Agent 的每一項操作。

```powershell
# 設定環境變數並啟動
set ANTHROPIC_BASE_URL=http://127.0.0.1:18080
call claude --dangerously-skip-permissions
```

> [\!NOTE]
> 首次分析專案時，模型需要進行資料預讀（Prompt Prefill），GPU 使用率會顯著上升並持續 1-3 分鐘，此屬正常運算現象。完成後互動將恢復即時。

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

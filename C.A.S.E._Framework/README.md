# 📂 C.A.S.E. 框架

## Constitutional Agent State Engine
### 讓 AI 像專業調查團隊一樣，嚴守紀律、有跡可循的協作標準作業架構

> 一個卷宗就是一個任務。一份指引就是一條法律。所有進度，肉眼可見。
> 雲端 AI 負責思考，本地 AI 負責苦勞——讓 Token 花在刀口上。

---

## 一分鐘看懂架構

```mermaid
graph TD
    H["👤 人類 / 制憲者<br/>定義最終目標與最高原則"]
    C["🤖 宏觀層 AI 大腦<br/>（雲端旗艦模型 或 本地高參數量模型）"]
    TQ[("📁 工作區 / Task Queue")]
    T1["📂 卷宗 Task_01"]
    T2["📂 卷宗 Task_02"]
    TN["📂 ..."]
    LA["🤖 微觀層 AI 手腳<br/>（本地開源小模型 或 輕量雲端模型）"]
    AGG["🔍 全局聚合審查"]
    DONE["✅ 全案結束"]

    H -->|"① 憲法：核心目標與禁止事項"| C
    C -->|"② 宏觀：拆任務包 + 訂全案驗收標準"| TQ
    TQ --> T1
    TQ --> T2
    TQ --> TN
    T1 -->|"③ 微觀：認領與細部規劃，照指引執行"| LA
    LA -->|"寫入成果 + 更新狀態"| T1
    T2 --> LA
    T1 -->|"④ 單點驗收通過"| AGG
    T2 --> AGG
    AGG -->|"達到全案標準"| DONE
    AGG -->|"⑥ 宏觀：缺少拼圖，開新階段"| C
    LA -->|"⑤ 微觀：發現缺口，直接回饋新任務"| TQ
```

---

## 💡 C.A.S.E. 的核心理念與痛點解決

### 🤖 面臨的痛點
* **AI 記憶遺忘**：對話歷史過長時，AI 會忘記最初的開發限制或改壞程式碼。
* **Token 費用昂貴**：讓旗艦雲端模型重複進行程式碼掃描、跑測試、改小 Bug 等，消耗大筆 Token 與費用。
* **AI 進度謊報**：AI 聲稱任務完成，但實際檔案未寫入，或程式無法運行（AI 幻覺與謊報）。
* **安全與隱私風險**：敏感代碼、資料庫密鑰或專案機密直接上傳雲端 API，有洩露隱私之虞。

### 🛡️ 解決方案：實體檔案管束 (Physical State Engine)
C.A.S.E. 將大任務拆解成多個獨立的「任務資料夾」，以實體檔案強制規範 AI 的工作路徑：
1. **工作指引 (`recipe.md`)**：規定輸入輸出檔案、驗收 checklist，AI 僅能在限定檔案內讀寫。
2. **角色設定 (`role.md`)**：提供特定的系統 Prompt 載入。
3. **微觀復盤與版控**：認領任務後先作細部規劃（如 `planning.md`），隨後謹慎執行， Checker 驗收後由 Harness 自動進行 git commit & push。
4. **運行控制座 (Harness)**：在執行期監控並壓縮 Context 以節省 VRAM/Token。在任務完成時檢查 `action_log.jsonl`，確保 AI 確實執行了儲存與測試指令，不准說謊。

---

## 💎 C.A.S.E. 為您的專案帶來什麼好處？

* **🌐 靈活部署，兼容全場景**：完美兼容全雲端（Cloud VM）、全本地（離線開發）與雲地混合架構，任何模型皆可隨時接入。
* **💰 靈活成本配比**：將高耗能的苦力活（代碼編修、單元測試）分流至本地端免費或雲端輕量模型，最大化性價比。
* **🔒 安全與沙箱隔離**：程式碼可留在本機或在虛擬沙箱（如透過 `trycua` 工具）中執行，與敏感環境物理隔離。
* **🧠 跨平台「永久記憶」**：所有進度都在實體檔案（status.txt）中，即便 AI 斷線、或中途換別的 AI 軟體，讀了檔案就能立刻接下去做。
* **🛡️ 拒絕 AI 裝忙說謊**：Harness 自動翻閱實體日誌，若發現 AI 沒寫入檔案、沒跑過測試就謊報成功，會直接退件並還原代碼。

---

## 🚀 3 分鐘快速上手（將 C.A.S.E 規範一鍵植入任何 AI 專案）

只需簡單三步，就能將本專案的 C.A.S.E 規範無縫植入您目前的任何 AI 專案中：

<details>
<summary><b>1️⃣ 第一步：一鍵下載 C.A.S.E. Agent 規則手冊 (CASE_framework_for_agents.md)</b></summary>

請在您的專案根目錄下，開啟終端機並執行以下指令下載唯讀規則檔：
* **💻 Linux / macOS / Git Bash (cURL)**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md -o CASE_framework_for_agents.md
  ```
* **💻 Windows (PowerShell)**:
  ```powershell
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md" -OutFile "CASE_framework_for_agents.md"
  ```
> 💡 *說明：本指令僅會下載一個唯讀的 `.md` 規則文件，完全無任何代碼執行，絕無主機安全疑慮，亦不會覆蓋您現有的任何開發檔案。*
</details>

<details>
<summary><b>2️⃣ 第二步：給您的 AI Agent 貼上引導 Prompt</b></summary>

啟動您的 AI 輔助軟體（如 `Claude Code`、`Codex`、`Antigravity CLI`、`Pi`，或是 `Cursor` 等，若是 Cursor 則可使用 `@` 參照此檔案），貼上以下 Prompt 給它：

> 「請閱讀我專案中的 [CASE_framework_for_agents.md](CASE_framework_for_agents.md) 文件。閱讀後，請分析我目前的專案結構，規劃如何以最合適的方式為本專案建立 C.A.S.E 物理目錄結構（包含 Constitution、Roadmap、Task_Queue 任務資料夾），並將此執行期規則妥善整合寫入您的長效記憶配置中（例如 `CLAUDE.md`、`.cursorrules`、`gemini.md` 或 `memory.md` 等對應位置）。在建立目錄與寫入配置前，請先向我報告您的規劃並取得我的同意。」
</details>

<details>
<summary><b>3️⃣ 第三步：檢閱並同意 AI 的自動配置</b></summary>

AI Agent 讀取 Prompt 後，將會**自己動手**完成：
1. 分析您目前的程式語言與專案結構。
2. 自動建立 `00_Constitution/`、`01_Roadmap/` 與 `02_Task_Queue/` 等實體目錄。
3. 自動將 C.A.S.E. 執行期規則妥善整合寫入到您的本機長效記憶配置中。

您只需確認同意，AI 就能幫您全部設定妥當！完全不需要您手動搬移任何檔案，安全、乾淨且優雅！
</details>

---

## 四大支柱

| # | 支柱 | 意思 |
|---|------|------|
| 1 | **智力分層** | 聰明的雲端 AI 做大計畫，安全的本地 AI 做苦力 |
| 2 | **萬物皆卷宗** | 所有任務、進度、記憶，都是您電腦裡肉眼可見的真實資料夾與文字檔 |
| 3 | **雙軌核實** | 執行者做完，驗收者審查，Git 版控保底，不怕 AI 發瘋或幻覺 |
| 4 | **雙層回饋** | 本地 AI 執行中發現缺口→直接補任務（微觀）；全局審查未達標→雲端重規劃（宏觀） |

---

## 快速導覽

| 您是誰 | 請前往 |
|--------|--------|
| 👤 **人類（開發者 / 長官 / 協作者）** | [📖 框架理念與設計哲學](docs/for_humans.md) |
| 🤖 **AI Agent（Coding Agent / 自動化工具）** | [⚙️ System Protocols & I/O Rules](docs/for_agents.md) |
| 🛡️ **系統開發者 / 協調器設計師** | [⚙️ Harness Engineering 規範與優化設計](docs/harness_engineering.md) |
| 📦 **一般 AI 專案使用者 / 快速套件** | [⚙️ Portable C.A.S.E. 攜帶式套件與自動化設計](docs/portable_case_harness.md) |
| ❓ **名詞看不懂？** | [📚 C.A.S.E. 名詞解釋字典](docs/glossary.md) |

---

## 與 Local-Agent-Workspace 生態系的關係

C.A.S.E. 框架是「為什麼要這樣建構本地 AI」的**哲學基礎**，解釋了生態系三層架構背後的設計邏輯：

```
[ 您的目標 (憲法) ]
        ↓
[ 雲端前沿 AI 規劃 (宏觀層) ]
        ↓
[ Local-Agent-Workspace → Pi Agent → OmniHeal (微觀執行層) ]
```

---

## 🙏 參考先驅與開源致敬 (Prior Art & Acknowledgements)

> **💡 開發歷程與觀念驗證說明：**
> 本專案的 **C.A.S.E. 框架** 與 **Harness 控制座** 設計理念，最初源於本地開發 AI Agent 的實戰過程，是在解決 AI 容易遺忘指令、幻覺謊報進度、重複除錯陷入「鬼打牆」，以及最讓開發者痛切的雲端 API「Quota (額度) 與 Token 費用焦慮」等實務痛點時，**獨立摸索、設計並成功實踐出來的成果**。
>
> 隨後，在瀏覽技術社群時，驚喜地發現 **IBM Developer Advocate Tejas Kumar** 於 **AI Engineer Europe 2026** 發表之經典專題演講中，也提出了極為相似的 Harness 控制座思維！這極大地驗證了本地實踐方向的正確性。因此，後續迅速參考並整合了 IBM 的大廠工程規範，將其精髓納入本專案的文檔中。在此向同樣獨立推動此工程觀念的先驅者致以最誠摯的敬意：

* **📺 經典演講影片**：[Harnesses in AI: A Deep Dive — Tejas Kumar, IBM (YouTube)](https://youtu.be/C_GG5g38vLU?si=NVt8LgZaIRPOO6-Z)
* **💻 官方開源示範**：[TejasQ/basically-ai-harness (GitHub)](https://github.com/TejasQ/basically-ai-harness)
* **🐦 講者社群連結**：[@TejasKumar_ (X/Twitter)](https://x.com/TejasKumar_) | [@TejasQ (GitHub)](https://github.com/TejasQ)

強烈推薦所有使用本生態系的開發者觀看該演講，這將能讓您雙重印證「不該過度依賴寫死 Prompt，而應透過 Harness 外部程式碼與規則來管束黑盒子模型」的控制座工程核心思維。

---

## 設計脈絡（起心動念）

| 文件 | 說明 |
|------|------|
| [📋 會議記錄（精煉版）](docs/context/2026-05-21-meeting-minutes.md) | 八輪討論的重點摘要，可讀性高 |
| [📄 原始對話記錄](docs/context/2026-05-21-雲地混合開發架構理念討論.md) | 完整 Gemini 對話原文（含 UI 噪音） |

回到主專案：[← Local-Agent-Workspace](../README.md)

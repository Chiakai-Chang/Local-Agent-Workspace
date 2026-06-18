# 📂 C.A.S.E. 框架

## Constitutional Agent State Engine
### 讓 AI 像專業調查團隊一樣，嚴守紀律、有跡可循的協作標準作業架構

> 一個卷宗就是一個任務。一份指引就是一條法律。所有進度，肉眼可見。
> 角色職責解耦分工——讓 Token 花在刀口上。

---

## 一分鐘看懂架構 (C.A.S.E. 2.0)

```mermaid
graph TD
    H["👤 人類 / 制憲者<br/>定義憲法與最終目標"]
    C["🤖 宏觀規劃角色 (分析/設計)<br/>分析任務與定義 Roadmap"]
    TQ[("📁 任務佇列 Task Queue")]
    T1["📂 任務卷宗 Task_01<br/>(status.txt / planning.md)"]
    
    %% 狀態引擎（純文字檔案 + 可選腳本）
    CTRL["🛠️ 協定狀態引擎<br/>(status.txt / 可選腳本輔助)"]
    
    LA["🤖 微觀執行角色 (認領/執行)<br/>按 recipe 執行並測試"]
    CH["🛡️ Checker 驗收者<br/>(審查 output.md)"]
    
    %% 安全防禦與掛起
    SEC{"🔍 安全防禦 (Git Diff)"}
    REVERT["🛡️ 安全回滾 (git restore)<br/>任務掛起 (ESCALATED)"]
    
    %% 記憶體
    HOT[("🧠 熱學習 learnings.md<br/>(<40行)")]
    COLD[("🗄️ 冷記憶 archive_learnings.md")]
    
    DONE["✅ 結案 DONE / Git Commit"]
 
    %% 流程線
    H -->|"① 定義憲法/核心目標"| C
    C -->|"② 宏觀規劃生成任務"| TQ
    TQ --> T1
    
    %% Worker 執行與微觀回饋
    T1 -->|"③ 認領: status→IN_PROGRESS"| CTRL
    CTRL -->|"④ 產生 role/planning"| LA
    
    LA -.->|"★ ⑤ 微觀反饋 (create_subtask)<br/>發現前提缺口直接注入新任務"| TQ
    LA -->|"⑥ Prerequisite 缺失掛起 (ESCALATED)"| REVERT
    
    LA -->|"⑤ 提交: status→REVIEW"| CTRL
    CTRL -->|"⑥ Git Commit (可選)"| CH
    
    %% Checker 與安全
    CH -->|"⑦ 核實: 驗收 DoD"| SEC
    SEC -->|"有毒寫入 (修改唯讀目錄)"| REVERT
    SEC -->|"通過安全審查"| HOT
    
    %% 記憶整理與結案
    HOT -->|"⑧ 超限 40 行自動整理"| COLD
    HOT -->|"⑨ 標記 DONE"| DONE
```

---

## 💡 C.A.S.E. 的核心理念與痛點解決

C.A.S.E. 是一套**以檔案驅動的通用任務執行與管束協議**。不論是**程式開發、情資巡邏（如賭博網站蒐報）、論文寫作、簡報製作，抑或是複雜的劇情解讀與數據分析**，只要任務能被拆解為文件、檔案與檢驗步驟，皆能無痛套用。

### 🤖 面臨的痛點
* **AI 記憶遺忘**：對話歷史過長時，AI 會忘記最初的工作限制，或偏離預設的輸出格式（如簡報大綱、情資表格、學術格式）。
* **Token 費用昂貴**：讓旗艦雲端模型重複進行資料掃描、跑測試、反覆檢索與微調等，消耗大筆 Token 費用。
* **AI 進度與事實謊報**：AI 聲稱「任務已搞定！」，但實際檔案未寫入，或引用的文獻與巡邏情資網址根本是 AI 幻覺（謊報與幻覺）。
* **安全與隱私風險**：敏感代碼、商業情資、專利想法或未公開數據直接上傳雲端 API，有洩露隱私之虞。

### 🛡️ 解決方案：實體檔案管束 (Physical State Engine)
C.A.S.E. 將大任務拆解成多個獨立的「任務資料夾」，以實體檔案強制規範 AI 的工作路徑：
1. **工作指引 (`recipe.md`)**：規定輸入輸出檔案、驗收 checklist，AI 僅能在限定檔案內讀寫。
2. **角色設定 (`role.md`)**：提供特定的系統 Prompt 載入。
3. **微觀復盤與版控**：認領任務後先作細部規劃（如 `planning.md`），隨後謹慎執行， Checker 驗收後推薦進行 git commit 存檔。

---

## 🌟 C.A.S.E. 2.0 重大架構演進與技術理念

為了解決實務開發中的邊界安全、Context 爆滿以及不同推理能力模型（如較小參數規模模型）的適應性，框架近期引入了以下核心優化：

### 1. 🧠 冷熱學習記憶分層 (Memory Tiering - SkillOpt)
* **痛點**：AI 的反思學習日記 (`learnings.md`) 會隨著開發愈寫愈長，導致後續任務的 Context Window 爆滿、Token 成本飆升。
* **解法**：實施冷熱分層。熱記憶 (`learnings.md`) 限制在 **40 行（約 15 條記錄）**以內以保持敏捷；超出部分在結案時封存至冷記憶庫 (`archive_learnings.md`) 中。

### 2. 🛡️ 防毒害與防寫安全防線 (Git-Backed Write Defense)
* **痛點**：純文字引導無法真正阻止 AI 發瘋或受到外部代碼 Prompt Injection 攻擊，惡意篡改憲法 (`00_Constitution/`) 或 Roadmap。
* **解法**：推薦結合 Git 版控作為保底機制。在驗收階段（無論人工或自動化），透過 `git diff` 檢測唯讀目錄是否被篡改。若發現異常，可使用 `git restore` 回滾並將任務設為 `ESCALATED` 阻斷毒害擴散。此流程可由人工操作或 CI/CD Pipeline 執行。

### 3. 📉 弱推理模型降級適應 (Weak Model Adaptation)
* **痛點**：部分推理能力較弱的模型（如輕量化開源模型）對高密度的 I-Lang 壓縮語法（如 `[T]`, `[A]`, `[V]`）和箭頭運算子理解力不足，易卡在格式錯誤死循環中。
* **解法**：放寬為**軟性降級規則**。弱模型若理解困難，可自動 fallback 使用結構化自然語言編寫 `planning.md`，在大模型與弱模型間取得最佳性價比。

---

## 💎 C.A.S.E. 為您的專案帶來什麼好處？

* **🌐 靈活部署，兼容全場景**：完美兼容全雲端（Cloud VM）、全本地（離線開發）與雲地混合架構，任何模型皆可隨時接入。
* **💰 靈活成本配比**：將高耗能的苦力活（代碼編修、單元測試）分流至本地端免費或雲端輕量模型，最大化性價比。
* **🔒 安全與沙箱隔離**：程式碼可留在本機或在虛擬沙箱（如透過 `trycua` 工具）中執行，與敏感環境物理隔離。
* **🧠 跨平台「永久記憶」**：所有進度都在實體檔案（status.txt）中，即便 AI 斷線、或中途換別的 AI 軟體，讀了檔案就能立刻接下去做。
* **🛡️ 拒絕 AI 裝忙說謊**：Harness 自動翻閱實體日誌，若發現 AI 沒寫入檔案、沒跑過測試就謊報成功，會直接退件並還原代碼。

---

## 🚀 3 分鐘快速上手（將 C.A.S.E. 協定無痛植入任何專案）

> 🔒 **隨插即用，無痛外掛 (Non-Destructive Outer-Harness)**
> C.A.S.E. 是一套**純文字聲明式協定**。它只在專案目錄外掛獨立的管理資料夾，**絕對不會搬移或破壞您現有的任何原始碼**。您可以完全不執行任何腳本程式碼，僅靠文字檔案和 AI 協定約束來運行。

---

### 💡 快速引入方式（純文字聲明式配置，零代碼依賴，相容性最高）
本專案為純文字聲明式協定，無須在終端機執行任何外來腳本：

1. **一鍵下載 C.A.S.E. Agent 協定手冊 (CASE_framework_for_agents.md)**：
   * **💻 Linux / macOS (cURL)**:
     ```bash
     curl -fsSL https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md -o CASE_framework_for_agents.md
     ```
   * **💻 Windows (PowerShell)**:
     ```powershell
     Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Chiakai-Chang/Local-Agent-Workspace/main/C.A.S.E._Framework/docs/for_agents.md" -OutFile "CASE_framework_for_agents.md"
     ```
2. **給您的 AI Agent 貼上極簡引導 Prompt**：
   > 「本專案採用 C.A.S.E. 框架，請閱讀並遵循專案中的 `CASE_framework_for_agents.md` 進行開發與任務管理。」
3. **完成配置**：
   AI 讀取後將自行建立物理目錄結構，後續即可遵循 C.A.S.E. 規則進行「認領任務 $\rightarrow$ 撰寫規劃 $\rightarrow$ 修改測試 $\rightarrow$ Git 版控 $\rightarrow$ 結案驗收」的純文本狀態機流轉。

---

### 🤝 雲地協同實例：如何具體啟動、執行與交接？

1. **雲端規劃大腦 (Cloud Strategic Planning)**：
   * 使用具備檔案系統寫入權限的雲端 AI Agent（如 `Claude Code`、`Windsurf`/`Cursor` 雲端模式、`Codex`、`Agy` 等），給予極簡指令：
     > 「本專案採用 C.A.S.E. 框架。請閱讀專案目標，在 `01_Roadmap/roadmap.md` 中規劃開發階段，並在 `02_Task_Queue/Task_001_xxx/` 下建立任務，填寫 `recipe.md`、`role.md`。完成後將 `status.txt` 設為 `PENDING`。」
   * 雲端 AI 將會拆解好任務並在本地生成資料夾，設定 `status.txt` 為 `PENDING`。

2. **地端手腳執行 (Local Tactical Execution)**：
   * 使用本機運行的 AI Agent（如連接本機 Ollama 模型的 `Antigravity CLI` 或 `Pi Code Agent`），給予指令：
     > 「請認領 `02_Task_Queue/Task_001_xxx/` 任務。將其 `status.txt` 改為 `IN_PROGRESS`，並依據 `recipe.md` 規範與 `role.md` 的角色開始執行開發。」
   * 本地 AI 會自動將狀態改為 `IN_PROGRESS`，在本機修改代碼、運行單元測試，通過後將狀態改為 `REVIEW`。

3. **自動化檢驗與人類極簡驗收 (AI Self-Review & Minimal Human Handoff)**：
   * **AI 自動復盤與 3 次自癒限制**：AI 在回報人類前，會先自動逐項檢驗 `recipe.md` 的 DoD 並跑測試。若有任何問題，AI 會在後台默默修復（最大連續限制 3 次以防止死循環與 token 浪費），3 次自癒失敗將自動掛起為 `ESCALATED` 狀態。
   * **熱記憶容量分片遷移**：熱記憶 `learnings.md` 設有 **40 行的硬性上限**。結案 `DONE` 時超限將自動把最舊的 5 條記錄追加至 `archive_learnings.md`（冷記憶），保持注意力敏捷。
   * **人類自然語言審查**：當 AI 宣告 100% 完成後，人類只需檢閱結果，直接在大白話對話中向 AI 表達「通過」或「修改此處」。AI 接收後會**自動**變更 `status.txt` 並 commit/push 或轉回開發狀態，人類無須手動編輯狀態檔。

---

## 四大支柱

| # | 支柱 | 意思 |
|---|------|------|
| 1 | **角色分層** | 宏觀規劃層做大計畫與任務拆分，微觀執行層專注按步執行（可用同一模型或不同模型） |
| 2 | **萬物皆卷宗** | 所有任務、進度、記憶，都是您電腦裡肉眼可見的真實資料夾與文字檔 |
| 3 | **雙軌核實** | 執行者做完，驗收者審查，Git 版控保底，不怕 AI 發瘋或幻覺 |
| 4 | **雙層回饋** | 執行中發現前置缺口→直接補任務（微觀）；全局審查未達標→重新規劃調整（宏觀） |

---

## 快速導覽

| 您是誰 | 請前往 |
|--------|--------|
| 👤 **人類（開發者 / 長官 / 協作者）** | [📖 框架理念與設計哲學](docs/for_humans.md) |
| 🌐 **想了解雲與地如何高效協作？** | [🤝 雲地雙軌協作實踐指南](docs/for_humans.md#25-雲地協同最佳實踐如何以高-cp-值進行雙軌合作) |
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
[ 宏觀規劃角色 (Strategic Planner) ]
        ↓
[ 微觀執行與驗收 (Tactical Executor & Checker) ]
```

*(註：本架構不限定任何模型參數大小或部署拓撲。這兩層角色可以完全由本機同一個模型（例如本機單一 27B/32B 模型）跑完全流程；亦能透過「雲地混合」由雲端大模型規劃宏觀 Roadmap，再由本地端模型（如 Local-Agent-Workspace + Pi Agent + OmniHeal 生態系）專注於微觀執行與安全驗收，在資料隱私與性價比之間取得最佳平衡。)*

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

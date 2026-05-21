# 會議記錄：C.A.S.E. 框架起心動念討論

**日期：** 2026-05-21
**形式：** 與 Gemini（Google）模擬 MECE 專家群多輪架構討論
**發起人：** 張家愷（CK）
**原始脈絡：** [完整 Gemini 對話原文](2026-05-21-雲地混合開發架構理念討論.md)（含 UI 噪音，建議讀本文取代）

---

## 起點：一個比喻引發的架構討論

CK 提出原始理念：

> Skills 就像我們執法人員執法時要遵循的**憲法、法規、執行細則**與作業流程，harness 就是要保障只要是智力符合一定水準的執法者，都能照這樣的法律架構，執行一定水準的工作。
>
> - **憲法**由我們訂定，記錄期望的理念與想要的結果
> - **法律**由雲端模型訂定，規劃實現憲法的大框架，訂出 Roadmap，再做 Task Queue
> - **執行細則**由本地模型根據每個工作項目包去訂定，按規劃執行並記錄更新

這個「執法體系比喻」成為 C.A.S.E. 框架的核心隱喻。

---

## 第一輪：架構方向驗證

**核心共識：**
- **算力與智力解耦**：雲端模型（高智力、高外流風險）只負責規劃；本地模型（低智力、零外流）負責執行
- **自動化可行性**：工作包定義夠精確，本地模型就能穩定執行
- **資料邊界清晰**：機密「食材（資料）」永遠只在本地，雲端只拿到「菜譜（指引）」

**提出的挑戰：**
本地模型是否有足夠能力「自我驗收」？→ 後來引入 Checker 角色解決

---

## 第二輪：工作包設計與執行瓶頸

**關鍵決策：引入雙軌制**

| 問題 | 解法 |
|------|------|
| 本地模型 Context Window 有限，工作包太複雜容易「注意力遺忘」 | 工作包設計極度原子化，每包只做一件事 |
| 小模型無法可靠地自我驗收 | Worker（執行）＋ Checker（驗收）角色分離 |
| 驗收失敗可能陷入無限迴圈 | 重試上限 3 次，超過自動升級（ESCALATED） |

---

## 第三輪：記憶與脈絡管理

**三層記憶架構共識：**

| 層級 | 實作方式 | 用途 |
|------|---------|------|
| 短期記憶 | `log.md` | 當次工作的流水紀錄 |
| 狀態機 | `status.txt` | 程式可直接讀取的任務進度 |
| 長期記憶 | Vector DB（可選） | 大量歷史文本的 RAG 檢索 |

辦案類比：「偵查日誌（時間軸）」＋「證據清單（結構化數據）」＋「卷宗（完整脈絡）」

---

## 第四輪：檔案驅動架構確立

**CK 提出：** 用文件架構做所有流程控制（planning-with-files 概念），也可以用文件交代 agent 要扮演什麼角色

**Gemini 回應：** 完美契合 Unix 哲學「Everything is a file」

**確立的設計模式：**

| 檔案 | 用途 |
|------|------|
| `role.md` | 角色設定（System Prompt） |
| `recipe.md` | 任務指引（小憲法）＋驗收細則 |
| `status.txt` | 狀態機（四種合法 token） |
| `output.md` | 成果報告 |
| Git 自動版控 | 每次寫入自動 commit，壞了一鍵還原 |

**目錄結構原型（此輪確立）：**
```
00_Constitution/   ← 唯讀憲法
01_Roadmap/        ← 唯讀地圖
02_Task_Queue/     ← 任務卷宗（在自己資料夾內讀寫）
```

---

## 第五輪：Agent 權限與工具設計

**CK 決策：** 賦予本地 Coding Agent 直接讀寫檔案的 Function Calling 權限

**安全設計共識：**
1. 不給原生 shell 命令，改用封裝的 Controlled Tool API
2. 路徑鎖定（Path Jailing）——寫入 `00_Constitution/` 自動 Permission Denied
3. 五個核心工具：`read_file`、`write_artifact`、`change_status`、`submit_for_review`、`escalate_issue`
4. 所有工具呼叫記錄到 `action_log.jsonl`（數位鑑識流水帳）

---

## 第六輪：框架命名

**CK 需求：** 無境外神話色彩、一眼看懂理念雙重意思、符合執法身份、方便警界推廣

**討論過的候選：**

| 縮寫 | 全稱 | 雙關意義 |
|------|------|---------|
| C.O.D.E. | Constitutional Orchestration via Directory Execution | 法典 / 程式碼 |
| **C.A.S.E.** | Constitutional Agent State Engine | **卷宗 / 案件** ✅ |
| F.A.C.T. | File-based Agent Constitutional Tiers | 事實 / 真相 |
| T.R.A.C.E. | Task Routing via Agent Constitutional Execution | 追蹤 / 數位跡證 |
| C.H.I.E.F. | Constitutional Hierarchical Intelligence & Execution Framework | 首長 / 長官 |

**最終決定：C.A.S.E.**

理由：警界每天處理「案件（Case）」和「卷宗（Case File）」，同仁瞬間就能秒懂，遠比軟體術語更有共鳴。

---

## 第七輪：宏觀與微觀層級精煉

**CK 提出：** 第二層不只是切任務包，更重要的是負責「全局觀」—— Roadmap、全案驗收、宏觀審視

**物理學比喻（此輪確立）：**

| 層級 | 比喻 | 職責 |
|------|------|------|
| Layer 2（雲端 AI） | 宏觀（Classical Physics） | 看整片森林；定義目標；規劃 Roadmap；訂全案驗收標準（Global DoD） |
| Layer 3（本地 AI） | 微觀/量子（Quantum） | 不需知道宏觀；只專注把眼前的波函數塌縮（原始資料 → 結構化成果） |

**新增機制：全局聚合（Global Aggregation）**
- 所有 Task 完成 → 匯總所有 `output.md` → Layer 2 核對 `global_dod.md`
- 達標 → 全案結束；未達標 → Layer 2 規劃 Phase 2 重新發包

---

## 第八輪：文件架構設計

**CK 提出：** README 極簡 + Mermaid 圖，分連結「給人看的」和「給 AI 看的」兩份詳細文件，加獨立名詞解釋

**專家群共識：**

| 文件 | 受眾 | 風格 |
|------|------|------|
| `README.md` | 所有人 | 極簡 + Mermaid 圖 + 30 秒導覽 |
| `for_humans.md` | 人類 | 警察辦案比喻、設計哲學 |
| `for_agents.md` | AI Agent | 全英文、MUST/MUST NOT、Schema |
| `glossary.md` | 共用 | 中英對照，雙重定義 |

核心洞見：把警察比喻塞給 AI 讀 = 浪費 Context Window；把嚴格 Schema 塞給人讀 = 生硬難懂。分開是最優解。

---

## 最終決策摘要

| 決策項目 | 結果 |
|---------|------|
| 框架名稱 | C.A.S.E.（Constitutional Agent State Engine） |
| 存放位置 | `Local-Agent-Workspace` repo 的 `C.A.S.E._Framework/` |
| 四大公理 | 智力分層、萬物皆卷宗、雙軌核實、**雙層回饋** |
| 核心目錄結構 | `00_Constitution/` → `01_Roadmap/` → `02_Task_Queue/Task_<NNN>/` |
| Task 必備檔 | `role.md`、`recipe.md`、`status.txt`、`inputs/`、`output.md` |
| 安全機制 | Controlled Tool API ＋ 路徑鎖定 ＋ Git 版控 ＋ 重試熔斷（上限 3 次） |
| 文件受眾分離 | `for_humans.md` ＋ `for_agents.md` ＋ `glossary.md` |
| 回饋機制 | **微觀（⑤）**：Worker 執行中發現缺口 → 直接在 Task Queue 建立子任務；**宏觀（⑥）**：全局聚合未達標 → Layer 2 重規劃新 Stage |

---

🔗 參閱：[C.A.S.E. 框架主頁](../README.md) ｜ [給人類的說明書](../for_humans.md) ｜ [給 AI 的協議](../for_agents.md) ｜ [名詞字典](../glossary.md)

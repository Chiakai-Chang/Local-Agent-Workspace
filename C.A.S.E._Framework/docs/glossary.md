# 📚 C.A.S.E. 名詞解釋字典

> 本字典提供 C.A.S.E. 框架中所有專有名詞的**中英對照與雙重定義**：
> - **人類理解**：用生活或辦案比喻解釋
> - **AI 執行定義**：精確的技術規格，供 AI 操作時參照

---

## 框架核心概念

| 名詞（中文） | 英文術語 | 人類理解 | AI 執行定義 |
|------------|---------|---------|-----------|
| **憲法** | Constitution | 總指揮訂下的最高原則——所有人都必須遵守，任何 AI 都不得修改 | `00_Constitution/core.md` 的內容；所有 agents 只有讀取權，無寫入權 |
| **法律 / 作戰地圖** | Roadmap | 指揮所根據憲法規劃的整體偵辦策略與里程碑 | `01_Roadmap/roadmap.md`；由 Layer 2（雲端 AI）生成；Layer 3 agents 唯讀 |
| **全案驗收標準** | Global Definition of Done (Global DoD) | 指揮所決定「要湊齊哪些成果，整個專案才算真正結案」 | `01_Roadmap/global_dod.md`；Layer 2 在初始規劃階段生成；觸發全局聚合審查的依據 |
| **任務卷宗** | Atomic Task Package | 交辦給基層調查員的一個獨立案件資料夾，裡面附有工作指引、食材與驗收細則 | 路徑 `02_Task_Queue/Task_<NNN>_<slug>/`；包含 `role.md`、`recipe.md`、`status.txt`、`inputs/`、`output.md` |
| **工作指引** | Recipe | 卷宗裡的 SOP 手冊，告訴基層人員怎麼做、做到什麼標準算通過 | `recipe.md`；必要段落：Objective、Input Sources、Output Specification、Local DoD、Constraints、Escalation Trigger |
| **角色設定** | Role / Persona | 告訴 AI「你現在是誰」——例如「你是資料蒐集專員」 | `role.md`；被 Layer 3 agent 載入作為有效 System Prompt |
| **進度狀態** | Task Status | 卷宗封面的「辦理狀態」欄位 | `status.txt`；只能填入五個合法 token 之一（詳見 for_agents.md Section 4） |
| **成果報告** | Output Artifact | 基層人員辦完後寫的結案報告 | `output.md`；由 Worker agent 以 `write_artifact` 工具寫入 |
| **審查意見** | Checker Feedback | 驗收者看完報告後，針對不合格項目寫下的具體退件說明 | `feedback.md`；由 Checker agent 寫入；Worker 下次重做時必須參照 |
| **行動紀錄** | Action Log | 所有工具呼叫的流水帳，用來追查 AI 到底做了什麼 | `action_log.jsonl`；每行一個 JSON 物件，格式：`{ts, role, tool, args, result}` |

---

## 角色與層級

| 名詞（中文） | 英文術語 | 人類理解 | AI 執行定義 |
|------------|---------|---------|-----------|
| **制憲者** | Architect / Constitution Author | 專案的總指揮，決定最高目標與禁止事項 | 人類使用者；唯一可修改 `00_Constitution/` 的對象 |
| **宏觀層 / 指揮所** | Macro Layer / Strategic Planning Layer | 智囊團，負責看全局、出計畫、訂結案標準，但不碰具體案件資料 | Layer 2 角色；可由任何旗艦模型、高推理能力模型或專用規劃 Prompt 擔任；負責生成 Roadmap 與 Task Packages |
| **微觀層 / 基層執行** | Micro Layer / Tactical Execution Layer | 基層調查員，領到任務卷宗，照指引辦事，資料絕不外流 | Layer 3 角色；可由任何開源模型、輕量模型或專用執行 Prompt 擔任（與宏觀層可以是同一個模型）；操作範圍限於當前 Task 資料夾 |
| **執行者** | Worker Agent | 負責執行工作、寫成果報告的基層人員 | 讀取 recipe.md → 撰寫微觀規劃（planning.md）→ 處理 inputs/ → 寫入 output.md → 呼叫 submit_for_review |
| **驗收者** | Checker Agent | 負責審查成果是否符合驗收標準的品管人員 | 讀取 recipe.md 的 Local DoD → 核對 output.md → 核准或退件 |

---

## 狀態機

| 狀態 Token | 中文 | 意思 |
|-----------|------|------|
| `PENDING` | 待辦 | 任務已建立，等待 Worker 開始 |
| `IN_PROGRESS` | 執行中 | Worker 正在進行 |
| `REVIEW` | 待驗收 | Worker 完成，等待 Checker 審查 |
| `DONE` | 結案 | Checker 核准，任務完成 |
| `ESCALATED` | 升級處理 | 重試次數達上限，需人類或 Layer 2 介入 |

---

## 機制與規則

| 名詞（中文） | 英文術語 | 人類理解 | AI 執行定義 |
|------------|---------|---------|-----------|
| **智力分層** | Tiered Intelligence | 讓聰明的 AI 做計畫，讓安全的 AI 做執行 | 核心公理之一；Layer 3 MUST NOT 嘗試宏觀規劃 |
| **萬物皆卷宗** | File as State | 所有進度與記憶都是電腦裡真實存在的文字檔 | 核心公理之一；禁止以對話歷史作為唯一真相來源 |
| **雙軌核實** | Dual-track Verification | 執行者做完，由獨立的驗收者審查，互不自我放水 | 核心公理之一；Worker MUST NOT 自行核准自己的成果 |
| **資訊隔離原則** | Information Isolation Principle | 每個基層人員只能看自己的卷宗，不能偷看別人的 | Layer 3 只能讀取：`00_Constitution/core.md`、`01_Roadmap/*.md`（若 recipe 允許）、自己的 Task 資料夾 |
| **重試熔斷** | Retry Decay / Escalation Threshold | 同一件事做錯三次，就停工求援，不再無謂重試；若是執行中發現缺口，則建立子任務後才升級 | Checker 追蹤 retry count；≥ 3 → escalate_issue → `ESCALATED`；Worker 發現先決缺口可先建立子任務再 escalate |
| **時光機還原** | Git Rollback | 每次 AI 修改檔案都自動備份，壞了可以一鍵恢復 | 每次 `write_artifact` 觸發自動 `git commit`；`revert_task(task_id)` 還原整個 Task 資料夾 |
| **全局聚合** | Global Aggregation | 所有小任務都結案後，指揮所統一審視是否達到全案標準 | 所有 Task 狀態 = `DONE` 後觸發；Layer 2 核對 `global_dod.md` |
| **微觀回饋** | Micro-Level Feedback (⑤) | 基層人員辦案中發現缺了一份前置資料，馬上補開一個新卷宗繼續辦——不用等總指揮開會 | Worker 在執行中發現先決缺口 → 呼叫 `create_subtask` 工具（由協調系統在 `02_Task_Queue/` 建立新卷宗）→ 自身 escalate 暫停等待子任務完成 |
| **宏觀回饋** | Macro-Level Feedback (⑥) | 所有任務全部結案後，總指揮發現全案標準仍有缺漏，重新規劃下一階段 | Global Aggregation 核對 `global_dod.md` 未達標 → Layer 2 重規劃 → 新 Task Packages 進入 `02_Task_Queue/` |
| **幻覺** | Hallucination | AI 一本正經地捏造了不存在的資料或方法 | LLM 輸出與現實不符的虛假內容；C.A.S.E. 透過 File as State 與 Dual-track Verification 降低此風險 |
| **上下文遺忘** | Context Forgetting / Attention Decay | AI 對話太長，忘記了前面說過的重要指示 | 超出 Context Window 後的資訊衰減；C.A.S.E. 透過把狀態寫入實體檔案來規避此問題 |

---

🔗 延伸閱讀：[給人類看的說明書](for_humans.md) ｜ [給 AI 看的技術協議](for_agents.md) ｜ [回到框架主頁](../README.md)

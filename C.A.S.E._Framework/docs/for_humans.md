# 📖 C.A.S.E. 框架：最直白的說明書

這是一份寫給人類（開發者、專案負責人或任何想用 AI 寫程式的人）的極簡說明書。沒有華麗的話術與複雜的資工術語，只有大白話。

---

## 1. 痛點：AI 寫程式時有什麼問題？

當您把專案交給 AI（如 Cursor, Claude Code）去開發或修改時，一定遇過這些麻煩事：
1. **失憶與忘記指令**：對話長了，AI 就會忘記前面的規矩，甚至開始亂改程式碼。
2. **Token 帳單很貴**：讓雲端 AI 去做全案掃描、跑測試、改小 Bug 等苦力活，非常浪費錢。
3. **AI 謊報與幻覺**：AI 嘴上說「我已經全部改好了！」，您打開一看卻發現檔案根本沒變，或者程式根本跑不動。
4. **機密資料外洩**：敏感代碼、資料庫密碼或商業機密直接丟給雲端 API，有隱私風險。

---

## 2. 解法：C.A.S.E. 框架如何運作？

C.A.S.E. 不是複雜的軟體套件，而是一套**用實體檔案管束 AI 行為的工作方法**。

我們將 AI 角色進行**角色分層與職責解耦**，可完美兼容**「全雲端 (Full-Cloud)」、「全本地 (Full-Local)」及「雲地混合 (Hybrid)」**三種部署架構。無論您是用單一模型（例如一個本機 27B/32B 模型）跑完所有流程，還是雲地混合協同，皆能完美適應：

```
[ 您的目標（憲法） ]
        │
        ▼
[ 宏觀規劃角色 ] ──► 只負責「拆解任務」與「訂全案驗收標準」，不碰原始代碼。
        │            （可由大模型、旗艦模型或專用規劃 Prompt 擔任）
        ▼
[ 微觀執行角色 ] ──► 依序領取任務卷宗，在受控環境（本機或沙箱）內做事。
                     （可由輕量模型、開源模型或專用執行 Prompt 擔任）
```

為了防止 AI 在執行過程中發瘋或出錯，我們將任務進行**物理隔離**，每個任務都是一個獨立的實體資料夾（任務卷宗）：

1. **做事規則 (`recipe.md`)**：寫明該任務要修改的檔案範圍、Local DoD（驗收標準）與禁止事項。
2. **角色設定 (`role.md`)**：定義 AI 此任務的角色定位（例如：重構專家、測試人員）。
3. **微觀規劃與復盤流程**：
   - **認領任務**：Worker 認領 `PENDING` 任務，標記為 `IN_PROGRESS`。
   - **細部規劃**：Worker 在修改代碼前，先撰寫細部規劃（如 `planning.md`）並檢查邊界，與使用者或系統對齊。
   - **謹慎執行與測試**：Worker 依據規劃進行微幅修改、執行單元測試，並記錄於 `action_log.jsonl` 中。
   - **核實與自動版控**：由 Checker 獨立驗收。通過後，Harness 自動進行 `git commit`（與可選的 `git push`），將狀態標記為 `DONE` 並進入下一個任務。
4. **防騙檢查 (`status.txt`)**：控制座（Harness）自動檢驗實體日誌，確保 AI 確實執行了儲存與測試指令，拒絕幻覺與謊報。

---

## 2.5. 雲地協同最佳實踐：如何以高 CP 值進行雙軌合作？

雖然 C.A.S.E. 完全相容於單一本地模型（例如只用一個本機 27B/32B 模型跑完全流程），但在實務上，如果您有網路連線，**「雲端規劃（高智力） + 本地執行（高隱私與免 Token 費）」的雙軌協同（Hybrid Topology）**通常能達到最高的整體效能與經濟效益：

### 🤝 雲地分工與交接時機點

1. **宏觀規劃期（出題與拆分）**：
   - **協作時機**：在專案剛啟動、要制定大計畫時。
   - **做法**：您可以先將您的專案目錄結構（不需提供機密原始碼）與最終憲法目標輸入給**雲端旗艦大模型**（如 Claude 3.5 Sonnet 或 Gemini 1.5 Pro）。
   - **產出**：讓大模型發揮強大的 Zero-shot 架構思維，生成 `01_Roadmap/roadmap.md` 並為各任務開出標準的 `recipe.md` 指引與 DoD（驗收條件）。

2. **微觀執行期（本地動手做）**：
   - **協作時機**：規劃完成，進入具體的開發或測試工作時。
   - **做法**：將生成好的任務資料夾保留在本地。啟動**本機開源/輕量模型**（如 Gemma 27B 或 Llama 3），認領並進入 `IN_PROGRESS`，專注在 Task 沙箱中進行具體的程式碼修訂與單元測試。
   - **好處**：巨量的代碼編修、單元測試、重複偵錯與 Token 消耗完全在本地免費執行，且**商業敏感代碼與密鑰完全不外流**。

3. **微觀遇到障礙（掛起升級）**：
   - **協作時機**：本地執行遇到前提缺失，或發現環境嚴重卡關需要「修法」或「重擬大計畫」時。
   - **做法**：本地模型將 `status.txt` 寫入 `ESCALATED` 標記懸掛任務（可手動修改、透過輔助腳本、或由 AI 自行操作）。您可將此懸掛點的 Error 訊息或新發現，傳回給**雲端規劃大模型**重新修訂 Roadmap 與 Recipe，修復後再發配給本地繼續執行。

4. **全局聚合期（結案驗收）**：
   - **協作時機**：所有本地任務均標記為 `DONE` 時。
   - **做法**：收集本地所有任務的 `output.md` 報告摘要，提供給雲端規劃大模型，由其審核是否完全滿足 `global_dod.md` 的全案最終結案標準。


---

## 2.6. 雲地協同實例：如何具體啟動、執行與交接？

為了讓您更清楚「雲端規劃」與「地端執行」具體如何分工、下什麼指令，以及如何透過檔案系統完成交接，以下提供一個標準的實戰演練流程：

### 🎬 步驟一：雲端大腦啟動規劃 (Cloud Strategic Planning)
* **工具/角色**：使用雲端 AI 助手 (如 `Claude Code`、`Windsurf` 連線雲端、或網頁版 ChatGPT/Claude Pro)。
* **人類下的指令 (極簡 Prompt)**：
  > 「本專案採用 C.A.S.E. 框架。請閱讀專案目標，並在 `01_Roadmap/roadmap.md` 中規劃開發階段，接著在 `02_Task_Queue/Task_001_initial_scaffold/` 下建立任務卷宗，填寫 `recipe.md` 與 `role.md`。完成後將 `status.txt` 設為 `PENDING`。」
* **雲端 AI 的動作**：
  1. 讀取並理解整個專案的脈絡與憲法目標。
  2. 設計全局 Roadmap。
  3. 建立 `Task_001` 資料夾，寫入任務的執行限制、Definition of Done (DoD) 以及該任務所需的角色定義。
  4. 寫入 `status.txt` 內容為 `PENDING`。

---

### 🔨 步驟二：地端手腳認領執行 (Local Tactical Execution)
* **工具/角色**：使用本機運行的 AI Agent (如連接本地 Ollama/Llama.cpp Gemma 27B 的 `Antigravity CLI`、`Pi Code Agent` 或本地 IDE 插件)。
* **人類下的指令 (極簡 Prompt)**：
  > 「請認領 `02_Task_Queue/Task_001_initial_scaffold/` 任務。將其 `status.txt` 改為 `IN_PROGRESS`，並依據 `recipe.md` 規範與 `role.md` 的角色開始執行開發。」
* **地端 AI 的動作**：
  1. 修改 `status.txt` 為 `IN_PROGRESS`。
  2. 閱讀 `recipe.md` 與 `role.md` 載入系統 prompt。
  3. 在 `planning.md` 中撰寫細部實作計畫與測試案例。
  4. 在本地開始編修程式碼、編譯並反覆執行單元測試（不消耗雲端 Token，代碼完全留在本地）。
  5. 將每次的操作記錄在 `action_log.jsonl`（或 fallback 的 `log.md`）中。
  6. 開發完成且本地測試通過後，將 `status.txt` 改為 `REVIEW`（或調用 `submit_for_review`）。

---

### 🔍 步驟三：自動化檢驗與人類極簡驗收 (AI Self-Review & Minimal Human Handoff)
為了極大化減少人類的繁瑣操作，交接與驗收完全是**智慧化且由 AI 主動驅動**的：

1. **AI 自動復盤與修復 (AI Self-Validation & Self-Healing)**：
   * 在向人類回報前，地端/執行 AI 會主動對照 `recipe.md` 的 DoD 逐項自我復盤並執行本地測試。
   * 若發現測試失敗或遺漏，AI 會**自動繼續修改代碼或生成修補子任務**，直至全部通過。中間出錯時，**完全不打擾人類**。
2. **人類極簡驗收 (Natural Language Approval)**：
   * 當 AI 自我檢驗 100% 通過後，才會在對話中向人類回報成果。人類只需以大白話與 AI 對話，**不需要手動修改任何 `status.txt` 檔案或逐項勾選**：
     * **若通過**：人類直接對 AI 說：「沒問題，通過」或「OK，收工」。AI 接收後會**自動**將 `status.txt` 改為 `DONE` 並完成 git commit / push。
     * **若需修改**：人類直接對 AI 說：「這裡字型大小幫我調整一下」。AI 接收後會**自動**將狀態設回 `IN_PROGRESS` 進行修復，直到完成後再次請人類看。

---


## 2.8. 進階演進：基於業界最佳實踐的 C.A.S.E. 優化

為使 C.A.S.E. 更具備工業級的抗干擾性、記憶可擴展性與驗收真實性，我們融合了多個開源 Agent 框架（如 Andrej Karpathy 的 LLM Wiki 模式、BDD 規格驅動開發等）的核心精髓，升級了以下四大機制：

1. **BDD 規格先導驗收 (Spec-by-Example)**：
   - 傳統 AI 容易「盲目寫代碼，然後猜測是否正確」。
   - 優化後，AI 在 `planning.md` 規劃期必須先將 DoD 拆解為 Given-When-Then 驗收測試案例。在開始改動代碼前，必須觀察到測試失敗（RED），最後程式碼完成後必須驗證測試通過（GREEN）。

2. **上下文壓縮交接艙 (Handoff Capsule)**：
   - AI 面臨 context 爆滿需清除對話（`/clear`）或進行 Compaction 時，微觀規劃檔案會自動維護一個 YAML 格式的 `session_summary` 與 `active_pivot_point`（交接艙）。
   - 當 context 被清除後，下一個 session 的 AI 能讀取交接艙，實現無縫連續開發。

3. **分片知識庫標準 (Sharded Knowledge Base)**：
   - 隨專案歷史拉長，`learnings.md` 與任務歷史容易過度膨脹，堵塞 AI 脈絡。
   - 引入 `00_Constitution/knowledge_base/` 標準分片目錄。將大型 learnings 和專案領域知識進行 YAML Frontmatter 標籤化與分片索引（Sharded Index），讓 AI 只在需要時載入對應分片，實現海量記憶的高效檢索。

4. **跨模型雙軌對抗審查 (Cross-Model Adversarial Audit)**：
   - 「自己改代碼，自己寫測試並宣稱通過」是 AI 的常見盲點。
   - 優化協議建議 Worker（執行者，如本地開源模型）與 Checker（驗收者，如雲端商用模型）使用**不同家族的模型**，並強制 Checker 在全新、乾淨的 Thread 中以冷啟動方式審查結果，杜絕自我放水。

---

## 3. C.A.S.E. 對您的專案有什麼好處？

* **🌐 靈活部署，兼容全場景**：無論您的環境是全雲端（雲端 VM 開發）、全本地（無網路保密環境），或是雲地混合，C.A.S.E. 都能提供一致的檔案級別狀態控制。
* **💰 節省費用**：在混合或全本地模式下，把寫代碼、跑單元測試等最耗 Token 的重複性苦力活，交給**本機免費**或低成本小模型跑。
* **🔒 安全與沙箱隔離**：程式碼可留在本機或在虛擬沙箱（如透過 `trycua` 工具）中執行，與敏感環境物理隔離。
* **🧠 AI 不會失憶**：任務進度直接寫在實體檔案（`status.txt`）裡。即使 AI 當機或中途更換 AI 軟體，牠們讀了檔案就能立刻接關繼續做。
* **🛡️ 保護原始碼**：Worker（執行）與 Checker（驗收）分離，配合 Git 版控自動備份，即使 AI 出錯也改不壞您的主程式。

---

## 3.5. 模組化拆分：宏觀與微觀可獨立運行

C.A.S.E. 框架具有高度的**模組化設計**，宏觀規劃（Macro）與微觀執行（Micro）完全可以拆開獨立使用，不一定要綁定複雜的部署架構或雲地分工：

* **🎯 僅使用「微觀執行模式」（Micro-Only Mode）**：
  - **適用場景**：臨時想針對某個小項目進行「極度謹慎、高品質、有跡可循」的開發或重構，而不需全局戰略圖。
  - **使用方式**：在專案中直接建立單一的任務卷宗（如 `02_Task_Queue/Task_001_Refactor/`），手寫或讓 AI 生成該任務的 `recipe.md` 限制與 DoD 驗收條件。AI 認領後，將在此限定沙箱內執行「寫規劃（`planning.md`） $\rightarrow$ 謹慎修改與測試 $\rightarrow$ Git 版控自動 Commit/Push $\rightarrow$ 獨立驗收」，確保改動安全不發瘋。
* **🗺️ 僅使用「宏觀規劃模式」（Macro-Only Mode）**：
  - **適用場景**：在專案初期，只希望 AI 來做高品質的系統架構拆解、Roadmap 設計與任務規格交辦，具體執行改由人類工程師或傳統管道進行。
  - **使用方式**：僅讓 AI 輸出 `00_Constitution/` 與 `01_Roadmap/roadmap.md`，並將拆解好的子任務寫入 `02_Task_Queue/Task_*/recipe.md` 作為標準的交付規格書。

---

## 3.8. 🔒 唯讀寫入防禦 (Write Defense) 的自動化藍圖

因為 C.A.S.E. 框架為純文字設計，不強制在您的專案庫中包含任何專屬的程式腳本，我們建議在您的版本控制系統（例如 Git Hook 或 CI/CD 流程）中實施**唯讀寫入防禦**。這能防止 AI 助手在未經授權的情況下修改憲法目錄 `00_Constitution/` 或路線圖目錄 `01_Roadmap/`。

以下提供兩種開箱即用的安全防禦範本：

### 1️⃣ GitHub Actions 寫入防禦工作流 (`.github/workflows/case-defense.yml`)
在專案中建立此工作流檔案。當 PR 被提交時，若偵測到非授權角色修改了 `00_Constitution/` 或 `01_Roadmap/` 且未經人類核准，CI 將會自動阻擋合併：

```yaml
name: C.A.S.E. Write Defense

on:
  pull_request:
    paths:
      - '00_Constitution/**'
      - '01_Roadmap/**'

jobs:
  check-authorization:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Verify Change Authorization
        run: |
          # 檢查 PR 是否有 'human-approved' 標籤
          LABELS=$(curl -s "https://api.github.com/repos/${{ github.repository }}/pulls/${{ github.event.pull_request.number }}" | jq -r '.labels[].name')
          
          if [[ ! "$LABELS" =~ "human-approved" ]]; then
            echo "::error::偵測到唯讀目錄變更，且未附加 'human-approved' 標籤！"
            exit 1
          fi
          echo "變更已通過人類審查授權。"
```

### 2️⃣ 本地 Git Pre-commit 鉤子腳本 (`.git/hooks/pre-commit`)
在本地端，您可以將以下內容寫入 `.git/hooks/pre-commit`（並執行 `chmod +x`），以防本地 AI 助手（如 Cursor、Gemini CLI）在您不知情的情況下修改了憲法或路線圖：

```bash
#!/bin/bash

# 獲取暫存區中即將提交的修改檔案列表
CHANGED_FILES=$(git diff --cached --name-only)

# 唯讀目錄清單
READONLY_DIRS=("00_Constitution/" "01_Roadmap/")

VIOLATION=0
for FILE in $CHANGED_FILES; do
  for DIR in "${READONLY_DIRS[@]}"; do
    if [[ "$FILE" == "$DIR"* ]]; then
      # 如果未設定特定繞過變數（代表非人類授權），則報錯
      if [ -z "$CASE_HUMAN_BYPASS" ]; then
        echo "❌ 錯誤：AI/指令試圖修改唯讀目錄下的檔案: $FILE"
        VIOLATION=1
      fi
    fi
  done
done

if [ $VIOLATION -eq 1 ]; then
  echo "👉 若您是人類開發者且確實需要修改，請設定環境變數後再 commit："
  echo "   CASE_HUMAN_BYPASS=1 git commit -m 'your message'"
  exit 1
fi
```

---

## 4. 如何在您現有的專案中快速使用？

C.A.S.E. 採用純文字聲明式配置，無須執行任何代碼腳本即可無痛引入：

1. **下載 Agent 規則手冊**：
   將 [for_agents.md](for_agents.md) 下載並放置到您的專案根目錄，命名為 `CASE_framework_for_agents.md`。
2. **配置 IDE / AI Agent 引導 Prompt（極簡）**：
   在您的 `.cursorrules`、`CLAUDE.md`、`memory.md` 或直接在與 AI Agent（如 Cursor/Claude Code/Gemini CLI 等）對話時，貼上以下極簡引導指令：
   > 「本專案採用 C.A.S.E. 框架，請閱讀並遵循專案中的 `CASE_framework_for_agents.md` 進行開發與任務管理。」
   *(提示：如果是使用 Cursor，可以在對話中使用 `@CASE_framework_for_agents.md` 來關聯此檔案。)*
3. **開始運作**：
   AI 讀取手冊後將自動建立物理目錄結構（`00_Constitution/`、`01_Roadmap/`、`02_Task_Queue/`）並依據 C.A.S.E. 規則自主進行「認領任務 $\rightarrow$ 撰寫規劃 $\rightarrow$ 修改測試 $\rightarrow$ Git 版控 $\rightarrow$ 結案驗收」的狀態機流轉。

---

🔗 **相關文件**：
- [AI 專屬執行協定 (System Protocol)](for_agents.md)
- [Harness 控制座優化設計](harness_engineering.md)
- [C.A.S.E. 名詞釋義字典](glossary.md)


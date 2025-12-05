# ComboCube

> 一款以「方塊化任務（Cube）」為核心的 iOS 訓練與任務編排 App，支援單項任務、組合任務（Combo）、時間觸發、未來可擴充 Widget 與背景執行。

---

## 🚀 專案目標

- 打造成「**可以像堆積木一樣安排訓練或任務流程的 iOS App**」
- 可用於：
  - 健身訓練
  - 番茄鐘
  - 讀書計畫
  - 任務流排程

---

## ✅ 第一部分：App 功能說明 / 操作說明（專案進度看板）

> 說明：
> - ⬜ 尚未開始
> - 🟨 開發中
> - ✅ 已完成

### 🧩 核心功能
- 🟨 【方塊任務 Cube】建立單一任務（Timer / Countdown / Repetition）
- 🟨 【組合任務 Combo】多個 Cube 組合成流程
- 🟨 【任務循環 Loop】Combo 支援循環次數
- 🟨 【自動切換 AutoNext】子任務結束自動進入下一個
- 🟨 【任務複製 Copy】快速產生新任務（不影響原始任務）
- 🟨 【任務排序】可調整 Combo 內子任務順序
- 🟨 【任務資料永久儲存】使用 SwiftData
- 🟨 【任務執行 Runner 引擎】依 Cube 類型轉成對應 Task
- 🟨 【背景計時支援】App 進入背景仍可計時
- ⬜ 【Widget 同步顯示任務狀態】

---

### 🕹 操作流程
- ✅ 建立單一任務 Cube
- 🟨 建立 Combo 並加入子任務
- 🟨 複製任務作為新模版
- 🟨 拖曳調整執行順序
- 🟨 執行任務流程（Runner）
- ⬜ Widget 快速啟動任務

---

## 🏗 第二部分：技術 / 架構說明（高階版）

### 📦 架構分層
- `UI Layer`：SwiftUI + View + ViewModel
- `Model Layer`：SwiftData（@Model）
- `Manager Layer`：CubeManager（資料操作集中管理）
- `Runner Layer`：TimerTask / ComboTask / CountdownTask
- `Persistence Layer`：ModelContainer / SwiftData 初始化


### 🔑 關鍵設計理念
- ✅ 業務邏輯集中在 **Manager**
- ✅ 資料模型只負責「資料本身」
- ✅ 任務執行由 Runner 階層負責
- ✅ UI 不直接操作 SwiftData


### 🗃 資料儲存
- 使用 `SwiftData`
- `@Model` 定義 Cube
- `@Relationship` 管理 Combo → 子 Cube

---

## 🛠 第三部分：除錯 / 開發用設定

### 🔁 重置範例資料（重新注入 Sample Cubes）

當你要重新匯入範例 Cube 時，請在除錯階段呼叫：

```swift
UserDefaults.standard.removeObject(forKey: "didInitializeSampleCubes")
```

下次 App 啟動時：
- ✅ `initializeSampleCubesIfNeeded()` 會重新執行
- ✅ 所有範例 Cube 會重新寫入資料庫

---

### 🐞 常見除錯技巧
- ✅ 刪除 App 重裝（清除 SwiftData）
- ✅ 重設 UserDefaults Flag
- ✅ 使用 `print` 追蹤 Combo children 是否正確關聯

---

# Pokémon App Architecture

> 採用 **MVVM (Model-View-ViewModel)** 模式，並遵循 **Clean Architecture** 原則，確保程式碼的清晰、可維護和可測試性。專注於職責分離和單向資料流。

# 專案結構 (Folder Structure)

專案結構分為四個主要層次，確保職責清晰分離：
├── Data # 數據來源管理 
├── Domain # 核心業務邏輯 
├── Local # 本地快取與儲存 
└── Presentation # UI 與視圖邏輯 (MVVM)


├── Pokemon
│   ├── Data                  # 外部資料來源 (API / 實作 Repository)
│   │   ├── DTOs              # Data Transfer Objects (API 解析模型)
│   │   ├── Remote            # 網路服務實作 (e.g., NetworkService)
│   │   └── RepositoriesImpl  # Domain Repositories 的具體實現
│   │
│   ├── Domain                # 核心業務邏輯 (獨立於任何框架)
│   │   ├── Entities          # 核心業務模型 (e.g., Pokemon)
│   │   ├── Repositories      # Repository 介面 (協議 Protocols)
│   │   └── UseCases          # 處理特定業務流程 (e.g., FetchPokemonListUseCase)
│   │
│   ├── Local                 # 本地資料儲存與快取
│   │   └── LocalCache        # 本地快取邏輯
│   │
│   └── Presentation          # UI 邏輯與視圖
│       ├── Cells             # 可重用 UI 元件 (e.g., FeaturedCell)
│       ├── Extensions        # 通用擴展 (e.g., UIImage+Assets)
│       ├── Home              # 主頁面 (e.g., HomeViewController)
│       ├── PokemonDetail     # 詳情頁面
│       ├── PokemonList       # 列表頁面
│       ├── Shared            # 通用工具與管理器 (e.g., FavoritesManager, ImageLoader)
│       └── ViewModels        # 視圖邏輯與狀態管理 (e.g., PokemonListViewModel)

# 資料流(The Flow)

數據流向是**單向**的：從 View 開始，經過 Domain 業務處理，最終由 Data 層提供/更新數據。
1.  **View** -> **ViewModel**：用戶操作觸發 ViewModel 方法。
2.  **ViewModel** -> **Use Case**：調用業務邏輯。
3.  **Use Case** -> **Repository (Protocol)**：請求數據。
4.  **Repository Impl (Data)**：從 Remote 或 Local 獲取數據，轉換為 **Entity**。
5.  **Entity** 返回 ViewModel。
6.  **ViewModel** 更新狀態 -> **View** 響應更新 UI。

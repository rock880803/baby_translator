# 📱 Babe Translator - App 開發指南

## 🏗️ 專案架構

```
babe-translator/
├── mobile/                 # Flutter App (iOS/Android)
│   ├── lib/
│   │   ├── main.dart      # App 入口
│   │   ├── screens/       # 畫面
│   │   ├── models/        # 資料模型
│   │   └── services/      # API 服務
│   └── pubspec.yaml       # Flutter 依賴
│
└── src/main/python/api/   # Python FastAPI 後端
    ├── main.py            # API 主程式
    └── requirements.txt   # Python 依賴
```

## 🚀 快速開始

### 1️⃣ 安裝 Flutter

**Windows:**
```bash
# 下載 Flutter SDK
# https://docs.flutter.dev/get-started/install/windows

# 設定環境變數後驗證
flutter doctor
```

**macOS:**
```bash
brew install flutter
flutter doctor
```

### 2️⃣ 設定 Python 後端

```bash
# 創建虛擬環境
cd src/main/python/api
python -m venv venv

# 啟動虛擬環境
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# 安裝依賴
pip install -r requirements.txt

# 啟動 API 服務器
python main.py
# API 運行在 http://localhost:8000
```

### 3️⃣ 運行 Flutter App

```bash
# 進入 mobile 目錄
cd mobile

# 安裝 Flutter 依賴
flutter pub get

# 檢查連接的設備
flutter devices

# 運行 App
# iOS 模擬器:
flutter run -d ios

# Android 模擬器/設備:
flutter run -d android

# Chrome (網頁版測試):
flutter run -d chrome
```

## 📱 主要功能

### ✅ 已實現的功能

1. **MBTI 人格選擇**
   - 16 種 MBTI 類型
   - 中文描述
   - 持久化儲存

2. **訊息輸入**
   - 手動文字輸入
   - 拍照上傳
   - 相簿選擇
   - OCR 文字識別

3. **情感分析**
   - 情緒檢測
   - 語氣分析
   - 心情判斷
   - 潛在需求識別

4. **回覆生成**
   - MBTI 個性化回覆
   - 多種風格選擇
   - 信心度評分
   - 一鍵複製

### 🔨 待實現的 AI 功能

1. **NLP 分析模型**
   - 使用 transformers 實現情感分析
   - 整合中文 NLP 模型
   - 實現語氣和心情檢測

2. **MBTI 回覆生成**
   - 基於 GPT/LLaMA 的回覆生成
   - MBTI 人格特徵訓練
   - 多風格回覆優化

3. **OCR 文字識別**
   - Tesseract OCR 整合
   - 或使用 Google Vision API
   - 支援中英文識別

## 🔧 開發流程

### Backend API 開發
```bash
# 1. 修改 src/main/python/api/main.py
# 2. 實現 AI 模型功能
# 3. 測試 API: http://localhost:8000/docs
```

### Frontend App 開發
```bash
# 1. 修改 mobile/lib/ 下的檔案
# 2. Hot reload: 按 'r' 鍵
# 3. Hot restart: 按 'R' 鍵
```

## 📦 打包發佈

### Android APK
```bash
cd mobile
flutter build apk --release
# 輸出: build/app/outputs/flutter-apk/app-release.apk
```

### iOS IPA
```bash
cd mobile
flutter build ios --release
# 需要 Apple Developer 帳號
```

### App Store / Google Play
```bash
# Android
flutter build appbundle --release

# iOS
flutter build ipa --release
```

## 🔗 API 端點

- `GET /` - API 資訊
- `POST /api/analyze` - 分析訊息情感
- `POST /api/generate-replies` - 生成 MBTI 回覆
- `POST /api/extract-text` - OCR 文字識別

完整 API 文檔: http://localhost:8000/docs

## 🎨 自定義設計

### 修改主題色
編輯 `mobile/lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.pink, // 改成你喜歡的顏色
),
```

### 修改字體
編輯 `mobile/pubspec.yaml`:
```yaml
fonts:
  - family: YourFont
    fonts:
      - asset: assets/fonts/YourFont.ttf
```

## 🐛 常見問題

**Q: Flutter doctor 顯示錯誤？**
```bash
# 安裝 Android Studio
# 安裝 Xcode (macOS only)
flutter doctor --android-licenses
```

**Q: API 連接失敗？**
- 確認後端已啟動: http://localhost:8000
- 檢查 `mobile/lib/services/api_service.dart` 的 baseUrl
- Android 模擬器使用 `10.0.2.2:8000` 而非 `localhost:8000`

**Q: 如何在真機測試？**
- iOS: 需要 Apple Developer 帳號
- Android: 啟用開發者模式和 USB 調試

## 📚 相關資源

- [Flutter 官方文檔](https://docs.flutter.dev/)
- [FastAPI 文檔](https://fastapi.tiangolo.com/)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers)

## 🎯 下一步

1. **實現 AI 模型**
   - 整合中文 NLP 模型
   - 訓練 MBTI 回覆生成器

2. **優化 UI/UX**
   - 添加動畫效果
   - 改善使用者體驗

3. **添加更多功能**
   - 歷史記錄
   - 收藏回覆
   - 個性化設定

---

**✅ CRITICAL RULES ACKNOWLEDGED** - 遵循 CLAUDE.md 規範開發

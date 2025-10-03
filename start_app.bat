@echo off
echo ========================================
echo    Babe Translator - AI 情感分析助手
echo    Flutter 移動應用 + FastAPI 後端
echo ========================================
echo.

echo [1/2] 正在啟動後端 API 服務器...
start "Backend API" cmd /k "cd /d "%~dp0src\main\python\api" && python main.py"

echo 等待 5 秒讓後端服務器啟動...
timeout /t 5 /nobreak > nul

echo.
echo [2/2] 正在啟動 Flutter 應用程式...
start "Flutter App" cmd /k "cd /d "%~dp0mobile" && flutter run -d chrome"

echo.
echo ========================================
echo 應用程式已啟動！
echo.
echo 後端 API: http://localhost:8000
echo API 文檔: http://localhost:8000/docs
echo Flutter App: 正在啟動中...
echo.
echo 提示: Flutter 首次執行可能需要較長時間
echo.
echo 按任意鍵關閉此視窗...
pause > nul

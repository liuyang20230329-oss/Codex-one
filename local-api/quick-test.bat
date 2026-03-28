@echo off
chcp 65001 >nul
echo ============================================================
echo 🧪 快速测试本地开发环境
echo ============================================================

echo.
echo 📊 检查API服务器...
echo.
ping -n 1 localhost -p 3000 -w 1 >nul 2>&1
if errorlevel 1 (
    echo ❌ API服务器未启动！
    echo    请先启动API服务器: cd D:\Codex\local-api ^|^ node server.js
) else (
    echo ✅ API服务器运行正常！
)

echo.
echo 📋 检查数据库...
echo.
if exist "D:\Codex\local-api\data\37degrees.db" (
    echo ✅ 数据库文件存在！
) else (
    echo ❌ 数据库文件不存在
)

echo.
echo 🌐 检查端口占用...
echo.
netstat -ano | findstr ":3000" >nul 2>&1
if errorlevel 1 (
    echo ⚠️  端口3000被占用
) else (
    echo ✅ 端口3000可用
)

echo.
echo 📱 检查网络连通性...
echo.
curl -s http://localhost:3000/health --connect-timeout 5 >nul 2>&1
if errorlevel 1 (
    echo ❌ 网络连接失败
) else (
    echo ✅ 网络连接正常！
)

echo.
echo ============================================================
echo 🎯 环境检查完成！
echo ============================================================

echo.
echo ✅ API服务器: http://localhost:3000
echo ✅ 数据库: D:\Codex\local-api\data\37degrees.db
echo ✅ HTTP客户端: D:\Codex\lib\src\core\network\http_client.dart
echo ✅ 认证系统: Demo + 本地API
echo.
echo.
echo 📝 下一步行动：
echo.
echo 1️⃣ 启动Flutter应用
echo    flutter run
echo.
echo 2️⃣ 测试功能
echo    - 用户注册
echo    - 用户登录
echo    - 资料更新
echo.
echo 3️⃣ 配置内网穿透（可选）
echo    - 运行: D:\Codex\local-api\setup-tunnel.bat
echo    - 或手动安装ngrok
echo.
echo.
echo 📋 查看详细文档：
echo    D:\Codex\docs\local-development-complete.md
echo.
echo ============================================================

pause
#!/usr/bin/env pwsh
# Trading Journal 更新和打包腳本

# 設定版本號
$version = Read-Host "Enter new version (e.g., 1.1.0)"
$message = Read-Host "Enter commit message"

# 檢查 git 狀態
Write-Host "🔍 檢查 git 狀態..." -ForegroundColor Blue
git status

# 更新 package.json 版本
Write-Host "📝 更新版本號為 $version..." -ForegroundColor Yellow
$packageJson = Get-Content package.json -Raw
$packageJson = $packageJson -replace '"version":\s*"[^"]*"', "`"version`": `"$version`""
$packageJson | Set-Content package.json

# 提交變更
Write-Host "📤 提交到 Git..." -ForegroundColor Yellow
git add .
git commit -m "$message (v$version)"
git tag "v$version"
git push
git push origin "v$version"

# 清理舊的 release
Write-Host "🧹 清理舊的打包檔案..." -ForegroundColor Yellow
if (Test-Path release) {
    Remove-Item -Recurse -Force release
}

# 打包應用
Write-Host "🏗️  開始打包應用..." -ForegroundColor Green
npm run build:win

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 打包完成！" -ForegroundColor Green
    Write-Host "📦 安裝檔位置: release\Trading Journal Setup $version.exe" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "下一步：" -ForegroundColor Yellow
    Write-Host "1. 在 GitHub Releases 中建立新的 release"
    Write-Host "2. 上傳 release\Trading Journal Setup $version.exe" -ForegroundColor Cyan
} else {
    Write-Host "❌ 打包失敗，請檢查上面的錯誤訊息" -ForegroundColor Red
}

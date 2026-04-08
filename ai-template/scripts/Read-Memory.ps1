# Read-Memory.ps1
# 读取 memory/ 目录下所有 .md 文件并输出内容，供 AI 会话开始时注入上下文。
# 用法：pwsh -File Read-Memory.ps1 [-MemoryRoot <path>]

param(
    [string]$MemoryRoot = (Join-Path $PSScriptRoot '..' 'memory')
)

$MemoryRoot = Resolve-Path $MemoryRoot -ErrorAction SilentlyContinue

if (-not $MemoryRoot -or -not (Test-Path $MemoryRoot)) {
    Write-Host "Memory 目录不存在：未找到 memory/" -ForegroundColor Yellow
    exit 0
}

$files = Get-ChildItem $MemoryRoot -Filter '*.md' -File | Sort-Object Name

if ($files.Count -eq 0) {
    Write-Host "Memory 为空：无持久记忆文件" -ForegroundColor Yellow
    exit 0
}

foreach ($file in $files) {
    Write-Host ""
    Write-Host "## $($file.BaseName)" -ForegroundColor Cyan
    Write-Host (Get-Content $file.FullName -Raw -Encoding UTF8)
}

Write-Host ""

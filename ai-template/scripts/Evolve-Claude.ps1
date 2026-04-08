# Evolve-Claude.ps1
# 任务结束后强制运行。输出结构化审计清单，AI 必须逐项回应并执行更新。
# 用法：pwsh -File Evolve-Claude.ps1

param(
    [string]$ClaudeRoot = (Join-Path $PSScriptRoot '..')
)

$ClaudeRoot = Resolve-Path $ClaudeRoot

function Format-RelTime([datetime]$dt) {
    $diff = (Get-Date) - $dt
    if ($diff.TotalHours -lt 1) { return "$([int]$diff.TotalMinutes)m ago" }
    if ($diff.TotalDays -lt 1) { return "$([int]$diff.TotalHours)h ago" }
    return "$([int]$diff.TotalDays)d ago"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host " EVOLVE .claude — 强制审计（跳过 = 违规）" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "你必须对以下每一项给出【已更新: ...】或【无需更新: 原因】。" -ForegroundColor Yellow
Write-Host "禁止全部跳过。如果本次任务产生了任何用户反馈、纠正、有效方案或教训，" -ForegroundColor Yellow
Write-Host "必须至少更新一项。空交付 = 违规。" -ForegroundColor Yellow
Write-Host ""

# --- 1. Memory ---
Write-Host "## [1/3] Memory (memory/)" -ForegroundColor Cyan
$memDir = Join-Path $ClaudeRoot 'memory'
if (Test-Path $memDir) {
    $memFiles = Get-ChildItem $memDir -Filter '*.md' -File | Sort-Object Name
    foreach ($f in $memFiles) {
        $lines = (Get-Content $f.FullName -Encoding UTF8).Count
        $mod = Format-RelTime $f.LastWriteTime
        Write-Host "  $($f.Name)  ($lines lines, modified $mod)"
    }
} else {
    Write-Host "  [!] memory/ 目录不存在" -ForegroundColor Red
}
Write-Host ""
Write-Host "  审计项：" -ForegroundColor White
Write-Host "  (a) 用户在本次任务中是否纠正了你的做法？→ 写入 patterns.md 反面教训" -ForegroundColor DarkGray
Write-Host "  (b) 本次任务是否发现了可复用的有效方案？→ 写入 patterns.md 有效方案" -ForegroundColor DarkGray
Write-Host "  (c) 用户是否表达了新偏好或工作流变更？→ 写入 profile.md" -ForegroundColor DarkGray
Write-Host ""

# --- 2. Skills ---
Write-Host "## [2/3] Skills (skills/)" -ForegroundColor Cyan
$skillsDir = Join-Path $ClaudeRoot 'skills'
foreach ($group in @('blocking', 'engineering')) {
    $groupDir = Join-Path $skillsDir $group
    if (-not (Test-Path $groupDir)) { continue }
    $skillDirs = Get-ChildItem $groupDir -Directory | Sort-Object Name
    foreach ($dir in $skillDirs) {
        $sf = Join-Path $dir.FullName 'SKILL.md'
        if (Test-Path $sf) {
            $mod = Format-RelTime (Get-Item $sf).LastWriteTime
            Write-Host "  [$group] $($dir.Name)  (modified $mod)"
        }
    }
}
Write-Host ""
Write-Host "  审计项：" -ForegroundColor White
Write-Host "  (a) 本次读取的技能是否有错误/遗漏需修正？→ 直接编辑 SKILL.md" -ForegroundColor DarkGray
Write-Host "  (b) 本次任务是否形成了可复用技术模式（出现 2+ 次的开发模式）？→ 考虑新建技能" -ForegroundColor DarkGray
Write-Host ""

# --- 3. Scripts ---
Write-Host "## [3/3] Scripts (scripts/)" -ForegroundColor Cyan
$scriptsDir = Join-Path $ClaudeRoot 'scripts'
if (Test-Path $scriptsDir) {
    $scripts = Get-ChildItem $scriptsDir -Filter '*.ps1' -File | Sort-Object Name
    foreach ($s in $scripts) {
        $mod = Format-RelTime $s.LastWriteTime
        Write-Host "  $($s.Name)  (modified $mod)"
    }
} else {
    Write-Host "  [!] scripts/ 目录不存在" -ForegroundColor Red
}
Write-Host ""
Write-Host "  审计项：" -ForegroundColor White
Write-Host "  (a) 本次运行的脚本是否有 bug？→ 直接修复" -ForegroundColor DarkGray
Write-Host "  (b) 是否有新的可复用自动化场景？→ 创建脚本" -ForegroundColor DarkGray
Write-Host ""

Write-Host "========================================" -ForegroundColor Red
Write-Host " 逐项回应后执行更新。保持通用性与简洁性。" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

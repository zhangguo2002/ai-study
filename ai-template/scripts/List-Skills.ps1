# List-Skills.ps1
# 扫描 skills/ 两级子目录，解析每个 SKILL.md 的 YAML frontmatter name + description，输出分组技能树。
# 用法：pwsh -File List-Skills.ps1 [-SkillsRoot <path>]

param(
    [string]$SkillsRoot = (Join-Path $PSScriptRoot '..' 'skills')
)

$SkillsRoot = Resolve-Path $SkillsRoot

$groupLabels = @{
    'blocking'    = 'BLOCKING（迭代模式 — 每次开发任务必读）'
    'engineering' = '工程技能'
}

$groupOrder = @('blocking', 'engineering')

foreach ($group in $groupOrder) {
    $groupDir = Join-Path $SkillsRoot $group
    if (-not (Test-Path $groupDir)) { continue }

    $label = if ($groupLabels.ContainsKey($group)) { $groupLabels[$group] } else { $group }
    Write-Host ""
    Write-Host "## $label" -ForegroundColor Cyan

    $skillDirs = Get-ChildItem $groupDir -Directory | Sort-Object Name
    foreach ($dir in $skillDirs) {
        $skillFile = Join-Path $dir.FullName 'SKILL.md'
        if (-not (Test-Path $skillFile)) { continue }

        $content = Get-Content $skillFile -Raw -Encoding UTF8
        $name = $dir.Name
        $description = ''

        if ($content -match '(?s)^---\s*\r?\n(.+?)\r?\n---') {
            $frontmatter = $Matches[1]
            if ($frontmatter -match '(?m)^name:\s*(.+)$') {
                $name = $Matches[1].Trim()
            }
            if ($frontmatter -match '(?m)^description:\s*(.+)$') {
                $description = $Matches[1].Trim()
            }
        }

        Write-Host "  - $name : $description"
    }
}

Write-Host ""

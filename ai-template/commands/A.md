# Always keep in mind

Absolute Precision vs. Efficiency & Extreme Perfection: Absolute Precision

Verbose or Over-Engineered Additions vs. Necessary & Sufficient Additions: Necessary & Sufficient Additions

Untested or Unguided Delivery vs. Verified, Visual & Guided Delivery: Verified, Visual & Guided Delivery

# Core Mandate

Using README: **BLOCKING**: Before entering the Write phase of ANY Mode, discover README files by walking from the task's target directory upward to the project root AND downward into immediate subdirectories, collecting every `README.md` (or `README.*`) found along these paths. MUST read all discovered READMEs in full and inject their knowledge into Context. After implementation, if any change alters behavior, API, structure, or usage documented in a discovered README, MUST update that README to reflect the change. Creating new modules/directories that lack a README is permitted only if the parent README already covers them; otherwise, draft a new README. Ignoring a relevant README — whether for reading or updating — is a violation.

Using Memory: At the very start of any session, run `pwsh -File <Cloud>/.claude/scripts/Read-Memory.ps1` to load persistent memory into Context. After completing a task, if a **reusable, general** insight was gained (user preference, effective pattern, or lesson learned), append a one-line bullet to the matching file in `<Cloud>/.claude/memory/` (dedup: skip if already recorded). Task-specific details belong in Record files, not memory.

Using Skill: At the very start of any session, run `pwsh -File <Cloud>/.claude/scripts/List-Skills.ps1` to obtain the full Skills 索引 and print the **Skill Tree**. **BLOCKING**: Before entering the Write phase of ANY Mode, match the current task's domain against the printed skill names, then MUST read every matching `SKILL.md` in full (path: `<Cloud>/.claude/skills/<blocking|engineering>/<skill>/SKILL.md`) and inject its rules into Context. Writing without first reading applicable skills is a violation.

Evolving .claude: **BLOCKING**: After completing ANY task, run `pwsh -File <Cloud>/.claude/scripts/Evolve-Claude.ps1`. Read the checklist output, then for EACH numbered audit item, produce exactly one of: **【已更新: {file} — {one-line diff}】** or **【无需更新: {reason}】**. User corrections, feedback, and effective patterns discovered during the task are the PRIMARY triggers — if any exist, at least one memory/skill update is mandatory. All changes MUST preserve generality and conciseness — no task-specific bloat. Ref [AgentSkill](../agent-skill/AgentSkill.md) for new skills. Skipping the script, giving empty responses, or ignoring user corrections is a violation.

# Mode

> Choose based on task requirements. Each mode defines its Read (gather context) and Impl (produce output) phases with applicable tools.

RD (R&D) => Read + Impl + Validate

Review => Read + Audit + Impl + Fix

Markdown => Read + Impl + Sort + Validate

# Tool

> Invoked when their condition is met within the current Mode, not universally.

**[CoreTool](../tools/CoreTool.md)** | Depend · Study · Xray — 核心分析工具集，按需调用，贯穿所有 Mode

Audit => Post-write => When a deep architectural review is required, thoroughly verify the content/code, audit specified sections for architecture compliance and integration, and flag any required fixes with clear explanations.

Fix => Write => When a bug has been identified and confirmed for repair after inquiry and approval, analyze its root cause and required changes. Then, switch to RD Mode and inject this analysis as a new repair task into Context, explicitly delegating the actual writing and implementation work to RD Mode.

Sort => Write => When writing headings or when existing headings are disordered, sort same-level headings alphabetically with key sections (such as Introduction, Conclusion, or specified priority sections) placed first.

Validate => Post-write => When content is added or modified, check for compilation errors, code/syntactic redundancy, encoding, logic, and parameter usage.

# Code Repository Path (Current path is the document repository)

### MiniMayhem 项目

D:\111project\MiniMayhem\ => [README](file:///D:/Project/MiniMayhem/docs/whisper554/README.md) <必读！系统核心框架文件！>

### deme 项目

D:\Project => [README](file:///D:\Project\deme\README.md) <必读！核心框架索引！>
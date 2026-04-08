---
name: git
description: 自动化 Git 提交工作流，覆盖仓库检测、提交历史查询、暂存变更分析与推送。当用户说"提交"、"commit"、"push"时使用。
---

# Steps

1. If a path is provided, locate its Git repository root using `git -C <path> rev-parse --show-toplevel`; otherwise, use the current directory by default.

2. If missing, query the current user's commit history (limit to the last 45 commits) to generate a relevant title and prompt for confirmation or an alternative.

3. Review each staged change individually (git diff --cached), deeply analyze the intent and impact, then craft a commit message accordingly.

4. To commit the staged changes, in case of the '.git/COMMIT_EDITMSG': Permission denied error, simply remove that file and proceed with the commit.

5. `git push`

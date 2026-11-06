# 16. Private packs

The plugin ships the **system** (process, departments, gates, rubrics, checks, sources). An owner can add a **private pack** on top: their own craft skills, agents, taste ledger, style library and lessons, kept in a private folder or repo that never ships with the plugin.

## How a pack connects
- List it in the workspace `profile.md` under `private_packs:` (a path, plus the files to read first, for example its map file and taste ledger). The session-start hook prints the line, so every session knows the pack exists.
- A pack can be a plain folder, a private git repo, or a second Claude Code plugin from a private marketplace (the paid "Pro pack" route for the open-core model: access by GitHub collaborator invite).

## Precedence
1. The owner's words in the current conversation.
2. The workspace `profile.md` rules and the run's core file (for example `brand-core.md`).
3. Private pack rules, taste and craft skills.
4. Harness defaults (this repo).
The harness still decides **process**: gates, approvals, evidence rules, QA panel and logging apply whichever craft skill does the work.

## What never crosses
- Pack content never enters this public repo (validator lint: no personal names, private paths or employer names in tracked files).
- One context never reads another's folders: a studio run does not read employer runs, a brand run does not read episode folders.
- Taste is written only from the owner's live words.

# memory — what the studio has validated

Five classes, kept apart ([docs/03-context-and-memory.md](../docs/03-context-and-memory.md), `policies/memory-policy.yaml`).

| File or folder | Class | Writer |
|---|---|---|
| `runs/<run-id>/STATUS.md`, `decision-log.md` | task state | the agent working the run |
| `studio-scopes/` | approved studio canon | memory-curator, after the owner's yes |
| `client-scopes/` | approved client canon and client preferences | memory-curator, after the owner's yes |
| `approved-lessons.md` | validated lessons (two separate real projects) | memory-curator, after the owner's yes |
| `lesson-candidates.md` | single-observation candidates | memory-curator |
| `rejected-or-expired.md` | wrong, superseded or overdue assumptions | memory-curator |

## Rules in one place
- **Promotion** to `approved-lessons.md` needs evidence from **two separate real projects** plus the owner's yes. Demo, fictional, same-client repeats and employer-context evidence do not count toward studio lessons.
- **Contexts never mix**: `studio`, `client:<name>`, `employer`, `demo`.
- The taste ledger (workspace `taste/`, or a private pack listed in the workspace profile.md (if any)) and any pack `lessons/` are **read-only** from here.
- Never store secrets, tokens, cookies, env values, employer-only data, or unverified claims written as facts.
- Every scope file carries a `review_by` date; overdue items move to `rejected-or-expired.md`.

Current state (2026-11-04): empty by design. No real project has run yet, so nothing is promoted.

# 00 — Charter and scope

## Source of truth
`~/creative-os/CHARTER.md` (18 Oct 2026) is the highest-priority document. Read it before anything here. When this repo and the charter disagree, the charter wins and the conflict is flagged to Ashish. This repo never copies the charter; it links to it, because a copy goes stale.

What the charter fixes, in one line each:
- The studio makes anything visible, in any style, for any domain. **No house style.**
- Style is derived from the client's idea, brand, product, audience and moment. **The client or project system outranks generic taste and tool defaults.**
- Quality bar: zero AI slop, real references only, measured QA, evidence over assertion.
- Two contexts, kept apart: `studio`, `client:<name>`, `employer`. A fourth value, `demo`, marks fictional proof work.
- The studio's own brand is **not decided** (charter §9). This harness holds no brand identity and never assumes one.
- No social account is linked, so content is prepared and Ashish publishes it (charter §10).

## What Studio Harness v1 is
A Claude Code-native, local-first, evidence-led operating contract for: content creation, AI film production, social-media strategy, motion, 3D and client delivery. It is **files, not a platform**: Markdown, YAML, CSV and shell validators.

| Layer | Folder | Purpose |
|---|---|---|
| Rules | `docs/`, `policies/` | what must hold, for humans and agents |
| Roles | `agents/` | ten role cards: mission, limits, handoff |
| Procedures | `skills/` | nine task procedures that route to creative-os skills |
| Shapes | `templates/` | every artifact has a fixed form |
| Task state | `runs/` | one folder per project, validated |
| Memory | `memory/` | approved canon, client scopes, validated lessons |
| Checks | `scripts/` | `validate-harness.sh` and two ledger/run checkers |

## In scope (v1)
- A brief-to-closeout loop with human gates ([01-operating-model.md](01-operating-model.md)).
- Staged tool policy and an approval record for every gated action ([04](04-tool-and-permission-policy.md), [07](07-publishing-and-approval-policy.md)).
- Evidence, source and rights ledgers with machine checks ([05](05-verification-and-qa.md), [06](06-source-rights-and-licensing.md)).
- Research rules for trends and competitors ([08](08-trend-and-competitor-research.md)).
- AI-film and Blender pipelines as written procedures ([09](09-ai-film-production-pipeline.md), [10](10-blender-cinematography-pipeline.md)).
- A fictional demo run that proves the checks work.

## Out of scope (v1)
- Installing, updating or connecting any tool, plugin, MCP, model or account.
- Spending credits, calling paid APIs, publishing, sending messages, logging in.
- A database or vector memory (Markdown/YAML/CSV/shell validation comes first).
- A generic "super agent" swarm. One Director decides; specialists research, build or critique.
- Replacing creative-os. This repo adds a contract around it and routes to its skills.
- Any studio brand, identity, name or positioning decision.

## Definition of done for v1
1. `scripts/validate-harness.sh` passes.
2. Every internal link and path resolves.
3. Anything unknown is labelled `[TO VERIFY]`; no integration is claimed that was not verified.
4. The first real project can start with one command ([README](../README.md)).

## Who decides what
Ashish decides brand, client, publishing, licensing, legal, financial and account matters, and picks the route. The Director agent prepares and records; it does not decide those. See [02-agent-roles.md](02-agent-roles.md).

# 14 — Channel measurement and learning

A new channel has no data, so measurement is planned first and data enters later, from real posts, with a source. The plan lives in `channel-metrics.md` ([template](../templates/channel-metrics.md)); reviews live in `reviews/` ([template](../templates/channel-review.md)). Enforced by `scripts/check-channel-plan.sh`.

## What the plan must contain
| Part | Requirement |
|---|---|
| Metric definitions | at least 4, each with a definition, source, cadence, type and the decision it informs; at least one **packaging** and one **retention** metric |
| Comparative signal definition | when a post may be called an outlier, and nothing looser |
| Decision rules | at least 3, each with a minimum of 5 posts before it may apply |
| Review cadence | when reviews happen and what each may change |
| Own-channel observations | empty while the channel has zero posts |
| Honest limits | what public data cannot tell us and how the plan copes |

Every pillar, format and calendar idea names a metric id (M1, M2, …) as its success metric. Success metrics are hypotheses to test, never promised numbers.

## Signals, kept apart
| Type | Shows | Evidence needed |
|---|---|---|
| Packaging | what earned the click or tap: views against the channel's own median, click or tap-through where the owner supplies it | public page or owner analytics |
| Retention | what held attention: watch time, average view duration, retention curve | **owner analytics only**; a packaging number is never reported as retention |
| Growth | followers, subscribers, reach | owner analytics |
| Engagement | likes, comments, saves, shares | public page or owner analytics |
| Production | effort against estimate, throughput, QA fail rate | the make logs |

No account is linked, so retention and growth numbers arrive as analytics screenshots or exports that the owner supplies. Each observation records its source and date.

## Comparative signal and "outlier"
Before any post is called an outlier, the plan defines the comparison, for example: views at least 2 times the median of this channel's previous 10 posts, with n of 10 or more. Until that many posts exist, no post is an outlier. For competitors the same rule applies (a ratio against that channel's own median with its sample size). Any statement in a channel plan that a post went viral or outperformed needs a tagged claim (OBSERVED or INFERRED, metric, ratio basis, sample size, platform, date, source id; format in [08](08-trend-and-competitor-research.md)). Without the tag it is rejected; the literal word inside a source title, quoted caption, creator name or URL is allowed.

## Honest numbers
- Zero posts: no audience data, no tested hooks, no observations, no reviews, no `published_by_owner` rows. The validator rejects each.
- Metrics are as of an access date; they change.
- `unknown` is written for a number that cannot be found. It is never estimated or back-filled.
- Platform rules and algorithm claims are `[TO VERIFY]` against the official page, with the date seen.

## The review loop
1. **Collect** real numbers from the owner's analytics for the period; record each in the observations table with its source.
2. **Compare** predictions with observations, hypothesis by hypothesis, using the comparative signal definition.
3. **Verdict:** `supported` or `refuted` only with at least 5 posts of evidence, otherwise `inconclusive`. Inconclusive is a normal and honest answer for a young channel.
4. **Decide** using the decision rules. Retire, repeat or adjust one thing at a time so the cause stays readable.
5. **Re-approve** any change to a locked item: positioning, pillars and formats, visual direction or calendar each need a new approval row before the change applies. Edits inside the unlocked material (ideas, hooks, packaging drafts) do not.
6. **Record** learning candidates for the memory-curator.

Review files carry `posts_in_scope` (at most the posts published), the period, a hypothesis table with n and verdict, what changes, and approvals needed. The validator rejects a review for a channel with zero posts, a verdict of supported or refuted below 5 posts, and a scope larger than the posts published.

## Learning and memory
What one channel teaches is a **lesson candidate**, not a studio lesson ([03](03-context-and-memory.md)). It reaches `memory/approved-lessons.md` only after two separate real projects confirm it and the owner says yes. A channel's own metrics belong to that channel's run and its client or studio scope and never enter another context.

## Paid and automated measurement
vidIQ and similar tools are paid and never automatic: a quote, then an approved `paid_generation` row, then a recorded result. Their scores are hints, not proof. Connecting an analytics account is an `account_connection` approval and is disabled in v1.

## Cadence suggestion (adjust in the plan)
A light check after each post (production metrics, QA notes), a review after the first 10 posts, then every 10 posts or 30 days, and a 90-day review that closes the first strategy. Until 5 posts exist, reviews are about the production system, not the audience.

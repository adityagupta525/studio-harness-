# Platform knowledge: YouTube + Instagram

**Last verified 2026-11-06; facts older than 30 days must be re-read before quoting.**

Used by youtube-strategist, instagram-strategist, analytics-analyst, channel-setup-lead and growth-chief. Tags: **[V]** read on the official page · **[W]** widely reported, or seen only in a search snippet or secondary source · **[U]** unverified. "Date seen" for every row is 2026-11-06 unless the row says otherwise. Re-verify any [W] or [U] row before promising it to the owner or a client. When a re-read changes a row, update the row, its tag and the date at the top, and note the change in the run's `sources.csv`.

---

## 1. Fact tables

### A1. YouTube: how recommendations work
| Claim | Source URL | Tag | Note |
|---|---|---|---|
| Recommendations use "viewing behaviour, likes, dislikes, subscriptions and feedback, including from satisfaction surveys"; also channel "reputation and quality"; external evaluators gauge quality | https://www.youtube.com/howyoutubeworks/product-features/recommendations/ | [V] | Page names no weights, no CTR, no "valued watch time". No date on page |
| Watch Next uses "watch history, broader viewer trends and current video topics" | same | [V] | |
| "the algorithm is constantly evolving to better follow the audience"; a sudden drop is "usually for another reason"; "topics can be seasonal" (visible year-on-year, not month-on-month); "A big spike can be followed by a big drop" | https://blog.youtube/creator-and-artist-stories/renes-top-five-march-4-2024/ | [V] | Creator Liaison, 4 Mar 2024 |
| Shorts feed has no thumbnails/impressions; the comparable signal is views vs swipe-aways; an underperforming Short "won't go much beyond" its initial views | same | [V] | |
| "The algorithm follows the audience, so please the audience" (Liaison, Shorts series) | https://www.tubefilter.com/2024/08/26/rene-ritchie-shorts-creator-faqs/ | [W] | Wording from coverage; original Short not watched |
| Recommendations are viewer-by-viewer and creator-agnostic (YouTube Discovery lead on Creator Insider) | https://www.vidcon.com/anaheim/speaker/9502/ (bio only) | [W] | Only third-party summaries found; video not watched |
| 2016 paper: two-stage system, candidate generation then ranking (Covington, Adams, Sargin, RecSys 2016) | https://research.google/pubs/deep-neural-networks-for-youtube-recommendations/ | [V] | Abstract page only. "Ranks on expected watch time, not click probability" is in the paper body = [W] |
| Search ranks on relevance ("title, tags, description, and video content match"), engagement ("watch time of a particular video for a particular query") and quality (expertise, authoritativeness, trustworthiness); no paid placement; personalised by history | https://support.google.com/youtube/answer/16090438 | [V] | Old howyoutubeworks search URL now redirects here |
| Test & Compare: up to 3 titles, thumbnails, or title+thumbnail; **winner = highest watch time**, not CTR; desktop Studio only; advanced features required; not for Shorts, scheduled lives, kids/mature/private; results "Winner / Performed Same / Inconclusive"; runs up to 2 weeks | https://support.google.com/youtube/answer/13861714 | [V] | Title testing announced Made on YouTube, 16 Sep 2025 |
| Made on YouTube 2025: Ask Studio, title A/B testing, Collaborations (up to 5 collaborators), lip-sync auto-dubbing (20 languages), likeness detection open beta for YPP | https://blog.youtube/news-and-events/youtube-studio-made-on-youtube-2025/ | [V] | 16 Sep 2025 |
| Inspiration tab is being deprecated "Starting August 2026"; use Ask Studio instead | https://support.google.com/youtube/answer/15575509 | [V] | 2026 change |
| Hype: YPP channels with 500–500,000 subs; viewers hype a video within 7 days of publish, "limited number of times at no cost"; weekly country leaderboard; 39 countries | https://support.google.com/youtube/answer/15509925 | [V] | Global launch reported 26 Aug 2025. Point values = [W], not on page |
| AI / altered content: must disclose realistic synthetic or altered content (real person saying/doing what they didn't, altered real events/places, realistic fake scenes, AI music as main focus) via the "AI use" question in Studio. Not needed for unrealistic/animated content, beauty filters, captions, AI-assisted scripts/titles/thumbnails, own voice clone | https://support.google.com/youtube/answer/14328491 | [V] | YouTube may auto-label (its own GenAI tools, C2PA metadata, detection) |
| Disclosure alone doesn't limit a video's audience or monetization; repeated non-disclosure can mean forced labels, removal, YPP suspension | same | [V] | |
| "Inauthentic content" (renamed from "repetitious content" on 15 Jul 2025): templated, repetitive or mass-produced content, incl. slideshows/scrolling text with minimal narrative, and AI from generic templates that looks mass-produced, is not monetizable | https://support.google.com/youtube/answer/1311392 | [V] | YouTube calls it "a minor update"; this content "has always been ineligible" |
| Reused content: repurposing without significant original commentary or modification is not monetizable "even if you have permission"; reaction/critical review with commentary is allowed; violations can demonetize the whole channel | same | [V] | Separate from copyright |
| Shorts up to 3 min (square or vertical) since 15 Oct 2024; any active Content ID claim on a >1 min Short blocks it globally | https://support.google.com/youtube/answer/15424877 | [V] | Use 16:9 to keep a video long-form |

### A2. YouTube: views and analytics definitions
| Claim | Source URL | Tag | Note |
|---|---|---|---|
| Shorts views counted on every start or replay from 31 Mar 2025, with no minimum watch time; the old metric is now "Engaged views"; YPP and Shorts rev share use engaged views | https://support.google.com/youtube/answer/10059070 | [V] | |
| **From 24 Aug 2026 all formats (long-form, live, Shorts) count a view from the first frame**, autoplay included; engaged view = "clicking to watch or watching past the initial seconds"; "no change to recommendations"; CTR, AVD, retention still based on engaged views | https://blog.youtube/inside-youtube/engaged-views-youtube-explained/ | [V] | Blog dated 19 Aug 2026. Old videos keep their totals = [W] |
| YPP earnings stay on engaged views + engaged watch hours; eligibility on qualified views; low-quality playbacks (multi-device/tab) may be discarded | https://support.google.com/youtube/answer/2991785 | [V] | |
| Impressions CTR: "Half of all channels and videos" sit at 2–10%; CTR naturally drops as impressions grow (Home); compare videos over the long term by traffic source; high CTR + low AVD is a clickbait warning | https://support.google.com/youtube/answer/7628154 | [V] | End screens and external sites don't count as impressions |
| Unique viewers = estimated viewers in the date range, from engaged views | https://support.google.com/youtube/answer/9314486 | [V] | New/casual/regular/returning definitions not on this page |
| Retention: AVD = "Average minutes watched among those who stayed to watch"; Intro = % still watching at 30 s; Top moments, Spikes (rewatch/share), Dips (skips); typical retention compares with your 10 latest videos of similar length; key moments need ≥60 s video and ≥100 views; data lags 1–2 days | https://support.google.com/youtube/answer/9314415 | [V] | Video level only |
| Traffic sources: Browse features (Home, subs, Watch Later), Suggested, YouTube search (terms card), Shorts (vertical viewer), Playlists, Channel pages, Notifications, End screens/cards, External, Direct/unknown | https://support.google.com/youtube/answer/9314355 | [V] | |
| RPM = your revenue after YouTube's share per 1,000 views (ads, memberships, Premium, Supers); CPM = advertiser cost per 1,000 ad impressions before revenue share; playback-based CPM = per 1,000 playbacks with an ad | https://support.google.com/youtube/answer/9314357 | [V] | RPM, not CPM, is what the owner earns |

### A3. YouTube: search, metadata, channel setup
| Claim | Source URL | Tag | Note |
|---|---|---|---|
| Tags "play a minimal role in your video's discovery"; useful if the topic is commonly misspelled; title, thumbnail, description matter more; excessive tags in descriptions = spam policy | https://support.google.com/youtube/answer/146402 | [V] | |
| Description max 5,000 characters; first lines show before "more"; put "1-2 main words" in both title and description; use the Research tab and Keyword Planner | https://support.google.com/youtube/answer/12948449 | [V] | |
| Hashtags: in title/description; up to 3 "most engaging" shown above the title; no spaces; **>60 hashtags = all ignored**; over-tagging can remove the video from uploads or search; must be relevant | https://support.google.com/youtube/answer/6390658 | [V] | |
| Chapters: first timestamp 00:00, ≥3 timestamps ascending, each ≥10 s; manual chapters override auto chapters | https://support.google.com/youtube/answer/9884579 | [W] | Search snippet of the official page; not opened |
| Profile: up to 14 links on the Home tab; channel name and handle each changeable twice per 14 days | https://support.google.com/youtube/answer/2972003 | [V] | |
| Banner: min 2048×1152 (16:9), safe area 1235×338, recommended 2560×1440, ≤6 MB; profile picture renders 98×98, ≤15 MB, JPG/PNG/BMP/static GIF | https://support.google.com/youtube/answer/12950272 and https://support.google.com/youtube/answer/10456525 | [W] | From official-page snippets; pages not opened |

### A4. YouTube: monetization (YPP)
| Claim | Source URL | Tag | Note |
|---|---|---|---|
| Today: 1,000 subs + 4,000 qualified public watch hours (12 mo) **or** 1,000 subs + 10M qualified Shorts views (90 days); Shorts-feed hours don't count toward 4,000 | https://support.google.com/youtube/answer/72851 | [V] | |
| Fan funding, Creator Partnerships (BrandConnect) and Shopping tier: 500 subs + 3,000 watch hours (12 mo) or 3M Shorts views (90 days); unchanged in 2027 | https://support.google.com/youtube/answer/12843009 | [V] | A "3 public uploads in 90 days" condition = [W] (not on this page) |
| **From 1 Feb 2027, new YPP applicants need 1,000 subs + 8,000 qualified watch hours (365 days) or 20M qualified Shorts views (90 days)**; existing members not affected; accept new terms by 31 Jan 2027 | same | [V] | Biggest 2027 change; plan launch timelines around it |
| From 1 Feb 2027 a channel stays "active" with 1,000 watch hours/365 days, or 1M Shorts views/90 days, or 2 long-form or 5 Shorts uploads every 90 days; an extended 90-day window to restore | same | [V] | |
| From 1 Feb 2027, earning from the Shorts Creator Pool needs ≥10M qualified Shorts views in the last 90 days (measured to the 15th of the prior month); missing it doesn't remove a channel from YPP | https://support.google.com/youtube/answer/12504220 | [V] | Hits small Shorts-only channels hard |
| Shorts: creators keep 45% of allocated pool revenue whatever the music; music reduces the pool share (1 track = half, 2 tracks = a third); payout by share of engaged views | same | [V] | |
| New: Targeted Shorts ads (≤5 channels) pay a direct 45%; Premium Lite expands to all Premium countries; Shorts incentive programs (Shopping bonuses, brand-deal credits, trend boosts) | https://support.google.com/youtube/answer/12843009 | [V] | Premium % wording is ambiguous on the page; re-read before quoting |
| Features named: "Watch Page Ads, Shorts Feed Ads, Memberships, Supers, and more"; each needs its module terms accepted | https://support.google.com/youtube/answer/72851 | [V] | Super Thanks/Chat/Stickers = Supers |

### B1. Instagram: ranking signals
| Claim | Source URL | Tag | Note |
|---|---|---|---|
| "Instagram doesn't have a singular algorithm"; each surface (Feed, Stories, Explore, Reels) has its own ranking | https://about.instagram.com/blog/announcements/instagram-ranking-explained/ | [V] | 31 May 2023; still the fullest official explainer |
| Feed: your activity, info about the post (how fast it gets likes/comments/shares/saves), info about the poster, your interaction history. Stories: viewing history, engagement history, closeness | same | [V] | |
| Explore: post popularity matters "much more" than in Feed; key predicted actions = likes, saves, shares | same | [V] | |
| Reels: key predicted actions = reshares, watching through, likes, visiting the audio page; reposted, low-res, watermarked, muted, bordered or mostly-text reels get less reach | same | [V] | |
| Account Status shows recommendation eligibility; breaking Recommendation Guidelines lowers recommendation, not removal; "shadowban" is not intended | same | [V] | |
| Reels Chaining system card (updated 11 Nov 2025) predicts: watching <3 s, watching more than 95% of viewers of similar-length reels, commenting, resharing, sharing off-Instagram, following the author, using the audio, tapping "Interested" | https://transparency.meta.com/features/explaining-ranking/ig-reels-chaining/ | [V] | Signals listed but unranked |
| Head of Instagram (Jan 2025): top 3 signals are **watch time, likes, sends**; track average watch time, likes per reach, sends per reach; likes count a bit more with followers, sends with non-followers | https://www.socialmediatoday.com/news/instagram-shares-algorithm-insights-2025/738034/ (original: https://www.instagram.com/p/DFFyRp-pINJ/) | [W] | Coverage 22 Jan 2025; original video not watched |
| Originality (Reels 2024; **photos and carousels from 30 Apr 2026**): accounts that mostly repost lose recommendation eligibility; 75% of US recommendations now from original posts; regain eligibility if most posts in the last 30 days are original; check/appeal in Account Status | https://creators.instagram.com/blog/rewarding-original-creators-on-instagram | [V] | Followers still see the posts |
| Unoriginal = copied, or only borders/watermarks/speed changes/credits added, or screenshots; original = own capture, or third-party content meaningfully changed (commentary, voiceover, joke, context). Test: remove your contribution; does the post look the same? Curate via native Repost | https://creators.instagram.com/original-content-guidelines/ | [V] | |
| Trial reels (10 Dec 2024): shown to non-followers first, not on the grid; metrics after ~24 h; optional auto-share to followers if it performs in the first 72 h | https://creators.instagram.com/blog/instagram-trial-reels | [V] | Eligibility (public pro account, 1,000+ followers) = [W]; help page is a JS wall |
| Hashtags capped at **5 per post/reel** (announced by @creators on Threads, 18–19 Dec 2025, gradual rollout); Instagram says hashtags don't increase reach, only describe the post | https://www.socialmediatoday.com/news/instagram-implements-new-limits-on-hashtag-use/808309/ (original: https://www.threads.com/@creators/post/DSalXGPCWM4/media) | [W] | Threads post not opened |
| "Your Algorithm" topic controls (Dec 2025): viewers can see and edit the topics feeding their Reels | https://www.socialpilot.co/blog/instagram-reels-algorithm | [U] | Only marketing-blog coverage found |

### B2. Instagram: formats, profile, insights, monetization
| Claim | Source URL | Tag | Note |
|---|---|---|---|
| Reels up to 3 minutes (from 90 s), Jan 2025; Edits app launched (iOS, 13 Mar 2025) | https://www.storyboard18.com/digital/instagram-extends-reels-to-three-minutes-and-updates-profile-layout-54043.htm | [W] | Original post not opened |
| Profile grid moved to 3:4 tall previews (Jan 2025); native 3:4 uploads later (≈May 2025); design at 4:5 (1080×1350) and keep the key content inside a centred 3:4 area | https://www.engadget.com/social-media/instagrams-experimental-profile-grid-has-rectangular-images-instead-of-squares-160007086.html | [W] | Pixel values differ across guides (1012×1350 vs 1015×1350) |
| "Views" replaced impressions and plays as the main metric across all formats (API switch 21 Apr 2025); counts repeats; impressions remain only in Ads Manager | https://docs.emplifi.io/platform/latest/home/instagram-insights-metrics-deprecation-april-2025 | [W] | Official Insights help is a JS wall |
| Reels skip rate = % of viewers who skip within the first 3 s; retention chart added (Aug 2025); skip rate and share rate extended to posts (Apr 2026) | https://www.socialsamosa.com/news-2/instagram-retention-chart-skip-rate-new-performance-metrics-reels-9730992 | [W] | |
| Monetization tools Instagram names: Subscriptions, Partnership ads, Creator Marketplace (branded content), Gifts, Badges, Bonuses (Reels, carousels, single photos) | https://creators.instagram.com/earn-money | [V] | No thresholds stated on the page |
| Subscriptions ≈ 18+, professional account, ~10,000 followers; Gifts ≈ 500 followers + 18+ + pro account; country lists vary | https://influencermarketinghub.com/instagram-subscriptions-gifts/ | [W] | Check in-app Monetization status per account |

---

## 2. Myths to avoid
| Myth | Reality (source) |
|---|---|
| "Tags rank your YouTube video." | Tags "play a minimal role"; title, thumbnail and description matter more. https://support.google.com/youtube/answer/146402 [V] |
| "Stuff 30 hashtags." | YouTube ignores all of them past 60 and may remove the video (https://support.google.com/youtube/answer/6390658 [V]). Instagram caps at 5 and says hashtags don't add reach (https://www.socialmediatoday.com/news/instagram-implements-new-limits-on-hashtag-use/808309/ [W]). |
| "CTR is king; maximise CTR." | CTR falls as impressions grow; Test & Compare picks the winner by **watch time**; high CTR + low AVD = warning. https://support.google.com/youtube/answer/7628154 · https://support.google.com/youtube/answer/13861714 [V] |
| "The algorithm punished me after a drop." | Liaison: drops are "usually for another reason" (seasonality, spike then drop). https://blog.youtube/creator-and-artist-stories/renes-top-five-march-4-2024/ [V] |
| "My views jumped in Sept 2026, so the algorithm is boosting me." | From 24 Aug 2026 every first frame counts as a view; recommendations unchanged. https://blog.youtube/inside-youtube/engaged-views-youtube-explained/ [V] |
| "1,000 subs + 4,000 hours gets anyone into YPP." | For new applicants from 1 Feb 2027 it is 8,000 hours or 20M Shorts views. https://support.google.com/youtube/answer/12843009 [V] |
| "Shorts watch hours count toward 4,000 hours." | They don't. https://support.google.com/youtube/answer/72851 [V] |
| "AI content is demonetized." | Only templated or mass-produced (inauthentic) or reused content is; disclosing AI alone doesn't limit reach or monetization. https://support.google.com/youtube/answer/1311392 · https://support.google.com/youtube/answer/14328491 [V] |
| "Reposting with credit is fine on Instagram." | Credit, watermark, border or speed change is not enough; mostly-repost accounts lose recommendations. https://creators.instagram.com/original-content-guidelines/ [V] |
| "Instagram has one algorithm / shadowbans creators." | There are multiple per-surface systems; check Account Status for eligibility. https://about.instagram.com/blog/announcements/instagram-ranking-explained/ [V] |
| "Cross-post TikToks with the watermark." | Watermarked and low-res reels are less visible. Same source [V] |
| "Ask the Inspiration tab for ideas." | Being deprecated from Aug 2026; use Ask Studio. https://support.google.com/youtube/answer/15575509 [V] |

---

## 3. Source registry (monitoring)
| Name | URL | Type | Trust tier | Refresh | What to extract |
|---|---|---|---|---|---|
| YouTube YPP changes | https://support.google.com/youtube/answer/12843009 | official | 1 | weekly until Feb 2027, then monthly | thresholds, activity rules, revenue shares |
| YouTube YPP overview | https://support.google.com/youtube/answer/72851 | official | 1 | monthly | eligibility, feature list |
| YouTube Shorts monetization | https://support.google.com/youtube/answer/12504220 | official | 1 | monthly | pool rules, 10M rule |
| YouTube engagement metrics / views | https://support.google.com/youtube/answer/2991785 | official | 1 | monthly | view, engaged, qualified definitions |
| YouTube channel monetization policies | https://support.google.com/youtube/answer/1311392 | official | 1 | monthly | inauthentic and reused content |
| YouTube AI disclosure | https://support.google.com/youtube/answer/14328491 | official | 1 | monthly | disclosure triggers, labels |
| How YouTube Works: recommendations | https://www.youtube.com/howyoutubeworks/product-features/recommendations/ | official | 1 | quarterly | named signals |
| YouTube search | https://support.google.com/youtube/answer/16090438 | official | 1 | quarterly | ranking factors |
| YouTube Official Blog | https://blog.youtube/ | official | 1 | weekly | launches, Liaison posts |
| Creator Insider (YouTube staff channel) | https://www.youtube.com/@CreatorInsider | official-adjacent | 1 | weekly | Studio and analytics changes; cite only from a transcript |
| YouTube Liaison | https://www.youtube.com/@YouTubeLiaison | official | 1 | weekly | myth corrections |
| Instagram Creators blog | https://creators.instagram.com/blog | official | 1 | weekly | features, originality, trial reels |
| Instagram original content guidelines | https://creators.instagram.com/original-content-guidelines/ | official | 1 | monthly | originality rules |
| Instagram newsroom | https://about.instagram.com/blog | official | 1 | weekly | ranking explainers |
| Meta Transparency: ranking system cards | https://transparency.meta.com/features/explaining-ranking/ | official | 1 | quarterly | predictions and signals per surface |
| Head of Instagram (Instagram, Threads) | https://www.instagram.com/mosseri/ · https://www.threads.com/@mosseri | official | 1 | weekly | weekly Q&A (login wall: read only in the owner's own browser, read-only) |
| Instagram @creators on Threads | https://www.threads.com/@creators | official | 1 | weekly | policy rollouts (the hashtag cap came here) |
| Social Media Today | https://www.socialmediatoday.com/ | analyst/news | 2 | weekly | fast, links primary posts; verify against them |
| Tubefilter | https://www.tubefilter.com/ | news | 2 | weekly | YouTube creator economy news |
| Paddy Galloway | https://www.youtube.com/@PaddyGalloway | analyst | 2 | monthly | packaging and ideation strategy [W] |
| vidIQ blog | https://vidiq.com/blog/ | analyst/vendor | 3 | monthly | change summaries; vendor bias, verify |
| Film Booth | https://www.youtube.com/@FilmBooth | analyst | 3 | monthly | packaging and title craft [W] |
| Buffer data studies | https://buffer.com/resources/when-is-the-best-time-to-post-on-instagram | data | 2 | quarterly | posting-time data; sample size stated inconsistently on the page |
| Lindsey Gamble | https://www.lindseygamble.com/blog | analyst | 3 | monthly | Instagram and creator-economy tracking |

Trust tiers: 1 = platform's own words · 2 = reliable reporter or analyst, links primary sources · 3 = useful practitioner or vendor, verify claims.

---

## 4. Channel setup checklist + first 30 days (generic)

**YouTube setup**
1. Handle + channel name (each changeable twice per 14 days); description with the 1–2 core keywords; up to 14 links; contact email. https://support.google.com/youtube/answer/2972003 [V]
2. Banner 2560×1440 (key content inside 1235×338), square profile picture, watermark. https://support.google.com/youtube/answer/12950272 [W]
3. Channel trailer for non-subscribers + featured sections (playlists by series). [U: no official page read]
4. Upload defaults: category, language, captions language, description template with a chapters block; answer the "AI use" question per video. https://support.google.com/youtube/answer/14328491 [V]
5. Playlists per series (playlists are a tracked traffic source). https://support.google.com/youtube/answer/9314355 [V]
6. Turn on advanced features (needed for Test & Compare). https://support.google.com/youtube/answer/13861714 [V]
7. Plan YPP: apply before 31 Jan 2027 if near 1,000 subs + 4,000 hours; after that, budget for 8,000 hours or 20M Shorts views. https://support.google.com/youtube/answer/12843009 [V]

**Instagram setup**
1. Professional (Creator) account, public; check Account Status shows recommendation-eligible. https://about.instagram.com/blog/announcements/instagram-ranking-explained/ [V]
2. Bio: one-line promise + link; Highlights per series; grid designed at 4:5 with the subject inside the centred 3:4 area. https://www.engadget.com/social-media/instagrams-experimental-profile-grid-has-rectangular-images-instead-of-squares-160007086.html [W]
3. Originality plan: own capture or clear transformation every post; native Repost only for curation. https://creators.instagram.com/original-content-guidelines/ [V]
4. Max 5 relevant hashtags; put keywords in captions instead. https://www.socialmediatoday.com/news/instagram-implements-new-limits-on-hashtag-use/808309/ [W]

**First 30 days (skeleton; a plan, not a promise of numbers)**
| Week | YouTube | Instagram | Read |
|---|---|---|---|
| 1 | 2 long-form + 3 Shorts on one series; chapters; at most 3 hashtags shown | 3 reels + 1 carousel; 1–2 as trial reels | Retention Intro %, viewed vs swiped away (Shorts) |
| 2 | Test & Compare titles/thumbnails on the long-forms | Trial reels for hook variants; keep winners | Watch time per variant; sends/reach, likes/reach |
| 3 | Double down on the topic with the best AVD; playlist it | Repurpose the best long-form beat into a 30–60 s reel (original edit) | Traffic sources: Browse vs Suggested vs Search terms |
| 4 | Review: CTR by traffic source, typical retention vs last 10 | Skip rate (<3 s), views, accounts reached, follows per reel | Decide series 2; log it in the run |

Rule: compare videos with the channel's own last 10 of similar length, not with other channels (YouTube's own baseline). https://support.google.com/youtube/answer/9314415 [V]

---

## 5. Could not verify or fetch (as of 2026-11-06)
| Item | What happened |
|---|---|
| https://transparency.meta.com/features/explaining-ranking/ig-reels/ | 404; only the Reels Chaining card opened. Feed/Explore/Stories cards not found from the index |
| help.instagram.com (Insights definitions, trial reels, subscriptions) | JS wall. Insights definitions, trial reel eligibility and Subscriptions/Gifts thresholds stay [W] |
| https://www.instagram.com/p/DFFyRp-pINJ/ and the @creators Threads hashtag post | Not opened (login wall likely); claims from coverage = [W] |
| Creator Insider / Liaison / Head of Instagram videos | Not watched; only text sources are cited |
| support.google.com/youtube/answer/9895302 (chapters) | 404; chapter rules taken from a snippet of 9884579 |
| Banner/profile spec pages (12950272, 10456525) | Not opened; spec numbers from search snippets = [W] |
| New / returning / casual / regular viewer definitions | Not found on the pages fetched |
| Channel trailer, featured sections, community posts setup | No official page read |
| Super Thanks / Chat / Shopping / BrandConnect individual rules; Shorts "3 public uploads" for the 500 tier | Not individually verified |
| Instagram Reels safe zones, max upload length beyond 3 min, "Your Algorithm" feature | Only marketing-blog coverage |
| Hype point values, viewer free-hype allowance | Not on the official page |
| Premium Lite revenue % wording | Page wording ambiguous; re-read before quoting |

No paid tools, no logins and no paid API calls were used to build this file.

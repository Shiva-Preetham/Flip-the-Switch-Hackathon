# Flip the Switch: Choosing a Track and an Idea

_Prepared 2026-11-06. Deadline: **Nov 7, 11:59 PM IST**. About 36 hours left._

---

## 1. What the judges want

The judges are WeMakeDevs (they make the shortlist), then a panel from Switch, DevTools Academy and WeMakeDevs. The page lists four criteria with no weights, so this file treats them as equal (25% each).

| Criterion | The judges' question | What they want to see |
|---|---|---|
| **Use of Switch** | Is Switch central, and would the project stop working without it? | Several agents and several people working in one room. The project uses Switch's own features: roles, room instructions, references, room documents, approval requests, agent-to-agent handoff and room links. A chat bot would not be enough. |
| **Technical execution** | Does it run, and could someone clone the repo and reproduce it? | A repo that a stranger can run from start to finish. Include a Switch **template YAML**, setup steps that work, sample data, and no secrets in the repo. Use bundled Mattermost so judges don't need Slack admin access. |
| **Creativity and impact** | Is it a fresh idea that solves a problem a real team has? | A real, painful team workflow, ideally one the judges have lived through. It should not be the most obvious demo, and the value should be clear, for example "this saves X hours" or "this cuts the hand-off delay". |
| **Presentation** | Do the demo video and README make clear how Switch is used? | A 2–3 minute video showing the chat: agents talking to each other, a person approving something, and the result. The README should have an architecture diagram and a section listing the Switch features used. |

**Hard rules:** Switch must be central. The Switch setup and the workflow must be built during the hackathon (Nov 4–7). You must understand your code and be able to explain it.

---

## 2. Track comparison

| | Track 01: Business Workflow | Track 02: Personal or Creative Workflow | Track 03: Core Contribution |
|---|---|---|---|
| Prize | $2,000 (one winner) | $2,000 (one winner) | $100 × top 20 PRs |
| Fit with the judging criteria | **Best.** The criterion "solves a problem a **real team** has" matches business workflows directly. | Weaker. A personal workflow has a harder time showing "real team" impact. | Judged separately, on how useful and well built the PR is. |
| Shows off Switch's main strength (people and agents together) | **Strongest.** Teams, roles and approvals are what Switch is built for. | Medium, since a personal workflow often has only one person. | Not applicable. |
| Feasibility in about 36 hours | Good, if the scope is tight. | Good. | **Blocked.** All 63 `hackathon` issues already have assignees (checked today), so a new contributor can't get assigned before the PR deadline. |
| Expected competition | Probably the most crowded. | Probably less crowded. | Not applicable. |
| Payoff from the work | High. The same project also feeds a blog entry and a Wispr entry. | Medium. | Low ($100) and gated behind assignment. |

### Decision: **Track 01, Best Business Workflow**
- It matches all four judging criteria best, especially "a real team" and "people and AI agents get work done."
- Track 03 is effectively closed to new people because every issue is assigned.
- Track 02 has the same prize, but it is harder to score well on impact.
- **Add-ons with little extra work:** turn the README into a blog post for the **Best Blog** side track (AirPods). If you code by voice with Wispr Flow (promo `WEMAKEDEVS`), you can enter **Code with Wispr** ($500) too. Also post on **#HowISwitch** and star the repo.

---

## 3. Idea comparison (scored 1–10 per criterion, out of 40)

The scores are my estimates. Nobody can calculate a real chance of winning, but a higher score means the idea is better aligned with what the judges are looking for.

| # | Idea | Track | Use of Switch | Tech execution (36h) | Creativity and impact | Presentation | **Total /40** | Crowding risk |
|---|---|---|---|---|---|---|---|---|
| **A** | **Support-to-Ship Bridge** (two linked rooms, support and engineering) | 01 | 10 | 7 | 9 | 9 | **35** | Low–medium |
| B | Bug-to-Merge Room (several agent vendors review each other's work) | 01 | 9 | 8 | 7 | 8 | **32** | Medium |
| C | Incident War Room | 01 | 9 | 8 | 6 | 9 | **32** | **High** (the organizers' own mockup is an incidents chat) |
| D | CVE / Dependency Patch Room | 01 | 8 | 7 | 8 | 7 | **30** | Low |
| E | Release Captain (go/no-go room) | 01 | 8 | 8 | 6 | 7 | **29** | Medium |
| F | Onboarding Buddy Room | 01 | 7 | 9 | 5 | 6 | **27** | Medium |
| G | Async Standup and Blocker Router | 01 | 7 | 8 | 5 | 6 | **26** | Medium |
| H | Writers' Room (creative, on Telegram) | 02 | 7 | 8 | 6 | 7 | **28** | Medium |

---

## 4. Idea details

### A. Support-to-Ship Bridge ⭐ Recommended
**Problem:** A customer reports a bug. Support copies it into an engineering channel. Engineers ask for details again, the fix takes days, and the customer never hears back. Every SaaS team has this hand-off delay between support and engineering.

**Flow:**
1. **#support room:** a support agent (Claude Code), briefed with the product docs as references, answers the ticket. If it decides the problem is a real bug, it writes a structured bug report as a room document.
2. It follows a **room link** to **#engineering** and hands the bug off to `@triage`.
3. **#engineering room:** a triage agent reproduces the bug against the demo repo. A fixer agent (Claude Code) writes a patch on a branch. A reviewer agent from a different vendor (Codex or OpenCode) reviews it.
4. A person on the engineering side gets an **approval request** ("Merge fix for #12?") and approves it.
5. The support agent, back in **#support**, drafts the customer reply. A support person approves it before it is "sent." The loop is closed.

**Switch features used:** two rooms, room links, room instructions, references (repo and docs), room documents (the bug report), shared and exclusive roles (`reviewer`, `support-lead`), handoff between agents, approval requests, agents from several vendors, and a template YAML for one-command setup.

**Why it can win:** Switch is needed at every step, the business problem is one judges will recognize, it's less obvious than "incident bot," and the demo shows a full loop from ticket to fix to reply in about 2 minutes. Starting points: `support-desk.template.yaml` and `triage-pair.template.yaml` in the Switch examples.

**Risk:** Two rooms is more setup than one. **To reduce the risk,** get #engineering working first (B covers that part), then add #support.

### B. Bug-to-Merge Room
In one room, someone files a bug. The triage agent reproduces it, Claude Code fixes it, Codex reviews it (agents from different vendors checking each other), and a person approves the merge. It is solid and feasible but less novel, and it is a subset of A, which makes it a good **fallback** if A runs late.

### C. Incident War Room
An alert arrives. An investigator agent reads the logs, a code agent finds the commit that caused it and proposes a rollback, and the on-call person approves it. An agent holding the exclusive `incident-commander` role then writes a postmortem as a room document. It demos well, but **many teams will build this**, so it is hard to stand out.

### D. CVE / Dependency Patch Room
A scanner agent finds a vulnerable dependency and a patch agent bumps the version and runs the tests. A security reviewer, a person, approves the change. This is real and somewhat fresh, but the "wow" in the video is smaller.

### E. Release Captain
An agent in the exclusive `release-manager` role drafts a changelog from the merged PRs, collects sign-offs from `@reviewer` holders, and asks a person for a go/no-go decision. It is close to Switch's own payments-room example, so it scores lower on novelty.

### F, G, H
These are easier to build but weaker on impact or novelty. H is the best Track 02 option if you prefer that track.

---

## 5. Checklist for the recommended idea (A)

**Use of Switch**
- [ ] README section "Switch features used," with each feature linked to where it appears
- [ ] At least 3 agents (2+ vendors), 2 people, 2 linked rooms
- [ ] At least one real approval request handled by a person in the video

**Technical execution**
- [ ] `switch-template.yaml` and `docker compose` / setup script, using bundled Mattermost
- [ ] A small demo repo with a planted bug and seed tickets
- [ ] `.env.example` with no secrets, plus tested "clone → run in 10 min" steps
- [ ] Test on Windows early. Switch Console's Windows build is early access, so have a fallback such as WSL or a teammate's Mac/Linux machine.

**Creativity and impact**
- [ ] Open the README and video with the pain point ("Support-to-eng hand-off takes days")
- [ ] A before/after number (manual steps or time saved)

**Presentation**
- [ ] A 2–3 minute video showing the real chat, with no long terminal footage
- [ ] An architecture diagram
- [ ] A blog post adapted from the README, for the Best Blog side track

---

## 6. Suggested 36-hour plan
| When | What |
|---|---|
| Nov 6, first 3h | Install Docker and Switch Console, run the quickstart, and get one agent working in Mattermost |
| Nov 6, next 6h | Build the #engineering room: triage, fixer and reviewer agents, plus the approval step (B works at this point) |
| Nov 7, morning | Add #support, the room link and the customer-reply approval (A works at this point) |
| Nov 7, afternoon | Template YAML, test a clean setup, README and diagram |
| Nov 7, evening | Record the video, write the blog post, submit by **11:59 PM IST**, with a buffer of at least 2 hours |

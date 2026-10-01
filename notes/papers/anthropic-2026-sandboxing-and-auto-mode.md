# Claude Code Sandboxing & Auto Mode (permissions)

- **Title:** (a) Beyond permission prompts: making Claude Code more secure and autonomous; (b) How we built Claude Code auto mode: a safer way to skip permissions
- **Authors:** (a) David Dworken, Oliver Weller-Davies; (b) Anthropic
- **Year:** (a) Oct 20, 2025; (b) Mar 25, 2026
- **Link:** (a) https://www.anthropic.com/engineering/claude-code-sandboxing; (b) https://www.anthropic.com/engineering/claude-code-auto-mode
- **Status:** (a) read in full; (b) read through design and results sections

**One-line TL;DR:** Replace approval-fatigued per-action prompts with (a) an OS-level sandbox enforcing **filesystem + network isolation** and (b) a **two-stage, reasoning-blind transcript classifier** that gates risky actions, plus a prompt-injection probe on tool outputs.

**Problem:** Users approve 93% of permission prompts (approval fatigue). `--dangerously-skip-permissions` is unsafe. Real incidents come from overeager behavior (deleting remote branches, uploading auth tokens, prod DB migrations).

**Method:**
- (a) bubblewrap / seatbelt sandbox for bash and subprocesses: cwd-only writes; network via a proxy with a domain allowlist; credentials kept out of cloud sandboxes (a git proxy checks branch and destination). Open-sourced `sandbox-runtime`.
- (b) Tier 1 allowlist / user rules (broad interpreter rules dropped) → Tier 2 in-project edits → Tier 3 transcript classifier (Sonnet 4.6): stage 1 fast single-token filter biased to block, stage 2 CoT on flagged items. Sees **only user messages + tool calls** (assistant text and tool outputs stripped). Fixed template plus customizable environment / block / allow slots (20+ default block rules). Sub-agents get handoff checks.

**Key results:**
- (a) Sandboxing reduced permission prompts by **84%** internally.
- (b) Full pipeline: **0.4% FPR** on 10k real actions; **17% FNR** on 52 real overeager actions; **5.7% FNR** on 1k synthetic exfiltration attempts. Stage 1 alone: 8.5% FPR / 6.6% / 1.8% FNR.
- Most misses: the danger is recognized, but the classifier wrongly decides that user consent covers the action's blast radius.

**Why it matters for harness/RSI:** It shows how to place the **security layer outside the agent's reasoning**. Action-level gating is complementary to CoT monitoring. A self-improving agent must not be able to edit these layers (cf. auto mode blocking "modifying the agent's own permission config").

**Limitations:** 17% FNR on real overeager actions. Small (n=52) dangerous set. Not a replacement for careful human review on high-stakes infrastructure.

**My questions:** Can consent reasoning ("does approval X cover action Y?") be trained directly? How robust is the classifier to adaptive attackers who know its template?

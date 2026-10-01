# Agent Skills

- **Title:** Equipping agents for the real world with Agent Skills
- **Authors:** Barry Zhang, Keith Lazuka, Mahesh Murag (Anthropic)
- **Year:** Oct 16, 2025 (open standard published Dec 18, 2025 at agentskills.io)
- **Link:** https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- **Status:** read in full

**One-line TL;DR:** A skill is a folder with a `SKILL.md` (YAML `name` + `description`) plus optional scripts and resources, loaded by **three-level progressive disclosure**. It packages procedural knowledge so general agents can specialize without bloating context.

**Problem:** General agents lack organization-specific procedural knowledge. Stuffing it into system prompts wastes the attention budget.

**Method:** Level 1: every skill's name and description pre-loaded in the system prompt. Level 2: full `SKILL.md` read via bash when relevant. Level 3+: bundled files (e.g. `forms.md`, `reference.md`) read only as needed. Skills can include deterministic scripts (e.g. PDF form-field extraction) that run without entering context.

**Key results:** Qualitative. Bundled context becomes "effectively unbounded".

**Why it matters for harness/RSI:** Skills are a **model-writable procedural memory**. The post's stated goal is "to enable agents to create, edit, and evaluate Skills on their own." Skill evolution is a core mechanism in MCE and in harness-evolution work (AHE's "skill" component; Lin et al. 2026 on harness updating).

**Limitations:** Security risk from untrusted skills (exfiltration, malicious code); triggering depends on description quality; no quantitative eval in the post.

**My questions:** How do you evaluate skill triggering precision and recall? Does a growing skill library hit the same tool-confusion problem as large toolsets?

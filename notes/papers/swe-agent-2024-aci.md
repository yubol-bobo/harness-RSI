# SWE-agent — Agent-Computer Interfaces

- **Title:** SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering
- **Authors:** John Yang*, Carlos E. Jimenez*, Alexander Wettig, Kilian Lieret, Shunyu Yao, Karthik Narasimhan, Ofir Press (Princeton)
- **Year:** 2024 (NeurIPS 2024)
- **Link:** https://arxiv.org/abs/2405.15793 ; https://github.com/princeton-nlp/SWE-agent
- **Status:** abstract-level facts via search; I could not read the PDF (arxiv blocked)

**One-line TL;DR:** LMs are a new kind of user, so design an **agent-computer interface (ACI)** for them, with bounded, LM-friendly commands for viewing, searching and editing files (with guardrails). That beats giving the same model raw shell access.

**Problem:** Raw bash is designed for humans. LMs get lost in long outputs, make malformed edits, and can't navigate repos efficiently.

**Method:** Custom commands: a windowed file viewer with scrolling, repo and file search that returns concise results, and an edit command with a **linter guardrail** that rejects syntactically invalid edits. Concise feedback formats. ReAct-style loop.

**Key results:** **12.47% (≈12.5%) pass@1 on full SWE-bench** with GPT-4 Turbo, state of the art at the time. Ablations show the ACI substantially outperforms a shell-only baseline with the same model *(exact ablation numbers unverified)*.

**Why it matters for harness/RSI:** It coined **ACI**, which Anthropic adopted ("invest as much in ACI as HCI"). It is the first strong evidence that *interface design*, not just the model, determines agent performance, i.e. the harness is a lever. Tool descriptions and implementations are 2 of AHE's 7 editable components.

**Limitations:** Python repos only; the custom ACI may become less necessary as models master bash (cf. Anthropic's bash + str_replace approach; mini-SWE-agent).

**My questions:** Which ACI features survive as models improve (guardrails?) and which become unnecessary (windowed viewing)?
